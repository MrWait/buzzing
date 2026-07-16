use loco_rs::{model::ModelError, model::ModelResult, prelude::*};

pub use base::models::_entities::documents::{ActiveModel, Column, Entity, Model};

#[derive(Debug)]
pub struct DocumentModel(pub Model);

impl DocumentModel {
    pub async fn get_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Option<Model>> {
        Ok(Entity::find_by_id(id).one(db).await?)
    }

    pub async fn get_by_space_id(
        db: &DatabaseConnection,
        space_id: i64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(model::query::condition().eq(Column::SpaceId, space_id).build())
            .all(db)
            .await?)
    }

    pub async fn create(db: &DatabaseConnection, params: ActiveModel) -> ModelResult<Model> {
        Ok(params.insert(db).await?)
    }

    pub async fn update_title(
        db: &DatabaseConnection,
        id: i64,
        title: String,
        version: i64,
    ) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?
            .into();
        model.title = ActiveValue::set(title);
        model.version = ActiveValue::set(version);
        Ok(model.update(db).await?)
    }

    pub async fn update_content(
        db: &DatabaseConnection,
        id: i64,
        content: Vec<u8>,
        version: i64,
    ) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?
            .into();
        model.content = ActiveValue::set(content);
        model.version = ActiveValue::set(version);
        Ok(model.update(db).await?)
    }

    pub async fn delete(db: &DatabaseConnection, id: i64) -> ModelResult<()> {
        Entity::delete_by_id(id).exec(db).await?;
        Ok(())
    }
}
