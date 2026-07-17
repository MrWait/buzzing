use loco_rs::{model::ModelError, model::ModelResult, prelude::*};
use sea_orm::Condition;

pub use base::models::_entities::document_members::{ActiveModel, Column, Entity, Model};
use common::time::current_ms;

#[derive(Debug)]
pub struct DocumentMemberModel(pub Model);

impl DocumentMemberModel {
    pub async fn get_members(
        db: &DatabaseConnection,
        doc_id: i64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(Column::DocId.eq(doc_id))
            .all(db)
            .await?)
    }

    pub async fn get_one(
        db: &DatabaseConnection,
        doc_id: i64,
        user_id: i64,
    ) -> ModelResult<Option<Model>> {
        Ok(Entity::find()
            .filter(
                Condition::all()
                    .add(Column::DocId.eq(doc_id))
                    .add(Column::UserId.eq(user_id)),
            )
            .one(db)
            .await?)
    }

    pub async fn add_member(
        db: &DatabaseConnection,
        doc_id: i64,
        user_id: i64,
        role: i32,
    ) -> ModelResult<Model> {
        Ok(ActiveModel {
            doc_id: ActiveValue::set(doc_id),
            user_id: ActiveValue::set(user_id),
            role: ActiveValue::set(role),
            joined_at: ActiveValue::set(current_ms() as i64),
        }
        .insert(db)
        .await?)
    }

    pub async fn update_role(
        db: &DatabaseConnection,
        doc_id: i64,
        user_id: i64,
        role: i32,
    ) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find()
            .filter(
                Condition::all()
                    .add(Column::DocId.eq(doc_id))
                    .add(Column::UserId.eq(user_id)),
            )
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?
            .into();
        model.role = ActiveValue::set(role);
        Ok(model.update(db).await?)
    }

    pub async fn remove_member(
        db: &DatabaseConnection,
        doc_id: i64,
        user_id: i64,
    ) -> ModelResult<()> {
        Entity::delete_many()
            .filter(
                Condition::all()
                    .add(Column::DocId.eq(doc_id))
                    .add(Column::UserId.eq(user_id)),
            )
            .exec(db)
            .await?;
        Ok(())
    }
}
