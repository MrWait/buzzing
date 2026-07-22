use anyhow::Result;
use prost::Message as _;
use tracing::debug;

use crate::AppChat;
use proto::idl::{command::Command, error::ErrorCode, pin};
use service::network::common_request;

impl AppChat {
    pub(crate) async fn pin_message(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = pin::PinMessageRequest::decode(params)?;
        debug!("pin message, req: {req:?}");
        let ack = common_request::<pin::PinMessageResponse>(
            Command::ChatPinMessage as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Ok as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn unpin_message(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = pin::UnpinMessageRequest::decode(params)?;
        debug!("unpin message, req: {req:?}");
        let ack = common_request::<pin::UnpinMessageResponse>(
            Command::ChatUnpinMessage as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Ok as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn get_pinned_messages(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = pin::GetPinnedMessagesRequest::decode(params)?;
        debug!("get pinned messages, req: {req:?}");
        let ack = common_request::<pin::GetPinnedMessagesResponse>(
            Command::ChatGetPinnedMessages as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Ok as i32, ack.encode_to_vec()))
    }
}
