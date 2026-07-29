use axum::debug_handler;
use loco_rs::prelude::*;
use serde::{Deserialize, Serialize};

use crate::models::document_shares::DocumentShareModel;
use crate::models::documents::DocumentModel;
use crate::permission::Role;

#[derive(Debug, Deserialize)]
pub struct VerifyParams {
    pub password: String,
}

#[derive(Debug, Serialize)]
pub struct ShareResolveResponse {
    pub doc_id: String,
    pub title: String,
    pub icon: Option<String>,
    pub role: i32,
    pub role_label: String,
    pub require_password: bool,
    pub token: Option<String>,
}

/// 公开：解析共享 token
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

    let doc = DocumentModel::get_by_id(&ctx.db, share.document_id)
        .await?
        .ok_or(Error::NotFound)?;
    let role = Role::from_i32(share.role as i32);
    if let Some(hash) = share.password_hash.as_deref() {
        match password {
            None => {
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

    DocumentShareModel::increment_visit(&ctx.db, share.id).await?;

    let jwt_secret = ctx.config.get_jwt_config()?;
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
