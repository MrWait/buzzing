use axum::extract::WebSocketUpgrade;
use axum::extract::ws::{Message, WebSocket};
use axum::response::IntoResponse;
use futures_util::stream::StreamExt;
use loco_rs::auth;
use loco_rs::prelude::*;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::cell::OnceCell;
use std::collections::HashMap;
use std::str::FromStr;
use std::sync::{Arc, LazyLock, OnceLock};
use std::time::Instant;
use strum::{EnumString, IntoStaticStr};
use tokio::sync::mpsc;
use tokio_stream::wrappers::UnboundedReceiverStream;
use tracing::debug;

use common::lock::RwLock;
use common::{BizHub, UserBrief, common_error};

const MAX_PEERS_PER_ROOM: usize = 4;

type WsConn = Arc<mpsc::UnboundedSender<Message>>;
static SIGNALER: LazyLock<RwLock<Signaler>> = LazyLock::new(|| RwLock::new(Signaler::default()));
static ROOMS: LazyLock<RwLock<RoomManager>> =
    LazyLock::new(|| RwLock::new(RoomManager::default()));
static JWT_SECRET: OnceLock<String> = OnceLock::new();
// AppContext 在 ws handler 中无法通过 axum State 注入，启动时缓存一份供 signaling 查询用户名等使用
static APP_CONTEXT: OnceLock<AppContext> = OnceLock::new();

pub fn init_jwt(secret: String) {
    let _ = JWT_SECRET.set(secret);
}

pub fn init_ctx(ctx: AppContext) {
    let _ = APP_CONTEXT.set(ctx);
}

pub fn validate_token(token: &str) -> Result<UserBrief, String> {
    let secret = JWT_SECRET.get().ok_or("JWT not configured")?;
    let claims = auth::jwt::JWT::new(secret)
        .validate(token)
        .map_err(|e| format!("invalid token: {e}"))?;
    UserBrief::from_string(&claims.claims.pid).map_err(|e| format!("invalid claims: {e}"))
}

/// 通过 user 模块接口查询用户名；查询失败时回退到 user_id 字符串
async fn fetch_user_name(user_id: i64) -> String {
    let ctx = match APP_CONTEXT.get() {
        Some(ctx) => ctx,
        None => return user_id.to_string(),
    };
    let hub = match BizHub::get() {
        Ok(hub) => hub,
        Err(_) => return user_id.to_string(),
    };
    match hub.user.get_user_by_id(ctx, user_id).await {
        Ok(u) if !u.name.is_empty() => u.name,
        _ => user_id.to_string(),
    }
}

#[derive(Deserialize)]
struct NewPeerRequest {
    token: String,
    #[serde(default)]
    #[allow(dead_code)]
    name: String,
    #[serde(default)]
    user_agent: String,
}

#[derive(Debug, Deserialize)]
struct JoinRequest {
    room_id: String,
}

#[derive(Debug, Deserialize)]
struct LeaveRequest {
    room_id: String,
}

async fn handle_new_peer(
    data: Value,
    tx: &mpsc::UnboundedSender<Message>,
) -> Result<String, String> {
    let req: NewPeerRequest =
        serde_json::from_value(data).map_err(|_| "invalid request".to_string())?;

    let secret = JWT_SECRET.get().ok_or("JWT not configured")?;
    let claims = auth::jwt::JWT::new(secret)
        .validate(&req.token)
        .map_err(|e| format!("invalid token: {e}"))?;

    let brief = UserBrief::from_string(&claims.claims.pid)
        .map_err(|e| format!("invalid claims: {e}"))?;

    let peer_id = brief.id.to_string();
    // 用户名以服务端从 user 模块查询结果为准，不信任客户端上报
    let name = fetch_user_name(brief.id).await;
    let info = PeerInfo {
        id: peer_id.clone(),
        name,
        user_agent: req.user_agent,
        user_id: brief.id,
        tenant_id: brief.tenant_id,
    };
    debug!("new peer registered: {info:?}");

    {
        let mut signaler = SIGNALER.write();
        signaler.peers.insert(
            peer_id.clone(),
            Peer {
                info,
                conn: Arc::new(tx.clone()),
                room_id: None,
            },
        );
    }

    Ok(peer_id)
}

