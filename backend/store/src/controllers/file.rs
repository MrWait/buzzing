#![allow(clippy::missing_errors_doc)]
#![allow(clippy::unnecessary_struct_initialization)]
#![allow(clippy::unused_async)]
use axum::body::Body;
use axum::debug_handler;
use axum::extract::multipart::Multipart;
use axum::http::header;
use axum::response::Html;
use loco_rs::prelude::*;
use std::path::PathBuf;
use tracing::debug;

use common::id_gen;

fn gen_path(mut base: PathBuf, mut id: u64) -> (PathBuf, String) {
    let mut url = String::new();
    for _ in 0..2 {
        debug!("concat id: {}", id);
        id = id >> 16;
        let f = format!("{:04X}", (id & 0xFFFF) as u16);
        base = base.join(&f);
        url.push_str("/");
        url.push_str(&f);
    }
    (base, url)
}

async fn upload_page() -> Html<&'static str> {
    Html(
        r#"
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>upload file</title>
</head>
<body>
<form action="/storage/avatar/upload" method="post" enctype="multipart/form-data">
<label>
upload file: <input type="file" name="file">
</label>
<button type="submit">upload</button>
</form>
</body>
</html>
"#,
    )
}

pub async fn generate_text_image(
    ctx: &AppContext,
    content: &str,
    category: &str,
) -> Result<String> {
    let fid = id_gen(None);
    let file_name = format!("{}.{}", fid, "jpg");
    let base = PathBuf::from(STORAGE_DIR);
    let base = base.join(category);
    let (mut base, mut url) = gen_path(base, fid as u64);
    url = format!(
        "{}:{}/storage/f/{}{}/{}",
        ctx.config.server.host, ctx.config.server.port, category, url, file_name
    );
    let _ = tokio::fs::create_dir_all(&base).await;
    base = base.join(&file_name);
    if let Err(err) = common::text_image::text_to_image(content, base.as_path()) {
        debug!("text to image error: {:?}", err);
        return Err(Error::InternalServerError);
    }
    Ok(url)
}

pub async fn upload(
    ctx: &AppContext,
    category: String,
    mut multipart: Multipart,
) -> Result<String> {
    if let Some(file) = multipart
        .next_field()
        .await
        .map_err(|_err| Error::BadRequest("bad request".to_string()))?
    {
        let content_type = file.content_type().unwrap_or("unknown");
        let index = content_type.find("/").map(|i| i).unwrap_or(std::usize::MAX);

        let mut ext = "dat";
        if index != std::usize::MAX {
            ext = &content_type[index + 1..];
        }

        let fid = id_gen(None);

        let file_name = format!("{}.{}", fid, ext);

        let base = PathBuf::from(STORAGE_DIR);
        let base = base.join("f").join(&category);
        let (mut base, url) = gen_path(base, fid as u64);
        let _ = tokio::fs::create_dir_all(&base).await;
        base = base.join(&file_name);

        debug!("start write file, {:?}", base);
        let data = file
            .bytes()
            .await
            .map_err(|_err| Error::BadRequest("bad request".to_string()))?;
        tokio::fs::write(base.to_str().unwrap(), &data).await?;
        let mut host = ctx.config.server.host.clone();
        if ctx.config.server.port != 80 {
            host = host + ":" + &ctx.config.server.port.to_string()
        }
        let url = host + "/storage/f/" + &category + "/" + &url + "/" + file_name.as_str();

        debug!("upload file, id: {:?}, {:?},{:?}", fid, base, url);
        Ok(url)
    } else {
        Err(Error::BadRequest("no file".to_string()))
    }
}

const STORAGE_DIR: &str = "storage";

#[debug_handler]
pub async fn download(
    State(_ctx): State<AppContext>,
    Path(path): Path<String>,
) -> Result<impl IntoResponse> {
    let subs: Vec<String> = path.split("/").map(|s| s.to_string()).collect();
    debug!("start download file: {:?}, subs: {:?}", path, subs);
    let mut file_path: PathBuf = PathBuf::from(STORAGE_DIR);
    for sub in subs {
        file_path = file_path.join(sub);
    }

    debug!("start download file: {:?}, file: {:?}", path, file_path);
    if file_path.is_file() {
        let file =
            tokio::fs::File::open(file_path.to_str().ok_or(Error::InternalServerError)?).await?;
        let stream = tokio_util::io::ReaderStream::new(file);
        let body = Body::from_stream(stream);

        let headers = [
            (
                header::CONTENT_TYPE,
                "text/plain; charset=utf-8".to_string(),
            ),
            (
                header::CONTENT_DISPOSITION,
                format!(
                    "attachment; filename=\"{}\"",
                    file_path
                        .file_name()
                        .ok_or(Error::InternalServerError)?
                        .to_str()
                        .ok_or(Error::InternalServerError)?
                ),
            ),
        ];
        debug!("file headers: {:?}", headers);
        Ok((headers, body))
    } else {
        Err(Error::BadRequest("file not found".to_string()))
    }
}

#[debug_handler]
pub async fn upload_avatar(
    State(ctx): State<AppContext>,
    multipart: Multipart,
) -> Result<Response> {
    let url = upload(&ctx, "avatar".to_string(), multipart).await?;
    format::text(&url)
}

#[debug_handler]
pub async fn upload_icon(State(ctx): State<AppContext>, multipart: Multipart) -> Result<Response> {
    let url = upload(&ctx, "icon".to_string(), multipart).await?;
    format::text(&url)
}

#[debug_handler]
pub async fn upload_file(State(ctx): State<AppContext>, multipart: Multipart) -> Result<Response> {
    let url = upload(&ctx, "file".to_string(), multipart).await?;
    format::text(&url)
}

pub fn routes() -> Routes {
    Routes::new()
        .prefix("storage")
        .add("/", get(upload_page))
        .add("/f/{*path}", get(download))
        .add("/avatar/upload", post(upload_avatar))
        .add("/icon/upload", post(upload_icon))
        // .prefix("storage/im")
        .add("/file/upload", post(upload_file))
}
