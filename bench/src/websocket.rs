use crate::config::*;
use crate::prelude::*;

use futures_util::SinkExt;
use futures_util::StreamExt;
use prost::Message as _;
use std::sync::atomic::{AtomicBool, Ordering};
use std::time::Instant;
use tokio_tungstenite::connect_async;
use tokio_tungstenite::tungstenite::client::IntoClientRequest;
use tungstenite::protocol::Message;

pub(crate) async fn user_task(user: UserContext) -> Result<()> {
    let interval = user.task.interval();
    let mut repeat: i32 = 0;
    let total_count = user.task.repeat();
    let event_ch = user.event_ch.clone();
    let user_id = user.user_id;
    let user = Arc::new(Mutex2::new(user));

    let _ = event_ch.send(Event::Start);

    let (tx, mut rx) = unbounded_channel::<UserCommand>();
    let tx1 = tx.clone();

    loop {
        let request = {
            let user = user.lock();
            let mut req = user.host.clone().into_client_request().unwrap();
            req.headers_mut().insert(
                "x-buzzing-tenant",
                user.tenant_id.to_string().parse().unwrap(),
            );
            req.headers_mut().insert(
                "x-buzzing-userid",
                user.user_id.to_string().parse().unwrap(),
            );
            req.headers_mut()
                .insert("x-buzzing-token", user.token.to_string().parse().unwrap());
            req.headers_mut().insert(
                "x-buzzing-accountid",
                user.account_id.to_string().parse().unwrap(),
            );
            req
        };

        let (mut sink, mut stream) = match connect_async(request).await {
            Ok(conn) => conn.0.split(),
            Err(err) => {
                println!("conn error: {:?}", err);
                tokio::time::sleep(Duration::from_millis(100)).await;
                continue;
            }
        };
        let _ = event_ch.send(Event::Connection(user_id, true));

        let waited: Mutex<HashMap<i64, (i32, Instant)>> = Mutex::new(HashMap::new());
        let running = AtomicBool::new(true);

        while running.load(Ordering::Relaxed) {
            tokio::select! {
                _ = async {
                    let msg = stream.next().await;
                    match msg {
                        Some(Ok(Message::Binary(data))) => {
                            if let Ok(packet) = entity::Packet::decode(data.as_slice()) {
                                let _ = event_ch.send(Event::RecvPacket);
                                let mut wait = waited.lock().await;
                                if let Some((cmd, ins)) = wait.remove(&packet.rid) {
                                    let _ = event_ch.send(Event::ActionAck(cmd, ins.elapsed().as_millis() as i64, packet));
                                }
                            }
                        }
                        Some(Ok(_)) => {
                            println!("recv unknown cmd: {:?}", msg);
                        }
                        Some(Err(_)) | None => {
                            println!("recv error, disconnect");
                            running.store(false, Ordering::Relaxed);
                        }
                    }
                } => {}
                _ = async {
                    let cmd = rx.recv().await;
                    if let Some(cmd) = cmd {
                        match cmd {
                            UserCommand::AsyncPacket(packet) => {
                                // println!("send async packet: {:?}", packet);
                                if let Ok(_) = sink.send(Message::Binary(packet.encode_to_vec())).await {
                                    let _ = event_ch.send(Event::SendPacket);
                                    let mut wait = waited.lock().await;
                                    wait.insert(packet.rid, (packet.cmd, Instant::now()));
                                }
                            }
                            UserCommand::Heartbeat => {},
                            UserCommand::Packet(packet) => {
                                let _ = sink.send(Message::Binary(packet.encode_to_vec())).await;
                                let _ = event_ch.send(Event::SendPacket);
                            }
                        }
                    }
                } => {}
                _ = async {
                    tokio::time::sleep(Duration::from_millis(interval as u64)).await;
                    if repeat < total_count {
                        let u = user.lock();
                        if u.task.send(&tx1) {
                            repeat += 1;
                            let _ = event_ch.send(Event::ActionStart);
                        }
                    }
                } => {}
            }
        }

        let _ = event_ch.send(Event::Connection(user_id, false));
    }
}
