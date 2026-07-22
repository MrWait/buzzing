use anyhow::Result;
use prost::Message as _;
use tracing::debug;

use crate::AppChat;
use proto::idl::{command::Command, error::ErrorCode, presence};
use service::network::common_request;

impl AppChat {
    pub(crate) async fn presence_update(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = presence::PresenceUpdateRequest::decode(params)?;
        debug!("presence update, req: {req:?}");
        let ack = common_request::<presence::PresenceUpdateResponse>(
            Command::UserPresenceUpdate as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Ok as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn presence_subscribe(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = presence::PresenceSubscribeRequest::decode(params)?;
        debug!("presence subscribe, req: {req:?}");
        let ack = common_request::<presence::PresenceSubscribeResponse>(
            Command::UserPresenceSubscribe as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Ok as i32, ack.encode_to_vec()))
    }
}
