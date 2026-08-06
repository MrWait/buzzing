use prost::Message;
use std::collections::{HashMap, HashSet};

use base_db::prelude::{params, params_from_iter, Connection, Error, Result, Row};
use base_db::{cost, placeholder, Pagerize};
use proto::idl::entity;

const FIELD_MESSAGE: &str = "id, dirty, readstate_dirty, reaction_dirty, version, readstate_version, reaction_version, tpy, chat_id, from_id, pos, badge_count, status, client_id, create_time_ms, update_time_ms, at_user_ids, content, summary, reaction, readstate, ref_message_id, ref_data";
const FIELD_COUNT: usize = 23;

pub(crate) fn init_tables(conn: &Connection) -> Result<()> {
    conn.execute(
        "CREATE TABLE IF NOT EXISTS message (
id BIGINT PRIMARY KEY,
dirty INTEGER DEFAULT 0,
readstate_dirty INTEGER DEFAULT 0,
reaction_dirty INTEGER DEFAULT 0,
version BIGINT DEFAULT 0,
readstate_version BIGINT DEFAULT 0,
reaction_version BIGINT DEFAULT 0,
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
readstate BLOB,
ref_message_id BIGINT DEFAULT 0,
ref_data BLOB
)",
        (),
    )?;
    // 兼容旧库：补充独立实体版本列（已读/表情各自独立 dirty+version，见 docs/data_sync §5）
    for sql in [
        "ALTER TABLE message ADD COLUMN readstate_dirty INTEGER NOT NULL DEFAULT 0",
        "ALTER TABLE message ADD COLUMN reaction_dirty INTEGER NOT NULL DEFAULT 0",
        "ALTER TABLE message ADD COLUMN version BIGINT NOT NULL DEFAULT 0",
        "ALTER TABLE message ADD COLUMN readstate_version BIGINT NOT NULL DEFAULT 0",
        "ALTER TABLE message ADD COLUMN reaction_version BIGINT NOT NULL DEFAULT 0",
        "ALTER TABLE message ADD COLUMN ref_message_id BIGINT NOT NULL DEFAULT 0",
        "ALTER TABLE message ADD COLUMN ref_data BLOB",
    ] {
        let _ = conn.execute(sql, ());
    }
    Ok(())
}

/// 消息实体脏标记：按类型区分内容（Message）/已读（Readstate）/表情（Reaction）。
#[derive(Default, Clone, Copy, Debug)]
pub(crate) struct MessageDirty {
    pub content: bool,
    pub readstate: bool,
    pub reaction: bool,
}
impl MessageDirty {
    pub fn any(&self) -> bool {
        self.content || self.readstate || self.reaction
    }
}

/// 单行解析结果：内容 Message + 已读/表情独立实体（若本地存在）。
pub(crate) struct MessageRow {
    pub message: entity::Message,
    pub read_state: Option<entity::ReadState>,
    pub reactions: Option<entity::Reactions>,
    pub dirty: MessageDirty,
}

fn parse_row(row: &Row) -> Result<MessageRow> {
    let at_user_ids: String = row.get(16)?;
    let at_user_ids = serde_json::from_str::<Vec<i64>>(&at_user_ids).unwrap_or_default();

    let dirty: i32 = row.get(1)?;
    let readstate_dirty: i32 = row.get(2)?;
    let reaction_dirty: i32 = row.get(3)?;

    // 已读/表情随内容行存储但定义上独立（见 docs/data_sync §5），列可能为 NULL
    let reaction: Option<Vec<u8>> = row.get(19)?;
    let reactions = reaction
        .as_deref()
        .and_then(|bytes| entity::Reactions::decode(bytes).ok());
    let readstate: Option<Vec<u8>> = row.get(20)?;
    let read_state = readstate
        .as_deref()
        .and_then(|bytes| entity::ReadState::decode(bytes).ok());

    // 引用回复：ref_data 为 MessageReference 的 proto blob，可能为 NULL
    let ref_data: Option<Vec<u8>> = row.get(22)?;
    let ref_data = ref_data
        .as_deref()
        .and_then(|bytes| entity::MessageReference::decode(bytes).ok());

    Ok(MessageRow {
        message: entity::Message {
            id: row.get(0)?,
            tpy: row.get(7)?,
            chat_id: row.get(8)?,
            from_id: row.get(9)?,
            pos: row.get(10)?,
            badge_count: row.get(11)?,
            status: row.get(12)?,
            client_id: row.get(13)?,
            create_time_ms: row.get(14)?,
            update_time_ms: row.get(15)?,
            at_user_ids,
            content: row.get(17)?,
            summary: row.get(18)?,
            version: row.get(4)?,
            ref_message_id: row.get(21)?,
            ref_data,
            // TODO: add column in sql
            thread_root_id: 0,
        },
        read_state,
        reactions,
        dirty: MessageDirty {
            content: dirty != 0,
            readstate: readstate_dirty != 0,
            reaction: reaction_dirty != 0,
        },
    })
}

