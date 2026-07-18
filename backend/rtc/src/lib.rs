mod meeting;
mod models;
mod signaling;
mod turn;

use axum::extract::Query;
use axum::routing::any;
use axum::response::IntoResponse;
use loco_rs::prelude::*;
use serde::Deserialize;
use tracing::debug;

use common::ExternApp;
use proto::idl::{command::Command, entity};

#[derive(Clone)]
pub struct AppRtc;

#[async_trait::async_trait]
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
        // 缓存 AppContext，供 ws handler 中通过 BizHub 跨模块查询用户名等数据
        signaling::init_ctx(ctx.clone());
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

    fn handled_command(&self) -> Vec<i32> {
        vec![
            Command::MeetingCreate as i32,
            Command::MeetingJoin as i32,
            Command::MeetingLeave as i32,
            Command::MeetingEnd as i32,
            Command::MeetingGetInfo as i32,
            Command::MeetingGetList as i32,
            Command::MeetingKick as i32,
            Command::MeetingSetRole as i32,
            Command::MeetingInvite as i32,
        ]
    }

    async fn handle_client_packet(
        &self,
        cmd: i32,
        ctx: &AppContext,
        brief: &common::UserBrief,
        packet: &entity::Packet,
        ws: bool,
    ) -> loco_rs::Result<(i32, Vec<u8>)> {
        let cmd: Command = cmd
            .try_into()
            .map_err(|_| loco_rs::Error::string("cmd parse error"))?;
        let (code, data) = match cmd {
            Command::MeetingCreate => meeting::handle_create(ctx, brief, packet, ws).await?,
            Command::MeetingJoin => meeting::handle_join(ctx, brief, packet, ws).await?,
            Command::MeetingLeave => meeting::handle_leave(ctx, brief, packet, ws).await?,
            Command::MeetingEnd => meeting::handle_end(ctx, brief, packet, ws).await?,
            Command::MeetingGetInfo => meeting::handle_get_info(ctx, brief, packet, ws).await?,
            Command::MeetingGetList => meeting::handle_get_list(ctx, brief, packet, ws).await?,
            Command::MeetingKick => meeting::handle_kick(ctx, brief, packet, ws).await?,
            Command::MeetingSetRole => meeting::handle_set_role(ctx, brief, packet, ws).await?,
            Command::MeetingInvite => meeting::handle_invite(ctx, brief, packet, ws).await?,
            _ => return Err(loco_rs::Error::string("unhandled meeting cmd")),
        };
        Ok((code, data))
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
