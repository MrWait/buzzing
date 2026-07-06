use common::time::current_ms;
use loco_rs::{Error, Result, app::AppContext, prelude::*};
use moka::future::Cache;
use prost::Message;
use proto::idl::entity::cycle_rule;
use proto::idl::pipeline;
use std::collections::HashMap;
use std::sync::{Arc, LazyLock};
use tokio::sync::RwLock;
use tracing::{debug, warn};

use crate::calendar::CACHE_CALENDAR;
use crate::cycled;
use crate::models::cycleds::CycledModel;
use crate::models::schedule_reminders::ScheduleReminderModel;
use crate::models::schedules::ScheduleModel;
use crate::schedule;
use common::{BizHub, EntityIds, EntityStatus, EntityType, Operate, UserBrief};
use common::{id_gen, pb_decode, rid};
use proto::idl::{calendar, command::Command, entity, error::ErrorCode, feed};

async fn push_schedule_to_users(
    ctx: &AppContext,
    user_ids: &[i64],
    schedules: Vec<entity::Schedule>,
) -> Result<()> {
    if user_ids.is_empty() || schedules.is_empty() {
        return Ok(());
    }
    let biz = BizHub::get()?;
    let rid = id_gen(None);
    let push = calendar::SchedulePushUpdateRequest {
        schedules,
    };
    let _ = biz
        .gateway
        .send_packet_to_user(
            ctx,
            user_ids,
            rid,
            Command::SchedulePushUpdate,
            push.encode_to_vec(),
            true,
        )
        .await?;
    Ok(())
}
pub(crate) async fn schedule_create(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let mut req = pb_decode::<calendar::ScheduleCreateRequest>(&packet.payload)?;
    let mut resp = calendar::ScheduleCreateResponse::default();
    debug!("schedule create, req: {req:?}");
    let mut schedule = if let Some(s) = req.schedule.take() {
        s
    } else {
        return Ok((ErrorCode::ErrorParamInvalid as i32, vec![]));
    };
    let calendar = CACHE_CALENDAR.get(ctx, &schedule.calendar_id).await?;
    {
        let cal = calendar.read().await;
        if let Some(sub) = cal.subscribers.subscribers.get(&brief.id) {
            if sub.role < entity::CalendarRole::RoleEditor as i32 {
                return Ok((ErrorCode::ErrorNoPermision as i32, vec![]));
            }
        } else {
            return Ok((ErrorCode::ErrorNoPermision as i32, vec![]));
        }
    }

    let id = id_gen(None);
    let now = current_ms() as i64;
    schedule.owner = brief.id;
    schedule.tenant_id = brief.tenant_id;
    schedule.version = now;
    schedule.id = id;
    if let Some(ref mut rule) = schedule.cycle {
        rule.id = id;
        rule.calendar_id = schedule.calendar_id;
        rule.version = now;
    }

    resp.schedule = Some(schedule.clone());

    if let Some(ref rule) = schedule.cycle {
        let expand_start = schedule.start_time;
        let expand_end = schedule.end_time + 120 * 86400_000i64;
        CycledModel::create_with_expand(&ctx.db, &schedule, expand_start, expand_end).await?;
        let instances = schedule_gen_by_rule(&schedule)?;
        ScheduleModel::create(&ctx.db, &instances).await?;
    } else {
        ScheduleModel::create(&ctx.db, &[schedule.clone()]).await?;
    }

    let _ = push_schedule_to_users(ctx, &schedule.member_ids, vec![schedule.clone()]).await;

    // 即时生成提醒
    let ctx_clone = ctx.clone();
    let schedule_clone = schedule.clone();
    tokio::spawn(async move {
        let _ = generate_reminders_immediate(&ctx_clone, &schedule_clone).await;
    });

    debug!("create schedule, resp: {resp:?}");

    Ok((0, resp.encode_to_vec()))
}

