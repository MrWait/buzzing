use prost::Message;
use std::collections::HashSet;
use tracing::debug;

use base_db::prelude::{params, params_from_iter, Connection, Result, Row};
use base_db::{cost, placeholder, Pagerize};
use proto::idl::entity;

#[derive(prost::Message)]
struct ScheduleExtra {
    #[prost(int64, tag = "1")]
    pub summary_doc_id: i64,
    #[prost(int64, tag = "2")]
    pub room_id: i64,
    #[prost(bool, tag = "3")]
    pub member_view_list: bool,
    #[prost(bool, tag = "4")]
    pub member_invite_other: bool,
    #[prost(bool, tag = "5")]
    pub member_alter_schedule: bool,
    #[prost(bool, tag = "6")]
    pub member_create_summary: bool,
    #[prost(bool, tag = "7")]
    pub member_create_meeting: bool,
    #[prost(bool, tag = "8")]
    pub need_check_in: bool,
    #[prost(bool, tag = "9")]
    pub show_as_idle: bool,
    #[prost(int32, tag = "10")]
    pub member_count: i32,
    #[prost(int32, tag = "11")]
    pub color: i32,
    #[prost(int32, tag = "12")]
    pub public_permision: i32,
    #[prost(string, tag = "13")]
    pub location: String,
    #[prost(string, tag = "14")]
    pub archive: String,
    #[prost(int64, repeated, tag = "15")]
    pub member_ids: Vec<i64>,
    #[prost(int32, repeated, tag = "16")]
    pub notify_time: Vec<i32>,
    #[prost(message, tag = "17")]
    pub cycle: Option<entity::ScheduleCycleRule>,
    #[prost(string, tag = "18")]
    pub title: String,
    #[prost(string, tag = "19")]
    pub desc: String,
}

const FIELD_SCHEDULE: &str = "id, calendar_id, dirty, type, tenant_id, owner, cycle_rule_id, chat_id, version, full_day, exception, start_time, end_time, extra";
const FIELD_COUNT: usize = 15;

pub(crate) fn init_tables(conn: &Connection) -> Result<()> {
    conn.execute(
        "CREATE TABLE IF NOT EXISTS schedule (
id BIGINT,
calendar_id BIGINT,
dirty INTEGER,
type INTEGER,
tenant_id BIGINT,
owner BIGINT,
cycle_rule_id BIGINT,
chat_id BIGINT,
version BIGINT,
full_day INTEGER,
exception INTEGER,
start_time BIGINT,
end_time BIGINT,
extra BLOB,
primary key(id, calendar_id)
)",
        (),
    )?;
    Ok(())
}

fn parse_schedule(row: &Row) -> Result<(entity::Schedule, bool)> {
    let dirty: i32 = row.get(2)?;
    let extra: Vec<u8> = row.get(13)?;
    let extra: ScheduleExtra = ScheduleExtra::decode(extra.as_slice()).unwrap_or_default();
    Ok((
        entity::Schedule {
            id: row.get(0)?,
            calendar_id: row.get(1)?,
            r#type: row.get(3)?,
            tenant_id: row.get(4)?,
            owner: row.get(5)?,
            cycle_rule_id: row.get(6)?,
            chat_id: row.get(7)?,
            version: row.get(8)?,
            full_day: row.get(9)?,
            exception: row.get(10)?,
            start_time: row.get(11)?,
            end_time: row.get(12)?,
            summary_doc_id: extra.summary_doc_id,
            room_id: extra.room_id,
            member_alter_schedule: extra.member_alter_schedule,
            member_count: extra.member_count,
            member_create_meeting: extra.member_create_meeting,
            member_create_summary: extra.member_create_summary,
            member_ids: extra.member_ids,
            member_invite_other: extra.member_invite_other,
            member_view_list: extra.member_view_list,
            color: extra.color,
            public_permision: extra.public_permision,
            location: extra.location,
            archive: extra.archive,
            notify_time: extra.notify_time,
            show_as_idle: extra.show_as_idle,
            need_checkin: extra.need_check_in,
            cycle: extra.cycle,
            desc: extra.desc,
            title: extra.title,
            modify_scope: 0,
        },
        dirty != 0,
    ))
}

