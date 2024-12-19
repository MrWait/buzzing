use anyhow::anyhow;
use std::sync::atomic::Ordering;

use super::ActionHandler;
use crate::Metrics;
use crate::config::*;
use crate::database::*;
use crate::prelude::*;

pub(crate) fn bench(
    config: &Config,
    tx: UnboundedSender<Event>,
) -> Result<Arc<Box<dyn ActionHandler>>> {
    let chat = config
        .chat
        .get(&config.scene)
        .ok_or(anyhow!("config mismatch"))?;
    let tenant_id = config.tenant;
    let action_count = chat.count;
    for i in 0..chat.count {
        let host = config.host.clone();
        let appversion = config.appversion.clone();
        let device = config.device.clone();
        let main = chat.base + (i * chat.size) as i64;
        let mut p = entity::Packet::default();
        let mut req = idl::chat::CreateChatRequest::default();
        req.chat = if chat.p2p {
            Some(entity::Chat {
                chat_type: entity::ChatType::ChatP2p as i32,
                peer_a_id: main,
                peer_b_id: main + 1,
                ..Default::default()
            })
        } else {
            let member_ids = (main..(main + chat.size as i64)).collect::<Vec<_>>();
            Some(entity::Chat {
                chat_type: entity::ChatType::ChatGroup as i32,
                owner_id: main,
                member_ids,
                ..Default::default()
            })
        };
        p.payload = req.encode_to_vec();
        p.cmd = Command::ChatCreate as i32;
        let tx1 = tx.clone();
        let chat_clone = chat.clone();
        let token = config.token.clone();
        tokio::spawn(async move {
            let user = UserContext {
                event_ch: tx1,
                user_id: main,
                token,
                account_id: main,
                tenant_id,
                host,
                appversion,
                device,
                task: Task::TaskChatCreate(chat_clone, p),
            };
            let _ = crate::websocket::user_task(user).await;
        });
    }

    let conn = init_db(&config.database)?;
    let handler = ChatHandler {
        inner: Mutex2::new(Inner {
            count: action_count,
            current_count: 0,
            conn: DbConn(conn),
            scene: config.scene.clone(),
        }),
    };
    Ok(Arc::new(Box::new(handler)))
}

#[allow(dead_code)]
struct Inner {
    pub count: i32,
    pub current_count: i32,
    pub conn: DbConn,
    pub scene: String,
}

pub struct ChatHandler {
    inner: Mutex2<Inner>,
}

impl ActionHandler for ChatHandler {
    fn init(&self) {}

    fn count(&self) -> i32 {
        0
    }

    fn finish(&self) -> bool {
        false
    }

    fn ack_handle(&self, cmd: i32, packet: entity::Packet, metric: &Metrics) {
        if cmd != Command::ChatCreate as i32 {
            return;
        }
        let mut inner = self.inner.lock();
        inner.current_count += 1;
        if packet.code == idl::error::ErrorCode::Ok as i32 {
            metric.ack.fetch_add(1, Ordering::Relaxed);
            if let Ok(mut resp) = idl::chat::CreateChatResponse::decode(packet.payload.as_slice()) {
                println!("create chat ok: {:?}", resp);
                if let Some(chat) = resp
                    .entities
                    .get_or_insert_default()
                    .chats
                    .get(&resp.chat_id)
                {
                    println!("save chat");
                    if let Err(err) = chat_save(inner.conn.inner(), &inner.scene, &chat) {
                        println!("write record error: {:?}", err);
                    }
                }
            }
        } else {
            metric.error.fetch_add(1, Ordering::Relaxed);
            println!(
                "create chat error, sid: {:?}, status: {:?}",
                packet.rid, packet.code
            );
        }
    }
}
