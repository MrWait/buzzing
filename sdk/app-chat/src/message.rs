use anyhow::Result;
use prost::Message as _;
use service::BizHub;
use std::collections::HashSet;
use tracing::{debug, instrument};

use crate::{message_database, AppChat};
use base_util::{gen_i32, id_gen, thread_id, time::current_ms};
use proto::idl::{command::Command, entity, error::ErrorCode, message};
use service::network::common_request;
use proto::EntityIds;

#[derive(Debug)]
pub(crate) struct PrefetchTask {
    chat_id: i64,
    low: i32,
    high: i32,
}

impl AppChat {
    pub(crate) fn message_init(&self) -> Result<()> {
        let ids;
        {
            let conn = self.message_db.inner()?;
            ids = message_database::message::message_get_all_stash(&conn)?;
        }

        {
            let mut stash_ids = self.stash_ids.write();
            stash_ids.extend(ids.iter());
        }
        base_runtime::spawn(async move {
            if let Ok(hub) = BizHub::get() {
                if let Some(chat) = hub.chat.downcast_ref::<Self>() {
                    chat.message_prefetch_task().await;
                }
            }
        });

        Ok(())
    }

    #[instrument(skip(self), fields(sid=gen_i32(), tid=thread_id()))]
    async fn message_prefetch_task(&self) {
        let mut rx = self.task_rx.lock().await;
        while let Some(task) = rx.recv().await {
            debug!("start message prefetch task: {task:?}");
            let mut entity = entity::Entity::default();
            let _ = self
                .message_fetch(task.chat_id, &mut entity, task.low, task.high, false)
                .await;
            tokio::time::sleep(std::time::Duration::from_millis(200)).await;
        }
    }

    fn message_prefetch(&self, chat_id: i64, low: i32, high: i32) {
        let _ = self.task_tx.send(PrefetchTask { chat_id, low, high });
    }

    pub(crate) fn message_create_draft(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let mut req = message::CreateMessageDraftRequest::decode(params)?;
        let mut resp = message::CreateMessageDraftResponse::default();
        if req.chat_id == 0 || req.message.is_none() {
            return Ok((ErrorCode::Success as i32, vec![]));
        }
        debug!("create draft: req: {:?}", req);
        let client_id = id_gen();
        let mut ids = EntityIds::default();
        let mut entity = entity::Entity::default();
        let msg = req.message.get_or_insert_default();
        let chat_id = req.chat_id;

        ids.feed_ids.insert(chat_id);
        if let Err(err) = self.feed_fill(&mut ids, &mut entity) {
            debug!("feed fill error: {:?}", err);
        }

        if let Some(feed) = entity.feeds.get(&chat_id) {
            debug!("get feed: {:?}", feed);
            msg.pos = feed.refer_pos;
            msg.id = client_id;
            msg.client_id = client_id;
            msg.create_time_ms = current_ms() as i64;
            msg.status = entity::EntityStatus::Fail as i32;
            {
                let conn = self.message_db.inner()?;
                let _ = message_database::message::message_save(&conn, &msg)?;
            }

            {
                let mut stash_ids = self.stash_ids.write();
                stash_ids.insert(client_id);
            }

            resp.client_id = client_id;
        } else {
            debug!("create draft error, feed not exists");
        }
        debug!("create draft finish, resp: {:?}", resp);
        Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
    }

    pub(crate) fn message_get_all_drafts(&self, _params: &[u8]) -> Result<(i32, Vec<u8>)> {
        Ok((ErrorCode::Success as i32, vec![]))
    }

    pub(crate) async fn message_recall(&self, _params: &[u8]) -> Result<(i32, Vec<u8>)> {
        Ok((ErrorCode::Success as i32, vec![]))
    }

    pub(crate) async fn message_get_by_ids(&self, _params: &[u8]) -> Result<(i32, Vec<u8>)> {
        Ok((ErrorCode::Success as i32, vec![]))
    }

    pub(crate) async fn message_get_by_chat(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = message::GetMessageByRangeRequest::decode(params)?;
        debug!("message get by chat, req: {req:?}");
        let mut resp = message::GetMessageByRangeResponse::default();
        if req.chat_id == 0 || req.count == 0 {
            return Ok((ErrorCode::Success as i32, vec![]));
        }
        let direct = entity::Direct::try_from(req.direct)
            .ok()
            .unwrap_or(entity::Direct::None);
        let (low, high) = match direct {
            entity::Direct::None | entity::Direct::Up => (req.pos, req.pos + req.count),
            entity::Direct::Down => (req.pos - req.count, req.pos),
            entity::Direct::Both => (req.pos - req.count, req.pos + req.count),
        };
        let entity = &mut resp.entity.get_or_insert_default();
        debug!("get chat message, req: {:?}", req);
        let _ = self
            .message_fetch(req.chat_id, entity, low, high, true)
            .await;

        let mut entity_ids = EntityIds::default();
        // entity_ids.feed_ids.insert(req.chat_id);
        let _ = self.fill_entity(&mut entity_ids, entity);
        debug!("get chat message, resp: {:?}", resp);
        Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
    }

