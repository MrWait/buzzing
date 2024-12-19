use anyhow::Result;
use async_trait::async_trait;
use std::sync::Arc;

use crate::Setting;
use crate::{AppTrait, Event, InitRequest, LoginRequest};

#[async_trait]
pub trait BizCommon: AppTrait {
    fn global_config_set(&self, key: &str, value: &str) -> Result<()>;
    fn global_config_get(&self, key: &str) -> Result<String>;
    fn config_set(&self, key: &str, value: &str) -> Result<()>;
    fn config_get(&self, key: &str) -> Result<Setting>;

    fn task_add(&self, task: Task);
    fn reg_task_handler(&self, cmd: i32, h: Arc<Box<dyn TaskHandler>>);

    async fn run_task(&self);
}

#[async_trait]
pub trait TaskHandler {
    async fn run(&self, task: Task) -> Result<()>;
}

#[derive(Default)]
pub struct Task {
    pub cmd: i32,
    pub data: Vec<u8>,
    pub flag: i32,
    pub create: i64,
}

#[derive(Debug, Clone, Default)]
pub struct DefaultCommon;
#[async_trait::async_trait]
impl AppTrait for DefaultCommon {
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

#[async_trait]
impl BizCommon for DefaultCommon {
    fn global_config_set(&self, key: &str, value: &str) -> Result<()> {
        Ok(())
    }
    fn global_config_get(&self, key: &str) -> Result<String> {
        Ok("".to_owned())
    }
    fn config_set(&self, key: &str, value: &str) -> Result<()> {
        Ok(())
    }
    fn config_get(&self, key: &str) -> Result<Setting> {
        Ok(Setting::default())
    }

    fn task_add(&self, task: Task) {}
    fn reg_task_handler(&self, cmd: i32, h: Arc<Box<dyn TaskHandler>>) {}

    async fn run_task(&self) {}
}
