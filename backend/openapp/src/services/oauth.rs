use loco_rs::auth;
use rand::Rng;
use serde::{Deserialize, Serialize};

use crate::error::{OpenAppError, Result};
use crate::middleware::AppBrief;
use crate::models::authorization::AuthorizationModel;
use crate::models::user_token::UserTokenModel;

const ACCESS_TOKEN_EXPIRY_SECS: i64 = 7200;   // 2 hours
const REFRESH_TOKEN_EXPIRY_SECS: i64 = 2592000; // 30 days
const AUTH_CODE_EXPIRY_SECS: i64 = 600;        // 10 minutes

/// User Access Token payload
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserAccessClaims {
    pub token_type: String,
    pub user_id: i64,
    pub app_id: String,
    pub tenant_id: i64,
    pub scopes: Vec<String>,
    pub authorization_id: i64,
}

pub fn generate_authorization_code() -> String {
    let bytes: [u8; 16] = rand::thread_rng().r#gen();
    format!("ac_{}", hex::encode(bytes))
}

pub fn generate_access_token() -> String {
    let bytes: [u8; 24] = rand::thread_rng().r#gen();
    format!("ua_{}", hex::encode(bytes))
}

pub fn generate_refresh_token() -> String {
    let bytes: [u8; 32] = rand::thread_rng().r#gen();
    format!("ur_{}", hex::encode(bytes))
}

/// Sign a user access JWT token
pub fn sign_user_access_token(
    ctx: &loco_rs::app::AppContext,
    claims: &UserAccessClaims,
) -> Result<String> {
    let jwt_config = ctx
        .config
        .get_jwt_config()
        .map_err(|e| OpenAppError::Internal(format!("jwt config error: {e}")))?;

    let claims_str = serde_json::to_string(claims)
        .map_err(|e| OpenAppError::Internal(format!("serialize error: {e}")))?;

    let mut extra = serde_json::Map::new();
    extra.insert(
        "token_type".to_string(),
        serde_json::Value::String("user_access".to_string()),
    );

    let token = auth::jwt::JWT::new(&jwt_config.secret)
        .generate_token(ACCESS_TOKEN_EXPIRY_SECS as u64, claims_str, extra)
        .map_err(|e| OpenAppError::Internal(format!("jwt generate error: {e}")))?;

    Ok(token)
}

/// Validate a user access JWT token
pub fn validate_user_access_token(
    token: &str,
    ctx: &loco_rs::app::AppContext,
) -> Result<UserAccessClaims> {
    let jwt_config = ctx
        .config
        .get_jwt_config()
        .map_err(|e| OpenAppError::Internal(format!("jwt config error: {e}")))?;

    let claims = auth::jwt::JWT::new(&jwt_config.secret)
        .validate(token)
        .map_err(|_| OpenAppError::Unauthorized("invalid or expired user access token".into()))?;

    let token_type = claims.claims.claims.get("token_type").and_then(|v| v.as_str());
    if token_type != Some("user_access") {
        return Err(OpenAppError::Unauthorized("not a valid user access token".into()));
    }

    let ua_claims: UserAccessClaims = serde_json::from_str(&claims.claims.pid)
        .map_err(|_| OpenAppError::Unauthorized("invalid token payload".into()))?;

    Ok(ua_claims)
}

