mod handlers;
pub mod middleware;
pub mod models;
pub mod services;
mod error;

use async_trait::async_trait;
use loco_rs::prelude::*;
use loco_rs::{Result, app::AppContext};

use common::{ExternApp, BizOpenApp};
use proto::idl::command::Command;

#[derive(Clone)]
pub struct AppOpenApp;

#[async_trait]
impl ExternApp for AppOpenApp {
    fn routes(&self, _: &AppContext) -> Vec<Routes> {
        vec![
            Routes::new()
                .prefix("/api/openapi/v1")
                // M1: Auth & App CRUD
                .add("/auth/tenant_access_token", post(handlers::auth::tenant_access_token))
                .add("/apps", post(handlers::app::create))
                .add("/apps", get(handlers::app::list))
                .add("/apps/{app_id}", get(handlers::app::get))
                .add("/apps/{app_id}", put(handlers::app::update))
                .add("/apps/{app_id}", delete(handlers::app::delete))
                .add("/apps/{app_id}/rotate_secret", post(handlers::app::rotate_secret))
                .add("/apps/{app_id}/bot", put(handlers::app::update_bot))
                // M1: Bot messages
                .add("/bot/message", post(handlers::bot::send_message))
                .add("/bot/message/{message_id}", patch(handlers::bot::edit_message))
                .add("/bot/message/{message_id}/recall", post(handlers::bot::recall_message))
                .add("/bot/message/{message_id}/reactions", post(handlers::bot::add_reaction))
                .add("/bot/message/{message_id}/reactions", delete(handlers::bot::remove_reaction))
                // M2: IM open API
                .add("/im/chats/{chat_id}", get(handlers::open_api::get_chat))
                .add("/im/chats/{chat_id}/members", get(handlers::open_api::list_chat_members))
                .add("/im/chats/{chat_id}/messages", get(handlers::open_api::list_messages))
                .add("/im/messages", post(handlers::open_api::send_message))
                // M2: User open API
                .add("/user/users/{user_id}", get(handlers::open_api::get_user))
                .add("/user/users/batch", post(handlers::open_api::batch_get_users))
                .add("/user/depts", get(handlers::open_api::list_depts))
                .add("/user/depts/{dept_id}", get(handlers::open_api::get_dept))
                .add("/user/depts/{dept_id}/members", get(handlers::open_api::list_dept_members))
                // M2: Calendar open API
                .add("/calendar/calendars", get(handlers::open_api::list_calendars))
                .add("/calendar/events", get(handlers::open_api::list_events))
                .add("/calendar/events", post(handlers::open_api::create_event))
                // M2: OAuth
                .add("/oauth/authorize", get(handlers::oauth::authorize))
                .add("/oauth/authorize", post(handlers::oauth::confirm_authorize))
                .add("/oauth/token", post(handlers::oauth::token))
                .add("/oauth/authorizations/{id}", delete(handlers::oauth::revoke_authorization))
                // M2: Stats
                .add("/apps/stats/{app_id}", get(handlers::open_api::get_app_stats))
                .add("/apps/stats/{app_id}/error_logs", get(handlers::open_api::get_error_logs))
                // M2: Outgoing Webhook
                .add("/apps/{app_id}/outgoing_webhooks", post(handlers::app::create_outgoing_webhook))
                .add("/apps/{app_id}/outgoing_webhooks/{webhook_id}", put(handlers::app::update_outgoing_webhook))
                .add("/apps/{app_id}/outgoing_webhooks/{webhook_id}", delete(handlers::app::delete_outgoing_webhook))
                .add("/apps/{app_id}/outgoing_webhooks", get(handlers::app::list_outgoing_webhooks))
                // M3: Card
                .add("/bot/card/{message_id}", patch(handlers::card::update_card))
                .add("/bot/card/action", post(handlers::card::handle_card_action))
                // M3: Bot management
                .add("/bot/chats", post(handlers::bot::create_chat))
                .add("/bot/chats/{chat_id}/members", post(handlers::bot::add_chat_members))
                .add("/bot/chats/{chat_id}/members", delete(handlers::bot::remove_chat_members))
                .add("/bot/chats/{chat_id}/announcement", put(handlers::bot::set_announcement))
                // M3: Scheduled tasks
                .add("/bot/scheduled_tasks", post(handlers::bot::create_scheduled_task))
                .add("/bot/scheduled_tasks", get(handlers::bot::list_scheduled_tasks))
                .add("/bot/scheduled_tasks/{task_id}", put(handlers::bot::update_scheduled_task))
                .add("/bot/scheduled_tasks/{task_id}", delete(handlers::bot::delete_scheduled_task))
                .add("/bot/scheduled_tasks/{task_id}/pause", post(handlers::bot::pause_scheduled_task))
                .add("/bot/scheduled_tasks/{task_id}/resume", post(handlers::bot::resume_scheduled_task))
                // M4: Versions
                .add("/apps/{app_id}/versions", post(handlers::market::submit_version))
                .add("/apps/{app_id}/versions", get(handlers::market::list_versions))
                // M4: Market
                .add("/market/apps", get(handlers::market::list_market_apps))
                .add("/market/apps/{app_id}", get(handlers::market::get_market_app_detail))
                .add("/market/install", post(handlers::market::install))
                .add("/market/installed", get(handlers::market::list_installed))
                .add("/market/installed/{id}/enable", post(handlers::market::enable_installation))
                .add("/market/installed/{id}/disable", post(handlers::market::disable_installation))
                .add("/market/installed/{id}", delete(handlers::market::uninstall))
                // M4: Reviews
                .add("/market/apps/{app_id}/reviews", post(handlers::market::create_review))
                .add("/market/apps/{app_id}/reviews", get(handlers::market::list_reviews))
                .add("/market/apps/{app_id}/reviews/{review_id}/reply", post(handlers::market::reply_review))
                .add("/market/apps/{app_id}/ratings", get(handlers::market::get_ratings))
                // M4: Admin
                .add("/admin/reviews", get(handlers::admin::list_reviews))
                .add("/admin/reviews/{version_id}", get(handlers::admin::review_detail))
                .add("/admin/reviews/{version_id}/approve", post(handlers::admin::approve))
                .add("/admin/reviews/{version_id}/reject", post(handlers::admin::reject))
                .add("/admin/reviews/{app_id}/unpublish", post(handlers::admin::unpublish))
                // M4: Dashboard
                .add("/dashboard/overview", get(handlers::dashboard::overview))
                .add("/dashboard/trends", get(handlers::dashboard::trends)),
        ]
    }

