use loco_rs::{Error, Result, app::AppContext};
use prost::Message;
use sea_orm::{ConnectionTrait, DbBackend, FromQueryResult, Statement};
use tracing::debug;

use crate::chat::{chat_cache_get};
use crate::models::{chats::ChatModel, feeds::FeedModel};
use common::{common_error, id_gen, pb_decode, time::current_ms, BizHub, UserBrief};
use proto::idl::{entity, error::ErrorCode, join_request};

#[derive(Debug, FromQueryResult)]
struct JoinRequestRow {
    id: i64,
    chat_id: i64,
    user_id: i64,
    status: i16,
    handler_id: Option<i64>,
    handled_at: Option<chrono::DateTime<chrono::FixedOffset>>,
    created_at: chrono::DateTime<chrono::FixedOffset>,
    chat_name: Option<String>,
    user_name: Option<String>,
}

pub(crate) async fn join_request_create(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<join_request::JoinRequestCreateRequest>(&packet.payload)?;
    debug!("join request create, req: {req:?}");
    let context = chat_cache_get(ctx, req.chat_id).await?;
    let mut resp = join_request::JoinRequestCreateResponse::default();

    {
        let c = context.read().await;
        if c.cmv.contains_key(brief.id) {
            return Ok((ErrorCode::Success as i32, resp.encode_to_vec()));
        }
    }

    // 检查用户是否已有 pending 申请
    let existing = JoinRequestRow::find_by_statement(Statement::from_sql_and_values(
        DbBackend::Postgres,
        "SELECT id FROM join_requests WHERE chat_id = $1 AND user_id = $2 AND status = 0 LIMIT 1",
        vec![req.chat_id.into(), brief.id.into()],
    ))
    .one(&ctx.db)
    .await
    .map_err(|e| common_error(&format!("query join request error: {e}")))?;

    if existing.is_some() {
        return Err(common_error("join request already exists"));
    }

    let now = current_ms() as i64;
    let request_id = id_gen(None);

    let stmt = Statement::from_sql_and_values(
        DbBackend::Postgres,
        r#"
        INSERT INTO join_requests (id, chat_id, user_id, status, handler_id, handled_at, created_at)
        VALUES ($1, $2, $3, 0, NULL, NULL, NOW())
        "#,
        vec![
            request_id.into(),
            req.chat_id.into(),
            brief.id.into(),
        ],
    );
    ctx.db.execute(stmt).await.map_err(|e| common_error(&format!("create join request error: {e}")))?;

    let biz = BizHub::get()?;
    let users = biz.user.get_user_by_ids(ctx, vec![brief.id]).await?;
    let user_name = users.first().map(|u| u.name.clone()).unwrap_or_default();

    let c = context.read().await;
    let chat_name = c.chat.name.clone();
    resp.request = Some(join_request::JoinRequest {
        id: request_id,
        chat_id: req.chat_id,
        chat_name: chat_name.clone(),
        user_id: brief.id,
        user_name,
        status: 0,
        handler_id: 0,
        handled_at: 0,
        created_at: now,
    });

    let e = resp.entities.get_or_insert_default();
    e.chats.insert(req.chat_id, c.get_entity());

    debug!("join request create done, id: {request_id}");
    Ok((0, resp.encode_to_vec()))
}

pub(crate) async fn join_request_approve(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<join_request::JoinRequestApproveRequest>(&packet.payload)?;
    debug!("join request approve, req: {req:?}");
    let mut resp = join_request::JoinRequestApproveResponse::default();

    let row = JoinRequestRow::find_by_statement(Statement::from_sql_and_values(
        DbBackend::Postgres,
        "SELECT id, chat_id, user_id, status, handler_id, handled_at, created_at, NULL AS chat_name, NULL AS user_name FROM join_requests WHERE id = $1",
        vec![req.request_id.into()],
    ))
    .one(&ctx.db)
    .await
    .map_err(|e| common_error(&format!("query join request error: {e}")))?
    .ok_or_else(|| Error::string("join request not found"))?;

    if row.status != 0 {
        return Err(common_error("join request already handled"));
    }

    let context = chat_cache_get(ctx, row.chat_id).await?;

    {
        let c = context.read().await;
        let is_owner = c.chat.owner_id == brief.id;
        let is_admin = c.chat.admin_ids.contains(&brief.id);
        if !is_owner && !is_admin {
            return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
        }
    }

    let now = common::time::date_time(current_ms() as i64);

    // 更新 join_request 状态
    let stmt = Statement::from_sql_and_values(
        DbBackend::Postgres,
        "UPDATE join_requests SET status = 1, handler_id = $1, handled_at = $2 WHERE id = $3",
        vec![brief.id.into(), now.into(), req.request_id.into()],
    );
    ctx.db.execute(stmt).await.map_err(|e| common_error(&format!("approve join request error: {e}")))?;

    // 添加成员
    let member_ids;
    {
        let mut c = context.write().await;
        if c.chat.r#type == entity::ChatType::ChatP2p as i16 {
            return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
        }
        if c.cmv.add(&vec![row.user_id])? {
            c.chat.version = crate::chat::bump_chat_version(c.chat.version);
            let version = c.chat.version;
            ChatModel::update_cmv(&ctx.db, c.chat.id, version, None, None, &mut c.cmv).await?;
            let _ = FeedModel::create_by_chat(&ctx.db, &c.chat, &vec![row.user_id]).await;
            let member_ids = c.cmv.ids();
            // 审批通过新增成员属 chat 实体变更：在线 PushChatUpdate 直推 + 离线 EntityChange mark dirty
            let _ = crate::chat::push_chat_update(
                ctx,
                &member_ids,
                row.chat_id,
                version,
                entity::Operate::Update,
            )
            .await;
        }
        member_ids = c.cmv.ids();
        let e = resp.entities.get_or_insert_default();
        e.chats.insert(row.chat_id, c.get_entity());
    }

    let _ = crate::feed::update_feed_status(ctx, row.chat_id, &member_ids, None).await;

    debug!("join request approve done");
    Ok((0, resp.encode_to_vec()))
}

