use anyhow::Result;
use prost::Message as _;
use tracing::debug;

use proto::idl::{command::Command, error::ErrorCode, timer};
use service::network::common_request;

use crate::AppChat;

impl AppChat {
    pub(crate) async fn schedule_message(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = timer::ScheduleMessageRequest::decode(params)?;
        debug!("schedule message, req: {req:?}");
        let ack = common_request::<timer::ScheduleMessageResponse>(
            Command::ScheduleMessage as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Ok as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn cancel_schedule(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = timer::CancelScheduleRequest::decode(params)?;
        debug!("cancel schedule, req: {req:?}");
        let ack = common_request::<timer::CancelScheduleResponse>(
            Command::CancelSchedule as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Ok as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn get_scheduled_messages(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = timer::GetScheduledMessagesRequest::decode(params)?;
        debug!("get scheduled messages, req: {req:?}");
        let ack = common_request::<timer::GetScheduledMessagesResponse>(
            Command::GetScheduledMessages as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Ok as i32, ack.encode_to_vec()))
    }
}
