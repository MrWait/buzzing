use loco_rs::{Error, Result, app::AppContext};
use prost::Message;
use sea_orm::{ConnectionTrait, DbBackend, Statement};
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::Mutex;
use tracing::{debug, error};

use common::time::current_ms;
use common::{UserBrief, common_error, id_gen, pb_decode};
use proto::idl::{command::Command, entity, error::ErrorCode, message, timer};

/// Schedule a message for future delivery (M5-E.7)
pub(crate) async fn schedule_message(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<timer::ScheduleMessageRequest>(&packet.payload)?;
    let now_ms = current_ms() as i64;

    if req.send_at_ms <= now_ms {
        return Err(common_error("send_at_ms must be in the future"));
    }

    let schedule_id = id_gen(None);

    ctx.db
        .execute(Statement::from_sql_and_values(
            DbBackend::Postgres,
            "INSERT INTO scheduled_messages (id, user_id, chat_id, client_id, tpy, content, send_at_ms, status, created_at, updated_at) \
             VALUES ($1, $2, $3, $4, $5, $6, $7, 0, NOW(), NOW())",
            vec![
                schedule_id.into(),
                brief.id.into(),
                req.chat_id.into(),
                req.client_id.into(),
                (req.tpy as i16).into(),
                req.content.into(),
                req.send_at_ms.into(),
            ],
        ))
        .await
        .map_err(|e| common_error(&format!("insert scheduled message failed: {e}")))?;

    let resp = timer::ScheduleMessageResponse {
        schedule_id,
        schedule_at_ms: req.send_at_ms,
    };
    Ok((ErrorCode::Ok as i32, resp.encode_to_vec()))
}

/// Cancel a scheduled message (M5-E.8)
pub(crate) async fn cancel_schedule(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<timer::CancelScheduleRequest>(&packet.payload)?;

    let result = ctx
        .db
        .execute(Statement::from_sql_and_values(
            DbBackend::Postgres,
            "UPDATE scheduled_messages SET status = 2, updated_at = NOW() WHERE id = $1 AND user_id = $2 AND status = 0",
            vec![req.schedule_id.into(), brief.id.into()],
        ))
        .await
        .map_err(|e| common_error(&format!("cancel schedule failed: {e}")))?;

    if result.rows_affected() == 0 {
        return Err(common_error("scheduled message not found or already sent"));
    }

    let resp = timer::CancelScheduleResponse {};
    Ok((ErrorCode::Ok as i32, resp.encode_to_vec()))
}

/// Get user's scheduled messages with pagination (M5-E.9)
pub(crate) async fn get_scheduled_messages(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<timer::GetScheduledMessagesRequest>(&packet.payload)?;
    let page = req.page.max(1);
    let page_size = req.page_size.clamp(1, 100);
    let offset = ((page - 1) * page_size) as i64;

    let rows = ctx
        .db
        .query_all(Statement::from_sql_and_values(
            DbBackend::Postgres,
            "SELECT id, chat_id, send_at_ms, tpy, content, status, \
             EXTRACT(EPOCH FROM created_at)::BIGINT * 1000 as created_at_ms \
             FROM scheduled_messages WHERE user_id = $1 \
             ORDER BY send_at_ms DESC LIMIT $2 OFFSET $3",
            vec![brief.id.into(), (page_size as i64).into(), offset.into()],
        ))
        .await
        .map_err(|e| common_error(&format!("query scheduled messages failed: {e}")))?;

    let total: i64 = ctx
        .db
        .query_one(Statement::from_sql_and_values(
            DbBackend::Postgres,
            "SELECT COUNT(*) as cnt FROM scheduled_messages WHERE user_id = $1",
            vec![brief.id.into()],
        ))
        .await
        .map_err(|e| common_error(&format!("count scheduled messages failed: {e}")))?
        .and_then(|r| r.try_get_by::<i64, _>("cnt").ok())
        .unwrap_or(0);

    let mut resp = timer::GetScheduledMessagesResponse::default();
    resp.total = total as i32;
    for row in rows {
        let id: i64 = row.try_get_by("id").unwrap_or(0);
        let chat_id: i64 = row.try_get_by("chat_id").unwrap_or(0);
        let send_at_ms: i64 = row.try_get_by("send_at_ms").unwrap_or(0);
        let tpy: i16 = row.try_get_by("tpy").unwrap_or(0);
        let content: Vec<u8> = row.try_get_by("content").unwrap_or_default();
        let status: i16 = row.try_get_by("status").unwrap_or(0);
        let created_at_ms: i64 = row.try_get_by("created_at_ms").unwrap_or(0);

        resp.messages.push(timer::ScheduledMessage {
            id,
            chat_id,
            send_at_ms,
            tpy: tpy as i32,
            content,
            status: status as i32,
            created_at_ms,
        });
    }

    Ok((ErrorCode::Ok as i32, resp.encode_to_vec()))
}

