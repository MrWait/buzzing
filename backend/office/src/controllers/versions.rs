use axum::debug_handler;
use loco_rs::prelude::*;
use serde::{Deserialize, Serialize};
use yrs::updates::decoder::Decode;
use yrs::{GetString, ReadTxn, StateVector, Transact, Update};

use crate::models::document_versions::DocumentVersionModel;
use crate::permission::{require_role, Role};
use common::{id_gen, model::UserBrief};

#[derive(Debug, Serialize)]
pub struct VersionResponse {
    pub id: String,
    pub document_id: String,
    pub version_number: i32,
    pub title: String,
    pub description: Option<String>,
    pub creator_id: String,
    pub is_minor: bool,
    pub created_at: String,
}

impl VersionResponse {
    pub fn from_model(m: crate::models::document_versions::Model) -> Self {
        Self {
            id: m.id.to_string(),
            document_id: m.document_id.to_string(),
            version_number: m.version_number,
            title: m.title,
            description: m.description,
            creator_id: m.creator_id.to_string(),
            is_minor: m.is_minor,
            created_at: m.created_at.to_rfc3339(),
        }
    }
}

#[derive(Debug, Deserialize)]
pub struct CreateVersionParams {
    pub title: String,
    pub description: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct DiffParams {
    pub v1_id: String,
    pub v2_id: String,
}

#[derive(Debug, Serialize)]
pub struct DiffLine {
    #[serde(rename = "type")]
    pub diff_type: String,
    pub text: String,
    pub pos: usize,
}

#[derive(Debug, Serialize)]
pub struct DiffStats {
    pub additions: usize,
    pub deletions: usize,
}

#[derive(Debug, Serialize)]
pub struct DiffResponse {
    pub ops: Vec<DiffLine>,
    pub stats: DiffStats,
}

#[debug_handler]
pub async fn list(
    auth: auth::JWT,
    Path(doc_id): Path<i64>,
    State(ctx): State<AppContext>,
    Query(params): Query<std::collections::HashMap<String, String>>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, doc_id, Role::Viewer).await?;
    let limit: u64 = params.get("limit").and_then(|s| s.parse().ok()).unwrap_or(50);
    let offset: u64 = params.get("offset").and_then(|s| s.parse().ok()).unwrap_or(0);
    let versions = DocumentVersionModel::list_by_document(&ctx.db, doc_id, limit, offset).await?;
    let items: Vec<VersionResponse> = versions.into_iter().map(VersionResponse::from_model).collect();
    format::json(items)
}

#[debug_handler]
pub async fn create(
    auth: auth::JWT,
    Path(doc_id): Path<i64>,
    State(ctx): State<AppContext>,
    Json(params): Json<CreateVersionParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, doc_id, Role::Editor).await?;

    let (yjs_snapshot, plain_text) = {
        let manager = crate::ws::YJS_MANAGER
            .get()
            .ok_or_else(|| Error::InternalServerError)?;
        let state = manager.get_or_create(doc_id).await?;
        let txn = state.doc.transact();
        let update = txn.encode_diff_v1(&yrs::StateVector::default());
        let plain = txn
            .get_xml_fragment("prosemirror")
            .map(|f| f.get_string(&txn))
            .map(|s| crate::yjs_store::strip_xml_tags(&s))
            .unwrap_or_default();
        (update, plain)
    };

    let version_number = DocumentVersionModel::get_max_version_number(&ctx.db, doc_id).await? + 1;
    let v = DocumentVersionModel::create(
        &ctx.db,
        id_gen(None),
        doc_id,
        version_number,
        params.title,
        params.description,
        yjs_snapshot,
        Some(plain_text),
        claim.id,
        false,
    )
    .await?;
    format::json(VersionResponse::from_model(v))
}

#[debug_handler]
pub async fn get(
    auth: auth::JWT,
    Path((doc_id, version_id)): Path<(i64, i64)>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, doc_id, Role::Viewer).await?;
    let v = DocumentVersionModel::get_by_document_and_version(&ctx.db, doc_id, version_id)
        .await?
        .ok_or(Error::NotFound)?;
    format::json(VersionResponse::from_model(v))
}

