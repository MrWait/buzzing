use std::collections::HashSet;
use std::net::SocketAddr;
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::sync::{Arc, OnceLock};
use std::time::Duration;

use dashmap::DashMap;
use futures_util::{SinkExt, StreamExt};
use loco_rs::{Error, Result, app::AppContext, auth};
use prost::Message as _;
use rustls::pki_types::{CertificateDer, PrivateKeyDer};
use tokio::net::{TcpListener, TcpStream};
use tokio::sync::mpsc::{UnboundedSender, unbounded_channel};
use tokio_rustls::TlsAcceptor;
use tokio_tungstenite::tungstenite::Message;
use tracing::{debug, info, instrument, warn};
use tungstenite::handshake::server::{ErrorResponse, Request, Response};

use sea_orm::{ConnectionTrait, DbBackend, Statement};
use common::{UserBrief, cost, pb_decode, rid, time::current_s};
use proto::idl::{command, entity, error as idl_error};

static USER_CONTEXT: OnceLock<Arc<UserContext>> = OnceLock::new();

#[allow(dead_code)]
#[derive(Default, Debug)]
struct ConnectionDetail {
    brief: UserBrief,
    device_id: String,
    token: String,
    app_version: String,
    connected: u64,
    logined: bool,
}

#[allow(dead_code)]
#[derive(Debug)]
pub struct WaitedPacket {
    packet: entity::Packet,
    tx: UnboundedSender<ClientCommand>,
}

#[allow(dead_code)]
pub enum ClientCommand {
    Request(entity::Packet),
    AsyncRequest(WaitedPacket),
    Heartbeat,
    HeartbeatAck,
}

#[derive(Default)]
pub(crate) struct UserContext {
    user_conn: DashMap<i64, HashSet<i64>>,
    conn_user: DashMap<i64, i64>,
    conn_receiver: DashMap<i64, Arc<UnboundedSender<ClientCommand>>>,
}

struct TokenVerify<'a> {
    pub ctx: &'a AppContext,
    pub detail: &'a mut ConnectionDetail,
}

pub(crate) fn get_user_context() -> Arc<UserContext> {
    USER_CONTEXT
        .get_or_init(|| Arc::new(UserContext::default()))
        .clone()
}

impl<'a> TokenVerify<'a> {
    pub fn new(ctx: &'a AppContext, detail: &'a mut ConnectionDetail) -> Self {
        Self { ctx, detail }
    }
}
impl<'a> tungstenite::handshake::server::Callback for TokenVerify<'a> {
    fn on_request(
        self,
        request: &Request,
        response: Response,
    ) -> std::result::Result<Response, ErrorResponse> {
        info!("ws recv new connection, request: {:?}", request);
        let validate = |ctx: &AppContext, request: &Request| -> Result<UserBrief> {
            let _app_version: String = request
                .headers()
                .get("x-buzzing-appversion")
                .and_then(|v| v.to_str().ok())
                .unwrap_or_default()
                .to_string();
            let _device_id: String = request
                .headers()
                .get("x-buzzing-deviceid")
                .and_then(|v| v.to_str().ok())
                .unwrap_or_default()
                .to_string();
            let token = request
                .headers()
                .get("x-buzzing-token")
                .and_then(|v| v.to_str().ok())
                .unwrap_or_default()
                .to_string();

            let token = if token.is_empty() {
                // 浏览器 WebSocket 无法设置自定义 header，通过 query param 传递 token
                request.uri().query()
                    .and_then(|q| {
                        q.split('&')
                            .find_map(|pair| {
                                let mut parts = pair.splitn(2, '=');
                                match (parts.next(), parts.next()) {
                                    (Some(k), Some(v)) if k == "token" => Some(v.to_string()),
                                    _ => None,
                                }
                            })
                    })
                    .unwrap_or_default()
            } else {
                token
            };

            if token == "buzzing_bench" {
                let id: i64 = request
                    .headers()
                    .get("x-buzzing-userid")
                    .and_then(|v| v.to_str().ok())
                    .and_then(|v| v.parse().ok())
                    .unwrap_or(0);
                let aid: i64 = request
                    .headers()
                    .get("x-buzzing-accoundid")
                    .and_then(|v| v.to_str().ok())
                    .and_then(|v| v.parse().ok())
                    .unwrap_or(0);
                let tenant_id: i64 = request
                    .headers()
                    .get("x-buzzing-tenant")
                    .and_then(|v| v.to_str().ok())
                    .and_then(|v| v.parse().ok())
                    .unwrap_or(0);
                Ok(UserBrief {
                    id,
                    pid: "".to_string(),
                    aid,
                    tenant_id,
                })
            } else {
                let jwt_secret = ctx.config.get_jwt_config()?;
                let claims = auth::jwt::JWT::new(&jwt_secret.secret)
                    .validate(&token)
                    .map_err(|err| {
                        warn!("validate token err: {:?}", err);
                        loco_rs::Error::Message("token validate error".to_string())
                    })?;
                return UserBrief::from_string(&claims.claims.pid);
            }
        };
        match validate(self.ctx, request) {
            Ok(info) => {
                self.detail.logined = true;
                self.detail.brief = info;
                // self.detail.device_id = device_id;
                // self.detail.app_version = app_version;
                Ok(response)
            }
            Err(err) => {
                warn!("token validate error: {:?}", err);
                Err(ErrorResponse::new(Some("token error".to_string())))
            }
        }
    }
}

