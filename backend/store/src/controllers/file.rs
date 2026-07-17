#![allow(clippy::missing_errors_doc)]
#![allow(clippy::unnecessary_struct_initialization)]
#![allow(clippy::unused_async)]
use loco_rs::prelude::*;
use tracing::debug;

use base::models::_entities::files::ActiveModel;
use common::{id_gen, time::current_ms};

use crate::models::files::FileModel;
use crate::services;

/// Generate a text-based avatar image, save to object_store and files table.
/// Returns the public URL path (e.g. "/api/files/{id}").
pub async fn generate_text_image(
    ctx: &AppContext,
    content: &str,
    category: &str,
) -> Result<String> {
    let storage_key = services::text_image_to_store(content, category)
        .await
        .map_err(|e| {
            debug!("text image error: {:?}", e);
            Error::InternalServerError
        })?;

    let fid = id_gen(None);
    let now = current_ms() as i64;
    let ext = "jpg".to_string();

    let file = FileModel::create(
        &ctx.db,
        ActiveModel {
            id: ActiveValue::set(fid),
            user_id: ActiveValue::set(0),
            doc_id: ActiveValue::set(None),
            file_name: ActiveValue::set(format!("{fid}.{ext}")),
            file_size: ActiveValue::set(0),
            mime_type: ActiveValue::set("image/jpeg".to_string()),
            ext: ActiveValue::set(ext),
            storage_key: ActiveValue::set(storage_key),
            md5: ActiveValue::set(None),
            category: ActiveValue::set(category.to_string()),
            created_at: ActiveValue::set(now),
            deleted_at: ActiveValue::set(None),
        },
    )
    .await?;

    let url = services::build_file_url(&ctx.config.server.host, ctx.config.server.port, file.id);
    Ok(url)
}
