use anyhow::Result;
use futures_util::{SinkExt, StreamExt};
use prost::Message as _;
use std::collections::HashMap;
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::mpsc::{UnboundedReceiver, UnboundedSender};
use tokio_tungstenite::connect_async_tls_with_config;
use tokio_tungstenite::tungstenite::client::IntoClientRequest;
use tokio_tungstenite::Connector;
use tracing::{debug, instrument, warn};
use tungstenite::protocol::Message;

use base_util::{gen_i32, lock::RwLock, thread_id, time::current_s};
use proto::idl::entity;
use service::{emit_event, network::Response, BizHub};

#[derive(Debug)]
pub struct WaitedPacket {
    pub packet: entity::Packet,
    pub tx: UnboundedSender<Response>,
}

#[allow(dead_code)]
#[derive(Debug)]
pub enum Command {
    Request(entity::Packet),
    AsyncRequest(WaitedPacket),
    Heartbeat,
    HeartbeatAck,
    PipeSyncState(bool),
    PipePacket(Vec<entity::Packet>),
}

const RECONNECT_INTERVAL: [u64; 7] = [0, 1000, 1500, 2000, 3000, 5000, 8000];
const HEART_BEAT_INTERVAL: u64 = 30;

fn insecure_connector() -> Connector {
    use rustls::ClientConfig;
    let provider = rustls::crypto::ring::default_provider();
    let config = ClientConfig::builder_with_provider(Arc::new(provider.clone()))
        .with_protocol_versions(&[&rustls::version::TLS13])
        .expect("valid protocol version")
        .dangerous()
        .with_custom_certificate_verifier(Arc::new(AcceptAllVerifier {
            supported_algs: provider.signature_verification_algorithms,
        }))
        .with_no_client_auth();
    Connector::Rustls(Arc::new(config))
}

#[derive(Debug)]
struct AcceptAllVerifier {
    supported_algs: rustls::crypto::WebPkiSupportedAlgorithms,
}

