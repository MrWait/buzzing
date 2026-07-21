use loco_rs::{Error, Result, app::AppContext};
use prost::Message;
use sea_orm::{ConnectionTrait, DbBackend, FromQueryResult, Statement};
use tracing::debug;

use crate::chat::{chat_cache_get, chat_get_all_user_ids};
use crate::models::{chats::ChatModel, feeds::FeedModel};
use common::{common_error, id_gen, pb_decode, time::current_ms, UserBrief};
use proto::idl::{entity, error::ErrorCode, invite};

fn generate_code() -> String {
    use std::time::{SystemTime, UNIX_EPOCH};
    let ts = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_millis();
    let mut code = format!("{:x}", ts);
    code.truncate(12);
    code
}

#[derive(Debug, FromQueryResult)]
struct InviteLinkRow {
    id: i64,
    chat_id: i64,
    code: String,
    created_by: i64,
    created_at: chrono::DateTime<chrono::FixedOffset>,
    expires_at: Option<chrono::DateTime<chrono::FixedOffset>>,
    max_uses: i32,
    use_count: i32,
    is_active: bool,
}

pub(crate) async fn invite_link_create(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<invite::InviteLinkCreateRequest>(&packet.payload)?;
    debug!("invite link create, req: {req:?}");
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

    let code = generate_code();
    let expires_at = if req.expires_at > 0 {
        Some(common::time::date_time(req.expires_at))
    } else {
        None
    };

    let stmt = Statement::from_sql_and_values(
        DbBackend::Postgres,
        r#"
        INSERT INTO invite_links (id, chat_id, code, created_by, created_at, expires_at, max_uses, use_count, is_active)
        VALUES ($1, $2, $3, $4, NOW(), $5, $6, 0, true)
        "#,
        vec![
            id_gen(None).into(),
            req.chat_id.into(),
            code.clone().into(),
            brief.id.into(),
            expires_at.into(),
            req.max_uses.into(),
        ],
    );
    ctx.db.execute(stmt).await.map_err(|e| common_error(&format!("create invite link error: {e}")))?;

    let resp = invite::InviteLinkCreateResponse {
        code: code.clone(),
        url: format!("buzzing://invite/{}", code),
    };

    debug!("invite link create done, code: {code}");
    Ok((0, resp.encode_to_vec()))
}

pub(crate) async fn invite_link_join(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<invite::InviteLinkJoinRequest>(&packet.payload)?;
    debug!("invite link join, req: {req:?}");
    let mut resp = invite::InviteLinkJoinResponse::default();

    let row = InviteLinkRow::find_by_statement(Statement::from_sql_and_values(
        DbBackend::Postgres,
        "SELECT id, chat_id, code, created_by, created_at, expires_at, max_uses, use_count, is_active FROM invite_links WHERE code = $1",
        vec![req.code.clone().into()],
    ))
    .one(&ctx.db)
    .await
    .map_err(|e| common_error(&format!("query invite link error: {e}")))?
    .ok_or_else(|| Error::string("invite link not found"))?;

    if !row.is_active {
        return Err(common_error("invite link is revoked"));
    }
    if let Some(expires) = row.expires_at {
        if expires.timestamp_millis() < current_ms() as i64 {
            return Err(common_error("invite link has expired"));
        }
    }
    if row.max_uses > 0 && row.use_count >= row.max_uses {
        return Err(common_error("invite link usage limit reached"));
    }

    let context = chat_cache_get(ctx, row.chat_id).await?;

    // 检查是否已是成员
    {
        let c = context.read().await;
        if c.cmv.contains_key(brief.id) {
            resp.chat_id = row.chat_id;
            resp.chat = Some(c.get_entity());
            return Ok((0, resp.encode_to_vec()));
        }
    }

    // 加入群聊
    {
        let mut c = context.write().await;
        if c.cmv.add(&vec![brief.id])? {
            ChatModel::update_cmv(&ctx.db, c.chat.id, None, None, &mut c.cmv).await?;
            let _ = FeedModel::create_by_chat(&ctx.db, &c.chat, &vec![brief.id]).await;
            resp.chat_id = row.chat_id;
            resp.chat = Some(c.get_entity());
        }
    }

    // 递增 use_count
    let stmt = Statement::from_sql_and_values(
        DbBackend::Postgres,
        "UPDATE invite_links SET use_count = use_count + 1 WHERE id = $1",
        vec![row.id.into()],
    );
    let _ = ctx.db.execute(stmt).await;

    let member_ids = chat_get_all_user_ids(ctx, row.chat_id).await?;
    let _ = crate::feed::update_feed_status(ctx, row.chat_id, &member_ids, None).await;

    debug!("invite link join done, chat_id: {}", row.chat_id);
    Ok((0, resp.encode_to_vec()))
}

pub(crate) async fn invite_link_revoke(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<invite::InviteLinkRevokeRequest>(&packet.payload)?;
    debug!("invite link revoke, req: {req:?}");
    let resp = invite::InviteLinkRevokeResponse::default();

    let row = InviteLinkRow::find_by_statement(Statement::from_sql_and_values(
        DbBackend::Postgres,
        "SELECT id, chat_id, code, created_by, created_at, expires_at, max_uses, use_count, is_active FROM invite_links WHERE code = $1",
        vec![req.code.clone().into()],
    ))
    .one(&ctx.db)
    .await
    .map_err(|e| common_error(&format!("query invite link error: {e}")))?
    .ok_or_else(|| Error::string("invite link not found"))?;

    let context = chat_cache_get(ctx, row.chat_id).await?;
    {
        let c = context.read().await;
        let is_owner = c.chat.owner_id == brief.id;
        let is_admin = c.chat.admin_ids.contains(&brief.id);
        if !is_owner && !is_admin {
            return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
        }
    }

    let stmt = Statement::from_sql_and_values(
        DbBackend::Postgres,
        "UPDATE invite_links SET is_active = false WHERE id = $1",
        vec![row.id.into()],
    );
    ctx.db.execute(stmt).await.map_err(|e| common_error(&format!("revoke invite link error: {e}")))?;

    debug!("invite link revoke done");
    Ok((0, resp.encode_to_vec()))
}
