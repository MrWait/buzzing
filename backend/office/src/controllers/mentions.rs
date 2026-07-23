use axum::debug_handler;
use loco_rs::prelude::*;
use sea_orm::{DbBackend, FromQueryResult, Statement};
use serde::Serialize;

use common::model::UserBrief;

#[derive(Debug, FromQueryResult, Serialize)]
struct UserRow {
    id: i64,
    name: String,
    avatar: Option<String>,
}

#[derive(Debug, FromQueryResult, Serialize)]
struct DocRow {
    id: i64,
    space_id: i64,
    title: String,
    icon: Option<String>,
    updated_at: chrono::DateTime<chrono::FixedOffset>,
}

fn table_name(t: &str) -> String {
    format!("\"{}\"", t.replace('"', "\"\""))
}

/// 搜索当前租户的用户（@user）
#[debug_handler]
pub async fn search_users(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Query(params): Query<std::collections::HashMap<String, String>>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let q = params.get("q").map(|s| s.as_str()).unwrap_or("").trim().to_lowercase();
    let sql = format!(
        "SELECT id, name, avatar FROM {} WHERE tenant_id = $1 AND name ILIKE $2 AND status = 1 ORDER BY name LIMIT 20",
        table_name("users"),
    );
    let stmt = Statement::from_sql_and_values(
        DbBackend::Postgres,
        &sql,
        vec![claim.tenant_id.into(), format!("%{}%", q).into()],
    );
    let rows = UserRow::find_by_statement(stmt).all(&ctx.db).await?;
    format::json(rows)
}

/// 搜索文档（@doc）
#[debug_handler]
pub async fn search_docs(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Query(params): Query<std::collections::HashMap<String, String>>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let q = params.get("q").map(|s| s.as_str()).unwrap_or("").trim().to_lowercase();
    let space_id: Option<i64> = params.get("space_id").and_then(|s| s.parse().ok());
    let mut conditions = vec![
        format!("tenant_id = {}", claim.tenant_id),
        "trashed_at IS NULL".to_string(),
        format!("title ILIKE '%{}%'", q.replace('\'', "''")),
    ];
    if let Some(sid) = space_id {
        conditions.push(format!("space_id = {}", sid));
    }
    let sql = format!(
        "SELECT id, space_id, title, icon, updated_at FROM {} WHERE {} ORDER BY updated_at DESC LIMIT 20",
        table_name("documents"),
        conditions.join(" AND "),
    );
    let stmt = Statement::from_sql_and_values(DbBackend::Postgres, &sql, vec![]);
    let rows = DocRow::find_by_statement(stmt).all(&ctx.db).await?;
    format::json(rows)
}
