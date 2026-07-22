use loco_rs::auth;

use crate::error::{OpenAppError, Result};
use crate::middleware::AppBrief;

pub fn generate_app_id() -> String {
    use rand::Rng;
    let bytes: [u8; 8] = rand::thread_rng().r#gen();
    format!("app_{}", hex_fmt(&bytes))
}

pub fn generate_app_secret() -> String {
    use rand::Rng;
    let bytes: [u8; 32] = rand::thread_rng().r#gen();
    format!("sk_{}", hex_fmt(&bytes))
}

pub fn hash_secret(secret: &str) -> String {
    use sha2::Digest;
    let mut hasher = sha2::Sha256::new();
    hasher.update(secret.as_bytes());
    hex::encode(hasher.finalize())
}

pub fn verify_secret(secret: &str, hash: &str) -> bool {
    hash_secret(secret) == hash
}

fn hex_fmt(bytes: &[u8]) -> String {
    bytes.iter().map(|b| format!("{b:02x}")).collect()
}

pub fn generate_tenant_token(
    ctx: &loco_rs::app::AppContext,
    brief: &AppBrief,
) -> Result<String> {
    let jwt_config = ctx
        .config
        .get_jwt_config()
        .map_err(|e| OpenAppError::Internal(format!("jwt config error: {e}")))?;
    let brief_str = serde_json::to_string(brief)
        .map_err(|e| OpenAppError::Internal(format!("serialize error: {e}")))?;
    let mut extra = serde_json::Map::new();
    extra.insert(
        "token_type".to_string(),
        serde_json::Value::String("openapp".to_string()),
    );
    let token = auth::jwt::JWT::new(&jwt_config.secret)
        .generate_token(jwt_config.expiration, brief_str, extra)
        .map_err(|e| OpenAppError::Internal(format!("jwt generate error: {e}")))?;
    Ok(token)
}

pub fn validate_tenant_token(token: &str, ctx: &loco_rs::app::AppContext) -> Result<AppBrief> {
    let jwt_config = ctx
        .config
        .get_jwt_config()
        .map_err(|e| OpenAppError::Internal(format!("jwt config error: {e}")))?;
    let claims = auth::jwt::JWT::new(&jwt_config.secret)
        .validate(token)
        .map_err(|_| OpenAppError::Unauthorized("invalid or expired token".into()))?;
    let token_type = claims.claims.claims.get("token_type").and_then(|v| v.as_str());
    if token_type != Some("openapp") {
        return Err(OpenAppError::Unauthorized(
            "not a valid openapp token".into(),
        ));
    }
    let brief: AppBrief = serde_json::from_str(&claims.claims.pid)
        .map_err(|_| OpenAppError::Unauthorized("invalid token payload".into()))?;
    Ok(brief)
}
