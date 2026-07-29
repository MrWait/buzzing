use std::collections::HashMap;

use loco_rs::{Error, Result, app::AppContext};
use prost::Message;
use sea_orm::{ActiveValue, DbBackend, FromQueryResult, Statement};
use tracing::instrument;
use yrs::{ReadTxn, StateVector, Transact, updates::decoder::Decode};

use common::{id_gen, model::UserBrief};
use proto::idl::{error::ErrorCode, office};

use crate::controllers::docs::check_not_home_doc;
use crate::models::document_stars::DocumentStarModel;
use crate::models::document_visits::DocumentVisitModel;
use crate::models::documents::DocumentModel;
use crate::permission::{require_role, resolve_role, Role};

const TRASH_RETENTION_DAYS: i64 = 30;

fn model_to_walk_item(d: &base::models::_entities::documents::Model) -> office::WalkItem {
    office::WalkItem {
        id: d.id.to_string(),
        title: d.title.clone(),
        icon: d.icon.clone().unwrap_or_default(),
    }
}

fn model_to_tree_node(
    d: &base::models::_entities::documents::Model,
    children: Vec<office::DocTreeNode>,
) -> office::DocTreeNode {
    office::DocTreeNode {
        id: d.id.to_string(),
        parent_id: d.parent_id.map(|v| v.to_string()).unwrap_or_default(),
        title: d.title.clone(),
        icon: d.icon.clone().unwrap_or_default(),
        children,
    }
}

fn model_to_get_resp(
    d: base::models::_entities::documents::Model,
    walk: Vec<office::WalkItem>,
    role: i32,
    role_label: String,
) -> office::GetDocResponse {
    office::GetDocResponse {
        id: d.id,
        wiki_id: d.wiki_id.map(|v| v.to_string()).unwrap_or_default(),
        parent_id: d.parent_id.map(|v| v.to_string()).unwrap_or_default(),
        title: d.title,
        icon: d.icon.unwrap_or_default(),
        cover: d.cover.unwrap_or_default(),
        doc_type: d.doc_type,
        version: d.version,
        trashed_at: d.trashed_at.map(|v| v.to_rfc3339()).unwrap_or_default(),
        created_at: d.created_at.to_rfc3339(),
        updated_at: d.updated_at.to_rfc3339(),
        role,
        role_label,
        walk,
    }
}

pub(crate) fn model_to_get_resp_simple(d: base::models::_entities::documents::Model) -> office::GetDocResponse {
    model_to_get_resp(d, vec![], 0, String::new())
}

fn build_tree_proto(docs: Vec<base::models::_entities::documents::Model>) -> Vec<office::DocTreeNode> {
    struct Tmp {
        id: i64,
        parent_id: Option<i64>,
        title: String,
        icon: Option<String>,
        children: Vec<Tmp>,
    }

    let mut nodes: HashMap<i64, Tmp> = HashMap::with_capacity(docs.len());
    let mut order: Vec<i64> = Vec::with_capacity(docs.len());
    for d in docs {
        order.push(d.id);
        nodes.insert(
            d.id,
            Tmp {
                id: d.id,
                parent_id: d.parent_id,
                title: d.title,
                icon: d.icon,
                children: Vec::new(),
            },
        );
    }

    let mut roots: Vec<Tmp> = Vec::new();
    let mut children_map: HashMap<i64, Vec<Tmp>> = HashMap::new();
    for id in order {
        if let Some(n) = nodes.remove(&id) {
            match n.parent_id {
                Some(pid) if nodes.contains_key(&pid) || children_map.contains_key(&pid) => {
                    children_map.entry(pid).or_default().push(n);
                }
                _ => roots.push(n),
            }
        }
    }

    fn attach(node: &mut Tmp, children_map: &mut HashMap<i64, Vec<Tmp>>) {
        if let Some(mut children) = children_map.remove(&node.id) {
            for c in &mut children {
                attach(c, children_map);
            }
            node.children = children;
        }
    }
    for r in &mut roots {
        attach(r, &mut children_map);
    }
    let mut orphans: Vec<Tmp> = children_map.into_values().flatten().collect();
    roots.append(&mut orphans);

    fn to_pb(n: Tmp) -> office::DocTreeNode {
        office::DocTreeNode {
            id: n.id.to_string(),
            parent_id: n.parent_id.map(|v| v.to_string()).unwrap_or_default(),
            title: n.title,
            icon: n.icon.unwrap_or_default(),
            children: n.children.into_iter().map(to_pb).collect(),
        }
    }
    roots.into_iter().map(to_pb).collect()
}