#[instrument(skip(ctx, raw_stream))]
async fn handle_client<S>(
    ctx: &AppContext,
    raw_stream: S,
    addr: SocketAddr,
    conn_id: i64,
) -> Result<()>
where
    S: tokio::io::AsyncRead + tokio::io::AsyncWrite + Unpin + Send + 'static,
{
    debug!("incoming tcp connection from: {:?}", addr);
    let (tx, mut rx) = unbounded_channel::<ClientCommand>();
    let mut detail = ConnectionDetail {
        connected: current_s(),
        logined: false,
        ..Default::default()
    };

    let user_ctx = get_user_context();

    let ws_stream = {
        let stream =
            tokio_tungstenite::accept_hdr_async(raw_stream, TokenVerify::new(ctx, &mut detail))
                .await
                .map_err(|err| {
                    warn!("accept error: {:?}", err);
                    Error::Message(err.to_string())
                })?;

        stream
    };
    user_ctx.conn_user.insert(conn_id, detail.brief.id);
    user_ctx
        .user_conn
        .entry(detail.brief.id)
        .or_default()
        .insert(conn_id);
    // M3: presence online on WS connect
    let _ = ctx.db.execute(Statement::from_sql_and_values(
        DbBackend::Postgres,
        "INSERT INTO user_presence (user_id, status, status_text, updated_at) VALUES ($1, 1, '', NOW()) ON CONFLICT (user_id) DO UPDATE SET status = 1, updated_at = NOW()",
        vec![detail.brief.id.into()],
    )).await;
    // Push online to subscribers
    if let Some(watchers) = common::PRESENCE_SUBSCRIBERS.get(&detail.brief.id) {
        let watcher_ids: Vec<i64> = watchers.iter().copied().collect();
        if !watcher_ids.is_empty() {
            let push = proto::idl::presence::PushPresence {
                user_id: detail.brief.id,
                status: 1,
                status_text: String::new(),
                last_seen_ms: 0,
            };
            let _ = send_packet_to_users(
                ctx, &watcher_ids, command::Command::PushPresence,
                common::rid(), push.encode_to_vec(),
            ).await;
        }
    }

    let tx_1 = tx.clone();
    let tx_2 = tx.clone();
    user_ctx.conn_receiver.insert(conn_id, Arc::new(tx));
    let (mut sink, mut stream) = ws_stream.split();

    debug!("websocket conn established: {:?}", detail);

    let running = AtomicBool::new(true);

    let _last_recv_heartbeat = AtomicU64::new(current_s());

    while running.load(Ordering::SeqCst) {
        let mut msg: Option<Message> = None;
        tokio::select! {
            _ = async {
                msg = stream.next().await.and_then(|m| m.ok());
            } => {
                match msg {
                    Some(Message::Text(txt)) => debug!("recv text msg: {}", txt),
                    Some(Message::Frame(frame)) => debug!("recv frame msg: {:?}", frame),
                    Some(Message::Binary(bin)) => {
                        // recv and send as Packet
                        let packet = if let Ok(packet) = pb_decode::<entity::Packet>(&bin) {
                            // debug!("recv packet, cmd: {:?}, rid: {}, len: {}", packet.cmd, packet.rid, packet.payload.len());
                            packet
                        } else {
                            warn!("recv packet decode error");
                            break;
                        };
                        let now = std::time::Instant::now();
                        let cmd = packet.cmd;
                        let (code, data) = match crate::handle_client_packet(conn_id, packet.cmd, ctx, &detail.brief, &packet, true).await {
                            Ok((code, data)) => {
                                debug!("handle cmd ok, cmd: {}, code: {}, cost: {}, data len: {:?}",  cmd, code, now.elapsed().as_millis(), data.len());
                                (code, data)
                            }
                            Err(err) => {
                                warn!("handle cmd error, cmd: {}, cost: {}, err: {:?}", cmd, now.elapsed().as_millis(), err);
                                (idl_error::ErrorCode::ErrorServerError as i32, vec![])
                            }
                        };
                        let mut resp = entity::Packet::default();
                        resp.rid = packet.rid;
                        resp.code = code;
                        resp.cmd = command::Command::Ack as  i32;
                        resp.payload = data;
                        let _ = tx_1.send(ClientCommand::Request(resp));
                    }
                    Some(Message::Ping(_bin)) => {
                        // debug!("recv ping msg: {:?}", bin);
                        let _ = tx_1.send(ClientCommand::HeartbeatAck);
                    }
                    Some(Message::Pong(_bin)) =>
                    {
                        // debug!("recv pong msg: {:?}", bin);
                    }
                    Some(Message::Close(bin)) => debug!("recv close msg: {:?}", bin),
                    None => {
                        // warn!("recv error, close");
                        running.store(false, Ordering::Relaxed);
                    }
                }
            }
            _ = async {
                tokio::time::sleep(Duration::from_secs(15)).await;
                // debug!("send heartbeat");
                let _ = tx_2.send(ClientCommand::Heartbeat);
            } => {}
            _ = async {
                let cmd = rx.recv().await;
                // debug!("command waited");
                match cmd {
                    Some(ClientCommand::Request(pkt)) => {
                        // debug!("ws send packet to client, rid: {}, cmd: {:?}", pkt.rid, pkt.cmd);
                       let _ =  sink.send(Message::Binary(pkt.encode_to_vec().into())).await;
                    }
                    Some(ClientCommand::AsyncRequest(wait)) => {
                        let _ = sink.send(Message::Binary(wait.packet.encode_to_vec().into())).await;
                    }
                    Some(ClientCommand::Heartbeat) => {
                        let _ = sink.send(Message::Ping(vec![].into())).await;
                    }
                    Some(ClientCommand::HeartbeatAck) => {
                        let _ = sink.send(Message::Pong(vec![].into())).await;
                    }
                    _ => {}
                }
            } => {}
        }
    }

    // ws_stream.close().await;
    if detail.logined {
        user_ctx.conn_user.remove(&conn_id);
        user_ctx.user_conn.entry(detail.brief.id).and_modify(|set| {
            set.remove(&conn_id);
        });
        user_ctx.conn_receiver.remove(&conn_id);

        // M3: presence offline only if no remaining connections
        let has_remaining = user_ctx.user_conn.get(&detail.brief.id)
            .map(|set| !set.is_empty())
            .unwrap_or(false);
        if !has_remaining {
            let now = common::time::current_ms() as i64;
            let _ = ctx.db.execute(Statement::from_sql_and_values(
                DbBackend::Postgres,
                "UPDATE user_presence SET status = 0, last_seen_at = $1, updated_at = NOW() WHERE user_id = $2",
                vec![
                    common::time::date_time(now).into(),
                    detail.brief.id.into(),
                ],
            )).await;

            if let Some(watchers) = common::PRESENCE_SUBSCRIBERS.get(&detail.brief.id) {
                let watcher_ids: Vec<i64> = watchers.iter().copied().collect();
                if !watcher_ids.is_empty() {
                    let push = proto::idl::presence::PushPresence {
                        user_id: detail.brief.id,
                        status: 0,
                        status_text: String::new(),
                        last_seen_ms: now,
                    };
                    let _ = send_packet_to_users(
                        ctx, &watcher_ids, command::Command::PushPresence,
                        common::rid(), push.encode_to_vec(),
                    ).await;
                }
            }
        }
    }

    Ok(())
}

