pub mod auth;
pub mod docs;
pub mod members;
pub mod mentions;
pub mod render;
pub mod search;
pub mod shares;
pub mod spaces;
pub mod stars;
pub mod trash;
pub mod versions;
pub mod wikis;

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
            // M6 文档渲染（HTML 预览）
            .add("/docs/{id}/render", get(render::render))
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
            // M8.1 文档预览（IM 消息卡片）
            .add("/docs/{id}/preview", get(docs::preview))
            // M8.2 @提及搜索
            .add("/mentions/users", get(mentions::search_users))
            .add("/mentions/docs", get(mentions::search_docs))
            // M5 版本历史（diff 必须放在 {version_id} 之前，避免 `diff` 被解析为 version_id）
            .add("/docs/{id}/versions", get(versions::list))
            .add("/docs/{id}/versions", post(versions::create))
            .add("/docs/{id}/versions/diff", post(versions::diff))
            .add("/docs/{id}/versions/{version_id}", get(versions::get))
            .add("/docs/{id}/versions/{version_id}/restore", post(versions::restore))
            // M4 共享链接管理
            .add("/docs/{id}/share", post(shares::create))
            .add("/docs/{id}/shares", get(shares::list))
            .add("/docs/shares/{share_id}", delete(shares::revoke))
            // M7 知识库
            .add("/wikis", get(wikis::list))
            .add("/wikis", post(wikis::create))
            .add("/wikis/{id}", get(wikis::get))
            .add("/wikis/{id}", patch(wikis::update))
            .add("/wikis/{id}", delete(wikis::delete))
            .add("/wikis/{id}/members", get(wikis::list_members))
            .add("/wikis/{id}/members", post(wikis::add_member))
            .add("/wikis/{id}/members/{user_id}", delete(wikis::remove_member))
            .add("/wikis/{id}/spaces", get(wikis::list_spaces))
            .add("/wikis/{id}/recent", get(wikis::recent))
            .add("/wikis/{id}/pins", get(wikis::list_pins))
            .add("/wikis/{id}/pins", post(wikis::add_pin))
            .add("/wikis/{id}/pins/{doc_id}", delete(wikis::remove_pin)),
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
