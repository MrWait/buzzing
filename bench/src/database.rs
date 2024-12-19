use anyhow::Result;
use rusqlite::*;

use crate::idl::entity;

pub struct DbConn(pub Connection);

#[allow(dead_code)]
impl DbConn {
    pub fn new(conn: Connection) -> Self {
        Self(conn)
    }

    pub fn inner(&self) -> &Connection {
        &self.0
    }
    pub fn inner_mut(&mut self) -> &mut Connection {
        &mut self.0
    }
}
unsafe impl Sync for DbConn {}
unsafe impl Send for DbConn {}

const PLACE_HOLHDER: &str = "  ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9,?10,?11,?12,?13,?14,?15,?16,?17,?18,?19,?20,?21,?22,?23,?24,?25,?26,?27,?28,?29,?30,?31,?32,?33,?34,?35,?36,?37,?38,?39,?40,?41,?42,?43,?44,?45,?46,?47,?48,?49,?50,?51,?52,?53,?54,?55,?56,?57,?58,?59,?60,?61,?62,?63,?64,?65,?66,?67,?68,?69,?70,?71,?72,?73,?74,?75,?76,?77,?78,?79,?80,?81,?82,?83,?84,?85,?86,?87,?88,?89,?90,?91,?92,?93,?94,?95,?96,?97,?98,?99,?100";

// only gen within 99
pub fn placeholder(count: usize) -> &'static str {
    assert!(count < 100);
    &PLACE_HOLHDER[..(count * 4)]
}

pub fn init_db(path: &str) -> Result<Connection> {
    let mut conn = Connection::open(&path)?;
    conn.execute_batch("PRAGMA synchronous=NORMAL")?;
    conn.execute_batch("PRAGMA journal_mode=WAL")?;
    init_tables(&mut conn, "p2p")?;
    init_tables(&mut conn, "normal")?;
    init_tables(&mut conn, "large")?;
    Ok(conn)
}

const FIELD_CHAT: &str = "id, dirty, tpy, status, name, peer_a_id, peer_b_id, owner, member_ids, create_at_ms, update_at_ms, last_message_id, last_message_badge, last_message_pos, admin_ids";
const FIELD_COUNT: usize = 15;

pub(crate) fn init_tables(conn: &Connection, table: &str) -> Result<()> {
    conn.execute(
        &format!(
            "CREATE TABLE IF NOT EXISTS {} (
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
admin_ids TEXT
)",
            table
        ),
        (),
    )?;
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
            version: 0,
        },
        dirty != 0,
    ))
}

#[allow(dead_code)]
pub(crate) fn chat_save(conn: &Connection, table: &str, chat: &entity::Chat) -> Result<()> {
    let query = format!(
        "REPLACE INTO {} ({}) VALUES ({})",
        table,
        FIELD_CHAT,
        placeholder(FIELD_COUNT)
    );
    let mut stmt = conn.prepare(&query)?;
    let member_ids = serde_json::to_string::<Vec<i64>>(&chat.member_ids).unwrap_or_default();
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
    ])?;

    Ok(())
}

#[allow(dead_code)]
pub(crate) fn chat_get_all(conn: &Connection, table: &str) -> Result<Vec<entity::Chat>> {
    let mut chats = Vec::new();
    let query = format!("SELECT {} FROM {}", FIELD_CHAT, table);
    let mut stmt = conn.prepare(&query)?;
    let _ = stmt.query([]).and_then(|mut rows| {
        while let Some(row) = rows.next()? {
            if let Ok((chat, _)) = parse_chat(&row) {
                chats.push(chat);
            }
        }
        Ok(())
    });
    Ok(chats)
}
