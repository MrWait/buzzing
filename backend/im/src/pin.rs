use loco_rs::{Result, app::AppContext};
use prost::Message;
use sea_orm::{ConnectionTrait, DbBackend, Statement};
use tracing::debug;

use common::{UserBrief, common_error, id_gen, pb_decode};
use proto::idl::{entity, error::ErrorCode, pin};

pub(crate) async fn pin_message(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<pin::PinMessageRequest>(&packet.payload)?;
    debug!("pin message, req: {req:?}");
    let mut resp = pin::PinMessageResponse::default();

    let context = super::chat::chat_cache_get(ctx, req.chat_id).await?;
    let member_ids;
    {
        let c = context.read().await;
        if c.chat.r#type == entity::ChatType::ChatP2p as i16 {
            return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
        }
        let is_owner = c.chat.owner_id == brief.id;
        let is_admin = c.chat.admin_ids.contains(&brief.id);
        if !is_owner && !is_admin {
            return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
        }
        member_ids = c.cmv.ids();
    }

    let pin_id = id_gen(None);
    ctx.db.execute(Statement::from_sql_and_values(
        DbBackend::Postgres,
        r#"
        INSERT INTO message_pins (id, chat_id, message_id, pinned_by)
        VALUES ($1, $2, $3, $4)
        ON CONFLICT (chat_id, message_id) DO NOTHING
        "#,
        vec![
            pin_id.into(),
            req.chat_id.into(),
            req.message_id.into(),
            brief.id.into(),
        ],
    )).await.map_err(|e| common_error(&format!("pin message error: {e}")))?;

    let e = resp.entities.get_or_insert_default();
    let c = context.read().await;
    e.chats.insert(req.chat_id, c.get_entity());

    let _ = crate::feed::push_entity(ctx, &member_ids, resp.entities.clone().unwrap_or_default()).await;

    debug!("pin message done");
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

pub(crate) async fn unpin_message(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<pin::UnpinMessageRequest>(&packet.payload)?;
    debug!("unpin message, req: {req:?}");
    let mut resp = pin::UnpinMessageResponse::default();

    let context = super::chat::chat_cache_get(ctx, req.chat_id).await?;
    let member_ids;
    {
        let c = context.read().await;
        if c.chat.r#type == entity::ChatType::ChatP2p as i16 {
            return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
        }
        let is_owner = c.chat.owner_id == brief.id;
        let is_admin = c.chat.admin_ids.contains(&brief.id);
        if !is_owner && !is_admin {
            return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
        }
        member_ids = c.cmv.ids();
    }

    ctx.db.execute(Statement::from_sql_and_values(
        DbBackend::Postgres,
        "DELETE FROM message_pins WHERE chat_id = $1 AND message_id = $2",
        vec![req.chat_id.into(), req.message_id.into()],
    )).await.map_err(|e| common_error(&format!("unpin message error: {e}")))?;

    let e = resp.entities.get_or_insert_default();
    let c = context.read().await;
    e.chats.insert(req.chat_id, c.get_entity());

    let _ = crate::feed::push_entity(ctx, &member_ids, resp.entities.clone().unwrap_or_default()).await;

    debug!("unpin message done");
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

pub(crate) async fn get_pinned_messages(
    ctx: &AppContext,
    _brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<pin::GetPinnedMessagesRequest>(&packet.payload)?;
    debug!("get pinned messages, req: {req:?}");
    let mut resp = pin::GetPinnedMessagesResponse::default();

    let rows = ctx.db.query_all(Statement::from_sql_and_values(
        DbBackend::Postgres,
        r#"
        SELECT m.id, m.chat_id, m.from_id, m.r#type AS msg_type, m.content, m.summary,
               m.status, m.created_at, m.updated_at, m.at_user_ids, m.thread_root_id
        FROM message_pins mp
        JOIN messages m ON m.id = mp.message_id
        WHERE mp.chat_id = $1
        ORDER BY mp.id DESC
        "#,
        vec![req.chat_id.into()],
    )).await.map_err(|e| common_error(&format!("get pinned messages error: {e}")))?;

    for row in rows {
        let msg = entity::Message {
            id: row.try_get("", "id").unwrap_or(0),
            chat_id: row.try_get("", "chat_id").unwrap_or(0),
            from_id: row.try_get("", "from_id").unwrap_or(0),
            tpy: row.try_get::<i16>("", "msg_type").unwrap_or(0) as i32,
            content: row.try_get::<Vec<u8>>("", "content").unwrap_or_default(),
            summary: row.try_get("", "summary").unwrap_or_default(),
            status: row.try_get::<i16>("", "status").unwrap_or(0) as i32,
            at_user_ids: row.try_get("", "at_user_ids").unwrap_or_default(),
            thread_root_id: row.try_get("", "thread_root_id").unwrap_or(0),
            create_time_ms: row.try_get::<chrono::DateTime<chrono::Utc>>("", "created_at")
                .ok().map(|t| t.timestamp_millis()).unwrap_or(0),
            update_time_ms: row.try_get::<chrono::DateTime<chrono::Utc>>("", "updated_at")
                .ok().map(|t| t.timestamp_millis()).unwrap_or(0),
            ..Default::default()
        };
        resp.messages.push(msg);
    }

    debug!("get pinned messages done, count: {}", resp.messages.len());
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}