/// Exchange authorization code for token pair
pub async fn exchange_code_for_token(
    db: &sea_orm::DatabaseConnection,
    ctx: &loco_rs::app::AppContext,
    code: &str,
    app_id: &str,
    app_db_id: i64,
    tenant_id: i64,
    scopes: Vec<String>,
    user_id: i64,
) -> Result<(String, String, i64, String)> {
    // Create authorization record
    let auth = AuthorizationModel::create(db, app_db_id, user_id, tenant_id, scopes.clone())
        .await
        .map_err(|_| OpenAppError::Internal("failed to create authorization".into()))?;

    let access_token = generate_access_token();
    let refresh_token = generate_refresh_token();

    let access_expire = chrono::Utc::now() + chrono::Duration::seconds(ACCESS_TOKEN_EXPIRY_SECS);
    let refresh_expire = chrono::Utc::now() + chrono::Duration::seconds(REFRESH_TOKEN_EXPIRY_SECS);

    // Store tokens in DB
    UserTokenModel::create(
        db,
        auth.0.id,
        &access_token,
        &refresh_token,
        scopes.clone(),
        access_expire.into(),
        refresh_expire.into(),
    )
    .await
    .map_err(|_| OpenAppError::Internal("failed to create tokens".into()))?;

    // Sign JWT
    let claims = UserAccessClaims {
        token_type: "user_access".to_string(),
        user_id,
        app_id: app_id.to_string(),
        tenant_id,
        scopes,
        authorization_id: auth.0.id,
    };
    let jwt = sign_user_access_token(ctx, &claims)?;

    Ok((jwt, access_token, ACCESS_TOKEN_EXPIRY_SECS, refresh_token))
}

/// Refresh token: validate refresh_token, issue new pair
pub async fn refresh_token(
    db: &sea_orm::DatabaseConnection,
    ctx: &loco_rs::app::AppContext,
    refresh_token: &str,
    app_id: &str,
    app_db_id: i64,
    tenant_id: i64,
) -> Result<(String, String, i64, String)> {
    let stored = UserTokenModel::find_by_refresh_token(db, refresh_token)
        .await
        .map_err(|_| OpenAppError::Internal("db error".into()))?
        .ok_or_else(|| OpenAppError::Unauthorized("invalid refresh token".into()))?;

    if stored.0.refresh_expire_at < chrono::Utc::now() {
        return Err(OpenAppError::TokenExpired("refresh token expired".into()));
    }

    let auth = AuthorizationModel::find_by_id(db, stored.0.authorization_id)
        .await
        .map_err(|_| OpenAppError::Internal("db error".into()))?
        .ok_or_else(|| OpenAppError::Unauthorized("authorization not found".into()))?;

    if auth.0.status != 1 {
        return Err(OpenAppError::Forbidden("authorization revoked".into()));
    }

    let new_access_token = generate_access_token();
    let new_refresh_token = generate_refresh_token();
    let access_expire = chrono::Utc::now() + chrono::Duration::seconds(ACCESS_TOKEN_EXPIRY_SECS);
    let refresh_expire = chrono::Utc::now() + chrono::Duration::seconds(REFRESH_TOKEN_EXPIRY_SECS);

    UserTokenModel::set_refresh_token(
        db,
        stored.0.id,
        &new_refresh_token,
        refresh_expire.into(),
        &new_access_token,
        access_expire.into(),
    )
    .await
    .map_err(|_| OpenAppError::Internal("failed to update tokens".into()))?;

    let claims = UserAccessClaims {
        token_type: "user_access".to_string(),
        user_id: auth.0.user_id,
        app_id: app_id.to_string(),
        tenant_id,
        scopes: auth.0.scopes.clone(),
        authorization_id: auth.0.id,
    };
    let jwt = sign_user_access_token(ctx, &claims)?;

    Ok((jwt, new_access_token, ACCESS_TOKEN_EXPIRY_SECS, new_refresh_token))
}

/// Revoke authorization: invalidate authorization + all tokens
pub async fn revoke_authorization(
    db: &sea_orm::DatabaseConnection,
    authorization_id: i64,
) -> Result<bool> {
    let ok = AuthorizationModel::revoke(db, authorization_id)
        .await
        .map_err(|e| OpenAppError::Internal(format!("db error: {e}")))?;
    if ok {
        UserTokenModel::invalidate_by_authorization(db, authorization_id)
            .await
            .map_err(|e| OpenAppError::Internal(format!("db error: {e}")))?;
    }
    Ok(ok)
}
