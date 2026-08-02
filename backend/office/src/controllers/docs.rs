use axum::debug_handler;
use loco_rs::prelude::*;
use serde::Serialize;

use crate::models::documents::DocumentModel;
use common::model::UserBrief;

#[derive(Debug, Serialize)]
pub struct WalkItem {
    pub id: String,
    pub title: String,
    pub icon: Option<String>,
    /// 节点类型: user=个人空间虚拟根, wiki=知识库根, doc=文档
    pub kind: String,
}

#[debug_handler]
pub async fn preview(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    crate::permission::require_role(&ctx, claim.id, id, crate::permission::Role::Viewer).await?;
    let doc = DocumentModel::get_by_id(&ctx.db, id)
        .await?
        .ok_or(Error::NotFound)?;
    use sea_orm::{DbBackend, FromQueryResult, Statement};
    #[derive(FromQueryResult, Serialize)]
    struct CreatorRow {
        id: i64,
        name: String,
        avatar: Option<String>,
    }
    let creator = CreatorRow::find_by_statement(Statement::from_sql_and_values(
        DbBackend::Postgres,
        "SELECT id, name, avatar FROM \"users\" WHERE id = $1",
        vec![doc.creator.into()],
    ))
    .one(&ctx.db)
    .await?;
    let excerpt = doc.plain_text.as_deref().unwrap_or("").chars().take(200).collect::<String>();
    format::json(serde_json::json!({
        "id": doc.id.to_string(),
        "title": doc.title,
        "icon": doc.icon,
        "excerpt": excerpt,
        "updated_at": doc.updated_at.to_rfc3339(),
        "creator": creator,
    }))
}

/// 检查文档是否为 wiki 首页文档（禁止删除/回收/永久删除）
pub async fn check_not_home_doc(ctx: &AppContext, doc_id: i64) -> Result<()> {
    use sea_orm::PaginatorTrait;
    use base::models::_entities::wikis::{Column as WCol, Entity as WEnt};
    let count = WEnt::find()
        .filter(WCol::HomeDocId.eq(doc_id))
        .count(&ctx.db)
        .await
        .map_err(|_| Error::NotFound)?;
    if count > 0 {
        return Err(Error::BadRequest("cannot delete wiki home page".into()));
    }
    Ok(())
}
