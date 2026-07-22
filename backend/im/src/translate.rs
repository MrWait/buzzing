use loco_rs::{Result, app::AppContext};
use prost::Message;
use sea_orm::DbBackend;
use tracing::debug;

use common::time::current_ms;
use common::{UserBrief, common_error, get_translation, pb_decode};
use proto::idl::{entity, error::ErrorCode, translate};

fn extract_text_for_translation(content: &[u8], tpy: i32) -> Result<String> {
    Ok(match tpy {
        1 => {
            let text = entity::MessageText::decode(content)
                .map_err(|e| common_error(&format!("decode text error: {e}")))?;
            text.text
        }
        11 => {
            let text = entity::MessageRichText::decode(content)
                .map_err(|e| common_error(&format!("decode richtext error: {e}")))?;
            text.text
        }
        13 => {
            let md = entity::MessageMarkdown::decode(content)
                .map_err(|e| common_error(&format!("decode markdown error: {e}")))?;
            md.text
        }
        _ => {
            return Err(common_error("unsupported message type for translation"));
        }
    })
}

/// Handle translate_message command (M5-F.7)
pub(crate) async fn translate_message(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<translate::TranslateMessageRequest>(&packet.payload)?;
    debug!("translate: message_id={}, chat_id={}, target={}", req.message_id, req.chat_id, req.target_lang);

    let row = ctx
        .db
        .query_one(Statement::from_sql_and_values(
            DbBackend::Postgres,
            "SELECT content, type FROM messages WHERE id = $1 AND chat_id = $2",
            vec![req.message_id.into(), req.chat_id.into()],
        ))
        .await
        .map_err(|e| common_error(&format!("query message error: {e}")))?
        .ok_or_else(|| common_error("message not found"))?;

    let content: Vec<u8> = row.try_get_by("content").unwrap_or_default();
    let r#type: i16 = row.try_get_by("type").unwrap_or(0);

    let original_text = extract_text_for_translation(&content, r#type as i32)?;

    let svc = get_translation().ok_or_else(|| common_error("translation service not configured"))?;
    let result = svc
        .translate(&original_text, &req.target_lang, None)
        .await
        .map_err(|e| common_error(&format!("translation error: {e}")))?;

    let resp = translate::TranslateMessageResponse {
        message_id: req.message_id,
        original_text: original_text.clone(),
        translated_text: result.translated_text,
        target_lang: req.target_lang,
        source_lang: result.source_lang,
    };
    Ok((ErrorCode::Ok as i32, resp.encode_to_vec()))
}

/// Handle get_translation_languages command (M5-F.8)
pub(crate) async fn get_translation_languages(
    _ctx: &AppContext,
    _brief: &UserBrief,
    _packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let svc = get_translation().ok_or_else(|| common_error("translation service not configured"))?;
    let langs = svc.supported_languages();
    let resp = translate::GetTranslationLanguagesResponse {
        languages: langs
            .into_iter()
            .map(|l| translate::TranslateLanguage {
                code: l.code,
                name: l.name,
            })
            .collect(),
    };
    Ok((ErrorCode::Ok as i32, resp.encode_to_vec()))
}
