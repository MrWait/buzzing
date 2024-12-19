use std::collections::HashSet;
use tracing::debug;

use base_db::prelude::{params, params_from_iter, Connection, Result, Row};
use base_db::{cost, placeholder, Pagerize};
use proto::idl::entity;

const FIELD_USER: &str = "id, dirty, status, name, tenant_id, version, avatar, dept_id";
const FIELD_COUNT: usize = 8;

pub(crate) fn init_tables(conn: &Connection) -> Result<()> {
    conn.execute(
        "CREATE TABLE IF NOT EXISTS user (
id BIGINT PRIMARY KEY,
dirty INTEGER,
status INTEGER,
name TEXT DEFAULT '',
tenant_id BIGINT,
version BIGINT,
avatar TEXT,
dept_id BIGINT
)",
        (),
    )?;
    Ok(())
}

fn parse_user(row: &Row) -> Result<(entity::User, bool)> {
    let dirty: i32 = row.get(1)?;
    Ok((
        entity::User {
            id: row.get(0)?,
            status: row.get(2)?,
            name: row.get(3)?,
            tenant_id: row.get(4)?,
            version: row.get(5)?,
            avatar: row.get(6)?,
            dept_id: row.get(7)?,
        },
        dirty != 0,
    ))
}

pub(crate) fn user_batch_save(conn: &mut Connection, users: &[entity::User]) -> Result<()> {
    cost!("user_batch_save");
    let tx = conn.transaction()?;
    let query = format!(
        "REPLACE INTO user ({}) VALUES ({})",
        FIELD_USER,
        placeholder(FIELD_COUNT)
    );
    {
        let mut stmt = tx.prepare(&query)?;

        for user in users.iter() {
            stmt.clear_bindings();
            let _ = stmt.execute(params![
                user.id,
                0,
                user.status,
                &user.name,
                user.tenant_id,
                user.version,
                &user.avatar,
                user.dept_id,
            ])?;
        }
    }

    tx.commit()?;
    Ok(())
}

#[allow(dead_code)]
pub(crate) fn user_save(conn: &Connection, user: &entity::User) -> Result<()> {
    cost!("user_save");
    let query = format!(
        "REPLACE INTO user ({}) VALUES ({})",
        FIELD_USER,
        placeholder(FIELD_COUNT)
    );
    let mut stmt = conn.prepare(&query)?;
    let _ = stmt.query(params![
        user.id,
        0,
        user.status,
        &user.name,
        user.tenant_id,
        user.version,
        &user.avatar,
        user.dept_id,
    ])?;

    Ok(())
}

pub(crate) fn user_get_by_ids(
    conn: &Connection,
    origin_ids: &[i64],
    users: &mut Vec<entity::User>,
) -> Result<HashSet<i64>> {
    cost!("user_get_by_ids");
    let mut dirty = HashSet::new();
    for ids in Pagerize::new(origin_ids, 99) {
        let query = format!(
            "SELECT {} FROM user WHERE id IN ({})",
            FIELD_USER,
            placeholder(ids.len())
        );
        let mut stmt = conn.prepare(&query)?;
        if let Err(err) = stmt
            .query(params_from_iter(ids.iter()))
            .and_then(|mut rows| {
                while let Some(row) = rows.next()? {
                    let (user, d) = parse_user(&row)?;
                    if d {
                        dirty.insert(user.id);
                    }
                    users.push(user);
                }
                Ok(())
            })
        {
            debug!("get user error: {:?}", err);
        }
    }
    Ok(dirty)
}

#[allow(dead_code)]
pub(crate) fn user_delete_by_ids(conn: &Connection, origin_ids: &[i64]) -> Result<()> {
    cost!("user_delete_by_ids");
    for ids in Pagerize::new(origin_ids, 99) {
        let query = format!("DELETE FROM user WHERE id IN ({})", placeholder(ids.len()));
        let mut stmt = conn.prepare(&query)?;
        let _ = stmt.query(params_from_iter(ids.iter()))?;
    }

    Ok(())
}

#[allow(dead_code)]
pub(crate) fn user_mark_dirty(conn: &Connection, origin_ids: &[i64]) -> Result<()> {
    cost!("user_mark_dirty");
    for ids in Pagerize::new(origin_ids, 99) {
        let query = format!(
            "UPDATE user SET dirty=1 WHERE id IN ({})",
            placeholder(ids.len())
        );
        let mut stmt = conn.prepare(&query)?;
        let _ = stmt.query(params_from_iter(ids.iter()))?;
    }

    Ok(())
}

#[allow(dead_code)]
pub(crate) fn user_get_dirty(conn: &Connection, limit: usize) -> Result<Vec<(i64, i64)>> {
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
