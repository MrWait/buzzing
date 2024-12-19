mod bench;
mod config;
mod database;
mod log;
mod websocket;

mod prelude {
    pub use crate::idl::{self, command::Command, entity};
    pub use anyhow::Result;
    pub use parking_lot::Mutex as Mutex2;
    pub use prost::Message;
    pub use serde::Deserialize;
    pub use std::collections::HashMap;
    pub use std::sync::{Arc, OnceLock};
    pub use std::time::Duration;
    pub use tokio::sync::Mutex;
    pub use tokio::sync::mpsc::{UnboundedReceiver, UnboundedSender, unbounded_channel};
}

use std::ops::DerefMut;
use std::sync::atomic::{AtomicI32, AtomicI64, Ordering};

use bench::ActionHandler;
use config::*;
use prelude::*;

static GLOBAL_CONFIG: OnceLock<Arc<config::Config>> = OnceLock::new();

#[tokio::main]
async fn main() {
    let config = config::load_config("bench.toml");
    match config {
        Ok(config) => {
            println!("load config: {:?}", config);
            GLOBAL_CONFIG.get_or_init(|| Arc::new(config))
        }
        Err(err) => {
            println!("load config error: {:?}", err);
            return;
        }
    };

    let (t, r) = tokio::sync::oneshot::channel::<()>();
    // rustls::crypto::default_fips_provider().install_default();
    rustls::crypto::ring::default_provider().install_default();

    tokio::spawn(async move {
        let (tx, rx) = unbounded_channel::<Event>();
        let config = GLOBAL_CONFIG.get().unwrap();
        let handler = {
            let cfg = config.clone();
            bench::bench(cfg.as_ref(), tx)
        };
        match handler {
            Ok(handler) => {
                handler.init();
                handle_event(rx, handler.clone()).await;
            }
            Err(err) => {
                println!("create bench task error: {:?}", err);
            }
        }
        let _ = t.send(());
    });

    let _ = r.await;

    println!("finish");
}

#[derive(Debug, Default)]
pub struct Metrics {
    pub start: AtomicI32,
    pub logined: AtomicI32,
    pub connect: AtomicI32,
    pub send: AtomicI32,
    pub recv: AtomicI32,
    pub action: AtomicI32,
    pub ack: AtomicI32,
    pub error: AtomicI32,
}

async fn handle_event(mut rx: UnboundedReceiver<Event>, handler: Arc<Box<dyn ActionHandler>>) {
    let metric = Metrics::default();

    let mut prev = AtomicI64::new(0);
    let now = std::time::Instant::now();
    loop {
        tokio::select! {
            _ = async {
                if let Some(ev) = rx.recv().await {
                    handler.handle(ev, &metric);
                }
                if (now.elapsed().as_millis() as i64 - prev.load(Ordering::SeqCst)) > 500 {
                    println!("{:?}", metric);
                    prev.store(now.elapsed().as_millis() as i64, Ordering::SeqCst);
                }
            } => {}
            _ = async {
                tokio::time::sleep(Duration::from_millis(10)).await;
                if (now.elapsed().as_millis() as i64 - prev.load(Ordering::SeqCst)) > 500 {
                    println!("{:?}", metric);
                    prev.store(now.elapsed().as_millis() as i64, Ordering::SeqCst);
                }
            } => {}
        }

        if handler.finish() {
            break;
        }
    }
}

pub mod idl {
    pub mod chat {
        include!("idl/chat.rs");
    }
    pub mod command {
        include!("idl/command.rs");
    }
    pub mod dept {
        include!("idl/dept.rs");
    }
    pub mod entity {
        include!("idl/entity.rs");
    }
    pub mod error {
        include!("idl/error.rs");
    }
    pub mod feed {
        include!("idl/feed.rs");
    }
    pub mod message {
        include!("idl/message.rs");
    }
    pub mod pipeline {
        include!("idl/pipeline.rs");
    }
    pub mod sdk {
        include!("idl/sdk.rs");
    }
    pub mod user {
        include!("idl/user.rs");
    }
}

const ID_BASE: i64 = std::i64::MAX / 2;
pub fn id_gen() -> i64 {
    use rand::Rng;
    let id: i64 = rand::thread_rng().r#gen::<i64>() / 2 + ID_BASE;
    id
}