    /// 已读上报（客户端 → 服务端）：会话已读位置（max_pos + 透传 badge_count）与消息级已读（精确 message_ids）
    /// 两套语义经同一入口上报，服务端拆开处理（见 data_sync §6.2 / §6.3）。
    pub(crate) async fn message_read(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = message::MessageReadRequest::decode(params)?;
        debug!("message read, req: {req:?}");
        let ack = common_request::<message::MessageReadResponse>(
            Command::MessageRead as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        debug!("message read ack: {ack:?}");
        Ok((ErrorCode::Success as i32, vec![]))
    }

    pub(crate) async fn message_send(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {        let mut req = message::SendMessageRequest::decode(params)?;
        if req.client_id == 0 {
            return Ok((ErrorCode::Success as i32, vec![]));
        }

        {
            let conn = self.message_db.inner()?;

            if let Some(ref mut msg) = req.message {
                msg.client_id = req.client_id;
                message_database::message::message_save(&conn, msg)?;
            } else if let Some(row) =
                message_database::message::message_get_by_id(&conn, req.client_id)?
            {
                req.message = Some(row.message);
            } else {
                return Ok((ErrorCode::ErrorParamInvalid as i32, vec![]));
            }
        }
        debug!("start send message: {:?}", req);
        let ack = crate::api::message_send(&req).await?;
        debug!("send message ok: {:?}", ack);

        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub(crate) fn fill_message(
        &self,
        ids: &mut EntityIds,
        entity: &mut entity::Entity,
    ) -> Result<()> {
        {
            let conn = self.message_db.inner()?;
            let message_ids: Vec<_> = ids.message_ids.iter().copied().collect();
            if let Err(err) =
                message_database::message::message_get_by_ids(&conn, &message_ids, entity)
            {
                debug!("get message error: {:?}", err);
            }
        }
        // 已读/表情随内容行本地读取，已并入 entity.readstates / entity.reactions（见 data_sync §5）
        ids.message_ids
            .retain(|id| !entity.messages.contains_key(id));
        Ok(())
    }

    pub(crate) async fn message_fetch(
        &self,
        chat_id: i64,
        entity: &mut entity::Entity,
        mut low: i32,
        mut high: i32,
        prefetch: bool,
    ) -> Result<()> {
        low = std::cmp::max(1, low);
        let last_pos;
        {
            let conn = self.db.inner()?;
            crate::database::feed::feed_get_by_ids(&conn, &vec![chat_id], entity)?;
            if let Some(ref feed) = entity.feeds.get(&chat_id) {
                high = std::cmp::min(high, feed.refer_pos);
                last_pos = feed.refer_pos;
            } else {
                debug!("local feed not exists, abort: {}", chat_id);
                return Ok(());
            }
        }
        let mut pos = HashSet::new();
        pos.extend(low..high);
        debug!(
            "message fetch, chat_id: {}, low: {}, high: {}, pos: {:?}",
            chat_id, low, high, pos,
        );
        if high > 0 {
            let conn = self.message_db.inner()?;
            message_database::message::message_get_by_range(&conn, entity, chat_id, low, high)?;
        } else {
            debug!("chat has no message");
        }

        entity.messages.values().for_each(|msg| {
            if msg.chat_id == chat_id {
                pos.remove(&msg.pos);
            }
        });
        debug!("missing messages, pos: {pos:?}");
        if !pos.is_empty() {
            let mut req = message::GetMessageByPosRequest::default();
            req.chat_id = chat_id;
            req.pos.extend(pos.iter());
            debug!("fetch message from server: {req:?}");
            let mut resp = crate::api::message_get_by_pos(&req).await?;
            debug!("fetch message from server, {resp:?}");
            let _ = self.save_entity(resp.entity.get_or_insert_default());
            let _ = entity.merge(
                resp.entity
                    .get_or_insert_default()
                    .encode_to_vec()
                    .as_slice(),
            );
        }
        if prefetch {
            if low > 1 {
                self.message_prefetch(chat_id, std::cmp::max(low - 30, 1), low);
            }

            if high < last_pos {
                self.message_prefetch(chat_id, high, std::cmp::max(high + 30, last_pos));
            }
        }

        Ok(())
    }

    pub(crate) async fn delete_message(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = message::DeleteMessageRequest::decode(params)?;
        debug!("delete message, req: {req:?}");
        let ack = common_request::<message::DeleteMessageResponse>(
            Command::MessageDelete as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    /// 已读详情：一次性全量返回成员（仅展示用，无需落库）。
    /// 约定：全量数据不上分页；已读状态最多承载到 2000 人的群，超出建议只展示 at 成员，超大群问题后续单独处理。
    pub(crate) async fn get_read_members(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = message::GetReadMembersRequest::decode(params)?;
        debug!("get read members, req: {req:?}");
        let ack = common_request::<message::GetReadMembersResponse>(
            Command::MessageGetReadMembers as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn message_forward(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = message::ForwardMessageRequest::decode(params)?;
        debug!("forward message: {:?}", req);
        let ack = crate::api::forward_message(&req).await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub(crate) fn handle_push_messages(&self, params: &[u8]) -> Result<()> {
        let mut push = message::PushMessages::decode(params)?;
        debug!("handle push messages, push: {:?}", push);
        // 统一实体 ingest：跨模块落库 + 派生客户端通知（方案 A，见 handle_push_entity）
        self.handle_push_entity(&push.entity.get_or_insert_default())
    }
}
