use axum::debug_handler;
use loco_rs::prelude::*;
use sea_orm::{DbBackend, FromQueryResult, Statement};
use serde::{Deserialize, Serialize};

use common::model::UserBrief;

#[derive(Debug, Deserialize)]
pub struct SearchParams {
    pub q: String,
    pub space_id: Option<String>,
    pub limit: Option<u64>,
}

#[derive(Debug, Serialize)]
pub struct SearchResult {
    pub id: String,
    pub space_id: String,
    pub title: String,
    pub icon: Option<String>,
    pub highlight: String,
    pub matched_in: String,
    pub updated_at: String,
}

#[derive(Debug, FromQueryResult)]
struct SearchRow {
    id: i64,
    space_id: i64,
    title: String,
    icon: Option<String>,
    highlight: String,
    matched_title: bool,
    updated_at: chrono::DateTime<chrono::FixedOffset>,
}

#[debug_handler]
pub async fn search(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Json(params): Json<SearchParams>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let query = params.q.trim();
    if query.is_empty() {
        return format::json(Vec::<SearchResult>::new());
    }
    let limit = params.limit.unwrap_or(20).min(100);
    let space_filter = params
        .space_id
        .as_deref()
        .and_then(|s| s.parse::<i64>().ok());

    // 使用 plainto_tsquery 兼容普通输入，'simple' 分词器（后续可换 pg_jieba）
    // 权限过滤：tenant_id 匹配 + trashed_at 为空
    // space_id 可选过滤
    let sql = if space_filter.is_some() {
        r#"
        SELECT
            id, space_id, title, icon,
            ts_headline(
                'simple',
                COALESCE(plain_text, ''),
                plainto_tsquery('simple', $1),
                'MaxWords=20, MinWords=5, HighlightAll=false, StartSel=<em>, StopSel=</em>'
            ) AS highlight,
            (to_tsvector('simple', title) @@ plainto_tsquery('simple', $1)) AS matched_title,
            updated_at
        FROM documents
        WHERE tenant_id = $2
          AND trashed_at IS NULL
          AND space_id = $3
          AND search_tsv @@ plainto_tsquery('simple', $1)
        ORDER BY ts_rank(search_tsv, plainto_tsquery('simple', $1)) DESC, updated_at DESC
        LIMIT $4
        "#
    } else {
        r#"
        SELECT
            id, space_id, title, icon,
            ts_headline(
                'simple',
                COALESCE(plain_text, ''),
                plainto_tsquery('simple', $1),
                'MaxWords=20, MinWords=5, HighlightAll=false, StartSel=<em>, StopSel=</em>'
            ) AS highlight,
            (to_tsvector('simple', title) @@ plainto_tsquery('simple', $1)) AS matched_title,
            updated_at
        FROM documents
        WHERE tenant_id = $2
          AND trashed_at IS NULL
          AND search_tsv @@ plainto_tsquery('simple', $1)
        ORDER BY ts_rank(search_tsv, plainto_tsquery('simple', $1)) DESC, updated_at DESC
        LIMIT $3
        "#
    };

    let values: Vec<sea_orm::Value> = if let Some(sp) = space_filter {
        vec![
            query.into(),
            claim.tenant_id.into(),
            sp.into(),
            (limit as i64).into(),
        ]
    } else {
        vec![query.into(), claim.tenant_id.into(), (limit as i64).into()]
    };

    let stmt = Statement::from_sql_and_values(DbBackend::Postgres, sql, values);
    let rows = SearchRow::find_by_statement(stmt).all(&ctx.db).await?;

    let items: Vec<SearchResult> = rows
        .into_iter()
        .map(|r| SearchResult {
            id: r.id.to_string(),
            space_id: r.space_id.to_string(),
            title: r.title,
            icon: r.icon,
            highlight: r.highlight,
            matched_in: if r.matched_title {
                "title".to_string()
            } else {
                "content".to_string()
            },
            updated_at: r.updated_at.to_rfc3339(),
        })
        .collect();

    format::json(items)
}
