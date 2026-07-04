use chrono::{DateTime, Datelike, Duration, NaiveDate, NaiveDateTime, TimeDelta, Timelike, Utc};
use loco_rs::Result;
use prost::Message;
use tracing::warn;

use proto::idl::entity;

const EXPAND_DAYS: i64 = 120;
const MS_PER_DAY: i64 = 86400000;

/// Generate concrete schedule instances from a template with cycle rule.
/// Limited to the [expand_start, expand_end) window.
pub fn gen_by_rule(schedule: &entity::Schedule) -> Result<Vec<entity::Schedule>> {
    let cycle = schedule.cycle.as_ref().ok_or_else(|| {
        loco_rs::Error::string("gen_by_rule called without cycle rule")
    })?;
    let rule = cycle.rule.as_ref().ok_or_else(|| {
        loco_rs::Error::string("gen_by_rule called without cycle rule.rule")
    })?;

    let expand_end_max = schedule.end_time + EXPAND_DAYS * MS_PER_DAY;
    let expand_end = if cycle.stop_at > 0 {
        cycle.stop_at.min(expand_end_max)
    } else {
        expand_end_max
    };
    let expand_start = cycle.start_at.max(schedule.start_time);

    if expand_start >= expand_end {
        return Ok(vec![]);
    }

    let duration = schedule.end_time - schedule.start_time;
    let exception_times: std::collections::HashSet<i64> =
        cycle.exception_times.iter().copied().collect();

    let base_dt = ms_to_datetime(cycle.start_at);
    let start_dt = ms_to_datetime(expand_start);
    let end_dt = ms_to_datetime(expand_end);

    let mut instances = Vec::new();

    match rule.cycle_type {
        1 => gen_by_day(
            schedule, cycle, rule, base_dt, start_dt, end_dt,
            duration, &exception_times, &mut instances,
        ),
        2 => gen_by_week(
            schedule, cycle, rule, base_dt, start_dt, end_dt,
            duration, &exception_times, &mut instances,
        ),
        3 => gen_by_month(
            schedule, cycle, rule, base_dt, start_dt, end_dt,
            duration, &exception_times, &mut instances,
        ),
        4 => gen_by_month_week(
            schedule, cycle, rule, base_dt, start_dt, end_dt,
            duration, &exception_times, &mut instances,
        ),
        5 => gen_by_year(
            schedule, cycle, rule, base_dt, start_dt, end_dt,
            duration, &exception_times, &mut instances,
        ),
        _ => {
            warn!("unknown cycle_type: {}", rule.cycle_type);
        }
    }

    Ok(instances)
}

fn gen_by_day(
    template: &entity::Schedule,
    cycle: &entity::ScheduleCycleRule,
    rule: &entity::CycleRule,
    _base_dt: DateTime<Utc>,
    start_dt: DateTime<Utc>,
    end_dt: DateTime<Utc>,
    duration: i64,
    exception_times: &std::collections::HashSet<i64>,
    instances: &mut Vec<entity::Schedule>,
) {
    let interval = rule.seq.max(1) as i64;
    let mut current = start_dt;
    while current < end_dt {
        let ts = datetime_to_ms(current);
        if ts >= cycle.start_at && ts >= template.start_time && !exception_times.contains(&ts) {
            instances.push(build_instance(template, ts, duration));
        }
        current = current + TimeDelta::days(interval);
    }
}

fn gen_by_week(
    template: &entity::Schedule,
    cycle: &entity::ScheduleCycleRule,
    rule: &entity::CycleRule,
    base_dt: DateTime<Utc>,
    start_dt: DateTime<Utc>,
    end_dt: DateTime<Utc>,
    duration: i64,
    exception_times: &std::collections::HashSet<i64>,
    instances: &mut Vec<entity::Schedule>,
) {
    let interval_weeks = rule.seq.max(1) as i64;
    let week_days: Vec<u32> = rule
        .week_seqs
        .iter()
        .map(|w| if *w == 0 { 6 } else { (*w - 1) as u32 })
        .collect();
    if week_days.is_empty() {
        return;
    }

    let mut current = start_dt;
    while current < end_dt {
        let weekday = current.weekday().num_days_from_monday();
        if week_days.contains(&weekday) {
            let ts = datetime_to_ms(current);
            if ts >= cycle.start_at
                && ts >= template.start_time
                && !exception_times.contains(&ts)
                && is_week_interval_match(base_dt, current, interval_weeks)
            {
                instances.push(build_instance(template, ts, duration));
            }
        }
        current = current + TimeDelta::days(1);
    }
}

