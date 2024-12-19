use tracing::debug;

use base_db::prelude::{params, Connection, Error, Result, Row};
use base_db::{cost, placeholder};
use service::Setting;

const FIELD_SETTING: &str = "key, value, version, dirty";
const FIELD_COUNT: usize = 4;

pub(crate) fn init_tables(conn: &Connection) -> Result<()> {
    cost!("init setting tables");
    let query = "CREATE TABLE IF NOT EXISTS setting (
key TEXT PRIMARY KEY,
value TEXT,
version BIGINT,
dirty INTEGER
)";
    // debug!("create message table: {:?}", query);
    conn.execute(query, ())?;
    Ok(())
}

pub(crate) fn drop_tables(conn: &Connection) -> Result<()> {
    conn.execute("DROP TABLE IF EXISTS setting", ())?;
    Ok(())
}

fn parse_setting(row: &Row) -> Result<Setting> {
    let dirty: i32 = row.get(3)?;
    Ok(Setting {
        key: row.get(0)?,
        value: row.get(1)?,
        version: row.get(2)?,
        dirty: dirty != 0,
    })
}

pub(crate) fn setting_add(conn: &Connection, setting: &Setting) -> Result<()> {
    cost!("setting_add");
    let query = format!(
        "REPLACE INTO setting ({}) VALUES ({})",
        FIELD_SETTING,
        placeholder(FIELD_COUNT)
    );
    let mut stmt = conn.prepare_cached(&query)?;
    if let Err(e) = stmt.execute(params![&setting.key, &setting.value, setting.version, 0,]) {
        debug!(
            "setting add error: {:?}, stmt: {:?}",
            e,
            stmt.expanded_sql()
        );
    }

    Ok(())
}

pub(crate) fn setting_del(conn: &Connection, key: &str) -> Result<()> {
    cost!("setting_del");
    let query = format!("DELETE FROM setting WHERE kstr=?1");
    let mut stmt = conn.prepare_cached(&query)?;
    if let Err(e) = stmt.query(params![key]) {
        debug!("setting del error: {:?}", e);
    }
    Ok(())
}

pub(crate) fn setting_get_by_key(conn: &Connection, key: &str) -> Result<Setting> {
    cost!("setting_get_by_ids");
    let query = format!("SELECT {} FROM setting WHERE kstr=?1", FIELD_SETTING);
    let mut stmt = conn.prepare(&query)?;
    stmt.query(params![key]).and_then(|mut rows| {
        if let Some(row) = rows.next()? {
            let c = parse_setting(&row)?;
            return Ok(c);
        }
        Err(Error::QueryReturnedNoRows)
    })
}

pub(crate) fn setting_mark_dirty(conn: &Connection, key: &str) -> Result<()> {
    cost!("setting_mark_dirty");
    let query = format!("UPDATE setting SET dirty=1 WHERE kstr=?1");
    let mut stmt = conn.prepare(&query)?;
    stmt.execute(params![key])?;
    Ok(())
}