// ---- existing handlers ----

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn create(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::CreateDocRequest>(&packet.payload)?;

    let wiki_id: Option<i64> = if req.wiki_id.is_empty() {
        None
    } else {
        Some(req.wiki_id.parse().map_err(|_| Error::string("invalid wiki_id"))?)
    };

    let parent_id: Option<i64> = if req.parent_id.is_empty() {
        None
    } else {
        Some(req.parent_id.parse().map_err(|_| Error::string("invalid parent_id"))?)
    };

    let icon: Option<String> = if req.icon.is_empty() { None } else { Some(req.icon) };

    let m = DocumentModel::create(
        &ctx.db,
        base::models::_entities::documents::ActiveModel {
            id: ActiveValue::set(id_gen(None)),
            wiki_id: ActiveValue::set(wiki_id),
            tenant_id: ActiveValue::set(brief.tenant_id),
            creator: ActiveValue::set(brief.id),
            title: ActiveValue::set(req.title),
            doc_type: ActiveValue::set(1),
            version: ActiveValue::set(common::time::current_ms() as i64),
            content: ActiveValue::set(vec![]),
            parent_id: ActiveValue::set(parent_id),
            icon: ActiveValue::set(icon),
            ..Default::default()
        },
    )
    .await?;

    let mut resp = office::CreateDocResponse::default();
    resp.id = m.id;
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn get(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::GetDocRequest>(&packet.payload)?;
    let doc_id = req.doc_id;

    let doc = DocumentModel::get_by_id(&ctx.db, doc_id)
        .await?
        .ok_or(Error::NotFound)?;
    let walk = DocumentModel::get_doc_path(&ctx.db, doc_id, brief.id).await?;
    let role = resolve_role(ctx, brief.id, doc_id)
        .await?
        .unwrap_or(Role::Viewer);
    let _ = DocumentVisitModel::upsert(&ctx.db, id_gen(None), brief.id, doc_id).await;

    // convert controller WalkItem -> proto WalkItem
    let walk_pb: Vec<office::WalkItem> = walk
        .into_iter()
        .map(|w| office::WalkItem {
            id: w.id,
            title: w.title,
            icon: w.icon.unwrap_or_default(),
        })
        .collect();

    let resp = model_to_get_resp(doc, walk_pb, role as i32, role.label().to_string());
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, _brief, packet))]
pub(crate) async fn update(
    ctx: &AppContext,
    _brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::UpdateDocRequest>(&packet.payload)?;
    let now = common::time::current_ms() as i64;

    if !req.title.is_empty() {
        DocumentModel::update_title(&ctx.db, req.doc_id, req.title, now).await?;
    }
    if !req.icon.is_empty() || !req.cover.is_empty() {
        let icon = if req.icon.is_empty() { None } else { Some(Some(req.icon)) };
        let cover = if req.cover.is_empty() { None } else { Some(Some(req.cover)) };
        DocumentModel::update_meta(&ctx.db, req.doc_id, icon, cover).await?;
    }

    let resp = office::UpdateDocResponse { ok: true };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, _brief, packet))]
pub(crate) async fn delete(
    ctx: &AppContext,
    _brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::DeleteDocRequest>(&packet.payload)?;
    DocumentModel::trash(&ctx.db, req.doc_id).await?;
    let resp = office::DeleteDocResponse { ok: true };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, _packet))]
