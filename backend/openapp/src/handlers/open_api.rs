use axum::extract::{Path, Query, State};
use axum::Json;
use loco_rs::prelude::*;
use serde::Deserialize;
use serde_json::{Value, json};
use tracing::{info, warn};

use crate::middleware::AppAuth;
use crate::models::api_stat::ApiStatModel;
use common::BizHub;
use crate::error::OpenAppError;

#[derive(Deserialize)]
pub struct PageQuery {
    pub page: Option<i32>,
    pub page_size: Option<i32>,
}

#[derive(Deserialize)]
pub struct BatchUserReq {
    pub user_ids: Vec<i64>,
}

#[derive(Deserialize)]
pub struct ListEventsQuery {
    pub start: Option<i64>,
    pub end: Option<i64>,
    pub calendar_id: Option<i64>,
}

#[derive(Deserialize)]
pub struct CreateEventReq {
    pub title: String,
    pub start_time: i64,
    pub end_time: i64,
    pub attendees: Option<Vec<i64>>,
}

#[derive(Deserialize)]
pub struct SendMessageReq {
    pub chat_id: i64,
    pub msg_type: String,
    pub content: Value,
    pub reply_to: Option<i64>,
}

#[derive(Deserialize)]
pub struct ListMessagesQuery {
    pub page: Option<i32>,
    pub page_size: Option<i32>,
    pub before_id: Option<i64>,
}

#[derive(Deserialize)]
pub struct StatsPeriodQuery {
    pub period: Option<String>,
    pub days: Option<i32>,
}

fn ok(data: Value) -> Result<Json<Value>> {
    Ok(Json(json!({"code": 0, "message": "ok", "data": data})))
}

fn hub() -> Result<std::sync::Arc<BizHub>> {
    BizHub::get().map_err(|_| loco_rs::Error::InternalServerError)
}

fn msg_type_str_to_i32(s: &str) -> i32 {
    match s {
        "text" => 13,
        "markdown" => 15,
        "image" => 14,
        "file" => 16,
        "interactive_card" => 17,
        _ => 13,
    }
}

// ─── IM API ──────────────────────────────────────────────

pub async fn get_chat(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Path(chat_id): Path<i64>,
) -> Result<Json<Value>> {
    auth.0.require_scope("im:chat:read").map_err(|e| {
        warn!("scope denied: {e}");
        loco_rs::Error::Unauthorized("forbidden".into())
    })?;
    let h = hub()?;
    let ub = auth.0.to_user_brief();
    let chat = h.im.get_chat(&ctx, &ub, chat_id).await.map_err(|e| {
        warn!("get chat error: {e}");
        loco_rs::Error::NotFound
    })?;
    let json_str = serde_json::to_string(&chat).unwrap_or_default();
    let val: Value = serde_json::from_str(&json_str).unwrap_or_default();
    ok(val)
}

pub async fn list_chat_members(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Path(chat_id): Path<i64>,
    Query(query): Query<PageQuery>,
) -> Result<Json<Value>> {
    auth.0.require_scope("im:chat:read").map_err(|_| loco_rs::Error::Unauthorized("forbidden".into()))?;
    let h = hub()?;
    let ub = auth.0.to_user_brief();
    let members = h.im.list_chat_members(&ctx, &ub, chat_id, query.page.unwrap_or(1), query.page_size.unwrap_or(50)).await.map_err(|e| {
        warn!("list members error: {e}");
        loco_rs::Error::NotFound
    })?;
    ok(json!({"items": members, "total": members.len()}))
}

pub async fn send_message(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Json(body): Json<SendMessageReq>,
) -> Result<Json<Value>> {
    auth.0.require_scope("im:message:write").map_err(|_| loco_rs::Error::Unauthorized("forbidden".into()))?;
    let h = hub()?;

    let content_bytes = serde_json::to_vec(&body.content)
        .map_err(|e| loco_rs::Error::BadRequest(format!("invalid content: {e}")))?;
    let msg_type = msg_type_str_to_i32(&body.msg_type);

    let from_id = auth.0.app_db_id;
    let ub = auth.0.to_user_brief();

    let message_id = h.im.send_message(&ctx, &ub, from_id, body.chat_id, msg_type, content_bytes, "".to_string()).await.map_err(|e| {
        warn!("send message error: {e}");
        loco_rs::Error::InternalServerError
    })?;

    ok(json!({"message_id": message_id}))
}