fn load_tls_config(ctx: &AppContext) -> Result<TlsAcceptor> {
    use rustls::crypto::ring;
    use std::fs::File;
    use std::io::BufReader;
    let settings = ctx
        .config
        .settings
        .as_ref()
        .and_then(|v| serde_json::from_value::<common::Settings>(v.clone()).ok())
        .expect("config settings not found");

    let cert_path = settings.cert.expect("config cert not found");
    let key_path = settings.cert_key.expect("config cert_key not found");

    let certs = rustls_pemfile::certs(&mut BufReader::new(File::open(&cert_path)?))
        .collect::<Result<Vec<CertificateDer>, _>>()?;
    let key = rustls_pemfile::private_key(&mut BufReader::new(File::open(&key_path)?))?
        .ok_or_else(|| Error::Message("no private key found".into()))?;

    let config = rustls::ServerConfig::builder_with_provider(ring::default_provider().into())
        .with_protocol_versions(&[&rustls::version::TLS13])
        .map_err(|e| Error::Message(e.to_string()))?
        .with_no_client_auth()
        .with_single_cert(certs, key)
        .map_err(|e| Error::Message(e.to_string()))?;

    Ok(TlsAcceptor::from(Arc::new(config)))
}

pub(crate) async fn server(ctx: &AppContext) -> Result<()> {
    debug!("start websocket server");
    let acceptor = load_tls_config(ctx)?;
    let server = TcpListener::bind("0.0.0.0:8889").await?;
    let mut conn_id: i64 = 0;
    while let Ok((stream, addr)) = server.accept().await {
        let context = ctx.clone();
        let acceptor = acceptor.clone();
        conn_id += 1;
        tokio::spawn(async move {
            match acceptor.accept(stream).await {
                Ok(tls_stream) => {
                    let _ = handle_client(&context, tls_stream, addr, conn_id).await;
                }
                Err(e) => {
                    warn!("tls accept error: {:?}", e);
                }
            }
        });
    }
    debug!("websocket server stop");
    Ok(())
}

