use loco_rs::app::AppContext;
use loco_rs::prelude::*;
use std::sync::Arc;

use common::ExternApp;
use common::BizOffice;

pub mod controllers;
pub mod models;
pub mod permission;
pub mod ws;
pub mod yjs_store;

#[derive(Clone)]
pub struct AppOffice;
impl ExternApp for AppOffice {
    fn routes(&self, _ctx: &AppContext) -> Vec<Routes> {
        controllers::routes()
    }

    fn serve(&self, ctx: &AppContext) {
        let manager = Arc::new(ws::YjsManager::new(ctx.clone()));
        ws::YJS_MANAGER.set(manager).ok();

        let ctx_clone = ctx.clone();
        tokio::spawn(async move {
            ws::periodic_save_loop(ctx_clone).await;
        });

        // M3: 定时清理回收站到期文档 (每天 03:00 检查一次，粒度到小时即可)
        let ctx_clone = ctx.clone();
        tokio::spawn(async move {
            let mut interval = tokio::time::interval(tokio::time::Duration::from_secs(3600));
            loop {
                interval.tick().await;
                match controllers::trash::cleanup_expired(&ctx_clone).await {
                    Ok(n) if n > 0 => {
                        tracing::info!(count = n, "office: cleaned expired trashed docs");
                    }
                    Ok(_) => {}
                    Err(e) => tracing::warn!(err = %e, "office: trash cleanup failed"),
                }
            }
        });
    }
}

#[async_trait::async_trait]
impl BizOffice for AppOffice {
    async fn create_user_default(
        &self,
        _ctx: &AppContext,
        _user_id: i64,
        _tenant_id: i64,
        _user_name: &str,
    ) -> Result<()> {
        // 个人空间是虚拟的，不需要创建根文档。顶层文档的 parent_id = user_id。
        Ok(())
    }
}


