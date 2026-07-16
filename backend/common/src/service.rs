use async_trait::async_trait;
use dashmap::DashMap;
use loco_rs::app::{AppContext, Initializer};
use loco_rs::prelude::{DatabaseConnection, Routes};
use loco_rs::{Error, Result};
use std::sync::{Arc, OnceLock};

use crate::EntityIds;
use crate::model::UserBrief;
use proto::idl::{command::Command, entity};

pub(crate) static APPS: OnceLock<Arc<AppHub>> = OnceLock::new();
pub(crate) static SERVICES: OnceLock<Arc<BizHub>> = OnceLock::new();

#[async_trait]
pub trait ExternApp {
    fn initializers(&self, _ctx: &AppContext) -> Vec<Box<dyn Initializer>> {
        Vec::new()
    }
    fn routes(&self, _ctx: &AppContext) -> Vec<Routes> {
        Vec::new()
    }
    fn serve(&self, _ctx: &AppContext) {}
    async fn handle_client_packet(
        &self,
        _cmd: i32,
        _ctx: &AppContext,
        _brief: &UserBrief,
        _packet: &entity::Packet,
        _ws: bool,
    ) -> Result<(i32, Vec<u8>)> {
        Err(Error::NotFound)
    }
    // 默认仅填充 src 即可。可在 ids 里填充附属依赖，
    // 或提前填充，并清理 ids
    async fn fill_entity(
        &self,
        _ctx: &AppContext,
        _brief: &UserBrief,
        _ids: &mut EntityIds,
        _entity: &mut entity::Entity,
    ) {
    }

    fn handled_command(&self) -> Vec<i32> {
        Vec::new()
    }
}

pub struct BizHub {
    pub store_impl: Arc<Box<dyn BizStore>>,
    pub gateway: Arc<Box<dyn BizGateway>>,
    pub setting: Arc<Box<dyn BizSetting>>,
    pub calendar: Arc<Box<dyn BizCalendar>>,
    pub office: Arc<Box<dyn BizOffice>>,
    pub user: Arc<Box<dyn BizUser>>,
}
impl BizHub {
    pub fn set(hub: Arc<BizHub>) {
        let _ = SERVICES.set(hub);
    }
    pub fn get() -> Result<Arc<Self>> {
        SERVICES.get().cloned().ok_or(Error::NotFound)
    }
}

pub struct AppHub {
    pub calendar: Arc<Box<dyn ExternApp + Send + Sync>>,
    pub gateway: Arc<Box<dyn ExternApp + Send + Sync>>,
    pub im: Arc<Box<dyn ExternApp + Send + Sync>>,
    pub office: Arc<Box<dyn ExternApp + Send + Sync>>,
    pub rtc: Arc<Box<dyn ExternApp + Send + Sync>>,
    pub store: Arc<Box<dyn ExternApp + Send + Sync>>,
    pub setting: Arc<Box<dyn ExternApp + Send + Sync>>,
    pub todo: Arc<Box<dyn ExternApp + Send + Sync>>,
    pub user: Arc<Box<dyn ExternApp + Send + Sync>>,

    pub gateway_handlers: Arc<DashMap<i32, Arc<Box<dyn ExternApp + Send + Sync>>>>,
}
impl AppHub {
    pub fn set(hub: Arc<AppHub>) {
        let apps = hub.get_all();
        for app in apps.iter() {
            let cmds = app.handled_command();
            for cmd in cmds.iter() {
                hub.gateway_handlers.insert(*cmd, app.clone());
            }
        }
        let _ = APPS.set(hub);
    }

    pub fn get() -> Result<Arc<Self>> {
        APPS.get().cloned().ok_or(Error::NotFound)
    }

    pub fn get_all(&self) -> Vec<Arc<Box<dyn ExternApp + Send + Sync>>> {
        let mut apps = Vec::new();
        apps.push(self.calendar.clone());
        apps.push(self.gateway.clone());
        apps.push(self.im.clone());
        apps.push(self.office.clone());
        apps.push(self.rtc.clone());
        apps.push(self.store.clone());
        apps.push(self.setting.clone());
        apps.push(self.todo.clone());
        apps.push(self.user.clone());
        apps
    }

    pub async fn handle_packet(
        &self,
        cmd: i32,
        ctx: &AppContext,
        brief: &UserBrief,
        packet: &entity::Packet,
        ws: bool,
    ) -> Result<(i32, Vec<u8>)> {
        if let Some(app) = self.gateway_handlers.get(&cmd) {
            return app.handle_client_packet(cmd, ctx, brief, packet, ws).await;
        }
        return Err(Error::NotFound);
    }

    pub async fn fill_entity(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        ids: &mut EntityIds,
        entity: &mut entity::Entity,
    ) -> Result<()> {
        self.im.fill_entity(ctx, brief, ids, entity).await;
        self.calendar.fill_entity(ctx, brief, ids, entity).await;
        self.user.fill_entity(ctx, brief, ids, entity).await;
        Ok(())
    }
}

