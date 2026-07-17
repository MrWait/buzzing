use std::env;
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
use yrs::encoding::write::Write;
use yrs::sync::awareness::Awareness;
use yrs::updates::decoder::Decode;
use yrs::updates::encoder::{Encoder, EncoderV1};
use yrs::{Doc, Transact, Update};
use yrs_axum::broadcast::BroadcastGroup;
use yrs_axum::ws::{AxumSink, AxumStream};
use yrs_axum::AwarenessRef;

use crate::yjs_store;

pub static YJS_MANAGER: OnceLock<Arc<YjsManager>> = OnceLock::new();

/// 自定义 Yjs 消息类型：文档已保存
/// payload 结构：`varuint(MSG_CUSTOM_SAVED) | varuint(saved_at_ms)`
/// 客户端在 y-websocket 中注册对应的 messageHandler 消费。
pub const MSG_CUSTOM_SAVED: u32 = 100;
/// 自定义 Yjs 消息类型：文档正在同步
pub const MSG_CUSTOM_SYNCING: u32 = 101;

fn broadcast_capacity() -> usize {
    env::var("BUZZING_YJS_MAX_CLIENTS")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(128)
}

/// 构造一条自定义广播消息（saved / syncing）。
fn build_status_msg(msg_type: u32, ts_ms: i64) -> Vec<u8> {
    let mut encoder = EncoderV1::new();
    encoder.write_var(msg_type);
    encoder.write_var(ts_ms as u64);
    encoder.to_vec()
}

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
        let capacity = broadcast_capacity();
        let bcast = Arc::new(BroadcastGroup::new(awareness.clone(), capacity).await);

        // dirty 标记：只要文档发生 update 就置为 true。
        // 只在从 clean→dirty 过渡的第一次广播 syncing 提示，避免高频输入淹没客户端。
        let dirty = Arc::new(AtomicBool::new(false));
        let dirty_clone = dirty.clone();
        let bcast_clone = bcast.clone();
        let sub = doc
            .observe_update_v1(move |_txn, _event| {
                let was_clean = dirty_clone
                    .compare_exchange(false, true, Ordering::SeqCst, Ordering::SeqCst)
                    .is_ok();
                if was_clean {
                    let msg = build_status_msg(MSG_CUSTOM_SYNCING, common::time::current_ms() as i64);
                    let _ = bcast_clone.broadcast(msg);
                }
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
    let claims = loco_rs::auth::jwt::JWT::new(&jwt_secret.secret)
        .validate(&token)
        .map_err(|_| Error::Unauthorized("invalid token".to_string()))?;

    // M4 权限校验：区分两类 pid
    //   1. 普通用户 pid = UserBrief 编码字符串 → 走 permission::resolve_role
    //   2. 分享临时 JWT pid = "share:{share_id}:{doc_id}" → 校验 doc_id 匹配
    let user_pid = &claims.claims.pid;
    if let Some(rest) = user_pid.strip_prefix("share:") {
        // pid 形如 "share:{share_id}:{doc_id}"
        let parts: Vec<&str> = rest.split(':').collect();
        let share_doc_id: i64 = parts
            .get(1)
            .and_then(|s| s.parse().ok())
            .ok_or_else(|| Error::Unauthorized("bad share token".into()))?;
        if share_doc_id != doc_id {
            return Err(Error::Unauthorized("share token doc mismatch".into()));
        }
        // 分享 token 通过，允许连接（viewer 角色由客户端强制只读）
    } else {
        let user = common::model::UserBrief::from_string(user_pid)
            .map_err(|_| Error::Unauthorized("bad user token".into()))?;
        // 至少需要 viewer
        crate::permission::require_role(
            &manager.ctx,
            user.id,
            doc_id,
            crate::permission::Role::Viewer,
        )
        .await
        .map_err(|_| Error::Unauthorized("no access to doc".into()))?;
    }

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
            match yjs_store::save_document(&ctx.db, doc_id, &state.doc).await {
                Ok(()) => {
                    state.dirty.store(false, Ordering::Relaxed);
                    // 广播 saved 消息给所有在线客户端。
                    let now = common::time::current_ms() as i64;
                    let msg = build_status_msg(MSG_CUSTOM_SAVED, now);
                    let _ = state.bcast.broadcast(msg);
                }
                Err(e) => {
                    eprintln!("failed to save doc {}: {}", doc_id, e);
                }
            }
        }
    }
}
