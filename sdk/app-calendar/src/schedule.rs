use anyhow::Result;
use prost::Message;
use tracing::debug;

use crate::{database, AppCalendar};
use proto::idl::{calendar, command::Command};
use service::{ffi::ffi_push, network::common_request};
use std::ops::DerefMut;

impl AppCalendar {
    pub async fn schedule_create(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = calendar::ScheduleCreateRequest::decode(param)?;
        debug!("create schedule, req: {req:?}");
        let ack = common_request::<calendar::ScheduleCreateResponse>(
            Command::ScheduleCreate as i32,
            req.encode_to_vec(),
            None,
        )
            .await?;
        debug!("create schedule, resp: {ack:?}");
        Ok((0, ack.encode_to_vec()))
    }

    pub async fn schedule_remove(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = calendar::ScheduleRemoveRequest::decode(param)?;
        debug!("remove schedule, req: {req:?}");
        let ack = common_request::<calendar::ScheduleRemoveResponse>(
            Command::ScheduleRemove as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((0, ack.encode_to_vec()))
    }

    pub async fn schedule_update(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = calendar::ScheduleUpdateRequest::decode(param)?;
        debug!("update schedule, req: {req:?}");
        let ack = common_request::<calendar::ScheduleUpdateResponse>(
            Command::ScheduleUpdate as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((0, ack.encode_to_vec()))
    }

    pub async fn schedule_pull_by_ids(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = calendar::SchedulePullByIdsRequest::decode(param)?;
        debug!("schedule pull by ids, req: {req:?}");
        let ack = common_request::<calendar::SchedulePullByIdsResponse>(
            Command::SchedulePullByIds as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        // 保存到本地
        if !ack.schedules.is_empty() {
            let mut conn = self.db.inner()?;
            let _ = database::schedule::schedule_batch_save(conn.deref_mut(), &ack.schedules)?;
        }
        Ok((0, ack.encode_to_vec()))
    }

    pub async fn schedule_pull_by_calendar_ids(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = calendar::SchedulePullByCalendarIdsRequest::decode(param)?;
        debug!("schedule pull by calendar ids, req: {req:?}");
        let ack = common_request::<calendar::SchedulePullByCalendarIdsResponse>(
            Command::SchedulePullByCalendarIds as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        // 保存到本地
        if !ack.schedules.is_empty() {
            let mut conn = self.db.inner()?;
            let _ = database::schedule::schedule_batch_save(conn.deref_mut(), &ack.schedules)?;
        }
        Ok((0, ack.encode_to_vec()))
    }

    pub async fn schedule_pull_busy(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = calendar::SchedulePullBusyRequest::decode(param)?;
        debug!("schedule pull busy, req: {req:?}");
        let ack = common_request::<calendar::SchedulePullBusyResponse>(
            Command::SchedulePullBusy as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((0, ack.encode_to_vec()))
    }

    pub async fn handle_push_schedule_update(&self, param: &[u8]) -> Result<()> {
        let push = calendar::SchedulePushUpdateRequest::decode(param)?;
        debug!("handle push schedule update, {push:?}");
        // 保存到本地 DB
        if !push.schedules.is_empty() {
            let mut conn = self.db.inner()?;
            database::schedule::schedule_batch_save(conn.deref_mut(), &push.schedules)?;
        }
        // ffi_push 透传到 Flutter
        let _ = ffi_push(Command::SchedulePushUpdate as i32, param.to_vec());
        Ok(())
    }

    pub async fn handle_push_schedule_delete(&self, param: &[u8]) -> Result<()> {
        let push = calendar::ScheduleDeletePush::decode(param)?;
        debug!("handle push schedule delete, {push:?}");
        let conn = self.db.inner()?;
        // 按 ids 逐个删除
        for id in &push.ids {
            let _ = database::schedule::schedule_remove_local(&conn, *id);
        }
        // 按 cycle_rule_id 批量删除
        if push.cycle_rule_id > 0 {
            if push.start_time > 0 {
                // start_time >= 此值：删除未来实例
                let _ = database::schedule::schedule_remove_future_by_cycle(
                    &conn,
                    push.cycle_rule_id,
                    push.start_time,
                );
            } else {
                // 删除整个 cycled 的所有实例
                let _ = database::schedule::schedule_remove_by_cycle_rule_id(&conn, push.cycle_rule_id);
            }
        }
        // ffi_push 透传到 Flutter
        let _ = ffi_push(Command::PushScheduleDelete as i32, param.to_vec());
        Ok(())
    }

    pub async fn handle_push_schedule_reminder(&self, param: &[u8]) -> Result<()> {
        let _push = calendar::ScheduleRemindPush::decode(param)?;
        debug!("handle push schedule reminder");
        // ffi_push 透传到 Flutter
        let _ = ffi_push(Command::PushScheduleReminder as i32, param.to_vec());
        Ok(())
    }
}