/// 把单行解析结果合并进 entity：内容→messages，已读/表情→readstates/reactions（key=message_id）。
fn fill_entity_row(row: &Row, entity: &mut entity::Entity, dirty: &mut HashSet<i64>) -> Result<()> {
    let r = parse_row(row)?;
    if r.dirty.any() {
        dirty.insert(r.message.id);
    }
    let id = r.message.id;
    entity.messages.insert(id, r.message);
    if let Some(rs) = r.read_state {
        entity.readstates.insert(id, rs);
    }
    if let Some(re) = r.reactions {
        entity.reactions.insert(id, re);
    }
    Ok(())
}

// ─── 三路写入：内容 / 已读 / 表情，互不覆盖，见 docs/data_sync §5 ──────────
// 三个 upsert 均带版本守卫：仅当 incoming version >= 已存 version 才落库并清脏，
// 陈旧实体（实时乱序 / 过期推拉）直接丢弃，脏标记保留等待更新数据补齐（见 §5 版本合并语义）。

fn message_content_upsert<'a>(
    conn: &Connection,
    messages: impl Iterator<Item = &'a entity::Message>,
) -> Result<()> {
    let query = "INSERT INTO message (id, dirty, version, tpy, chat_id, from_id, pos, badge_count, status, client_id, create_time_ms, update_time_ms, at_user_ids, content, summary, ref_message_id, ref_data)
VALUES (?1,0,?2,?3,?4,?5,?6,?7,?8,?9,?10,?11,?12,?13,?14,?15,?16)
ON CONFLICT(id) DO UPDATE SET
    version=excluded.version, tpy=excluded.tpy, chat_id=excluded.chat_id, from_id=excluded.from_id,
    pos=excluded.pos, badge_count=excluded.badge_count, status=excluded.status,
    client_id=excluded.client_id, create_time_ms=excluded.create_time_ms, update_time_ms=excluded.update_time_ms,
    at_user_ids=excluded.at_user_ids, content=excluded.content, summary=excluded.summary, dirty=0,
    ref_message_id=excluded.ref_message_id, ref_data=excluded.ref_data
WHERE excluded.version >= version";
    let mut stmt = conn.prepare(query)?;
    for message in messages {
        let at_user_ids =
            serde_json::to_string::<Vec<i64>>(&message.at_user_ids).unwrap_or_default();
        // ref_data 为 MessageReference proto blob，未设置时为 NULL
        let ref_data = message.ref_data.as_ref().map(|d| d.encode_to_vec());
        stmt.execute(params![
            message.id,
            message.version,
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
            message.ref_message_id,
            &ref_data,
        ])?;
    }
    Ok(())
}

fn message_readstate_upsert(
    conn: &Connection,
    readstates: &HashMap<i64, entity::ReadState>,
) -> Result<()> {
    let query = "INSERT INTO message (id, readstate_dirty, readstate_version, readstate)
VALUES (?1,0,?2,?3)
ON CONFLICT(id) DO UPDATE SET
    readstate_version=excluded.readstate_version, readstate=excluded.readstate, readstate_dirty=0
WHERE excluded.readstate_version >= readstate_version";
    let mut stmt = conn.prepare(query)?;
    for (id, rs) in readstates {
        // 落库时把实体 id（= message_id）写进 blob，支持 vector 形态存储（见 docs/data_sync §5）
        let mut rs = rs.clone();
        rs.id = *id;
        let blob = rs.encode_to_vec();
        stmt.execute(params![id, rs.version, &blob])?;
    }
    Ok(())
}

fn message_reaction_upsert(
    conn: &Connection,
    reactions: &HashMap<i64, entity::Reactions>,
) -> Result<()> {
    let query = "INSERT INTO message (id, reaction_dirty, reaction_version, reaction)
VALUES (?1,0,?2,?3)
ON CONFLICT(id) DO UPDATE SET
    reaction_version=excluded.reaction_version, reaction=excluded.reaction, reaction_dirty=0
WHERE excluded.reaction_version >= reaction_version";
    let mut stmt = conn.prepare(query)?;
    for (id, re) in reactions {
        // 落库时把实体 id（= message_id）写进 blob，支持 vector 形态存储（见 docs/data_sync §5）
        let mut re = re.clone();
        re.id = *id;
        let blob = re.encode_to_vec();
        stmt.execute(params![id, re.version, &blob])?;
    }
    Ok(())
}

