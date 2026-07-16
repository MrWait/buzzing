use anyhow::Result;
use downcast_rs::{impl_downcast, Downcast};

use crate::{AppTrait, Event, InitRequest, LoginRequest};

pub trait BizOffice: AppTrait + Downcast {}
impl_downcast!(BizOffice);

#[derive(Debug, Clone, Default)]
pub struct DefaultOffice;
#[async_trait::async_trait]
impl AppTrait for DefaultOffice {
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
        Ok((0, vec![]))
    }
    async fn on_net_command(&self, _source: i32, _command: i32, _params: &[u8]) -> Result<()> {
        Ok(())
    }
    fn on_event(&self, _event: Event, _params: &[u8]) {}
}
impl BizOffice for DefaultOffice {}
