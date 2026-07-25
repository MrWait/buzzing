use loco_rs::{Error, Result, app::AppContext};
use prost::Message;
use tracing::debug;

use crate::models::users;
use common::{model::UserBrief, pb_decode};
use proto::idl::{entity, user, error::ErrorCode};

pub async fn get_by_ids(
    ctx: &AppContext,
    _brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<user::GetUserByIdsRequest>(&packet.payload)?;
    debug!("user get by ids, req: {req:?}");
    let mut resp = user::GetUserByIdsResponse::default();

    if req.ids.is_empty() {
        return Ok((ErrorCode::Success as i32, resp.encode_to_vec()));
    }

    resp.users = users::UserModel::find_by_ids(&ctx.db, &req.ids)
        .await?
        .drain(..)
        .map(|user| users::UserModel(user).into())
        .collect();

    debug!("user get by ids, resp: {resp:?}");

    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}
