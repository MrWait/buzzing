use dashmap::DashMap;
use std::sync::atomic::AtomicI32;
use std::sync::atomic::Ordering;
use std::sync::LazyLock;
use std::sync::OnceLock;
use tokio::sync::mpsc::UnboundedSender;
use tokio::sync::oneshot::{self, Sender};

use proto::idl::sdk;

static INVOKE_CH: LazyLock<DashMap<i32, Sender<sdk::InvokeResponse>>> =
    LazyLock::new(|| DashMap::new());
static INVOKE_SEQ: AtomicI32 = AtomicI32::new(0);

static PUSH_CH: OnceLock<UnboundedSender<sdk::SdkPushPacket>> = OnceLock::new();

#[allow(dead_code)]
pub async fn invoke(cmd: i32, param: Vec<u8>) -> sdk::InvokeResponse {
    let seq = INVOKE_SEQ.fetch_add(1, Ordering::Relaxed);
    let (tx, rx) = oneshot::channel::<sdk::InvokeResponse>();
    INVOKE_CH.insert(seq, tx);
    let _ = crate::app::invoke_impl(seq, cmd, param);
    let result = rx.await;
    result.unwrap_or_else(|_| sdk::InvokeResponse {
        seq,
        status: -1,
        user_id: 0,
        payload: vec![],
    })
}

pub fn invoke_response(seq: i32, resp: sdk::InvokeResponse) {
    if let Some(tx) = INVOKE_CH.remove(&seq) {
        let _ = tx.1.send(resp);
    }
}

pub fn push_packet(packet: sdk::SdkPushPacket) {
    if let Some(sender) = PUSH_CH.get() {
        let _ = sender.send(packet);
    }
}

#[allow(dead_code)]
pub fn reg_push_handler(sender: UnboundedSender<sdk::SdkPushPacket>) {
    PUSH_CH.get_or_init(|| sender);
}
