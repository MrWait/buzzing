pub mod account;
pub mod calendar;
pub mod chat;
pub mod common;
pub mod ffi;
mod get;
pub mod model;
pub mod network;
pub mod office;
pub mod todo;

use anyhow::Result;
use async_trait::async_trait;
use dashmap::DashMap;
use serde::{Deserialize, Serialize};
use std::{
    default,
    sync::{Arc, OnceLock},
};
use tracing::debug;

pub use account::BizAccount;
pub use calendar::BizCalendar;
pub use chat::BizChat;
pub use common::BizCommon;
pub use ffi::BizFfi;
pub use model::Setting;
pub use network::BizNetwork;
pub use office::BizOffice;
pub use todo::BizTodo;

static BIZ_HUB: OnceLock<Arc<BizHub>> = OnceLock::new();

#[derive(Debug, Clone, Copy)]
pub enum Event {
    EventLogin,
    EventLogout,
    EventNetConnect,
    EventNetDisconnect,
    EventFeedSyncFinish,
    EventPipeSyncFinish,
}

#[derive(Debug)]
pub struct InitRequest {
    pub device_type: i32,
    pub app_id: String,
    pub app_version: String,
    pub device_id: String,
    pub log_path: String,
    pub storage_path: String,
    pub locale: String,
    pub common_data_path: String,
}

#[derive(Clone)]
pub struct BizHub {
    pub app_account: Arc<Box<dyn AppTrait>>,
    pub app_chat: Arc<Box<dyn AppTrait>>,
    pub app_common: Arc<Box<dyn AppTrait>>,
    pub app_ffi: Arc<Box<dyn AppTrait>>,
    pub app_network: Arc<Box<dyn AppTrait>>,
    pub app_calendar: Arc<Box<dyn AppTrait>>,
    pub app_office: Arc<Box<dyn AppTrait>>,

    pub ffi_handlers: DashMap<i32, Arc<Box<dyn AppTrait>>>,
    pub net_handlers: DashMap<i32, Arc<Box<dyn AppTrait>>>,

    pub account: Arc<Box<dyn BizAccount>>,
    pub chat: Arc<Box<dyn BizChat>>,
    pub common: Arc<Box<dyn BizCommon>>,
    pub ffi: Arc<Box<dyn BizFfi>>,
    pub network: Arc<Box<dyn BizNetwork>>,
    pub calendar: Arc<Box<dyn BizCalendar>>,
    pub todo: Arc<Box<dyn BizTodo>>,
    pub office: Arc<Box<dyn BizOffice>>,
}

impl BizHub {
    pub fn get() -> Result<Arc<Self>> {
        Ok(BIZ_HUB
            .get()
            .ok_or(anyhow::anyhow!("service not init"))?
            .clone())
    }

    pub fn set(mut hub: Self) {
        let services = hub.get_all();
        for svc in services.iter() {
            let cmds = svc.ffi_commands();
            hub.ffi_handlers
                .extend(cmds.iter().map(|cmd| (*cmd, svc.clone())));
            let cmds = svc.net_commands();
            hub.net_handlers
                .extend(cmds.iter().map(|cmd| (*cmd, svc.clone())));
        }

        let _ = BIZ_HUB.set(Arc::new(hub));
    }

    pub fn get_all(&self) -> Vec<Arc<Box<dyn AppTrait>>> {
        let mut services = Vec::new();
        services.push(self.app_account.clone());
        services.push(self.app_chat.clone());
        services.push(self.app_common.clone());
        services.push(self.app_ffi.clone());
        services.push(self.app_network.clone());
        services.push(self.app_calendar.clone());
        services.push(self.app_office.clone());
        services
    }

    pub fn emit_event(&self, event: Event, body: &[u8]) {
        let services = self.get_all();
        for svc in services.iter() {
            svc.on_event(event, &body);
        }
    }

    pub async fn invoke_ffi_command(&self, cmd: i32, body: &[u8]) -> Result<(i32, Vec<u8>)> {
        if let Some(handler) = self.ffi_handlers.get(&cmd) {
            handler.on_ffi_command(cmd, body).await
        } else {
            Err(anyhow::anyhow!("not support"))
        }
    }

    pub async fn invoke_net_command(&self, source: i32, cmd: i32, body: &[u8]) -> Result<()> {
        if let Some(handler) = self.net_handlers.get(&cmd) {
            handler.on_net_command(source, cmd, body).await
        } else {
            Err(anyhow::anyhow!("not support"))
        }
    }
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct UnionClientConfig {
    pub union: String,
    pub union_id: i32,
    pub gateway: String,
    pub gateway_port: i32,
    pub ws: String,
    pub ws_port: i32,
    pub upload_file_path: String,
    pub upload_avatar_path: String,
    pub api_gateway: String,
    pub features: Vec<String>,
}

impl Default for UnionClientConfig {
    fn default() -> Self {
        Self {
            union: "www.buzzing-im.com".to_string(),
            union_id: 1024,
            gateway: "http://www.buzzing-im.com".to_string(),
            gateway_port: 5150,
            ws: "ws://www.buzzing-im.com".to_string(),
            ws_port: 8889,
            upload_file_path: "/storage/file/upload".to_string(),
            upload_avatar_path: "/storage/avatar/upload".to_string(),
            api_gateway: "/api/v1".to_string(),
            features: vec![
                "im".to_string(),
                "calendar".to_string(),
                "meeting".to_string(),
            ],
        }
    }
}

#[derive(Debug)]
pub struct LoginRequest {
    pub user_id: i64,
    pub token: String,
    pub tenant_id: i64,
    pub client_config: UnionClientConfig,
}

#[async_trait]
pub trait AppTrait: Send + Sync {
    fn init(&self, req: &InitRequest) -> Result<()>;
    fn uninit(&self) -> Result<()>;
    fn login(&self, req: &LoginRequest) -> Result<()>;
    fn logout(&self) -> Result<()>;
    async fn on_ffi_command(&self, command: i32, params: &[u8]) -> Result<(i32, Vec<u8>)>;
    async fn on_net_command(&self, source: i32, command: i32, params: &[u8]) -> Result<()>;
    fn on_event(&self, event: Event, params: &[u8]);

    fn ffi_commands(&self) -> Vec<i32> {
        Vec::new()
    }
    fn net_commands(&self) -> Vec<i32> {
        Vec::new()
    }
}

pub fn emit_event(ev: Event, data: Vec<u8>) {
    if let Ok(hub) = BizHub::get() {
        let services = hub.get_all();
        for svc in services.iter() {
            svc.on_event(ev, &data);
        }
    }
}
