use axum::debug_handler;
use loco_rs::prelude::*;
use sea_orm::{sea_query::Query, ActiveValue, QueryOrder, QuerySelect};
use serde::{Deserialize, Serialize};

use crate::models::document_spaces::DocumentSpaceModel;
use crate::models::documents::DocumentModel;
use crate::models::wiki_members::WikiMemberModel;
use crate::models::wiki_pins::WikiPinModel;
use crate::models::wikis::WikiModel;
use crate::permission::{require_role, require_wiki_role, Role, WikiRole};
use common::{id_gen, model::UserBrief};

// ---- DTOs ----

#[derive(Debug, Serialize)]
pub struct WikiResponse {
    pub id: String,
    pub tenant_id: String,
    pub name: String,
    pub description: Option<String>,
    pub icon: Option<String>,
    pub cover: Option<String>,
    pub creator_id: String,
    pub created_at: String,
    pub updated_at: String,
}

impl WikiResponse {
    fn from_model(m: crate::models::wikis::Model) -> Self {
        Self {
            id: m.id.to_string(),
            tenant_id: m.tenant_id.to_string(),
            name: m.name,
            description: m.description,
            icon: m.icon,
            cover: m.cover,
            creator_id: m.creator_id.to_string(),
            created_at: m.created_at.to_rfc3339(),
            updated_at: m.updated_at.to_rfc3339(),
        }
    }
}

