use axum::debug_handler;
use loco_rs::prelude::*;
use rand::RngCore;
use serde::{Deserialize, Serialize};

use crate::models::document_shares::DocumentShareModel;
use crate::models::documents::DocumentModel;
use crate::permission::{require_role, Role};
use common::{id_gen, model::UserBrief};

// ---- 请求 / 响应结构 ----

#[derive(Debug, Deserialize)]
pub struct CreateShareParams {
    /// 0=viewer, 1=commenter
    pub role: i32,
    pub password: Option<String>,
    /// ISO8601 时间 (可选)
    pub expires_at: Option<String>,
    pub max_visits: Option<i32>,
}

#[derive(Debug, Serialize)]
pub struct ShareInfo {
    pub id: String,
    pub token: String,
    pub url: String,
    pub role: i32,
    pub role_label: String,
    pub has_password: bool,
    pub expires_at: Option<String>,
    pub max_visits: Option<i32>,
    pub visit_count: i32,
    pub revoked: bool,
    pub created_at: String,
}

impl ShareInfo {
    pub fn from_model(m: crate::models::document_shares::Model) -> Self {
        let role = Role::from_i32(m.role as i32);
        Self {
            id: m.id.to_string(),
            token: m.token.clone(),
            url: format!("/share/{}", m.token),
            role: m.role as i32,
            role_label: role.label().to_string(),
            has_password: m.password_hash.is_some(),
            expires_at: m.expires_at.map(|v| v.to_rfc3339()),
            max_visits: m.max_visits,
            visit_count: m.visit_count,
            revoked: m.revoked_at.is_some(),
            created_at: m.created_at.to_rfc3339(),
        }
    }
}

#[derive(Debug, Deserialize)]
pub struct VerifyParams {
    pub password: String,
}

#[derive(Debug, Serialize)]
pub struct ShareResolveResponse {
    /// 文档基本元数据
    pub doc_id: String,
    pub title: String,
    pub icon: Option<String>,
    pub role: i32,
    pub role_label: String,
    /// 是否需要密码 (未通过校验时返回 true 且 token 为空)
    pub require_password: bool,
    /// 临时 JWT (通过校验后返回)
    pub token: Option<String>,
}

// ---- Handlers ----

/// 创建共享链接 (需 editor+)
#[debug_handler]
pub async fn create(
    auth: auth::JWT,
    Path(doc_id): Path<i64>,
    State(ctx): State<AppContext>,
    Json(params): Json<CreateShareParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, doc_id, Role::Editor).await?;

    // role 仅允许 viewer / commenter
    let role_val = params.role.clamp(0, 1) as i16;
    let token = generate_token(32);
    let password_hash = match params.password.as_deref() {
        Some(pwd) if !pwd.is_empty() => Some(
            bcrypt::hash(pwd, bcrypt::DEFAULT_COST)
                .map_err(|_| Error::InternalServerError)?,
        ),
        _ => None,
    };
    let expires_at = match params.expires_at.as_deref() {
        Some(s) if !s.is_empty() => Some(
            chrono::DateTime::parse_from_rfc3339(s)
                .map_err(|_| Error::BadRequest("invalid expires_at".into()))?,
        ),
        _ => None,
    };

    let am = base::models::_entities::document_shares::ActiveModel {
        id: ActiveValue::set(id_gen(None)),
        document_id: ActiveValue::set(doc_id),
        token: ActiveValue::set(token.clone()),
        creator_id: ActiveValue::set(claim.id),
        role: ActiveValue::set(role_val),
        password_hash: ActiveValue::set(password_hash),
        expires_at: ActiveValue::set(expires_at),
        max_visits: ActiveValue::set(params.max_visits),
        visit_count: ActiveValue::set(0),
        revoked_at: ActiveValue::set(None),
        ..Default::default()
    };
    let created = DocumentShareModel::create(&ctx.db, am).await?;
    format::json(ShareInfo::from_model(created))
}

/// 列出文档的所有共享链接 (需 editor+)
#[debug_handler]
pub async fn list(
    auth: auth::JWT,
    Path(doc_id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, doc_id, Role::Editor).await?;
    let shares = DocumentShareModel::list_by_doc(&ctx.db, doc_id).await?;
    let items: Vec<ShareInfo> = shares.into_iter().map(ShareInfo::from_model).collect();
    format::json(items)
}

