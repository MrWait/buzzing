use axum::debug_handler;
use loco_rs::prelude::*;
use serde::{Deserialize, Serialize};
use yrs::{Doc, ReadTxn, StateVector, Transact, Update};
use yrs::updates::decoder::Decode;

use crate::models::documents::DocumentModel;
use crate::models::document_visits::DocumentVisitModel;
use crate::permission::{require_role, Role};
use common::{id_gen, model::UserBrief};

#[derive(Debug, Deserialize)]
pub struct CreateDocParams {
    pub wiki_id: Option<String>,
    pub title: String,
    pub parent_id: Option<String>,
    pub icon: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct CreatePersonalDocParams {
    pub title: String,
    pub parent_id: Option<String>,
    pub icon: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct UpdateDocParams {
    pub title: Option<String>,
    pub icon: Option<String>,
    pub cover: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct MoveDocParams {
    pub parent_id: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct DuplicateParams {
    #[serde(default)]
    pub include_children: bool,
}

#[derive(Debug, Serialize)]
pub struct DocResponse {
    pub id: String,
    pub wiki_id: Option<String>,
    pub parent_id: Option<String>,
    pub title: String,
    pub icon: Option<String>,
    pub cover: Option<String>,
    pub doc_type: i32,
    pub version: i64,
    pub trashed_at: Option<String>,
    pub created_at: String,
    pub updated_at: String,
}

impl DocResponse {
    pub fn from_model(d: crate::models::documents::Model) -> Self {
        Self {
            id: d.id.to_string(),
            wiki_id: d.wiki_id.map(|v| v.to_string()),
            parent_id: d.parent_id.map(|v| v.to_string()),
            title: d.title,
            icon: d.icon,
            cover: d.cover,
            doc_type: d.doc_type,
            version: d.version,
            trashed_at: d.trashed_at.map(|v| v.to_rfc3339()),
            created_at: d.created_at.to_rfc3339(),
            updated_at: d.updated_at.to_rfc3339(),
        }
    }
}

#[derive(Debug, Serialize)]
pub struct EditUrlResponse {
    pub edit_url: String,
    pub title: String,
}

#[debug_handler]
pub async fn list(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Query(params): Query<std::collections::HashMap<String, String>>,
) -> Result<Response> {
    let _claim = UserBrief::from_string(&auth.claims.pid)?;
    if let Some(wiki_id) = params.get("wiki_id").and_then(|s| s.parse::<i64>().ok()) {
        let docs = DocumentModel::get_by_wiki_id(&ctx.db, wiki_id).await?;
        let items: Vec<DocResponse> = docs.into_iter().map(DocResponse::from_model).collect();
        format::json(items)
    } else {
        format::json(Vec::<DocResponse>::new())
    }
}

#[debug_handler]
pub async fn create(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Json(params): Json<CreateDocParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let wiki_id: Option<i64> = params.wiki_id.as_deref().and_then(|s| s.parse().ok());
    let parent_id = params
        .parent_id
        .as_deref()
        .and_then(|s| s.parse::<i64>().ok());
    let doc = DocumentModel::create(
        &ctx.db,
        base::models::_entities::documents::ActiveModel {
            id: ActiveValue::set(id_gen(None)),
            wiki_id: ActiveValue::set(wiki_id),
            tenant_id: ActiveValue::set(claim.tenant_id),
            creator: ActiveValue::set(claim.id),
            title: ActiveValue::set(params.title),
            doc_type: ActiveValue::set(1),
            version: ActiveValue::set(common::time::current_ms() as i64),
            content: ActiveValue::set(vec![]),
            parent_id: ActiveValue::set(parent_id),
            icon: ActiveValue::set(params.icon),
            ..Default::default()
        },
    )
    .await?;
    format::json(DocResponse::from_model(doc))
}

/// 创建个人文档（wiki_id = NULL）
#[debug_handler]
pub async fn create_personal(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Json(params): Json<CreatePersonalDocParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let parent_id = params
        .parent_id
        .as_deref()
        .and_then(|s| s.parse::<i64>().ok());
    let doc = DocumentModel::create(
        &ctx.db,
        base::models::_entities::documents::ActiveModel {
            id: ActiveValue::set(id_gen(None)),
            wiki_id: ActiveValue::set(None),
            tenant_id: ActiveValue::set(claim.tenant_id),
            creator: ActiveValue::set(claim.id),
            title: ActiveValue::set(params.title),
            doc_type: ActiveValue::set(1),
            version: ActiveValue::set(common::time::current_ms() as i64),
            content: ActiveValue::set(vec![]),
            parent_id: ActiveValue::set(parent_id),
            icon: ActiveValue::set(params.icon),
            ..Default::default()
        },
    )
    .await?;
    format::json(DocResponse::from_model(doc))
}

#[debug_handler]
pub async fn get(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, id, Role::Viewer).await?;
    let doc = DocumentModel::get_by_id(&ctx.db, id)
        .await?
        .ok_or(Error::NotFound)?;
    format::json(DocResponse::from_model(doc))
}

#[debug_handler]
pub async fn permission(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let role = crate::permission::resolve_role(&ctx, claim.id, id).await?;
    match role {
        Some(r) => format::json(serde_json::json!({
            "role": r as i32,
            "role_label": r.label(),
        })),
        None => Err(Error::Unauthorized("no access to doc".into())),
    }
}

#[debug_handler]
pub async fn update(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
    Json(params): Json<UpdateDocParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, id, Role::Editor).await?;

    if let Some(title) = params.title {
        let now = common::time::current_ms() as i64;
        DocumentModel::update_title(&ctx.db, id, title, now).await?;
    }
    if params.icon.is_some() || params.cover.is_some() {
        DocumentModel::update_meta(
            &ctx.db,
            id,
            params.icon.map(Some),
            params.cover.map(Some),
        )
        .await?;
    }

    let doc = DocumentModel::get_by_id(&ctx.db, id)
        .await?
        .ok_or(Error::NotFound)?;
    format::json(DocResponse::from_model(doc))
}

#[debug_handler]
pub async fn delete(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, id, Role::Owner).await?;
    // 检查是否为 wiki 首页文档，禁止单独删除
    check_not_home_doc(&ctx, id).await?;
    DocumentModel::trash(&ctx.db, id).await?;
    format::json(serde_json::json!({"ok": true}))
}

#[debug_handler]
pub async fn edit_url(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let _claim = UserBrief::from_string(&auth.claims.pid)?;
    let doc = DocumentModel::get_by_id(&ctx.db, id)
        .await?
        .ok_or(Error::NotFound)?;
    let edit_url = format!("/office/editor/{}", id);
    format::json(EditUrlResponse {
        edit_url,
        title: doc.title,
    })
}

/// 移动文档到新父级
#[debug_handler]
pub async fn move_doc(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
    Json(params): Json<MoveDocParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, id, Role::Editor).await?;
    let parent = match params.parent_id.as_deref() {
        None | Some("") | Some("0") => Some(None),
        Some(s) => Some(s.parse::<i64>().ok()),
    };
    let doc = DocumentModel::move_to(&ctx.db, id, parent).await?;
    format::json(DocResponse::from_model(doc))
}

