use anyhow::Result;
use prost::Message;
use std::ops::DerefMut;
use tracing::debug;

use crate::{database, AppAccount};
use proto::idl::{command::Command, dept, entity, error::ErrorCode, sdk, user};
use service::{ffi::ffi_push, network::common_request};

impl AppAccount {
    pub async fn dept_get_by_id(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = dept::GetDeptRequest::decode(params)?;
        debug!("dept get by ids, req: {req:?}");
        let ack = common_request::<dept::GetDeptResponse>(
            Command::DeptGetById as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        debug!("dept get by ids, resp: {ack:?}");
        Ok((ErrorCode::Success as i32, ack.encode_to_vec()))
    }
}
