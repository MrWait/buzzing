use anyhow::Result;
use prost::Message as _;
use std::ops::DerefMut;
use std::sync::atomic::Ordering;
use tracing::{debug, instrument, warn};

use base_db::meta::MetaTable;
use base_util::{gen_i32, thread_id};
use proto::idl::pipeline;
use service::AppTrait;

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

        loop {
            let mut req = pipeline::PullPipelineRequest::default();
            req.sid = sid;
            req.count = 50;
            let ack = crate::api::pipe_pull_packet(&req).await?;
            debug!("pipeline pull ack: {:?}", ack);
            for packet in ack.packets.iter() {
                debug!(
                    "pipeline replay packet, rid: {}, cmd: {}",
                    packet.rid, packet.cmd
                );
                // 复用实时推送的同一分发逻辑（PushMessages / PushFeedList）
                let _ = self
                    .on_net_command(1, packet.cmd, &packet.payload)
                    .await;
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
}
