use anyhow::Result;
use async_trait::async_trait;
use prost::Message;
use rand::RngCore;
use std::collections::HashMap;
use std::ops::DerefMut;
use std::sync::atomic::{AtomicBool, AtomicI32, Ordering};
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::mpsc::{unbounded_channel, UnboundedSender};
use tracing::{debug, instrument};

use base_util::lock::{Mutex, RwLock};
use base_util::{gen_i32, thread_id};
use connection::WaitedPacket;
pub use http::{get, post, request};
use proto::idl::{command::Command, entity, error::ErrorCode, sdk};
use service::network::{LonglinkState, NetworkConfig, RequestOption, Response};
use service::{AppTrait, BizHub, BizNetwork, Event, InitRequest, LoginRequest};

mod connection;
mod http;

#[allow(dead_code)]
#[derive(Debug)]
pub struct NetworkState {
    longlink_state: AtomicI32,
    running: AtomicBool,
    config: RwLock<NetworkConfig>,
    foreground: AtomicBool,
}
impl NetworkState {
    pub fn new() -> Self {
        Self {
            longlink_state: AtomicI32::new(LonglinkState::Stop as i32),
            running: AtomicBool::new(false),
            config: RwLock::new(NetworkConfig::new()),
            foreground: AtomicBool::new(false),
        }
    }

    pub fn set_longlink_state(&self, state: LonglinkState) {
        self.longlink_state.store(state as i32, Ordering::SeqCst);
    }

    pub fn get_longlink_state(&self) -> LonglinkState {
        match self.longlink_state.load(Ordering::SeqCst) {
            1 => LonglinkState::Connecting,
            2 => LonglinkState::Connected,
            _ => LonglinkState::Stop,
        }
    }
}

pub const NET_HTTP_DELAY_MS: u64 = 500;

#[derive(Debug, Clone)]
pub struct AppNetwork {
    net_status: Arc<NetworkState>,
    ws_tx: Arc<Mutex<Option<UnboundedSender<connection::Command>>>>,
}
impl AppNetwork {
    pub fn new() -> Self {
        AppNetwork {
            net_status: Arc::new(NetworkState::new()),
            ws_tx: Arc::new(Mutex::new(None)),
        }
    }
    fn send_longlink_request(
        &self,
        cmd: i32,
        rid: i64,
        payload: Vec<u8>,
        tx: UnboundedSender<Response>,
    ) -> Result<()> {
        debug!("send longlink request cmd: {:?}, rid: {:?}", cmd, rid);
        let packet = entity::Packet {
            cmd,
            rid,
            payload,
            ..Default::default()
        };
        let cmd = connection::Command::AsyncRequest(WaitedPacket { packet, tx });
        let _ = self.ws_tx.lock().as_ref().and_then(|tx| Some(tx.send(cmd)));
        debug!("send longlink request ok");
        Ok(())
    }
}

