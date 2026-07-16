use loco_rs::{model::ModelError, model::ModelResult, prelude::*};

pub use base::models::_entities::document_spaces::{ActiveModel, Column, Entity, Model};

#[derive(Debug)]
pub struct DocumentSpaceModel(pub Model);

impl DocumentSpaceModel {
    pub async fn get_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Option<Model>> {
        Ok(Entity::find_by_id(id).one(db).await?)
    }

    pub async fn get_by_creator(
        db: &DatabaseConnection,
        creator: i64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(model::query::condition().eq(Column::Creator, creator).build())
            .all(db)
            .await?)
    }

    pub async fn create(db: &DatabaseConnection, params: ActiveModel) -> ModelResult<Model> {
        Ok(params.insert(db).await?)
    }

    pub async fn update_name(
        db: &DatabaseConnection,
        id: i64,
        name: String,
    ) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?
            .into();
        model.name = ActiveValue::set(name);
        Ok(model.update(db).await?)
    }

    pub async fn delete(db: &DatabaseConnection, id: i64) -> ModelResult<()> {
        Entity::delete_by_id(id).exec(db).await?;
        Ok(())
    }
}
