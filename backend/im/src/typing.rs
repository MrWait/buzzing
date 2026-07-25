use loco_rs::{Result, app::AppContext};
use prost::Message;
use tracing::debug;

use common::{BizHub, UserBrief, pb_decode, rid};
use proto::idl::{command::Command, entity, error::ErrorCode, typing};

pub(crate) async fn handle_typing(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<typing::TypingRequest>(&packet.payload)?;
    debug!("typing, req: {req:?}");

    let member_ids = super::chat::chat_get_all_user_ids(ctx, req.chat_id).await?;
    if member_ids.is_empty() {
        return Ok((ErrorCode::Success as i32, vec![]));
    }

    let user_name = if let Ok(hub) = BizHub::get() {
        hub.user.get_user_by_id(ctx, brief.id).await.map(|u| u.name).unwrap_or_default()
    } else {
        String::new()
    };
    let expire_at_ms = common::time::current_ms() as i64 + 10_000;
    let push = typing::PushTyping {
        chat_id: req.chat_id,
        user_id: brief.id,
        user_name,
        expire_at_ms,
    };

    let target_ids: Vec<i64> = member_ids.into_iter().filter(|id| *id != brief.id).collect();
    if target_ids.is_empty() {
        return Ok((ErrorCode::Success as i32, vec![]));
    }

    if let Ok(hub) = BizHub::get() {
        hub.gateway
            .send_packet_to_user(
                ctx,
                &target_ids,
                rid(),
                Command::PushTyping,
                push.encode_to_vec(),
                false,
            )
            .await?;
    }

    debug!("typing push done");
    Ok((ErrorCode::Success as i32, vec![]))
}
