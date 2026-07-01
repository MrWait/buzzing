mod models;
mod pipeline;
mod websocket;

use async_trait::async_trait;
use axum::body::Body;
use axum::debug_handler;
use axum::extract::Multipart;
use axum::http::HeaderMap;
use loco_rs::{Error, Result, app::AppContext, prelude::*};
use std::collections::HashMap;
use std::sync::Arc;
use tracing::{debug, instrument};

use common::{AppHub, BizGateway, ExternApp, UserBrief, gen_i32, id_gen};
use models::pipelines;
use proto::idl::{command::Command, entity};

#[derive(Clone)]
pub struct AppGateway;
#[async_trait]
impl ExternApp for AppGateway {
    fn routes(&self, _: &AppContext) -> Vec<Routes> {
        vec![
            Routes::new()
                .prefix("/api/v1")
                .add("/", post(handle_gateway))
                .add("/test", get(handle_id_gen)),
        ]
    }
    fn serve(&self, ctx: &AppContext) {
        websocket::start_server(ctx);
    }

    fn handled_command(&self) -> Vec<i32> {
        vec![
            Command::PipelinePullPacket as i32,
            Command::PipelinePullEntity as i32,
        ]
    }

    async fn handle_client_packet(
        &self,
        _cmd: i32,
        ctx: &AppContext,
        brief: &UserBrief,
        packet: &entity::Packet,
        ws: bool,
    ) -> Result<(i32, Vec<u8>)> {
        let cmd: Command = packet
            .cmd
            .try_into()
            .map_err(|_| Error::string("cmd parse error"))?;
        let (code, data) = match cmd {
            // pipeline
            Command::PipelinePullPacket => {
                pipeline::pipeline_pull_packet(ctx, brief, packet, ws).await?
            }
            Command::PipelinePullEntity => {
                pipeline::pipeline_pull_entity(ctx, brief, packet, ws).await?
            }
            _ => (0, vec![]),
        };
        Ok((code, data))
    }
}

#[async_trait]
impl BizGateway for AppGateway {
    async fn send_packet_to_user(
        &self,
        ctx: &AppContext,
        user_ids: &[i64],
        sid: i64,
        cmd: Command,
        body: Vec<u8>,
        pipe: bool,
    ) -> Result<()> {
        if pipe {
            let _ =
                pipelines::PipelineModel::save_packet(&ctx.db, user_ids, sid, cmd as i32, &body)
                    .await;
        }

        let _ = websocket::send_packet_to_users(ctx, user_ids, cmd, sid, body).await;
        Ok(())
    }
}

#[debug_handler]
async fn handle_id_gen() -> &'static str {
    let tenant_id = id_gen(None);
    let user_id = id_gen(Some(false));
    let dept_id = id_gen(None);
    debug!("create tenant, id: {tenant_id}, owner: {user_id}, dept_id: {dept_id}");
    "ok"
}

#[debug_handler]
pub(crate) async fn handle_gateway(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    header: HeaderMap,
    mut data: Multipart,
) -> Result<impl IntoResponse> {
    debug!("api v1 recv data, header:{:?}, : {:?}", header, data);
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let rid: i64 = header
        .get("rid")
        .and_then(|v| v.to_str().ok())
        .and_then(|v| v.parse().ok())
        .ok_or(Error::BadRequest("parse error".to_string()))?;
    let cmd: i32 = header
        .get("cmd")
        .and_then(|v| v.to_str().ok())
        .and_then(|v| v.parse().ok())
        .ok_or(Error::BadRequest("parse error".to_string()))?;
    if let Some(body) = data
        .next_field()
        .await
        .map_err(|_| Error::BadRequest("bad request".to_string()))?
    {
        let mut packet = entity::Packet::default();
        packet.cmd = cmd;
        packet.rid = rid;
        packet.payload = body
            .bytes()
            .await
            .map_err(|_| Error::BadRequest("bad request".to_string()))?
            .to_vec();
        let (code, data) = handle_client_packet(0, cmd, &ctx, &claim, &packet, false)
            .await
            .map_err(|_| Error::BadRequest("handle error".to_string()))?;

        let headers = [("rid", rid.to_string()), ("code", code.to_string())];
        let res = Body::from(data);

        Ok((headers, res))
    } else {
        Err(Error::NotFound)
    }
}

pub fn routes() -> Routes {
    Routes::new()
        .prefix("/api/v1")
        .add("/", post(handle_gateway))
}

#[allow(dead_code)]
pub(crate) struct ChatContext {
    chat: entity::Chat,
    message: Option<entity::Message>,
}

#[allow(dead_code)]
pub(crate) struct UserFeedContext {
    feeds: HashMap<i64, Arc<entity::Feed>>,
    feed_sort: Vec<(i64, Arc<entity::Feed>)>,
}

#[instrument(skip(ctx, brief, packet, ws), fields(sid=gen_i32()))]
pub(crate) async fn handle_client_packet(
    conn_id: i64,
    cmd: i32,
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    ws: bool,
) -> Result<(i32, Vec<u8>)> {
    debug!(
        "start handle client packet, connid: {conn_id} cmd: {cmd} {}, user: {}",
        packet.rid, brief.id
    );
    AppHub::get()?
        .handle_packet(cmd, ctx, brief, packet, ws)
        .await
}
