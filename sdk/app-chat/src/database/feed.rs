use tracing::{debug, warn};

use base_db::prelude::{params, params_from_iter, Connection, Result, Row};
use base_db::{cost, placeholder, Pagerize};
use proto::idl::entity;

const FIELDS_FEED: &str = "id, tpy, badge, update_ms, rank_time_ms, refer_id, refer_pos, refer_badge, read_pos, read_badge, version, is_top, is_mute, status";
const FIELDS_COUNT: usize = 14;

pub(crate) fn init_tables(conn: &Connection) -> Result<()> {
    conn.execute(
        "CREATE TABLE IF NOT EXISTS feed (
id INTEGER PRIMARY KEY,
tpy INTEGER,
badge INTEGER,
update_ms BIGINT,
rank_time_ms BIGINT,
refer_id BIGINT,
refer_pos INTEGER,
refer_badge INTEGER,
read_pos INTEGER,
read_badge INTEGER,
version BIGINT,
is_top INTEGER,
is_mute INTEGER,
status INTEGER
)",
        (),
    )?;
    Ok(())
}

fn parse_feed(row: &Row) -> Result<entity::Feed> {
    Ok(entity::Feed {
        id: row.get(0)?,
        r#type: row.get(1)?,
        badge: row.get(2)?,
        update_time_ms: row.get(3)?,
        rank_time_ms: row.get(4)?,
        refer_id: row.get(5)?,
        refer_pos: row.get(6)?,
        refer_badge: row.get(7)?,
        read_pos: row.get(8)?,
        read_badge: row.get(9)?,
        version: row.get(10)?,
        is_top: row.get(11)?,
        is_mute: row.get(12)?,
        status: row.get(13)?,
    })
}

pub(crate) fn feed_batch_save(conn: &mut Connection, entity: &entity::Entity) -> Result<()> {
    cost!("feed_batch_save");
    let tx = conn.transaction()?;
    let query = format!(
        "REPLACE INTO feed ({}) VALUES ({})",
        FIELDS_FEED,
        placeholder(FIELDS_COUNT)
    );
    {
        let mut stmt = tx.prepare(&query)?;

        for feed in entity.feeds.values() {
            stmt.clear_bindings();
            // 未读数本地派生（见 data_sync §6）：badge = max(0, refer_badge - read_badge)。
            // 服务端不写 badge（恒为 0），所有保存路径统一在此重算，保证会话列表/全局角标口径一致。
            let badge = (feed.refer_badge - feed.read_badge).max(0);
            if let Err(err) = stmt.execute(params![
                feed.id,
                feed.r#type,
                badge,
                feed.update_time_ms,
                feed.rank_time_ms,
                feed.refer_id,
                feed.refer_pos,
                feed.refer_badge,
                feed.read_pos,
                feed.read_badge,
                feed.version,
                feed.is_top,
                feed.is_mute,
                feed.status,
            ]) {
                warn!("sql error: {:?}", err);
            }
        }
    }
    tx.commit()?;
    debug!("feed batch save: {:?}", entity);
    Ok(())
}

#[allow(dead_code)]
pub(crate) fn feed_save(conn: &Connection, feed: &entity::Feed) -> Result<()> {
    cost!("feed_save");
    let query = format!(
        "REPLACE INTO feed ({}) VALUES ({})",
        FIELDS_FEED,
        placeholder(FIELDS_COUNT)
    );
    let mut stmt = conn.prepare(&query)?;
    let _ = stmt.query(params![
        feed.id,
        feed.r#type,
        feed.badge,
        feed.update_time_ms,
        feed.rank_time_ms,
        feed.refer_id,
        feed.refer_pos,
        feed.refer_badge,
        feed.read_pos,
        feed.read_badge,
        feed.version,
        feed.is_top,
        feed.is_mute,
        feed.status,
    ])?;
    Ok(())
}

pub(crate) fn feed_get_by_cursor(
    conn: &Connection,
    max: i64,
    limit: i32,
    entity: &mut entity::Entity,
) -> Result<()> {
    cost!("feed_get_by_cursor");
    let query = format!(
        "SELECT {} FROM feed WHERE rank_time_ms < ?1 ORDER BY rank_time_ms DESC LIMIT ?2",
        FIELDS_FEED
    );
    let mut cursor = max;
    if cursor == 0 {
        cursor = std::i64::MAX;
    }

    let mut stmt = conn.prepare_cached(&query)?;
    let _ = stmt.query(params![cursor, limit]).and_then(|mut rows| {
        while let Some(row) = rows.next()? {
            let feed = parse_feed(&row)?;
            entity.feeds.insert(feed.id, feed);
        }
        Ok(())
    })?;
    Ok(())
}

pub(crate) fn feed_get_by_ids(
    conn: &Connection,
    origin_ids: &[i64],
    entity: &mut entity::Entity,
) -> Result<()> {
    cost!("feed_get_by_ids");
    for ids in Pagerize::new(origin_ids, 99) {
        let query = format!(
            "SELECT {} FROM feed WHERE id IN ({})",
            FIELDS_FEED,
            placeholder(ids.len())
        );
        let mut stmt = conn.prepare(&query)?;
        let _ = stmt
            .query(params_from_iter(ids.iter()))
            .and_then(|mut rows| {
                while let Some(row) = rows.next()? {
                    let feed = parse_feed(&row)?;
                    entity.feeds.insert(feed.id, feed);
                }
                Ok(())
            });
    }
    Ok(())
}

#[allow(dead_code)]
pub(crate) fn feed_get_badge_count(conn: &Connection) -> Result<i32> {
    cost!("feed_get_badge_count");
    let query = format!("SELECT id, badge FROM feed WHERE badge > 0");
    let mut count: i32 = 0;
    let mut stmt = conn.prepare_cached(&query)?;
    let mut badges: Vec<(i64, i32)> = Vec::new();
    let _ = stmt.query([]).and_then(|mut rows| {
        while let Some(row) = rows.next()? {
            let id = row.get(0)?;
            let badge = row.get(1)?;
            count += badge;
            badges.push((id, badge));
        }
        Ok(())
    })?;
    tracing::debug!("badges: {:?}", badges);
    Ok(count)
}
