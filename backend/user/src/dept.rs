use loco_rs::{Error, Result, app::AppContext};
use prost::Message;

use crate::models::{depts, tenants, users};
use common::{model::UserBrief, pb_decode};
use proto::idl::{dept, entity};

#[allow(unused_variables)]
pub async fn get_dept(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<dept::GetDeptRequest>(&packet.payload)?;
    let mut resp = dept::GetDeptResponse::default();

    tracing::debug!("get dept, req: {req:?}");

    let id = if req.id == 0 {
        let tenant = tenants::TenantModel::find_by_id(&ctx.db, req.tenant_id).await?.0;
        tenant.root_dept_id
    } else {
        req.id
    };

    resp.depts = depts::Model::find_by_parent_id(&ctx.db, id)
        .await?
        .drain(..)
        .map(|dept| (dept.0.id, dept.into()))
        .collect();
    resp.users = users::UserModel::find_by_dept_id(&ctx.db, id)
        .await?
        .drain(..)
        .map(|user| (user.0.id, user.into()))
        .collect();
    tracing::debug!("get dept, resp: {resp:?}");
    Ok((0, resp.encode_to_vec()))
}
