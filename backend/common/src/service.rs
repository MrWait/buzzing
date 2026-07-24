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
    pub im: Arc<Box<dyn BizIm>>,
    pub openapp: Arc<Box<dyn BizOpenApp>>,
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
    pub openapp: Arc<Box<dyn ExternApp + Send + Sync>>,
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
        apps.push(self.openapp.clone());
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
    // M2: 日历/日程查询
    async fn list_calendars(&self, ctx: &AppContext, brief: &UserBrief, tenant_id: i64) -> Result<Vec<entity::Calendar>>;
    async fn list_events(&self, ctx: &AppContext, brief: &UserBrief, calendar_id: i64, start: i64, end: i64) -> Result<Vec<entity::Schedule>>;
    async fn create_event(&self, ctx: &AppContext, brief: &UserBrief, calendar_id: i64, title: &str, start_time: i64, end_time: i64, attendees: &[i64]) -> Result<i64>;
}
pub struct DefaultBizCalendar {}
#[async_trait]
impl BizCalendar for DefaultBizCalendar {
    async fn create_user_default(&self, _ctx: &AppContext, _user_id: i64, _tenant_id: i64, _user_name: &str) -> Result<()> { Err(Error::NotFound) }
    async fn list_calendars(&self, _ctx: &AppContext, _brief: &UserBrief, _tenant_id: i64) -> Result<Vec<entity::Calendar>> { Err(Error::NotFound) }
    async fn list_events(&self, _ctx: &AppContext, _brief: &UserBrief, _calendar_id: i64, _start: i64, _end: i64) -> Result<Vec<entity::Schedule>> { Err(Error::NotFound) }
    async fn create_event(&self, _ctx: &AppContext, _brief: &UserBrief, _calendar_id: i64, _title: &str, _start_time: i64, _end_time: i64, _attendees: &[i64]) -> Result<i64> { Err(Error::NotFound) }
}

#[async_trait]
pub trait BizIm: Send + Sync {
    async fn send_message(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        from_id: i64,
        chat_id: i64,
        msg_type: i32,
        content: Vec<u8>,
        summary: String,
    ) -> Result<i64>;
    async fn edit_message(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        message_id: i64,
        content: Vec<u8>,
        summary: String,
    ) -> Result<()>;
    async fn recall_message(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        message_id: i64,
    ) -> Result<()>;
    // M2: 群信息/成员/消息历史
    async fn get_chat(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        chat_id: i64,
    ) -> Result<entity::Chat>;
    async fn list_chat_members(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        chat_id: i64,
        page: i32,
        page_size: i32,
    ) -> Result<Vec<i64>>;
    async fn list_messages(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        chat_id: i64,
        page: i32,
        page_size: i32,
        before_id: Option<i64>,
    ) -> Result<entity::Entity>;
    // M3: Bot 管理
    async fn create_bot_chat(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        name: &str,
        desc: &str,
        member_ids: &[i64],
    ) -> Result<i64>;
    async fn add_chat_members(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        chat_id: i64,
        member_ids: &[i64],
    ) -> Result<()>;
    async fn remove_chat_members(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        chat_id: i64,
        member_ids: &[i64],
    ) -> Result<()>;
    async fn set_chat_announcement(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        chat_id: i64,
        announcement: &str,
    ) -> Result<()>;
    async fn add_message_reaction(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        message_id: i64,
        reaction: &str,
    ) -> Result<()>;
    async fn remove_message_reaction(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        message_id: i64,
        reaction: &str,
    ) -> Result<()>;
}
pub struct DefaultBizIm {}
#[async_trait]
impl BizIm for DefaultBizIm {
    async fn send_message(&self, _ctx: &AppContext, _brief: &UserBrief, _from_id: i64, _chat_id: i64, _msg_type: i32, _content: Vec<u8>, _summary: String) -> Result<i64> { Err(Error::NotFound) }
    async fn edit_message(&self, _ctx: &AppContext, _brief: &UserBrief, _message_id: i64, _content: Vec<u8>, _summary: String) -> Result<()> { Err(Error::NotFound) }
    async fn recall_message(&self, _ctx: &AppContext, _brief: &UserBrief, _message_id: i64) -> Result<()> { Err(Error::NotFound) }
    async fn get_chat(&self, _ctx: &AppContext, _brief: &UserBrief, _chat_id: i64) -> Result<entity::Chat> { Err(Error::NotFound) }
    async fn list_chat_members(&self, _ctx: &AppContext, _brief: &UserBrief, _chat_id: i64, _page: i32, _page_size: i32) -> Result<Vec<i64>> { Err(Error::NotFound) }
    async fn list_messages(&self, _ctx: &AppContext, _brief: &UserBrief, _chat_id: i64, _page: i32, _page_size: i32, _before_id: Option<i64>) -> Result<entity::Entity> { Err(Error::NotFound) }
    async fn create_bot_chat(&self, _ctx: &AppContext, _brief: &UserBrief, _name: &str, _desc: &str, _member_ids: &[i64]) -> Result<i64> { Err(Error::NotFound) }
    async fn add_chat_members(&self, _ctx: &AppContext, _brief: &UserBrief, _chat_id: i64, _member_ids: &[i64]) -> Result<()> { Err(Error::NotFound) }
    async fn remove_chat_members(&self, _ctx: &AppContext, _brief: &UserBrief, _chat_id: i64, _member_ids: &[i64]) -> Result<()> { Err(Error::NotFound) }
    async fn set_chat_announcement(&self, _ctx: &AppContext, _brief: &UserBrief, _chat_id: i64, _announcement: &str) -> Result<()> { Err(Error::NotFound) }
    async fn add_message_reaction(&self, _ctx: &AppContext, _brief: &UserBrief, _message_id: i64, _reaction: &str) -> Result<()> { Err(Error::NotFound) }
    async fn remove_message_reaction(&self, _ctx: &AppContext, _brief: &UserBrief, _message_id: i64, _reaction: &str) -> Result<()> { Err(Error::NotFound) }
}

