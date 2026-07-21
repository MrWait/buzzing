//! `SeaORM` Entity

use sea_orm::entity::prelude::*;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, PartialEq, DeriveEntityModel, Serialize, Deserialize)]
#[sea_orm(table_name = "files")]
pub struct Model {
    #[sea_orm(primary_key, auto_increment = false)]
    pub id: i64,
    pub user_id: i64,
    pub doc_id: Option<i64>,
    pub file_name: String,
    pub file_size: i64,
    pub mime_type: String,
    pub ext: String,
    pub storage_key: String,
    pub md5: Option<String>,
    pub category: String,
    pub width: Option<i32>,
    pub height: Option<i32>,
    pub thumbnail_key: Option<String>,
    pub created_at: i64,
    pub deleted_at: Option<i64>,
}

#[derive(Copy, Clone, Debug, EnumIter, DeriveRelation)]
pub enum Relation {}

impl ActiveModelBehavior for ActiveModel {}
