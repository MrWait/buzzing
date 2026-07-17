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
    pub space_id: String,
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
    pub space_id: Option<String>,
    /// null 表示移到空间根级
    pub parent_id: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct DuplicateParams {
    /// 是否递归复制子页面（默认 false）
    #[serde(default)]
    pub include_children: bool,
}

#[derive(Debug, Serialize)]
pub struct DocResponse {
    pub id: String,
    pub space_id: String,
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
            space_id: d.space_id.to_string(),
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
    let space_id = params.get("space_id").and_then(|s| s.parse().ok()).unwrap_or(0);
    let docs = DocumentModel::get_by_space_id(&ctx.db, space_id).await?;
    let items: Vec<DocResponse> = docs.into_iter().map(DocResponse::from_model).collect();
    format::json(items)
}

#[debug_handler]
pub async fn create(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Json(params): Json<CreateDocParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let space_id: i64 = params.space_id.parse().map_err(|_| Error::InternalServerError)?;
    let parent_id = params
        .parent_id
        .as_deref()
        .and_then(|s| s.parse::<i64>().ok());
    let doc = DocumentModel::create(
        &ctx.db,
        base::models::_entities::documents::ActiveModel {
            id: ActiveValue::set(id_gen(None)),
            space_id: ActiveValue::set(space_id),
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

/// 查询当前用户对文档的权限
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
            "role": r.as_i32(),
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

/// 软删除（进入回收站）
#[debug_handler]
pub async fn delete(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, id, Role::Owner).await?;
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

/// 移动文档到新空间或改父级
#[debug_handler]
pub async fn move_doc(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
    Json(params): Json<MoveDocParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, id, Role::Editor).await?;
    let space_id = params
        .space_id
        .as_deref()
        .and_then(|s| s.parse::<i64>().ok());
    // parent_id: 字段存在 → 需要更新（None 也表示移到根级）
    // 通过 Option<String> 中 "0" / "" / null 表达 "根级"
    let parent = if params.space_id.is_some() || params.parent_id.is_some() {
        Some(match params.parent_id.as_deref() {
            None | Some("") | Some("0") => None,
            Some(s) => s.parse::<i64>().ok(),
        })
    } else {
        None
    };
    let doc = DocumentModel::move_to(&ctx.db, id, space_id, parent).await?;
    format::json(DocResponse::from_model(doc))
}

/// 复制文档
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

/// 递归复制文档 (Box + Pin 消除 async 递归)
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
        // 复制 Yjs 状态：src content 里读一个完整 state，再作为新文档的初始 content
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
                space_id: ActiveValue::set(src.space_id),
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

/// 记录访问
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

/// 最近访问
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

/// 空间下的树形结构
#[debug_handler]
pub async fn tree(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Query(params): Query<std::collections::HashMap<String, String>>,
) -> Result<Response> {
    let _claim = UserBrief::from_string(&auth.claims.pid)?;
    let space_id: i64 = params
        .get("space_id")
        .and_then(|s| s.parse().ok())
        .ok_or_else(|| Error::BadRequest("space_id required".into()))?;
    let all = DocumentModel::get_space_tree_flat(&ctx.db, space_id).await?;
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

    // 内部临时结构：使用 i64，便于挂载
    struct Tmp {
        id: i64,
        parent_id: Option<i64>,
        title: String,
        icon: Option<String>,
        children: Vec<Tmp>,
    }

    // 用 id → Tmp 建索引，先构造无 children 的节点
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

    // 分离根 / 待挂载子集
    let mut roots: Vec<Tmp> = Vec::new();
    let mut children_map: HashMap<i64, Vec<Tmp>> = HashMap::new();
    for id in order {
        if let Some(n) = nodes.remove(&id) {
            match n.parent_id {
                Some(pid) if nodes.contains_key(&pid) || children_map.contains_key(&pid) => {
                    children_map.entry(pid).or_default().push(n);
                }
                Some(_) => roots.push(n), // 孤儿提升为根
                None => roots.push(n),
            }
        }
    }

    // 递归挂载
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
    // 若还残留（孤儿嵌套），一并作为根
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