pub(crate) async fn personal_tree(
    ctx: &AppContext,
    brief: &UserBrief,
    _packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let all = DocumentModel::get_personal_tree(&ctx.db, brief.id, brief.tenant_id).await?;

    let tree = build_tree_proto(all);

    let mut resp = office::PersonalTreeResponse::default();
    resp.items = tree;
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

// ---- new handlers ----

#[instrument(skip(ctx, _brief, packet))]
pub(crate) async fn list(
    ctx: &AppContext,
    _brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::ListDocsRequest>(&packet.payload)?;
    let wiki_id: i64 = req.wiki_id.parse().map_err(|_| Error::string("invalid wiki_id"))?;
    let docs = DocumentModel::get_by_wiki_id(&ctx.db, wiki_id).await?;
    let items: Vec<office::GetDocResponse> = docs.into_iter().map(model_to_get_resp_simple).collect();
    let resp = office::ListDocsResponse { items };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, _brief, packet))]
pub(crate) async fn tree(
    ctx: &AppContext,
    _brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::TreeDocsRequest>(&packet.payload)?;
    let wiki_id: i64 = req.wiki_id.parse().map_err(|_| Error::string("invalid wiki_id"))?;
    let all = DocumentModel::get_wiki_tree_flat(&ctx.db, wiki_id).await?;
    let items = build_tree_proto(all);
    let resp = office::TreeDocsResponse { items };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn recent(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::RecentDocsRequest>(&packet.payload)?;
    let limit = if req.limit > 0 { req.limit as u64 } else { 20 };
    let visits = DocumentVisitModel::list_recent(&ctx.db, brief.id, limit).await?;
    let mut items: Vec<office::RecentItem> = Vec::with_capacity(visits.len());
    for v in visits {
        if let Some(doc) = DocumentModel::get_by_id(&ctx.db, v.document_id).await? {
            if doc.trashed_at.is_some() {
                continue;
            }
            items.push(office::RecentItem {
                doc: Some(model_to_get_resp_simple(doc)),
                visited_at: v.visited_at,
            });
        }
    }
    let resp = office::RecentDocsResponse { items };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, _packet))]
pub(crate) async fn trash_list(
    ctx: &AppContext,
    brief: &UserBrief,
    _packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let docs = DocumentModel::list_trashed(&ctx.db, brief.tenant_id, brief.id).await?;
    let now = chrono::Utc::now();
    let items: Vec<office::TrashItem> = docs
        .into_iter()
        .map(|d| {
            let trashed_at = d.trashed_at.map(|v| v.with_timezone(&chrono::Utc));
            let remaining = trashed_at
                .map(|t| {
                    let expires = t + chrono::Duration::days(TRASH_RETENTION_DAYS);
                    let delta = expires - now;
                    delta.num_days().max(0)
                })
                .unwrap_or(0);
            office::TrashItem {
                doc: Some(model_to_get_resp_simple(d)),
                remaining_days: remaining as i32,
            }
        })
        .collect();
    let resp = office::TrashListResponse { items };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, _packet))]
