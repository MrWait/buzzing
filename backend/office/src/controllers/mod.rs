pub mod auth;
pub mod docs;
pub mod render;
pub mod shares;
pub mod trash;

use loco_rs::prelude::*;
use crate::ws;

pub fn routes() -> Vec<Routes> {
    vec![
        Routes::new()
            .prefix("/api/office")
            // M6 文档渲染 (keep, no pb equivalent)
            .add("/docs/{id}/render", get(render::render))
            // M8.1 文档预览 (keep, no pb equivalent)
            .add("/docs/{id}/preview", get(docs::preview))
            // Auth (keep, no pb equivalent)
            .add("/auth/login", post(auth::login)),
        Routes::new()
            .prefix("/api/share")
            // 公开共享链接 (keep, public endpoints no auth)
            .add("/{token}", get(shares::resolve))
            .add("/{token}/verify", post(shares::verify)),
        Routes::new()
            .prefix("/office")
            .add("/ws/{doc_id}", get(ws::ws_handler)),
    ]
}
