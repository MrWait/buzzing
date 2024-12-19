mod controllers;

use async_trait::async_trait;
use loco_rs::prelude::*;
use loco_rs::{Result, app::AppContext};

pub use base::{mailers, models, util, views};
use common::{ExternApp, BizStore};

#[derive(Clone)]
pub struct AppStore;
#[async_trait]
impl ExternApp for AppStore {
    fn routes(&self, _: &AppContext) -> Vec<Routes> {
        vec![controllers::file::routes()]
    }
}

#[async_trait]
impl BizStore for AppStore {
    async fn create_text_image(
        &self,
        ctx: &AppContext,
        content: &str,
        categore: &str,
    ) -> Result<String> {
        controllers::file::generate_text_image(ctx, content, categore).await
    }
}
