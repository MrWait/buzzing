use axum::extract::{Query, State};
use axum::Json;
use loco_rs::prelude::*;
use serde::Deserialize;
use serde_json::{Value, json};

use crate::error::OpenAppError;
use crate::models::api_stat::ApiStatModel;
use crate::models::installation::InstallationModel;

fn ok(data: Value) -> Result<Json<Value>> {
    Ok(Json(json!({"code": 0, "message": "ok", "data": data})))
}

#[derive(Deserialize)]
pub struct TrendsQuery {
    pub metric: Option<String>,
    pub period: Option<String>,
    pub app_id: Option<i64>,
}

/// GET /dashboard/overview — platform overview
pub async fn overview(
    State(ctx): State<AppContext>,
) -> Json<Value> {
    let total_installed = InstallationModel::count_active(&ctx.db).await.unwrap_or(0) as i64;
    let api_calls: i64 = 0;
    let api_errors: i64 = 0;

    Json(json!({
        "code": 0,
        "message": "ok",
        "data": {
            "installed_apps": total_installed,
            "active_apps": total_installed,
            "api_calls_today": api_calls,
            "api_errors_today": api_errors,
            "bot_messages_today": 0,
            "event_push_success_rate": 0.0,
        }
    }))
}

/// GET /dashboard/trends — trend data
pub async fn trends(
    State(ctx): State<AppContext>,
    Query(query): Query<TrendsQuery>,
) -> Result<Json<Value>> {
    let _metric = query.metric.as_deref().unwrap_or("api_calls");

    // For MVP, return empty trends
    ok(json!({
        "labels": [],
        "values": []
    }))
}
