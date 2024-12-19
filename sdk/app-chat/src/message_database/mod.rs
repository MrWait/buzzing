pub(crate) mod message;

use base_db::prelude::{Connection, Result, DbConn};
use service::account::{DeviceInfo, UserInfo};

static DB_NAME: &str = "message.db";

pub(crate) fn init_db(user_info: &UserInfo, _device_info: &DeviceInfo) -> Result<Connection> {
    let conn = DbConn::open(&user_info.storage_path, DB_NAME, Some(&user_info.db_key))?;
    init_tables(&conn)?;
    Ok(conn)
}

fn init_tables(conn: &Connection) -> Result<()> {
    message::init_tables(conn)?;
    Ok(())
}
