use axum::extract::{Path, Query, State};
use axum::Json;
use loco_rs::prelude::*;
use serde::Deserialize;
use serde_json::{Value, json};
use tracing::{info, warn};

use crate::error::OpenAppError;
use crate::middleware::AppAuth;
use crate::models::app::OpenAppModel;
use crate::services::oauth;

#[derive(Deserialize)]
pub struct AuthorizeQuery {
    pub response_type: Option<String>,
    pub client_id: Option<String>,
    pub redirect_uri: Option<String>,
    pub scope: Option<String>,
    pub state: Option<String>,
}

#[derive(Deserialize)]
pub struct TokenReq {
    pub grant_type: String,
    pub code: Option<String>,
    pub refresh_token: Option<String>,
    pub client_id: String,
    pub client_secret: String,
}

#[derive(Deserialize)]
pub struct AuthorizeConfirmReq {
    pub client_id: String,
    pub scopes: Vec<String>,
    pub state: Option<String>,
}

fn ok(data: Value) -> Result<Json<Value>> {
    Ok(Json(json!({"code": 0, "message": "ok", "data": data})))
}

fn err(code: u32, message: &str) -> (axum::http::StatusCode, Json<Value>) {
    (
        axum::http::StatusCode::BAD_REQUEST,
        Json(json!({"code": code, "message": message, "data": null})),
    )
}

/// GET /oauth/authorize — validate params and redirect to confirm page
pub async fn authorize(
    State(_ctx): State<AppContext>,
    Query(query): Query<AuthorizeQuery>,
) -> Result<Json<Value>> {
    if query.response_type.as_deref() != Some("code") {
        return Err(loco_rs::Error::BadRequest("response_type must be 'code'".into()));
    }
    let _client_id = query.client_id.as_deref().ok_or_else(|| {
        loco_rs::Error::BadRequest("missing client_id".into())
    })?;
    let _redirect_uri = query.redirect_uri.as_deref().ok_or_else(|| {
        loco_rs::Error::BadRequest("missing redirect_uri".into())
    })?;

    // Return authorize page data (Vue SPA renders the confirmation UI)
    ok(json!({
        "client_id": query.client_id,
        "redirect_uri": query.redirect_uri,
        "scope": query.scope,
        "state": query.state,
    }))
}

/// POST /oauth/authorize — user confirms authorization
pub async fn confirm_authorize(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Json(body): Json<AuthorizeConfirmReq>,
) -> Result<Json<Value>> {
    let brief = common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;

    let app = OpenAppModel::find_by_app_id(&ctx.db, &body.client_id)
        .await
        .map_err(|_| loco_rs::Error::InternalServerError)?
        .ok_or_else(|| loco_rs::Error::NotFound)?;

    if app.0.status != 1 {
        return Err(loco_rs::Error::BadRequest("app is disabled".into()));
    }

    let code = oauth::generate_authorization_code();
    info!("OAuth authorize: user={}, app={}, code={}", brief.id, body.client_id, code);

    ok(json!({
        "code": code,
        "state": body.state,
    }))
}

/// POST /oauth/token — exchange code for token or refresh token
pub async fn token(
    State(ctx): State<AppContext>,
    Json(body): Json<TokenReq>,
) -> Result<Json<Value>> {
    let app = OpenAppModel::find_by_app_id(&ctx.db, &body.client_id)
        .await
        .map_err(|_| loco_rs::Error::InternalServerError)?
        .ok_or_else(|| loco_rs::Error::BadRequest("invalid client_id".into()))?;

    if app.0.status != 1 {
        return Err(loco_rs::Error::BadRequest("app is disabled".into()));
    }

    // Verify secret
    if !crate::services::auth::verify_secret(&body.client_secret, &app.0.app_secret) {
        return Err(loco_rs::Error::Unauthorized("invalid client_secret".into()));
    }

    match body.grant_type.as_str() {
        "authorization_code" => {
            let code = body.code.as_deref().ok_or_else(|| {
                loco_rs::Error::BadRequest("missing code".into())
            })?;

            // In a real implementation, code would be validated against a cache/store
            // For now, we generate tokens directly
            let scopes: Vec<String> = vec![]; // from the original authorize request
            let (jwt, access_token, expires_in, refresh_token) = oauth::exchange_code_for_token(
                &ctx.db,
                &ctx,
                code,
                &app.0.app_id,
                app.0.id,
                app.0.tenant_id,
                scopes,
                app.0.owner_id,
            )
            .await
            .map_err(|e| {
                warn!("token exchange error: {e}");
                loco_rs::Error::InternalServerError
            })?;

            ok(json!({
                "access_token": jwt,
                "token_type": "Bearer",
                "expires_in": expires_in,
                "refresh_token": refresh_token,
                "scope": "",
            }))
        }
        "refresh_token" => {
            let rtoken = body.refresh_token.as_deref().ok_or_else(|| {
                loco_rs::Error::BadRequest("missing refresh_token".into())
            })?;

            let (jwt, access_token, expires_in, refresh_token) = oauth::refresh_token(
                &ctx.db,
                &ctx,
                rtoken,
                &app.0.app_id,
                app.0.id,
                app.0.tenant_id,
            )
            .await
            .map_err(|e| {
                warn!("refresh token error: {e}");
                loco_rs::Error::Unauthorized("invalid refresh_token".into())
            })?;

            ok(json!({
                "access_token": jwt,
                "token_type": "Bearer",
                "expires_in": expires_in,
                "refresh_token": refresh_token,
                "scope": "",
            }))
        }
        _ => Err(loco_rs::Error::BadRequest("unsupported grant_type".into())),
    }
}

/// DELETE /oauth/authorizations/{id} — revoke authorization
pub async fn revoke_authorization(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Path(id): Path<i64>,
) -> Result<Json<Value>> {
    let _brief = common::UserBrief::from_string(&auth.claims.pid)
        .map_err(|_| loco_rs::Error::Unauthorized("invalid token".into()))?;

    let success = oauth::revoke_authorization(&ctx.db, id)
        .await
        .map_err(|_| loco_rs::Error::InternalServerError)?;

    if !success {
        return Err(loco_rs::Error::NotFound);
    }
    ok(json!({"revoked": true}))
}
