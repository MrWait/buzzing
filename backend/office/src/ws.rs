use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::sync::OnceLock;
use std::collections::HashMap;

use axum::extract::ws::WebSocket;
use axum::extract::{Path, WebSocketUpgrade};
use axum::http::HeaderMap;
use axum::response::IntoResponse;
use futures_util::StreamExt;
use loco_rs::app::AppContext;
use loco_rs::prelude::*;
use tokio::sync::RwLock;
use yrs::sync::awareness::Awareness;
use yrs::updates::decoder::Decode;
use yrs::{Doc, Transact, Update};
use yrs_axum::broadcast::BroadcastGroup;
use yrs_axum::ws::{AxumSink, AxumStream};
use yrs_axum::AwarenessRef;

use crate::yjs_store;

pub static YJS_MANAGER: OnceLock<Arc<YjsManager>> = OnceLock::new();

pub struct DocState {
    pub doc: Doc,
    _awareness: AwarenessRef,
    pub bcast: Arc<BroadcastGroup>,
    pub dirty: Arc<AtomicBool>,
    _subscription: yrs::Subscription,
}

pub struct YjsManager {
    pub ctx: AppContext,
    docs: RwLock<HashMap<i64, Arc<DocState>>>,
}

impl YjsManager {
    pub fn new(ctx: AppContext) -> Self {
        Self {
            ctx,
            docs: RwLock::new(HashMap::new()),
        }
    }

    pub async fn get_or_create(&self, doc_id: i64) -> Result<Arc<DocState>> {
        {
            let docs = self.docs.read().await;
            if let Some(state) = docs.get(&doc_id) {
                return Ok(state.clone());
            }
        }

        let doc = Doc::new();
        if let Some(content) = yjs_store::load_document(&self.ctx.db, doc_id).await? {
            if !content.is_empty() {
                let update = Update::decode_v1(&content).map_err(|e| Error::msg(e))?;
                doc.transact_mut().apply_update(update);
            }
        }

        let awareness = Arc::new(RwLock::new(Awareness::new(doc.clone())));
        let bcast = Arc::new(BroadcastGroup::new(awareness.clone(), 32).await);

        let dirty = Arc::new(AtomicBool::new(false));
        let dirty_clone = dirty.clone();
        let sub = doc
            .observe_update_v1(move |_txn, _event| {
                dirty_clone.store(true, Ordering::SeqCst);
            })
            .map_err(|e| Error::Message(format!("observe_update failed: {}", e)))?;

        let state = Arc::new(DocState {
            doc,
            _awareness: awareness,
            bcast,
            dirty,
            _subscription: sub,
        });

        self.docs.write().await.insert(doc_id, state.clone());
        Ok(state)
    }
}

pub async fn ws_handler(
    ws: WebSocketUpgrade,
    Path(doc_id): Path<i64>,
    headers: HeaderMap,
) -> Result<impl IntoResponse> {
    let token = headers
        .get("sec-websocket-protocol")
        .and_then(|v| v.to_str().map(|s| s.to_owned()).ok())
        .ok_or_else(|| Error::Unauthorized("missing token".to_string()))?;

    let manager = YJS_MANAGER
        .get()
        .ok_or_else(|| Error::Message("YjsManager not initialized".to_string()))?;

    let jwt_secret = manager.ctx.config.get_jwt_config()?;
    loco_rs::auth::jwt::JWT::new(&jwt_secret.secret)
        .validate(&token)
        .map_err(|_| Error::Unauthorized("invalid token".to_string()))?;

    let doc_state = manager.get_or_create(doc_id).await?;

    Ok(ws
        .protocols([token])
        .on_upgrade(move |socket| handle_connection(socket, doc_state)))
}

async fn handle_connection(ws: WebSocket, state: Arc<DocState>) {
    let (sink, stream) = ws.split();
    let sink = Arc::new(tokio::sync::Mutex::new(AxumSink::from(sink)));
    let stream = AxumStream::from(stream);
    let sub = state.bcast.subscribe(sink, stream);
    if let Err(e) = sub.completed().await {
        eprintln!("yjs connection error: {}", e);
    }
}

pub async fn periodic_save_loop(ctx: AppContext) {
    let mut interval = tokio::time::interval(tokio::time::Duration::from_secs(30));
    loop {
        interval.tick().await;
        let manager = match YJS_MANAGER.get() {
            Some(m) => m,
            None => continue,
        };
        let doc_ids: Vec<i64> = manager.docs.read().await.keys().copied().collect();
        for doc_id in doc_ids {
            let state = match manager.docs.read().await.get(&doc_id) {
                Some(s) => s.clone(),
                None => continue,
            };
            if !state.dirty.load(Ordering::Relaxed) {
                continue;
            }
            if let Err(e) = yjs_store::save_document(&ctx.db, doc_id, &state.doc).await {
                eprintln!("failed to save doc {}: {}", doc_id, e);
            } else {
                state.dirty.store(false, Ordering::Relaxed);
            }
        }
    }
}
