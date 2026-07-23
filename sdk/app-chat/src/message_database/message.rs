use prost::Message;
use std::collections::HashSet;

use base_db::prelude::{params, params_from_iter, Connection, Error, Result, Row};
use base_db::{cost, placeholder, Pagerize};
use proto::idl::entity;

const FIELD_MESSAGE: &str = "id, dirty, tpy, chat_id, from_id, pos, badge_count, status, client_id, create_time_ms, update_time_ms, at_user_ids, content, summary, reaction, readstate";
const FIELD_COUNT: usize = 16;

pub(crate) fn init_tables(conn: &Connection) -> Result<()> {
    conn.execute(
        "CREATE TABLE IF NOT EXISTS message (
id BIGINT PRIMARY KEY,
dirty INTEGER,
tpy INTEGER,
chat_id BIGINT,
from_id BIGINT,
pos INTEGER,
badge_count INTEGER,
status INTEGER,
client_id BIGINT,
create_time_ms BIGINT,
update_time_ms BIGINT,
at_user_ids TEXT,
content BLOB,
summary TEXT,
reaction BLOB,
readstate BLOB
)",
        (),
    )?;
    Ok(())
}

fn parse_message(row: &Row) -> Result<(entity::Message, bool)> {
    let at_user_ids: String = row.get(11)?;
    let at_user_ids = serde_json::from_str::<Vec<i64>>(&at_user_ids).unwrap_or_default();
    let dirty: i32 = row.get(1)?;
    let dirty = dirty != 0;

    let reactions: Vec<u8> = row.get(14)?;
    let reactions = entity::Reactions::decode(reactions.as_slice())
        .ok()
        .unwrap_or_default()
        .reactions;
    let read_state: Vec<u8> = row.get(15)?;
    let read_state =
        Some(entity::ReadState::decode(read_state.as_slice()).map_err(|_| Error::InvalidQuery)?);

    Ok((
        entity::Message {
            id: row.get(0)?,
            tpy: row.get(2)?,
            chat_id: row.get(3)?,
            from_id: row.get(4)?,
            pos: row.get(5)?,
            badge_count: row.get(6)?,
            status: row.get(7)?,
            client_id: row.get(8)?,
            create_time_ms: row.get(9)?,
            update_time_ms: row.get(10)?,
            at_user_ids,
            content: row.get(12)?,
            summary: row.get(13)?,
            version: 0,
            reactions,
            read_state,
            ref_message_id: 0,
            ref_data: None,
            // TODO: add column in sql
            thread_root_id: 0,
        },
        dirty,
    ))
}

pub(crate) fn message_batch_save(conn: &mut Connection, entity: &entity::Entity) -> Result<()> {
    cost!("message_batch_save");
    let tx = conn.transaction()?;
    let query = format!(
        "REPLACE INTO message ({}) VALUES ({})",
        FIELD_MESSAGE,
        placeholder(FIELD_COUNT)
    );
    {
        let mut stmt = tx.prepare(&query)?;

        for message in entity.messages.values() {
            stmt.clear_bindings();
            let at_user_ids =
                serde_json::to_string::<Vec<i64>>(&message.at_user_ids).unwrap_or_default();
            let reactions = entity::Reactions {
                reactions: message.reactions.clone(),
            }
            .encode_to_vec();
            let read_state = message
                .read_state
                .as_ref()
                .and_then(|rs| Some(rs.encode_to_vec()))
                .unwrap_or_default();
            let _ = stmt.execute(params![
                message.id,
                0,
                message.tpy,
                message.chat_id,
                message.from_id,
                message.pos,
                message.badge_count,
                message.status,
                message.client_id,
                message.create_time_ms,
                message.update_time_ms,
                &at_user_ids,
                &message.content,
                &message.summary,
                &reactions,
                &read_state,
            ])?;
        }
    }

    tx.commit()?;
    Ok(())
}

