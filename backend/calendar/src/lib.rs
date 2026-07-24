pub mod calendar;
pub mod cycled;
pub mod models;
pub mod schedule;

use loco_rs::{Error, Result, app::AppContext};
use std::collections::HashMap;
use std::sync::Arc;
use tracing::debug;

use common::{BizCalendar, EntityIds, ExternApp, UserBrief, VecBool};
use proto::idl::{command::Command, entity};

mod workers;

#[derive(Clone)]
pub struct AppCalendar;
#[async_trait::async_trait]
impl ExternApp for AppCalendar {
    fn serve(&self, ctx: &AppContext) {
        workers::start_batch_remind_worker(ctx);
        workers::start_remind_worker(ctx);
    }

    fn handled_command(&self) -> Vec<i32> {
        vec![
            // calendar
            Command::CalendarCreate as i32,
            Command::CalendarDelete as i32,
            Command::CalendarGetList as i32,
            Command::CalendarSearch as i32,
            Command::CalendarSubscribe as i32,
            Command::CalendarUpdate as i32,
            // schedule
            Command::ScheduleCreate as i32,
            Command::SchedulePullBusy as i32,
            Command::SchedulePullByCalendarIds as i32,
            Command::SchedulePullByIds as i32,
            Command::ScheduleRemove as i32,
            Command::ScheduleUpdate as i32,
        ]
    }

    async fn handle_client_packet(
        &self,
        _cmd: i32,
        ctx: &AppContext,
        brief: &UserBrief,
        packet: &entity::Packet,
        ws: bool,
    ) -> Result<(i32, Vec<u8>)> {
        let cmd: Command = packet
            .cmd
            .try_into()
            .map_err(|_| Error::string("cmd parse error"))?;
        let (code, data) = match cmd {
            // calendar
            Command::CalendarCreate => calendar::calendar_create(ctx, brief, packet, ws).await?,
            Command::CalendarDelete => calendar::calendar_delete(ctx, brief, packet, ws).await?,
            Command::CalendarSearch => calendar::calendar_search(ctx, brief, packet, ws).await?,
            Command::CalendarGetList => calendar::calendar_get_list(ctx, brief, packet, ws).await?,
            Command::CalendarSubscribe => {
                calendar::calendar_subscribe(ctx, brief, packet, ws).await?
            }
            Command::CalendarUpdate => calendar::calendar_update(ctx, brief, packet, ws).await?,
            // schedule
            Command::ScheduleCreate => schedule::schedule_create(ctx, brief, packet, ws).await?,
            Command::SchedulePullBusy => {
                schedule::schedule_pull_busy(ctx, brief, packet, ws).await?
            }
            Command::SchedulePullByCalendarIds => {
                schedule::schedule_pull_by_calendar_ids(ctx, brief, packet, ws).await?
            }
            Command::SchedulePullByIds => {
                schedule::schedule_pull_by_ids(ctx, brief, packet, ws).await?
            }
            Command::ScheduleRemove => schedule::schedule_remove(ctx, brief, packet, ws).await?,
            Command::ScheduleUpdate => schedule::schedule_update(ctx, brief, packet, ws).await?,
            _ => {
                return Err(Error::NotFound);
            }
        };
        debug!("calendar handled, code: {code}");
        Ok((code, data))
    }
}

#[async_trait::async_trait]
impl BizCalendar for AppCalendar {
    async fn create_user_default(
        &self,
        ctx: &AppContext,
        user_id: i64,
        tenant_id: i64,
        user_name: &str,
    ) -> Result<()> {
        calendar::create_user_default(ctx, user_id, tenant_id, user_name).await?;
        Ok(())
    }

    async fn list_calendars(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        _tenant_id: i64,
    ) -> Result<Vec<entity::Calendar>> {
        use crate::models::calendars::CalendarModel;
        let mut list = CalendarModel::get_by_user_id(&ctx.db, brief.id).await?;
        Ok(list.drain(..).map(|c| CalendarModel(c).into()).collect())
    }

    async fn list_events(
        &self,
        ctx: &AppContext,
        _brief: &UserBrief,
        calendar_id: i64,
        start: i64,
        end: i64,
    ) -> Result<Vec<entity::Schedule>> {
        use crate::models::schedules::ScheduleModel;
        let mut list =
            ScheduleModel::find_by_calendar_ids(&ctx.db, vec![calendar_id], start, end).await?;
        Ok(list.drain(..).map(|s| ScheduleModel(s).into()).collect())
    }

    async fn create_event(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        calendar_id: i64,
        title: &str,
        start_time: i64,
        end_time: i64,
        attendees: &[i64],
    ) -> Result<i64> {
        use crate::models::schedules::ScheduleModel;
        use common::id_gen;
        use common::time::current_ms;

        let id = id_gen(None);
        let now = current_ms() as i64;
        let mut member_ids = attendees.to_vec();
        if !member_ids.contains(&brief.id) {
            member_ids.push(brief.id);
        }
        let schedule = entity::Schedule {
            id,
            calendar_id,
            title: title.to_owned(),
            start_time,
            end_time,
            owner: brief.id,
            tenant_id: brief.tenant_id,
            version: now,
            member_ids,
            ..Default::default()
        };
        ScheduleModel::create(&ctx.db, &[schedule]).await?;
        Ok(id)
    }
}
