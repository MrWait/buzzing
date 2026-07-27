use loco_rs::app::AppContext;
use loco_rs::prelude::*;
use sea_orm::ActiveValue;
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
        ctx: &AppContext,
        user_id: i64,
        tenant_id: i64,
        user_name: &str,
    ) -> Result<()> {
        use common::id_gen;
        use sea_orm::ActiveValue as AV;
        use yrs::{Doc, ReadTxn, Transact};

        // 创建个人根文档（wiki_id = NULL）
        let doc_id = id_gen(None);
        let empty_yjs = {
            let doc = Doc::new();
            doc.transact().encode_state_as_update_v1(&Default::default())
        };
        crate::models::documents::DocumentModel::create(
            &ctx.db,
            base::models::_entities::documents::ActiveModel {
                id: AV::Set(doc_id),
                wiki_id: AV::Set(None),
                tenant_id: AV::Set(tenant_id),
                creator: AV::Set(user_id),
                title: AV::Set(format!("{} 的文档库", user_name)),
                doc_type: AV::Set(1),
                version: AV::Set(common::time::current_ms() as i64),
                content: AV::Set(empty_yjs),
                parent_id: AV::Set(Some(user_id)),
                icon: AV::Set(None),
                ..Default::default()
            },
        ).await?;
        Ok(())
    }
}


