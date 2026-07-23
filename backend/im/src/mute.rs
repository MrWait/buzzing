use loco_rs::{Result, app::AppContext};
use prost::Message;
use sea_orm::{ConnectionTrait, DbBackend, Statement};
use tracing::debug;

use crate::chat::{chat_cache_get, chat_get_all_user_ids};
use common::{common_error, pb_decode, UserBrief};
use proto::idl::{entity, error::ErrorCode, mute};

pub(crate) async fn mute_member(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<mute::MuteMemberRequest>(&packet.payload)?;
    debug!("mute member, req: {req:?}");
    let context = chat_cache_get(ctx, req.chat_id).await?;

    {
        let c = context.read().await;
        if c.chat.r#type == entity::ChatType::ChatP2p as i16 {
            return Ok((ErrorCode::ErrorNoPermision as i32, vec![]));
        }
        let is_owner = c.chat.owner_id == brief.id;
        let is_admin = c.chat.admin_ids.contains(&brief.id);
        if !is_owner && !is_admin {
            return Ok((ErrorCode::ErrorNoPermision as i32, vec![]));
        }
        if !c.cmv.contains_key(req.member_id) {
            return Ok((ErrorCode::ErrorNoPermision as i32, vec![]));
        }
    }

    if req.until_ms <= 0 {
        let stmt = Statement::from_sql_and_values(
            DbBackend::Postgres,
            "DELETE FROM group_mutes WHERE chat_id = $1 AND member_id = $2",
            vec![req.chat_id.into(), req.member_id.into()],
        );
        ctx.db.execute(stmt).await.map_err(|e| common_error(&format!("unmute error: {e}")))?;
    } else {
        let muted_until = common::time::date_time(req.until_ms);
        let stmt = Statement::from_sql_and_values(
            DbBackend::Postgres,
            r#"
            INSERT INTO group_mutes (id, chat_id, member_id, muted_until, created_at, updated_at)
            VALUES ($1, $2, $3, $4, NOW(), NOW())
            ON CONFLICT (chat_id, member_id) DO UPDATE SET
                muted_until = EXCLUDED.muted_until,
                updated_at = NOW()
            "#,
            vec![
                common::id_gen(None).into(),
                req.chat_id.into(),
                req.member_id.into(),
                muted_until.into(),
            ],
        );
        ctx.db.execute(stmt).await.map_err(|e| common_error(&format!("mute error: {e}")))?;
    }

    debug!("mute member done");
    Ok((0, vec![]))
}

pub(crate) async fn global_mute(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<mute::GlobalMuteRequest>(&packet.payload)?;
    debug!("global mute, req: {req:?}");
    let context = chat_cache_get(ctx, req.chat_id).await?;

    {
        let c = context.read().await;
        if c.chat.r#type == entity::ChatType::ChatP2p as i16 {
            return Ok((ErrorCode::ErrorNoPermision as i32, vec![]));
        }
        let is_owner = c.chat.owner_id == brief.id;
        let is_admin = c.chat.admin_ids.contains(&brief.id);
        if !is_owner && !is_admin {
            return Ok((ErrorCode::ErrorNoPermision as i32, vec![]));
        }
    }

    let global_mute_until = if req.until_ms > 0 {
        Some(common::time::date_time(req.until_ms))
    } else {
        None
    };

    let stmt = Statement::from_sql_and_values(
        DbBackend::Postgres,
        "UPDATE chats SET global_mute_until = $1 WHERE id = $2",
        vec![global_mute_until.into(), req.chat_id.into()],
    );
    ctx.db.execute(stmt).await.map_err(|e| common_error(&format!("global mute error: {e}")))?;

    let member_ids = chat_get_all_user_ids(ctx, req.chat_id).await?;
    let mut entity = entity::Entity::default();
    {
        let c = context.read().await;
        entity.chats.insert(req.chat_id, c.get_entity());
    }
    let _ = crate::feed::push_entity(ctx, &member_ids, entity).await;

    debug!("global mute done");
    Ok((0, vec![]))
}
