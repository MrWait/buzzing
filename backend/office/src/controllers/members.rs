use axum::debug_handler;
use loco_rs::prelude::*;
use sea_orm::EntityTrait;
use serde::{Deserialize, Serialize};

use crate::models::document_members::DocumentMemberModel;
use crate::permission::{require_role, Role};
use common::model::UserBrief;

#[derive(Debug, Deserialize)]
pub struct AddMemberParams {
    pub user_id: String,
    pub role: i32,
}

#[derive(Debug, Deserialize)]
pub struct UpdateMemberParams {
    pub role: i32,
}

#[derive(Debug, Serialize)]
pub struct MemberResponse {
    pub user_id: String,
    pub name: String,
    pub avatar: Option<String>,
    pub role: i32,
    pub role_label: String,
    pub joined_at: i64,
}

/// 列出文档成员 (需 viewer 及以上)
#[debug_handler]
pub async fn list(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, id, Role::Viewer).await?;
    let members = DocumentMemberModel::get_members(&ctx.db, id).await?;

    let user_ids: Vec<i64> = members.iter().map(|m| m.user_id).collect();
    let users = if user_ids.is_empty() {
        vec![]
    } else {
        use base::models::_entities::users::{Column as UCol, Entity as UsersEntity};
        UsersEntity::find()
            .filter(UCol::Id.is_in(user_ids.clone()))
            .all(&ctx.db)
            .await?
    };
    let mut items: Vec<MemberResponse> = Vec::with_capacity(members.len());
    for m in members {
        let user = users.iter().find(|u| u.id == m.user_id);
        let role = Role::from_i32(m.role);
        items.push(MemberResponse {
            user_id: m.user_id.to_string(),
            name: user.map(|u| u.name.clone()).unwrap_or_else(|| String::from("未知用户")),
            avatar: user.and_then(|u| u.avatar.clone()),
            role: m.role,
            role_label: role.label().to_string(),
            joined_at: m.joined_at,
        });
    }
    format::json(items)
}

/// 添加成员 (需 owner)
#[debug_handler]
pub async fn add(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
    Json(params): Json<AddMemberParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, id, Role::Owner).await?;
    let user_id: i64 = params
        .user_id
        .parse()
        .map_err(|_| Error::BadRequest("invalid user_id".into()))?;
    // 若已存在则更新角色 (upsert)
    if DocumentMemberModel::get_one(&ctx.db, id, user_id).await?.is_some() {
        DocumentMemberModel::update_role(&ctx.db, id, user_id, params.role).await?;
    } else {
        DocumentMemberModel::add_member(&ctx.db, id, user_id, params.role).await?;
    }
    format::json(serde_json::json!({"ok": true}))
}

/// 修改角色 (需 owner)
#[debug_handler]
pub async fn update(
    auth: auth::JWT,
    Path((id, user_id)): Path<(i64, i64)>,
    State(ctx): State<AppContext>,
    Json(params): Json<UpdateMemberParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, id, Role::Owner).await?;
    DocumentMemberModel::update_role(&ctx.db, id, user_id, params.role).await?;
    format::json(serde_json::json!({"ok": true}))
}

/// 移除成员 (需 owner)
#[debug_handler]
pub async fn remove(
    auth: auth::JWT,
    Path((id, user_id)): Path<(i64, i64)>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, id, Role::Owner).await?;
    DocumentMemberModel::remove_member(&ctx.db, id, user_id).await?;
    format::json(serde_json::json!({"ok": true}))
}
