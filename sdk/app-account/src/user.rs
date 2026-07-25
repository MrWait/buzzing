use anyhow::Result;
use prost::Message;
use std::ops::DerefMut;
use tracing::debug;

use crate::{database, AppAccount};
use proto::idl::{command::Command, entity, error::ErrorCode, sdk, user};
use service::{ffi::ffi_push, network::common_request};

impl AppAccount {
    pub async fn user_get_by_ids(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = user::GetUserByIdsRequest::decode(params)?;
        debug!("user get by ids: {req:?}");
        let mut resp = user::GetUserByIdsResponse::default();
        let mut dirty;
        {
            let conn = self.db.inner()?;
            dirty = database::user::user_get_by_ids(&conn, &req.ids, &mut resp.users)?;
        }

        let mut missing = req.ids.clone();
        let ids: Vec<_> = resp.users.iter().map(|user| user.id).collect();
        missing.retain(|id| !ids.contains(id));
        dirty.extend(missing.iter());
        dirty.remove(&0);

        if !dirty.is_empty() {
            debug!("missing users: {:?}", dirty);
            let ids: Vec<i64> = dirty.iter().copied().collect();
            let mut users = self.user_pull_by_ids(ids, true).await?;
            let ack_ids: Vec<i64> = users.iter().map(|u| u.id).collect();
            resp.users.retain(|user| !ack_ids.contains(&user.id));
            resp.users.extend(users.drain(..));
        }

        debug!("user get by ids, resp: {resp:?}");

        Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
    }

    pub async fn user_pull_by_ids(&self, ids: Vec<i64>, push: bool) -> Result<Vec<entity::User>> {
        debug!("pull user by ids: {ids:?}");
        let req = user::GetUserByIdsRequest { ids };
        let mut ack = common_request::<user::GetUserByIdsResponse>(
            Command::UserGetByIds as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        debug!("pull user from server: {ack:?}");
        {
            let mut conn = self.db.inner()?;
            database::user::user_batch_save(conn.deref_mut(), &ack.users)?;
        }

        if push {
            let mut push = sdk::PushEntityChangeRequest::default();
            push.types.push(entity::EntityType::User as i32);
            push.entity
                .get_or_insert_default()
                .users
                .extend(ack.users.iter().map(|u| (u.id, u.clone())));
            debug!("push user info to client: {push:?}");
            let _ = ffi_push(Command::PushEntityChange as i32, push.encode_to_vec());
        }

        Ok(ack.users)
    }
}
