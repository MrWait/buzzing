use anyhow::Result;
use prost::Message;
use tracing::debug;

use crate::AppCalendar;
use proto::idl::{calendar, command::Command};
use service::network::common_request;

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
        Ok((0, vec![]))
    }

    pub async fn schedule_pull_by_calendar_ids(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        Ok((0, vec![]))
    }

    pub async fn schedule_pull_busy(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = calendar::SchedulePullBusyRequest::decode(param)?;
        debug!("schedule pull busy, req: {req:?}");
        let ack = common_request::<calendar::SchedulePullBusyResponse>(
            Command::ScheduleUpdate as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((0, ack.encode_to_vec()))
    }

    pub async fn handle_push_schedule_update(&self, param: &[u8]) -> Result<()> {
        let push = calendar::SchedulePushUpdateRequest::decode(param)?;
        debug!("handle push schedule update, {push:?}");
        Ok(())
    }
}
