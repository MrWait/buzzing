use axum::http::header;
use axum::http::HeaderMap;
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use std::path::PathBuf;
use std::sync::LazyLock;

#[cfg(feature = "embed")]
use rust_embed::Embed;

#[cfg(feature = "embed")]
#[derive(Embed)]
#[folder = "../../frontend/dist"]
struct Assets;

static DIST_DIR: LazyLock<PathBuf> = LazyLock::new(|| {
    if let Ok(dir) = std::env::var("BUZZING_FRONTEND_DIST") {
        return PathBuf::from(dir);
    }
    // Try paths relative to CWD: backend/ or backend/base/
    for rel in ["../frontend/dist", "../../frontend/dist"] {
        let mut path = std::env::current_dir().unwrap_or_default();
        path.push(rel);
        if path.join("index.html").exists() {
            return path;
        }
    }
    // Fallback to manifest dir at compile time
    let mut path = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    path.push("../../frontend/dist");
    path
});

pub async fn spa_handler(axum::extract::Path(path): axum::extract::Path<String>) -> Response {
    let path = path.trim_start_matches('/');
    let path = if path.is_empty() { "index.html" } else { path };

    match load_file(path).await {
        Some(data) => serve(&data, path),
        None => match load_file("index.html").await {
            Some(data) => serve(&data, "index.html"),
            None => StatusCode::NOT_FOUND.into_response(),
        },
    }
}

pub async fn spa_index_handler() -> Response {
    match load_file("index.html").await {
        Some(data) => serve(&data, "index.html"),
        None => StatusCode::NOT_FOUND.into_response(),
    }
}

#[cfg(feature = "embed")]
async fn load_file(path: &str) -> Option<Vec<u8>> {
    Assets::get(path).map(|f| f.data.to_vec())
}

#[cfg(not(feature = "embed"))]
async fn load_file(path: &str) -> Option<Vec<u8>> {
    let full_path = DIST_DIR.join(path);
    tokio::fs::read(&full_path).await.ok()
}

fn serve(data: &[u8], path: &str) -> Response {
    let mime = mime_guess::from_path(path).first_or_octet_stream();
    let mut headers = HeaderMap::new();
    headers.insert(header::CONTENT_TYPE, mime.as_ref().parse().unwrap());
    (headers, data.to_vec()).into_response()
}
