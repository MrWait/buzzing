mod database;
mod global_database;

use anyhow::Result;
use async_trait::async_trait;
use base_db::meta::MetaTable;
use std::sync::Arc;

use base_db::prelude::DbConn;
use proto::idl::command::Command;
use service::common::{Task, TaskHandler};
use service::{AppTrait, BizCommon, Event, InitRequest, LoginRequest};
use service::{BizHub, Setting};

#[derive(Clone)]
pub struct AppCommon {
    db: Arc<DbConn>,
    global_db: Arc<DbConn>,
}
impl AppCommon {
    pub fn new() -> Self {
        AppCommon {
            db: Arc::new(DbConn::default()),
            global_db: Arc::new(DbConn::default()),
        }
    }
}

#[async_trait]
impl AppTrait for AppCommon {
    fn init(&self, _req: &InitRequest) -> Result<()> {
        let hub = BizHub::get()?;
        let device_info = hub.account.get_device_info();
        let conn = global_database::init_db(&device_info)?;
        self.global_db.set(conn);

        Ok(())
    }
    fn uninit(&self) -> Result<()> {
        Ok(())
    }

    fn login(&self, _req: &LoginRequest) -> Result<()> {
        let hub = BizHub::get()?;
        let user_info = hub.account.get_user_info();
        let device_info = hub.account.get_device_info();
        let conn = database::init_db(&user_info, &device_info)?;
        self.db.set(conn);

        Ok(())
    }
    fn logout(&self) -> Result<()> {
        self.db.reset();
        Ok(())
    }
    async fn on_ffi_command(&self, _command: i32, _params: &[u8]) -> Result<(i32, Vec<u8>)> {
        Err(anyhow::anyhow!("not handled"))
    }
    async fn on_net_command(&self, _source: i32, command: i32, _params: &[u8]) -> Result<()> {
        let cmd = command.try_into()?;
        match cmd {
            Command::UploadLog => {}
            _ => {}
        }
        Err(anyhow::anyhow!("not handled"))
    }
    fn on_event(&self, _event: Event, _params: &[u8]) {}
}

#[async_trait]
impl BizCommon for AppCommon {
    fn global_config_set(&self, key: &str, value: &str) -> Result<()> {
        let db = self.global_db.inner()?;
        MetaTable::meta(&db).insert(key, value)?;
        Ok(())
    }
    fn global_config_get(&self, key: &str) -> Result<String> {
        let db = self.global_db.inner()?;
        Ok(MetaTable::meta(&db).get(key)?)
    }
    fn config_set(&self, key: &str, value: &str) -> Result<()> {
        let db = self.db.inner()?;
        database::setting::setting_add(
            &db,
            &Setting {
                key: key.to_string(),
                value: value.to_string(),
                version: 0,
                dirty: false,
            },
        )?;
        Ok(())
    }
    fn config_get(&self, key: &str) -> Result<Setting> {
        let db = self.db.inner()?;
        database::setting::setting_get_by_key(&db, key).map_err(|_| anyhow::anyhow!("error"))
    }

    fn task_add(&self, _task: Task) {}
    fn reg_task_handler(&self, _cmd: i32, _h: Arc<Box<dyn TaskHandler>>) {}

    async fn run_task(&self) {}
}
