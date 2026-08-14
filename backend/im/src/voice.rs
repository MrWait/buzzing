use loco_rs::{Result, app::AppContext};
use prost::Message;
use sea_orm::{ConnectionTrait, DbBackend, Statement};
use tracing::debug;

use crate::models::messages::MessageModel;
use common::time::current_ms;
use common::{UserBrief, common_error, get_asr, pb_decode};
use proto::idl::{entity, error::ErrorCode};

pub(crate) async fn transcribe_voice(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<entity::TranscribeVoiceRequest>(&packet.payload)?;
    let mut resp = entity::TranscribeVoiceResponse::default();
    debug!("transcribe voice: message_id={}, chat_id={}", req.message_id, req.chat_id);

    let msg = MessageModel::find_by_id(&ctx.db, req.message_id)
        .await
        .map_err(|e| common_error(&format!("message not found: {e}")))?;

    if msg.r#type as i32 != entity::MessageType::Voice as i32 {
        return Err(common_error("not a voice message"));
    }

    let voice = entity::VoiceContent::decode(msg.content.as_slice())
        .map_err(|e| common_error(&format!("decode voice content error: {e}")))?;

    let text = if let Some(asr) = get_asr() {
        asr.transcribe(&voice.url, voice.duration_sec).await?
    } else {
        "[转文字功能未配置]".to_string()
    };

    let mut updated = voice;
    updated.transcription = text.clone();
    updated.transcription_status = 2;

    let summary = format!("[语音] {}", text.chars().take(80).collect::<String>());
    let content_final = updated.encode_to_vec();
    let ts = current_ms() as i64;

    ctx.db.execute(Statement::from_sql_and_values(
        DbBackend::Postgres,
        "UPDATE messages SET content = $1, summary = $2, version = $3 WHERE id = $4",
        vec![content_final.into(), summary.into(), ts.into(), req.message_id.into()],
    ))
    .await
    .map_err(|e| common_error(&format!("update message error: {e}")))?;

    let member_ids = super::chat::chat_get_all_user_ids(ctx, req.chat_id).await?;
    // 转写属内容变更，携带消息体推送
    super::message::push_messages(ctx, brief, &member_ids, &[req.message_id], true).await?;
    // 转写属消息内容变更：内容已由 1211 实时送达在线端，这里仅持久化到 pipeline
    // 供离线端重连回放后 mark dirty + 懒拉，见 docs/data_sync §5
    let _ = super::message::push_entity_changed(
        ctx,
        &member_ids,
        &[req.message_id],
        ts,
        entity::Operate::Update,
        entity::EntityType::Message,
        common::SendMode::Persist,
    )
    .await;

    resp.message_id = req.message_id;
    resp.transcription = text;
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}
