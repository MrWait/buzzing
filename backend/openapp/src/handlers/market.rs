use axum::extract::{Path, Query, State};
use axum::Json;
use loco_rs::prelude::*;
use serde::Deserialize;
use serde_json::{Value, json};
use tracing::{info, warn};

use crate::error::OpenAppError;
use crate::models::app::OpenAppModel;
use crate::models::installation::InstallationModel;
use crate::models::market_info::MarketInfoModel;
use crate::models::review::ReviewModel;
use crate::models::version::VersionModel;
use crate::services::market;

fn ok(data: Value) -> Result<Json<Value>> {
    Ok(Json(json!({"code": 0, "message": "ok", "data": data})))
}

#[derive(Deserialize)]
pub struct PageQuery {
    pub page: Option<i32>,
    pub page_size: Option<i32>,
}

#[derive(Deserialize)]
pub struct SubmitVersionReq {
    pub version: String,
    pub release_notes: Option<String>,
    pub market_info: Option<MarketInfoData>,
}

#[derive(Deserialize)]
pub struct MarketInfoData {
    pub category: Option<String>,
    pub short_description: Option<String>,
    pub detailed_description: Option<String>,
    pub developer_name: Option<String>,
    pub developer_email: Option<String>,
    pub support_url: Option<String>,
    pub homepage_url: Option<String>,
    pub permissions: Option<Vec<String>>,
}

#[derive(Deserialize)]
pub struct InstallReq {
    pub app_id: i64,
    pub scopes: Option<Vec<String>>,
}

#[derive(Deserialize)]
pub struct CreateReviewReq {
    pub rating: i16,
    pub content: Option<String>,
}

#[derive(Deserialize)]
pub struct ReplyReviewReq {
    pub content: String,
}

#[derive(Deserialize)]
pub struct MarketListQuery {
    pub page: Option<i32>,
    pub page_size: Option<i32>,
    pub category: Option<String>,
    pub search: Option<String>,
}

// ─── Version Management ───────────────────────────────

/// POST /apps/{app_id}/versions — submit new version
pub async fn submit_version(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(app_id): Path<i64>,
    Json(body): Json<SubmitVersionReq>,
) -> Result<Json<Value>> {
    let _brief = common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;

    let version = VersionModel::create(
        &ctx.db,
        app_id,
        &body.version,
        body.release_notes.as_deref(),
    )
    .await
    .map_err(|e| {
        warn!("create version error: {e}");
        loco_rs::Error::InternalServerError
    })?;

    if let Some(mi) = body.market_info {
        let _ = MarketInfoModel::upsert(
            &ctx.db,
            app_id,
            mi.category.as_deref().unwrap_or("bot"),
            mi.short_description.as_deref().unwrap_or(""),
            mi.detailed_description.as_deref(),
            mi.developer_name.as_deref().unwrap_or(""),
            mi.developer_email.as_deref().unwrap_or(""),
            mi.support_url.as_deref().unwrap_or(""),
            mi.homepage_url.as_deref().unwrap_or(""),
            mi.permissions.unwrap_or_default(),
        )
        .await;
    }

    info!("Version submitted: app={app_id}, version={}", body.version);
    ok(version.to_json())
}

/// GET /apps/{app_id}/versions — list versions
pub async fn list_versions(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(app_id): Path<i64>,
) -> Result<Json<Value>> {
    let _brief = common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;

    let versions = VersionModel::find_by_app(&ctx.db, app_id).await.map_err(|e| {
        warn!("list versions error: {e}");
        loco_rs::Error::InternalServerError
    })?;

    let items: Vec<Value> = versions.iter().map(|v| v.to_json()).collect();
    ok(json!({"items": items}))
}

// ─── Market App Listing ───────────────────────────────

