use loco_rs::{model::ModelError, model::ModelResult, prelude::*};
use sea_orm::{ActiveValue, Condition};

pub use base::models::_entities::document_stars::{ActiveModel, Column, Entity, Model};

pub struct DocumentStarModel;

impl DocumentStarModel {
    pub async fn get(
        db: &DatabaseConnection,
        user_id: i64,
        document_id: i64,
    ) -> ModelResult<Option<Model>> {
        Ok(Entity::find()
            .filter(
                Condition::all()
                    .add(Column::UserId.eq(user_id))
                    .add(Column::DocumentId.eq(document_id)),
            )
            .one(db)
            .await?)
    }

    pub async fn create(
        db: &DatabaseConnection,
        id: i64,
        user_id: i64,
        document_id: i64,
        group_name: Option<String>,
    ) -> ModelResult<Model> {
        let m = ActiveModel {
            id: ActiveValue::set(id),
            user_id: ActiveValue::set(user_id),
            document_id: ActiveValue::set(document_id),
            group_name: ActiveValue::set(group_name),
            ..Default::default()
        };
        Ok(m.insert(db).await?)
    }

    pub async fn remove(
        db: &DatabaseConnection,
        user_id: i64,
        document_id: i64,
    ) -> ModelResult<()> {
        Entity::delete_many()
            .filter(
                Condition::all()
                    .add(Column::UserId.eq(user_id))
                    .add(Column::DocumentId.eq(document_id)),
            )
            .exec(db)
            .await?;
        Ok(())
    }

    pub async fn list_by_user(db: &DatabaseConnection, user_id: i64) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(Column::UserId.eq(user_id))
            .all(db)
            .await?)
    }
}

// 供 clippy 抑制未使用 ModelError
#[allow(dead_code)]
fn _touch() -> Option<ModelError> {
    None
}
