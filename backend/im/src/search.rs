use loco_rs::{Result, app::AppContext};
use prost::Message;
use sea_orm::{ConnectionTrait, DbBackend, Statement};
use tracing::debug;

use common::{UserBrief, common_error, pb_decode};
use proto::idl::{entity, error::ErrorCode, search};

// ── helpers ──

fn highlight(text: &str, keyword: &str) -> String {
    if keyword.is_empty() || text.is_empty() {
        return text.chars().take(100).collect();
    }
    let lower = text.to_lowercase();
    let kw = keyword.to_lowercase();
    if let Some(pos) = lower.find(&kw) {
        let start = pos.saturating_sub(20);
        let end = (pos + kw.len() + 20).min(text.len());
        let snippet = &text[start..end];
        let kw_start = if start > 0 { pos - start } else { pos };
        let kw_end = kw_start + kw.len();
        let mut result = String::with_capacity(snippet.len() + 11);
        if start > 0 {
            result.push_str("...");
        }
        result.push_str(&snippet[..kw_start]);
        result.push_str("<mark>");
        result.push_str(&snippet[kw_start..kw_end]);
        result.push_str("</mark>");
        result.push_str(&snippet[kw_end..]);
        if end < text.len() {
            result.push_str("...");
        }
        result
    } else {
        text.chars().take(100).collect()
    }
}

fn paginate(page: i32, page_size: i32) -> (i32, i32, i32) {
    let p = page.max(1);
    let ps = page_size.max(1).min(100);
    (p, ps, (p - 1) * ps)
}

// ── search_messages ──

