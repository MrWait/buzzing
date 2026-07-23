//! M4 文档权限模块 + M7 知识库权限模块。
//!
//! 文档查询顺序：
//!   1. 若 `user_id == documents.creator` → Owner
//!   2. `document_members` 查记录 → 对应角色
//!   3. 若 `documents.inherit_from_space=true` → 查找 space 所在 wiki 的角色
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

/// 知识库级别角色（与文档角色取值对齐便于继承）
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

/// 解析用户对该文档的角色。若无任何权限，返回 None。
pub async fn resolve_role(
    ctx: &AppContext,
    user_id: i64,
    doc_id: i64,
) -> Result<Option<Role>> {
    let doc = DocumentModel::get_by_id(&ctx.db, doc_id).await?;
    let Some(doc) = doc else {
        return Ok(None);
    };
    // 1. Owner: 文档创建者
    if doc.creator == user_id {
        return Ok(Some(Role::Owner));
    }
    // 2. document_members
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
    // 3. 空间继承: 若 inherit_from_space，查找 space 所在 wiki 的角色
    if doc.inherit_from_space {
        use base::models::_entities::document_spaces::Column as SpcCol;
        let space = base::models::_entities::document_spaces::Entity::find()
            .filter(SpcCol::Id.eq(doc.space_id))
            .one(&ctx.db)
            .await?;
        if let Some(s) = space {
            if let Some(wiki_id) = s.wiki_id {
                if let Some(wiki_role) = resolve_wiki_role_inner(ctx, user_id, wiki_id).await? {
                    // 映射 wiki role → doc role（owner → owner, admin → editor, editor → editor, viewer → viewer）
                    let doc_role = match wiki_role {
                        WikiRole::Owner => Role::Owner,
                        WikiRole::Admin => Role::Editor,
                        WikiRole::Editor => Role::Editor,
                        WikiRole::Viewer => Role::Viewer,
                    };
                    return Ok(Some(doc_role));
                }
            }
        }
    }
    Ok(None)
}

/// 校验用户是否具备至少 `min_role` 的权限，成功返回实际角色。
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
    // 1. Owner: 知识库创建者
    if wiki.creator_id == user_id {
        return Ok(Some(WikiRole::Owner));
    }
    // 2. wiki_members
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

/// 解析用户对该知识库的角色
pub async fn resolve_wiki_role(
    ctx: &AppContext,
    user_id: i64,
    wiki_id: i64,
) -> Result<Option<WikiRole>> {
    resolve_wiki_role_inner(ctx, user_id, wiki_id).await
}

/// 校验用户是否具备至少 `min_role` 的知识库权限
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
