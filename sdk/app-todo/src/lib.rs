use anyhow::Result;
use async_trait::async_trait;

use service::{AppTrait, BizTodo, Event, InitRequest, LoginRequest};

#[derive(Debug, Clone)]
pub struct AppTodo {}
impl AppTodo {
    pub fn new() -> Self {
        AppTodo {}
    }
}

#[async_trait]
impl AppTrait for AppTodo {
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
        Err(anyhow::anyhow!("not handled"))
    }
    async fn on_net_command(&self, source: i32, command: i32, params: &[u8]) -> Result<()> {
        Err(anyhow::anyhow!("not handled"))
    }
    fn on_event(&self, event: Event, params: &[u8]) {}
}

impl BizTodo for AppTodo {}
