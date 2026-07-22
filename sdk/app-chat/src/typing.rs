use anyhow::Result;
use prost::Message as _;
use tracing::debug;

use crate::AppChat;
use proto::idl::{command::Command, error::ErrorCode, typing};
use service::network::common_request;

impl AppChat {
    pub(crate) async fn send_typing(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = typing::TypingRequest::decode(params)?;
        debug!("send typing, req: {req:?}");
        let ack = common_request::<typing::TypingResponse>(
            Command::Typing as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Ok as i32, ack.encode_to_vec()))
    }
}