pub(crate) async fn starred(
    ctx: &AppContext,
    brief: &UserBrief,
    _packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let stars = DocumentStarModel::list_by_user(&ctx.db, brief.id).await?;
    let mut items: Vec<office::StarItem> = Vec::with_capacity(stars.len());
    for s in stars {
        if let Some(doc) = DocumentModel::get_by_id(&ctx.db, s.document_id).await? {
            if doc.trashed_at.is_some() {
                continue;
            }
            items.push(office::StarItem {
                doc: Some(model_to_get_resp_simple(doc)),
                group_name: s.group_name.unwrap_or_default(),
            });
        }
    }
    let resp = office::StarredDocsResponse { items };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn star(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::StarDocRequest>(&packet.payload)?;
    let group_name: Option<String> = if req.group_name.is_empty() { None } else { Some(req.group_name) };
    let existing = DocumentStarModel::get(&ctx.db, brief.id, req.doc_id).await?;
    if existing.is_none() {
        DocumentStarModel::create(&ctx.db, id_gen(None), brief.id, req.doc_id, group_name).await?;
    }
    let resp = office::StarDocResponse { ok: true };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn unstar(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::UnstarDocRequest>(&packet.payload)?;
    DocumentStarModel::remove(&ctx.db, brief.id, req.doc_id).await?;
    let resp = office::UnstarDocResponse { ok: true };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn restore(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::RestoreDocRequest>(&packet.payload)?;
    require_role(ctx, brief.id, req.doc_id, Role::Owner).await?;
    DocumentModel::restore(&ctx.db, req.doc_id).await?;
    let resp = office::RestoreDocResponse { ok: true };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn purge(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::PurgeDocRequest>(&packet.payload)?;
    require_role(ctx, brief.id, req.doc_id, Role::Owner).await?;
    check_not_home_doc(ctx, req.doc_id).await?;
    DocumentModel::purge(&ctx.db, req.doc_id).await?;
    let resp = office::PurgeDocResponse { ok: true };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn r#move(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::MoveDocRequest>(&packet.payload)?;
    require_role(ctx, brief.id, req.doc_id, Role::Editor).await?;
    let parent = if req.parent_id.is_empty() || req.parent_id == "0" {
        Some(None)
    } else {
        Some(Some(req.parent_id.parse().map_err(|_| Error::string("invalid parent_id"))?))
    };
    DocumentModel::move_to(&ctx.db, req.doc_id, parent).await?;
    let resp = office::MoveDocResponse { ok: true };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn duplicate(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::DuplicateDocRequest>(&packet.payload)?;
    require_role(ctx, brief.id, req.doc_id, Role::Viewer).await?;
    let new_root = duplicate_recursive(&ctx.db, req.doc_id, None, req.include_children, brief).await?;
    let mut resp = office::DuplicateDocResponse::default();
    resp.id = new_root.id;
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

fn duplicate_recursive<'a>(
    db: &'a sea_orm::DatabaseConnection,
    src_id: i64,
    new_parent: Option<i64>,
    include_children: bool,
    claim: &'a UserBrief,
) -> std::pin::Pin<Box<dyn std::future::Future<Output = Result<base::models::_entities::documents::Model>> + Send + 'a>> {
    Box::pin(async move {
        let src = DocumentModel::get_by_id(db, src_id)
            .await?
            .ok_or(Error::NotFound)?;
        let content: Vec<u8> = if src.content.is_empty() {
            vec![]
        } else {
            let doc = yrs::Doc::new();
            if let Ok(update) = yrs::Update::decode_v1(&src.content) {
                doc.transact_mut().apply_update(update);
            }
            doc.transact().encode_state_as_update_v1(&StateVector::default())
        };
        let new_id = id_gen(None);
        let created = DocumentModel::create(
            db,
            base::models::_entities::documents::ActiveModel {
                id: ActiveValue::set(new_id),
                wiki_id: ActiveValue::set(src.wiki_id),
                tenant_id: ActiveValue::set(claim.tenant_id),
                creator: ActiveValue::set(claim.id),
                title: ActiveValue::set(format!("{} (副本)", src.title)),
                doc_type: ActiveValue::set(src.doc_type),
                version: ActiveValue::set(common::time::current_ms() as i64),
                content: ActiveValue::set(content),
                parent_id: ActiveValue::set(new_parent),
                icon: ActiveValue::set(src.icon.clone()),
                cover: ActiveValue::set(src.cover.clone()),
                plain_text: ActiveValue::set(src.plain_text.clone()),
                ..Default::default()
            },
        )
        .await?;
        if include_children {
            let children = DocumentModel::get_children(db, src_id).await?;
            for c in children {
                duplicate_recursive(db, c.id, Some(new_id), true, claim).await?;
            }
        }
        Ok(created)
    })
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn visit(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::VisitDocRequest>(&packet.payload)?;
    DocumentVisitModel::upsert(&ctx.db, id_gen(None), brief.id, req.doc_id).await?;
    let resp = office::VisitDocResponse { ok: true };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, _packet))]
pub(crate) async fn my_docs(
    ctx: &AppContext,
    brief: &UserBrief,
    _packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let docs = DocumentModel::get_by_creator(&ctx.db, brief.id, brief.tenant_id).await?;
    let items: Vec<office::GetDocResponse> = docs.into_iter().map(model_to_get_resp_simple).collect();
    let resp = office::MyDocsResponse { items };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, _packet))]
pub(crate) async fn shared_docs(
    ctx: &AppContext,
    brief: &UserBrief,
    _packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let docs = DocumentModel::get_shared_with_user(&ctx.db, brief.id, brief.tenant_id).await?;
    let items: Vec<office::GetDocResponse> = docs.into_iter().map(model_to_get_resp_simple).collect();
    let resp = office::SharedDocsResponse { items };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[derive(Debug, FromQueryResult)]
struct SearchRow {
    id: i64,
    wiki_id: Option<i64>,
    title: String,
    icon: Option<String>,
    highlight: String,
    matched_title: bool,
    updated_at: chrono::DateTime<chrono::FixedOffset>,
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn search(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::SearchDocsRequest>(&packet.payload)?;
    let query = req.q.trim().to_string();
    if query.is_empty() {
        let resp = office::SearchDocsResponse { items: vec![] };
        return Ok((ErrorCode::Success as i32, resp.encode_to_vec()));
    }
    let limit = if req.limit > 0 { req.limit.min(100) } else { 20 };
    let wiki_filter = if req.wiki_id.is_empty() { None } else { req.wiki_id.parse::<i64>().ok() };

    let sql = if wiki_filter.is_some() {
        r#"
        SELECT id, wiki_id, title, icon,
            ts_headline('simple', COALESCE(plain_text, ''), plainto_tsquery('simple', $1), 'MaxWords=20, MinWords=5, HighlightAll=false, StartSel=<em>, StopSel=</em>') AS highlight,
            (to_tsvector('simple', title) @@ plainto_tsquery('simple', $1)) AS matched_title,
            updated_at
        FROM documents
        WHERE tenant_id = $2 AND trashed_at IS NULL AND wiki_id = $3
          AND search_tsv @@ plainto_tsquery('simple', $1)
        ORDER BY ts_rank(search_tsv, plainto_tsquery('simple', $1)) DESC, updated_at DESC
        LIMIT $4
        "#
    } else {
        r#"
        SELECT id, wiki_id, title, icon,
            ts_headline('simple', COALESCE(plain_text, ''), plainto_tsquery('simple', $1), 'MaxWords=20, MinWords=5, HighlightAll=false, StartSel=<em>, StopSel=</em>') AS highlight,
            (to_tsvector('simple', title) @@ plainto_tsquery('simple', $1)) AS matched_title,
            updated_at
        FROM documents
        WHERE tenant_id = $2 AND trashed_at IS NULL
          AND search_tsv @@ plainto_tsquery('simple', $1)
        ORDER BY ts_rank(search_tsv, plainto_tsquery('simple', $1)) DESC, updated_at DESC
        LIMIT $3
        "#
    };

    let values: Vec<sea_orm::Value> = if let Some(wi) = wiki_filter {
        vec![query.into(), brief.tenant_id.into(), wi.into(), (limit as i64).into()]
    } else {
        vec![query.into(), brief.tenant_id.into(), (limit as i64).into()]
    };

    let stmt = Statement::from_sql_and_values(DbBackend::Postgres, sql, values);
    let rows = SearchRow::find_by_statement(stmt).all(&ctx.db).await?;

    let items: Vec<office::SearchResult> = rows
        .into_iter()
        .map(|r| office::SearchResult {
            id: r.id.to_string(),
            title: r.title,
            icon: r.icon.unwrap_or_default(),
            highlight: r.highlight,
            matched_in: if r.matched_title { "title".to_string() } else { "content".to_string() },
            updated_at: r.updated_at.to_rfc3339(),
        })
        .collect();

    let resp = office::SearchDocsResponse { items };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn permission(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::PermissionRequest>(&packet.payload)?;
    let role = resolve_role(ctx, brief.id, req.doc_id).await?;
    match role {
        Some(r) => {
            let resp = office::PermissionResponse {
                role: r as i32,
                role_label: r.label().to_string(),
            };
            Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
        }
        None => Err(Error::Unauthorized("no access to doc".into())),
    }
}

#[instrument(skip(ctx, _brief, packet))]
pub(crate) async fn edit_url(
    ctx: &AppContext,
    _brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::EditUrlRequest>(&packet.payload)?;
    let doc = DocumentModel::get_by_id(&ctx.db, req.doc_id)
        .await?
        .ok_or(Error::NotFound)?;
    let edit_url = format!("/office/editor/{}", req.doc_id);
    let resp = office::EditUrlResponse {
        edit_url,
        title: doc.title,
    };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}
