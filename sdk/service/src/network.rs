use anyhow::Result;
use async_trait::async_trait;
use downcast_rs::{impl_downcast, Downcast};
use std::collections::HashMap;

use crate::{AppTrait, Event, InitRequest, LoginRequest};
use crate::{BizHub, UnionClientConfig};

#[derive(Debug, Copy, Clone)]
pub enum NetRetryCount {
    Count0,
    Count1,
    Count3,
    CountInfinity,
}
impl NetRetryCount {
    pub fn retry(&self) -> usize {
        match self {
            Self::Count0 => 0,
            Self::Count1 => 1,
            Self::Count3 => 3,
            Self::CountInfinity => 100,
        }
    }
}

#[derive(Debug, Copy, Clone)]
pub enum NetTimeout {
    Timeout1,
    Timeout5,
    Timeout15,
}
impl NetTimeout {
    pub fn timeout(&self) -> u64 {
        match self {
            NetTimeout::Timeout1 => 1000,
            NetTimeout::Timeout5 => 5000,
            NetTimeout::Timeout15 => 15000,
        }
    }
}

#[derive(Debug, Copy, Clone)]
pub struct RequestOption {
    pub retry: NetRetryCount,
    pub timeout: NetTimeout,
}
impl Default for RequestOption {
    fn default() -> Self {
        Self {
            retry: NetRetryCount::Count0,
            timeout: NetTimeout::Timeout5,
        }
    }
}

#[derive(Default)]
pub struct Request {
    pub cmd: i32,
    pub data: Vec<u8>,
    pub option: RequestOption,
}

#[derive(Default)]
pub struct Response {
    pub rid: i64,
    pub code: i32,
    pub data: Vec<u8>,
}

impl Response {
    pub fn new() -> Self {
        Self {
            rid: 0,
            code: 0,
            data: vec![],
        }
    }

    pub fn is_success(&self) -> bool {
        self.code == 200
    }
}

#[derive(Eq, PartialEq, Clone, Copy, Debug)]
pub enum LonglinkState {
    Stop,
    Connecting,
    Connected,
}

#[derive(Debug)]
pub struct NetworkConfig {
    pub client_config: UnionClientConfig,
}
impl NetworkConfig {
    pub fn new() -> Self {
        Self {
            client_config: UnionClientConfig::default(),
        }
    }
    pub fn api(&self) -> String {
        format!(
            "{}:{}{}",
            self.client_config.gateway,
            self.client_config.gateway_port,
            self.client_config.api_gateway
        )
    }

    pub fn ws(&self) -> String {
        format!("{}:{}", self.client_config.ws, self.client_config.ws_port)
    }
}

#[async_trait]
pub trait BizNetwork: AppTrait {
    async fn request(
        &self,
        command: i32,
        req: Vec<u8>,
        option: Option<RequestOption>,
    ) -> Result<Response>;
    async fn get(
        &self,
        path: &str,
        headers: HashMap<String, String>,
        query: HashMap<String, String>,
    ) -> Result<String>;
    async fn post(
        &self,
        path: &str,
        headers: HashMap<String, String>,
        body: String,
    ) -> Result<String>;
    fn get_longlink_status(&self) -> LonglinkState;
    fn start(&self);
    fn stop(&self);
    fn set_network_config(&self, config: NetworkConfig);
    fn api(&self) -> String;
    fn ws(&self) -> String;
}

pub async fn request(
    command: i32,
    data: Vec<u8>,
    option: Option<RequestOption>,
) -> Result<Response> {
    BizHub::get()?.network.request(command, data, option).await
}

pub async fn common_request<T>(
    command: i32,
    data: Vec<u8>,
    option: Option<RequestOption>,
) -> Result<T>
where
    T: prost::Message + Default,
{
    let resp = request(command, data, option).await?;
    T::decode(resp.data.as_slice()).map_err(|_| anyhow::anyhow!("parse error"))
}

#[derive(Debug, Clone, Default)]
pub struct DefaultNetwork;
#[async_trait::async_trait]
impl AppTrait for DefaultNetwork {
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
impl BizNetwork for DefaultNetwork {
    async fn request(
        &self,
        command: i32,
        req: Vec<u8>,
        option: Option<RequestOption>,
    ) -> Result<Response> {
        Ok(Response::default())
    }
    async fn get(
        &self,
        path: &str,
        headers: HashMap<String, String>,
        query: HashMap<String, String>,
    ) -> Result<String> {
        Ok(String::default())
    }
    async fn post(
        &self,
        path: &str,
        headers: HashMap<String, String>,
        body: String,
    ) -> Result<String> {
        Ok(String::default())
    }
    fn get_longlink_status(&self) -> LonglinkState {
        LonglinkState::Connected
    }
    fn start(&self) {}
    fn stop(&self) {}
    fn set_network_config(&self, config: NetworkConfig) {}
    fn api(&self) -> String {
        String::default()
    }
    fn ws(&self) -> String {
        String::default()
    }
}