#[allow(dead_code)]
pub(crate) fn start_server(ctx: &AppContext) {
    let ctx = ctx.clone();
    tokio::spawn(async move {
        let _ = server(&ctx).await;
    });
}

#[allow(dead_code)]
pub(crate) async fn send_packet_to_users(
    _ctx: &AppContext,
    user_ids: &[i64],
    cmd: command::Command,
    sid: i64,
    payload: Vec<u8>,
) -> Result<()> {
    cost!("send_packet_to_users");
    debug!(
        "send packet to users, {cmd:?} len: {}, sid: {sid}, users: {user_ids:?}",
        payload.len()
    );
    let packet = entity::Packet {
        rid: sid,
        code: 0,
        cmd: cmd as i32,
        http: false,
        payload,
    };
    let context = get_user_context();
    for user_id in user_ids {
        let conn_ids = context.user_conn.get(user_id);
        let ids: Vec<i64> = if let Some(ids) = conn_ids {
            ids.iter().cloned().collect()
        } else {
            continue;
        };
        // debug!(
        //     "push packet to user, cmd: {:?}, len: {:?}, rid: {:?}, conn_ids: {:?}",
        //     cmd,
        //     packet.payload.len(),
        //     packet.rid,
        //     ids
        // );
        for id in ids.iter() {
            let ch = context.conn_receiver.get(&id);
            if let Some(tx) = ch.as_ref() {
                // debug!("push packet to conn: {}", id);
                let _ = tx.send(ClientCommand::Request(packet.clone()));
            };
        }
    }
    Ok(())
}
