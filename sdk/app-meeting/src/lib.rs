use anyhow::Result;
use async_trait::async_trait;
use prost::Message;
use tracing::instrument;

use proto::idl::command::Command;
use proto::idl::meeting;
use service::network::common_request;
use service::ffi::ffi_push;
use service::{AppTrait, BizMeeting, Event, InitRequest, LoginRequest};

#[derive(Debug, Clone)]
pub struct AppMeeting;

impl AppMeeting {
    pub fn new() -> Self {
        AppMeeting
    }

    #[instrument(skip(self, param))]
    pub async fn meeting_create(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = meeting::MeetingCreateRequest::decode(param)?;
        let ack = common_request::<meeting::MeetingCreateResponse>(
            Command::MeetingCreate as i32,
            req.encode_to_vec(),
            None,
        ).await?;
        Ok((0, ack.encode_to_vec()))
    }

    #[instrument(skip(self, param))]
    pub async fn meeting_join(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = meeting::JoinMeetingRequest::decode(param)?;
        let ack = common_request::<meeting::JoinMeetingResponse>(
            Command::MeetingJoin as i32,
            req.encode_to_vec(),
            None,
        ).await?;
        Ok((0, ack.encode_to_vec()))
    }

    #[instrument(skip(self, param))]
    pub async fn meeting_leave(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = meeting::LeaveMeetingRequest::decode(param)?;
        common_request::<meeting::LeaveMeetingResponse>(
            Command::MeetingLeave as i32,
            req.encode_to_vec(),
            None,
        ).await?;
        Ok((0, vec![]))
    }

    #[instrument(skip(self, param))]
    pub async fn meeting_end(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = meeting::EndMeetingRequest::decode(param)?;
        common_request::<meeting::EndMeetingResponse>(
            Command::MeetingEnd as i32,
            req.encode_to_vec(),
            None,
        ).await?;
        Ok((0, vec![]))
    }

    #[instrument(skip(self, param))]
    pub async fn meeting_get_list(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = meeting::MeetingGetListRequest::decode(param)?;
        let ack = common_request::<meeting::MeetingGetListResponse>(
            Command::MeetingGetList as i32,
            req.encode_to_vec(),
            None,
        ).await?;
        Ok((0, ack.encode_to_vec()))
    }

    #[instrument(skip(self, param))]
    pub async fn meeting_get_info(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = meeting::GetMeetingInfoRequest::decode(param)?;
        let ack = common_request::<meeting::GetMeetingInfoResponse>(
            Command::MeetingGetInfo as i32,
            req.encode_to_vec(),
            None,
        ).await?;
        Ok((0, ack.encode_to_vec()))
    }

    #[instrument(skip(self, param))]
    pub async fn meeting_kick(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = meeting::KickMeetingRequest::decode(param)?;
        common_request::<meeting::KickMeetingResponse>(
            Command::MeetingKick as i32,
            req.encode_to_vec(),
            None,
        ).await?;
        Ok((0, vec![]))
    }

    #[instrument(skip(self, param))]
    pub async fn meeting_set_role(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = meeting::SetRoleRequest::decode(param)?;
        common_request::<meeting::SetRoleResponse>(
            Command::MeetingSetRole as i32,
            req.encode_to_vec(),
            None,
        ).await?;
        Ok((0, vec![]))
    }

    #[instrument(skip(self, param))]
    pub async fn meeting_invite(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = meeting::InviteMeetingRequest::decode(param)?;
        let ack = common_request::<meeting::InviteMeetingResponse>(
            Command::MeetingInvite as i32,
            req.encode_to_vec(),
            None,
        ).await?;
        Ok((0, ack.encode_to_vec()))
    }

    #[instrument(skip(self, param))]
    pub async fn handle_push_update(&self, param: &[u8]) -> Result<()> {
        let _push = meeting::MeetingPushUpdate::decode(param)?;
        let _ = ffi_push(Command::MeetingPushUpdate as i32, param.to_vec());
        Ok(())
    }
}

#[async_trait]
impl AppTrait for AppMeeting {
    fn init(&self, _req: &InitRequest) -> Result<()> {
        Ok(())
    }
    fn uninit(&self) -> Result<()> {
        Ok(())
    }
    fn login(&self, _req: &LoginRequest) -> Result<()> {
        Ok(())
    }
    fn logout(&self) -> Result<()> {
        Ok(())
    }

    fn ffi_commands(&self) -> Vec<i32> {
        vec![
            Command::MeetingCreate as i32,
            Command::MeetingJoin as i32,
            Command::MeetingLeave as i32,
            Command::MeetingEnd as i32,
            Command::MeetingGetList as i32,
            Command::MeetingGetInfo as i32,
            Command::MeetingKick as i32,
            Command::MeetingSetRole as i32,
            Command::MeetingInvite as i32,
        ]
    }

    fn net_commands(&self) -> Vec<i32> {
        vec![
            Command::MeetingPushUpdate as i32,
        ]
    }

    async fn on_ffi_command(&self, command: i32, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let cmd = Command::try_from(command)?;
        let ret = match cmd {
            Command::MeetingCreate => self.meeting_create(params).await,
            Command::MeetingJoin => self.meeting_join(params).await,
            Command::MeetingLeave => self.meeting_leave(params).await,
            Command::MeetingEnd => self.meeting_end(params).await,
            Command::MeetingGetList => self.meeting_get_list(params).await,
            Command::MeetingGetInfo => self.meeting_get_info(params).await,
            Command::MeetingKick => self.meeting_kick(params).await,
            Command::MeetingSetRole => self.meeting_set_role(params).await,
            Command::MeetingInvite => self.meeting_invite(params).await,
            _ => return Err(anyhow::anyhow!("not handled")),
        };
        ret
    }

    async fn on_net_command(&self, _source: i32, command: i32, params: &[u8]) -> Result<()> {
        let cmd = Command::try_from(command)?;
        match cmd {
            Command::MeetingPushUpdate => self.handle_push_update(params).await,
            _ => return Err(anyhow::anyhow!("not handled")),
        }
    }

    fn on_event(&self, _event: Event, _params: &[u8]) {}
}

impl BizMeeting for AppMeeting {}
