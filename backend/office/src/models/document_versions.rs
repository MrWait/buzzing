use loco_rs::prelude::*;
use sea_orm::{ActiveValue, PaginatorTrait, QueryOrder, QuerySelect};

pub use base::models::_entities::document_versions::{ActiveModel, Column, Entity, Model};

pub struct DocumentVersionModel;

impl DocumentVersionModel {
    pub async fn list_by_document(
        db: &DatabaseConnection,
        document_id: i64,
        limit: u64,
        offset: u64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(Column::DocumentId.eq(document_id))
            .order_by(Column::VersionNumber, sea_orm::Order::Desc)
            .limit(limit)
            .offset(offset)
            .all(db)
            .await?)
    }

    pub async fn get_by_id(
        db: &DatabaseConnection,
        id: i64,
    ) -> ModelResult<Option<Model>> {
        Ok(Entity::find_by_id(id).one(db).await?)
    }

    pub async fn get_by_document_and_version(
        db: &DatabaseConnection,
        document_id: i64,
        version_id: i64,
    ) -> ModelResult<Option<Model>> {
        Ok(Entity::find()
            .filter(
                sea_orm::Condition::all()
                    .add(Column::DocumentId.eq(document_id))
                    .add(Column::Id.eq(version_id)),
            )
            .one(db)
            .await?)
    }

    pub async fn create(
        db: &DatabaseConnection,
        id: i64,
        document_id: i64,
        version_number: i32,
        title: String,
        description: Option<String>,
        yjs_snapshot: Vec<u8>,
        plain_text: Option<String>,
        creator_id: i64,
        is_minor: bool,
    ) -> ModelResult<Model> {
        let m = ActiveModel {
            id: ActiveValue::set(id),
            document_id: ActiveValue::set(document_id),
            version_number: ActiveValue::set(version_number),
            title: ActiveValue::set(title),
            description: ActiveValue::set(description),
            yjs_snapshot: ActiveValue::set(yjs_snapshot),
            plain_text: ActiveValue::set(plain_text),
            creator_id: ActiveValue::set(creator_id),
            is_minor: ActiveValue::set(is_minor),
            ..Default::default()
        };
        Ok(m.insert(db).await?)
    }

    pub async fn count_by_document(
        db: &DatabaseConnection,
        document_id: i64,
    ) -> ModelResult<u64> {
        Ok(Entity::find()
            .filter(Column::DocumentId.eq(document_id))
            .count(db)
            .await?)
    }

    pub async fn delete_oldest_by_document(
        db: &DatabaseConnection,
        document_id: i64,
        keep_count: u64,
    ) -> ModelResult<u64> {
        use sea_orm::QueryOrder;
        let all = Entity::find()
            .filter(Column::DocumentId.eq(document_id))
            .filter(Column::IsMinor.eq(true))
            .order_by(Column::VersionNumber, sea_orm::Order::Asc)
            .all(db)
            .await?;
        if all.len() <= keep_count as usize {
            return Ok(0);
        }
        let to_delete = all.len() - keep_count as usize;
        for v in all.iter().take(to_delete) {
            Entity::delete_by_id(v.id).exec(db).await?;
        }
        Ok(to_delete as u64)
    }

    pub async fn get_max_version_number(
        db: &DatabaseConnection,
        document_id: i64,
    ) -> ModelResult<i32> {
        use sea_orm::QueryOrder;
        let result = Entity::find()
            .filter(Column::DocumentId.eq(document_id))
            .order_by(Column::VersionNumber, sea_orm::Order::Desc)
            .one(db)
            .await?;
        Ok(result.map(|v| v.version_number).unwrap_or(0))
    }
}
