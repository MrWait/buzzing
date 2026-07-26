use std::sync::LazyLock;

use std::io::Cursor;

use bytes::Bytes;
use chrono::Datelike;
use futures::{StreamExt, stream};
use image::GenericImageView;
use object_store::{GetOptions, ObjectStore, PutOptions, PutPayload, path::Path};
use tracing::debug;

use common::id_gen;

pub fn build_file_url(host: &str, port: i32, file_id: i64) -> String {
    if port == 80 || port == 443 {
        format!("{host}/api/files/{file_id}")
    } else {
        format!("{host}:{port}/api/files/{file_id}")
    }
}

static STORE: LazyLock<Result<Box<dyn ObjectStore>, object_store::Error>> =
    LazyLock::new(|| {
        let path =
            std::env::var("BUZZING_STORAGE_DIR").unwrap_or_else(|_| "storage".to_string());
        debug!("initializing object_store with prefix: {path}");
        std::fs::create_dir_all(&path)
            .unwrap_or_else(|e| panic!("failed to create storage directory '{path}': {e}"));
        object_store::local::LocalFileSystem::new_with_prefix(&path)
            .map(|fs| Box::new(fs) as Box<dyn ObjectStore>)
    });

fn store() -> &'static dyn ObjectStore {
    STORE
        .as_ref()
        .expect("object_store initialization failed")
        .as_ref()
}

pub fn generate_storage_key(category: &str, ext: &str) -> String {
    let fid = id_gen(None);
    let now = chrono::Utc::now();
    format!(
        "{category}/{year:04}/{month:02}/{fid}.{ext}",
        category = category,
        year = now.year(),
        month = now.month(),
        fid = fid,
        ext = ext,
    )
}

pub fn mime_to_ext(mime: &str) -> &str {
    let idx = mime.find('/').map(|i| i + 1).unwrap_or(0);
    if idx == 0 || idx >= mime.len() {
        return "dat";
    }
    let ext = &mime[idx..];
    if ext.is_empty() {
        "dat"
    } else {
        ext
    }
}

pub async fn put(key: &str, data: Vec<u8>) -> Result<(), object_store::Error> {
    let path = Path::from(key);
    let payload = PutPayload::from_bytes(Bytes::from(data));
    store().put_opts(&path, payload, PutOptions::default()).await?;
    Ok(())
}

pub async fn get(key: &str) -> Result<Bytes, object_store::Error> {
    let path = Path::from(key);
    let result = store().get_opts(&path, GetOptions::default()).await?;
    result.bytes().await
}

pub async fn delete(key: &str) -> Result<(), object_store::Error> {
    let path = Path::from(key);
    let paths: Vec<Result<Path, object_store::Error>> = vec![Ok(path)];
    let mut results = store().delete_stream(Box::pin(stream::iter(paths)));
    while let Some(result) = results.next().await {
        result?;
    }
    Ok(())
}

pub fn generate_thumbnail_key(storage_key: &str) -> String {
    // e.g. "file/2024/07/12345.jpg" → "file/2024/07/12345_thumb.jpg"
    let dot = storage_key.rfind('.');
    if let Some(pos) = dot {
        let (base, _) = storage_key.split_at(pos);
        format!("{base}_thumb.jpg")
    } else {
        format!("{storage_key}_thumb.jpg")
    }
}

pub fn generate_thumbnail(data: &[u8], max_dim: u32) -> Result<(Vec<u8>, u32, u32), String> {
    let img = image::load_from_memory(data).map_err(|e| format!("image decode error: {e}"))?;
    let (w, h) = img.dimensions();

    // 原始图已小于 max_dim 则直接返回缩略图为原图
    if w <= max_dim && h <= max_dim {
        let mut buf = Cursor::new(Vec::new());
        img.write_to(&mut buf, image::ImageFormat::Jpeg)
            .map_err(|e| format!("image encode error: {e}"))?;
        return Ok((buf.into_inner(), w, h));
    }

    let ratio = (w as f64 / h as f64).min(h as f64 / w as f64);
    let (thumb_w, thumb_h) = if w > h {
        (max_dim, (max_dim as f64 / ratio).round() as u32)
    } else {
        ((max_dim as f64 / ratio).round() as u32, max_dim)
    };
    let thumb_w = thumb_w.max(1);
    let thumb_h = thumb_h.max(1);

    let thumb = img.resize(thumb_w, thumb_h, image::imageops::FilterType::Lanczos3);
    let mut buf = Cursor::new(Vec::new());
    thumb
        .write_to(&mut buf, image::ImageFormat::Jpeg)
        .map_err(|e| format!("image encode error: {e}"))?;
    Ok((buf.into_inner(), w, h))
}

pub async fn text_image_to_store(
    content: &str,
    category: &str,
) -> Result<String, Box<dyn std::error::Error + Send + Sync>> {
    let ext = "jpg";
    let key = generate_storage_key(category, ext);

    let tmp_dir = std::env::temp_dir();
    let tmp_name = key.replace('/', "_");
    let tmp_path = tmp_dir.join(&tmp_name);
    if let Some(parent) = tmp_path.parent() {
        tokio::fs::create_dir_all(parent).await?;
    }

    common::text_image::text_to_image(content, &tmp_path)?;
    let data = tokio::fs::read(&tmp_path).await?;
    let _ = tokio::fs::remove_file(&tmp_path).await;

    put(&key, data).await?;

    Ok(key)
}

/// Extract a video frame via ffmpeg CLI and return (jpeg_bytes, width, height).
/// Returns Err if ffmpeg is not installed or the command fails.
pub async fn generate_video_thumbnail(data: &[u8], ext: &str) -> Result<(Vec<u8>, u32, u32), String> {
    let tmp_dir = std::env::temp_dir();
    let input_name = format!("thumb_{}", id_gen(None));
    let input_path = tmp_dir.join(&input_name).with_extension(ext);
    let output_path = tmp_dir.join(&input_name).with_extension("jpg");

    tokio::fs::write(&input_path, data)
        .await
        .map_err(|e| format!("write tmp file: {e}"))?;

    let ip = input_path.clone();
    let op = output_path.clone();
    let result = tokio::task::spawn_blocking(move || {
        std::process::Command::new("ffmpeg")
            .arg("-i")
            .arg(&ip)
            .arg("-ss")
            .arg("00:00:01")
            .arg("-vframes")
            .arg("1")
            .arg("-q:v")
            .arg("2")
            .arg("-y")
            .arg(&op)
            .output()
    })
    .await
    .map_err(|e| format!("spawn ffmpeg: {e}"))?
    .map_err(|e| format!("ffmpeg failed: {e}"))?;

    let _ = tokio::fs::remove_file(&input_path).await;

    match result {
        ref out if out.status.success() => {
            let thumb_data = tokio::fs::read(&output_path)
                .await
                .map_err(|e| format!("read thumb: {e}"))?;
            let _ = tokio::fs::remove_file(&output_path).await;
            let (w, h) = match image::load_from_memory(&thumb_data) {
                Ok(img) => img.dimensions(),
                Err(_) => (0, 0),
            };
            Ok((thumb_data, w, h))
        }
        out => {
            let stderr = String::from_utf8_lossy(&out.stderr);
            Err(format!("ffmpeg failed: {stderr}"))
        }
    }
}