pub(crate) async fn search_messages(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<search::SearchRequest>(&packet.payload)?;
    debug!("search messages, keyword={}, page={}, page_size={}", req.keyword, req.page, req.page_size);

    let keyword = req.keyword.trim();
    if keyword.is_empty() {
        return Ok((ErrorCode::ErrorParamInvalid as i32, search::SearchMessagesResponse::default().encode_to_vec()));
    }

    let (page, page_size, offset) = paginate(req.page, req.page_size);
    let filter = req.filter.unwrap_or_default();

    let filter_chat_id = filter.chat_id;
    let filter_from_id = filter.from_id;
    let filter_msg_type = filter.msg_type;
    let filter_time_start = filter.time_start_ms;
    let filter_time_end = filter.time_end_ms;

    // Count query
    let count_sql = format!(
        r#"
        SELECT COUNT(*) AS total FROM messages m
        WHERE m.summary % $1
          AND m.chat_id IN (SELECT entity_id FROM feeds WHERE user_id = $2 AND entity_type = 2 AND status = 0)
          AND ($3 = 0 OR m.chat_id = $3)
          AND ($4 = 0 OR m.from_id = $4)
          AND ($5 = 0 OR m.r#type = $5)
          AND ($6 = 0 OR m.created_at >= to_timestamp($6::double precision / 1000))
          AND ($7 = 0 OR m.created_at <= to_timestamp($7::double precision / 1000))
        "#
    );
    let total_row = ctx.db.query_one(Statement::from_sql_and_values(
        DbBackend::Postgres,
        &count_sql,
        vec![
            keyword.into(),
            brief.id.into(),
            filter_chat_id.into(),
            filter_from_id.into(),
            filter_msg_type.into(),
            filter_time_start.into(),
            filter_time_end.into(),
        ],
    )).await.map_err(|e| common_error(&format!("search messages count error: {e}")))?
        .ok_or_else(|| common_error("search messages count no result"))?;
    let total: i32 = total_row.try_get_by::<i64, _>("total").unwrap_or(0) as i32;

    // Data query
    let data_sql = format!(
        r#"
        SELECT m.id, m.chat_id, m.from_id, m.r#type AS msg_type, m.content, m.summary,
               m.status, m.created_at, m.updated_at, m.at_user_ids, m.thread_root_id,
               similarity(m.summary, $1) AS sim
        FROM messages m
        WHERE m.summary % $1
          AND m.chat_id IN (SELECT entity_id FROM feeds WHERE user_id = $2 AND entity_type = 2 AND status = 0)
          AND ($3 = 0 OR m.chat_id = $3)
          AND ($4 = 0 OR m.from_id = $4)
          AND ($5 = 0 OR m.r#type = $5)
          AND ($6 = 0 OR m.created_at >= to_timestamp($6::double precision / 1000))
          AND ($7 = 0 OR m.created_at <= to_timestamp($7::double precision / 1000))
        ORDER BY sim DESC, m.id DESC
        LIMIT $8 OFFSET $9
        "#
    );
    let rows = ctx.db.query_all(Statement::from_sql_and_values(
        DbBackend::Postgres,
        &data_sql,
        vec![
            keyword.into(),
            brief.id.into(),
            filter_chat_id.into(),
            filter_from_id.into(),
            filter_msg_type.into(),
            filter_time_start.into(),
            filter_time_end.into(),
            page_size.into(),
            offset.into(),
        ],
    )).await.map_err(|e| common_error(&format!("search messages error: {e}")))?;

    let mut resp = search::SearchMessagesResponse { total: total as i32, ..Default::default() };
    for row in rows {
        let summary: String = row.try_get("", "summary").unwrap_or_default();
        let hl = highlight(&summary, keyword);
        let msg = entity::Message {
            id: row.try_get("", "id").unwrap_or(0),
            chat_id: row.try_get("", "chat_id").unwrap_or(0),
            from_id: row.try_get("", "from_id").unwrap_or(0),
            tpy: row.try_get::<i16>("", "msg_type").unwrap_or(0) as i32,
            content: row.try_get::<Vec<u8>>("", "content").unwrap_or_default(),
            summary: summary.clone(),
            status: row.try_get::<i16>("", "status").unwrap_or(0) as i32,
            at_user_ids: row.try_get("", "at_user_ids").unwrap_or_default(),
            thread_root_id: row.try_get("", "thread_root_id").unwrap_or(0),
            create_time_ms: row.try_get::<chrono::DateTime<chrono::Utc>>("", "created_at")
                .ok().map(|t| t.timestamp_millis()).unwrap_or(0),
            update_time_ms: row.try_get::<chrono::DateTime<chrono::Utc>>("", "updated_at")
                .ok().map(|t| t.timestamp_millis()).unwrap_or(0),
            ..Default::default()
        };
        resp.results.push(search::MessageSearchResult {
            message: Some(msg),
            highlight: hl,
        });
    }

    debug!("search messages done, total={}, returned={}", total, resp.results.len());
    Ok((ErrorCode::Ok as i32, resp.encode_to_vec()))
}

// ── search_chats ──

pub(crate) async fn search_chats(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<search::SearchRequest>(&packet.payload)?;
    debug!("search chats, keyword={}", req.keyword);

    let keyword = req.keyword.trim();
    if keyword.is_empty() {
        return Ok((ErrorCode::ErrorParamInvalid as i32, search::SearchChatsResponse::default().encode_to_vec()));
    }

    let (page, page_size, offset) = paginate(req.page, req.page_size);

    let count_sql = r#"
        SELECT COUNT(*) AS total FROM chats c
        WHERE c.name % $1
          AND c.id IN (SELECT entity_id FROM feeds WHERE user_id = $2 AND entity_type = 2 AND status = 0)
    "#;
    let total_row = ctx.db.query_one(Statement::from_sql_and_values(
        DbBackend::Postgres,
        count_sql,
        vec![keyword.into(), brief.id.into()],
    )).await.map_err(|e| common_error(&format!("search chats count error: {e}")))?
        .ok_or_else(|| common_error("search chats count no result"))?;
    let total: i32 = total_row.try_get_by::<i64, _>("total").unwrap_or(0) as i32;

    let data_sql = r#"
        SELECT c.id, c.r#type, c.status, c.name, c.owner_id, c.peer_a_id, c.peer_b_id,
               c.cmv, c.last_message_id, c.last_message_pos, c.last_message_badge,
               c.admin_ids, c.created_at, c.updated_at, c.description, c.join_mode,
               c.global_mute_until,
               similarity(c.name, $1) AS sim
        FROM chats c
        WHERE c.name % $1
          AND c.id IN (SELECT entity_id FROM feeds WHERE user_id = $2 AND entity_type = 2 AND status = 0)
        ORDER BY sim DESC, c.id DESC
        LIMIT $3 OFFSET $4
    "#;
    let rows = ctx.db.query_all(Statement::from_sql_and_values(
        DbBackend::Postgres,
        data_sql,
        vec![keyword.into(), brief.id.into(), page_size.into(), offset.into()],
    )).await.map_err(|e| common_error(&format!("search chats error: {e}")))?;

    let mut resp = search::SearchChatsResponse { total: total as i32, ..Default::default() };
    for row in rows {
        let name: String = row.try_get("", "name").unwrap_or_default();
        let hl = highlight(&name, keyword);
        let cmv_bytes: Vec<u8> = row.try_get("", "cmv").unwrap_or_default();
        let member_ids = crate::models::Cmv::from(&cmv_bytes)?.ids();

        let create_at: i64 = row.try_get::<chrono::DateTime<chrono::Utc>>("", "created_at")
            .ok().map(|t| t.timestamp_millis()).unwrap_or(0);
        let update_at: i64 = row.try_get::<chrono::DateTime<chrono::Utc>>("", "updated_at")
            .ok().map(|t| t.timestamp_millis()).unwrap_or(0);
        let global_mute_raw: Option<chrono::DateTime<chrono::Utc>> = row.try_get("", "global_mute_until").ok();
        let global_mute_until = global_mute_raw.map(|t| t.timestamp_millis()).unwrap_or(0);

        let chat = entity::Chat {
            id: row.try_get("", "id").unwrap_or(0),
            chat_type: row.try_get::<i16>("", "r#type").unwrap_or(0) as i32,
            status: row.try_get::<i16>("", "status").unwrap_or(0) as i32,
            name,
            owner_id: row.try_get("", "owner_id").unwrap_or(0),
            peer_a_id: row.try_get("", "peer_a_id").unwrap_or(0),
            peer_b_id: row.try_get("", "peer_b_id").unwrap_or(0),
            member_ids,
            admin_ids: row.try_get("", "admin_ids").unwrap_or_default(),
            last_message_id: row.try_get("", "last_message_id").unwrap_or(0),
            last_message_pos: row.try_get("", "last_message_pos").unwrap_or(0),
            last_message_badge_count: row.try_get("", "last_message_badge").unwrap_or(0),
            create_at_ms: create_at,
            update_at_ms: update_at,
            description: row.try_get("", "description").unwrap_or_default(),
            join_mode: row.try_get::<i16>("", "join_mode").unwrap_or(0) as i32,
            global_mute_until,
            ..Default::default()
        };
        resp.results.push(search::ChatSearchResult {
            chat: Some(chat),
            highlight: hl,
        });
    }

    debug!("search chats done, total={}, returned={}", total, resp.results.len());
    Ok((ErrorCode::Ok as i32, resp.encode_to_vec()))
}

// ── search_users ──

pub(crate) async fn search_users(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<search::SearchRequest>(&packet.payload)?;
    debug!("search users, keyword={}", req.keyword);

    let keyword = req.keyword.trim();
    if keyword.is_empty() {
        return Ok((ErrorCode::ErrorParamInvalid as i32, search::SearchUsersResponse::default().encode_to_vec()));
    }

    let (page, page_size, offset) = paginate(req.page, req.page_size);

    let count_sql = r#"
        SELECT COUNT(*) AS total FROM users
        WHERE name % $1 AND tenant_id = $2
    "#;
    let total_row = ctx.db.query_one(Statement::from_sql_and_values(
        DbBackend::Postgres,
        count_sql,
        vec![keyword.into(), brief.tenant_id.into()],
    )).await.map_err(|e| common_error(&format!("search users count error: {e}")))?
        .ok_or_else(|| common_error("search users count no result"))?;
    let total: i32 = total_row.try_get_by::<i64, _>("total").unwrap_or(0) as i32;

    let data_sql = r#"
        SELECT id, name, status, tenant_id, avatar, dept_id,
               similarity(name, $1) AS sim
        FROM users
        WHERE name % $1 AND tenant_id = $2
        ORDER BY sim DESC, id ASC
        LIMIT $3 OFFSET $4
    "#;
    let rows = ctx.db.query_all(Statement::from_sql_and_values(
        DbBackend::Postgres,
        data_sql,
        vec![keyword.into(), brief.tenant_id.into(), page_size.into(), offset.into()],
    )).await.map_err(|e| common_error(&format!("search users error: {e}")))?;

    let mut resp = search::SearchUsersResponse { total: total as i32, ..Default::default() };
    for row in rows {
        let name: String = row.try_get("", "name").unwrap_or_default();
        let hl = highlight(&name, keyword);
        let user = entity::User {
            id: row.try_get("", "id").unwrap_or(0),
            name,
            status: row.try_get::<i16>("", "status").unwrap_or(0) as i32,
            tenant_id: row.try_get("", "tenant_id").unwrap_or(0),
            avatar: row.try_get("", "avatar").unwrap_or_default(),
            dept_id: row.try_get("", "dept_id").unwrap_or(0),
            ..Default::default()
        };
        resp.results.push(search::UserSearchResult {
            user: Some(user),
            highlight: hl,
        });
    }

    debug!("search users done, total={}, returned={}", total, resp.results.len());
    Ok((ErrorCode::Ok as i32, resp.encode_to_vec()))
}

// ── search_files ──

pub(crate) async fn search_files(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<search::SearchRequest>(&packet.payload)?;
    debug!("search files, keyword={}", req.keyword);

    let keyword = req.keyword.trim();
    if keyword.is_empty() {
        return Ok((ErrorCode::ErrorParamInvalid as i32, search::SearchFilesResponse::default().encode_to_vec()));
    }

    let (page, page_size, offset) = paginate(req.page, req.page_size);

    let count_sql = r#"
        SELECT COUNT(*) AS total FROM files
        WHERE file_name % $1 AND deleted_at IS NULL
    "#;
    let total_row = ctx.db.query_one(Statement::from_sql_and_values(
        DbBackend::Postgres,
        count_sql,
        vec![keyword.into()],
    )).await.map_err(|e| common_error(&format!("search files count error: {e}")))?
        .ok_or_else(|| common_error("search files count no result"))?;
    let total: i32 = total_row.try_get_by::<i64, _>("total").unwrap_or(0) as i32;

    let data_sql = r#"
        SELECT id, user_id, file_name, mime_type, file_size, storage_key, created_at,
               similarity(file_name, $1) AS sim
        FROM files
        WHERE file_name % $1 AND deleted_at IS NULL
        ORDER BY sim DESC, id DESC
        LIMIT $2 OFFSET $3
    "#;
    let rows = ctx.db.query_all(Statement::from_sql_and_values(
        DbBackend::Postgres,
        data_sql,
        vec![keyword.into(), page_size.into(), offset.into()],
    )).await.map_err(|e| common_error(&format!("search files error: {e}")))?;

    let mut resp = search::SearchFilesResponse { total: total as i32, ..Default::default() };
    for row in rows {
        let file_name: String = row.try_get("", "file_name").unwrap_or_default();
        let hl = highlight(&file_name, keyword);
        let storage_key: String = row.try_get("", "storage_key").unwrap_or_default();
        let file_id: i64 = row.try_get("", "id").unwrap_or(0);
        // Build download URL via store API path
        let url = format!("/api/files/{}", file_id);
        resp.results.push(search::FileSearchResult {
            file_id: file_id.to_string(),
            file_name: file_name.clone(),
            mime_type: row.try_get("", "mime_type").unwrap_or_default(),
            size: row.try_get("", "file_size").unwrap_or(0),
            url,
            highlight: hl,
            created_at_ms: row.try_get::<i64>("", "created_at").unwrap_or(0),
            uploader_id: row.try_get("", "user_id").unwrap_or(0),
        });
    }

    debug!("search files done, total={}, returned={}", total, resp.results.len());
    Ok((ErrorCode::Ok as i32, resp.encode_to_vec()))
}

// ── global_search ──

pub(crate) async fn global_search(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<search::GlobalSearchRequest>(&packet.payload)?;
    debug!("global search, keyword={}", req.keyword);

    let keyword = req.keyword.trim().to_string();
    if keyword.is_empty() {
        return Ok((ErrorCode::ErrorParamInvalid as i32, search::GlobalSearchResponse::default().encode_to_vec()));
    }

    let limit = req.page_size.max(1).min(20);
    let types = req.types;
    let types_empty = types.is_empty();

    let mut resp = search::GlobalSearchResponse::default();

    // Search messages
    if types_empty || types.contains(&"message".to_string()) {
        let msg_req = search::SearchRequest {
            keyword: keyword.clone(),
            page: 1,
            page_size: limit,
            filter: None,
        };
        let msg_packet = entity::Packet {
            cmd: 0,
            payload: msg_req.encode_to_vec(),
            ..Default::default()
        };
        match search_messages(ctx, brief, &msg_packet, ws).await {
            Ok((_, data)) => {
                if let Ok(r) = search::SearchMessagesResponse::decode(data.as_slice()) {
                    resp.messages = r.results;
                    resp.message_total = r.total;
                }
            }
            Err(e) => debug!("global search messages error: {e}"),
        }
    }

    // Search chats
    if types_empty || types.contains(&"chat".to_string()) {
        let chat_req = search::SearchRequest {
            keyword: keyword.clone(),
            page: 1,
            page_size: limit,
            filter: None,
        };
        let chat_packet = entity::Packet {
            cmd: 0,
            payload: chat_req.encode_to_vec(),
            ..Default::default()
        };
        match search_chats(ctx, brief, &chat_packet, ws).await {
            Ok((_, data)) => {
                if let Ok(r) = search::SearchChatsResponse::decode(data.as_slice()) {
                    resp.chats = r.results;
                    resp.chat_total = r.total;
                }
            }
            Err(e) => debug!("global search chats error: {e}"),
        }
    }

    // Search users
    if types_empty || types.contains(&"user".to_string()) {
        let user_req = search::SearchRequest {
            keyword: keyword.clone(),
            page: 1,
            page_size: limit,
            filter: None,
        };
        let user_packet = entity::Packet {
            cmd: 0,
            payload: user_req.encode_to_vec(),
            ..Default::default()
        };
        match search_users(ctx, brief, &user_packet, ws).await {
            Ok((_, data)) => {
                if let Ok(r) = search::SearchUsersResponse::decode(data.as_slice()) {
                    resp.users = r.results;
                    resp.user_total = r.total;
                }
            }
            Err(e) => debug!("global search users error: {e}"),
        }
    }

    // Search files
    if types_empty || types.contains(&"file".to_string()) {
        let file_req = search::SearchRequest {
            keyword: keyword.clone(),
            page: 1,
            page_size: limit,
            filter: None,
        };
        let file_packet = entity::Packet {
            cmd: 0,
            payload: file_req.encode_to_vec(),
            ..Default::default()
        };
        match search_files(ctx, brief, &file_packet, ws).await {
            Ok((_, data)) => {
                if let Ok(r) = search::SearchFilesResponse::decode(data.as_slice()) {
                    resp.files = r.results;
                    resp.file_total = r.total;
                }
            }
            Err(e) => debug!("global search files error: {e}"),
        }
    }

    debug!("global search done: {} msgs, {} chats, {} users, {} files",
        resp.messages.len(), resp.chats.len(), resp.users.len(), resp.files.len());
    Ok((ErrorCode::Ok as i32, resp.encode_to_vec()))
}