async fn handle_join(
    peer_id: &str,
    data: Value,
    tx: &mpsc::UnboundedSender<Message>,
) -> Result<(), String> {
    let req: JoinRequest = serde_json::from_value(data).map_err(|_| "invalid join request")?;

    let room_id = req.room_id;

    let room_info = {
        let mut rooms = ROOMS.write();
        let room = rooms.rooms.entry(room_id.clone()).or_insert(Room {
            id: room_id.clone(),
            host: peer_id.to_string(),
            peers: HashMap::new(),
            created_at: Instant::now(),
        });

        if room.peers.len() >= MAX_PEERS_PER_ROOM {
            return Err("room_full".to_string());
        }

        if room.peers.contains_key(peer_id) {
            return Ok(());
        }

        let signaler = SIGNALER.read();
        let info = signaler
            .peers
            .get(peer_id)
            .map(|p| p.info.clone())
            .ok_or("peer not found")?;
        drop(signaler);

        if room.peers.is_empty() {
            room.host = peer_id.to_string();
        }
        room.peers.insert(peer_id.to_string(), info);
        room.to_info()
    };

    {
        let mut signaler = SIGNALER.write();
        if let Some(peer) = signaler.peers.get_mut(peer_id) {
            peer.room_id = Some(room_id.clone());
        }
    }

    let resp = Request {
        r#type: "room_info".to_owned(),
        data: serde_json::to_value(&room_info).map_err(|_| "serialize error")?,
    };
    if let Ok(s) = serde_json::to_string(&resp) {
        let _ = tx.send(Message::Text(s.into()));
    }

    broadcast_room_info(&room_id, Some(peer_id)).await;

    Ok(())
}

async fn handle_leave(peer_id: &str, data: Option<Value>) -> Result<(), String> {
    let room_id = if let Some(d) = data {
        let req: LeaveRequest =
            serde_json::from_value(d).map_err(|_| "invalid leave request")?;
        req.room_id
    } else {
        let signaler = SIGNALER.read();
        signaler
            .peers
            .get(peer_id)
            .and_then(|p| p.room_id.clone())
            .ok_or("peer not in any room")?
    };

    let remove_room = {
        let mut rooms = ROOMS.write();
        let empty = if let Some(room) = rooms.rooms.get_mut(&room_id) {
            room.peers.remove(peer_id);
            if room.peers.is_empty() {
                true
            } else {
                if room.host == peer_id {
                    let earliest = room
                        .peers
                        .keys()
                        .next()
                        .cloned()
                        .unwrap_or_default();
                    room.host = earliest;
                }
                false
            }
        } else {
            false
        };
        if empty {
            rooms.rooms.remove(&room_id);
        }
        empty
    };

    {
        let mut signaler = SIGNALER.write();
        if let Some(peer) = signaler.peers.get_mut(peer_id) {
            peer.room_id = None;
        }
    }

    if !remove_room {
        broadcast_room_info(&room_id, Some(peer_id)).await;
    }

    Ok(())
}

async fn broadcast_room_info(room_id: &str, exclude_peer_id: Option<&str>) {
    let rooms = ROOMS.read();
    let room = match rooms.rooms.get(room_id) {
        Some(r) => r,
        None => return,
    };
    let room_info = room.to_info();
    let peer_ids: Vec<String> = room
        .peers
        .keys()
        .filter(|pid| exclude_peer_id.map_or(true, |ex| pid.as_str() != ex))
        .cloned()
        .collect();
    drop(rooms);

    if peer_ids.is_empty() {
        return;
    }

    let req = Request {
        r#type: "room_info".to_owned(),
        data: serde_json::to_value(room_info).unwrap_or_default(),
    };
    if let Ok(s) = serde_json::to_string(&req) {
        let msg = Message::Text(s.into());
        let signaler = SIGNALER.read();
        for pid in &peer_ids {
            if let Some(peer) = signaler.peers.get(pid) {
                let _ = peer.conn.send(msg.clone());
            }
        }
    }
}

async fn forward_to_room(sender_id: &str, msg: &str) -> Result<(), String> {
    let targets = {
        let rooms = ROOMS.read();
        let signaler = SIGNALER.read();

        let room_id = signaler
            .peers
            .get(sender_id)
            .and_then(|p| p.room_id.as_ref())
            .cloned()
            .ok_or("sender not in a room")?;

        let room = rooms
            .rooms
            .get(&room_id)
            .ok_or("room not found")?;

        let targets: Vec<WsConn> = room
            .peers
            .keys()
            .filter(|pid| pid.as_str() != sender_id)
            .filter_map(|pid| signaler.peers.get(pid))
            .map(|p| p.conn.clone())
            .collect();

        targets
    };

    let msg = Message::Text(msg.to_owned().into());
    send_to_peers(targets, msg);
    Ok(())
}

pub async fn meeting_handler(ws: WebSocketUpgrade) -> impl IntoResponse {
    debug!("ws handler");
    ws.on_upgrade(move |socket| handle_socket_meeting(socket))
}

