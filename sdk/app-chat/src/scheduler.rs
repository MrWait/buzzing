use anyhow::Result;
use prost::Message;

use proto::idl::{command::Command, timer};

use crate::AppChat;

impl AppChat {
    pub async fn schedule_message(&self, req: &timer::ScheduleMessageRequest) -> Result<timer::ScheduleMessageResponse> {
        let data = self
            .invoke(Command::ScheduleMessage as i32, req.encode_to_vec())
            .await?;
        Ok(timer::ScheduleMessageResponse::decode(data.as_slice())?)
    }

    pub async fn cancel_schedule(&self, req: &timer::CancelScheduleRequest) -> Result<timer::CancelScheduleResponse> {
        let data = self
            .invoke(Command::CancelSchedule as i32, req.encode_to_vec())
            .await?;
        Ok(timer::CancelScheduleResponse::decode(data.as_slice())?)
    }

    pub async fn get_scheduled_messages(
        &self,
        req: &timer::GetScheduledMessagesRequest,
    ) -> Result<timer::GetScheduledMessagesResponse> {
        let data = self
            .invoke(Command::GetScheduledMessages as i32, req.encode_to_vec())
            .await?;
        Ok(timer::GetScheduledMessagesResponse::decode(data.as_slice())?)
    }
}
