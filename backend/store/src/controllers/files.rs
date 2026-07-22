use axum::debug_handler;
use axum::extract::{multipart::Multipart, Query};
use axum::http::header;
use loco_rs::prelude::*;
use serde::{Deserialize, Serialize};

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
    pub thumbnail_url: Option<String>,
    pub width: Option<i32>,
    pub height: Option<i32>,
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

    let is_image = mime_type.starts_with("image/");
    let is_video = mime_type.starts_with("video/");
    let (thumbnail_key, width, height) = if is_image {
        match services::generate_thumbnail(&data, 256) {
            Ok((thumb_data, w, h)) => {
                let thumb_key = services::generate_thumbnail_key(&storage_key);
                let _ = services::put(&thumb_key, thumb_data).await;
                (Some(thumb_key), Some(w as i32), Some(h as i32))
            }
            Err(_) => (None, None, None),
        }
    } else if is_video {
        match services::generate_video_thumbnail(&data, &ext).await {
            Ok((thumb_data, w, h)) => {
                let thumb_key = services::generate_thumbnail_key(&storage_key);
                let _ = services::put(&thumb_key, thumb_data).await;
                (Some(thumb_key), Some(w as i32), Some(h as i32))
            }
            Err(_) => (None, None, None),
        }
    } else {
        (None, None, None)
    };

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
            width: ActiveValue::set(width),
            height: ActiveValue::set(height),
            thumbnail_key: ActiveValue::set(thumbnail_key),
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
        thumbnail_url: if file.thumbnail_key.is_some() {
            Some(format!("{}?size=thumb", services::build_file_url(&host, port, file.id)))
        } else {
            None
        },
        width: file.width,
        height: file.height,
        created_at: file.created_at,
    })
}

#[derive(Debug, Deserialize)]
pub struct DownloadParams {
    size: Option<String>,
}

#[debug_handler]
pub async fn download(
    Path(id): Path<i64>,
    Query(params): Query<DownloadParams>,
    State(ctx): State<AppContext>,
) -> Result<impl IntoResponse> {
    let file = FileModel::get_by_id(&ctx.db, id)
        .await?
        .ok_or(Error::NotFound)?;

    let is_thumb = params.size.as_deref() == Some("thumb");
    let storage_key = if is_thumb {
        file.thumbnail_key.as_deref().unwrap_or(&file.storage_key)
    } else {
        &file.storage_key
    };

    let data = services::get(storage_key)
        .await
        .map_err(|_| Error::NotFound)?;

    let content_type = if is_thumb {
        "image/jpeg".to_string()
    } else if file.mime_type.is_empty() {
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
        thumbnail_url: if file.thumbnail_key.is_some() {
            Some(services::build_file_url(&host, port, file.id))
        } else {
            None
        },
        width: file.width,
        height: file.height,
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
