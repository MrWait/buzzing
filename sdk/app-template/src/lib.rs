use anyhow::Result;
use async_trait::async_trait;
use lazy_static::lazy_static;
use prost::Message;
use std::sync::{Arc, RwLock};

use service::template::{ServiceTemplate};
use service::{InitRequest, LoginRequest, Service};
use proto::idl::sdk;

pub struct AppTemplate{}
impl AppTemplate {
    pub fn new() -> Self {
        AppTemplate {}
    }
}

#[async_trait]
impl Service for AppTemplate {
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
    async fn handle_ffi_command(&self, command: i32, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        Err(anyhow::anyhow!("not handled"))
    }
    async fn handle_net_command(&self, source: i32, command: i32, params: &[u8]) -> Result<()> {
        Err(anyhow::anyhow!("not handled"))
    }
    fn handle_event(&self, event: i32, params: &[u8]) {}
}

impl ServiceTemplate for AppTemplate {
}
