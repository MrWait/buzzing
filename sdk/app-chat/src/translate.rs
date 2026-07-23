use anyhow::Result;
use prost::Message as _;
use tracing::debug;

use proto::idl::{command::Command, error::ErrorCode, translate};
use service::network::common_request;

use crate::AppChat;

impl AppChat {
    pub(crate) async fn translate_message(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = translate::TranslateMessageRequest::decode(params)?;
        debug!("translate message, req: {req:?}");
        let ack = common_request::<translate::TranslateMessageResponse>(
            Command::TranslateMessage as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Ok as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn get_translation_languages(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = translate::GetTranslationLanguagesRequest::decode(params)?;
        debug!("get translation languages, req: {req:?}");
        let ack = common_request::<translate::GetTranslationLanguagesResponse>(
            Command::GetTranslationLanguages as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Ok as i32, ack.encode_to_vec()))
    }
}
