use axum::debug_handler;
use loco_rs::prelude::*;
use serde::{Deserialize, Serialize};

use crate::models::document_spaces::DocumentSpaceModel;
use common::{id_gen, model::UserBrief};

#[derive(Debug, Deserialize)]
pub struct CreateSpaceParams {
    pub name: String,
    pub icon: Option<String>,
    pub color: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct UpdateSpaceParams {
    pub name: Option<String>,
    pub icon: Option<String>,
    pub color: Option<String>,
    pub sort_order: Option<i32>,
}

#[derive(Debug, Deserialize)]
pub struct ArchiveParams {
    pub archived: bool,
}

#[derive(Debug, Serialize)]
pub struct SpaceResponse {
    pub id: String,
    pub name: String,
    pub icon: Option<String>,
    pub color: Option<String>,
    pub sort_order: i32,
    pub sp_type: i32,
    pub archived_at: Option<String>,
    pub created_at: String,
    pub updated_at: String,
}

impl SpaceResponse {
    fn from_model(s: crate::models::document_spaces::Model) -> Self {
        Self {
            id: s.id.to_string(),
            name: s.name,
            icon: s.icon,
            color: s.color,
            sort_order: s.sort_order,
            sp_type: s.sp_type,
            archived_at: s.archived_at.map(|v| v.to_rfc3339()),
            created_at: s.created_at.to_rfc3339(),
            updated_at: s.updated_at.to_rfc3339(),
        }
    }
}

#[debug_handler]
pub async fn list(auth: auth::JWT, State(ctx): State<AppContext>) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let spaces = DocumentSpaceModel::get_by_creator(&ctx.db, claim.id).await?;
    let items: Vec<SpaceResponse> = spaces.into_iter().map(SpaceResponse::from_model).collect();
    format::json(items)
}

#[debug_handler]
pub async fn list_archived(auth: auth::JWT, State(ctx): State<AppContext>) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let spaces = DocumentSpaceModel::list_archived(&ctx.db, claim.id).await?;
    let items: Vec<SpaceResponse> = spaces.into_iter().map(SpaceResponse::from_model).collect();
    format::json(items)
}

#[debug_handler]
pub async fn create(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Json(params): Json<CreateSpaceParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let space = DocumentSpaceModel::create(
        &ctx.db,
        base::models::_entities::document_spaces::ActiveModel {
            id: ActiveValue::set(id_gen(None)),
            tenant_id: ActiveValue::set(claim.tenant_id),
            creator: ActiveValue::set(claim.id),
            name: ActiveValue::set(params.name),
            sp_type: ActiveValue::set(1),
            icon: ActiveValue::set(params.icon),
            color: ActiveValue::set(params.color),
            sort_order: ActiveValue::set(0),
            ..Default::default()
        },
    )
    .await?;
    format::json(SpaceResponse::from_model(space))
}

#[debug_handler]
pub async fn update(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
    Json(params): Json<UpdateSpaceParams>,
) -> Result<Response> {
    let _claim = UserBrief::from_string(&auth.claims.pid)?;
    let space = DocumentSpaceModel::update_meta(
        &ctx.db,
        id,
        params.name,
        params.icon.map(Some),
        params.color.map(Some),
        params.sort_order,
    )
    .await?;
    format::json(SpaceResponse::from_model(space))
}

#[debug_handler]
pub async fn archive(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
    Json(params): Json<ArchiveParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let existing = DocumentSpaceModel::get_by_id(&ctx.db, id)
        .await?
        .ok_or(Error::NotFound)?;
    if existing.creator != claim.id {
        return Err(Error::Unauthorized("not space owner".into()));
    }
    if existing.sp_type == 0 {
        return Err(Error::BadRequest("默认空间不允许归档".into()));
    }
    let space = DocumentSpaceModel::set_archived(&ctx.db, id, params.archived).await?;
    format::json(SpaceResponse::from_model(space))
}

#[debug_handler]
pub async fn delete(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let existing = DocumentSpaceModel::get_by_id(&ctx.db, id)
        .await?
        .ok_or(Error::NotFound)?;
    if existing.creator != claim.id {
        return Err(Error::Unauthorized("not space owner".into()));
    }
    if existing.sp_type == 0 {
        return Err(Error::BadRequest("默认空间不允许删除".into()));
    }
    DocumentSpaceModel::delete(&ctx.db, id).await?;
    format::json(serde_json::json!({"ok": true}))
}
