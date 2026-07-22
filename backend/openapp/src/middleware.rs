use axum::extract::FromRequestParts;
use axum::http::request::Parts;
use axum::http::HeaderMap;
use loco_rs::app::AppContext;

use crate::error::{OpenAppError, Result};
use crate::services::auth;

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct AppBrief {
    pub app_id: String,
    pub app_db_id: i64,
    pub tenant_id: i64,
    pub scopes: Vec<String>,
}

impl AppBrief {
    pub fn has_scope(&self, scope: &str) -> bool {
        self.scopes.iter().any(|s| s == scope)
    }
}

pub struct AppAuth(pub AppBrief);

impl FromRequestParts<AppContext> for AppAuth
{
    type Rejection = OpenAppError;

    async fn from_request_parts(parts: &mut Parts, state: &AppContext) -> Result<Self> {
        let token = extract_bearer_token(&parts.headers)?;
        let brief = auth::validate_tenant_token(token, state)?;
        Ok(AppAuth(brief))
    }
}

fn extract_bearer_token(headers: &HeaderMap) -> Result<&str> {
    let auth_header = headers
        .get("Authorization")
        .ok_or_else(|| OpenAppError::Unauthorized("missing Authorization header".into()))?;
    let auth_str = auth_header
        .to_str()
        .map_err(|_| OpenAppError::Unauthorized("invalid Authorization header".into()))?;
    auth_str
        .strip_prefix("Bearer ")
        .ok_or_else(|| OpenAppError::Unauthorized("invalid auth scheme, must be Bearer".into()))
}
