use anyhow::Result;
use prost::Message as _;
use tracing::debug;

use crate::AppChat;
use proto::idl::{command::Command, error::ErrorCode, mute};
use service::network::common_request;

impl AppChat {
    pub(crate) async fn mute_member(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = mute::MuteMemberRequest::decode(params)?;
        debug!("mute member, req: {req:?}");
        let ack = common_request::<mute::MuteMemberResponse>(
            Command::ChatMuteMember as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Ok as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn global_mute(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = mute::GlobalMuteRequest::decode(params)?;
        debug!("global mute, req: {req:?}");
        let ack = common_request::<mute::GlobalMuteResponse>(
            Command::ChatGlobalMute as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Ok as i32, ack.encode_to_vec()))
    }
}
