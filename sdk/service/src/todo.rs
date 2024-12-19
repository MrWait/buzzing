use anyhow::Result;
use downcast_rs::{Downcast, impl_downcast};

use crate::{AppTrait, Event, InitRequest, LoginRequest};

pub trait BizTodo: AppTrait + Downcast {}
impl_downcast!(BizTodo);

#[derive(Debug, Clone, Default)]
pub struct DefaultTodo;
#[async_trait::async_trait]
impl AppTrait for DefaultTodo {
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
impl BizTodo for DefaultTodo {}
