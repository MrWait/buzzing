use loco_rs::{Result, app::AppContext};
use tracing::debug;

use common::{UserBrief, pb_decode};
use proto::idl::{entity, error::ErrorCode, thread};

use crate::models::messages::MessageModel;

pub(crate) async fn get_thread(
    ctx: &AppContext,
    _brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<thread::GetThreadRequest>(&packet.payload)?;
    debug!("get thread, req: {req:?}");

    let (db_messages, total) = MessageModel::find_by_thread_root(
        &ctx.db,
        req.chat_id,
        req.root_message_id,
        req.page,
        req.page_size,
    )
    .await?;

    let mut resp = thread::GetThreadResponse {
        total,
        ..Default::default()
    };

    for msg in db_messages {
        let e_msg: entity::Message = MessageModel(msg).into();
        resp.messages.push(e_msg);
    }

    debug!("get thread done, total: {}", resp.total);
    Ok((ErrorCode::Ok as i32, resp.encode_to_vec()))
}