pub async fn list_messages(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Path(chat_id): Path<i64>,
    Query(query): Query<ListMessagesQuery>,
) -> Result<Json<Value>> {
    auth.0.require_scope("im:message:read").map_err(|_| loco_rs::Error::Unauthorized("forbidden".into()))?;
    let h = hub()?;
    let ub = auth.0.to_user_brief();
    let entity = h.im.list_messages(&ctx, &ub, chat_id, query.page.unwrap_or(1), query.page_size.unwrap_or(20), query.before_id).await.map_err(|e| {
        warn!("list messages error: {e}");
        loco_rs::Error::InternalServerError
    })?;
    let json_str = serde_json::to_string(&entity).unwrap_or_default();
    let val: Value = serde_json::from_str(&json_str).unwrap_or_default();
    ok(val)
}

pub async fn get_user(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Path(user_id): Path<i64>,
) -> Result<Json<Value>> {
    auth.0.require_scope("user:info:read").map_err(|_| loco_rs::Error::Unauthorized("forbidden".into()))?;
    let h = hub()?;
    let user = h.user.get_user_by_id(&ctx, user_id).await.map_err(|e| {
        warn!("get user error: {e}");
        loco_rs::Error::NotFound
    })?;
    let json_str = serde_json::to_string(&user).unwrap_or_default();
    let val: Value = serde_json::from_str(&json_str).unwrap_or_default();
    ok(val)
}

pub async fn batch_get_users(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Json(body): Json<BatchUserReq>,
) -> Result<Json<Value>> {
    auth.0.require_scope("user:info:read").map_err(|_| loco_rs::Error::Unauthorized("forbidden".into()))?;
    let h = hub()?;
    let users = h.user.get_user_by_ids(&ctx, body.user_ids).await.map_err(|e| {
        warn!("batch get users error: {e}");
        loco_rs::Error::InternalServerError
    })?;
    let items: Vec<Value> = users.iter().map(|u| {
        let json_str = serde_json::to_string(u).unwrap_or_default();
        serde_json::from_str(&json_str).unwrap_or_default()
    }).collect();
    ok(json!({"items": items}))
}

pub async fn list_depts(
    auth: AppAuth,
    State(ctx): State<AppContext>,
) -> Result<Json<Value>> {
    auth.0.require_scope("user:dept:read").map_err(|_| loco_rs::Error::Unauthorized("forbidden".into()))?;
    let h = hub()?;
    let ub = auth.0.to_user_brief();
    let depts = h.user.list_depts(&ctx, &ub, auth.0.tenant_id).await.map_err(|e| {
        warn!("list depts error: {e}");
        loco_rs::Error::InternalServerError
    })?;
    let items: Vec<Value> = depts.iter().map(|d| {
        let json_str = serde_json::to_string(d).unwrap_or_default();
        serde_json::from_str(&json_str).unwrap_or_default()
    }).collect();
    ok(json!({"items": items}))
}

pub async fn get_dept(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Path(dept_id): Path<i64>,
) -> Result<Json<Value>> {
    auth.0.require_scope("user:dept:read").map_err(|_| loco_rs::Error::Unauthorized("forbidden".into()))?;
    let h = hub()?;
    let ub = auth.0.to_user_brief();
    let dept = h.user.get_dept(&ctx, &ub, dept_id).await.map_err(|e| {
        warn!("get dept error: {e}");
        loco_rs::Error::NotFound
    })?;
    let json_str = serde_json::to_string(&dept).unwrap_or_default();
    let val: Value = serde_json::from_str(&json_str).unwrap_or_default();
    ok(val)
}

pub async fn list_dept_members(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Path(dept_id): Path<i64>,
    Query(query): Query<PageQuery>,
) -> Result<Json<Value>> {
    auth.0.require_scope("user:dept:read").map_err(|_| loco_rs::Error::Unauthorized("forbidden".into()))?;
    let h = hub()?;
    let ub = auth.0.to_user_brief();
    let members = h.user.list_dept_members(&ctx, &ub, dept_id, query.page.unwrap_or(1), query.page_size.unwrap_or(50)).await.map_err(|e| {
        warn!("list dept members error: {e}");
        loco_rs::Error::InternalServerError
    })?;
    let items: Vec<Value> = members.iter().map(|m| {
        let json_str = serde_json::to_string(m).unwrap_or_default();
        serde_json::from_str(&json_str).unwrap_or_default()
    }).collect();
    ok(json!({"items": items, "total": items.len()}))
}

