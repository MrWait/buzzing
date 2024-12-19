use axum::extract::WebSocketUpgrade;
use axum::extract::ws::WebSocket;
use axum::response::Response;
use axum::routing::get;
use axum::{Extension, Router};
use futures_util::StreamExt;
use loco_rs::app::AppContext;
use std::sync::Arc;
use tokio::sync::{Mutex, RwLock};
use yrs::sync::awareness::Awareness;
use yrs::{Doc, Text, Transact};
use yrs_axum::AwarenessRef;
use yrs_axum::broadcast::BroadcastGroup;
use yrs_axum::ws::{AxumSink, AxumStream};

use common::ExternApp;

#[allow(dead_code)]
const STATIC_FILES_DIR: &str = "examples/code-mirror/frontend/dist";

#[derive(Clone)]
pub struct AppOffice;
impl ExternApp for AppOffice {
    fn serve(&self, _ctx: &AppContext) {
        tokio::spawn(async {
            serve().await;
        });
    }
}

#[allow(dead_code)]
async fn serve() {
    // We're using a single static document shared among all the peers.
    let awareness: AwarenessRef = {
        let doc = Doc::new();
        {
            // pre-initialize code mirror document with some text
            let txt = doc.get_or_insert_text("codemirror");
            let mut txn = doc.transact_mut();
            txt.push(
                &mut txn,
                r#"function hello() {
  console.log('hello world');
}"#,
            );
        }
        Arc::new(RwLock::new(Awareness::new(doc)))
    };

    // open a broadcast group that listens to awareness and document updates
    // and has a pending message buffer of up to 32 updates
    let bcast = Arc::new(BroadcastGroup::new(awareness.clone(), 32).await);

    let app = Router::<()>::new()
        // .nest_service("/", ServeDir::new(STATIC_FILES_DIR))
        .route("/my-room", get(ws_handler))
        .layer(Extension(bcast));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

#[allow(dead_code)]
async fn ws_handler(
    ws: WebSocketUpgrade,
    Extension(bcast): Extension<Arc<BroadcastGroup>>,
) -> Response {
    ws.on_upgrade(move |socket| peer(socket, bcast))
}

#[allow(dead_code)]
async fn peer(ws: WebSocket, bcast: Arc<BroadcastGroup>) {
    let (sink, stream) = ws.split();
    let sink = Arc::new(Mutex::new(AxumSink::from(sink)));
    let stream = AxumStream::from(stream);
    let sub = bcast.subscribe(sink, stream);
    match sub.completed().await {
        Ok(_) => println!("broadcasting for channel finished successfully"),
        Err(e) => eprintln!("broadcasting for channel finished abruptly: {}", e),
    }
}
