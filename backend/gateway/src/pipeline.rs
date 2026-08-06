use common::pb_decode;
use loco_rs::{Result, app::AppContext};
use moka::future::Cache;
use prost::Message;
use sea_orm::{ConnectionTrait, TransactionTrait};
use std::collections::{BTreeMap, HashMap};
use std::sync::{Arc, LazyLock};
use tokio::sync::RwLock;
use tokio::sync::mpsc::{UnboundedReceiver, UnboundedSender};
use tracing::{debug, warn};

use crate::models::pipeline_cleanup_state::CleanupStateModel;
use crate::models::pipelines::{self, PipelineModel};
use base::util::EntityType;
use common::model::UserBrief;
use proto::idl::{command, entity, pipeline};
use setting::models::settings::SettingModel;

// pipeline TTL 清理水位线使用的设置类型（见 entity.proto SettingType）
const SETTING_TYPE_WATERMARK: i32 = entity::SettingType::SettingPipelineWatermark as i32;
// TTL 清理默认值（未在 config settings 中配置时）：30 天过期、每 24 小时清理一次
const DEFAULT_TTL_SECONDS: u64 = 30 * 24 * 3600;
const DEFAULT_CLEANUP_INTERVAL_SECONDS: u64 = 24 * 3600;

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

// 单个合并后的 1057 包最多承载的变更数（超出拆包，防止单包过大）
const MERGE_CHANGES_LIMIT: usize = 2048;
// 拉取窗口下限：单次至少 load 这么多行做 1057 全局合并（请求 count 更大时按 count）。
// 支持超额返回——响应包数可超过请求 count，SDK 侧按 sid 翻页不受包数限制。
const LOAD_LIMIT: usize = 500;

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

