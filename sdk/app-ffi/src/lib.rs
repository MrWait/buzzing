use anyhow::Result;
use async_trait::async_trait;

use service::{ffi::BizFfi, AppTrait, Event, InitRequest, LoginRequest};

#[derive(Debug, Clone)]
pub struct AppFfi {
    push_fn: fn(i32, Vec<u8>),
}

impl AppFfi {
    pub fn new(f: fn(i32, Vec<u8>)) -> Self {
        Self { push_fn: f }
    }
}

#[async_trait]
impl AppTrait for AppFfi {
    fn init(&self, _req: &InitRequest) -> Result<()> {
        Ok(())
    }
    fn uninit(&self) -> Result<()> {
        Ok(())
    }

    fn login(&self, _req: &LoginRequest) -> Result<()> {
        Ok(())
    }
    fn logout(&self) -> Result<()> {
        Ok(())
    }
    async fn on_ffi_command(&self, _command: i32, _params: &[u8]) -> Result<(i32, Vec<u8>)> {
        Err(anyhow::anyhow!("not handled"))
    }
    async fn on_net_command(&self, _source: i32, _command: i32, _params: &[u8]) -> Result<()> {
        Err(anyhow::anyhow!("not handled"))
    }
    fn on_event(&self, _event: Event, _params: &[u8]) {}
}

impl BizFfi for AppFfi {
    fn invoke(&self, _param: &[u8]) {}
    fn ffi_push(&self, cmd: i32, data: Vec<u8>) {
        (self.push_fn)(cmd, data);
    }
}