#[debug_handler]
pub async fn diff(
    auth: auth::JWT,
    Path(doc_id): Path<i64>,
    State(ctx): State<AppContext>,
    Json(params): Json<DiffParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, doc_id, Role::Viewer).await?;

    let v1_id: i64 = params.v1_id.parse().map_err(|_| Error::BadRequest("invalid v1_id".into()))?;
    let v2_id: i64 = params.v2_id.parse().map_err(|_| Error::BadRequest("invalid v2_id".into()))?;

    let v1 = DocumentVersionModel::get_by_document_and_version(&ctx.db, doc_id, v1_id)
        .await?
        .ok_or(Error::NotFound)?;
    let v2 = DocumentVersionModel::get_by_document_and_version(&ctx.db, doc_id, v2_id)
        .await?
        .ok_or(Error::NotFound)?;

    let diff = compute_diff(
        v1.plain_text.as_deref().unwrap_or(""),
        v2.plain_text.as_deref().unwrap_or(""),
    );
    format::json(diff)
}

#[debug_handler]
pub async fn restore(
    auth: auth::JWT,
    Path((doc_id, version_id)): Path<(i64, i64)>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, doc_id, Role::Editor).await?;

    let v = DocumentVersionModel::get_by_document_and_version(&ctx.db, doc_id, version_id)
        .await?
        .ok_or(Error::NotFound)?;

    // 创建临时 doc 并应用版本快照，获取完整状态
    let restored = yrs::Doc::new();
    {
        let mut txn = restored.transact_mut();
        let update = yrs::Update::decode_v1(&v.yjs_snapshot)
            .map_err(|_| Error::InternalServerError)?;
        txn.apply_update(update);
    }
    let full_update = {
        let txn = restored.transact();
        txn.encode_diff_v1(&yrs::StateVector::default())
    };

    // 将恢复的状态应用到当前在线 doc
    let manager = crate::ws::YJS_MANAGER
        .get()
        .ok_or_else(|| Error::InternalServerError)?;
    let state = manager.get_or_create(doc_id).await?;
    {
        let mut txn = state.doc.transact_mut();
        let update = yrs::Update::decode_v1(&full_update)
            .map_err(|_| Error::InternalServerError)?;
        txn.apply_update(update);
    }

    // 创建回滚记录（追加新版本）
    let version_number = DocumentVersionModel::get_max_version_number(&ctx.db, doc_id).await? + 1;
    DocumentVersionModel::create(
        &ctx.db,
        id_gen(None),
        doc_id,
        version_number,
        format!("回滚至版本 v{}", v.version_number),
        Some(format!("从版本 v{} 回滚 ({})", v.version_number, v.title)),
        full_update,
        v.plain_text.clone(),
        claim.id,
        false,
    )
    .await?;

    format::json(serde_json::json!({"ok": true, "new_version": version_number}))
}

/// 基于 plain_text 的逐行 diff
fn compute_diff(text_a: &str, text_b: &str) -> DiffResponse {
    let lines_a: Vec<&str> = text_a.lines().collect();
    let lines_b: Vec<&str> = text_b.lines().collect();

    let mut ops = Vec::new();
    let mut stats = DiffStats { additions: 0, deletions: 0 };

    let max_len = lines_a.len().max(lines_b.len());
    for i in 0..max_len {
        let a = lines_a.get(i).copied().unwrap_or("");
        let b = lines_b.get(i).copied().unwrap_or("");
        if a == b {
            ops.push(DiffLine { diff_type: "equal".into(), text: a.into(), pos: i });
        } else {
            if !a.is_empty() {
                ops.push(DiffLine { diff_type: "delete".into(), text: a.into(), pos: i });
                stats.deletions += 1;
            }
            if !b.is_empty() {
                ops.push(DiffLine { diff_type: "insert".into(), text: b.into(), pos: i });
                stats.additions += 1;
            }
        }
    }

    DiffResponse { ops, stats }
}
