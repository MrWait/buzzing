pub mod auth;
pub mod docs;
pub mod spaces;

use loco_rs::prelude::*;
use crate::ws;

pub fn routes() -> Vec<Routes> {
    vec![
        Routes::new()
            .prefix("/api/office")
            .add("/spaces", get(spaces::list))
            .add("/spaces", post(spaces::create))
            .add("/spaces/{id}", put(spaces::update))
            .add("/spaces/{id}", delete(spaces::delete))
            .add("/docs", get(docs::list))
            .add("/docs", post(docs::create))
            .add("/docs/{id}", get(docs::get))
            .add("/docs/{id}", patch(docs::update))
            .add("/docs/{id}", delete(docs::delete))
            .add("/docs/{id}/edit-url", get(docs::edit_url)),
        Routes::new()
            .prefix("/api/office/auth")
            .add("/login", post(auth::login)),
        Routes::new()
            .prefix("/office")
            .add("/ws/{doc_id}", get(ws::ws_handler)),
    ]
}
