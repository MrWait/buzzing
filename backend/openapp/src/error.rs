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
}

impl fmt::Display for OpenAppError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            OpenAppError::BadRequest(msg) => write!(f, "BadRequest: {msg}"),
            OpenAppError::NotFound(msg) => write!(f, "NotFound: {msg}"),
            OpenAppError::Unauthorized(msg) => write!(f, "Unauthorized: {msg}"),
            OpenAppError::Forbidden(msg) => write!(f, "Forbidden: {msg}"),
            OpenAppError::Internal(msg) => write!(f, "Internal: {msg}"),
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
