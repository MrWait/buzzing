use anyhow::Result;
use async_trait::async_trait;
use prost::Message;
use rand::RngCore;
use std::collections::HashMap;
use std::ops::DerefMut;
use std::sync::atomic::{AtomicBool, Ordering};
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
    longlink_state: LonglinkState,
    running: AtomicBool,
    config: RwLock<NetworkConfig>,
    foreground: AtomicBool,
}
impl NetworkState {
    pub fn new() -> Self {
        Self {
            longlink_state: LonglinkState::Stop,
            running: AtomicBool::new(false),
            config: RwLock::new(NetworkConfig::new()),
            foreground: AtomicBool::new(false),
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
        struct Timeout {
            gap: u64,
            timeout: u64,
            step: u64,
            i: usize,
        }
        impl Iterator for Timeout {
            // timeout, longlink, http
            type Item = (u64, bool, bool);
            fn next(&mut self) -> Option<Self::Item> {
                self.i = self.i + 1;
                match self.i {
                    1 => Some((0, true, false)),
                    2 => Some((self.gap, false, true)),
                    0 => Some((0, false, false)),
                    _ => {
                        if ((self.i as u64) * self.step) < self.timeout {
                            Some((self.step, true, false))
                        } else {
                            None
                        }
                    }
                }
            }
        }

        let now = std::time::Instant::now();
        let rid = rand::thread_rng().next_u64() as i64;

        let (tx, mut rx) = unbounded_channel::<Response>();
        let waiting = AtomicBool::new(true);
        let option = option.unwrap_or_default();
        let mut timeout = Timeout {
            gap: NET_HTTP_DELAY_MS,
            timeout: option.timeout.timeout(),
            step: 3000,
            i: 0,
        };

        debug!(
            "request start, cmd: {cmd}, option: {:?}, rid: {rid}, len: {}",
            option,
            data.len(),
        );

        while waiting.load(Ordering::Relaxed) {
            let (time, longlink, http) = match timeout.next() {
                None => {
                    debug!("request timeout, abort");
                    break;
                }
                Some(c) => c,
            };
            debug!("next request loop, {time}, {longlink}, {http}");

            let tx1 = tx.clone();
            let tx2 = tx.clone();
            let mut resp: Option<Response> = None;
            let option_clone = option.clone();
            let data_clone = data.clone();
            tokio::select!(
                _ = async {
                    resp = rx.recv().await;
                    debug!("recv request resp");
                } => {
                    let resp = resp.unwrap_or_default();
                    debug!(
                        "request finish, cmd: {:?}, cost: {:?}, ack state: {:?}, rid: {:?}",
                        cmd, now.elapsed().as_millis(), resp.code, rid,
                    );
                    if resp.code == ErrorCode::ErrorOnProcess as i32{
                        debug!("request was processing");
                        continue;
                    }
                    waiting.store(false, Ordering::Relaxed);
                    return Ok(resp);
                }
                _ = async move {
                    tokio::time::sleep(Duration::from_millis(time)).await;
                    if http {
                        let data_clone_2 = data_clone.clone();
                        base_runtime::spawn(async move {
                            debug!("start send request with http, rid: {:?}", rid);
                            let ret = http::request(cmd, rid, data_clone_2, Some(option_clone)).await;
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
                    }
                    if longlink {
                        debug!("request send with longlink");
                        let _ = self.send_longlink_request(cmd, rid, data_clone, tx1);
                    }
                } => {}
            );
        }

        debug!(
            "request finish, cmd: {:?}, cost: {:?}, rid: {:?}",
            cmd,
            now.elapsed().as_millis(),
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
        LonglinkState::Stop
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
            base_runtime::spawn(async {
                let _ = connection::ws_task(cmd_tx, rx).await;
            });
        }
        self.start();
        Ok(())
    }
    fn logout(&self) -> Result<()> {
        let _ = http::uninit_user_client();
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