#[debug_handler]
pub async fn duplicate(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
    Json(params): Json<DuplicateParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, id, Role::Viewer).await?;
    let new_root = duplicate_recursive(&ctx.db, id, None, params.include_children, &claim).await?;
    format::json(DocResponse::from_model(new_root))
}

fn duplicate_recursive<'a>(
    db: &'a DatabaseConnection,
    src_id: i64,
    new_parent: Option<i64>,
    include_children: bool,
    claim: &'a UserBrief,
) -> std::pin::Pin<Box<dyn std::future::Future<Output = Result<crate::models::documents::Model>> + Send + 'a>>
{
    Box::pin(async move {
        let src = DocumentModel::get_by_id(db, src_id)
            .await?
            .ok_or(Error::NotFound)?;
        let content: Vec<u8> = if src.content.is_empty() {
            vec![]
        } else {
            let doc = Doc::new();
            if let Ok(update) = Update::decode_v1(&src.content) {
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

#[debug_handler]
pub async fn visit(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    DocumentVisitModel::upsert(&ctx.db, id_gen(None), claim.id, id).await?;
    format::json(serde_json::json!({"ok": true}))
}

#[debug_handler]
pub async fn recent(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Query(params): Query<std::collections::HashMap<String, String>>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let limit: u64 = params
        .get("limit")
        .and_then(|s| s.parse().ok())
        .unwrap_or(20);
    let visits = DocumentVisitModel::list_recent(&ctx.db, claim.id, limit).await?;
    let mut items: Vec<serde_json::Value> = Vec::with_capacity(visits.len());
    for v in visits {
        if let Some(doc) = DocumentModel::get_by_id(&ctx.db, v.document_id).await? {
            if doc.trashed_at.is_some() {
                continue;
            }
            items.push(serde_json::json!({
                "doc": DocResponse::from_model(doc),
                "visited_at": v.visited_at,
            }));
        }
    }
    format::json(items)
}

/// 我创建的文档
#[debug_handler]
pub async fn my_docs(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let docs = DocumentModel::get_by_creator(&ctx.db, claim.id, claim.tenant_id).await?;
    let items: Vec<DocResponse> = docs.into_iter().map(DocResponse::from_model).collect();
    format::json(items)
}

/// 与我共享的文档（用户有权限但不是创建者）
#[debug_handler]
pub async fn shared_docs(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let docs = DocumentModel::get_shared_with_user(&ctx.db, claim.id, claim.tenant_id).await?;
    let items: Vec<DocResponse> = docs.into_iter().map(DocResponse::from_model).collect();
    format::json(items)
}

/// 知识库下的树形结构（通过 wiki_id 查询，不再需要 space_id）
#[debug_handler]
pub async fn tree(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Query(params): Query<std::collections::HashMap<String, String>>,
) -> Result<Response> {
    let _claim = UserBrief::from_string(&auth.claims.pid)?;
    let wiki_id: i64 = params
        .get("wiki_id")
        .and_then(|s| s.parse().ok())
        .ok_or_else(|| Error::BadRequest("wiki_id required".into()))?;
    let all = DocumentModel::get_wiki_tree_flat(&ctx.db, wiki_id).await?;
    let tree = build_tree(all);
    format::json(tree)
}

#[derive(Serialize)]
struct TreeNode {
    id: String,
    parent_id: Option<String>,
    title: String,
    icon: Option<String>,
    children: Vec<TreeNode>,
}

fn build_tree(docs: Vec<crate::models::documents::Model>) -> Vec<TreeNode> {
    use std::collections::HashMap;

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
                Some(_) => roots.push(n),
                None => roots.push(n),
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

    fn to_pub(n: Tmp) -> TreeNode {
        TreeNode {
            id: n.id.to_string(),
            parent_id: n.parent_id.map(|v| v.to_string()),
            title: n.title,
            icon: n.icon,
            children: n.children.into_iter().map(to_pub).collect(),
        }
    }
    roots.into_iter().map(to_pub).collect()
}

#[debug_handler]
pub async fn preview(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    crate::permission::require_role(&ctx, claim.id, id, crate::permission::Role::Viewer).await?;
    let doc = DocumentModel::get_by_id(&ctx.db, id)
        .await?
        .ok_or(Error::NotFound)?;
    use sea_orm::{DbBackend, FromQueryResult, Statement};
    #[derive(FromQueryResult, Serialize)]
    struct CreatorRow {
        id: i64,
        name: String,
        avatar: Option<String>,
    }
    let creator = CreatorRow::find_by_statement(Statement::from_sql_and_values(
        DbBackend::Postgres,
        "SELECT id, name, avatar FROM \"users\" WHERE id = $1",
        vec![doc.creator.into()],
    ))
    .one(&ctx.db)
    .await?;
    let excerpt = doc.plain_text.as_deref().unwrap_or("").chars().take(200).collect::<String>();
    format::json(serde_json::json!({
        "id": doc.id.to_string(),
        "title": doc.title,
        "icon": doc.icon,
        "excerpt": excerpt,
        "updated_at": doc.updated_at.to_rfc3339(),
        "creator": creator,
    }))
}

/// 个人文档树（wiki_id IS NULL）
#[debug_handler]
pub async fn personal_tree(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let all = DocumentModel::get_personal_tree(&ctx.db, claim.id, claim.tenant_id).await?;
    let tree = build_tree(all);
    format::json(tree)
}

/// 检查文档是否为 wiki 首页文档（禁止删除/回收/永久删除）
pub async fn check_not_home_doc(ctx: &AppContext, doc_id: i64) -> Result<()> {
    use sea_orm::PaginatorTrait;
    use base::models::_entities::wikis::{Column as WCol, Entity as WEnt};
    let count = WEnt::find()
        .filter(WCol::HomeDocId.eq(doc_id))
        .count(&ctx.db)
        .await
        .map_err(|_| Error::NotFound)?;
    if count > 0 {
        return Err(Error::BadRequest("cannot delete wiki home page".into()));
    }
    Ok(())
}
