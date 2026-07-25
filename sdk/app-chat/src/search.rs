use anyhow::Result;
use prost::Message as _;
use tracing::debug;

use crate::AppChat;
use proto::idl::{command::Command, error::ErrorCode, search};
use service::network::common_request;

impl AppChat {
    pub(crate) async fn search_messages(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = search::SearchRequest::decode(params)?;
        debug!("search messages, req: {req:?}");
        let ack = common_request::<search::SearchMessagesResponse>(
            Command::SearchMessage as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn search_chats(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = search::SearchRequest::decode(params)?;
        debug!("search chats, req: {req:?}");
        let ack = common_request::<search::SearchChatsResponse>(
            Command::SearchChat as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn search_users(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = search::SearchRequest::decode(params)?;
        debug!("search users, req: {req:?}");
        let ack = common_request::<search::SearchUsersResponse>(
            Command::SearchUser as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn search_files(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = search::SearchRequest::decode(params)?;
        debug!("search files, req: {req:?}");
        let ack = common_request::<search::SearchFilesResponse>(
            Command::SearchFiles as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn global_search(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = search::GlobalSearchRequest::decode(params)?;
        debug!("global search, req: {req:?}");
        let ack = common_request::<search::GlobalSearchResponse>(
            Command::GlobalSearch as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }
}
