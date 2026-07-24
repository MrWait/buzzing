use axum::extract::{Path, Query, State};
use axum::Json;
use loco_rs::prelude::*;
use serde::Deserialize;
use serde_json::{Value, json};
use tracing::{info, warn};

use crate::error::OpenAppError;
use crate::models::app::OpenAppModel;
use crate::models::bot::OpenAppBotModel;
use crate::models::outgoing_webhook::OutgoingWebhookModel;
use crate::services::auth as auth_svc;

#[derive(Deserialize)]
pub struct ListQuery {
    pub page: Option<i32>,
    pub page_size: Option<i32>,
}

#[derive(Deserialize)]
pub struct CreateAppReq {
    pub name: String,
    pub description: Option<String>,
    #[serde(rename = "app_type", default)]
    pub app_type: i16,
}

#[derive(Deserialize)]
pub struct UpdateAppReq {
    pub name: Option<String>,
    pub description: Option<String>,
    pub scopes: Option<Vec<String>>,
}

#[derive(Deserialize)]
pub struct UpdateBotReq {
    pub webhook_url: Option<String>,
    pub event_types: Option<Vec<String>>,
}

fn user_brief_from_jwt(auth: &auth::JWT) -> Result<common::UserBrief> {
    common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))
}

fn ok(data: Value) -> Result<Json<Value>> {
    Ok(Json(json!({"code": 0, "message": "ok", "data": data})))
}

pub async fn create(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Json(body): Json<CreateAppReq>,
) -> Result<Json<Value>> {
    let brief = user_brief_from_jwt(&auth)?;

    let (model, raw_secret, bot_user_id) = OpenAppModel::create(
        &ctx.db,
        brief.id,
        brief.tenant_id,
        &body.name,
        body.description.as_deref().unwrap_or(""),
        body.app_type,
    )
    .await
    .map_err(|e| {
        warn!("create app error: {e}");
        loco_rs::Error::InternalServerError
    })?;

    let mut data = model.with_secret(&raw_secret);
    if let Some(bot_uid) = bot_user_id {
        if let Ok(Some(bot)) = OpenAppBotModel::find_by_app(&ctx.db, model.0.id).await {
            data["bot"] = bot.to_json();
        }
    }

    ok(data)
}

pub async fn list(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Query(query): Query<ListQuery>,
) -> Result<Json<Value>> {
    let brief = user_brief_from_jwt(&auth)?;
    let page = query.page.unwrap_or(1).max(1);
    let page_size = query.page_size.unwrap_or(20).max(1).min(100);

    let (items, total) = OpenAppModel::find_by_tenant(&ctx.db, brief.tenant_id, page, page_size)
        .await
        .map_err(|e| {
            warn!("list apps error: {e}");
            loco_rs::Error::InternalServerError
        })?;

    let apps: Vec<Value> = items.iter().map(|m| m.to_json()).collect();
    ok(json!({"items": apps, "total": total, "page": page, "page_size": page_size}))
}

pub async fn get(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(app_id): Path<String>,
) -> Result<Json<Value>> {
    let _brief = user_brief_from_jwt(&auth)?;

    let app = OpenAppModel::find_by_app_id(&ctx.db, &app_id)
        .await
        .map_err(|e| {
            warn!("get app error: {e}");
            loco_rs::Error::InternalServerError
        })?
        .ok_or_else(|| loco_rs::Error::NotFound)?;

    let mut data = app.to_json();
    // 附带 Bot 信息
    if app.0.app_type == 1 {
        if let Ok(Some(bot)) = OpenAppBotModel::find_by_app(&ctx.db, app.0.id).await {
            data["bot"] = bot.to_json();
        }
    }

    ok(data)
}

pub async fn update(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(app_id): Path<String>,
    Json(body): Json<UpdateAppReq>,
) -> Result<Json<Value>> {
    let _brief = user_brief_from_jwt(&auth)?;

    let app = OpenAppModel::update(
        &ctx.db,
        &app_id,
        body.name.as_deref(),
        body.description.as_deref(),
        body.scopes,
    )
    .await
    .map_err(|e| {
        warn!("update app error: {e}");
        loco_rs::Error::InternalServerError
    })?
    .ok_or_else(|| loco_rs::Error::NotFound)?;

    ok(app.to_json())
}

pub async fn delete(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(app_id): Path<String>,
) -> Result<Json<Value>> {
    let _brief = user_brief_from_jwt(&auth)?;

    let deleted = OpenAppModel::soft_delete(&ctx.db, &app_id)
        .await
        .map_err(|e| {
            warn!("delete app error: {e}");
            loco_rs::Error::InternalServerError
        })?;

    if !deleted {
        return Err(loco_rs::Error::NotFound);
    }
    ok(json!({"deleted": true}))
}

pub async fn rotate_secret(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(app_id): Path<String>,
) -> Result<Json<Value>> {
    let _brief = user_brief_from_jwt(&auth)?;

    let new_secret = OpenAppModel::rotate_secret(&ctx.db, &app_id)
        .await
        .map_err(|e| {
            warn!("rotate secret error: {e}");
            loco_rs::Error::InternalServerError
        })?
        .ok_or_else(|| loco_rs::Error::NotFound)?;

    ok(json!({"app_secret": new_secret}))
}

