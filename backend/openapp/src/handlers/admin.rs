use axum::extract::{Path, Query, State};
use axum::Json;
use loco_rs::prelude::*;
use serde::Deserialize;
use serde_json::{Value, json};
use tracing::{info, warn};

use crate::models::app::OpenAppModel;
use crate::models::market_info::MarketInfoModel;
use crate::models::version::VersionModel;

fn ok(data: Value) -> Result<Json<Value>> {
    Ok(Json(json!({"code": 0, "message": "ok", "data": data})))
}

#[derive(Deserialize)]
pub struct ReviewListQuery {
    pub status: Option<i16>,
    pub page: Option<i32>,
    pub page_size: Option<i32>,
}

#[derive(Deserialize)]
pub struct RejectReq {
    pub reason: String,
}

#[derive(Deserialize)]
pub struct UnpublishReq {
    pub reason: Option<String>,
}

/// GET /admin/reviews — list review requests
pub async fn list_reviews(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Query(query): Query<ReviewListQuery>,
) -> Result<Json<Value>> {
    let _brief = common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;

    let status = query.status.unwrap_or(0);
    let page = query.page.unwrap_or(1).max(1);
    let page_size = query.page_size.unwrap_or(20).max(1).min(100);

    let (items, total) = VersionModel::find_by_status(&ctx.db, status, page, page_size)
        .await
        .map_err(|e| {
            warn!("list reviews error: {e}");
            loco_rs::Error::InternalServerError
        })?;

    let mut result = Vec::new();
    for v in &items {
        let mut item = v.to_json();
        if let Ok(Some(app)) = OpenAppModel::find_by_id(&ctx.db, v.0.app_id).await {
            item["app"] = json!({
                "id": app.0.id,
                "name": app.0.name,
                "app_type": app.0.app_type,
                "app_id": app.0.app_id,
            });
        }
        result.push(item);
    }

    ok(json!({"items": result, "total": total}))
}

/// GET /admin/reviews/{version_id} — review detail
pub async fn review_detail(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(version_id): Path<i64>,
) -> Result<Json<Value>> {
    let _brief = common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;

    let version = VersionModel::find_by_id(&ctx.db, version_id)
        .await
        .map_err(|_| loco_rs::Error::InternalServerError)?
        .ok_or_else(|| loco_rs::Error::NotFound)?;

    let mut data = version.to_json();
    if let Ok(Some(app)) = OpenAppModel::find_by_id(&ctx.db, version.0.app_id).await {
        data["app"] = app.to_json();
    }
    if let Ok(Some(mi)) = MarketInfoModel::find_by_app(&ctx.db, version.0.app_id).await {
        data["market_info"] = mi.to_json();
    }

    ok(data)
}

/// POST /admin/reviews/{version_id}/approve — approve version
pub async fn approve(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(version_id): Path<i64>,
) -> Result<Json<Value>> {
    let brief = common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;

    let version = VersionModel::approve(&ctx.db, version_id, brief.id)
        .await
        .map_err(|e| {
            warn!("approve version error: {e}");
            loco_rs::Error::InternalServerError
        })?
        .ok_or_else(|| loco_rs::Error::NotFound)?;

    // Auto-publish if approved
    let _ = VersionModel::publish(&ctx.db, version_id).await;

    info!("Version {version_id} approved by {}", brief.id);
    ok(version.to_json())
}

/// POST /admin/reviews/{version_id}/reject — reject version
pub async fn reject(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(version_id): Path<i64>,
    Json(body): Json<RejectReq>,
) -> Result<Json<Value>> {
    let brief = common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;

    let version = VersionModel::reject(&ctx.db, version_id, brief.id, &body.reason)
        .await
        .map_err(|e| {
            warn!("reject version error: {e}");
            loco_rs::Error::InternalServerError
        })?
        .ok_or_else(|| loco_rs::Error::NotFound)?;

    info!("Version {version_id} rejected by {}: {}", brief.id, body.reason);
    ok(version.to_json())
}

/// POST /admin/reviews/{app_id}/unpublish — unpublish app from market
pub async fn unpublish(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(app_id): Path<i64>,
    Json(_body): Json<UnpublishReq>,
) -> Result<Json<Value>> {
    let _brief = common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;

    // Set all published versions to draft
    let versions = VersionModel::find_by_app(&ctx.db, app_id)
        .await
        .map_err(|_| loco_rs::Error::InternalServerError)?;

    for v in &versions {
        if v.0.status == 3 {
            let _ = VersionModel::set_status(&ctx.db, v.0.id, 0i16).await;
        }
    }

    info!("App {app_id} unpublished");
    ok(json!({"unpublished": true}))
}
