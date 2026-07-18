use anyhow::Result;
use downcast_rs::{Downcast, impl_downcast};

use crate::{AppTrait, Event, InitRequest, LoginRequest};

pub trait BizMeeting: AppTrait + Downcast {}
impl_downcast!(BizMeeting);

#[derive(Debug, Clone, Default)]
pub struct DefaultMeeting;
#[async_trait::async_trait]
impl AppTrait for DefaultMeeting {
    fn init(&self, _req: &InitRequest) -> Result<()> { Ok(()) }
    fn uninit(&self) -> Result<()> { Ok(()) }
    fn login(&self, _req: &LoginRequest) -> Result<()> { Ok(()) }
    fn logout(&self) -> Result<()> { Ok(()) }
    async fn on_ffi_command(&self, _command: i32, _params: &[u8]) -> Result<(i32, Vec<u8>)> {
        Ok((0, vec![]))
    }
    async fn on_net_command(&self, _source: i32, _command: i32, _params: &[u8]) -> Result<()> {
        Ok(())
    }
    fn on_event(&self, _event: Event, _params: &[u8]) {}
}
impl BizMeeting for DefaultMeeting {}
