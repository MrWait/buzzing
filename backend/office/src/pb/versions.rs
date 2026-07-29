use loco_rs::{Error, Result, app::AppContext};
use prost::Message;
use tracing::instrument;
use yrs::{GetString, ReadTxn, StateVector, Transact, Update, updates::decoder::Decode};

use common::{id_gen, model::UserBrief};
use proto::idl::{error::ErrorCode, office};

use crate::models::document_versions::DocumentVersionModel;
use crate::permission::{require_role, Role};

fn version_to_item(v: crate::models::document_versions::Model) -> office::VersionItem {
    office::VersionItem {
        id: v.id.to_string(),
        document_id: v.document_id.to_string(),
        version_number: v.version_number,
        title: v.title,
        description: v.description.unwrap_or_default(),
        creator_id: v.creator_id.to_string(),
        is_minor: v.is_minor,
        created_at: v.created_at.to_rfc3339(),
    }
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn list(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::VersionListRequest>(&packet.payload)?;
    require_role(ctx, brief.id, req.doc_id, Role::Viewer).await?;
    let limit = if req.limit > 0 { req.limit as u64 } else { 50 };
    let offset = if req.offset > 0 { req.offset as u64 } else { 0 };
    let versions =
        DocumentVersionModel::list_by_document(&ctx.db, req.doc_id, limit, offset).await?;
    let items: Vec<office::VersionItem> = versions.into_iter().map(version_to_item).collect();
    let resp = office::VersionListResponse { items };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn create(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::VersionCreateRequest>(&packet.payload)?;
    require_role(ctx, brief.id, req.doc_id, Role::Editor).await?;

    let (yjs_snapshot, plain_text) = {
        let manager = crate::ws::YJS_MANAGER
            .get()
            .ok_or_else(|| Error::string("yjs manager not ready"))?;
        let state = manager.get_or_create(req.doc_id).await?;
        let txn = state.doc.transact();
        let update = txn.encode_diff_v1(&StateVector::default());
        let plain = txn
            .get_xml_fragment("prosemirror")
            .map(|f| f.get_string(&txn))
            .map(|s| crate::yjs_store::strip_xml_tags(&s))
            .unwrap_or_default();
        (update, plain)
    };

    let description: Option<String> = if req.description.is_empty() {
        None
    } else {
        Some(req.description)
    };

    let version_number =
        DocumentVersionModel::get_max_version_number(&ctx.db, req.doc_id).await? + 1;
    let v = DocumentVersionModel::create(
        &ctx.db,
        id_gen(None),
        req.doc_id,
        version_number,
        req.title,
        description,
        yjs_snapshot,
        Some(plain_text),
        brief.id,
        false,
    )
    .await?;

    let resp = office::VersionCreateResponse {
        item: Some(version_to_item(v)),
    };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn get(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::VersionGetRequest>(&packet.payload)?;
    require_role(ctx, brief.id, req.doc_id, Role::Viewer).await?;
    let v = DocumentVersionModel::get_by_document_and_version(&ctx.db, req.doc_id, req.version_id)
        .await?
        .ok_or(Error::NotFound)?;
    let resp = office::VersionGetResponse {
        item: Some(version_to_item(v)),
    };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn diff(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::VersionDiffRequest>(&packet.payload)?;
    require_role(ctx, brief.id, req.doc_id, Role::Viewer).await?;

    let v1 = DocumentVersionModel::get_by_document_and_version(&ctx.db, req.doc_id, req.v1_id)
        .await?
        .ok_or(Error::NotFound)?;
    let v2 = DocumentVersionModel::get_by_document_and_version(&ctx.db, req.doc_id, req.v2_id)
        .await?
        .ok_or(Error::NotFound)?;

    let text_a = v1.plain_text.as_deref().unwrap_or("");
    let text_b = v2.plain_text.as_deref().unwrap_or("");

    let lines_a: Vec<&str> = text_a.lines().collect();
    let lines_b: Vec<&str> = text_b.lines().collect();

    let mut ops: Vec<office::DiffLine> = Vec::new();
    let mut additions = 0i32;
    let mut deletions = 0i32;

    let max_len = lines_a.len().max(lines_b.len());
    for i in 0..max_len {
        let a = lines_a.get(i).copied().unwrap_or("");
        let b = lines_b.get(i).copied().unwrap_or("");
        if a == b {
            ops.push(office::DiffLine {
                r#type: "equal".into(),
                text: a.into(),
                pos: i as i32,
            });
        } else {
            if !a.is_empty() {
                ops.push(office::DiffLine {
                    r#type: "delete".into(),
                    text: a.into(),
                    pos: i as i32,
                });
                deletions += 1;
            }
            if !b.is_empty() {
                ops.push(office::DiffLine {
                    r#type: "insert".into(),
                    text: b.into(),
                    pos: i as i32,
                });
                additions += 1;
            }
        }
    }

    let resp = office::VersionDiffResponse {
        ops,
        stats: Some(office::DiffStats {
            additions,
            deletions,
        }),
    };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn restore(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::VersionRestoreRequest>(&packet.payload)?;
    require_role(ctx, brief.id, req.doc_id, Role::Editor).await?;

    let v = DocumentVersionModel::get_by_document_and_version(&ctx.db, req.doc_id, req.version_id)
        .await?
        .ok_or(Error::NotFound)?;

    let restored = yrs::Doc::new();
    {
        let mut txn = restored.transact_mut();
        let update =
            Update::decode_v1(&v.yjs_snapshot).map_err(|_| Error::InternalServerError)?;
        txn.apply_update(update);
    }
    let full_update = {
        let txn = restored.transact();
        txn.encode_diff_v1(&StateVector::default())
    };

    let manager = crate::ws::YJS_MANAGER
        .get()
        .ok_or_else(|| Error::string("yjs manager not ready"))?;
    let state = manager.get_or_create(req.doc_id).await?;
    {
        let mut txn = state.doc.transact_mut();
        let update =
            Update::decode_v1(&full_update).map_err(|_| Error::InternalServerError)?;
        txn.apply_update(update);
    }

    let version_number =
        DocumentVersionModel::get_max_version_number(&ctx.db, req.doc_id).await? + 1;
    DocumentVersionModel::create(
        &ctx.db,
        id_gen(None),
        req.doc_id,
        version_number,
        format!("回滚至版本 v{}", v.version_number),
        Some(format!("从版本 v{} 回滚 ({})", v.version_number, v.title)),
        full_update,
        v.plain_text.clone(),
        brief.id,
        false,
    )
    .await?;

    let resp = office::VersionRestoreResponse {
        ok: true,
        new_version: version_number,
    };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}
