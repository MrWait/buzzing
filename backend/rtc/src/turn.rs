use common::common_error;
use loco_rs::prelude::*;
use std::net::IpAddr;
use std::str::FromStr;
use std::sync::Arc;
use std::sync::OnceLock;
use std::time::Duration;
use tokio::net::UdpSocket;
use tracing::debug;
use webrtc::turn::relay::relay_static::RelayAddressGeneratorStatic;
use webrtc::turn::{auth, server};
use webrtc::util::vnet;

static TURN_SECRET: OnceLock<String> = OnceLock::new();

pub fn init_secret(secret: String) {
    let _ = TURN_SECRET.set(secret);
}

pub fn generate_credential() -> (String, String) {
    let secret = TURN_SECRET.get().map(|s| s.as_str()).unwrap_or("");
    auth::generate_long_term_credentials(secret, Duration::from_secs(86400)).unwrap_or_default()
}

pub async fn serve() -> Result<()> {
    let secret = TURN_SECRET.get().map(|s| s.as_str()).unwrap_or("").to_string();

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
        auth_handler: Arc::new(auth::LongTermAuthHandler::new(secret)),
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