#[async_trait]
impl BizNetwork for AppNetwork {
    async fn request(
        &self,
        cmd: i32,
        data: Vec<u8>,
        option: Option<RequestOption>,
    ) -> Result<Response> {
        let start = std::time::Instant::now();
        let rid = rand::thread_rng().next_u64() as i64;

        let (tx, mut rx) = unbounded_channel::<Response>();
        let option = option.unwrap_or_default();
        let timeout = option.timeout.timeout();
        let deadline = start + Duration::from_millis(timeout);

        // ws 已连接时优先走 ws；断开/连接中直接走 http，避免空等
        let ws_connected = self.get_longlink_status() == LonglinkState::Connected;
        debug!(
            "request start, cmd: {cmd}, option: {:?}, rid: {rid}, len: {}, ws_connected: {ws_connected}",
            option,
            data.len(),
        );

        let mut longlink_fired = false;
        let mut http_fired = false;
        let mut longlink_at = std::time::Instant::now();
        let mut last_longlink_at = std::time::Instant::now();

        loop {
            let now = std::time::Instant::now();
            if now >= deadline {
                debug!("request timeout, abort");
                break;
            }

            // 决定本轮动作：优先 ws -> 500ms 未回兜底 http -> 每 3s 重试 ws
            let mut sleep_ms = 0u64;
            let mut do_longlink = false;
            let mut do_http = false;

            if !ws_connected {
                if !http_fired {
                    do_http = true;
                } else {
                    sleep_ms = deadline.saturating_duration_since(now).as_millis().max(1) as u64;
                }
            } else if !longlink_fired {
                do_longlink = true;
            } else if !http_fired
                && now.duration_since(longlink_at) >= Duration::from_millis(NET_HTTP_DELAY_MS)
            {
                do_http = true;
            } else if now.duration_since(last_longlink_at) >= Duration::from_millis(3000) {
                do_longlink = true;
            } else {
                // 等待到最近的事件点（http 触发 / ws 重试 / 截止时间）
                let next = [
                    longlink_at + Duration::from_millis(NET_HTTP_DELAY_MS),
                    last_longlink_at + Duration::from_millis(3000),
                    deadline,
                ]
                .into_iter()
                .filter(|t| *t > now)
                .min()
                .unwrap_or(deadline);
                sleep_ms = next.duration_since(now).as_millis().max(1) as u64;
            }

            tokio::select!(
                resp = rx.recv() => {
                    match resp {
                        Some(resp) => {
                            debug!(
                                "request finish, cmd: {:?}, cost: {:?}, ack state: {:?}, rid: {:?}",
                                cmd, start.elapsed().as_millis(), resp.code, rid,
                            );
                            if resp.code == ErrorCode::ErrorOnProcess as i32 {
                                debug!("request was processing");
                                continue;
                            }
                            return Ok(resp);
                        }
                        None => {
                            debug!("request channel closed, rid: {rid}");
                            break;
                        }
                    }
                }
                _ = tokio::time::sleep(Duration::from_millis(sleep_ms)) => {
                    if do_http {
                        debug!("start send request with http, rid: {:?}", rid);
                        let tx2 = tx.clone();
                        let option_clone = option.clone();
                        let data_clone = data.clone();
                        let _ = base_runtime::spawn(async move {
                            let ret = http::request(cmd, rid, data_clone, Some(option_clone)).await;
                            debug!("request with http finish: {:?}", rid);
                            match ret {
                                Ok(resp) => {
                                    let _ = tx2.send(resp);
                                }
                                Err(err) => {
                                    debug!("request http error: {:?}", err);
                                    let _ = tx2.send(Response::default());
                                }
                            }
                        });
                        http_fired = true;
                    }
                    if do_longlink {
                        debug!("request send with longlink");
                        let _ = self.send_longlink_request(cmd, rid, data.clone(), tx.clone());
                        if !longlink_fired {
                            longlink_at = std::time::Instant::now();
                            longlink_fired = true;
                        }
                        last_longlink_at = std::time::Instant::now();
                    }
                }
            );
        }

        debug!(
            "request finish, cmd: {:?}, cost: {:?}, rid: {:?}",
            cmd,
            start.elapsed().as_millis(),
            rid,
        );
        Err(anyhow::anyhow!("request error"))
    }
    async fn get(
        &self,
        _path: &str,
        _headers: HashMap<String, String>,
        _query: HashMap<String, String>,
    ) -> Result<String> {
        Ok("".to_string())
    }
    async fn post(
        &self,
        _path: &str,
        _headers: HashMap<String, String>,
        _body: String,
    ) -> Result<String> {
        Ok("".to_string())
    }
    fn get_longlink_status(&self) -> LonglinkState {
        self.net_status.get_longlink_state()
    }
    fn start(&self) {}
    fn stop(&self) {}
    fn set_network_config(&self, new: NetworkConfig) {
        *self.net_status.config.write() = new;
    }
    fn api(&self) -> String {
        let config = self.net_status.config.read();
        config.api()
    }
    fn ws(&self) -> String {
        let config = self.net_status.config.read();
        config.ws()
    }
}

#[async_trait]
impl AppTrait for AppNetwork {
    fn init(&self, _req: &InitRequest) -> Result<()> {
        let _ = http::init_global_client();
        Ok(())
    }
    fn uninit(&self) -> Result<()> {
        Ok(())
    }

    fn login(&self, req: &LoginRequest) -> Result<()> {
        self.net_status.foreground.store(true, Ordering::SeqCst);
        {
            let mut config = self.net_status.config.write();
            (*config).client_config = req.client_config.clone();
        }
        let _ = http::init_user_client(&req.client_config);
        if !self.net_status.running.load(Ordering::SeqCst) {
            self.net_status.running.store(true, Ordering::Relaxed);
            let (tx, rx) = unbounded_channel::<connection::Command>();
            let cmd_tx = Arc::new(tx.clone());
            self.ws_tx.lock().replace(tx);
            let net_status = self.net_status.clone();
            base_runtime::spawn(async {
                let _ = connection::ws_task(cmd_tx, rx, net_status).await;
            });
        }
        self.start();
        Ok(())
    }
    fn logout(&self) -> Result<()> {
        let _ = http::uninit_user_client();
        // 复位长连接状态：登出时 ws_task 已被 base_runtime::stop 取消，
        // 但 running 标志必须置回 false，否则再次登录时不会重新启动 ws_task
        self.net_status.running.store(false, Ordering::SeqCst);
        self.net_status.foreground.store(false, Ordering::SeqCst);
        self.net_status.set_longlink_state(LonglinkState::Stop);
        self.ws_tx.lock().take();
        Ok(())
    }

    fn ffi_commands(&self) -> Vec<i32> {
        vec![Command::NetRequest as i32]
    }

    async fn on_ffi_command(&self, command: i32, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let cmd = Command::try_from(command)?;
        let ret = match cmd {
            Command::NetRequest => {
                let req = sdk::NetRequest::decode(params)?;
                let res = self.request(req.cmd, req.body, None).await?;
                Ok((res.code, res.data))
            }
            _ => Err(anyhow::anyhow!("not handled")),
        };
        ret
    }
    async fn on_net_command(&self, _source: i32, _command: i32, _params: &[u8]) -> Result<()> {
        Err(anyhow::anyhow!("not handled"))
    }
    fn on_event(&self, _event: Event, _params: &[u8]) {}
}

#[instrument(skip_all, fields(sid=gen_i32(), tid=thread_id()))]
pub fn dispatch_net_packet(source: i32, cmd: i32, body: Vec<u8>) -> Result<()> {
    base_runtime::spawn(async move {
        if let Ok(hub) = BizHub::get() {
            let _ = hub.invoke_net_command(source, cmd, &body).await;
        }
    });
    Ok(())
}
