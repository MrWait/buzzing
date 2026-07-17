mod controllers;
pub mod models;
pub mod services;

use async_trait::async_trait;
use loco_rs::prelude::*;
use loco_rs::{Result, app::AppContext};

pub use base::{mailers, util, views};
use common::{ExternApp, BizStore};

#[derive(Clone)]
pub struct AppStore;
#[async_trait]
impl ExternApp for AppStore {
    fn routes(&self, _: &AppContext) -> Vec<Routes> {
        vec![Routes::new()
            .prefix("/api/files")
            .add("/upload", post(controllers::files::upload))
            .add("/{id}", get(controllers::files::download))
            .add("/{id}/info", get(controllers::files::info))
            .add("/{id}", delete(controllers::files::delete))]
    }
}

#[async_trait]
impl BizStore for AppStore {
    async fn create_text_image(
        &self,
        ctx: &AppContext,
        content: &str,
        category: &str,
    ) -> Result<String> {
        controllers::file::generate_text_image(ctx, content, category).await
    }
}
