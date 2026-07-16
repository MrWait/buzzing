use axum::debug_handler;
use loco_rs::prelude::*;
use serde::{Deserialize, Serialize};

use crate::models::document_spaces::DocumentSpaceModel;
use common::{id_gen, model::UserBrief};

#[derive(Debug, Deserialize)]
pub struct CreateSpaceParams {
    pub name: String,
}

#[derive(Debug, Deserialize)]
pub struct UpdateSpaceParams {
    pub name: String,
}

#[derive(Debug, Serialize)]
pub struct SpaceResponse {
    pub id: String,
    pub name: String,
    pub sp_type: i32,
    pub created_at: String,
    pub updated_at: String,
}

#[debug_handler]
pub async fn list(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let spaces = DocumentSpaceModel::get_by_creator(&ctx.db, claim.id).await?;
    let items: Vec<SpaceResponse> = spaces
        .into_iter()
        .map(|s| SpaceResponse {
            id: s.id.to_string(),
            name: s.name,
            sp_type: s.sp_type,
            created_at: s.created_at.to_string(),
            updated_at: s.updated_at.to_string(),
        })
        .collect();
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
            ..Default::default()
        },
    )
    .await?;
    format::json(SpaceResponse {
        id: space.id.to_string(),
        name: space.name,
        sp_type: space.sp_type,
        created_at: space.created_at.to_string(),
        updated_at: space.updated_at.to_string(),
    })
}

#[debug_handler]
pub async fn update(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
    Json(params): Json<UpdateSpaceParams>,
) -> Result<Response> {
    let _claim = UserBrief::from_string(&auth.claims.pid)?;
    let space = DocumentSpaceModel::update_name(&ctx.db, id, params.name).await?;
    format::json(SpaceResponse {
        id: space.id.to_string(),
        name: space.name,
        sp_type: space.sp_type,
        created_at: space.created_at.to_string(),
        updated_at: space.updated_at.to_string(),
    })
}

#[debug_handler]
pub async fn delete(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let _claim = UserBrief::from_string(&auth.claims.pid)?;
    DocumentSpaceModel::delete(&ctx.db, id).await?;
    format::json(serde_json::json!({"ok": true}))
}
