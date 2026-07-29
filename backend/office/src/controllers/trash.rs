use loco_rs::prelude::*;

use crate::models::documents::DocumentModel;

/// 回收站保留天数
pub const TRASH_RETENTION_DAYS: i64 = 30;

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