pub async fn list_calendars(
    auth: AppAuth,
    State(ctx): State<AppContext>,
) -> Result<Json<Value>> {
    auth.0.require_scope("calendar:event:read").map_err(|_| loco_rs::Error::Unauthorized("forbidden".into()))?;
    let h = hub()?;
    let ub = auth.0.to_user_brief();
    let cals = h.calendar.list_calendars(&ctx, &ub, auth.0.tenant_id).await.map_err(|e| {
        warn!("list calendars error: {e}");
        loco_rs::Error::InternalServerError
    })?;
    let items: Vec<Value> = cals.iter().map(|c| {
        let json_str = serde_json::to_string(c).unwrap_or_default();
        serde_json::from_str(&json_str).unwrap_or_default()
    }).collect();
    ok(json!({"items": items}))
}

pub async fn list_events(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Query(query): Query<ListEventsQuery>,
) -> Result<Json<Value>> {
    auth.0.require_scope("calendar:event:read").map_err(|_| loco_rs::Error::Unauthorized("forbidden".into()))?;
    let h = hub()?;
    let cal_id = query.calendar_id.unwrap_or(0);
    let ub = auth.0.to_user_brief();
    let events = h.calendar.list_events(&ctx, &ub, cal_id, query.start.unwrap_or(0), query.end.unwrap_or(0)).await.map_err(|e| {
        warn!("list events error: {e}");
        loco_rs::Error::InternalServerError
    })?;
    let items: Vec<Value> = events.iter().map(|e| {
        let json_str = serde_json::to_string(e).unwrap_or_default();
        serde_json::from_str(&json_str).unwrap_or_default()
    }).collect();
    ok(json!({"items": items}))
}

pub async fn create_event(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Json(body): Json<CreateEventReq>,
) -> Result<Json<Value>> {
    auth.0.require_scope("calendar:event:write").map_err(|_| loco_rs::Error::Unauthorized("forbidden".into()))?;
    let h = hub()?;
    let attendees = body.attendees.as_deref().unwrap_or(&[]);
    let ub = auth.0.to_user_brief();
    let event_id = h.calendar.create_event(&ctx, &ub, 0, &body.title, body.start_time, body.end_time, attendees).await.map_err(|e| {
        warn!("create event error: {e}");
        loco_rs::Error::InternalServerError
    })?;
    ok(json!({"event_id": event_id}))
}

// ─── Stats API (called via admin, not open API) ────────

pub async fn get_app_stats(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(app_id): Path<i64>,
    Query(query): Query<StatsPeriodQuery>,
) -> Result<Json<Value>> {
    let _brief = common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;

    let days = query.days.unwrap_or(7).max(1).min(90);
    let stats = ApiStatModel::get_daily_summary(&ctx.db, app_id, days).await.map_err(|e| {
        warn!("get stats error: {e}");
        loco_rs::Error::InternalServerError
    })?;

    let items: Vec<Value> = stats.iter().map(|s| {
        json!({
            "date": s.date,
            "endpoint": s.endpoint,
            "call_count": s.call_count,
            "error_count": s.error_count,
            "total_latency_ms": s.total_latency_ms,
        })
    }).collect();

    ok(json!({"items": items}))
}

pub async fn get_error_logs(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(app_id): Path<i64>,
    Query(query): Query<StatsPeriodQuery>,
) -> Result<Json<Value>> {
    let _brief = common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;

    let days = query.days.unwrap_or(7).max(1).min(90);
    let stats = ApiStatModel::get_daily_summary(&ctx.db, app_id, days).await.map_err(|e| {
        warn!("get error logs error: {e}");
        loco_rs::Error::InternalServerError
    })?;

    let items: Vec<Value> = stats.iter().filter(|s| s.error_count > 0).map(|s| {
        json!({
            "date": s.date,
            "endpoint": s.endpoint,
            "error_count": s.error_count,
        })
    }).collect();

    ok(json!({"items": items}))
}
