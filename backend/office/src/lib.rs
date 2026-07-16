use loco_rs::app::AppContext;
use loco_rs::prelude::*;
use sea_orm::ActiveValue;
use std::sync::Arc;

use common::ExternApp;
use common::BizOffice;

pub mod controllers;
pub mod models;
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
        use crate::models::document_spaces::DocumentSpaceModel;

        let space_name = format!("{} 的文档", user_name);
        DocumentSpaceModel::create(
            &ctx.db,
            base::models::_entities::document_spaces::ActiveModel {
                id: ActiveValue::set(id_gen(None)),
                tenant_id: ActiveValue::set(tenant_id),
                creator: ActiveValue::set(user_id),
                name: ActiveValue::set(space_name),
                sp_type: ActiveValue::set(1),
                ..Default::default()
            },
        )
        .await?;
        Ok(())
    }
}