#[allow(unused_variables)]
pub(crate) async fn pipeline_pull_packet(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<pipeline::PullPipelineRequest>(&packet.payload)?;
    debug!("pipeline pull packets, req: {req:?}");
    let mut resp = pipeline::PullPipelineResponse::default();
    let watermark = pipeline_watermark_get(&ctx.db, brief.id).await?;
    resp.min_sid = watermark;

    // 全新安装（cursor=0）：无需回放历史，返回当前最大 sid（无数据为 0）。
    // 客户端初始数据走 feed 全量同步，此处不返回 packets。
    if req.sid == 0 {
        resp.sid = PipelineModel::find_max_sid(&ctx.db, brief.id).await?;
        debug!(
            "pipeline pull fresh, sid: {}, watermark: {}",
            resp.sid, watermark
        );
        return Ok((0, resp.encode_to_vec()));
    }

    // 数据已被 TTL 清理（本地 cursor 落后于清理水位）：仅返回 expired + sid。
    // 客户端据此软重置本地数据（清表 + feed 全量同步），不依赖具体缺失行。
    if req.sid < watermark {
        resp.sid = PipelineModel::find_max_sid(&ctx.db, brief.id).await?;
        resp.expired = true;
        debug!(
            "pipeline pull expired, req_sid: {}, watermark: {}, max_sid: {}",
            req.sid, watermark, resp.sid
        );
        return Ok((0, resp.encode_to_vec()));
    }

    // ── 正常拉取：合并窗口下限 LOAD_LIMIT 行，保证离线积压的 1057 突发在窗口内全局合并 ──
    // 返回的包数可超过请求 count（超额返回），SDK 按 sid 翻页消费。
    let load = std::cmp::max(req.count as usize, LOAD_LIMIT);
    let rows = PipelineModel::find_by_sid(&ctx.db, brief.id, req.sid, load as u64).await?;
    // 以「取到整页行数」判定是否还有更多：合并压缩后包数会少于行数，
    // 不能再用 packets.len()==count 的启发式，否则会提前终止丢数据。
    resp.has_more = load > 0 && rows.len() == load;

    // ── PUSH_ENTITY_CHANGE(1057) 包合并压缩（见 docs/data_sync）────────────────
    // 策略1（合并）：同一实体 (type,id) 多次变更只保留 version 最大的一条（连同其 operate）。
    // 策略2（压缩）：窗口内所有 1057 行收敛为 1 个（超限拆包）PushEntityChanged 包，
    //   放在被合并行最后一条的位置，rid 取被合并行最大 sid，保证游标推进。
    let mut passthrough: Vec<entity::Packet> = Vec::new(); // 非 1057 行 + 解码失败的 1057 行，原样透传
    let mut merged: BTreeMap<(i32, i64), (i64, i32)> = BTreeMap::new(); // (type,id) -> (max_version, operate)
    let mut last_merged_sid: i64 = 0;
    for pm in rows {
        let sid = pm.0.sid;
        if pm.0.command == command::Command::PushEntityChange as i32 {
            match pipeline::PushEntityChanged::decode(&pm.0.data[..]) {
                Ok(push) => {
                    last_merged_sid = sid;
                    for change in push.changes {
                        let key = (change.r#type, change.id);
                        let e = merged.entry(key).or_insert((change.version, change.operate));
                        if change.version > e.0 {
                            e.0 = change.version;
                            e.1 = change.operate;
                        }
                    }
                }
                Err(_) => passthrough.push(pm.into()),
            }
        } else {
            passthrough.push(pm.into());
        }
    }
    // 重建合并包：按 (type,id) 排序保证确定性，超限拆包（每包最多 MERGE_CHANGES_LIMIT 条变更）
    let mut merged_packets: Vec<entity::Packet> = Vec::new();
    if !merged.is_empty() {
        let all_changes: Vec<entity::EntityChange> = merged
            .iter()
            .map(|((t, id), (version, operate))| entity::EntityChange {
                id: *id,
                r#type: *t,
                version: *version,
                operate: *operate,
            })
            .collect();
        for chunk in all_changes.chunks(MERGE_CHANGES_LIMIT) {
            let push = pipeline::PushEntityChanged {
                changes: chunk.to_vec(),
                ..Default::default()
            };
            let mut p = entity::Packet::default();
            p.rid = last_merged_sid;
            p.cmd = command::Command::PushEntityChange as i32;
            p.payload = push.encode_to_vec();
            merged_packets.push(p);
        }
    }
    // 透传包按 sid 顺序输出，合并包插在被合并行最后一条之后（保持与其他命令的相对顺序）
    let mut emitted = merged_packets.is_empty();
    for p in passthrough {
        if !emitted && p.rid > last_merged_sid {
            resp.packets.append(&mut merged_packets);
            emitted = true;
        }
        resp.packets.push(p);
    }
    if !emitted {
        resp.packets.append(&mut merged_packets);
    }

    resp.sid = resp
        .packets
        .last()
        .map(|p| p.rid)
        .unwrap_or(req.sid);
    // 注意：拉取不再删除已返回的 pipeline 行（delete_le_sid 已移除）——
    // pipeline 数据多设备共享，不能因单个设备拉取就清理，清理统一交给 TTL worker。
    debug!(
        "pipeline pull packets, resp: packets={}, sid={}, has_more={}, expired={}",
        resp.packets.len(),
        resp.sid,
        resp.has_more,
        resp.expired
    );
    Ok((0, resp.encode_to_vec()))
}

// ── pipeline TTL 清理 & 水位线（见 docs/data_sync）─────────────────────────
// 水位线语义：删数据的一方回答「丢没丢」。TTL 清理删除行后，按用户记录被删行的
// max(sid)，客户端 cursor>0 且 < 水位线即判定数据丢失（expired），触发软重置。

/// 从 settings 表存储的水位线字节（i64 LE）解析出 sid。
fn watermark_from_data(data: &[u8]) -> i64 {
    if data.len() == 8 {
        i64::from_le_bytes(data[..8].try_into().unwrap_or([0; 8]))
    } else {
        0
    }
}

/// 读取用户 pipeline 水位线（TTL 清理到的最远 sid），无记录为 0。
async fn pipeline_watermark_get<C: ConnectionTrait>(
    db: &C,
    user_id: i64,
) -> Result<i64> {
    let setting = SettingModel::setting_get(db, user_id, SETTING_TYPE_WATERMARK).await?;
    Ok(setting.map(|s| watermark_from_data(&s.data)).unwrap_or(0))
}

/// 更新用户 pipeline 水位线（单调递增：取 max 再写入）。
async fn pipeline_watermark_update<C: ConnectionTrait>(
    db: &C,
    user_id: i64,
    watermark: i64,
) -> Result<()> {
    SettingModel::setting_update(
        db,
        user_id,
        SETTING_TYPE_WATERMARK,
        Box::new(move |s| {
            let cur = watermark_from_data(&s.data);
            let next = std::cmp::max(cur, watermark);
            let mut setting = s;
            setting.data = next.to_le_bytes().to_vec();
            Ok(setting)
        }),
    )
    .await?;
    Ok(())
}

/// 读取 config settings 中的 pipeline TTL 配置（秒），缺失时用默认值。
fn pipeline_config(ctx: &AppContext) -> (u64, u64) {
    let settings = ctx
        .config
        .settings
        .as_ref()
        .and_then(|v| serde_json::from_value::<common::Settings>(v.clone()).ok());
    let ttl = settings
        .as_ref()
        .and_then(|s| s.pipeline_ttl_seconds)
        .unwrap_or(DEFAULT_TTL_SECONDS);
    let interval = settings
        .as_ref()
        .and_then(|s| s.pipeline_cleanup_interval_seconds)
        .unwrap_or(DEFAULT_CLEANUP_INTERVAL_SECONDS);
    (ttl, interval)
}

/// 启动 pipeline TTL 清理后台任务（在 AppGateway::serve 中调用）。
/// 上次执行时间持久化到 pipeline_cleanup_state 表：服务重启后按间隔自动补跑，
/// 不依赖进程内 timer 生命周期。
pub(crate) fn start_cleanup_worker(ctx: &AppContext) {
    let ctx = ctx.clone();
    tokio::spawn(async move {
        loop {
            if let Err(err) = pipeline_cleanup_once(&ctx).await {
                warn!("pipeline cleanup error: {err:?}");
            }
            let (_ttl, interval) = pipeline_config(&ctx);
            tokio::time::sleep(std::time::Duration::from_secs(interval)).await;
        }
    });
    debug!("pipeline cleanup worker started");
}

/// 单次 TTL 清理：过期行删除 + 每用户水位线更新 + 记录执行时间，单事务完成，
/// 避免「删了行但水位没记」的中间态。
async fn pipeline_cleanup_once(ctx: &AppContext) -> Result<()> {
    let (ttl, interval) = pipeline_config(ctx);
    let now = common::time::current_s() as i64;
    let last = CleanupStateModel::get(&ctx.db).await?;
    // 距上次执行未到周期则跳过（间隔主要由 sleep 控制，这里兜底处理重启后的并发窗口）
    if last > 0 && now - last < interval as i64 {
        return Ok(());
    }

    let cutoff_ms = now * 1000 - ttl as i64 * 1000;
    let tx = ctx.db.begin().await?;
    // 先查再删（同一事务）：聚合按 created_at < cutoff 命中的 (user_id, sid)，
    // 事务内新增的行 created_at 必然 >= cutoff，不会漏记水位。
    let expired = PipelineModel::find_expired(&tx, cutoff_ms).await?;
    PipelineModel::delete_expired(&tx, cutoff_ms).await?;
    let mut per_user: HashMap<i64, i64> = HashMap::new();
    for (user_id, sid) in expired {
        let e = per_user.entry(user_id).or_insert(0);
        *e = std::cmp::max(*e, sid);
    }
    let deleted_users = per_user.len();
    for (user_id, max_sid) in per_user {
        if let Err(err) = pipeline_watermark_update(&tx, user_id, max_sid).await {
            warn!("pipeline watermark update error: user={user_id}, err={err:?}");
        }
    }
    CleanupStateModel::set(&tx, now).await?;
    tx.commit().await?;
    debug!(
        "pipeline cleanup done, deleted_users={deleted_users}, ttl={ttl}s, interval={interval}s"
    );
    Ok(())
}