async fn handle_socket_meeting(ws: WebSocket) {
    debug!("meeting websocket connect");
    let (user_ws_tx, mut user_ws_rx) = ws.split();
    let (tx, rx) = mpsc::unbounded_channel();
    tokio::task::spawn(async move {
        let rx_stream = UnboundedReceiverStream::new(rx);
        let _ = rx_stream.map(Ok).forward(user_ws_tx).await;
    });
    let peer_id: OnceCell<String> = OnceCell::new();
    while let Some(Ok(message)) = user_ws_rx.next().await {
        match message {
            Message::Text(msg) => {
                debug!("recv msg: {msg}");
                if let Ok(req) = serde_json::from_str::<Request>(&msg) {
                    match SignalType::from_str(&req.r#type) {
                        Ok(SignalType::New) => {
                            match handle_new_peer(req.data, &tx).await {
                                Ok(pid) => {
                                    let _ = peer_id.set(pid.clone());
                                    // 给当前客户端发送它自己的 peer_id，前端据此设置 uid
                                    let resp = Request {
                                        r#type: "new_ack".to_owned(),
                                        data: serde_json::json!({ "peer_id": pid }),
                                    };
                                    if let Ok(s) = serde_json::to_string(&resp) {
                                        let _ = tx.send(Message::Text(s.into()));
                                    }
                                    let _ = notify_peers_update().await;
                                }
                                Err(err_msg) => {
                                    let req = Request {
                                        r#type: "error".to_owned(),
                                        data: serde_json::json!({"reason": err_msg}),
                                    };
                                    if let Ok(s) = serde_json::to_string(&req) {
                                        let _ = tx.send(Message::Text(s.into()));
                                    }
                                    break;
                                }
                            }
                        }
                        Ok(SignalType::Join) => {
                            if let Some(pid) = peer_id.get() {
                                if let Err(e) = handle_join(pid, req.data, &tx).await {
                                    let req = Request {
                                        r#type: "error".to_owned(),
                                        data: serde_json::json!({"reason": e}),
                                    };
                                    if let Ok(s) = serde_json::to_string(&req) {
                                        let _ = tx.send(Message::Text(s.into()));
                                    }
                                }
                            }
                        }
                        Ok(SignalType::Leave) => {
                            if let Some(pid) = peer_id.get() {
                                let _ = handle_leave(pid, Some(req.data)).await;
                            }
                        }
                        Ok(SignalType::Bye) => {
                            if let Ok(bye) = serde_json::from_value::<ByeBye>(req.data) {
                                let ids: Vec<String> =
                                    bye.session_id.split('-').map(|s| s.to_owned()).collect();
                                if ids.len() != 2 {
                                    if let Ok(s) = serde_json::to_value(RtcError {
                                        request: "bye".to_owned(),
                                        reason: "invalid session id".to_owned(),
                                    }) {
                                        let req = Request {
                                            r#type: "error".to_owned(),
                                            data: s,
                                        };
                                        if let Ok(s) = serde_json::to_string(&req) {
                                            send_to_peers(
                                                vec![Arc::new(tx.clone())],
                                                Message::Text(s.into()),
                                            );
                                        }
                                    }
                                } else {
                                    let signaler = SIGNALER.read();
                                    let send_bye = |session: &str, id: &str| {
                                        let mut data: HashMap<String, String> = HashMap::new();
                                        data.insert(
                                            "session_id".to_string(),
                                            session.to_owned(),
                                        );
                                        let req = Request {
                                            r#type: "bye".to_string(),
                                            data: serde_json::to_value(data)
                                                .map_err(|_| common_error("parse error"))?,
                                        };
                                        if let Ok(s) = serde_json::to_string(&req) {
                                            if let Some(peer) = signaler.peers.get(id) {
                                                debug!(
                                                    "send bye to peer: {:?}, {s:?}",
                                                    peer.info
                                                );
                                                let _ = peer
                                                    .conn
                                                    .send(Message::Text(s.into()));
                                            }
                                        }
                                        Ok::<(), Error>(())
                                    };
                                    let _ = send_bye(&bye.session_id, &ids[0]);
                                    let _ = send_bye(&bye.session_id, &ids[1]);
                                }
                            } else {
                                debug!("parse bye message error");
                            }
                        }
                        Ok(SignalType::Offer | SignalType::Answer | SignalType::Candidate) => {
                            // drop read guard before await
                            let is_room = {
                                let signaler = SIGNALER.read();
                                peer_id
                                    .get()
                                    .and_then(|pid| signaler.peers.get(pid))
                                    .map(|p| p.room_id.is_some())
                                    .unwrap_or(false)
                            };
                            if is_room {
                                if let Some(pid) = peer_id.get() {
                                    let msg = msg.clone();
                                    let _ = forward_to_room(pid, &msg).await;
                                }
                            } else {
                                let peer: Option<Peer> = {
                                    let signaler = SIGNALER.read();
                                    serde_json::from_value::<Negotiation>(req.data)
                                        .ok()
                                        .and_then(|nego| signaler.peers.get(&nego.to).cloned())
                                };
                                if let Some(p) = peer {
                                    debug!("send to peer: {:?}", p.info);
                                    send_to_peers(vec![p.conn], Message::Text(msg));
                                }
                            }
                        }
                        Ok(SignalType::Keepalive) => {
                            debug!("send keepalive to peer: {msg}");
                            send_to_peers(vec![Arc::new(tx.clone())], Message::Text(msg));
                        }
                        Err(_) => {}
                    }
                } else {
                    debug!("msg parse error");
                }
            }
            _ => {}
        }
    }

    // close
    if let Some(pid) = peer_id.get() {
        // try room-aware leave first
        let had_room = {
            let signaler = SIGNALER.read();
            signaler
                .peers
                .get(pid)
                .and_then(|p| p.room_id.clone())
        };
        if had_room.is_some() {
            let _ = handle_leave(pid, None).await;
        }

        let conns;
        {
            let mut signaler = SIGNALER.write();
            signaler.peers.remove(pid);
            conns = signaler.conns();
        }
        let req = Request {
            r#type: "leave".to_owned(),
            data: serde_json::Value::String(pid.to_owned()),
        };
        if let Ok(s) = serde_json::to_string(&req) {
            send_to_peers(conns, Message::Text(s.into()));
        }
    }
}

