pub(crate) mod calendar;
pub(crate) mod schedule;

use anyhow::Result;

use base_db::prelude::{Connection, DbConn, MetaTable};
use service::account::{DeviceInfo, UserInfo};

static DB_NAME: &str = "calendar.db";

pub(crate) fn init_db(user_info: &UserInfo, _device_info: &DeviceInfo) -> Result<Connection> {
    let conn = DbConn::open(&user_info.storage_path, DB_NAME, Some(&user_info.db_key))?;
    init_tables(&conn)?;
    MetaTable::meta(&conn).init_table()?;
    Ok(conn)
}

fn init_tables(conn: &Connection) -> Result<()> {
    calendar::init_tables(conn)?;
    schedule::init_tables(conn)?;
    Ok(())
}
