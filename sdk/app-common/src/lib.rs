mod database;
mod global_database;

use anyhow::Result;
use async_trait::async_trait;
use base_db::meta::MetaTable;
use prost::Message as _;
use std::sync::Arc;

use base_db::prelude::DbConn;
use proto::idl::command::Command;
use proto::idl::setting;
use service::common::{Task, TaskHandler};
use service::{AppTrait, BizCommon, Event, InitRequest, LoginRequest};
use service::{BizHub, Setting};
use tracing::debug;

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
    fn ffi_commands(&self) -> Vec<i32> {
        vec![
            Command::SettingSet as i32,
            Command::SettingGet as i32,
        ]
    }

    async fn on_ffi_command(&self, command: i32, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let cmd = Command::try_from(command)?;
        let ret = match cmd {
            Command::SettingSet => self.setting_set(params),
            Command::SettingGet => self.setting_get(params),
            _ => return Err(anyhow::anyhow!("not handled")),
        };
        if let Err(ref err) = ret {
            debug!("handle setting command error: {:?}", err);
        }
        ret
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

impl AppCommon {
    fn setting_set(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = setting::LocalSettingSetRequest::decode(params)?;
        let db = self.db.inner()?;
        database::setting::setting_add(
            &db,
            &Setting {
                key: req.key.clone(),
                value: req.value.clone(),
                version: 0,
                dirty: false,
            },
        )?;
        Ok((0, setting::LocalSettingSetResponse {}.encode_to_vec()))
    }

    fn setting_get(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = setting::LocalSettingGetRequest::decode(params)?;
        let db = self.db.inner()?;
        match database::setting::setting_get_by_key(&db, &req.key) {
            Ok(setting) => {
                let resp = setting::LocalSettingGetResponse {
                    key: setting.key,
                    value: setting.value,
                };
                Ok((0, resp.encode_to_vec()))
            }
            Err(_) => Ok((0, setting::LocalSettingGetResponse::default().encode_to_vec())),
        }
    }
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
