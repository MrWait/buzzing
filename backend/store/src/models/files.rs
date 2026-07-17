use loco_rs::{model::ModelResult, prelude::*};

pub use base::models::_entities::files::{ActiveModel, Column, Entity, Model};

#[derive(Debug)]
pub struct FileModel(pub Model);

impl FileModel {
    pub async fn get_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Option<Model>> {
        Ok(Entity::find_by_id(id).one(db).await?)
    }

    pub async fn get_by_doc_id(
        db: &DatabaseConnection,
        doc_id: i64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(Column::DocId.eq(doc_id))
            .all(db)
            .await?)
    }

    pub async fn get_by_md5(
        db: &DatabaseConnection,
        md5_val: &str,
        category: &str,
    ) -> ModelResult<Option<Model>> {
        Ok(Entity::find()
            .filter(Column::Md5.eq(md5_val))
            .filter(Column::Category.eq(category))
            .filter(Column::DeletedAt.is_null())
            .one(db)
            .await?)
    }

    pub async fn create(db: &DatabaseConnection, params: ActiveModel) -> ModelResult<Model> {
        Ok(params.insert(db).await?)
    }

    pub async fn soft_delete(db: &DatabaseConnection, id: i64) -> ModelResult<()> {
        let now = chrono::Utc::now().timestamp_millis();
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(loco_rs::model::ModelError::EntityNotFound)?
            .into();
        model.deleted_at = ActiveValue::set(Some(now));
        model.update(db).await?;
        Ok(())
    }
}
