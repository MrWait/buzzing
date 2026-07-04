use prost::Message;
use std::collections::HashSet;
use tracing::debug;

use base_db::prelude::{params, params_from_iter, Connection, Result, Row};
use base_db::{cost, placeholder, Pagerize};
use proto::idl::entity;

const FIELD_CALENDAR: &str =
    "id, dirty, creator, tenant_id, version, color, name, desc, is_default, public, subscriber";
const FIELD_COUNT: usize = 11;

pub(crate) fn init_tables(conn: &Connection) -> Result<()> {
    conn.execute(
        "CREATE TABLE IF NOT EXISTS calendar (
id BIGINT PRIMARY KEY,
dirty INTEGER,
creator BIGINT,
tenant_id BIGINT,
version BIGINT,
color INTEGER,
name TEXT,
desc TEXT,
is_default INTEGER,
public INTEGER,
subscriber BLOB
)",
        (),
    )?;
    Ok(())
}

fn parse_calendar(row: &Row) -> Result<(entity::Calendar, bool)> {
    let dirty: i32 = row.get(1)?;
    let subscribers: Vec<u8> = row.get(10)?;
    let subscribers =
        Some(entity::CalendarSubscribers::decode(subscribers.as_slice()).unwrap_or_default());
    Ok((
        entity::Calendar {
            id: row.get(0)?,
            creater: row.get(2)?,
            tenant_id: row.get(3)?,
            version: row.get(4)?,
            color: row.get(5)?,
            name: row.get(6)?,
            desc: row.get(7)?,
            is_default: row.get(8)?,
            public: row.get(9)?,
            enable: true,
            subscribers,
        },
        dirty != 0,
    ))
}

pub(crate) fn calendar_batch_save(
    conn: &mut Connection,
    calendars: &[entity::Calendar],
) -> Result<()> {
    cost!("calendar_batch_save");
    let tx = conn.transaction()?;
    let query = format!(
        "REPLACE INTO calendar ({}) VALUES ({})",
        FIELD_CALENDAR,
        placeholder(FIELD_COUNT)
    );
    {
        let mut stmt = tx.prepare(&query)?;

        for calendar in calendars {
            stmt.clear_bindings();
            let subscribers = calendar
                .subscribers
                .as_ref()
                .and_then(|s| Some(s.encode_to_vec()))
                .unwrap_or(vec![]);
            let _ = stmt.execute(params![
                calendar.id,
                0,
                calendar.creater,
                calendar.tenant_id,
                calendar.version,
                calendar.color,
                &calendar.name,
                &calendar.desc,
                &calendar.is_default,
                calendar.public,
                &subscribers,
            ])?;
        }
    }

    tx.commit()?;
    Ok(())
}

#[allow(dead_code)]
pub(crate) fn calendar_save(conn: &Connection, calendar: &entity::Calendar) -> Result<()> {
    cost!("calendar_save");
    let query = format!(
        "REPLACE INTO calendar ({}) VALUES ({})",
        FIELD_CALENDAR,
        placeholder(FIELD_COUNT)
    );
    let mut stmt = conn.prepare(&query)?;
    let subscribers = calendar
        .subscribers
        .as_ref()
        .map(|s| s.encode_to_vec())
        .unwrap_or(vec![]);
    let _ = stmt.execute(params![
        calendar.id,
        0,
        calendar.creater,
        calendar.tenant_id,
        calendar.version,
        calendar.color,
        &calendar.name,
        &calendar.desc,
        &calendar.is_default,
        calendar.public,
        &subscribers,
    ])?;

    Ok(())
}

pub(crate) fn calendar_get_all(conn: &Connection) -> Result<Vec<entity::Calendar>> {
    let mut calendars = Vec::new();
    let query = format!("select {} from calendar", FIELD_CALENDAR);
    let mut stmt = conn.prepare(&query)?;
    stmt.query(params![]).and_then(|mut rows| {
        while let Some(row) = rows.next()? {
            let calendar = parse_calendar(&row)?.0;
            calendars.push(calendar);
        }
        Ok(())
    });
    Ok(calendars)
}

pub(crate) fn calendar_get_by_ids(
    conn: &Connection,
    origin_ids: &[i64],
    calendars: &mut Vec<entity::Calendar>,
) -> Result<HashSet<i64>> {
    cost!("calendar_get_by_ids");
    let mut dirty = HashSet::new();
    for ids in Pagerize::new(origin_ids, 99) {
        let query = format!(
            "SELECT {} FROM calendar WHERE id IN ({})",
            FIELD_CALENDAR,
            placeholder(ids.len())
        );
        let mut stmt = conn.prepare(&query)?;
        if let Err(err) = stmt
            .query(params_from_iter(ids.iter()))
            .and_then(|mut rows| {
                while let Some(row) = rows.next()? {
                    let (calendar, d) = parse_calendar(&row)?;
                    if d {
                        dirty.insert(calendar.id);
                    }
                    calendars.push(calendar);
                }
                Ok(())
            })
        {
            debug!("get calendar error: {:?}", err);
        }
    }
    Ok(dirty)
}

#[allow(dead_code)]
pub(crate) fn calendar_delete_by_ids(conn: &Connection, origin_ids: &[i64]) -> Result<()> {
    cost!("calendar_delete_by_ids");
    for ids in Pagerize::new(origin_ids, 99) {
        let query = format!(
            "DELETE FROM calendar WHERE id IN ({})",
            placeholder(ids.len())
        );
        let mut stmt = conn.prepare(&query)?;
        let _ = stmt.query(params_from_iter(ids.iter()))?;
    }
    Ok(())
}

#[allow(dead_code)]
pub(crate) fn calendar_mark_dirty(conn: &Connection, origin_ids: &[i64]) -> Result<()> {
    cost!("calendar_mark_dirty");
    for ids in Pagerize::new(origin_ids, 99) {
        let query = format!(
            "UPDATE calendar SET dirty=1 WHERE id IN ({})",
            placeholder(ids.len())
        );
        let mut stmt = conn.prepare(&query)?;
        let _ = stmt.query(params_from_iter(ids.iter()))?;
    }

    Ok(())
}

#[allow(dead_code)]
pub(crate) fn calendar_get_dirty(conn: &Connection, limit: usize) -> Result<Vec<(i64, i64)>> {
    let query = format!("SELECT (id, update_at_ms) WHERE dirty=1 LIMIT ?1");
    let mut stmt = conn.prepare(&query)?;
    let mut result = Vec::with_capacity(limit);
    let _ = stmt.query(params![limit]).and_then(|mut rows| {
        while let Some(row) = rows.next()? {
            result.push((row.get(0)?, row.get(1)?));
        }
        Ok(())
    });
    Ok(result)
}

pub(crate) fn calendar_remove_local(conn: &Connection, id: i64) -> Result<()> {
    conn.execute("DELETE FROM calendar WHERE id = ?1", params![id])?;
    Ok(())
}