impl rustls::client::danger::ServerCertVerifier for AcceptAllVerifier {
    fn verify_server_cert(
        &self,
        _end_entity: &rustls::pki_types::CertificateDer<'_>,
        _intermediates: &[rustls::pki_types::CertificateDer<'_>],
        _server_name: &rustls::pki_types::ServerName<'_>,
        _ocsp_response: &[u8],
        _now: rustls::pki_types::UnixTime,
    ) -> Result<rustls::client::danger::ServerCertVerified, rustls::Error> {
        Ok(rustls::client::danger::ServerCertVerified::assertion())
    }

    fn verify_tls12_signature(
        &self,
        message: &[u8],
        cert: &rustls::pki_types::CertificateDer<'_>,
        dss: &rustls::DigitallySignedStruct,
    ) -> Result<rustls::client::danger::HandshakeSignatureValid, rustls::Error> {
        rustls::crypto::verify_tls12_signature(message, cert, dss, &self.supported_algs)
    }

    fn verify_tls13_signature(
        &self,
        message: &[u8],
        cert: &rustls::pki_types::CertificateDer<'_>,
        dss: &rustls::DigitallySignedStruct,
    ) -> Result<rustls::client::danger::HandshakeSignatureValid, rustls::Error> {
        rustls::crypto::verify_tls13_signature(message, cert, dss, &self.supported_algs)
    }

    fn supported_verify_schemes(&self) -> Vec<rustls::SignatureScheme> {
        self.supported_algs
            .mapping
            .iter()
            .map(|(scheme, _)| *scheme)
            .collect()
    }
}

#[instrument(skip_all, fields(sid=gen_i32(), tid=thread_id()))]
pub(crate) async fn ws_task(
    cmd_tx: Arc<UnboundedSender<Command>>,
    mut rx: UnboundedReceiver<Command>,
) -> Result<()> {
    let waited: RwLock<HashMap<i64, UnboundedSender<Response>>> = RwLock::new(HashMap::new());

    let (user_info, device_info) = {
        let svc = BizHub::get()?.account.clone();
        (svc.get_user_info(), svc.get_device_info())
    };
    let ws_host = BizHub::get()?.network.ws();
    debug!("start ws task, host: {ws_host}");
    loop {
        let mut retry_count = 0;
        let mut ws_stream = None;
        loop {
            retry_count += 1;
            if retry_count > 6 {
                retry_count = 0;
            }
            tokio::select!(
                _ = async {
                    debug!("start connect server, retry_count: {} {:?} {:?}", retry_count, user_info, device_info);
                    tokio::time::sleep(Duration::from_millis(RECONNECT_INTERVAL[retry_count])).await;
                    let mut request = ws_host.clone().into_client_request().unwrap();
                    request
                        .headers_mut()
                        .insert("x-buzzing-token", user_info.token.parse().unwrap());
                    request.headers_mut().insert(
                        "x-buzzing-appversion",
                        device_info.app_version.parse().unwrap(),
                    );
                    request
                        .headers_mut()
                        .insert("x-buzzing-deviceid", device_info.device_id.parse().unwrap());

                    match connect_async_tls_with_config(request, None, false, Some(insecure_connector())).await {
                        Ok(result) => {
                            debug!("connect response: {:?}", result.1);
                            ws_stream = Some(result.0);
                        }
                        Err(e) => {
                            warn!("connect error: {e:?}");
                        }
                    }
                } => {}
                _ = async {
                    tokio::time::sleep(Duration::from_secs(10)).await;
                    debug!("connect timeout");
                } => {}
            );

            if ws_stream.is_some() {
                break;
            }
        }

        debug!("start process loop");

        let (mut sink, mut stream) = match ws_stream {
            Some(ws) => ws.split(),
            _ => continue,
        };

        emit_event(service::Event::EventLogin, vec![]);

        let running = AtomicBool::new(true);

        if !running.load(Ordering::SeqCst) {
            break;
        }
        let last_send_heartbeat = AtomicU64::new(current_s());
        let last_resp_heartbeat = AtomicU64::new(0);
        while running.load(Ordering::SeqCst) {
            tokio::select!(
                _ = async {
                    tokio::time::sleep(Duration::from_secs(5)).await;
                    // debug!("ws tick");
                    let last = last_send_heartbeat.load(Ordering::SeqCst);
                    let resp = last_resp_heartbeat.load(Ordering::SeqCst);
                    let next = last + HEART_BEAT_INTERVAL;
                    let now = current_s();
                    if now % 5 == 0 {
                        debug!("check heartbeat, last: {}, resp: {}, next: {}, now: {}", last, resp, next, now);
                    }
                    if now > next {
                        if let Err(err) = cmd_tx.send(Command::Heartbeat) {
                            warn!("send command error: {:?}", err);
                        }
                    }

                    // check client heartbeat
                    if resp == 0 && (now > last + 3) {
                        warn!("recv server heartbeat timeout, reconnect");
                        // running.store(false, Ordering::Relaxed);
                    }

                }=> {},
                _ = async {
                    let message = stream.next().await;
                    // debug!("recv message: {:?}", message);
                    match message {
                        Some(Ok(Message::Binary(data))) => {
                            if let Ok(packet) = entity::Packet::decode(data.as_slice()) {
                                debug!("recv packet, rid: {}, cmd: {}, code: {}, len: {:?}", packet.rid, packet.cmd, packet.code, packet.payload.len());
                                let rid = packet.rid;
                                let tx = {
                                    let mut wait = waited.write();
                                    wait.remove(&rid)
                                };
                                if let Some(tx) = tx {
                                    let _ = tx.send(Response {
                                        rid: packet.rid,
                                        data: packet.payload,
                                        code: packet.code,
                                    });
                                } else {
                                    let _ = crate::dispatch_net_packet(1, packet.cmd, packet.payload);
                                }
                            }
                        }
                        Some(Ok(Message::Ping(_))) => {
                            let _ = cmd_tx.send(Command::HeartbeatAck);
                        }
                        Some(Ok(Message::Pong(_))) => {
                            // debug!("recv server heartbeat");
                            last_resp_heartbeat.store(current_s(), Ordering::SeqCst);
                        }
                        Some(Ok(_)) => {
                            warn!("recv unsupport type message");
                        }
                        _ => {
                            warn!("recv error, reconnect");
                            running.store(false, Ordering::SeqCst);
                        }
                    }

                }=> {},
                _ = async {
                    let command = rx.recv().await;
                    // debug!("waited command");
                    if let Some(cmd) = command {
                        match cmd {
                            Command::Request(packet) => {
                                if let Err(err) = sink.send(Message::Binary(packet.encode_to_vec())).await {
                                    debug!("send packet error: {:?}", err);
                                }
                            }
                            Command::AsyncRequest(WaitedPacket{packet, tx}) => {
                                match sink.send(Message::Binary(packet.encode_to_vec())).await {
                                    Ok(_) => {
                                        let mut   wait = waited.write();
                                        wait.insert(packet.rid, tx);
                                    }
                                    Err(err) => {
                                        warn!("send packet error, stop, err: {:?}", err);
                                        running.store(false, Ordering::SeqCst);
                                    }
                                }

                            }
                            Command::Heartbeat => {
                                let _ = sink.send(Message::Ping(vec![])).await;
                            }
                            Command::HeartbeatAck => {
                                let _ = sink.send(Message::Pong(vec![])).await;
                            }
                            Command::PipeSyncState(_sync) => {}
                            Command::PipePacket(_packets)=> {}
                        }
                    }
                } => {}
            );
        }
    }
    Ok(())
}
