use anyhow::Result;
use prost::Message as _;
use std::ops::DerefMut;
use std::sync::atomic::Ordering;
use tracing::{debug, instrument, warn};

use base_db::meta::MetaTable;
use base_util::{gen_i32, thread_id};
use proto::idl::pipeline;
use service::{AppTrait, BizHub};

use crate::AppChat;

impl AppChat {
    /// 拉取并回放离线期间的 pipeline 包（公告变更等进入消息 pipeline 的推送）
    #[instrument(skip(self), fields(sid=gen_i32(), tid=thread_id()))]
    pub(crate) async fn pipeline_sync(&self) {
        if self.pipeline_sync_flag.load(Ordering::Relaxed) {
            debug!("pipeline was syncing");
            return;
        }
        self.pipeline_sync_flag.store(true, Ordering::Relaxed);
        if let Err(err) = self.pipeline_sync_impl().await {
            warn!("pipeline sync error: {:?}", err);
        }
        self.pipeline_sync_flag.store(false, Ordering::Relaxed);
        debug!("pipeline sync finish");
    }

    async fn pipeline_sync_impl(&self) -> Result<()> {
        let mut sid;
        {
            let mut conn = self.db.inner()?;
            let cursor = MetaTable::meta(conn.deref_mut()).get(crate::constant::FLAG_PIPE_CURSOR);
            sid = cursor
                .and_then(|cursor| Ok(cursor.parse::<i64>()))
                .unwrap_or(Ok(0))
                .unwrap_or(0);
        }

        // 服务端 TTL 清理导致管道数据丢失（expired）时，软重置本地数据
        let mut need_reset = false;

        loop {
            let mut req = pipeline::PullPipelineRequest::default();
            req.sid = sid;
            req.count = 50;
            let ack = crate::api::pipe_pull_packet(&req).await?;
            debug!(
                "pipeline pull ack, packets: {}, sid: {}, has_more: {}, expired: {}",
                ack.packets.len(),
                ack.sid,
                ack.has_more,
                ack.expired
            );
            if ack.expired {
                // 数据已丢失（cursor 落后于服务端清理水位，min_sid 供观测）：
                // 服务端仅返回 expired+sid 不含数据，跳过回放，清空本地消息/会话，
                // 并把 feed cursor 置 0 触发全量同步覆盖。见 docs/data_sync §pipeline TTL。
                warn!(
                    "pipeline data expired (watermark {}), soft reset, new sid: {}",
                    ack.min_sid, ack.sid
                );
                self.reset_pipeline_data()?;
                sid = ack.sid;
                need_reset = true;
                break;
            }
            for packet in ack.packets.iter() {
                debug!(
                    "pipeline replay packet, rid: {}, cmd: {}",
                    packet.rid, packet.cmd
                );
                // 复用实时推送的同一分发逻辑（走 hub 统一分发）：
                // PushMessages / PushFeedList / PushChatUpdate 由 app-chat 处理，
                // PushEntityChange(1057) 由 BizHub::invoke_net_command 特化统一分发后按
                // EntityType 到各 service（chat mark dirty / calendar 删删/标脏）。见 docs/data_sync §5。
                if let Ok(hub) = BizHub::get() {
                    let _ = hub.invoke_net_command(1, packet.cmd, &packet.payload).await;
                }
            }
            sid = ack.sid;
            if !ack.has_more {
                break;
            }
        }

        {
            let conn = self.db.inner()?;
            let _ = MetaTable::meta(&conn)
                .insert(crate::constant::FLAG_PIPE_CURSOR, &sid.to_string());
        }

        // 数据丢失重置后：本地已清空，无需拉脏实体，直接全量重建（feed 覆盖 + 消息按需）
        if need_reset {
            self.feed_sync().await;
            return Ok(());
        }

        // 回放完成后，统一拉取本地脏实体（离线期间 PUSH_ENTITY_CHANGE 仅标记 dirty）。
        // 消息类走 PullEntity 全量补齐落库清脏，会话类同步更新成员列表。见 docs/data_sync §5。
        match self.collect_dirty_entities() {
            Ok(dirty_ids) if !dirty_ids.is_empty() => {
                let mut req = pipeline::PullEntityRequest::default();
                req.ids = dirty_ids;
                let mut resp = crate::api::pipe_pull_entity(&req).await?;
                self.save_entity(&resp.entity.get_or_insert_default())?;
                let _ = self.push_entity_changed(&resp.entity.get_or_insert_default());
            }
            Ok(_) => {}
            Err(err) => {
                warn!("collect dirty entities error: {:?}", err);
            }
        }
        Ok(())
    }

    /// 管道数据丢失（expired）后的软重置：
    /// - 消息表清空（保留草稿 status=8，消息走按需通道，打开会话时重新拉取）
    /// - 会话表清空（feed 全量同步会重建）
    /// - feed cursor 置 0（feed 表数据幂等，不清表，下次 feed_sync 全量拉取覆盖）
    fn reset_pipeline_data(&self) -> Result<()> {
        {
            let conn = self.message_db.inner()?;
            conn.execute("DELETE FROM message WHERE status != 8", ())?;
        }
        {
            let conn = self.db.inner()?;
            conn.execute("DELETE FROM chat", ())?;
        }
        {
            let conn = self.db.inner()?;
            MetaTable::meta(&conn).insert(crate::constant::FLAG_FEED_CURSOR, "0")?;
        }
        Ok(())
    }
}