fn gen_by_month(
    template: &entity::Schedule,
    cycle: &entity::ScheduleCycleRule,
    rule: &entity::CycleRule,
    base_dt: DateTime<Utc>,
    start_dt: DateTime<Utc>,
    end_dt: DateTime<Utc>,
    duration: i64,
    exception_times: &std::collections::HashSet<i64>,
    instances: &mut Vec<entity::Schedule>,
) {
    let interval = rule.seq.max(1) as i64;
    let day_of_month = base_dt.day().min(28);
    let months_since_base = months_between(base_dt, start_dt);
    let start_month_offset = ((months_since_base + interval - 1) / interval) * interval;

    let mut current = advance_months(base_dt, start_month_offset);
    while current < end_dt {
        let adjusted = set_day(current, day_of_month);
        let ts = datetime_to_ms(adjusted);
        if ts >= cycle.start_at
            && ts >= template.start_time
            && !exception_times.contains(&ts)
        {
            instances.push(build_instance(template, ts, duration));
        }
        current = advance_months(current, interval);
    }
}

fn gen_by_month_week(
    template: &entity::Schedule,
    cycle: &entity::ScheduleCycleRule,
    rule: &entity::CycleRule,
    base_dt: DateTime<Utc>,
    start_dt: DateTime<Utc>,
    end_dt: DateTime<Utc>,
    duration: i64,
    exception_times: &std::collections::HashSet<i64>,
    instances: &mut Vec<entity::Schedule>,
) {
    let interval = rule.seq.max(1) as i64;
    let week_of_month = if rule.week_seqs.is_empty() {
        0
    } else {
        rule.week_seqs[0].max(0)
    } as u32;
    let day_of_week = if rule.week_seqs.len() > 1 {
        let w = rule.week_seqs[1];
        if w == 0 { 6 } else { (w - 1) as u32 }
    } else {
        base_dt.weekday().num_days_from_monday()
    };
    let months_since_base = months_between(base_dt, start_dt);
    let start_month_offset = ((months_since_base + interval - 1) / interval) * interval;
    let mut current = advance_months(base_dt, start_month_offset);
    while current < end_dt {
        let adjusted = nth_weekday_of_month(current, week_of_month, day_of_week);
        let ts = datetime_to_ms(adjusted);
        if ts >= cycle.start_at
            && ts >= template.start_time
            && !exception_times.contains(&ts)
        {
            instances.push(build_instance(template, ts, duration));
        }
        current = advance_months(current, interval);
    }
}

fn gen_by_year(
    template: &entity::Schedule,
    cycle: &entity::ScheduleCycleRule,
    rule: &entity::CycleRule,
    base_dt: DateTime<Utc>,
    start_dt: DateTime<Utc>,
    end_dt: DateTime<Utc>,
    duration: i64,
    exception_times: &std::collections::HashSet<i64>,
    instances: &mut Vec<entity::Schedule>,
) {
    let interval = rule.seq.max(1) as i64;
    let years_since_base = (start_dt.year() - base_dt.year()) as i64;
    let start_year_offset = ((years_since_base + interval - 1) / interval) * interval;
    let mut current = advance_months(base_dt, start_year_offset * 12);
    while current < end_dt {
        let ts = datetime_to_ms(current);
        if ts >= cycle.start_at
            && ts >= template.start_time
            && !exception_times.contains(&ts)
        {
            instances.push(build_instance(template, ts, duration));
        }
        current = advance_months(current, interval * 12);
    }
}