/// 撤销共享链接 (需 editor+)
#[debug_handler]
pub async fn revoke(
    auth: auth::JWT,
    Path(share_id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let share = DocumentShareModel::get_by_id(&ctx.db, share_id)
        .await?
        .ok_or(Error::NotFound)?;
    require_role(&ctx, claim.id, share.document_id, Role::Editor).await?;
    DocumentShareModel::revoke(&ctx.db, share_id).await?;
    format::json(serde_json::json!({"ok": true}))
}

/// 公开：解析共享 token
/// - 若 token 无效/过期/超次/已撤销 → 404
/// - 若有密码且未在 body 中传密码 → 返回 require_password=true，token=None
/// - 否则返回临时 JWT + 文档元数据
#[debug_handler]
pub async fn resolve(
    Path(token): Path<String>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    resolve_inner(&ctx, &token, None).await
}

/// 公开：验证密码后再解析
#[debug_handler]
pub async fn verify(
    Path(token): Path<String>,
    State(ctx): State<AppContext>,
    Json(params): Json<VerifyParams>,
) -> Result<Response> {
    resolve_inner(&ctx, &token, Some(&params.password)).await
}

async fn resolve_inner(
    ctx: &AppContext,
    token: &str,
    password: Option<&str>,
) -> Result<Response> {
    let share = DocumentShareModel::get_by_token(&ctx.db, token)
        .await?
        .ok_or(Error::NotFound)?;

    if share.revoked_at.is_some() {
        return Err(Error::NotFound);
    }
    if let Some(exp) = share.expires_at {
        if chrono::Utc::now() > exp {
            return Err(Error::NotFound);
        }
    }
    if let Some(max) = share.max_visits {
        if share.visit_count >= max {
            return Err(Error::NotFound);
        }
    }

    // 密码校验
    let doc = DocumentModel::get_by_id(&ctx.db, share.document_id)
        .await?
        .ok_or(Error::NotFound)?;
    let role = Role::from_i32(share.role as i32);
    if let Some(hash) = share.password_hash.as_deref() {
        match password {
            None => {
                // 需要密码但未提供，返回 require_password
                return format::json(ShareResolveResponse {
                    doc_id: doc.id.to_string(),
                    title: doc.title.clone(),
                    icon: doc.icon.clone(),
                    role: share.role as i32,
                    role_label: role.label().to_string(),
                    require_password: true,
                    token: None,
                });
            }
            Some(pwd) => {
                let ok = bcrypt::verify(pwd, hash).unwrap_or(false);
                if !ok {
                    return Err(Error::Unauthorized("wrong password".into()));
                }
            }
        }
    }

    // 通过校验：+1 visit_count + 签发临时 JWT
    DocumentShareModel::increment_visit(&ctx.db, share.id).await?;

    let jwt_secret = ctx.config.get_jwt_config()?;
    // pid 使用 "share:{share_id}:{doc_id}"，claims 附加 role/doc_id
    let pid = format!("share:{}:{}", share.id, doc.id);
    let mut extra = serde_json::Map::new();
    extra.insert("share_id".into(), serde_json::json!(share.id));
    extra.insert("doc_id".into(), serde_json::json!(doc.id));
    extra.insert("role".into(), serde_json::json!(share.role));
    extra.insert("scope".into(), serde_json::json!("share"));
    let expiration = share
        .expires_at
        .map(|v| {
            let secs = (v.with_timezone(&chrono::Utc) - chrono::Utc::now())
                .num_seconds()
                .max(3600);
            secs as u64
        })
        .unwrap_or(24 * 3600);
    let token_str = loco_rs::auth::jwt::JWT::new(&jwt_secret.secret)
        .generate_token(expiration, pid, extra)
        .map_err(|_| Error::InternalServerError)?;

    format::json(ShareResolveResponse {
        doc_id: doc.id.to_string(),
        title: doc.title,
        icon: doc.icon,
        role: share.role as i32,
        role_label: role.label().to_string(),
        require_password: false,
        token: Some(token_str),
    })
}

/// 生成 url-safe base64 随机 token
fn generate_token(bytes: usize) -> String {
    let mut buf = vec![0u8; bytes];
    rand::thread_rng().fill_bytes(&mut buf);
    // 简单转 base62 (只用 [A-Za-z0-9])
    const ALPHABET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    buf.iter()
        .map(|b| ALPHABET[(*b as usize) % ALPHABET.len()] as char)
        .collect()
}
