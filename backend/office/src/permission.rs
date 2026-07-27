//! M4 文档权限模块 + M7 知识库权限模块。
//!
//! 文档查询顺序：
//!   1. 若 `user_id == documents.creator` → Owner
//!   2. `document_members` 查记录 → 对应角色
//!   3. 通过 `documents.wiki_id` 查询 wiki_members → 对应角色
//!   4. 否则 403
//!
//! 知识库查询顺序：
//!   1. 若 `user_id == wikis.creator_id` → Owner
//!   2. `wiki_members` 查记录 → 对应角色
//!   3. 否则 403

use loco_rs::prelude::*;

use crate::models::documents::DocumentModel;

/// 文档级别角色
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum Role {
    Viewer = 0,
    Commenter = 1,
    Editor = 2,
    Owner = 3,
}

impl Role {
    pub fn from_i32(v: i32) -> Self {
        match v {
            0 => Role::Viewer,
            1 => Role::Commenter,
            2 => Role::Editor,
            3 => Role::Owner,
            _ => Role::Viewer,
        }
    }

    pub fn label(&self) -> &'static str {
        match self {
            Role::Viewer => "viewer",
            Role::Commenter => "commenter",
            Role::Editor => "editor",
            Role::Owner => "owner",
        }
    }
}

/// 知识库级别角色
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum WikiRole {
    Viewer = 0,
    Editor = 2,
    Admin = 3,
    Owner = 4,
}

impl WikiRole {
    pub fn from_i16(v: i16) -> Self {
        match v {
            1 => WikiRole::Viewer,
            2 => WikiRole::Editor,
            3 => WikiRole::Admin,
            4 => WikiRole::Owner,
            _ => WikiRole::Viewer,
        }
    }

    pub fn label(&self) -> &'static str {
        match self {
            WikiRole::Viewer => "viewer",
            WikiRole::Editor => "editor",
            WikiRole::Admin => "admin",
            WikiRole::Owner => "owner",
        }
    }
}

// ---- 文档权限 ----

/// 解析用户对该文档的角色。
pub async fn resolve_role(
    ctx: &AppContext,
    user_id: i64,
    doc_id: i64,
) -> Result<Option<Role>> {
    let doc = DocumentModel::get_by_id(&ctx.db, doc_id).await?;
    let Some(doc) = doc else {
        return Ok(None);
    };
    // 1. Owner: 文档创建者（个人文档仅创建者可访问）
    if doc.creator == user_id {
        return Ok(Some(Role::Owner));
    }
    // 2. 个人文档（wiki_id IS NULL）非创建者无权限
    if doc.wiki_id.is_none() {
        return Ok(None);
    }
    // 3. document_members
    use base::models::_entities::document_members::{Column, Entity};
    use sea_orm::{ColumnTrait, EntityTrait, QueryFilter};
    if let Some(m) = Entity::find()
        .filter(Column::DocId.eq(doc_id))
        .filter(Column::UserId.eq(user_id))
        .one(&ctx.db)
        .await?
    {
        return Ok(Some(Role::from_i32(m.role)));
    }
    // 4. 知识库继承: 通过 documents.wiki_id 直接查询 wiki_members
    if let Some(wiki_id) = doc.wiki_id {
        if let Some(wiki_role) = resolve_wiki_role_inner(ctx, user_id, wiki_id).await? {
            let doc_role = match wiki_role {
                WikiRole::Owner => Role::Owner,
                WikiRole::Admin => Role::Editor,
                WikiRole::Editor => Role::Editor,
                WikiRole::Viewer => Role::Viewer,
            };
            return Ok(Some(doc_role));
        }
    }
    Ok(None)
}

/// 校验用户是否具备至少 `min_role` 的权限
pub async fn require_role(
    ctx: &AppContext,
    user_id: i64,
    doc_id: i64,
    min_role: Role,
) -> Result<Role> {
    let actual = resolve_role(ctx, user_id, doc_id).await?;
    match actual {
        Some(r) if r >= min_role => Ok(r),
        _ => Err(Error::Unauthorized(format!(
            "insufficient permission (require {})",
            min_role.label()
        ))),
    }
}

// ---- 知识库权限 ----

async fn resolve_wiki_role_inner(
    ctx: &AppContext,
    user_id: i64,
    wiki_id: i64,
) -> Result<Option<WikiRole>> {
    let wiki = crate::models::wikis::WikiModel::get_by_id(&ctx.db, wiki_id).await?;
    let Some(wiki) = wiki else {
        return Ok(None);
    };
    if wiki.creator_id == user_id {
        return Ok(Some(WikiRole::Owner));
    }
    use base::models::_entities::wiki_members::{Column as WmCol, Entity as WmEnt};
    if let Some(m) = WmEnt::find()
        .filter(WmCol::WikiId.eq(wiki_id))
        .filter(WmCol::UserId.eq(user_id))
        .one(&ctx.db)
        .await?
    {
        return Ok(Some(WikiRole::from_i16(m.role)));
    }
    Ok(None)
}

pub async fn resolve_wiki_role(
    ctx: &AppContext,
    user_id: i64,
    wiki_id: i64,
) -> Result<Option<WikiRole>> {
    resolve_wiki_role_inner(ctx, user_id, wiki_id).await
}

pub async fn require_wiki_role(
    ctx: &AppContext,
    user_id: i64,
    wiki_id: i64,
    min_role: WikiRole,
) -> Result<WikiRole> {
    let actual = resolve_wiki_role_inner(ctx, user_id, wiki_id).await?;
    match actual {
        Some(r) if r >= min_role => Ok(r),
        _ => Err(Error::Unauthorized(format!(
            "insufficient wiki permission (require {})",
            min_role.label()
        ))),
    }
}