    fn handled_command(&self) -> Vec<i32> {
        vec![
            Command::CmdCardAction as i32,
            Command::CmdCardUpdate as i32,
            Command::CmdCardTemplate as i32,
        ]
    }

    fn serve(&self, ctx: &AppContext) {
        let ctx = ctx.clone();
        tokio::spawn(async move {
            match crate::services::scheduler::TaskScheduler::start(&ctx).await {
                Ok(_) => tracing::info!("Task scheduler started successfully"),
                Err(e) => tracing::warn!("Task scheduler failed to start: {e}"),
            }
        });
    }
}

#[async_trait]
impl BizOpenApp for AppOpenApp {
    async fn dispatch_event(
        &self,
        ctx: &AppContext,
        app_db_id: i64,
        app_id_str: &str,
        event_type: &str,
        payload_json: &str,
    ) -> loco_rs::Result<()> {
        let event_type = services::webhook::EventType::from_str(event_type)
            .ok_or_else(|| loco_rs::Error::InternalServerError)?;
        let payload: serde_json::Value = serde_json::from_str(payload_json)
            .map_err(|_| loco_rs::Error::InternalServerError)?;

        let ctx_clone = ctx.clone();
        let app_id_str = app_id_str.to_string();
        tokio::spawn(async move {
            services::webhook::dispatch_event(&ctx_clone, app_db_id, &app_id_str, event_type, payload).await;
        });

        Ok(())
    }
}
