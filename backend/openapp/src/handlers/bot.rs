use axum::extract::{Path, Query, State};
use axum::Json;
use loco_rs::prelude::*;
use serde::Deserialize;
use serde_json::{Value, json};
use tracing::{info, warn};

use crate::middleware::AppAuth;
use crate::models::app::OpenAppModel;
use crate::models::bot::OpenAppBotModel;
use crate::models::scheduled_task::ScheduledTaskModel;
use crate::services::rate_limiter::MESSAGE_RATE_LIMITER;
use common::BizHub;
use crate::services::scheduler::TaskScheduler;

#[derive(Deserialize)]
pub struct SendMessageReq {
    pub chat_id: i64,
    pub msg_type: String,
    pub content: Value,
    pub reply_to: Option<i64>,
}

#[derive(Deserialize)]
pub struct EditMessageReq {
    pub msg_type: String,
    pub content: Value,
}

fn msg_type_to_i32(msg_type: &str) -> i32 {
    match msg_type {
        "text" => proto::idl::entity::MessageType::Text as i32,
        "markdown" => proto::idl::entity::MessageType::Markdown as i32,
        "image" => proto::idl::entity::MessageType::Image as i32,
        "file" => proto::idl::entity::MessageType::File as i32,
        "interactive_card" => 17,
        _ => 1, // default text
    }
}

fn serialize_content(msg_type: &str, content: &Value) -> Vec<u8> {
    let content_json = serde_json::to_vec(content).unwrap_or_default();
    match msg_type {
        "text" => {
            let text = content.get("text").and_then(|v| v.as_str()).unwrap_or("");
            let msg_text = proto::idl::entity::MessageText {
                text: text.to_string(),
                mentions: vec![],
            };
            prost::Message::encode_to_vec(&msg_text)
        }
        _ => content_json,
    }
}

fn ok(data: Value) -> Result<Json<Value>> {
    Ok(Json(json!({"code": 0, "message": "ok", "data": data})))
}

pub async fn send_message(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Json(body): Json<SendMessageReq>,
) -> Result<Json<Value>> {
    let app_brief = &auth.0;

    // Rate limit check
    if !MESSAGE_RATE_LIMITER.check(&app_brief.app_id) {
        return Ok(Json(json!({"code": 429, "message": "rate limit exceeded", "data": null})));
    }

    // 验证应用为 Bot 类型且已启用
    let app = OpenAppModel::find_by_app_id(&ctx.db, &app_brief.app_id)
        .await
        .map_err(|e| {
            warn!("find app error: {e}");
            loco_rs::Error::InternalServerError
        })?
        .ok_or_else(|| loco_rs::Error::NotFound)?;

    if app.0.app_type != 1 {
        return Err(loco_rs::Error::BadRequest("app is not a bot".into()));
    }

    let bot = OpenAppBotModel::find_by_app(&ctx.db, app.0.id)
        .await
        .map_err(|e| {
            warn!("find bot error: {e}");
            loco_rs::Error::InternalServerError
        })?
        .ok_or_else(|| loco_rs::Error::NotFound)?;

    let bot_user_id = bot.0.bot_user_id;
    let msg_type_i32 = msg_type_to_i32(&body.msg_type);
    let content_bytes = serialize_content(&body.msg_type, &body.content);
    let summary = body
        .content
        .get("text")
        .and_then(|v| v.as_str())
        .unwrap_or("")
        .to_string();

    let hub = BizHub::get().map_err(|_| loco_rs::Error::InternalServerError)?;
    let ub = app_brief.to_user_brief();
    let message_id = hub
        .im
        .send_message(
            &ctx,
            &ub,
            bot_user_id,
            body.chat_id,
            msg_type_i32,
            content_bytes,
            summary,
        )
        .await
        .map_err(|e| {
            warn!("send message error: {e}");
            loco_rs::Error::InternalServerError
        })?;

    info!("bot send message success: message_id={message_id}");
    ok(json!({"message_id": message_id}))
}

pub async fn edit_message(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Path(message_id): Path<i64>,
    Json(body): Json<EditMessageReq>,
) -> Result<Json<Value>> {
    let content_bytes = serialize_content(&body.msg_type, &body.content);
    let summary = body
        .content
        .get("text")
        .and_then(|v| v.as_str())
        .unwrap_or("")
        .to_string();

    let hub = BizHub::get().map_err(|_| loco_rs::Error::InternalServerError)?;
    let ub = auth.0.to_user_brief();
    hub.im
        .edit_message(&ctx, &ub, message_id, content_bytes, summary)
        .await
        .map_err(|e| {
            warn!("edit message error: {e}");
            loco_rs::Error::InternalServerError
        })?;

    ok(json!({"message_id": message_id}))
}

