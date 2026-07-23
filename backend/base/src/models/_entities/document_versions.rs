//! `SeaORM` Entity, M5 手工添加

use sea_orm::entity::prelude::*;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, PartialEq, DeriveEntityModel, Eq, Serialize, Deserialize)]
#[sea_orm(table_name = "document_versions")]
pub struct Model {
    pub created_at: DateTimeWithTimeZone,
    pub updated_at: DateTimeWithTimeZone,
    #[sea_orm(primary_key, auto_increment = false)]
    pub id: i64,
    pub document_id: i64,
    pub version_number: i32,
    pub title: String,
    pub description: Option<String>,
    pub yjs_snapshot: Vec<u8>,
    pub plain_text: Option<String>,
    pub creator_id: i64,
    pub is_minor: bool,
}

#[derive(Copy, Clone, Debug, EnumIter, DeriveRelation)]
pub enum Relation {}

impl ActiveModelBehavior for ActiveModel {}
