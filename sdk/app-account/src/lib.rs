mod database;
mod dept;
mod user;

use anyhow::Result;
use async_trait::async_trait;
use base_db::DbConn;
use std::sync::Arc;
use tracing::debug;

use base_runtime::spawn;
use base_util::lock::RwLock;
use proto::idl::{command::Command, entity::Entity};
use proto::EntityIds;
use service::account::{BizAccount, DeviceInfo, UserInfo};
use service::{AppTrait, BizHub, Event, InitRequest, LoginRequest, UnionClientConfig};

#[derive(Debug, Default, Clone)]
struct AccountInfo {
    device_info: DeviceInfo,
    user_info: UserInfo,
    client_config: UnionClientConfig,
}

#[derive(Clone)]
pub struct AppAccount {
    account_info: Arc<RwLock<AccountInfo>>,
    db: Arc<DbConn>,
}
impl AppAccount {
    pub fn new() -> Self {
        AppAccount {
            account_info: Arc::new(RwLock::new(AccountInfo::default())),
            db: Arc::new(DbConn::default()),
        }
    }
}

#[async_trait]
impl AppTrait for AppAccount {
    fn init(&self, req: &InitRequest) -> Result<()> {
        let device_info = DeviceInfo {
            app_id: req.app_id.clone(),
            device_type: req.device_type.clone(),
            device_id: req.device_id.clone(),
            app_version: req.app_version.clone(),
            log_path: req.log_path.clone(),
            storage_path: std::path::Path::new(&req.storage_path).to_path_buf(),
        };
        self.set_device_info(&device_info);
        Ok(())
    }
    fn uninit(&self) -> Result<()> {
        Ok(())
    }

    fn login(&self, req: &LoginRequest) -> Result<()> {
        let device_info = self.get_device_info();
        let mut storage_path = device_info.storage_path.clone();
        storage_path.push(req.user_id.to_string());

        std::fs::create_dir_all(&storage_path)?;
        let user_info = UserInfo {
            user_id: req.user_id,
            token: req.token.clone(),
            tenant_id: req.tenant_id,
            seq: 0,
            country: "".to_string(),
            storage_path,
            db_key: base_util::db_get_crypt_key(
                &req.tenant_id.to_string(),
                &req.user_id.to_string(),
            ),
        };
        tracing::info!("login with user info: {:?}", user_info);

        let conn = database::init_db(&user_info, &device_info)?;
        {
            let mut account_info = self.account_info.write();
            (*account_info).user_info = user_info;
            (*account_info).client_config = req.client_config.clone();
        }
        self.db.set(conn);
        Ok(())
    }
    fn logout(&self) -> Result<()> {
        self.db.reset();
        Ok(())
    }

    fn ffi_commands(&self) -> Vec<i32> {
        vec![Command::UserGetByIds as i32, Command::DeptGetById as i32]
    }

    async fn on_ffi_command(&self, command: i32, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let cmd = Command::try_from(command)?;
        let ret = match cmd {
            Command::UserGetByIds => self.user_get_by_ids(params).await,
            Command::DeptGetById => self.dept_get_by_id(params).await,
            _ => Err(anyhow::anyhow!("not handled")),
        };
        ret
    }
    async fn on_net_command(&self, _source: i32, _command: i32, _params: &[u8]) -> Result<()> {
        Err(anyhow::anyhow!("not handled"))
    }
    fn on_event(&self, _event: Event, _params: &[u8]) {}
}

impl BizAccount for AppAccount {
    fn set_device_info(&self, device: &DeviceInfo) {
        let mut account_info = self.account_info.write();
        (*account_info).device_info = device.clone();
    }

    fn get_device_info(&self) -> DeviceInfo {
        let account_info = self.account_info.read();
        account_info.device_info.clone()
    }

    fn set_user_info(&self, user: &UserInfo) {
        let mut account_info = self.account_info.write();
        (*account_info).user_info = user.clone();
    }

    fn get_user_info(&self) -> UserInfo {
        let account_info = self.account_info.read();
        account_info.user_info.clone()
    }

    fn fill_entity(
        &self,
        entity_ids: &mut EntityIds,
        entity: &mut Entity,
        sync: bool,
    ) -> Result<()> {
        entity_ids.user_ids.remove(&0);
        entity_ids
            .user_ids
            .retain(|id| !entity.users.contains_key(id));
        {
            let conn = self.db.inner()?;
            let user_ids: Vec<i64> = entity_ids.user_ids.iter().copied().collect();
            let mut users = Vec::new();
            database::user::user_get_by_ids(&conn, &user_ids, &mut users)?;
            entity
                .users
                .extend(users.drain(..).map(|user| (user.id, user)));
        }
        entity_ids
            .user_ids
            .retain(|id| !entity.users.contains_key(id));

        if !entity_ids.user_ids.is_empty() {
            debug!("missing user info: {:?}", entity_ids.user_ids);
            if sync {
                let ids: Vec<i64> = entity_ids.user_ids.iter().copied().collect();
                spawn(async move {
                    if let Ok(hub) = BizHub::get() {
                        if let Some(acc) = hub.account.downcast_ref::<AppAccount>() {
                            let _ = acc.user_pull_by_ids(ids, true).await;
                        }
                    }
                });
            }
        }
        Ok(())
    }
}
