use anyhow::Result;
use prost::Message as _;
use tracing::debug;

use crate::AppChat;
use proto::idl::{command::Command, error::ErrorCode, thread};
use service::network::common_request;

impl AppChat {
    pub(crate) async fn get_thread(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = thread::GetThreadRequest::decode(params)?;
        debug!("get thread, req: {req:?}");
        let ack = common_request::<thread::GetThreadResponse>(
            Command::MessageGetThread as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }
}
