pub mod auth;
pub mod docs;
pub mod members;
pub mod search;
pub mod shares;
pub mod spaces;
pub mod stars;
pub mod trash;

use loco_rs::prelude::*;
use crate::ws;

pub fn routes() -> Vec<Routes> {
    vec![
        Routes::new()
            .prefix("/api/office")
            // 空间
            .add("/spaces", get(spaces::list))
            .add("/spaces", post(spaces::create))
            .add("/spaces/archived", get(spaces::list_archived))
            .add("/spaces/{id}", put(spaces::update))
            .add("/spaces/{id}", delete(spaces::delete))
            .add("/spaces/{id}/archive", post(spaces::archive))
            // 文档 CRUD
            .add("/docs", get(docs::list))
            .add("/docs", post(docs::create))
            .add("/docs/search", post(search::search))
            .add("/docs/trash", get(trash::list))
            .add("/docs/starred", get(stars::list))
            .add("/docs/recent", get(docs::recent))
            .add("/docs/tree", get(docs::tree))
            .add("/docs/{id}", get(docs::get))
            .add("/docs/{id}", patch(docs::update))
            .add("/docs/{id}", delete(docs::delete))
            .add("/docs/{id}/edit-url", get(docs::edit_url))
            .add("/docs/{id}/permission", get(docs::permission))
            // M3 新增
            .add("/docs/{id}/move", post(docs::move_doc))
            .add("/docs/{id}/duplicate", post(docs::duplicate))
            .add("/docs/{id}/visit", post(docs::visit))
            .add("/docs/{id}/star", post(stars::star))
            .add("/docs/{id}/star", delete(stars::unstar))
            .add("/docs/{id}/restore", post(trash::restore))
            .add("/docs/{id}/purge", delete(trash::purge))
            // M4 成员管理
            .add("/docs/{id}/members", get(members::list))
            .add("/docs/{id}/members", post(members::add))
            .add("/docs/{id}/members/{user_id}", patch(members::update))
            .add("/docs/{id}/members/{user_id}", delete(members::remove))
            // M4 共享链接管理
            .add("/docs/{id}/share", post(shares::create))
            .add("/docs/{id}/shares", get(shares::list))
            .add("/docs/shares/{share_id}", delete(shares::revoke)),
        Routes::new()
            .prefix("/api/office/auth")
            .add("/login", post(auth::login)),
        // M4 公开共享入口
        Routes::new()
            .prefix("/api/share")
            .add("/{token}", get(shares::resolve))
            .add("/{token}/verify", post(shares::verify)),
        Routes::new()
            .prefix("/office")
            .add("/ws/{doc_id}", get(ws::ws_handler)),
    ]
}
