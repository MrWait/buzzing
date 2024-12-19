use loco_rs::{model::ModelResult, prelude::*};

pub use base::models::_entities::cmvs::{ActiveModel, Column, Entity, Model};

#[derive(Debug)]
pub struct CmvModel(pub Model);
pub type Cmvs = Entity;

impl CmvModel {
    pub async fn find_by_ids(db: &DatabaseConnection, ids: &[i64]) -> ModelResult<Vec<Model>> {
        let db_cmvs = Entity::find()
            .filter(
                model::query::condition()
                    .is_in(Column::Id, ids.to_vec())
                    .build(),
            )
            .all(db)
            .await?;
        Ok(db_cmvs)
    }

    pub async fn find_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Self> {
        let cmv = Entity::find()
            .filter(model::query::condition().eq(Column::Id, id).build())
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?;
        Ok(Self(cmv))
    }
}
