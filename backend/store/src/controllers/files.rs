use axum::debug_handler;
use axum::extract::multipart::Multipart;
use axum::http::header;
use loco_rs::prelude::*;
use serde::Serialize;

use base::models::_entities::files::ActiveModel;
use common::{id_gen, model::UserBrief, time::current_ms};

use crate::models::files::FileModel;
use crate::services;

#[derive(Debug, Serialize)]
pub struct FileResponse {
    pub id: String,
    pub file_name: String,
    pub file_size: i64,
    pub mime_type: String,
    pub ext: String,
    pub category: String,
    pub url: String,
    pub created_at: i64,
}

#[debug_handler]
pub async fn upload(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    mut multipart: Multipart,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let now = current_ms() as i64;

    let field = multipart
        .next_field()
        .await
        .map_err(|_| Error::BadRequest("invalid multipart".to_string()))?
        .ok_or(Error::BadRequest("no file".to_string()))?;

    let file_name = field
        .file_name()
        .unwrap_or("unknown")
        .to_string();
    let mime_type = field
        .content_type()
        .unwrap_or("application/octet-stream")
        .to_string();
    let ext = services::mime_to_ext(&mime_type).to_string();
    let data = field
        .bytes()
        .await
        .map_err(|_| Error::BadRequest("read file failed".to_string()))?;

    let storage_key = services::generate_storage_key("file", &ext);
    services::put(&storage_key, data.to_vec())
        .await
        .map_err(|_| Error::InternalServerError)?;

    let host = ctx.config.server.host.clone();
    let port = ctx.config.server.port;
    let fid = id_gen(None);
    let file = FileModel::create(
        &ctx.db,
        ActiveModel {
            id: ActiveValue::set(fid),
            user_id: ActiveValue::set(claim.id),
            doc_id: ActiveValue::set(None),
            file_name: ActiveValue::set(file_name),
            file_size: ActiveValue::set(data.len() as i64),
            mime_type: ActiveValue::set(mime_type.clone()),
            ext: ActiveValue::set(ext.clone()),
            storage_key: ActiveValue::set(storage_key.clone()),
            md5: ActiveValue::set(None),
            category: ActiveValue::set("file".to_string()),
            created_at: ActiveValue::set(now),
            deleted_at: ActiveValue::set(None),
        },
    )
    .await?;

    format::json(FileResponse {
        id: file.id.to_string(),
        file_name: file.file_name,
        file_size: file.file_size,
        mime_type: file.mime_type,
        ext: file.ext,
        category: file.category,
        url: services::build_file_url(&host, port, file.id),
        created_at: file.created_at,
    })
}

#[debug_handler]
pub async fn download(
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<impl IntoResponse> {
    let file = FileModel::get_by_id(&ctx.db, id)
        .await?
        .ok_or(Error::NotFound)?;

    let data = services::get(&file.storage_key)
        .await
        .map_err(|_| Error::NotFound)?;

    let content_type = if file.mime_type.is_empty() {
        "application/octet-stream".to_string()
    } else {
        file.mime_type.clone()
    };

    let is_inline = content_type.starts_with("image/")
        || content_type.starts_with("text/")
        || content_type == "application/pdf";

    let disposition = if is_inline {
        format!("inline; filename=\"{}\"", file.file_name)
    } else {
        format!("attachment; filename=\"{}\"", file.file_name)
    };

    let headers = [
        (header::CONTENT_TYPE, content_type),
        (header::CONTENT_DISPOSITION, disposition),
    ];

    let body = axum::body::Body::from(data.to_vec());
    Ok((headers, body))
}

#[debug_handler]
pub async fn info(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let _claim = UserBrief::from_string(&auth.claims.pid)?;
    let host = ctx.config.server.host.clone();
    let port = ctx.config.server.port;
    let file = FileModel::get_by_id(&ctx.db, id)
        .await?
        .ok_or(Error::NotFound)?;

    format::json(FileResponse {
        id: file.id.to_string(),
        file_name: file.file_name,
        file_size: file.file_size,
        mime_type: file.mime_type,
        ext: file.ext,
        category: file.category,
        url: services::build_file_url(&host, port, file.id),
        created_at: file.created_at,
    })
}

#[debug_handler]
pub async fn delete(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let _claim = UserBrief::from_string(&auth.claims.pid)?;
    let file = FileModel::get_by_id(&ctx.db, id)
        .await?
        .ok_or(Error::NotFound)?;

    let _ = services::delete(&file.storage_key).await;
    FileModel::soft_delete(&ctx.db, id).await?;

    format::json(serde_json::json!({"ok": true}))
}