pub(crate) fn message_save(conn: &Connection, message: &entity::Message) -> Result<()> {
    cost!("message_save");
    let query = format!(
        "REPLACE INTO message ({}) VALUES ({})",
        FIELD_MESSAGE,
        placeholder(FIELD_COUNT)
    );
    let mut stmt = conn.prepare(&query)?;
    let at_user_ids = serde_json::to_string::<Vec<i64>>(&message.at_user_ids).unwrap_or_default();
    let reactions = entity::Reactions {
        reactions: message.reactions.clone(),
    }
    .encode_to_vec();
    let read_state = message
        .read_state
        .as_ref()
        .and_then(|rs| Some(rs.encode_to_vec()))
        .unwrap_or_default();

    let _ = stmt.query(params![
        message.id,
        0,
        message.tpy,
        message.chat_id,
        message.from_id,
        message.pos,
        message.badge_count,
        message.status,
        message.client_id,
        message.create_time_ms,
        message.update_time_ms,
        &at_user_ids,
        &message.content,
        &message.summary,
        &reactions,
        &read_state,
    ])?;

    Ok(())
}

pub(crate) fn message_get_by_ids(
    conn: &Connection,
    origin_ids: &[i64],
    entity: &mut entity::Entity,
) -> Result<HashSet<i64>> {
    cost!("message_get_by_ids");
    let mut dirty = HashSet::new();
    for ids in Pagerize::new(origin_ids, 99) {
        let query = format!(
            "SELECT {} FROM message WHERE id IN ({})",
            FIELD_MESSAGE,
            placeholder(ids.len())
        );
        let mut stmt = conn.prepare(&query)?;
        let _ = stmt
            .query(params_from_iter(ids.iter()))
            .and_then(|mut rows| {
                while let Some(row) = rows.next()? {
                    let (message, d) = parse_message(&row)?;
                    if d {
                        dirty.insert(message.id);
                    }
                    entity.messages.insert(message.id, message);
                }
                Ok(())
            })?;
    }
    Ok(dirty)
}

pub(crate) fn message_get_by_id(
    conn: &Connection,
    id: i64,
) -> Result<Option<(entity::Message, bool)>> {
    cost!("message_get_by_ids");
    let query = format!("SELECT {} FROM message WHERE id=?1", FIELD_MESSAGE,);
    let mut stmt = conn.prepare(&query)?;
    let mut result = None;
    let _ = stmt.query(params![id]).and_then(|mut rows| {
        if let Some(row) = rows.next()? {
            let (message, d) = parse_message(&row)?;
            result = Some((message, d));
        }
        Ok(())
    })?;
    Ok(result)
}

pub(crate) fn message_get_by_range(
    conn: &Connection,
    entity: &mut entity::Entity,
    chat_id: i64,
    low: i32,
    high: i32,
) -> Result<HashSet<i64>> {
    let mut dirty = HashSet::new();
    let query = format!(
        "SELECT {} FROM message WHERE chat_id=?1 AND pos>=?2 AND pos<=?3",
        FIELD_MESSAGE
    );
    let mut stmt = conn.prepare_cached(&query)?;
    let _ = stmt
        .query(params![chat_id, low, high])
        .and_then(|mut rows| {
            while let Some(row) = rows.next()? {
                let (message, d) = parse_message(&row)?;
                if d {
                    dirty.insert(message.id);
                }
                entity.messages.insert(message.id, message);
            }
            Ok(())
        });
    Ok(dirty)
}

#[allow(dead_code)]
pub(crate) fn message_delete_by_ids(conn: &Connection, origin_ids: &[i64]) -> Result<()> {
    cost!("message_delete_by_ids");
    for ids in Pagerize::new(origin_ids, 99) {
        let query = format!(
            "DELETE FROM message WHERE id IN ({})",
            placeholder(ids.len())
        );
        let mut stmt = conn.prepare(&query)?;
        let _ = stmt.query(params_from_iter(ids.iter()))?;
    }
    Ok(())
}

pub(crate) fn message_get_all_stash(conn: &Connection) -> Result<HashSet<i64>> {
    let mut ids = HashSet::new();
    let query = format!("SELECT id FROM message WHERE status=5");
    let mut stmt = conn.prepare(&query)?;
    let _ = stmt.query(params![]).and_then(|mut rows| {
        while let Some(row) = rows.next()? {
            let id: i64 = row.get(0)?;
            ids.insert(id);
        }
        Ok(())
    });
    Ok(ids)
}
