pub mod chat;
pub mod message;

use crate::Metrics;
use crate::config::*;
use crate::prelude::*;
use std::sync::atomic::Ordering;

pub(crate) fn bench(
    config: &crate::config::Config,
    tx: UnboundedSender<Event>,
) -> Result<Arc<Box<dyn ActionHandler>>> {
    match config.target {
        _ if config.target == "message" => message::bench(config, tx),
        _ if config.target == "chat" => chat::bench(config, tx),
        _ => Err(anyhow::anyhow!("target not support")),
    }
}

#[allow(dead_code)]
pub trait ActionHandler: Send + Sync {
    fn init(&self);
    fn handle(&self, event: Event, metric: &Metrics) -> i32 {
        match event {
            Event::Start => metric.start.fetch_add(1, Ordering::Relaxed),
            Event::Logined => metric.logined.fetch_add(1, Ordering::Relaxed),
            Event::Connection(_user_id, conn) => {
                metric
                    .connect
                    .fetch_add(if conn { 1 } else { -1 }, Ordering::Relaxed);
                0
            }
            Event::ActionStart => metric.action.fetch_add(1, Ordering::Relaxed),
            Event::SendPacket => metric.send.fetch_add(1, Ordering::Relaxed),
            Event::RecvPacket => metric.recv.fetch_add(1, Ordering::Relaxed),
            Event::ActionAck(cmd, _ins, packet) => {
                self.ack_handle(cmd, packet, metric);
                0
            }
        }
    }

    fn ack_handle(&self, cmd: i32, packet: entity::Packet, metric: &Metrics);

    fn count(&self) -> i32;

    fn finish(&self) -> bool;
}
