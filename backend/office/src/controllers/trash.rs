use axum::debug_handler;
use loco_rs::prelude::*;
use serde::Serialize;

use crate::controllers::docs::{check_not_home_doc, DocResponse};
use crate::models::documents::DocumentModel;
use crate::permission::{require_role, Role};
use common::model::UserBrief;

/// 回收站保留天数
pub const TRASH_RETENTION_DAYS: i64 = 30;

#[derive(Debug, Serialize)]
pub struct TrashItem {
    #[serde(flatten)]
    pub doc: DocResponse,
    /// 剩余天数 (向上取整)
    pub remaining_days: i64,
}

#[debug_handler]
pub async fn list(auth: auth::JWT, State(ctx): State<AppContext>) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let docs = DocumentModel::list_trashed(&ctx.db, claim.tenant_id, claim.id).await?;
    let now = chrono::Utc::now();
    let items: Vec<TrashItem> = docs
        .into_iter()
        .map(|d| {
            let trashed_at = d.trashed_at.map(|v| v.with_timezone(&chrono::Utc));
            let remaining = trashed_at
                .map(|t| {
                    let expires = t + chrono::Duration::days(TRASH_RETENTION_DAYS);
                    let delta = expires - now;
                    delta.num_days().max(0)
                })
                .unwrap_or(0);
            TrashItem {
                doc: DocResponse::from_model(d),
                remaining_days: remaining,
            }
        })
        .collect();
    format::json(items)
}

#[debug_handler]
pub async fn restore(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, id, Role::Owner).await?;
    let doc = DocumentModel::restore(&ctx.db, id).await?;
    format::json(DocResponse::from_model(doc))
}

/// 永久删除
#[debug_handler]
pub async fn purge(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, id, Role::Owner).await?;
    check_not_home_doc(&ctx, id).await?;
    DocumentModel::purge(&ctx.db, id).await?;
    format::json(serde_json::json!({"ok": true}))
}

/// 后台任务：清理超过保留期的回收站文档 (由 lib.rs 的定时任务调用)
pub async fn cleanup_expired(ctx: &AppContext) -> Result<usize> {
    let cutoff = chrono::Utc::now() - chrono::Duration::days(TRASH_RETENTION_DAYS);
    let expired = DocumentModel::list_expired_trashed(&ctx.db, cutoff).await?;
    let count = expired.len();
    for d in expired {
        if let Err(e) = DocumentModel::purge(&ctx.db, d.id).await {
            tracing::warn!(doc_id = d.id, err = %e, "purge expired doc failed");
        }
    }
    Ok(count)
}