fn schedule_gen_by_rule(schedule: &entity::Schedule) -> Result<Vec<entity::Schedule>> {
    cycled::gen_by_rule(schedule)
}

pub(crate) async fn schedule_pull_busy(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let mut req = pb_decode::<calendar::SchedulePullBusyRequest>(&packet.payload)?;
    let mut resp = calendar::SchedulePullBusyResponse::default();
    debug!("schedule pull busy, req: {req:?}");

    let mut schedules = ScheduleModel::find_by_user_ids(
        &ctx.db,
        req.user_ids.clone(),
        req.start_time,
        req.end_time,
    )
    .await?;
    for schedule in schedules.drain(..) {
        let sche: entity::Schedule = ScheduleModel(schedule).into();
        for user_id in req.user_ids.iter() {
            if sche.member_ids.contains(user_id) {
                resp.schedules
                    .entry(*user_id)
                    .or_insert(entity::UserScheduleBrief::default())
                    .briefs
                    .push(entity::user_schedule_brief::Brief {
                        id: sche.id,
                        calendar_id: sche.calendar_id,
                        name: sche.title.clone(),
                        start_time: sche.start_time,
                        end_time: sche.end_time,
                    });
            }
        }
    }

    // 展开 cycled 实例算忙闲
    let calendars_used: Vec<i64> = resp.schedules.iter().flat_map(|(_, brief)| {
        brief.briefs.iter().map(|b| b.calendar_id)
    }).collect::<std::collections::HashSet<i64>>()
        .into_iter().collect();
    let cycleds = CycledModel::find_active_by_calendar_ids(&ctx.db, calendars_used).await?;
    for cycled in &cycleds {
        let template = CycledModel(cycled.clone()).template_as_schedule();
        if let Ok(instances) = cycled::gen_by_rule(&template) {
            for inst in instances {
                if inst.start_time >= req.start_time && inst.start_time < req.end_time {
                    for user_id in req.user_ids.iter() {
                        if inst.member_ids.contains(user_id) {
                            resp.schedules
                                .entry(*user_id)
                                .or_insert(entity::UserScheduleBrief::default())
                                .briefs
                                .push(entity::user_schedule_brief::Brief {
                                    id: inst.id,
                                    calendar_id: inst.calendar_id,
                                    name: inst.title.clone(),
                                    start_time: inst.start_time,
                                    end_time: inst.end_time,
                                });
                        }
                    }
                }
            }
        }
    }

    Ok((0, resp.encode_to_vec()))
}

pub(crate) async fn schedule_pull_by_calendar_ids(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let mut req = pb_decode::<calendar::SchedulePullByCalendarIdsRequest>(&packet.payload)?;
    let mut resp = calendar::SchedulePullByCalendarIdsResponse::default();
    debug!("schedule pull by calendar ids, req: {req:?}");
    if req.calendar_ids.contains(&brief.id) {
        let mut schedules =
            ScheduleModel::find_by_user_ids(&ctx.db, vec![brief.id], req.start_time, req.end_time)
                .await?;
        resp.schedules = schedules
            .drain(..)
            .map(|m| ScheduleModel(m).into())
            .collect();

        req.calendar_ids.retain(|id| *id != brief.id);
    }
    if !req.calendar_ids.is_empty() {
        let mut schedules = ScheduleModel::find_by_calendar_ids(
            &ctx.db,
            req.calendar_ids.clone(),
            req.start_time,
            req.end_time,
        )
        .await?;
        resp.schedules
            .extend(schedules.drain(..).map(|m| ScheduleModel(m).into()));
    }

    // 按需展开 cycled
    let cycleds = CycledModel::find_active_by_calendar_ids(&ctx.db, req.calendar_ids.clone()).await?;
    for cycled in &cycleds {
        let template = CycledModel(cycled.clone()).template_as_schedule();
        if cycled.expand_end.unwrap_or(0) < req.end_time {
            // 展开窗口不足，重新展开
            let new_end = req.end_time.max(template.start_time + 120 * 86400_000i64);
            CycledModel::update_expand_end(&ctx.db, cycled.id, new_end).await?;
        }
        // 只有 template 的 start_time 在请求范围内时才展开
        if template.start_time < req.end_time {
            if let Ok(instances) = cycled::gen_by_rule(&template) {
                // 只添加在请求时间范围内的实例
                for inst in instances {
                    if inst.start_time >= req.start_time && inst.start_time < req.end_time {
                        // 检查是否已存在于 resp.schedules 中
                        if !resp.schedules.iter().any(|s| s.id == inst.id) {
                            resp.schedules.push(inst);
                        }
                    }
                }
            }
        }
    }

    debug!("schedule pull by calendar ids, resp: {resp:?}");

    Ok((0, resp.encode_to_vec()))
}

