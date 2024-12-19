use common::time::current_ms;
use loco_rs::{Error, Result, app::AppContext};
use moka::future::Cache;
use prost::Message;
use proto::idl::entity::cycle_rule;
use proto::idl::pipeline;
use std::collections::HashMap;
use std::sync::{Arc, LazyLock};
use tokio::sync::RwLock;
use tracing::{debug, warn};

use crate::calendar::CACHE_CALENDAR;
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
    let schedules = if schedule.cycle.is_none() {
        vec![schedule.clone()]
    } else {
        schedule_gen_by_rule(&schedule)?
    };

    ScheduleModel::create(&ctx.db, &schedules).await?;

    let _ = push_schedule_to_users(ctx, &schedule.member_ids, vec![schedule.clone()]).await;

    debug!("create schedule, resp: {resp:?}");

    Ok((0, resp.encode_to_vec()))
}

fn schedule_gen_by_rule(schedule: &entity::Schedule) -> Result<Vec<entity::Schedule>> {
    Ok(vec![])
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
    Ok((0, resp.encode_to_vec()))
}

pub(crate) async fn schedule_pull_by_ids(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let mut req = pb_decode::<calendar::SchedulePullByIdsRequest>(&packet.payload)?;
    let mut resp = calendar::SchedulePullByIdsResponse::default();
    debug!("schedule pull by ids, req: {req:?}");

    let mut schedules = ScheduleModel::get_by_ids(&ctx.db, req.ids.clone()).await?;
    resp.schedules = schedules
        .drain(..)
        .map(|s| ScheduleModel(s).into())
        .collect();
    Ok((0, vec![]))
}

pub(crate) async fn schedule_remove(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<calendar::ScheduleRemoveRequest>(&packet.payload)?;
    let mut resp = calendar::ScheduleRemoveResponse::default();
    debug!("schedule remove, req: {req:?}");
    let schedule = ScheduleModel::remove(&ctx.db, req.id).await?;

    let now = current_ms() as i64;
    let sid = id_gen(None);
    let biz = BizHub::get()?;
    let mut push = pipeline::PushEntityChanged::default();
    push.changes.push(entity::EntityChange {
        id: schedule.id,
        r#type: EntityType::Schedule as i32,
        version: now,
        operate: Operate::Delete as i32,
    });
    let _ = biz
        .gateway
        .send_packet_to_user(
            ctx,
            &schedule.member_ids,
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
    Ok((0, vec![]))
}
