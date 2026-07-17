//! M4 文档权限模块：角色定义 + `require_role` 校验。
//!
//! 查询顺序：
//!   1. 若 `user_id == documents.creator` → Owner
//!   2. `document_members` 查记录 → 对应角色
//!   3. TODO: 若 `documents.inherit_from_space=true` → 空间成员表（暂未建表）
//!   4. 否则 403

use loco_rs::prelude::*;

use crate::models::documents::DocumentModel;

/// 角色定义，数值可直接与 `document_members.role` / `document_shares.role` 对齐。
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

    pub fn as_i32(&self) -> i32 {
        *self as i32
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
    // 3. TODO 空间继承 (inherit_from_space + space_members)
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
