use axum::debug_handler;
use loco_rs::prelude::*;
use serde::{Deserialize, Serialize};

use crate::models::documents::DocumentModel;
use common::{id_gen, model::UserBrief};

#[derive(Debug, Deserialize)]
pub struct CreateDocParams {
    pub space_id: String,
    pub title: String,
}

#[derive(Debug, Deserialize)]
pub struct UpdateDocParams {
    pub title: Option<String>,
    pub space_id: Option<String>,
}

#[derive(Debug, Serialize)]
pub struct DocResponse {
    pub id: String,
    pub space_id: String,
    pub title: String,
    pub doc_type: i32,
    pub version: i64,
    pub created_at: String,
    pub updated_at: String,
}

#[derive(Debug, Serialize)]
pub struct EditUrlResponse {
    pub edit_url: String,
    pub title: String,
}

#[debug_handler]
pub async fn list(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Query(params): Query<std::collections::HashMap<String, String>>,
) -> Result<Response> {
    let _claim = UserBrief::from_string(&auth.claims.pid)?;
    let space_id = params.get("space_id").and_then(|s| s.parse().ok()).unwrap_or(0);
    let docs = DocumentModel::get_by_space_id(&ctx.db, space_id).await?;
    let items: Vec<DocResponse> = docs
        .into_iter()
        .map(|d| DocResponse {
            id: d.id.to_string(),
            space_id: d.space_id.to_string(),
            title: d.title,
            doc_type: d.doc_type,
            version: d.version,
            created_at: d.created_at.to_string(),
            updated_at: d.updated_at.to_string(),
        })
        .collect();
    format::json(items)
}

#[debug_handler]
pub async fn create(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Json(params): Json<CreateDocParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let doc = DocumentModel::create(
        &ctx.db,
        base::models::_entities::documents::ActiveModel {
            id: ActiveValue::set(id_gen(None)),
            space_id: ActiveValue::set(params.space_id.parse().map_err(|_| Error::InternalServerError)?),
            tenant_id: ActiveValue::set(claim.tenant_id),
            creator: ActiveValue::set(claim.id),
            title: ActiveValue::set(params.title),
            doc_type: ActiveValue::set(1),
            version: ActiveValue::set(common::time::current_ms() as i64),
            content: ActiveValue::set(vec![]),
            ..Default::default()
        },
    )
    .await?;
    format::json(DocResponse {
        id: doc.id.to_string(),
        space_id: doc.space_id.to_string(),
        title: doc.title,
        doc_type: doc.doc_type,
        version: doc.version,
        created_at: doc.created_at.to_string(),
        updated_at: doc.updated_at.to_string(),
    })
}

#[debug_handler]
pub async fn get(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let _claim = UserBrief::from_string(&auth.claims.pid)?;
    let doc = DocumentModel::get_by_id(&ctx.db, id)
        .await?
        .ok_or(Error::NotFound)?;
    format::json(DocResponse {
        id: doc.id.to_string(),
        space_id: doc.space_id.to_string(),
        title: doc.title,
        doc_type: doc.doc_type,
        version: doc.version,
        created_at: doc.created_at.to_string(),
        updated_at: doc.updated_at.to_string(),
    })
}

#[debug_handler]
pub async fn update(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
    Json(params): Json<UpdateDocParams>,
) -> Result<Response> {
    let _claim = UserBrief::from_string(&auth.claims.pid)?;

    if let Some(title) = params.title {
        let now = common::time::current_ms() as i64;
        DocumentModel::update_title(&ctx.db, id, title, now).await?;
    }

    let doc = DocumentModel::get_by_id(&ctx.db, id)
        .await?
        .ok_or(Error::NotFound)?;
    format::json(DocResponse {
        id: doc.id.to_string(),
        space_id: doc.space_id.to_string(),
        title: doc.title,
        doc_type: doc.doc_type,
        version: doc.version,
        created_at: doc.created_at.to_string(),
        updated_at: doc.updated_at.to_string(),
    })
}

#[debug_handler]
pub async fn delete(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let _claim = UserBrief::from_string(&auth.claims.pid)?;
    DocumentModel::delete(&ctx.db, id).await?;
    format::json(serde_json::json!({"ok": true}))
}

#[debug_handler]
pub async fn edit_url(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let _claim = UserBrief::from_string(&auth.claims.pid)?;
    let doc = DocumentModel::get_by_id(&ctx.db, id)
        .await?
        .ok_or(Error::NotFound)?;
    let edit_url = format!("/office/editor/{}", id);
    format::json(EditUrlResponse {
        edit_url,
        title: doc.title,
    })
}