pub(crate) async fn join_request_reject(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<join_request::JoinRequestRejectRequest>(&packet.payload)?;
    debug!("join request reject, req: {req:?}");
    let resp = join_request::JoinRequestRejectResponse::default();

    let row = JoinRequestRow::find_by_statement(Statement::from_sql_and_values(
        DbBackend::Postgres,
        "SELECT id, chat_id, user_id, status, handler_id, handled_at, created_at, NULL AS chat_name, NULL AS user_name FROM join_requests WHERE id = $1",
        vec![req.request_id.into()],
    ))
    .one(&ctx.db)
    .await
    .map_err(|e| common_error(&format!("query join request error: {e}")))?
    .ok_or_else(|| Error::string("join request not found"))?;

    if row.status != 0 {
        return Err(common_error("join request already handled"));
    }

    {
        let ctx2 = chat_cache_get(ctx, row.chat_id).await?;
        let c = ctx2.read().await;
        let is_owner = c.chat.owner_id == brief.id;
        let is_admin = c.chat.admin_ids.contains(&brief.id);
        if !is_owner && !is_admin {
            return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
        }
    }

    let now = common::time::date_time(current_ms() as i64);

    let stmt = Statement::from_sql_and_values(
        DbBackend::Postgres,
        "UPDATE join_requests SET status = 2, handler_id = $1, handled_at = $2 WHERE id = $3",
        vec![brief.id.into(), now.into(), req.request_id.into()],
    );
    ctx.db.execute(stmt).await.map_err(|e| common_error(&format!("reject join request error: {e}")))?;

    debug!("join request reject done");
    Ok((0, resp.encode_to_vec()))
}

pub(crate) async fn join_request_list(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<join_request::JoinRequestListRequest>(&packet.payload)?;
    debug!("join request list, req: {req:?}");
    let mut resp = join_request::JoinRequestListResponse::default();

    {
        let ctx2 = chat_cache_get(ctx, req.chat_id).await?;
        let c = ctx2.read().await;
        let is_owner = c.chat.owner_id == brief.id;
        let is_admin = c.chat.admin_ids.contains(&brief.id);
        if !is_owner && !is_admin {
            return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
        }
    }

    let page = if req.page <= 0 { 1 } else { req.page };
    let page_size = if req.page_size <= 0 { 20 } else { req.page_size.min(100) };
    let offset = ((page - 1) * page_size) as i64;

    let rows = JoinRequestRow::find_by_statement(Statement::from_sql_and_values(
        DbBackend::Postgres,
        r#"
        SELECT jr.id, jr.chat_id, jr.user_id, jr.status, jr.handler_id, jr.handled_at, jr.created_at,
               c.name AS chat_name, u.name AS user_name
        FROM join_requests jr
        LEFT JOIN chats c ON c.id = jr.chat_id
        LEFT JOIN users u ON u.id = jr.user_id
        WHERE jr.chat_id = $1 AND jr.status = $2
        ORDER BY jr.created_at DESC
        LIMIT $3 OFFSET $4
        "#,
        vec![
            req.chat_id.into(),
            req.status.into(),
            page_size.into(),
            offset.into(),
        ],
    ))
    .all(&ctx.db)
    .await
    .map_err(|e| common_error(&format!("query join requests error: {e}")))?;

    for row in rows {
        resp.requests.push(join_request::JoinRequest {
            id: row.id,
            chat_id: row.chat_id,
            chat_name: row.chat_name.unwrap_or_default(),
            user_id: row.user_id,
            user_name: row.user_name.unwrap_or_default(),
            status: row.status as i32,
            handler_id: row.handler_id.unwrap_or(0),
            handled_at: row.handled_at.map(|t| t.timestamp_millis()).unwrap_or(0),
            created_at: row.created_at.timestamp_millis(),
        });
    }

    resp.total = resp.requests.len() as i32;

    debug!("join request list done, count: {}", resp.total);
    Ok((0, resp.encode_to_vec()))
}
