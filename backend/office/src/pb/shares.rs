use loco_rs::{Error, Result, app::AppContext};
use prost::Message;
use rand::RngCore;
use sea_orm::ActiveValue;
use tracing::instrument;

use common::{id_gen, model::UserBrief};
use proto::idl::{error::ErrorCode, office};

use crate::models::document_shares::DocumentShareModel;
use crate::models::documents::DocumentModel;
use crate::permission::{require_role, Role};

fn share_to_item(m: crate::models::document_shares::Model) -> office::ShareItem {
    let role = Role::from_i32(m.role as i32);
    office::ShareItem {
        id: m.id.to_string(),
        token: m.token.clone(),
        url: format!("/share/{}", m.token),
        role: m.role as i32,
        role_label: role.label().to_string(),
        has_password: m.password_hash.is_some(),
        expires_at: m.expires_at.map(|v| v.to_rfc3339()).unwrap_or_default(),
        max_visits: m.max_visits.unwrap_or(0),
        visit_count: m.visit_count,
        revoked: m.revoked_at.is_some(),
        created_at: m.created_at.to_rfc3339(),
    }
}

fn generate_token(bytes: usize) -> String {
    let mut buf = vec![0u8; bytes];
    rand::thread_rng().fill_bytes(&mut buf);
    const ALPHABET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    buf.iter()
        .map(|b| ALPHABET[(*b as usize) % ALPHABET.len()] as char)
        .collect()
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn create(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::ShareCreateRequest>(&packet.payload)?;
    require_role(ctx, brief.id, req.doc_id, Role::Editor).await?;

    let role_val = req.role.clamp(0, 1) as i16;
    let token = generate_token(32);
    let password_hash = match req.password.as_str() {
        "" => None,
        pwd => Some(
            bcrypt::hash(pwd, bcrypt::DEFAULT_COST)
                .map_err(|_| Error::InternalServerError)?,
        ),
    };
    let expires_at: Option<chrono::DateTime<chrono::FixedOffset>> = match req.expires_at.as_str() {
        "" => None,
        s => Some(
            chrono::DateTime::parse_from_rfc3339(s)
                .map_err(|_| Error::string("invalid expires_at"))?,
        ),
    };
    let max_visits: Option<i32> = if req.max_visits > 0 {
        Some(req.max_visits)
    } else {
        None
    };

    let am = base::models::_entities::document_shares::ActiveModel {
        id: ActiveValue::set(id_gen(None)),
        document_id: ActiveValue::set(req.doc_id),
        token: ActiveValue::set(token.clone()),
        creator_id: ActiveValue::set(brief.id),
        role: ActiveValue::set(role_val),
        password_hash: ActiveValue::set(password_hash),
        expires_at: ActiveValue::set(expires_at),
        max_visits: ActiveValue::set(max_visits),
        visit_count: ActiveValue::set(0),
        revoked_at: ActiveValue::set(None),
        ..Default::default()
    };
    let created = DocumentShareModel::create(&ctx.db, am).await?;
    let resp = office::ShareCreateResponse {
        item: Some(share_to_item(created)),
    };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn list(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::ShareListRequest>(&packet.payload)?;
    require_role(ctx, brief.id, req.doc_id, Role::Editor).await?;
    let shares = DocumentShareModel::list_by_doc(&ctx.db, req.doc_id).await?;
    let items: Vec<office::ShareItem> = shares.into_iter().map(share_to_item).collect();
    let resp = office::ShareListResponse { items };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn revoke(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::ShareRevokeRequest>(&packet.payload)?;
    let share = DocumentShareModel::get_by_id(&ctx.db, req.share_id)
        .await?
        .ok_or(Error::NotFound)?;
    require_role(ctx, brief.id, share.document_id, Role::Editor).await?;
    DocumentShareModel::revoke(&ctx.db, req.share_id).await?;
    let resp = office::ShareRevokeResponse { ok: true };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(_ctx, _brief, packet))]
pub(crate) async fn resolve(
    _ctx: &AppContext,
    _brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::ShareResolveRequest>(&packet.payload)?;
    resolve_inner(&_ctx, &req.token, None).await
}

#[instrument(skip(_ctx, _brief, packet))]
pub(crate) async fn verify(
    _ctx: &AppContext,
    _brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::ShareVerifyRequest>(&packet.payload)?;
    resolve_inner(&_ctx, &req.token, Some(&req.password)).await
}

async fn resolve_inner(
    ctx: &AppContext,
    token: &str,
    password: Option<&str>,
) -> Result<(i32, Vec<u8>)> {
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
                let resp = office::ShareResolveResponse {
                    doc_id: doc.id.to_string(),
                    title: doc.title.clone(),
                    icon: doc.icon.unwrap_or_default(),
                    role: share.role as i32,
                    role_label: role.label().to_string(),
                    require_password: true,
                    token: String::new(),
                };
                return Ok((ErrorCode::Success as i32, resp.encode_to_vec()));
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

    let resp = office::ShareResolveResponse {
        doc_id: doc.id.to_string(),
        title: doc.title,
        icon: doc.icon.unwrap_or_default(),
        role: share.role as i32,
        role_label: role.label().to_string(),
        require_password: false,
        token: token_str,
    };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}
