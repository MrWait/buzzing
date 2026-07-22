use anyhow::Result;
use prost::Message;

use proto::idl::{command::Command, translate};

use crate::AppChat;

impl AppChat {
    pub async fn translate_message(&self, req: &translate::TranslateMessageRequest) -> Result<translate::TranslateMessageResponse> {
        let data = self
            .invoke(Command::TranslateMessage as i32, req.encode_to_vec())
            .await?;
        Ok(translate::TranslateMessageResponse::decode(data.as_slice())?)
    }

    pub async fn get_translation_languages(&self) -> Result<translate::GetTranslationLanguagesResponse> {
        let req = translate::GetTranslationLanguagesRequest {};
        let data = self
            .invoke(Command::GetTranslationLanguages as i32, req.encode_to_vec())
            .await?;
        Ok(translate::GetTranslationLanguagesResponse::decode(data.as_slice())?)
    }
}