pub(crate) fn message_batch_save(conn: &mut Connection, entity: &entity::Entity) -> Result<()> {
    cost!("message_batch_save");
    let tx = conn.transaction()?;
    if !entity.messages.is_empty() {
        message_content_upsert(&tx, entity.messages.values())?;
    }
    if !entity.readstates.is_empty() {
        message_readstate_upsert(&tx, &entity.readstates)?;
    }
    if !entity.reactions.is_empty() {
        message_reaction_upsert(&tx, &entity.reactions)?;
    }
    tx.commit()?;
    Ok(())
}

pub(crate) fn message_save(conn: &Connection, message: &entity::Message) -> Result<()> {
    cost!("message_save");
    message_content_upsert(conn, std::iter::once(message))?;
    Ok(())
}

// ─── 读取 ─────────────────────────────────────────────────────────────

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
                    fill_entity_row(&row, entity, &mut dirty)?;
                }
                Ok(())
            })?;
    }
    Ok(dirty)
}

pub(crate) fn message_get_by_id(conn: &Connection, id: i64) -> Result<Option<MessageRow>> {
    cost!("message_get_by_ids");
    let query = format!("SELECT {} FROM message WHERE id=?1", FIELD_MESSAGE,);
    let mut stmt = conn.prepare(&query)?;
    let mut result = None;
    let _ = stmt.query(params![id]).and_then(|mut rows| {
        if let Some(row) = rows.next()? {
            result = Some(parse_row(&row)?);
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
                fill_entity_row(&row, entity, &mut dirty)?;
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
    // stash 草稿以 status=FAIL(8) 落库（见 message_create_draft），重启时据此重载
    let query = format!("SELECT id FROM message WHERE status=8");
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

/// 实体变更标记 dirty：按实体类型分别标记（Message→内容、Readstate→已读、Reaction→表情）。
/// `updates` 为 (id, version) 对，逐条携带各自的实体版本（EntityChange 是逐条带 version 下发的，
/// 同一类型多条变更版本可能不同，不能退化为单一 version）。按 version 分组批量 UPDATE，
/// 并包在单个事务里提交，避免每条 id 执行一次。
/// 脏标记在 pipeline 同步完成后统一拉取全量实体落库清除（见 docs/data_sync §5）。
pub(crate) fn message_mark_dirty(
    conn: &mut Connection,
    updates: &[(i64, i64)],
    r#type: i32,
) -> Result<()> {
    cost!("message_mark_dirty");
    if updates.is_empty() {
        return Ok(());
    }
    let set_clause = match r#type {
        x if x == entity::EntityType::Message as i32 => "dirty=1, version=?1",
        x if x == entity::EntityType::Readstate as i32 => {
            "readstate_dirty=1, readstate_version=?1"
        }
        x if x == entity::EntityType::Reaction as i32 => {
            "reaction_dirty=1, reaction_version=?1"
        }
        _ => return Ok(()),
    };
    let tx = conn.transaction()?;
    let mut by_version: HashMap<i64, Vec<i64>> = Default::default();
    for (id, version) in updates {
        by_version.entry(*version).or_default().push(*id);
    }
    for (version, ids) in &by_version {
        for chunk in Pagerize::new(ids, 99) {
            let query = format!(
                "UPDATE message SET {} WHERE id IN ({})",
                set_clause,
                placeholder(chunk.len())
            );
            tx.execute(
                &query,
                params_from_iter(std::iter::once(version).chain(chunk.iter())),
            )?;
        }
    }
    tx.commit()?;
    Ok(())
}

/// 汇总所有脏消息实体（含类型），供 pipeline 同步完成后统一拉取。
pub(crate) fn message_get_dirty(conn: &Connection) -> Result<Vec<entity::EntityId>> {
    cost!("message_get_dirty");
    let mut result = Vec::new();
    let query =
        "SELECT id, dirty, readstate_dirty, reaction_dirty FROM message WHERE dirty=1 OR readstate_dirty=1 OR reaction_dirty=1";
    let mut stmt = conn.prepare(query)?;
    let _ = stmt.query(params![]).and_then(|mut rows| {
        while let Some(row) = rows.next()? {
            let id: i64 = row.get(0)?;
            let content: i32 = row.get(1)?;
            let readstate: i32 = row.get(2)?;
            let reaction: i32 = row.get(3)?;
            if content != 0 {
                result.push(entity::EntityId {
                    id,
                    r#type: entity::EntityType::Message as i32,
                });
            }
            if readstate != 0 {
                result.push(entity::EntityId {
                    id,
                    r#type: entity::EntityType::Readstate as i32,
                });
            }
            if reaction != 0 {
                result.push(entity::EntityId {
                    id,
                    r#type: entity::EntityType::Reaction as i32,
                });
            }
        }
        Ok(())
    })?;
    Ok(result)
}
