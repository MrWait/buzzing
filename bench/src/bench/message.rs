use crate::Metrics;
use crate::config::*;
use crate::database::*;
use crate::prelude::*;
use std::sync::atomic::Ordering;

use super::ActionHandler;
const TEXT: &str = "
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;
a quick fox jump a brown lazy dog;";

pub(crate) fn bench(
    config: &Config,
    tx: UnboundedSender<Event>,
) -> Result<Arc<Box<dyn ActionHandler>>> {
    let set = config
        .message
        .get(&config.scene)
        .ok_or(anyhow::anyhow!("config mismatch"))?;

    let tenant_id = config.tenant;
    let conn = init_db(&config.database)?;
    let chats = chat_get_all(&conn, &config.scene)?;
    let mut user_ids = Vec::new();

    let mut count = 0;
    for c in chats.iter() {
        let chat_id = c.id;
        if set.p2p {
            user_ids.push((c.peer_a_id, true, chat_id));
            if set.peer > 1 {
                user_ids.push((c.peer_b_id, true, chat_id));
            } else {
                user_ids.push((c.peer_b_id, false, chat_id));
            }
        } else {
            user_ids.extend(
                c.member_ids[0..(set.peer as usize)]
                    .iter()
                    .map(|id| (*id, true, chat_id)),
            );
            user_ids.extend(
                c.member_ids[(set.peer as usize)..]
                    .iter()
                    .map(|id| (*id, false, chat_id)),
            );
        }
        count += 1;
        if count == set.count {
            break;
        }
    }
    println!("message bench suite: {:?}", user_ids);
    let mut p = entity::Packet::default();
    let mut req = idl::message::SendMessageRequest::default();
    let txt = entity::MessageText {
        text: TEXT.to_string(),
    };
    p.cmd = Command::MessageSend as i32;
    req.message = Some(entity::Message {
        tpy: entity::MessageType::Text as i32,
        summary: TEXT.to_string(),
        content: txt.encode_to_vec(),
        ..Default::default()
    });

    for (id, main, chat_id) in user_ids.iter() {
        if let Some(ref mut msg) = req.message {
            msg.chat_id = *chat_id;
        }
        p.payload = req.encode_to_vec();

        let host = config.host.clone();
        let appversion = config.appversion.clone();
        let device = config.device.clone();

        let tx1 = tx.clone();
        let set_clone = set.clone();
        let token = config.token.clone();
        let pkt = p.clone();
        let user_id = *id;
        let main = *main;
        tokio::spawn(async move {
            let user = UserContext {
                event_ch: tx1,
                user_id,
                token,
                account_id: user_id,
                tenant_id,
                host,
                appversion,
                device,
                task: if main {
                    Task::TaskMessageSend(set_clone, pkt)
                } else {
                    Task::TaskSlave
                },
            };
            let _ = crate::websocket::user_task(user).await;
        });
    }

    Ok(Arc::new(Box::new(MessageHandler {
        inner: Mutex2::new(Inner {
            count: 0,
            current: 0,
            scene: config.scene.clone(),
        }),
    })))
}

struct Inner {
    pub count: i32,
    pub current: i32,
    pub scene: String,
}

pub struct MessageHandler {
    inner: Mutex2<Inner>,
}

impl ActionHandler for MessageHandler {
    fn init(&self) {}

    fn count(&self) -> i32 {
        let inner = self.inner.lock();
        inner.count
    }

    fn finish(&self) -> bool {
        false
    }

    fn ack_handle(&self, cmd: i32, packet: entity::Packet, metric: &Metrics) {
        if cmd != Command::MessageSend as i32 {
            return;
        }
        let mut inner = self.inner.lock();
        inner.current += 1;
        if packet.code == idl::error::ErrorCode::Ok as i32 {
            metric.ack.fetch_add(1, Ordering::Relaxed);
        } else {
            metric.error.fetch_add(1, Ordering::Relaxed);
            println!(
                "send message error, sid: {:?}, status: {:?}",
                packet.rid, packet.code
            );
        }
    }
}
