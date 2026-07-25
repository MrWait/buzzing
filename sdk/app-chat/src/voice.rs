use anyhow::Result;
use prost::Message as _;
use tracing::debug;

use crate::AppChat;
use proto::idl::{command::Command, entity, error::ErrorCode};
use service::network::common_request;

impl AppChat {
    pub(crate) async fn transcribe_voice(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = entity::TranscribeVoiceRequest::decode(params)?;
        debug!("transcribe voice, req: {req:?}");
        let ack = common_request::<entity::TranscribeVoiceResponse>(
            Command::VoiceTranscribe as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }
}
