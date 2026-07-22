use axum::extract::{Path, State};
use axum::Json;
use loco_rs::prelude::*;
use serde_json::Value;

use crate::middleware::AppAuth;

pub async fn send_message(
    _auth: AppAuth,
    State(_ctx): State<AppContext>,
    Json(_body): Json<Value>,
) -> Result<Json<Value>> {
    Ok(Json(serde_json::json!({"code": 0, "message": "ok", "data": null})))
}

pub async fn edit_message(
    _auth: AppAuth,
    State(_ctx): State<AppContext>,
    Path(_message_id): Path<i64>,
    Json(_body): Json<Value>,
) -> Result<Json<Value>> {
    Ok(Json(serde_json::json!({"code": 0, "message": "ok", "data": null})))
}

pub async fn recall_message(
    _auth: AppAuth,
    State(_ctx): State<AppContext>,
    Path(_message_id): Path<i64>,
) -> Result<Json<Value>> {
    Ok(Json(serde_json::json!({"code": 0, "message": "ok", "data": null})))
}