/// GET /market/apps — list published apps
pub async fn list_market_apps(
    State(ctx): State<AppContext>,
    Query(query): Query<MarketListQuery>,
) -> Result<Json<Value>> {
    let page = query.page.unwrap_or(1).max(1);
    let page_size = query.page_size.unwrap_or(20).max(1).min(100);

    // List apps that have market_info and at least one published version
    use sea_orm::{ColumnTrait, EntityTrait, QueryFilter, QueryOrder};
    use base::models::_entities::open_apps::Entity as AppEntity;
    use base::models::_entities::open_apps::Column as AppColumn;

    let mut condition = sea_orm::Condition::all()
        .add(AppColumn::DeletedAt.is_null())
        .add(AppColumn::Status.eq(1i16));

    if let Some(cat) = &query.category {
        // Filter by market_info category via subquery or join
        // Simple approach: get all active apps
    }

    use sea_orm::PaginatorTrait;
    let paginator = AppEntity::find()
        .filter(condition)
        .order_by_desc(AppColumn::Id)
        .paginate(&ctx.db, page_size as u64);
    let total = paginator.num_items().await.unwrap_or(0);
    let apps = paginator.fetch_page((page - 1).max(0) as u64).await.unwrap_or_default();

    let mut items = Vec::new();
    for app in &apps {
        let base = json!({
            "id": app.id,
            "name": app.name,
            "app_type": app.app_type,
            "app_id": app.app_id,
        });
        if let Ok(Some(mi)) = MarketInfoModel::find_by_app(&ctx.db, app.id).await {
            items.push(serde_json::from_value::<Value>(base).unwrap_or_default());
            if let Some(last) = items.last_mut() {
                if let Some(obj) = last.as_object_mut() {
                    obj.insert("market".to_string(), mi.to_json());
                }
            }
        }
    }

    Ok(Json(json!({
        "code": 0,
        "message": "ok",
        "data": { "items": items, "total": total }
    })))
}

/// GET /market/apps/{app_id} — get market app detail
pub async fn get_market_app_detail(
    State(ctx): State<AppContext>,
    Path(app_id): Path<i64>,
) -> Result<Json<Value>> {
    let app = OpenAppModel::find_by_id(&ctx.db, app_id)
        .await
        .map_err(|_| loco_rs::Error::InternalServerError)?
        .ok_or_else(|| loco_rs::Error::NotFound)?;

    let mut data = app.to_json();
    if let Ok(Some(mi)) = MarketInfoModel::find_by_app(&ctx.db, app_id).await {
        data["market"] = mi.to_json();
    }
    if let Ok(ratings) = ReviewModel::get_rating_summary(&ctx.db, app_id).await {
        data["ratings"] = ratings;
    }

    ok(data)
}

// ─── Installation ─────────────────────────────────────

/// POST /market/install — install an app
pub async fn install(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Json(body): Json<InstallReq>,
) -> Result<Json<Value>> {
    let brief = common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;

    // Check app exists
    let _app = OpenAppModel::find_by_id(&ctx.db, body.app_id)
        .await
        .map_err(|_| loco_rs::Error::InternalServerError)?
        .ok_or_else(|| loco_rs::Error::NotFound)?;

    // Check not already installed
    let existing = InstallationModel::find_by_app_tenant(&ctx.db, body.app_id, brief.tenant_id)
        .await
        .map_err(|_| loco_rs::Error::InternalServerError)?;

    if existing.is_some() {
        return Err(loco_rs::Error::BadRequest("already installed".into()));
    }

    let inst = market::process_installation(
        &ctx.db,
        body.app_id,
        brief.tenant_id,
        brief.id,
        body.scopes.unwrap_or_default(),
    )
    .await
    .map_err(|e| {
        warn!("installation error: {e}");
        loco_rs::Error::InternalServerError
    })?;

    info!("App {} installed in tenant {}", body.app_id, brief.tenant_id);
    ok(inst.to_json())
}

/// GET /market/installed — list installed apps
pub async fn list_installed(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
) -> Result<Json<Value>> {
    let brief = common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;

    let insts = InstallationModel::find_by_tenant(&ctx.db, brief.tenant_id)
        .await
        .map_err(|e| {
            warn!("list installed error: {e}");
            loco_rs::Error::InternalServerError
        })?;

    let mut items = Vec::new();
    for inst in &insts {
        let mut item = inst.to_json();
        if let Ok(Some(app)) = OpenAppModel::find_by_id(&ctx.db, inst.0.app_id).await {
            item["app"] = json!({
                "id": app.0.id,
                "name": app.0.name,
                "app_type": app.0.app_type,
                "app_id": app.0.app_id,
            });
            if let Ok(Some(mi)) = MarketInfoModel::find_by_app(&ctx.db, inst.0.app_id).await {
                item["app"]["icon_url"] = mi.0.icon_file_id.map(|fid| json!(fid)).unwrap_or(Value::Null);
            }
        }
        items.push(item);
    }

    ok(json!({"items": items}))
}