async fn notify_peers_update() -> Result<()> {
    let conns;
    let req;
    {
        let signaler = SIGNALER.read();
        conns = signaler.conns();
        let peers: Vec<PeerInfo> = signaler.peers.values().map(|p| p.info.clone()).collect();
        req = Request {
            r#type: "peers".to_owned(),
            data: serde_json::to_value(peers)?,
        };
    }
    if let Ok(s) = serde_json::to_string(&req) {
        let msg = Message::Text(s.into());
        send_to_peers(conns, msg);
    }
    Ok(())
}

fn send_to_peers(conns: Vec<WsConn>, msg: Message) {
    debug!("send to peers: {msg:?}");
    for conn in conns {
        let _ = conn.send(msg.clone());
    }
}

#[derive(IntoStaticStr, EnumString)]
enum SignalType {
    #[strum(serialize = "new")]
    New,
    #[strum(serialize = "bye")]
    Bye,
    #[strum(serialize = "offer")]
    Offer,
    #[strum(serialize = "answer")]
    Answer,
    #[strum(serialize = "candidate")]
    Candidate,
    #[strum(serialize = "join")]
    Join,
    #[strum(serialize = "leave")]
    Leave,
    #[strum(serialize = "keepalive")]
    Keepalive,
}

#[derive(Debug, Clone)]
struct Peer {
    pub info: PeerInfo,
    pub conn: WsConn,
    pub room_id: Option<String>,
}

#[derive(Debug)]
struct Session {
    pub id: String,
    pub from: Peer,
    pub to: Peer,
}

#[derive(Debug, Clone)]
struct Room {
    pub id: String,
    pub host: String,
    pub peers: HashMap<String, PeerInfo>,
    pub created_at: Instant,
}

impl Room {
    pub fn to_info(&self) -> RoomInfoResponse {
        RoomInfoResponse {
            room_id: self.id.clone(),
            peers: self.peers.values().cloned().collect(),
            host: self.host.clone(),
        }
    }
}

#[derive(Debug, Default)]
struct RoomManager {
    pub rooms: HashMap<String, Room>,
}

#[derive(Debug, Serialize, Deserialize)]
struct RoomInfoResponse {
    pub room_id: String,
    pub peers: Vec<PeerInfo>,
    pub host: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct Request {
    pub r#type: String,
    pub data: Value,
}

#[derive(Clone, Debug, Default, Serialize, Deserialize)]
struct PeerInfo {
    pub id: String,
    pub name: String,
    pub user_agent: String,
    #[serde(default)]
    pub user_id: i64,
    #[serde(default)]
    pub tenant_id: i64,
}

#[derive(Debug, Default, Serialize, Deserialize)]
struct Negotiation {
    pub from: String,
    pub to: String,
    pub session_id: String,
}

#[derive(Debug, Default, Serialize, Deserialize)]
struct ByeBye {
    pub session_id: String,
    pub from: String,
}

#[derive(Debug, Default, Serialize, Deserialize)]
struct RtcError {
    pub request: String,
    pub reason: String,
}

#[derive(Debug, Default)]
struct Signaler {
    pub peers: HashMap<String, Peer>,
    #[allow(dead_code)]
    pub sessions: HashMap<String, Session>,
}

impl Signaler {
    async fn send(&self) -> Result<()> {
        Ok(())
    }

    pub fn conns(&self) -> Vec<WsConn> {
        self.peers.values().map(|p| p.conn.clone()).collect()
    }
}
