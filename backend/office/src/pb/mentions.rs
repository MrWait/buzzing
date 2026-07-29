use loco_rs::Result;
use prost::Message;
use sea_orm::{DbBackend, FromQueryResult, Statement};
use tracing::instrument;

use common::model::UserBrief;
use loco_rs::app::AppContext;
use proto::idl::{error::ErrorCode, office};

#[derive(Debug, FromQueryResult)]
struct UserRow {
    id: i64,
    name: String,
    avatar: Option<String>,
}

#[derive(Debug, FromQueryResult)]
struct DocRow {
    id: i64,
    wiki_id: Option<i64>,
    title: String,
    icon: Option<String>,
    updated_at: chrono::DateTime<chrono::FixedOffset>,
}

fn table_name(t: &str) -> String {
    format!("\"{}\"", t.replace('"', "\"\""))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn search_users(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::MentionUsersRequest>(&packet.payload)?;
    let q = req.q.trim().to_lowercase();
    let sql = format!(
        "SELECT id, name, avatar FROM {} WHERE tenant_id = $1 AND name ILIKE $2 AND status = 1 ORDER BY name LIMIT 20",
        table_name("users"),
    );
    let stmt = Statement::from_sql_and_values(
        DbBackend::Postgres,
        &sql,
        vec![brief.tenant_id.into(), format!("%{}%", q).into()],
    );
    let rows = UserRow::find_by_statement(stmt).all(&ctx.db).await?;
    let items: Vec<office::MentionUserItem> = rows
        .into_iter()
        .map(|r| office::MentionUserItem {
            id: r.id.to_string(),
            name: r.name,
            avatar: r.avatar.unwrap_or_default(),
        })
        .collect();
    let resp = office::MentionUsersResponse { items };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn search_docs(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::MentionDocsRequest>(&packet.payload)?;
    let q = req.q.trim().to_lowercase();
    let wiki_filter = if req.wiki_id.is_empty() {
        None
    } else {
        Some(req.wiki_id.parse::<i64>().unwrap_or(0))
    };
    let mut conditions = vec![
        format!("tenant_id = {}", brief.tenant_id),
        "trashed_at IS NULL".to_string(),
        format!("title ILIKE '%{}%'", q.replace('\'', "''")),
    ];
    if let Some(wid) = wiki_filter {
        if wid > 0 {
            conditions.push(format!("wiki_id = {}", wid));
        }
    }
    let sql = format!(
        "SELECT id, wiki_id, title, icon, updated_at FROM {} WHERE {} ORDER BY updated_at DESC LIMIT 20",
        table_name("documents"),
        conditions.join(" AND "),
    );
    let stmt = Statement::from_sql_and_values(DbBackend::Postgres, &sql, vec![]);
    let rows = DocRow::find_by_statement(stmt).all(&ctx.db).await?;
    let items: Vec<office::MentionDocItem> = rows
        .into_iter()
        .map(|r| office::MentionDocItem {
            id: r.id.to_string(),
            wiki_id: r.wiki_id.map(|v| v.to_string()).unwrap_or_default(),
            title: r.title,
            icon: r.icon.unwrap_or_default(),
            updated_at: r.updated_at.to_rfc3339(),
        })
        .collect();
    let resp = office::MentionDocsResponse { items };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}