pub(crate) fn schedule_batch_save(
    conn: &mut Connection,
    schedules: &[entity::Schedule],
) -> Result<()> {
    cost!("schedule_batch_save");
    let tx = conn.transaction()?;
    let query = format!(
        "REPLACE INTO schedule ({}) VALUES ({})",
        FIELD_SCHEDULE,
        placeholder(FIELD_COUNT)
    );
    {
        let mut stmt = tx.prepare(&query)?;

        for schedule in schedules.iter() {
            stmt.clear_bindings();
            let extra = ScheduleExtra {
                summary_doc_id: schedule.summary_doc_id,
                room_id: schedule.room_id,
                member_view_list: schedule.member_view_list,
                member_invite_other: schedule.member_invite_other,
                member_alter_schedule: schedule.member_alter_schedule,
                member_count: schedule.member_count,
                member_create_meeting: schedule.member_create_meeting,
                member_create_summary: schedule.member_create_summary,
                member_ids: schedule.member_ids.clone(),
                need_check_in: schedule.need_checkin,
                show_as_idle: schedule.show_as_idle,
                color: schedule.color,
                public_permision: schedule.public_permision,
                location: schedule.location.clone(),
                archive: schedule.archive.clone(),
                notify_time: schedule.notify_time.clone(),
                title: schedule.title.clone(),
                desc: schedule.desc.clone(),
                cycle: schedule.cycle.clone(),
            };
            let extra = extra.encode_to_vec();
            let _ = stmt.execute(params![
                schedule.id,
                schedule.calendar_id,
                0,
                schedule.r#type,
                schedule.tenant_id,
                schedule.owner,
                schedule.cycle_rule_id,
                schedule.chat_id,
                schedule.version,
                schedule.full_day,
                schedule.exception,
                schedule.start_time,
                schedule.end_time,
                &extra
            ])?;
        }
    }

    tx.commit()?;
    Ok(())
}

#[allow(dead_code)]
pub(crate) fn schedule_save(conn: &Connection, schedule: &entity::Schedule) -> Result<()> {
    cost!("schedule_save");
    let query = format!(
        "REPLACE INTO schedule ({}) VALUES ({})",
        FIELD_SCHEDULE,
        placeholder(FIELD_COUNT)
    );
    let mut stmt = conn.prepare(&query)?;
    let extra = ScheduleExtra {
        summary_doc_id: schedule.summary_doc_id,
        room_id: schedule.room_id,
        member_view_list: schedule.member_view_list,
        member_invite_other: schedule.member_invite_other,
        member_alter_schedule: schedule.member_alter_schedule,
        member_count: schedule.member_count,
        member_create_meeting: schedule.member_create_meeting,
        member_create_summary: schedule.member_create_summary,
        member_ids: schedule.member_ids.clone(),
        need_check_in: schedule.need_checkin,
        show_as_idle: schedule.show_as_idle,
        color: schedule.color,
        public_permision: schedule.public_permision,
        location: schedule.location.clone(),
        archive: schedule.archive.clone(),
        notify_time: schedule.notify_time.clone(),
        title: schedule.title.clone(),
        desc: schedule.desc.clone(),
        cycle: schedule.cycle.clone(),
    };
    let extra = extra.encode_to_vec();
    let _ = stmt.execute(params![
        schedule.id,
        schedule.calendar_id,
        0,
        schedule.r#type,
        schedule.tenant_id,
        schedule.owner,
        schedule.cycle_rule_id,
        schedule.chat_id,
        schedule.version,
        schedule.full_day,
        schedule.exception,
        schedule.start_time,
        schedule.end_time,
        &extra
    ])?;

    Ok(())
}

