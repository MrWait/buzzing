pub mod models;

use axum::debug_handler;
use loco_rs::prelude::*;
use std::sync::{Arc, OnceLock};
use tracing::debug;

use crate::models::settings::SettingModel;
use common::{BizSetting, ExternApp, Settings, lock::Mutex, lock::RwLock};
use proto::idl::entity;

pub struct UnionConfig {}

#[derive(Clone, Default, Debug)]
pub struct AppSetting {
    pub settings: Arc<Mutex<Settings>>,
}

static CLIENT_CONFIG: OnceLock<Arc<RwLock<String>>> = OnceLock::new();
impl ExternApp for AppSetting {
    fn initializers(&self, ctx: &AppContext) -> Vec<Box<dyn Initializer>> {
        self.init_setting(&ctx.config.settings);
        Vec::new()
    }

    fn routes(&self, _ctx: &AppContext) -> Vec<loco_rs::prelude::Routes> {
        vec![
            Routes::new()
                .prefix("/union")
                .add("/register", post(union_register))
                .add("/update", post(union_update)),
            Routes::new()
                .prefix("/config")
                .add("/user", get(get_user_config))
                .add("/client", get(get_client_config)),
        ]
    }
}

impl AppSetting {
    fn init_setting(&self, value: &Option<serde_json::Value>) {
        value
            .as_ref()
            .and_then(|value| serde_json::from_value::<Settings>(value.clone()).ok())
            .and_then(|settings| {
                let mut lock = self.settings.lock();
                *lock = settings;
                Some(())
            });
        debug!("set config: {:?}", self.settings);
        {
            let settings = self.settings.lock();
            settings.union_id.and_then(|id| {
                common::set_union_id(id);
                Some(())
            });
        }

        let union_config = {
            let setting = self.settings.lock();
            setting.client_config.clone()
        };

        if let Some(path) = union_config {
            let path = std::path::PathBuf::from(path);
            let _ = std::fs::read_to_string(path).and_then(|content| {
                debug!("read client config: {content}");
                let client_config = Arc::new(RwLock::new(content));
                let _ = CLIENT_CONFIG.set(client_config);
                Ok(())
            });
        }
    }
}

#[async_trait::async_trait]
impl BizSetting for AppSetting {
    async fn set_config(
        &self,
        db: &DatabaseConnection,
        user_id: i64,
        t: i32,
        setting: &entity::Setting,
    ) -> Result<()> {
        SettingModel::setting_set(db, user_id, t, setting).await?;
        Ok(())
    }
    async fn get_config(
        &self,
        db: &DatabaseConnection,
        user_id: i64,
        t: i32,
    ) -> Result<Option<entity::Setting>> {
        let result = SettingModel::setting_get(db, user_id, t).await?;
        Ok(result)
    }

    async fn update_config(
        &self,
        db: &DatabaseConnection,
        user_id: i64,
        t: i32,
        f: Box<dyn Fn(entity::Setting) -> Result<entity::Setting> + Send + Sync>,
    ) -> Result<entity::Setting> {
        let result = SettingModel::setting_update(db, user_id, t, f).await?;
        Ok(result)
    }
}

#[debug_handler]
async fn get_client_config() -> String {
    let content = CLIENT_CONFIG
        .get()
        .and_then(|config| Some(config.read().clone()))
        .unwrap_or_default();
    content
}

async fn get_user_config() -> &'static str {
    "ok"
}

async fn union_register() -> &'static str {
    "ok"
}

async fn union_update() -> &'static str {
    "ok"
}