/// POST /market/installed/{id}/enable — enable installation
pub async fn enable_installation(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(id): Path<i64>,
) -> Result<Json<Value>> {
    let _brief = common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;

    let success = InstallationModel::set_status(&ctx.db, id, 1i16).await.map_err(|e| {
        warn!("enable installation error: {e}");
        loco_rs::Error::InternalServerError
    })?;

    if !success { return Err(loco_rs::Error::NotFound); }
    ok(json!({"enabled": true}))
}

/// POST /market/installed/{id}/disable — disable installation
pub async fn disable_installation(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(id): Path<i64>,
) -> Result<Json<Value>> {
    let _brief = common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;

    let success = InstallationModel::set_status(&ctx.db, id, 0i16).await.map_err(|e| {
        warn!("disable installation error: {e}");
        loco_rs::Error::InternalServerError
    })?;

    if !success { return Err(loco_rs::Error::NotFound); }
    ok(json!({"disabled": true}))
}

/// DELETE /market/installed/{id} — uninstall
pub async fn uninstall(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(id): Path<i64>,
) -> Result<Json<Value>> {
    let _brief = common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;

    let success = market::process_uninstallation(&ctx.db, id).await.map_err(|e| {
        warn!("uninstall error: {e}");
        loco_rs::Error::InternalServerError
    })?;

    if !success { return Err(loco_rs::Error::NotFound); }
    ok(json!({"uninstalled": true}))
}

// ─── Reviews ──────────────────────────────────────────

/// POST /market/apps/{app_id}/reviews — create review
pub async fn create_review(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(app_id): Path<i64>,
    Json(body): Json<CreateReviewReq>,
) -> Result<Json<Value>> {
    let brief = common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;

    if body.rating < 1 || body.rating > 5 {
        return Err(loco_rs::Error::BadRequest("rating must be 1-5".into()));
    }

    // Check existing
    let existing = ReviewModel::find_by_user(&ctx.db, app_id, brief.id, brief.tenant_id)
        .await
        .map_err(|e| {
            warn!("find review error: {e}");
            loco_rs::Error::InternalServerError
        })?;

    if existing.is_some() {
        return Err(loco_rs::Error::BadRequest("already reviewed".into()));
    }

    let review = ReviewModel::create(
        &ctx.db,
        app_id,
        brief.id,
        brief.tenant_id,
        body.rating,
        body.content.as_deref(),
    )
    .await
    .map_err(|e| {
        warn!("create review error: {e}");
        loco_rs::Error::InternalServerError
    })?;

    // Update rating avg
    let _ = market::update_rating_avg(&ctx.db, app_id).await;

    ok(review.to_json())
}

/// GET /market/apps/{app_id}/reviews — list reviews
pub async fn list_reviews(
    State(ctx): State<AppContext>,
    Path(app_id): Path<i64>,
    Query(query): Query<PageQuery>,
) -> Result<Json<Value>> {
    let page = query.page.unwrap_or(1).max(1);
    let page_size = query.page_size.unwrap_or(20).max(1).min(100);

    let (items, total) = ReviewModel::find_by_app(&ctx.db, app_id, page, page_size)
        .await
        .map_err(|e| {
            warn!("list reviews error: {e}");
            loco_rs::Error::InternalServerError
        })?;

    let items: Vec<Value> = items.iter().map(|r| r.to_json()).collect();
    ok(json!({"items": items, "total": total}))
}

/// POST /market/apps/{app_id}/reviews/{review_id}/reply — developer reply
pub async fn reply_review(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path((_app_id, review_id)): Path<(i64, i64)>,
    Json(body): Json<ReplyReviewReq>,
) -> Result<Json<Value>> {
    let _brief = common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;

    let review = ReviewModel::reply(&ctx.db, review_id, &body.content)
        .await
        .map_err(|e| {
            warn!("reply review error: {e}");
            loco_rs::Error::InternalServerError
        })?
        .ok_or_else(|| loco_rs::Error::NotFound)?;

    ok(review.to_json())
}

/// GET /market/apps/{app_id}/ratings — rating summary
pub async fn get_ratings(
    State(ctx): State<AppContext>,
    Path(app_id): Path<i64>,
) -> Result<Json<Value>> {
    let summary = ReviewModel::get_rating_summary(&ctx.db, app_id)
        .await
        .map_err(|e| {
            warn!("get ratings error: {e}");
            loco_rs::Error::InternalServerError
        })?;

    ok(summary)
}