pub async fn recall_message(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Path(message_id): Path<i64>,
) -> Result<Json<Value>> {
    let hub = BizHub::get().map_err(|_| loco_rs::Error::InternalServerError)?;
    let ub = auth.0.to_user_brief();
    hub.im
        .recall_message(&ctx, &ub, message_id)
        .await
        .map_err(|e| {
            warn!("recall message error: {e}");
            loco_rs::Error::InternalServerError
        })?;

    ok(json!({"message_id": message_id}))
}

// ─── Reaction API ─────────────────────────────────────

#[derive(Deserialize)]
pub struct ReactionReq {
    pub reaction_type: String,
}

pub async fn add_reaction(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Path(message_id): Path<i64>,
    Json(body): Json<ReactionReq>,
) -> Result<Json<Value>> {
    let hub = BizHub::get().map_err(|_| loco_rs::Error::InternalServerError)?;
    let ub = auth.0.to_user_brief();
    hub.im.add_message_reaction(&ctx, &ub, message_id, &body.reaction_type).await.map_err(|e| {
        warn!("add reaction error: {e}");
        loco_rs::Error::InternalServerError
    })?;
    ok(json!({"success": true}))
}

pub async fn remove_reaction(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Path(message_id): Path<i64>,
    Json(body): Json<ReactionReq>,
) -> Result<Json<Value>> {
    let hub = BizHub::get().map_err(|_| loco_rs::Error::InternalServerError)?;
    let ub = auth.0.to_user_brief();
    hub.im.remove_message_reaction(&ctx, &ub, message_id, &body.reaction_type).await.map_err(|e| {
        warn!("remove reaction error: {e}");
        loco_rs::Error::InternalServerError
    })?;
    ok(json!({"success": true}))
}

// ─── M3: Bot 群管理 ────────────────────────────────────

#[derive(Deserialize)]
pub struct CreateChatReq {
    pub name: String,
    #[serde(default)]
    pub description: String,
    #[serde(default)]
    pub member_ids: Vec<i64>,
}

pub async fn create_chat(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Json(body): Json<CreateChatReq>,
) -> Result<Json<Value>> {
    let hub = BizHub::get().map_err(|_| loco_rs::Error::InternalServerError)?;
    let ub = auth.0.to_user_brief();
    let chat_id = hub
        .im
        .create_bot_chat(&ctx, &ub, &body.name, &body.description, &body.member_ids)
        .await
        .map_err(|e| {
            warn!("bot create chat error: {e}");
            loco_rs::Error::InternalServerError
        })?;
    ok(json!({"chat_id": chat_id}))
}

#[derive(Deserialize)]
pub struct ChatMembersReq {
    pub member_ids: Vec<i64>,
}

pub async fn add_chat_members(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Path(chat_id): Path<i64>,
    Json(body): Json<ChatMembersReq>,
) -> Result<Json<Value>> {
    let hub = BizHub::get().map_err(|_| loco_rs::Error::InternalServerError)?;
    let ub = auth.0.to_user_brief();
    hub.im
        .add_chat_members(&ctx, &ub, chat_id, &body.member_ids)
        .await
        .map_err(|e| {
            warn!("bot add chat members error: {e}");
            loco_rs::Error::InternalServerError
        })?;
    ok(json!({"success": true}))
}

pub async fn remove_chat_members(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Path(chat_id): Path<i64>,
    Json(body): Json<ChatMembersReq>,
) -> Result<Json<Value>> {
    let hub = BizHub::get().map_err(|_| loco_rs::Error::InternalServerError)?;
    let ub = auth.0.to_user_brief();
    hub.im
        .remove_chat_members(&ctx, &ub, chat_id, &body.member_ids)
        .await
        .map_err(|e| {
            warn!("bot remove chat members error: {e}");
            loco_rs::Error::InternalServerError
        })?;
    ok(json!({"success": true}))
}

#[derive(Deserialize)]
pub struct AnnouncementReq {
    pub announcement: String,
}

