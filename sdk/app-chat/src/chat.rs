use anyhow::Result;
use prost::Message as _;
use tracing::debug;

use crate::AppChat;
use proto::idl::{chat, command::Command, entity, error::ErrorCode};
use proto::EntityIds;
use service::network::common_request;

impl AppChat {
    pub(crate) async fn chat_create(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = chat::CreateChatRequest::decode(params)?;
        debug!("start chat create: {:?}", req);

        let ack = crate::api::chat_create(&req).await?;
        debug!("create chat ok: {:?}", ack);
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn chat_add_chatters(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = chat::AddChatChatterRequest::decode(params)?;
        debug!("chat add chatters, req: {req:?}");

        let ack = common_request::<chat::AddChatChatterResponse>(
            Command::ChatAddChatters as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn chat_delete_chatters(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = chat::RemoveChatChatterRequest::decode(params)?;
        debug!("chat delete chatters, req: {req:?}");
        let ack = common_request::<chat::RemoveChatChatterResponse>(
            Command::ChatDeleteChatters as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn chat_get_by_ids(&self, _params: &[u8]) -> Result<(i32, Vec<u8>)> {
        Ok((ErrorCode::Success as i32, vec![]))
    }

    pub(crate) fn chat_fill(&self, ids: &mut EntityIds, entity: &mut entity::Entity) -> Result<()> {
        {
            let conn = self.db.inner()?;
            let chat_ids: Vec<_> = ids.chat_ids.iter().copied().collect();
            if let Err(err) = crate::database::chat::chat_get_by_ids(&conn, &chat_ids, entity) {
                debug!("chat get error: {:?}", err);
            }
        }
        ids.chat_ids.retain(|id| !entity.chats.contains_key(id));
        Ok(())
    }

    pub(crate) async fn chat_update(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = chat::UpdateChatRequest::decode(params)?;
        debug!("chat update, req: {req:?}");
        let ack = common_request::<chat::UpdateChatResponse>(
            Command::ChatUpdate as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub async fn chat_quit(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = chat::QuitChatRequest::decode(params)?;
        debug!("chat quit, req: {req:?}");
        let ack = common_request::<chat::QuitChatResponse>(
            Command::ChatQuit as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub async fn chat_dismiss(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = chat::DismissChatRequest::decode(params)?;
        debug!("chat dismiss, req: {req:?}");
        let ack = common_request::<chat::DismissChatResponse>(
            Command::ChatDismiss as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub fn chat_set_draft(&self, _params: &[u8]) -> Result<(i32, Vec<u8>)> {
        Ok((0, vec![]))
    }

    pub fn chat_get_draft(&self, _params: &[u8]) -> Result<(i32, Vec<u8>)> {
        Ok((0, vec![]))
    }

    // ─── M2: Announcement ───────────────────────────────────────────────

    pub(crate) async fn chat_set_announcement(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = chat::SetAnnouncementRequest::decode(params)?;
        debug!("chat set announcement, req: {req:?}");
        let ack = common_request::<chat::SetAnnouncementResponse>(
            Command::ChatSetAnnouncement as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn chat_delete_announcement(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = chat::DeleteAnnouncementRequest::decode(params)?;
        debug!("chat delete announcement, req: {req:?}");
        let ack = common_request::<chat::DeleteAnnouncementResponse>(
            Command::ChatDeleteAnnouncement as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    // ─── M2: Members ────────────────────────────────────────────────────

    pub(crate) async fn chat_get_members(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = chat::GetMembersRequest::decode(params)?;
        debug!("chat get members, req: {req:?}");
        let ack = common_request::<chat::GetMembersResponse>(
            Command::ChatGetMembers as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }
}
