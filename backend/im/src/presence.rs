use dashmap::mapref::entry;
use loco_rs::{Result, app::AppContext};
use prost::Message;
use sea_orm::{ConnectionTrait, DbBackend, Statement, Value};
use std::collections::HashSet;
use tracing::debug;

use common::{BizHub, PRESENCE_SUBSCRIBERS, UserBrief, common_error, pb_decode, rid};
use proto::idl::{command::Command, entity, error::ErrorCode, presence};

/// Update own presence status (called from client or gateway on connect/disconnect)
pub(crate) async fn update_presence_internal(
    ctx: &AppContext,
    user_id: i64,
    status: i32,
    status_text: &str,
) -> Result<()> {
    let now = common::time::current_ms() as i64;
    let last_seen = if status == 0 { Some(now) } else { None };

    ctx.db.execute(Statement::from_sql_and_values(
        DbBackend::Postgres,
        r#"
        INSERT INTO user_presence (user_id, status, status_text, last_seen_at, updated_at)
        VALUES ($1, $2, $3, $4, NOW())
        ON CONFLICT (user_id) DO UPDATE SET
            status = EXCLUDED.status,
            status_text = EXCLUDED.status_text,
            last_seen_at = COALESCE(EXCLUDED.last_seen_at, user_presence.last_seen_at),
            updated_at = NOW()
        "#,
        vec![
            user_id.into(),
            status.into(),
            status_text.into(),
            last_seen.map(|t| common::time::date_time(t).into())
                .unwrap_or(Value::from(None::<sea_orm::prelude::DateTimeWithTimeZone>)),
        ],
    )).await.map_err(|e| common_error(&format!("update presence error: {e}")))?;

    // Push to subscribers
    if let Some(watchers) = PRESENCE_SUBSCRIBERS.get(&user_id) {
        let watcher_ids: Vec<i64> = watchers.iter().copied().collect();
        if !watcher_ids.is_empty() {
            let push = presence::PushPresence {
                user_id,
                status,
                status_text: status_text.to_string(),
                last_seen_ms: last_seen.unwrap_or(0),
            };
            if let Ok(hub) = BizHub::get() {
                hub.gateway
                    .send_packet_to_user(
                        ctx,
                        &watcher_ids,
                        rid(),
                        Command::PushPresence,
                        push.encode_to_vec(),
                        false,
                    )
                    .await?;
            }
        }
    }

    Ok(())
}

pub(crate) async fn handle_presence_update(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<presence::PresenceUpdateRequest>(&packet.payload)?;
    debug!("presence update, req: {req:?}");

    update_presence_internal(ctx, brief.id, req.status, &req.status_text).await?;

    Ok((ErrorCode::Ok as i32, presence::PresenceUpdateResponse::default().encode_to_vec()))
}

pub(crate) async fn handle_presence_subscribe(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<presence::PresenceSubscribeRequest>(&packet.payload)?;
    debug!("presence subscribe, req: {req:?}");

    for target_id in &req.user_ids {
        match PRESENCE_SUBSCRIBERS.entry(*target_id) {
            entry::Entry::Occupied(mut e) => {
                e.get_mut().insert(brief.id);
            }
            entry::Entry::Vacant(e) => {
                let mut set = HashSet::new();
                set.insert(brief.id);
                e.insert(set);
            }
        }
    }

    Ok((ErrorCode::Ok as i32, presence::PresenceSubscribeResponse::default().encode_to_vec()))
}