pub async fn set_announcement(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Path(chat_id): Path<i64>,
    Json(body): Json<AnnouncementReq>,
) -> Result<Json<Value>> {
    let hub = BizHub::get().map_err(|_| loco_rs::Error::InternalServerError)?;
    let ub = auth.0.to_user_brief();
    hub.im
        .set_chat_announcement(&ctx, &ub, chat_id, &body.announcement)
        .await
        .map_err(|e| {
            warn!("bot set announcement error: {e}");
            loco_rs::Error::InternalServerError
        })?;
    ok(json!({"success": true}))
}

// ─── M3: Scheduled Task ────────────────────────────────

#[derive(Deserialize)]
pub struct CreateScheduledTaskReq {
    pub name: String,
    pub cron_expr: String,
    pub action_type: String,
    pub action_config: Value,
    pub chat_id: Option<i64>,
}

#[derive(Deserialize)]
pub struct UpdateScheduledTaskReq {
    pub name: Option<String>,
    pub cron_expr: Option<String>,
    pub action_config: Option<Value>,
    pub status: Option<i16>,
}

pub async fn create_scheduled_task(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Json(body): Json<CreateScheduledTaskReq>,
) -> Result<Json<Value>> {
    let task = ScheduledTaskModel::create(
        &ctx.db,
        auth.0.app_db_id,
        &body.name,
        &body.cron_expr,
        &body.action_type,
        body.action_config,
        body.chat_id,
    )
    .await
    .map_err(|e| {
        warn!("create scheduled task error: {e}");
        loco_rs::Error::InternalServerError
    })?;
    ok(task.to_json())
}

pub async fn list_scheduled_tasks(
    auth: AppAuth,
    State(ctx): State<AppContext>,
) -> Result<Json<Value>> {
    let tasks = ScheduledTaskModel::find_by_app(&ctx.db, auth.0.app_db_id)
        .await
        .map_err(|e| {
            warn!("list scheduled tasks error: {e}");
            loco_rs::Error::InternalServerError
        })?;
    let items: Vec<Value> = tasks.iter().map(|t| t.to_json()).collect();
    ok(json!({"items": items, "total": items.len()}))
}

pub async fn update_scheduled_task(
    _auth: AppAuth,
    State(ctx): State<AppContext>,
    Path(task_id): Path<i64>,
    Json(body): Json<UpdateScheduledTaskReq>,
) -> Result<Json<Value>> {
    let task = ScheduledTaskModel::update(
        &ctx.db,
        task_id,
        body.name.as_deref(),
        body.cron_expr.as_deref(),
        body.action_config,
        body.status,
    )
    .await
    .map_err(|e| {
        warn!("update scheduled task error: {e}");
        loco_rs::Error::InternalServerError
    })?
    .ok_or_else(|| loco_rs::Error::NotFound)?;
    ok(task.to_json())
}

pub async fn delete_scheduled_task(
    _auth: AppAuth,
    State(ctx): State<AppContext>,
    Path(task_id): Path<i64>,
) -> Result<Json<Value>> {
    let deleted = ScheduledTaskModel::delete(&ctx.db, task_id)
        .await
        .map_err(|e| {
            warn!("delete scheduled task error: {e}");
            loco_rs::Error::InternalServerError
        })?;
    if !deleted {
        return Err(loco_rs::Error::NotFound);
    }
    ok(json!({"deleted": true}))
}

pub async fn pause_scheduled_task(
    _auth: AppAuth,
    State(ctx): State<AppContext>,
    Path(task_id): Path<i64>,
) -> Result<Json<Value>> {
    let task = ScheduledTaskModel::set_status(&ctx.db, task_id, 0)
        .await
        .map_err(|e| {
            warn!("pause scheduled task error: {e}");
            loco_rs::Error::InternalServerError
        })?
        .ok_or_else(|| loco_rs::Error::NotFound)?;
    ok(task.to_json())
}

pub async fn resume_scheduled_task(
    _auth: AppAuth,
    State(ctx): State<AppContext>,
    Path(task_id): Path<i64>,
) -> Result<Json<Value>> {
    let task = ScheduledTaskModel::set_status(&ctx.db, task_id, 1)
        .await
        .map_err(|e| {
            warn!("resume scheduled task error: {e}");
            loco_rs::Error::InternalServerError
        })?
        .ok_or_else(|| loco_rs::Error::NotFound)?;
    ok(task.to_json())
}
