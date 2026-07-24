use axum::extract::{Path, State};
use axum::Json;
use loco_rs::prelude::*;
use serde::Deserialize;
use serde_json::{Value, json};
use tracing::{info, warn};

use crate::error::OpenAppError;
use crate::middleware::AppAuth;
use crate::models::app::OpenAppModel;
use crate::models::bot::OpenAppBotModel;
use common::BizHub;

#[derive(Deserialize)]
pub struct UpdateCardReq {
    pub content: Value,
}

#[derive(Deserialize)]
pub struct CardActionReq {
    pub message_id: i64,
    pub action_value: String,
    pub chat_id: i64,
}

fn ok(data: Value) -> Result<Json<Value>> {
    Ok(Json(json!({"code": 0, "message": "ok", "data": data})))
}

/// PATCH /bot/card/{message_id} — update card content in place
pub async fn update_card(
    auth: AppAuth,
    State(ctx): State<AppContext>,
    Path(message_id): Path<i64>,
    Json(body): Json<UpdateCardReq>,
) -> Result<Json<Value>> {
    auth.0.require_scope("im:message:write").map_err(|e| {
        warn!("scope denied: {e}");
        loco_rs::Error::Unauthorized("forbidden: scope denied".into())
    })?;

    let content_bytes = serde_json::to_vec(&body.content)
        .map_err(|e| {
            warn!("serialize card content error: {e}");
            loco_rs::Error::BadRequest("invalid content".into())
        })?;

    let hub = BizHub::get().map_err(|_| loco_rs::Error::InternalServerError)?;
    let ub = auth.0.to_user_brief();

    hub.im
        .edit_message(&ctx, &ub, message_id, content_bytes, "".to_string())
        .await
        .map_err(|e| {
            warn!("edit card message error: {e}");
            loco_rs::Error::InternalServerError
        })?;

    // TODO: push CMD_CARD_UPDATE to clients via gateway
    info!("Card message {message_id} updated");

    ok(json!({"updated": true}))
}

/// handle_card_action — process CMD_CARD_ACTION from client
pub async fn handle_card_action(
    _auth: AppAuth,
    State(ctx): State<AppContext>,
    Json(body): Json<CardActionReq>,
) -> Result<Json<Value>> {
    info!(
        "Card action: message_id={}, action_value={}, chat_id={}",
        body.message_id, body.action_value, body.chat_id
    );

    // Find the message's app (via bot user id on the message)
    // For now, dispatch to webhook if configured
    let _hub = BizHub::get().map_err(|_| loco_rs::Error::InternalServerError)?;

    // For MVP, just acknowledge (async processing)
    ok(json!({"success": true}))
}