fn build_instance(
    template: &entity::Schedule,
    start_time: i64,
    duration: i64,
) -> entity::Schedule {
    entity::Schedule {
        id: template.id,
        calendar_id: template.calendar_id,
        r#type: template.r#type,
        tenant_id: template.tenant_id,
        owner: template.owner,
        version: template.version,
        start_time,
        end_time: start_time + duration,
        title: template.title.clone(),
        location: template.location.clone(),
        desc: template.desc.clone(),
        color: template.color,
        public_permision: template.public_permision,
        full_day: template.full_day,
        member_ids: template.member_ids.clone(),
        member_count: template.member_count,
        member_view_list: template.member_view_list,
        member_invite_other: template.member_invite_other,
        member_alter_schedule: template.member_alter_schedule,
        member_create_summary: template.member_create_summary,
        member_create_meeting: template.member_create_meeting,
        need_checkin: template.need_checkin,
        show_as_idle: template.show_as_idle,
        exception: template.exception,
        summary_doc_id: template.summary_doc_id,
        room_id: template.room_id,
        chat_id: template.chat_id,
        cycle_rule_id: template.cycle_rule_id,
        notify_time: template.notify_time.clone(),
        archive: template.archive.clone(),
        cycle: template.cycle.clone(),
        modify_scope: 0,
    }
}

fn ms_to_datetime(ms: i64) -> DateTime<Utc> {
    let secs = ms / 1000;
    let nsecs = ((ms % 1000) * 1_000_000) as u32;
    DateTime::from_timestamp(secs, nsecs).unwrap_or_default()
}

fn datetime_to_ms(dt: DateTime<Utc>) -> i64 {
    dt.timestamp_millis()
}

fn months_between(from: DateTime<Utc>, to: DateTime<Utc>) -> i64 {
    (to.year() - from.year()) as i64 * 12 + (to.month() - from.month()) as i64
}

fn advance_months(dt: DateTime<Utc>, months: i64) -> DateTime<Utc> {
    let total_months = dt.year() as i64 * 12 + dt.month() as i64 - 1 + months;
    let year = (total_months / 12) as i32;
    let month = (total_months % 12 + 1) as u32;
    let day = dt.day().min(days_in_month(year, month));
    let hour = dt.hour();
    let min = dt.minute();
    let sec = dt.second();
    let naive = NaiveDateTime::new(
        NaiveDate::from_ymd_opt(year, month, day).unwrap_or(dt.date_naive()),
        dt.time(),
    );
    DateTime::from_naive_utc_and_offset(naive, Utc)
}

fn is_week_interval_match(base: DateTime<Utc>, current: DateTime<Utc>, interval: i64) -> bool {
    if interval <= 1 {
        return true;
    }
    let days_diff = (current - base).num_days();
    let weeks_diff = days_diff / 7;
    weeks_diff % interval == 0
}

fn days_in_month(year: i32, month: u32) -> u32 {
    match month {
        1 | 3 | 5 | 7 | 8 | 10 | 12 => 31,
        4 | 6 | 9 | 11 => 30,
        2 => {
            if (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) {
                29
            } else {
                28
            }
        }
        _ => 30,
    }
}

/// Get the Nth weekday of a month.
/// week_of_month: 0=first, 1=second, 2=third, 3=fourth, 4=last
/// day_of_week: 0=Monday, 1=Tuesday, ..., 6=Sunday
fn nth_weekday_of_month(
    dt: DateTime<Utc>,
    week_of_month: u32,
    day_of_week: u32,
) -> DateTime<Utc> {
    let year = dt.year();
    let month = dt.month();
    let first = NaiveDate::from_ymd_opt(year, month, 1).unwrap();
    let first_weekday = first.weekday().num_days_from_monday();
    let diff = (day_of_week + 7 - first_weekday) % 7;
    let target_day = 1 + diff + week_of_month * 7;
    let adjusted_day = target_day.min(days_in_month(year, month));
    let naive = NaiveDateTime::new(
        NaiveDate::from_ymd_opt(year, month, adjusted_day).unwrap_or(dt.date_naive()),
        dt.time(),
    );
    DateTime::from_naive_utc_and_offset(naive, Utc)
}

fn set_day(dt: DateTime<Utc>, day: u32) -> DateTime<Utc> {
    let adjusted = day.min(days_in_month(dt.year(), dt.month()));
    let naive = NaiveDateTime::new(
        NaiveDate::from_ymd_opt(dt.year(), dt.month(), adjusted).unwrap_or(dt.date_naive()),
        dt.time(),
    );
    DateTime::from_naive_utc_and_offset(naive, Utc)
}