pub async fn update_bot(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(app_id): Path<String>,
    Json(body): Json<UpdateBotReq>,
) -> Result<Json<Value>> {
    let _brief = user_brief_from_jwt(&auth)?;

    let app = OpenAppModel::find_by_app_id(&ctx.db, &app_id)
        .await
        .map_err(|e| {
            warn!("find app error: {e}");
            loco_rs::Error::InternalServerError
        })?
        .ok_or_else(|| loco_rs::Error::NotFound)?;

    if app.0.app_type != 1 {
        return Err(loco_rs::Error::BadRequest("not a bot app".into()));
    }

    let webhook_url = body.webhook_url.unwrap_or_default();
    let event_types = body.event_types.unwrap_or_default();

    let bot = OpenAppBotModel::update_webhook(&ctx.db, app.0.id, &webhook_url, &event_types)
        .await
        .map_err(|e| {
            warn!("update bot error: {e}");
            loco_rs::Error::InternalServerError
        })?
        .ok_or_else(|| loco_rs::Error::NotFound)?;

    ok(bot.to_json())
}

// ─── Outgoing Webhook CRUD ────────────────────────────

#[derive(Deserialize)]
pub struct CreateOutgoingWebhookReq {
    pub chat_id: i64,
    pub name: String,
    pub command: String,
    pub webhook_url: String,
}

#[derive(Deserialize)]
pub struct UpdateOutgoingWebhookReq {
    pub name: Option<String>,
    pub command: Option<String>,
    pub webhook_url: Option<String>,
    pub status: Option<i16>,
}

pub async fn create_outgoing_webhook(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(app_id): Path<String>,
    Json(body): Json<CreateOutgoingWebhookReq>,
) -> Result<Json<Value>> {
    let _brief = user_brief_from_jwt(&auth)?;

    let app = OpenAppModel::find_by_app_id(&ctx.db, &app_id)
        .await
        .map_err(|_| loco_rs::Error::InternalServerError)?
        .ok_or_else(|| loco_rs::Error::NotFound)?;

    let secret = auth_svc::generate_app_secret();
    let wh = OutgoingWebhookModel::create(
        &ctx.db,
        app.0.id,
        body.chat_id,
        &body.name,
        &body.command,
        &body.webhook_url,
        &secret,
    )
    .await
    .map_err(|e| {
        warn!("create outgoing webhook error: {e}");
        loco_rs::Error::InternalServerError
    })?;

    info!("Outgoing webhook created: app={}, name={}", app_id, body.name);
    ok(wh.to_json())
}

pub async fn update_outgoing_webhook(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path((app_id, webhook_id)): Path<(String, i64)>,
    Json(body): Json<UpdateOutgoingWebhookReq>,
) -> Result<Json<Value>> {
    let _brief = user_brief_from_jwt(&auth)?;

    let _app = OpenAppModel::find_by_app_id(&ctx.db, &app_id)
        .await
        .map_err(|_| loco_rs::Error::InternalServerError)?
        .ok_or_else(|| loco_rs::Error::NotFound)?;

    let wh = OutgoingWebhookModel::update(
        &ctx.db,
        webhook_id,
        body.name.as_deref(),
        body.command.as_deref(),
        body.webhook_url.as_deref(),
        body.status,
    )
    .await
    .map_err(|e| {
        warn!("update outgoing webhook error: {e}");
        loco_rs::Error::InternalServerError
    })?
    .ok_or_else(|| loco_rs::Error::NotFound)?;

    ok(wh.to_json())
}

pub async fn delete_outgoing_webhook(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path((app_id, webhook_id)): Path<(String, i64)>,
) -> Result<Json<Value>> {
    let _brief = user_brief_from_jwt(&auth)?;

    let _app = OpenAppModel::find_by_app_id(&ctx.db, &app_id)
        .await
        .map_err(|_| loco_rs::Error::InternalServerError)?
        .ok_or_else(|| loco_rs::Error::NotFound)?;

    let deleted = OutgoingWebhookModel::delete(&ctx.db, webhook_id)
        .await
        .map_err(|_| loco_rs::Error::InternalServerError)?;

    if !deleted { return Err(loco_rs::Error::NotFound); }
    ok(json!({"deleted": true}))
}

pub async fn list_outgoing_webhooks(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(app_id): Path<String>,
) -> Result<Json<Value>> {
    let _brief = user_brief_from_jwt(&auth)?;

    let app = OpenAppModel::find_by_app_id(&ctx.db, &app_id)
        .await
        .map_err(|_| loco_rs::Error::InternalServerError)?
        .ok_or_else(|| loco_rs::Error::NotFound)?;

    let items = OutgoingWebhookModel::find_by_app(&ctx.db, app.0.id)
        .await
        .map_err(|_| loco_rs::Error::InternalServerError)?;

    let hooks: Vec<Value> = items.iter().map(|w| w.to_json()).collect();
    ok(json!({"items": hooks}))
}