#[async_trait]
pub trait BizOpenApp: Send + Sync {
    async fn dispatch_event(
        &self,
        ctx: &AppContext,
        app_db_id: i64,
        app_id_str: &str,
        event_type: &str,
        payload_json: &str,
    ) -> Result<()>;
}
pub struct DefaultBizOpenApp {}
#[async_trait]
impl BizOpenApp for DefaultBizOpenApp {
    async fn dispatch_event(
        &self,
        _ctx: &AppContext,
        _app_db_id: i64,
        _app_id_str: &str,
        _event_type: &str,
        _payload_json: &str,
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
    // M2: 部门/组织架构
    async fn list_depts(&self, ctx: &AppContext, brief: &UserBrief, tenant_id: i64) -> Result<Vec<entity::Department>>;
    async fn get_dept(&self, ctx: &AppContext, brief: &UserBrief, dept_id: i64) -> Result<entity::Department>;
    async fn list_dept_members(&self, ctx: &AppContext, brief: &UserBrief, dept_id: i64, page: i32, page_size: i32) -> Result<Vec<entity::User>>;
}
pub struct DefaultBizUser {}
#[async_trait]
impl BizUser for DefaultBizUser {
    async fn get_user_by_id(&self, _ctx: &AppContext, _user_id: i64) -> Result<entity::User> { Err(Error::NotFound) }
    async fn get_user_by_ids(&self, _ctx: &AppContext, _user_ids: Vec<i64>) -> Result<Vec<entity::User>> { Err(Error::NotFound) }
    async fn list_depts(&self, _ctx: &AppContext, _brief: &UserBrief, _tenant_id: i64) -> Result<Vec<entity::Department>> { Err(Error::NotFound) }
    async fn get_dept(&self, _ctx: &AppContext, _brief: &UserBrief, _dept_id: i64) -> Result<entity::Department> { Err(Error::NotFound) }
    async fn list_dept_members(&self, _ctx: &AppContext, _brief: &UserBrief, _dept_id: i64, _page: i32, _page_size: i32) -> Result<Vec<entity::User>> { Err(Error::NotFound) }
}
