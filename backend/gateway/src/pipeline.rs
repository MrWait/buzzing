use common::pb_decode;
use loco_rs::{Result, app::AppContext};
use moka::future::Cache;
use prost::Message;
use std::sync::{Arc, LazyLock};
use tokio::sync::RwLock;
use tokio::sync::mpsc::{UnboundedReceiver, UnboundedSender};
use tracing::debug;

use crate::models::pipelines::{self, PipelineModel};
use base::util::EntityType;
use common::model::UserBrief;
use proto::idl::{command, entity, pipeline};

#[allow(dead_code)]
struct PipeContext {
    user_id: i64,
    packets: Vec<entity::Packet>,
    last_sid: i64,
    ch: UnboundedReceiver<entity::Packet>,
}

#[allow(dead_code)]
type CacheEntry = Arc<RwLock<PipeContext>>;
#[allow(dead_code)]
static CACHE_PIPE: LazyLock<Cache<i64, CacheEntry>> = LazyLock::new(|| Cache::new(100));
#[allow(dead_code)]
static PIPE_TX: LazyLock<dashmap::DashMap<i64, UnboundedSender<entity::Packet>>> =
    LazyLock::new(|| dashmap::DashMap::new());

// pipeline: 数据存储在 Postgres 中，通过 pipelines 表持久化，重启不丢失。
// global: 租户内用户共享
// personal: 用户级别
// group: 聚合模式，按特定规则选取批量用户

// pipeline-{type}-{id}
#[allow(dead_code)]
fn pipe_name(tpy: EntityType, id: i64) -> String {
    format!("pipeline-{:?}-{}", tpy, id)
}

#[allow(dead_code)]
pub(crate) async fn open_pipeline(_user_id: i64) -> Result<()> {
    Ok(())
}

#[allow(dead_code)]
pub(crate) async fn put_pipeline_packet() -> Result<()> {
    Ok(())
}

#[allow(dead_code)]
pub(crate) async fn get_pipeline_packet() -> Result<()> {
    Ok(())
}

#[allow(dead_code)]
pub(crate) async fn send_packet_to_tenant() -> Result<()> {
    Ok(())
}

#[allow(dead_code)]
#[allow(unused_variables)]
pub(crate) async fn send_packet_to_chat(
    ctx: &AppContext,
    id: i64,
    cmd: command::Command,
    packet: Vec<u8>,
    persist: bool,
    need_ack: bool,
) -> Result<()> {
    Ok(())
}

#[allow(dead_code)]
#[allow(unused_variables)]
pub(crate) async fn pipeline_pull_packet(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<pipeline::PullPipelineRequest>(&packet.payload)?;
    debug!("pipeline pull packets, req: {req:?}");
    let mut resp = pipeline::PullPipelineResponse::default();
    resp.packets = PipelineModel::find_by_sid(&ctx.db, brief.id, req.sid, req.count as u64)
        .await?
        .drain(..)
        .map(|p| p.into())
        .collect();
    resp.has_more = resp.packets.len() == (req.count as usize);
    debug!("pipeline pull packets, resp: {resp:?}");
    Ok((0, resp.encode_to_vec()))
}

#[allow(dead_code)]
#[allow(unused_variables)]
pub(crate) async fn pipeline_pull_entity(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    ws: bool,
) -> Result<(i32, Vec<u8>)> {

    Ok((0, vec![]))
}
