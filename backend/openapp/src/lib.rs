mod handlers;
pub mod middleware;
pub mod models;
pub mod services;
mod error;

use async_trait::async_trait;
use loco_rs::prelude::*;
use loco_rs::{Result, app::AppContext};

use common::ExternApp;

#[derive(Clone)]
pub struct AppOpenApp;

#[async_trait]
impl ExternApp for AppOpenApp {
    fn routes(&self, _: &AppContext) -> Vec<Routes> {
        vec![
            Routes::new()
                .prefix("/openapi/v1")
                .add("/auth/tenant_access_token", post(handlers::auth::tenant_access_token))
                .add("/apps", post(handlers::app::create))
                .add("/apps", get(handlers::app::list))
                .add("/apps/{app_id}", get(handlers::app::get))
                .add("/apps/{app_id}", put(handlers::app::update))
                .add("/apps/{app_id}", delete(handlers::app::delete))
                .add("/apps/{app_id}/rotate_secret", post(handlers::app::rotate_secret))
                .add("/apps/{app_id}/bot", put(handlers::app::update_bot))
                .add("/bot/message", post(handlers::bot::send_message))
                .add("/bot/message/{message_id}", patch(handlers::bot::edit_message))
                .add("/bot/message/{message_id}/recall", post(handlers::bot::recall_message)),
        ]
    }
}
