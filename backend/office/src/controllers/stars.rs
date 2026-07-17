use axum::debug_handler;
use loco_rs::prelude::*;
use serde::{Deserialize, Serialize};

use crate::controllers::docs::DocResponse;
use crate::models::document_stars::DocumentStarModel;
use crate::models::documents::DocumentModel;
use common::{id_gen, model::UserBrief};

#[derive(Debug, Deserialize)]
pub struct StarParams {
    pub group_name: Option<String>,
}

#[derive(Debug, Serialize)]
pub struct StarItem {
    #[serde(flatten)]
    pub doc: DocResponse,
    pub group_name: Option<String>,
}

/// 添加星标 (幂等)
#[debug_handler]
pub async fn star(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
    Json(params): Json<StarParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let existing = DocumentStarModel::get(&ctx.db, claim.id, id).await?;
    if existing.is_some() {
        return format::json(serde_json::json!({"ok": true, "existed": true}));
    }
    DocumentStarModel::create(&ctx.db, id_gen(None), claim.id, id, params.group_name).await?;
    format::json(serde_json::json!({"ok": true, "existed": false}))
}

/// 取消星标
#[debug_handler]
pub async fn unstar(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    DocumentStarModel::remove(&ctx.db, claim.id, id).await?;
    format::json(serde_json::json!({"ok": true}))
}

/// 星标文档列表
#[debug_handler]
pub async fn list(auth: auth::JWT, State(ctx): State<AppContext>) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let stars = DocumentStarModel::list_by_user(&ctx.db, claim.id).await?;
    let mut items: Vec<StarItem> = Vec::with_capacity(stars.len());
    for s in stars {
        if let Some(doc) = DocumentModel::get_by_id(&ctx.db, s.document_id).await? {
            if doc.trashed_at.is_some() {
                continue;
            }
            items.push(StarItem {
                doc: DocResponse::from_model(doc),
                group_name: s.group_name,
            });
        }
    }
    format::json(items)
}
