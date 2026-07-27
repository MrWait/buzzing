use sea_orm::entity::prelude::*;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, PartialEq, DeriveEntityModel, Eq, Serialize, Deserialize)]
#[sea_orm(table_name = "documents")]
pub struct Model {
    pub created_at: DateTimeWithTimeZone,
    pub updated_at: DateTimeWithTimeZone,
    #[sea_orm(primary_key, auto_increment = false)]
    pub id: i64,
    pub tenant_id: i64,
    pub creator: i64,
    pub title: String,
    pub doc_type: i32,
    pub version: i64,
    #[sea_orm(column_type = "VarBinary(StringLen::None)")]
    pub content: Vec<u8>,
    pub parent_id: Option<i64>,
    pub trashed_at: Option<DateTimeWithTimeZone>,
    pub icon: Option<String>,
    pub cover: Option<String>,
    pub plain_text: Option<String>,
    pub wiki_id: Option<i64>,
}

#[derive(Copy, Clone, Debug, EnumIter, DeriveRelation)]
pub enum Relation {}
