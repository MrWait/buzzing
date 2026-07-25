use anyhow::Result;
use prost::Message as _;
use tracing::debug;

use crate::AppChat;
use proto::idl::{command::Command, error::ErrorCode, join_request};
use service::network::common_request;

impl AppChat {
    pub(crate) async fn join_request_create(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = join_request::JoinRequestCreateRequest::decode(params)?;
        debug!("join request create, req: {req:?}");
        let ack = common_request::<join_request::JoinRequestCreateResponse>(
            Command::ChatJoinRequestCreate as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn join_request_approve(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = join_request::JoinRequestApproveRequest::decode(params)?;
        debug!("join request approve, req: {req:?}");
        let ack = common_request::<join_request::JoinRequestApproveResponse>(
            Command::ChatJoinRequestApprove as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn join_request_reject(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = join_request::JoinRequestRejectRequest::decode(params)?;
        debug!("join request reject, req: {req:?}");
        let ack = common_request::<join_request::JoinRequestRejectResponse>(
            Command::ChatJoinRequestReject as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn join_request_list(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = join_request::JoinRequestListRequest::decode(params)?;
        debug!("join request list, req: {req:?}");
        let ack = common_request::<join_request::JoinRequestListResponse>(
            Command::ChatJoinRequestList as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }
}
