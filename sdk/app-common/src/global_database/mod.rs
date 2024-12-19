use anyhow::Result;

use base_db::prelude::{Connection, DbConn, MetaTable};
use service::account::DeviceInfo;

static DB_NAME: &str = "global.db";

pub(crate) fn init_db(device_info: &DeviceInfo) -> Result<Connection> {
    let conn = DbConn::open(&device_info.storage_path, DB_NAME, None)?;
    init_tables(&conn)?;
    MetaTable::meta(&conn).init_table()?;
    Ok(conn)
}

fn init_tables(_conn: &Connection) -> Result<()> {
    Ok(())
}