pub(crate) fn schedule_get_by_ids(
    conn: &Connection,
    origin_ids: &[i64],
    schedules: &mut Vec<entity::Schedule>,
) -> Result<HashSet<i64>> {
    cost!("schedule_get_by_ids");
    let mut dirty = HashSet::new();
    for ids in Pagerize::new(origin_ids, 99) {
        let query = format!(
            "SELECT {} FROM schedule WHERE id IN ({})",
            FIELD_SCHEDULE,
            placeholder(ids.len())
        );
        let mut stmt = conn.prepare(&query)?;
        if let Err(err) = stmt
            .query(params_from_iter(ids.iter()))
            .and_then(|mut rows| {
                while let Some(row) = rows.next()? {
                    let (schedule, d) = parse_schedule(&row)?;
                    if d {
                        dirty.insert(schedule.id);
                    }
                    schedules.push(schedule);
                }
                Ok(())
            })
        {
            debug!("get schedule error: {:?}", err);
        }
    }
    Ok(dirty)
}

#[allow(dead_code)]
pub(crate) fn schedule_delete_by_ids(conn: &Connection, origin_ids: &[i64]) -> Result<()> {
    cost!("schedule_delete_by_ids");
    for ids in Pagerize::new(origin_ids, 99) {
        let query = format!(
            "DELETE FROM schedule WHERE id IN ({})",
            placeholder(ids.len())
        );
        let mut stmt = conn.prepare(&query)?;
        let _ = stmt.query(params_from_iter(ids.iter()))?;
    }
    Ok(())
}

#[allow(dead_code)]
pub(crate) fn schedule_mark_dirty(conn: &Connection, origin_ids: &[i64]) -> Result<()> {
    cost!("schedule_mark_dirty");
    for ids in Pagerize::new(origin_ids, 99) {
        let query = format!(
            "UPDATE schedule SET dirty=1 WHERE id IN ({})",
            placeholder(ids.len())
        );
        let mut stmt = conn.prepare(&query)?;
        let _ = stmt.query(params_from_iter(ids.iter()))?;
    }

    Ok(())
}

#[allow(dead_code)]
pub(crate) fn schedule_get_dirty(conn: &Connection, limit: usize) -> Result<Vec<(i64, i64)>> {
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

pub(crate) fn schedule_remove_local(conn: &Connection, schedule_id: i64) -> Result<()> {
    cost!("schedule_remove_local");
    conn.execute("DELETE FROM schedule WHERE id = ?1", params![schedule_id])?;
    Ok(())
}

pub(crate) fn schedule_get_by_range(
    conn: &Connection,
    calendar_ids: &[i64],
    start_time: i64,
    end_time: i64,
    schedules: &mut Vec<entity::Schedule>,
) -> Result<()> {
    cost!("schedule_get_by_range");
    if calendar_ids.is_empty() {
        return Ok(());
    }
    for cid in calendar_ids {
        let query = format!(
            "SELECT {} FROM schedule WHERE calendar_id = ?1 AND end_time >= ?2 AND start_time <= ?3",
            FIELD_SCHEDULE,
        );
        let mut stmt = conn.prepare(&query)?;
        if let Err(err) = stmt
            .query(params![cid, start_time, end_time])
            .and_then(|mut rows| {
                while let Some(row) = rows.next()? {
                    let (schedule, _) = parse_schedule(&row)?;
                    schedules.push(schedule);
                }
                Ok(())
            })
        {
            debug!("schedule_get_by_range error: {:?}", err);
        }
    }
    Ok(())
}

pub(crate) fn schedule_remove_by_cycle_rule_id(conn: &Connection, cycle_rule_id: i64) -> Result<()> {
    cost!("schedule_remove_by_cycle_rule_id");
    conn.execute(
        "DELETE FROM schedule WHERE cycle_rule_id = ?1",
        params![cycle_rule_id],
    )?;
    Ok(())
}

pub(crate) fn schedule_remove_future_by_cycle(
    conn: &Connection,
    cycle_rule_id: i64,
    start_time: i64,
) -> Result<()> {
    cost!("schedule_remove_future_by_cycle");
    conn.execute(
        "DELETE FROM schedule WHERE cycle_rule_id = ?1 AND start_time >= ?2",
        params![cycle_rule_id, start_time],
    )?;
    Ok(())
}

pub(crate) fn schedule_remove_by_calendar(conn: &Connection, calendar_id: i64) -> Result<()> {
    cost!("schedule_remove_by_calendar");
    conn.execute(
        "DELETE FROM schedule WHERE calendar_id = ?1",
        params![calendar_id],
    )?;
    Ok(())
}
