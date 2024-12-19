mod signaling;
mod turn;

use axum::Router as ARouter;
use axum::extract::WebSocketUpgrade;
use axum::extract::ws::{Message, WebSocket};
use axum::response::IntoResponse;
use axum::routing::any;
use axum_server::tls_rustls::RustlsConfig;
use futures_util::stream::StreamExt;
use loco_rs::prelude::*;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::net::SocketAddr;
use std::path::PathBuf;
use std::sync::{Arc, LazyLock, Mutex};
use tokio::sync::mpsc;
use tokio_stream::wrappers::UnboundedReceiverStream;
use tracing::debug;

use common::ExternApp;

type Clients = Arc<Mutex<HashMap<String, mpsc::UnboundedSender<Message>>>>;

static CLIENTS: LazyLock<Clients> = LazyLock::new(|| Arc::new(Mutex::new(HashMap::new())));

#[derive(Serialize, Deserialize)]
pub struct Signal {
    event: String,
    data: String,
    target: Option<String>,
}

#[derive(Clone)]
pub struct AppRtc;
impl ExternApp for AppRtc {
    fn routes(&self, _: &AppContext) -> Vec<Routes> {
        vec![
            Routes::new()
                .add("/meeting", any(ws_handler))
                .add("/ws", any(signaling::meeting_handler)),
            Routes::new().prefix("/api/turn")
                .add("/", any(handle_turn_credential)),
        ]
    }

    fn serve(&self, ctx: &AppContext) {
        let cc = ctx.clone();
        tokio::spawn(async move {
            let _ = turn::serve(&cc).await;
        });
    }
}
/*
WebSocketServerConfig{
                Host:           "0.0.0.0",
                Port:           8086,
                HTMLRoot:       "web",
                WebSocketPath:  "/ws",
                TurnServerPath: "/api/turn",
        }
*/
async fn serve() -> Result<()> {
    let app = ARouter::new()
        .route("/meeting", any(ws_handler))
        .route("/ws", any(signaling::meeting_handler));
    let config = RustlsConfig::from_pem_file(
        PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("..")
            .join("base")
            .join("assets")
            .join("cert")
            .join("www.buzzing-im.com+2.pem"),
        PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("..")
            .join("base")
            .join("assets")
            .join("cert")
            .join("www.buzzing-im.com+2-key.pem"),
    )
    .await?;
    let addr = SocketAddr::from(([0, 0, 0, 0], 8088));
    let _ = axum_server::bind_rustls(addr, config)
        .serve(app.into_make_service())
        .await;
    Ok(())
}

async fn ws_handler(ws: WebSocketUpgrade) -> impl IntoResponse {
    debug!("ws handler");
    ws.on_upgrade(move |socket| handle_socket(socket))
}

async fn handle_turn_credential(req: String) -> impl IntoResponse {
    format::json("{}")
}

async fn handle_socket(ws: WebSocket) {
    debug!("websocket connect");
    let clients = CLIENTS.clone();
    let (user_ws_tx, mut user_ws_rx) = ws.split();
    let (tx, rx) = mpsc::unbounded_channel();
    tokio::task::spawn(async move {
        let rx_stream = UnboundedReceiverStream::new(rx);
        let _ = rx_stream.map(Ok).forward(user_ws_tx).await;
    });

    let user_id = uuid::Uuid::new_v4().to_string();
    clients.lock().unwrap().insert(user_id.clone(), tx);

    while let Some(Ok(message)) = user_ws_rx.next().await {
        match message {
            Message::Text(msg) => {
                if let Ok(signal) = serde_json::from_str::<Signal>(&msg) {
                    if let Some(target) = &signal.target {
                        if let Some(target_tx) = clients.lock().unwrap().get(target) {
                            let _ = target_tx.send(Message::text(msg)).unwrap();
                        }
                    }
                }
            }
            _ => {}
        }
    }
    clients.lock().unwrap().remove(&user_id);
}

/*
pub async fn serve() {
    let clients: Clients = Arc::new(Mutex::new(HashMap::new()));

    let ws_route = warp::path("ws")
        .and(warp::ws())
        .and(with_clients(clients.clone()))
        .map(move |ws: warp::ws::Ws, clients| {
            ws.on_upgrade(move |socket| handle_connection(socket, clients))
        });
    let index_route = warp::path("index.html").and(warp::fs::file("./rtc.html"));
    let routes = ws_route.or(index_route);
    debug!("start rtc server");
    warp::serve(routes)
        .tls()
        .cert_path("assets/cert/localhost+3.pem")
        .key_path("assets/cert/localhost+3-key.pem")
        .run(([0, 0, 0, 0], 8891))
        .await;
    debug!("rtc server done");
}

fn with_clients(
    clients: Clients,
) -> impl Filter<Extract = (Clients,), Error = std::convert::Infallible> + Clone {
    warp::any().map(move || clients.clone())
}

async fn handle_connection(ws: WebSocket, clients: Clients) {
    let (user_ws_tx, mut user_ws_rx) = ws.split();
    let (tx, rx) = mpsc::unbounded_channel();
    tokio::task::spawn(async move {
        let rx_stream = UnboundedReceiverStream::new(rx);
        let _ = rx_stream.map(Ok).forward(user_ws_tx).await;
    });

    let user_id = uuid::Uuid::new_v4().to_string();
    clients.lock().unwrap().insert(user_id.clone(), tx);

    while let Some(Ok(message)) = user_ws_rx.next().await {
        if let Ok(msg_text) = message.to_str() {
            if let Ok(signal) = serde_json::from_str::<Signal>(msg_text) {
                if let Some(target) = &signal.target {
                    if let Some(target_tx) = clients.lock().unwrap().get(target) {
                        if let Ok(text) = message.to_str() {
                            let _ = target_tx.send(Message::text(text)).unwrap();
                        }
                    }
                }
            }
        }
    }
    clients.lock().unwrap().remove(&user_id);
}
*/
