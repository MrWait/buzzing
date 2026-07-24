use std::fmt;

use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use axum::Json;
use serde_json::json;

pub type Result<T> = std::result::Result<T, OpenAppError>;

#[derive(Debug)]
pub enum OpenAppError {
    BadRequest(String),
    NotFound(String),
    Unauthorized(String),
    Forbidden(String),
    Internal(String),
    ScopeDenied(String),
    RateLimit(String),
    TokenExpired(String),
    AppDisabled(String),
}

impl fmt::Display for OpenAppError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            OpenAppError::BadRequest(msg) => write!(f, "BadRequest: {msg}"),
            OpenAppError::NotFound(msg) => write!(f, "NotFound: {msg}"),
            OpenAppError::Unauthorized(msg) => write!(f, "Unauthorized: {msg}"),
            OpenAppError::Forbidden(msg) => write!(f, "Forbidden: {msg}"),
            OpenAppError::Internal(msg) => write!(f, "Internal: {msg}"),
            OpenAppError::ScopeDenied(msg) => write!(f, "ScopeDenied: {msg}"),
            OpenAppError::RateLimit(msg) => write!(f, "RateLimit: {msg}"),
            OpenAppError::TokenExpired(msg) => write!(f, "TokenExpired: {msg}"),
            OpenAppError::AppDisabled(msg) => write!(f, "AppDisabled: {msg}"),
        }
    }
}

impl IntoResponse for OpenAppError {
    fn into_response(self) -> Response {
        let (status, code, message) = match self {
            OpenAppError::BadRequest(msg) => (StatusCode::BAD_REQUEST, 400, msg),
            OpenAppError::NotFound(msg) => (StatusCode::NOT_FOUND, 404, msg),
            OpenAppError::Unauthorized(msg) => (StatusCode::UNAUTHORIZED, 401, msg),
            OpenAppError::Forbidden(msg) => (StatusCode::FORBIDDEN, 403, msg),
            OpenAppError::Internal(msg) => (StatusCode::INTERNAL_SERVER_ERROR, 500, msg),
            OpenAppError::ScopeDenied(msg) => (StatusCode::FORBIDDEN, 21001, msg),
            OpenAppError::RateLimit(msg) => (StatusCode::TOO_MANY_REQUESTS, 21002, msg),
            OpenAppError::TokenExpired(msg) => (StatusCode::UNAUTHORIZED, 21003, msg),
            OpenAppError::AppDisabled(msg) => (StatusCode::FORBIDDEN, 21005, msg),
        };
        let body = Json(json!({
            "code": code,
            "message": message,
            "data": null,
        }));
        (status, body).into_response()
    }
}

impl From<sea_orm::DbErr> for OpenAppError {
    fn from(e: sea_orm::DbErr) -> Self {
        OpenAppError::Internal(format!("db error: {e}"))
    }
}

impl From<loco_rs::Error> for OpenAppError {
    fn from(e: loco_rs::Error) -> Self {
        OpenAppError::Internal(format!("internal error: {e}"))
    }
}