pub(crate) async fn schedule_pull_by_ids(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<calendar::SchedulePullByIdsRequest>(&packet.payload)?;
    let mut resp = calendar::SchedulePullByIdsResponse::default();
    debug!("schedule pull by ids, req: {req:?}");

    let mut schedules = ScheduleModel::get_by_ids(&ctx.db, req.ids.clone()).await?;
    resp.schedules = schedules
        .drain(..)
        .map(|s| ScheduleModel(s).into())
        .collect();
    debug!("schedule pull by ids, resp: {resp:?}");
    Ok((0, resp.encode_to_vec()))
}

pub(crate) async fn schedule_remove(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<calendar::ScheduleRemoveRequest>(&packet.payload)?;
    let resp = calendar::ScheduleRemoveResponse::default();
    debug!("schedule remove, req: {req:?}");

    let now = current_ms() as i64;
    let scope = req.modify_scope;
    let schedule = ScheduleModel::get_by_ids(&ctx.db, vec![req.id]).await?
        .into_iter().next()
        .ok_or_else(|| Error::string("schedule not found"))?;

    let mut removed_ids = vec![req.id];
    let mut member_ids = schedule.member_ids.clone();

    if scope == 1 {
        // 全部: delete all instances + cycled
        if schedule.cycle_rule_id > 0 {
            let instances = ScheduleModel::remove_by_cycle_id(&ctx.db, schedule.cycle_rule_id).await?;
            removed_ids.extend(instances.iter().map(|s| s.id));
            for inst in &instances {
                if inst.member_ids.iter().any(|uid| !member_ids.contains(uid)) {
                    member_ids.extend(inst.member_ids.clone());
                }
            }
            CycledModel::remove(&ctx.db, schedule.cycle_rule_id).await?;
        } else {
            ScheduleModel::remove(&ctx.db, req.id).await?;
        }
    } else if scope == 2 {
        // 以后: split cycled, delete future instances
        if schedule.cycle_rule_id > 0 {
            let future = ScheduleModel::remove_future_by_cycle(&ctx.db, schedule.cycle_rule_id, schedule.start_time)
                .await?;
            removed_ids.extend(future.iter().map(|s| s.id));
            for inst in &future {
                if inst.member_ids.iter().any(|uid| !member_ids.contains(uid)) {
                    member_ids.extend(inst.member_ids.clone());
                }
            }
            CycledModel::update_stop_at(&ctx.db, schedule.cycle_rule_id, schedule.start_time).await?;
        } else {
            ScheduleModel::remove(&ctx.db, req.id).await?;
        }
    } else {
        // 仅此: mark cancelled + add exception
        ScheduleModel::mark_cancelled(&ctx.db, req.id).await?;
        if schedule.cycle_rule_id > 0 {
            CycledModel::add_exception_time(&ctx.db, schedule.cycle_rule_id, schedule.start_time).await?;
        } else {
            ScheduleModel::remove(&ctx.db, req.id).await?;
        }
    }

    let sid = id_gen(None);
    let biz = BizHub::get()?;
    let push = pipeline::PushEntityChanged::default();
    let _ = biz
        .gateway
        .send_packet_to_user(
            ctx,
            &member_ids,
            sid,
            Command::PushEntityChange,
            push.encode_to_vec(),
            true,
        )
        .await;

    Ok((0, resp.encode_to_vec()))
}

