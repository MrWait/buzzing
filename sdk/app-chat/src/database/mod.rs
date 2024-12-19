pub(crate) mod chat;
pub(crate) mod feed;

use anyhow::Result;

use base_db::prelude::{Connection, MetaTable, DbConn};
use service::account::{DeviceInfo, UserInfo};

pub(crate) const TABLE_DRAFT: &str = "draft";
static DB_NAME: &str = "chat.db";

pub(crate) fn init_db(user_info: &UserInfo, _device_info: &DeviceInfo) -> Result<Connection> {
    let conn = DbConn::open(&user_info.storage_path, DB_NAME, Some(&user_info.db_key))?;
    init_tables(&conn)?;
    MetaTable::meta(&conn).init_table()?;
    MetaTable::new(TABLE_DRAFT, &conn).init_table()?;
    Ok(conn)
}

fn init_tables(conn: &Connection) -> Result<()> {
    chat::init_tables(conn)?;
    feed::init_tables(conn)?;
    Ok(())
}
