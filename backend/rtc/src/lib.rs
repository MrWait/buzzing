mod signaling;
mod turn;

use axum::extract::Query;
use axum::routing::any;
use axum::response::IntoResponse;
use loco_rs::prelude::*;
use serde::Deserialize;

use common::ExternApp;

#[derive(Clone)]
pub struct AppRtc;
impl ExternApp for AppRtc {
    fn routes(&self, _: &AppContext) -> Vec<Routes> {
        vec![
            Routes::new()
                .add("/ws", any(signaling::meeting_handler)),
            Routes::new().prefix("/api/turn")
                .add("/", any(handle_turn_credential)),
        ]
    }

    fn serve(&self, ctx: &AppContext) {
        if let Ok(jwt_secret) = ctx.config.get_jwt_config() {
            signaling::init_jwt(jwt_secret.secret.clone());
        }
        let turn_secret = ctx
            .config
            .settings
            .as_ref()
            .and_then(|v| v.get("turn_secret").and_then(|v| v.as_str()))
            .unwrap_or("")
            .to_string();
        turn::init_secret(turn_secret);
        tokio::spawn(async move {
            let _ = turn::serve().await;
        });
    }
}

#[derive(Deserialize)]
struct TurnQuery {
    token: String,
}

async fn handle_turn_credential(query: Query<TurnQuery>) -> impl IntoResponse {
    match signaling::validate_token(&query.token) {
        Ok(_user) => {
            let (username, credential) = turn::generate_credential();
            format::json(serde_json::json!({
                "urls": ["turn:127.0.0.1:19302"],
                "username": username,
                "credential": credential
            }))
        }
        Err(e) => {
            format::json(serde_json::json!({
                "error": e
            }))
        }
    }
}