#[derive(Debug, Deserialize)]
pub struct CreateWikiParams {
    pub name: String,
    pub description: Option<String>,
    pub icon: Option<String>,
    pub cover: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct UpdateWikiParams {
    pub name: Option<String>,
    pub description: Option<String>,
    pub icon: Option<String>,
    pub cover: Option<String>,
}

#[derive(Debug, Serialize)]
pub struct WikiMemberResponse {
    pub wiki_id: String,
    pub user_id: String,
    pub role: i16,
    pub joined_at: i64,
}

#[derive(Debug, Deserialize)]
pub struct AddMemberParams {
    pub user_id: String,
    pub role: Option<i16>,
}

#[derive(Debug, Serialize)]
pub struct WikiDetailResponse {
    #[serde(flatten)]
    pub wiki: WikiResponse,
    pub member_count: usize,
    pub space_count: usize,
}

// ---- 知识库 CRUD ----

#[debug_handler]
pub async fn list(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let wikis = WikiModel::list_accessible(&ctx.db, claim.tenant_id, claim.id).await?;
    let items: Vec<WikiResponse> = wikis.into_iter().map(WikiResponse::from_model).collect();
    format::json(items)
}

#[debug_handler]
pub async fn create(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Json(params): Json<CreateWikiParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let id = id_gen(None);
    let now = common::time::current_ms() as i64;
    let model = WikiModel::create(
        &ctx.db,
        crate::models::wikis::ActiveModel {
            id: ActiveValue::Set(id),
            tenant_id: ActiveValue::Set(claim.tenant_id),
            name: ActiveValue::Set(params.name),
            description: ActiveValue::Set(params.description),
            icon: ActiveValue::Set(params.icon),
            cover: ActiveValue::Set(params.cover),
            creator_id: ActiveValue::Set(claim.id),
            created_at: ActiveValue::Set(chrono::Utc::now().into()),
            updated_at: ActiveValue::Set(chrono::Utc::now().into()),
        },
    )
    .await?;
    // 创建者自动成为 owner
    WikiMemberModel::add_member(&ctx.db, id, claim.id, 3, now).await?;
    format::json(WikiResponse::from_model(model))
}

#[debug_handler]
pub async fn get(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_wiki_role(&ctx, claim.id, id, WikiRole::Viewer).await?;
    let wiki = WikiModel::get_by_id(&ctx.db, id)
        .await?
        .ok_or(Error::NotFound)?;
    let members = WikiMemberModel::list_by_wiki(&ctx.db, id).await?;
    let spaces = DocumentSpaceModel::get_by_wiki(&ctx.db, id).await?;
    let detail = WikiDetailResponse {
        wiki: WikiResponse::from_model(wiki),
        member_count: members.len(),
        space_count: spaces.len(),
    };
    format::json(detail)
}

#[debug_handler]
pub async fn update(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
    Json(params): Json<UpdateWikiParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_wiki_role(&ctx, claim.id, id, WikiRole::Admin).await?;
    let model = WikiModel::update(
        &ctx.db,
        id,
        crate::models::wikis::ActiveModel {
            id: ActiveValue::NotSet,
            tenant_id: ActiveValue::NotSet,
            name: ActiveValue::Set(params.name.unwrap_or_default()),
            description: ActiveValue::Set(params.description),
            icon: ActiveValue::Set(params.icon),
            cover: ActiveValue::Set(params.cover),
            creator_id: ActiveValue::NotSet,
            created_at: ActiveValue::NotSet,
            updated_at: ActiveValue::NotSet,
        },
    )
    .await?;
    format::json(WikiResponse::from_model(model))
}

#[debug_handler]
pub async fn delete(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_wiki_role(&ctx, claim.id, id, WikiRole::Owner).await?;
    WikiModel::delete(&ctx.db, id).await?;
    format::json(serde_json::json!({"ok": true}))
}

// ---- 成员管理 ----

#[debug_handler]
pub async fn list_members(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_wiki_role(&ctx, claim.id, id, WikiRole::Viewer).await?;
    let members = WikiMemberModel::list_by_wiki(&ctx.db, id).await?;
    let items: Vec<WikiMemberResponse> = members
        .into_iter()
        .map(|m| WikiMemberResponse {
            wiki_id: m.wiki_id.to_string(),
            user_id: m.user_id.to_string(),
            role: m.role,
            joined_at: m.joined_at,
        })
        .collect();
    format::json(items)
}

#[debug_handler]
pub async fn add_member(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
    Json(params): Json<AddMemberParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_wiki_role(&ctx, claim.id, id, WikiRole::Admin).await?;
    let user_id: i64 = params.user_id.parse().map_err(|_| Error::BadRequest("invalid user_id".into()))?;
    let role = params.role.unwrap_or(1);
    let now = common::time::current_ms() as i64;
    let m = WikiMemberModel::add_member(&ctx.db, id, user_id, role, now).await?;
    format::json(WikiMemberResponse {
        wiki_id: m.wiki_id.to_string(),
        user_id: m.user_id.to_string(),
        role: m.role,
        joined_at: m.joined_at,
    })
}

#[debug_handler]
pub async fn remove_member(
    auth: auth::JWT,
    Path((id, user_id)): Path<(i64, i64)>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_wiki_role(&ctx, claim.id, id, WikiRole::Admin).await?;
    WikiMemberModel::remove_member(&ctx.db, id, user_id).await?;
    format::json(serde_json::json!({"ok": true}))
}

// ---- 空间列表 ----

#[debug_handler]
pub async fn list_spaces(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_wiki_role(&ctx, claim.id, id, WikiRole::Viewer).await?;
    let spaces = DocumentSpaceModel::get_by_wiki(&ctx.db, id).await?;
    format::json(spaces)
}

// ---- 最近更新 ----

#[debug_handler]
pub async fn recent(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_wiki_role(&ctx, claim.id, id, WikiRole::Viewer).await?;
    // 获取 wiki 下所有 space ID
    use base::models::_entities::document_spaces::Column as SpcCol;
    let space_ids: Vec<i64> = DocumentSpaceModel::get_by_wiki(&ctx.db, id)
        .await?
        .into_iter()
        .map(|s| s.id)
        .collect();
    if space_ids.is_empty() {
        return format::json(Vec::<serde_json::Value>::new());
    }
    // 查这些 space 下最近更新的文档（分页前 20）
    use base::models::_entities::documents::Column as DocCol;
    let docs = base::models::_entities::documents::Entity::find()
        .filter(DocCol::SpaceId.is_in(space_ids))
        .filter(DocCol::TrashedAt.is_null())
        .order_by_desc(DocCol::UpdatedAt)
        .limit(20)
        .all(&ctx.db)
        .await?;
    format::json(docs)
}

// ---- 置顶 ----

#[debug_handler]
pub async fn list_pins(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_wiki_role(&ctx, claim.id, id, WikiRole::Viewer).await?;
    let pins = WikiPinModel::list_by_wiki(&ctx.db, id).await?;
    let mut doc_ids: Vec<i64> = pins.iter().map(|p| p.doc_id).collect();
    doc_ids.dedup();
    let docs = if doc_ids.is_empty() {
        vec![]
    } else {
        DocumentModel::get_by_ids(&ctx.db, &doc_ids).await?
    };
    format::json(docs)
}

#[debug_handler]
pub async fn add_pin(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
    Json(params): Json<serde_json::Value>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_wiki_role(&ctx, claim.id, id, WikiRole::Editor).await?;
    let doc_id: i64 = params.get("doc_id")
        .and_then(|v| v.as_str())
        .and_then(|s| s.parse().ok())
        .ok_or_else(|| Error::BadRequest("invalid doc_id".into()))?;
    let now = common::time::current_ms() as i64;
    WikiPinModel::add_pin(&ctx.db, id_gen(None), id, doc_id, claim.id, now).await?;
    format::json(serde_json::json!({"ok": true}))
}

#[debug_handler]
pub async fn remove_pin(
    auth: auth::JWT,
    Path((id, doc_id)): Path<(i64, i64)>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_wiki_role(&ctx, claim.id, id, WikiRole::Editor).await?;
    WikiPinModel::remove_pin(&ctx.db, id, doc_id).await?;
    format::json(serde_json::json!({"ok": true}))
}
