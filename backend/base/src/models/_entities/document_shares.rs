//! `SeaORM` Entity, M4 手工添加

use sea_orm::entity::prelude::*;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, PartialEq, DeriveEntityModel, Eq, Serialize, Deserialize)]
#[sea_orm(table_name = "document_shares")]
pub struct Model {
    pub created_at: DateTimeWithTimeZone,
    pub updated_at: DateTimeWithTimeZone,
    #[sea_orm(primary_key, auto_increment = false)]
    pub id: i64,
    pub document_id: i64,
    pub token: String,
    pub creator_id: i64,
    pub role: i16,
    pub password_hash: Option<String>,
    pub expires_at: Option<DateTimeWithTimeZone>,
    pub max_visits: Option<i32>,
    pub visit_count: i32,
    pub revoked_at: Option<DateTimeWithTimeZone>,
}

#[derive(Copy, Clone, Debug, EnumIter, DeriveRelation)]
pub enum Relation {}

impl ActiveModelBehavior for ActiveModel {}