/// Shared scheduler state
pub(crate) struct SchedulerService {
    pub ctx: Arc<Mutex<Option<AppContext>>>,
}

impl SchedulerService {
    pub fn new() -> Self {
        Self {
            ctx: Arc::new(Mutex::new(None)),
        }
    }

    pub async fn set_ctx(&self, ctx: AppContext) {
        let mut guard = self.ctx.lock().await;
        *guard = Some(ctx);
    }

    /// Background loop: poll due messages every second and send them (M5-E.10)
    pub async fn run(&self) {
        let mut interval = tokio::time::interval(Duration::from_secs(1));
        loop {
            interval.tick().await;
            let guard = self.ctx.lock().await;
            let ctx = match guard.as_ref() {
                Some(c) => c.clone(),
                None => continue,
            };
            drop(guard);

            let now_ms = current_ms() as i64;
            let due = match ctx
                .db
                .query_all(Statement::from_sql_and_values(
                    DbBackend::Postgres,
                    "SELECT id, user_id, chat_id, tpy, content FROM scheduled_messages \
                     WHERE send_at_ms <= $1 AND status = 0 ORDER BY send_at_ms ASC LIMIT 100",
                    vec![now_ms.into()],
                ))
                .await
            {
                Ok(rows) => rows,
                Err(e) => {
                    error!("scheduler query due messages error: {e}");
                    continue;
                }
            };

            for row in due {
                let id: i64 = row.try_get_by("id").unwrap_or(0);
                let user_id: i64 = row.try_get_by("user_id").unwrap_or(0);
                let chat_id: i64 = row.try_get_by("chat_id").unwrap_or(0);
                let tpy: i16 = row.try_get_by("tpy").unwrap_or(0);
                let content: Vec<u8> = row.try_get_by("content").unwrap_or_default();

                // Build a fake UserBrief for the message sender
                let brief = UserBrief {
                    id: user_id,
                    ..Default::default()
                };

                // Construct a send-message packet
                let send_req = message::SendMessageRequest {
                    client_id: id,
                    message: Some(entity::Message {
                        chat_id,
                        tpy: tpy as i32,
                        content: content.clone(),
                        ..Default::default()
                    }),
                };

                let packet = entity::Packet {
                    cmd: Command::MessageSend as i32,
                    payload: send_req.encode_to_vec(),
                    ..Default::default()
                };

                match crate::message::message_send(&ctx, &brief, &packet, false).await {
                    Ok(_) => {
                        let _ = ctx
                            .db
                            .execute(Statement::from_sql_and_values(
                                DbBackend::Postgres,
                                "UPDATE scheduled_messages SET status = 1, updated_at = NOW() WHERE id = $1",
                                vec![id.into()],
                            ))
                            .await;
                    }
                    Err(e) => {
                        error!("scheduler send message {} failed: {e}", id);
                    }
                }
            }
        }
    }
}
