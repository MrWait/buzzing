use std::collections::HashSet;
use tracing::debug;

use base_db::prelude::{params, params_from_iter, Connection, Result, Row};
use base_db::{cost, placeholder, Pagerize};
use proto::idl::entity;

const FIELD_CHAT: &str = "id, dirty, tpy, status, name, peer_a_id, peer_b_id, owner, member_ids, create_at_ms, update_at_ms, last_message_id, last_message_badge, last_message_pos, admin_ids, avatar, color, description, join_mode, global_mute_until, version";
const FIELD_COUNT: usize = 21;

pub(crate) fn init_tables(conn: &Connection) -> Result<()> {
    conn.execute(
        "CREATE TABLE IF NOT EXISTS chat (
id BIGINT PRIMARY KEY,
dirty INTEGER,
tpy INTEGER,
status INTEGER,
name TEXT DEFAULT '',
peer_a_id BIGINT,
peer_b_id BIGINT,
owner BIGINT,
member_ids TEXT,
create_at_ms BIGINT,
update_at_ms BIGINT,
last_message_id BIGINT,
last_message_badge INTEGER,
last_message_pos INTEGER,
admin_ids TEXT,
avatar TEXT,
color INTEGER,
description TEXT DEFAULT '',
join_mode INTEGER DEFAULT 0,
global_mute_until BIGINT DEFAULT 0,
version BIGINT DEFAULT 0
)",
        (),
    )?;
    // 兼容旧库：补充 chat 实体版本列
    let _ = conn.execute("ALTER TABLE chat ADD COLUMN version BIGINT NOT NULL DEFAULT 0", ());
    Ok(())
}

fn parse_chat(row: &Row) -> Result<(entity::Chat, bool)> {
    let member_ids: String = row.get(8)?;
    let member_ids = serde_json::from_str::<Vec<i64>>(&member_ids).unwrap_or_default();

    let admin_ids: String = row.get(14)?;
    let admin_ids = serde_json::from_str::<Vec<i64>>(&admin_ids).unwrap_or_default();
    let dirty: i32 = row.get(1)?;
    Ok((
        entity::Chat {
            id: row.get(0)?,
            chat_type: row.get(2)?,
            status: row.get(3)?,
            name: row.get(4)?,
            peer_a_id: row.get(5)?,
            peer_b_id: row.get(6)?,
            owner_id: row.get(7)?,
            member_ids,
            create_at_ms: row.get(9)?,
            update_at_ms: row.get(10)?,
            last_message_id: row.get(11)?,
            last_message_badge_count: row.get(12)?,
            last_message_pos: row.get(13)?,
            admin_ids,
            version: row.get(20)?,
            avatar: row.get(15)?,
            color: row.get(16)?,
            description: row.get(17)?,
            join_mode: row.get(18)?,
            global_mute_until: row.get(19)?,
        },
        dirty != 0,
    ))
}

pub(crate) fn chat_batch_save(conn: &mut Connection, entity: &entity::Entity) -> Result<()> {
    cost!("chat_batch_save");
    let tx = conn.transaction()?;
    let query = format!(
        "REPLACE INTO chat ({}) VALUES ({})",
        FIELD_CHAT,
        placeholder(FIELD_COUNT)
    );
    {
        let mut stmt = tx.prepare(&query)?;

        for chat in entity.chats.values() {
            stmt.clear_bindings();
            let member_ids =
                serde_json::to_string::<Vec<i64>>(&chat.member_ids).unwrap_or_default();
            let admin_ids = serde_json::to_string::<Vec<i64>>(&chat.admin_ids).unwrap_or_default();
            let _ = stmt.execute(params![
                chat.id,
                0,
                chat.chat_type,
                chat.status,
                &chat.name,
                chat.peer_a_id,
                chat.peer_b_id,
                chat.owner_id,
                &member_ids,
                chat.create_at_ms,
                chat.update_at_ms,
                chat.last_message_id,
                chat.last_message_badge_count,
                chat.last_message_pos,
                &admin_ids,
                &chat.avatar,
                chat.color,
                &chat.description,
                chat.join_mode,
                chat.global_mute_until,
                chat.version,
            ])?;
        }
    }

    tx.commit()?;
    Ok(())
}

