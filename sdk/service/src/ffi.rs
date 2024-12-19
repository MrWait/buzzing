use anyhow::Result;
use downcast_rs::{impl_downcast, Downcast};

use crate::BizHub;
use crate::{AppTrait, Event, InitRequest, LoginRequest};

pub trait BizFfi: AppTrait {
    fn invoke(&self, param: &[u8]);
    fn ffi_push(&self, cmd: i32, data: Vec<u8>);
}

pub fn ffi_push(cmd: i32, data: Vec<u8>) -> Result<()> {
    let ffi = BizHub::get()?.ffi.clone();
    ffi.ffi_push(cmd, data);
    Ok(())
}

#[derive(Debug, Clone, Default)]
pub struct DefaultFfi;
#[async_trait::async_trait]
impl AppTrait for DefaultFfi {
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
impl BizFfi for DefaultFfi {
    fn invoke(&self, param: &[u8]) {}
    fn ffi_push(&self, cmd: i32, data: Vec<u8>) {}
}
