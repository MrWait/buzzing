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
use strum::{EnumString, IntoStaticStr};
use tokio::sync::mpsc;
use tokio_stream::wrappers::UnboundedReceiverStream;
use tracing::debug;

use common::lock::RwLock;
use common::{UserBrief, common_error};

type WsConn = Arc<mpsc::UnboundedSender<Message>>;
static SIGNALER: LazyLock<RwLock<Signaler>> = LazyLock::new(|| RwLock::new(Signaler::default()));
static JWT_SECRET: OnceLock<String> = OnceLock::new();

pub fn init_jwt(secret: String) {
    let _ = JWT_SECRET.set(secret);
}

pub fn validate_token(token: &str) -> Result<UserBrief, String> {
    let secret = JWT_SECRET.get().ok_or("JWT not configured")?;
    let claims = auth::jwt::JWT::new(secret)
        .validate(token)
        .map_err(|e| format!("invalid token: {e}"))?;
    UserBrief::from_string(&claims.claims.pid).map_err(|e| format!("invalid claims: {e}"))
}

#[derive(Deserialize)]
struct NewPeerRequest {
    token: String,
    #[serde(default)]
    name: String,
    #[serde(default)]
    user_agent: String,
}

async fn handle_new_peer(data: Value, tx: &mpsc::UnboundedSender<Message>) -> Result<String, String> {
    let req: NewPeerRequest =
        serde_json::from_value(data).map_err(|_| "invalid request".to_string())?;

    let secret = JWT_SECRET.get().ok_or("JWT not configured")?;
    let claims = auth::jwt::JWT::new(secret)
        .validate(&req.token)
        .map_err(|e| format!("invalid token: {e}"))?;

    let brief = UserBrief::from_string(&claims.claims.pid)
        .map_err(|e| format!("invalid claims: {e}"))?;

    let peer_id = brief.id.to_string();
    let info = PeerInfo {
        id: peer_id.clone(),
        name: req.name,
        user_agent: req.user_agent,
        user_id: brief.id,
        tenant_id: brief.tenant_id,
    };
    debug!("new peer registered: {info:?}");

    {
        let mut signaler = SIGNALER.write();
        signaler.peers.insert(peer_id.clone(), Peer {
            info,
            conn: Arc::new(tx.clone()),
        });
    }

    Ok(peer_id)
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
                debug!("recv msg: ${msg}");
                if let Ok(req) = serde_json::from_str::<Request>(&msg) {
                    match SignalType::from_str(&req.r#type) {
                        Ok(SignalType::New) => {
                            match handle_new_peer(req.data, &tx).await {
                                Ok(pid) => {
                                    let _ = peer_id.set(pid);
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
                        Ok(SignalType::Bye) => {
                            if let Ok(bye) = serde_json::from_value::<ByeBye>(req.data) {
                                let ids = bye.session_id.split('-');
                                let ids: Vec<String> = ids.map(|s| s.to_owned()).collect();
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
                                    let send_bye = |session: &str, id: &str| {
                                        let mut data: HashMap<String, String> = HashMap::new();
                                        data.insert("session_id".to_string(), session.to_owned());
                                        let req = Request {
                                            r#type: "bye".to_string(),
                                            data: serde_json::to_value(data)
                                                .map_err(|_| common_error("parse error"))?,
                                        };
                                        if let Ok(s) = serde_json::to_string(&req) {
                                            let signaler = SIGNALER.read();
                                            if let Some(peer) = signaler.peers.get(id) {
                                                debug!("send bye to peer: {:?}, {s:?}", peer.info);
                                                let _ = peer.conn.send(Message::Text(s.into()));
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
                            if let Ok(nego) = serde_json::from_value::<Negotiation>(req.data) {
                                let peer: Option<Peer>;
                                {
                                    let signal = SIGNALER.read();
                                    peer = signal.peers.get(&nego.to).cloned();
                                }
                                if let Some(p) = peer {
                                    debug!("send to peer: {:?}", p.info);
                                    send_to_peers(vec![p.conn], Message::Text(msg));
                                }
                            }
                        }
                        Ok(SignalType::Leave) => {}
                        Ok(SignalType::Keepalive) => {
                            debug!("send keepalive to peer: {:?}", msg);
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
    if let Some(id) = peer_id.get() {
        let conns;
        {
            let mut signaler = SIGNALER.write();
            signaler.peers.remove(id);
            conns = signaler.conns();
        }
        let req = Request {
            r#type: "leave".to_owned(),
            data: serde_json::Value::String(id.to_owned()),
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

/*
[general]
domain=demo.cloudwebrtc.com
cert=configs/certs/cert.pem
key=configs/certs/key.pem
bind=0.0.0.0
port=8086
html_root=web

[turn]
public_ip=127.0.0.1
port=19302
realm=flutter-webrtc
*/

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
    #[strum(serialize = "leave")]
    Leave,
    #[strum(serialize = "keepalive")]
    Keepalive,
}

#[derive(Debug, Clone)]
struct Peer {
    pub info: PeerInfo,
    pub conn: WsConn,
}

#[derive(Debug)]
struct Session {
    pub id: String,
    pub from: Peer,
    pub to: Peer,
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