#[allow(dead_code)]
pub(crate) fn chat_save(conn: &Connection, chat: &entity::Chat) -> Result<()> {
    cost!("chat_save");
    let query = format!(
        "REPLACE INTO chat ({}) VALUES ({})",
        FIELD_CHAT,
        placeholder(FIELD_COUNT)
    );
    let mut stmt = conn.prepare(&query)?;
    let member_ids = serde_json::to_string::<Vec<i64>>(&chat.member_ids).unwrap_or_default();
    let admin_ids = serde_json::to_string::<Vec<i64>>(&chat.admin_ids).unwrap_or_default();
    let _ = stmt.query(params![
        chat.id,
        0,
        chat.chat_type,
        chat.status,
        &chat.name,
        chat.peer_a_id,
        chat.peer_b_id,
        chat.owner_id,
        &member_ids,
        chat.create_at_ms,
        chat.update_at_ms,
        chat.last_message_id,
        chat.last_message_badge_count,
        chat.last_message_pos,
        &admin_ids,
        &chat.avatar,
        chat.color,
        &chat.description,
        chat.join_mode,
        chat.global_mute_until,
        chat.version,
    ])?;

    Ok(())
}

pub(crate) fn chat_get_by_ids(
    conn: &Connection,
    origin_ids: &[i64],
    entity: &mut entity::Entity,
) -> Result<HashSet<i64>> {
    cost!("chat_get_by_ids");
    let mut dirty = HashSet::new();
    for ids in Pagerize::new(origin_ids, 99) {
        let query = format!(
            "SELECT {} FROM chat WHERE id IN ({})",
            FIELD_CHAT,
            placeholder(ids.len())
        );
        let mut stmt = conn.prepare(&query)?;
        if let Err(err) = stmt.query(params_from_iter(ids.iter()))
            .and_then(|mut rows| {
                while let Some(row) = rows.next()? {
                    let (chat, d) = parse_chat(&row)?;
                    if d {
                        dirty.insert(chat.id);
                    }
                    entity.chats.insert(chat.id, chat);
                }
                Ok(())
            }) {
                debug!("get chat error: {:?}", err);
            }
    }
    Ok(dirty)
}

#[allow(dead_code)]
pub(crate) fn chat_delete_by_ids(conn: &Connection, origin_ids: &[i64]) -> Result<()> {
    cost!("chat_delete_by_ids");
    for ids in Pagerize::new(origin_ids, 99) {
        let query = format!("DELETE FROM chat WHERE id IN ({})", placeholder(ids.len()));
        let mut stmt = conn.prepare(&query)?;
        let _ = stmt.query(params_from_iter(ids.iter()))?;
    }
    Ok(())
}

#[allow(dead_code)]
pub(crate) fn chat_mark_dirty(conn: &Connection, origin_ids: &[i64]) -> Result<()> {
    cost!("chat_mark_dirty");
    for ids in Pagerize::new(origin_ids, 99) {
        let query = format!(
            "UPDATE chat SET dirty=1 WHERE id IN ({})",
            placeholder(ids.len())
        );
        let mut stmt = conn.prepare(&query)?;
        let _ = stmt.query(params_from_iter(ids.iter()))?;
    }

    Ok(())
}

#[allow(dead_code)]
pub(crate) fn chat_get_dirty(conn: &Connection) -> Result<Vec<entity::EntityId>> {
    cost!("chat_get_dirty");
    let query = "SELECT id FROM chat WHERE dirty=1";
    let mut stmt = conn.prepare(query)?;
    let mut result = Vec::new();
    let _ = stmt.query(params![]).and_then(|mut rows| {
        while let Some(row) = rows.next()? {
            let id: i64 = row.get(0)?;
            result.push(entity::EntityId {
                id,
                r#type: entity::EntityType::Chat as i32,
            });
        }
        Ok(())
    });
    Ok(result)
}
