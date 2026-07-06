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
        let mut resp = calendar::SchedulePullByIdsResponse::default();
        // 优先从本地 DB 读取
        let mut missing_ids = req.ids.clone();
        if !missing_ids.is_empty() {
            let conn = self.db.inner()?;
            let mut local = Vec::new();
            let dirty = database::schedule::schedule_get_by_ids(&conn, &missing_ids, &mut local)?;
            if !local.is_empty() {
                resp.schedules.extend(local);
                // 已找到的 ID 从 missing 中移除
                missing_ids.retain(|id| !resp.schedules.iter().any(|s| s.id == *id));
            }
            // 脏数据需要从服务端刷新
            missing_ids.extend(dirty);
        }
        // fallback 到服务端
        if !missing_ids.is_empty() {
            let fetch_req = calendar::SchedulePullByIdsRequest {
                calendar_id: req.calendar_id,
                ids: missing_ids.clone(),
            };
            let ack = common_request::<calendar::SchedulePullByIdsResponse>(
                Command::SchedulePullByIds as i32,
                fetch_req.encode_to_vec(),
                None,
            )
            .await?;
            // 保存到本地
            if !ack.schedules.is_empty() {
                let mut conn = self.db.inner()?;
                let _ = database::schedule::schedule_batch_save(
                    conn.deref_mut(),
                    &ack.schedules,
                );
            }
            resp.schedules.extend(ack.schedules);
        }
        Ok((0, resp.encode_to_vec()))
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
        // ffi_push 透传 SCHEDULE_PUSH_UPDATE 给 Flutter（详情页刷新用）
        let _ = ffi_push(Command::SchedulePushUpdate as i32, param.to_vec());
        // 计算影响范围，推送 PUSH_SCHEDULE_UPDATE_BY_RANGE（列表刷新用）
        let mut cal_ids = Vec::new();
        let mut min_start = i64::MAX;
        let mut max_end = i64::MIN;
        let expand_ms = 120 * 86400_000i64;
        for s in &push.schedules {
            if !cal_ids.contains(&s.calendar_id) {
                cal_ids.push(s.calendar_id);
            }
            if s.start_time < min_start {
                min_start = s.start_time;
            }
            let end = if s.cycle.is_some() {
                s.start_time + expand_ms
            } else {
                s.end_time
            };
            if end > max_end {
                max_end = end;
            }
        }
        if min_start != i64::MAX && max_end != i64::MIN {
            let range = calendar::SchedulePushByRange {
                calendar_ids: cal_ids,
                start_time: min_start - 86400_000i64,
                end_time: max_end + 86400_000i64,
            };
            let _ = ffi_push(
                Command::PushScheduleUpdateByRange as i32,
                range.encode_to_vec(),
            );
        }
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

    pub async fn handle_push_schedule_update_by_range(&self, param: &[u8]) -> Result<()> {
        debug!("handle push schedule update by range");
        let _ = ffi_push(Command::PushScheduleUpdateByRange as i32, param.to_vec());
        Ok(())
    }
}
