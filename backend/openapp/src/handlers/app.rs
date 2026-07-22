use axum::extract::{Path, Query, State};
use axum::Json;
use loco_rs::prelude::*;
use serde::Deserialize;
use serde_json::{Value, json};

#[derive(Deserialize)]
pub struct ListQuery {
    pub page: Option<i32>,
    pub page_size: Option<i32>,
}

pub async fn create(
    auth: auth::JWT,
    State(_ctx): State<AppContext>,
    Json(_body): Json<Value>,
) -> Result<Json<Value>> {
    let _claim = common::model::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;
    Ok(Json(json!({"code": 0, "message": "ok", "data": null})))
}

pub async fn list(
    auth: auth::JWT,
    State(_ctx): State<AppContext>,
    Query(_query): Query<ListQuery>,
) -> Result<Json<Value>> {
    let _claim = common::model::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;
    Ok(Json(json!({"code": 0, "message": "ok", "data": null})))
}

pub async fn get(
    auth: auth::JWT,
    State(_ctx): State<AppContext>,
    Path(_app_id): Path<String>,
) -> Result<Json<Value>> {
    let _claim = common::model::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;
    Ok(Json(json!({"code": 0, "message": "ok", "data": null})))
}

pub async fn update(
    auth: auth::JWT,
    State(_ctx): State<AppContext>,
    Path(_app_id): Path<String>,
    Json(_body): Json<Value>,
) -> Result<Json<Value>> {
    let _claim = common::model::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;
    Ok(Json(json!({"code": 0, "message": "ok", "data": null})))
}

pub async fn delete(
    auth: auth::JWT,
    State(_ctx): State<AppContext>,
    Path(_app_id): Path<String>,
) -> Result<Json<Value>> {
    let _claim = common::model::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;
    Ok(Json(json!({"code": 0, "message": "ok", "data": null})))
}

pub async fn rotate_secret(
    auth: auth::JWT,
    State(_ctx): State<AppContext>,
    Path(_app_id): Path<String>,
) -> Result<Json<Value>> {
    let _claim = common::model::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;
    Ok(Json(json!({"code": 0, "message": "ok", "data": null})))
}

pub async fn update_bot(
    auth: auth::JWT,
    State(_ctx): State<AppContext>,
    Path(_app_id): Path<String>,
    Json(_body): Json<Value>,
) -> Result<Json<Value>> {
    let _claim = common::model::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;
    Ok(Json(json!({"code": 0, "message": "ok", "data": null})))
}