#[async_trait]
pub trait BizStore: Send + Sync {
    async fn create_text_image(
        &self,
        ctx: &AppContext,
        content: &str,
        category: &str,
    ) -> Result<String>;
}
pub struct DefaultBizStore {}
#[async_trait]
impl BizStore for DefaultBizStore {
    async fn create_text_image(
        &self,
        _ctx: &AppContext,
        _content: &str,
        _category: &str,
    ) -> Result<String> {
        Err(Error::NotFound)
    }
}

#[async_trait]
pub trait BizGateway: Send + Sync {
    async fn send_packet_to_user(
        &self,
        _ctx: &AppContext,
        _users: &[i64],
        _sid: i64,
        _cmd: Command,
        _body: Vec<u8>,
        _pipe: bool,
    ) -> Result<()>;
}
pub struct DefaultBizGateway {}
#[async_trait]
impl BizGateway for DefaultBizGateway {
    async fn send_packet_to_user(
        &self,
        _ctx: &AppContext,
        _users: &[i64],
        _sid: i64,
        _cmd: Command,
        _body: Vec<u8>,
        _pipe: bool,
    ) -> Result<()> {
        Ok(())
    }
}

#[async_trait]
pub trait BizSetting: Send + Sync {
    async fn set_config(
        &self,
        db: &DatabaseConnection,
        user_id: i64,
        t: i32,
        setting: &entity::Setting,
    ) -> Result<()>;
    async fn get_config(
        &self,
        db: &DatabaseConnection,
        user_id: i64,
        t: i32,
    ) -> Result<Option<entity::Setting>>;
    async fn update_config(
        &self,
        db: &DatabaseConnection,
        user_id: i64,
        t: i32,
        f: Box<dyn Fn(entity::Setting) -> Result<entity::Setting> + Send + Sync>,
    ) -> Result<entity::Setting>;
}
pub struct DefaultBizSetting {}
#[async_trait]
impl BizSetting for DefaultBizSetting {
    async fn set_config(
        &self,
        _db: &DatabaseConnection,
        _user_id: i64,
        _t: i32,
        _setting: &entity::Setting,
    ) -> Result<()> {
        Err(Error::NotFound)
    }
    async fn get_config(
        &self,
        _db: &DatabaseConnection,
        _user_id: i64,
        _t: i32,
    ) -> Result<Option<entity::Setting>> {
        Err(Error::NotFound)
    }
    async fn update_config(
        &self,
        _db: &DatabaseConnection,
        _user_id: i64,
        _t: i32,
        _f: Box<dyn Fn(entity::Setting) -> Result<entity::Setting> + Send + Sync>,
    ) -> Result<entity::Setting> {
        Err(Error::NotFound)
    }
}

#[async_trait]
pub trait BizOffice: Send + Sync {
    async fn create_user_default(
        &self,
        ctx: &AppContext,
        user_id: i64,
        tenant_id: i64,
        user_name: &str,
    ) -> Result<()>;
}
pub struct DefaultBizOffice {}
#[async_trait]
impl BizOffice for DefaultBizOffice {
    async fn create_user_default(
        &self,
        _ctx: &AppContext,
        _user_id: i64,
        _tenant_id: i64,
        _user_name: &str,
    ) -> Result<()> {
        Err(Error::NotFound)
    }
}

#[async_trait]
pub trait BizCalendar: Send + Sync {
    async fn create_user_default(
        &self,
        ctx: &AppContext,
        user_id: i64,
        tenant_id: i64,
        user_name: &str,
    ) -> Result<()>;
}
pub struct DefaultBizCalendar {}
#[async_trait]
impl BizCalendar for DefaultBizCalendar {
    async fn create_user_default(
        &self,
        _ctx: &AppContext,
        _user_id: i64,
        _tenant_id: i64,
        _user_name: &str,
    ) -> Result<()> {
        Err(Error::NotFound)
    }
}

#[async_trait]
pub trait BizUser: Send + Sync {
    async fn get_user_by_id(&self, ctx: &AppContext, user_id: i64) -> Result<entity::User>;
    async fn get_user_by_ids(
        &self,
        ctx: &AppContext,
        user_ids: Vec<i64>,
    ) -> Result<Vec<entity::User>>;
}
pub struct DefaultBizUser {}
#[async_trait]
impl BizUser for DefaultBizUser {
    async fn get_user_by_id(&self, _ctx: &AppContext, _user_id: i64) -> Result<entity::User> {
        Err(Error::NotFound)
    }

    async fn get_user_by_ids(
        &self,
        ctx: &AppContext,
        user_ids: Vec<i64>,
    ) -> Result<Vec<entity::User>> {
        Err(Error::NotFound)
    }
}
