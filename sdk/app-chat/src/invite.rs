use anyhow::Result;
use prost::Message as _;
use tracing::debug;

use crate::AppChat;
use proto::idl::{command::Command, error::ErrorCode, invite};
use service::network::common_request;

impl AppChat {
    pub(crate) async fn invite_link_create(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = invite::InviteLinkCreateRequest::decode(params)?;
        debug!("invite link create, req: {req:?}");
        let ack = common_request::<invite::InviteLinkCreateResponse>(
            Command::ChatInviteLinkCreate as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn invite_link_join(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = invite::InviteLinkJoinRequest::decode(params)?;
        debug!("invite link join, req: {req:?}");
        let ack = common_request::<invite::InviteLinkJoinResponse>(
            Command::ChatInviteLinkJoin as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn invite_link_revoke(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = invite::InviteLinkRevokeRequest::decode(params)?;
        debug!("invite link revoke, req: {req:?}");
        let ack = common_request::<invite::InviteLinkRevokeResponse>(
            Command::ChatInviteLinkRevoke as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }
}