pub(crate) async fn schedule_update(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let mut req = pb_decode::<calendar::ScheduleUpdateRequest>(&packet.payload)?;
    let mut resp = calendar::ScheduleUpdateResponse::default();
    debug!("schedule update, req: {req:?}");

    let src = req.schedule.take().ok_or_else(|| Error::string("schedule_update: no schedule"))?;
    let scope = req.modify_scope;
    let now = current_ms() as i64;
    let mut updated = src.clone();
    updated.version = now;

    if scope == 1 {
        // 全部: update template + all instances
        if let Some(ref rule) = updated.cycle {
            updated.cycle_rule_id = rule.id;
            CycledModel::update_template(&ctx.db, rule.id, &updated, now).await?;
            ScheduleModel::update_by_cycle_rule_id(&ctx.db, rule.id, &updated).await?;
        }
        ScheduleModel::update(&ctx.db, updated.id, &updated).await?;
    } else if scope == 2 {
        // 以后: split cycled, update future instances
        if let Some(ref rule) = updated.cycle {
            let old_rule_id = updated.cycle_rule_id;
            updated.cycle_rule_id = rule.id;
            let new_id = id_gen(None);

            CycledModel::create_split_with_expand(
                &ctx.db,
                new_id,
                old_rule_id,
                &updated,
                updated.start_time,
                updated.start_time + 120 * 86400_000i64,
                now,
            ).await?;

            ScheduleModel::remove_future_by_cycle(&ctx.db, old_rule_id, updated.start_time).await?;
            CycledModel::update_stop_at(&ctx.db, old_rule_id, updated.start_time).await?;

            let instances = schedule_gen_by_rule(&updated)?;
            ScheduleModel::create(&ctx.db, &instances).await?;
        } else {
            ScheduleModel::update(&ctx.db, updated.id, &updated).await?;
        }
    } else {
        // 仅此: update single instance + add exception to cycled
        if updated.cycle_rule_id > 0 {
            CycledModel::add_exception_time(&ctx.db, updated.cycle_rule_id, updated.start_time).await?;
            updated.cycle_rule_id = 0;
            updated.cycle = None;
        }
        ScheduleModel::update(&ctx.db, updated.id, &updated).await?;
    }

    resp.schedule = Some(updated.clone());
    let _ = push_schedule_to_users(ctx, &updated.member_ids, vec![updated.clone()]).await;

    // 即时生成提醒
    let ctx_clone = ctx.clone();
    let schedule_clone = updated.clone();
    tokio::spawn(async move {
        let _ = generate_reminders_immediate(&ctx_clone, &schedule_clone).await;
    });

    debug!("schedule update, resp: {resp:?}");

    Ok((0, resp.encode_to_vec()))
}

/// 为单个日程生成未来 2 小时内的提醒行
async fn generate_reminders_immediate(
    ctx: &AppContext,
    schedule: &entity::Schedule,
) -> Result<()> {
    let now = current_ms() as i64;
    let end_range = now + 7200_000i64;
    if schedule.start_time < now || schedule.start_time > end_range {
        return Ok(());
    }
    let mut reminders = Vec::new();
    for notify_min in &schedule.notify_time {
        let remind_at = schedule.start_time - (*notify_min as i64 * 60_000);
        if remind_at > now && remind_at < end_range {
            for uid in &schedule.member_ids {
                reminders.push((schedule.id, *uid, remind_at, *notify_min));
            }
        }
    }
    if !reminders.is_empty() {
        ScheduleReminderModel::batch_insert_ignore(&ctx.db, reminders).await?;
    }
    Ok(())
}
