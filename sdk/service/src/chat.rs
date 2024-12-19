use anyhow::Result;
use downcast_rs::{impl_downcast, Downcast};

use crate::{AppTrait, Event, InitRequest, LoginRequest};

pub trait BizChat: AppTrait + Downcast {}
impl_downcast!(BizChat);

#[derive(Debug, Clone, Default)]
pub struct DefaultChat;
#[async_trait::async_trait]
impl AppTrait for DefaultChat {
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
impl BizChat for DefaultChat {}
