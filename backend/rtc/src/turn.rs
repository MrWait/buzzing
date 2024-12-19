use axum::Router;
use axum::extract::WebSocketUpgrade;
use axum::extract::ws::{Message, WebSocket};
use axum::response::IntoResponse;
use axum::routing::any;
use axum_server::tls_rustls::RustlsConfig;
use futures_util::stream::StreamExt;
use loco_rs::prelude::*;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::net::{IpAddr, SocketAddr};
use std::path::PathBuf;
use std::str::FromStr;
use std::sync::{Arc, LazyLock, Mutex};
use std::time::Duration;
use tokio::net::UdpSocket;
use tokio::sync::mpsc;
use tokio_stream::wrappers::UnboundedReceiverStream;
use tracing::debug;
use webrtc::turn::relay::relay_static::RelayAddressGeneratorStatic;
use webrtc::turn::{self, auth, server};
use webrtc::util::vnet;

use common::{ExternApp, common_error};

pub async fn serve(ctx: &AppContext) -> Result<()> {
    let conn = Arc::new(UdpSocket::bind("0.0.0.0:19302").await?);
    debug!("create turn bind ok: {:?}", conn.local_addr());

    let config = server::config::ServerConfig {
        conn_configs: vec![server::config::ConnConfig {
            conn,
            relay_addr_generator: Box::new(RelayAddressGeneratorStatic {
                relay_address: IpAddr::from_str("127.0.0.1")
                    .map_err(|e| common_error(&e.to_string()))?,
                address: "0.0.0.0".to_owned(),
                net: Arc::new(vnet::net::Net::new(None)),
            }),
        }],
        realm: "flutter-webrtc".to_owned(),
        auth_handler: Arc::new(RtcAuthHandler::new()),
        channel_bind_timeout: Duration::from_secs(0),
        alloc_close_notify: None,
    };
    let server = server::Server::new(config)
        .await
        .map_err(|e| common_error(&e.to_string()))?;
    server
        .close()
        .await
        .map_err(|e| common_error(&e.to_string()))?;
    Ok(())
}

struct RtcAuthHandler {
    cred_map: HashMap<String, Vec<u8>>,
}

impl RtcAuthHandler {
    fn new() -> Self {
        Self {
            cred_map: HashMap::new(),
        }
    }
}

impl auth::AuthHandler for RtcAuthHandler {
    fn auth_handle(
        &self,
        username: &str,
        realm: &str,
        src_addr: SocketAddr,
    ) -> std::result::Result<Vec<u8>, turn::Error> {
        if let Some(pw) = self.cred_map.get(username) {
            Ok(pw.to_vec())
        } else {
            Err(turn::Error::ErrFakeErr)
        }
    }
}
