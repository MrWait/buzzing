use anyhow::Result;
use downcast_rs::{impl_downcast, Downcast};

use crate::{AppTrait, Event, InitRequest, LoginRequest};
use proto::{idl::entity::Entity, EntityIds};

#[derive(Debug, Clone, Default)]
pub struct DeviceInfo {
    pub device_type: i32,
    pub app_version: String,
    pub app_id: String,
    pub device_id: String,
    pub log_path: String,
    pub storage_path: std::path::PathBuf,
}

#[derive(Debug, Clone, Default)]
pub struct UserInfo {
    pub user_id: i64,
    pub token: String,
    pub tenant_id: i64,
    pub seq: i64,
    pub country: String,
    pub storage_path: std::path::PathBuf,
    pub db_key: String,
}

pub trait BizAccount: AppTrait + Downcast {
    fn set_device_info(&self, device: &DeviceInfo);
    fn get_device_info(&self) -> DeviceInfo;
    fn set_user_info(&self, user: &UserInfo);
    fn get_user_info(&self) -> UserInfo;
    fn fill_entity(
        &self,
        entity_ids: &mut EntityIds,
        entity: &mut Entity,
        sync: bool,
    ) -> Result<()>;
}
impl_downcast!(BizAccount);

pub fn fill_entity(entity_ids: &mut EntityIds, entity: &mut Entity, sync: bool) -> Result<()> {
    let app = crate::BizHub::get()?;
    app.account.fill_entity(entity_ids, entity, sync)
}

#[derive(Debug, Clone, Default)]
pub struct DefaultAccount;
#[async_trait::async_trait]
impl AppTrait for DefaultAccount {
    fn init(&self, req: &InitRequest) -> Result<()> {
        Ok(())
    }
    fn uninit(&self) -> Result<()> {
        Ok(())
    }
    fn login(&self, req: &LoginRequest) -> Result<()> {
        Ok(())
    }
    fn logout(&self) -> Result<()> {
        Ok(())
    }
    async fn on_ffi_command(&self, command: i32, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        Ok((0, vec![]))
    }
    async fn on_net_command(&self, source: i32, command: i32, params: &[u8]) -> Result<()> {
        Ok(())
    }
    fn on_event(&self, event: Event, params: &[u8]) {}
}
impl BizAccount for DefaultAccount {
    fn set_device_info(&self, device: &DeviceInfo) {}
    fn get_device_info(&self) -> DeviceInfo {
        Default::default()
    }
    fn set_user_info(&self, user: &UserInfo) {}
    fn get_user_info(&self) -> UserInfo {
        Default::default()
    }
    fn fill_entity(
        &self,
        entity_ids: &mut EntityIds,
        entity: &mut Entity,
        sync: bool,
    ) -> Result<()> {
        Ok(())
    }
}
