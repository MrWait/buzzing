use loco_rs::{model::ModelResult, prelude::*};

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
            .filter(model::query::condition().eq(Column::DocId, doc_id).build())
            .all(db)
            .await?)
    }

    pub async fn add_member(
        db: &DatabaseConnection,
        doc_id: i64,
        user_id: i64,
        role: i32,
    ) -> ModelResult<()> {
        ActiveModel {
            doc_id: ActiveValue::set(doc_id),
            user_id: ActiveValue::set(user_id),
            role: ActiveValue::set(role),
            joined_at: ActiveValue::set(current_ms() as i64),
        }
        .insert(db)
        .await?;
        Ok(())
    }

    pub async fn remove_member(
        db: &DatabaseConnection,
        doc_id: i64,
        user_id: i64,
    ) -> ModelResult<()> {
        Entity::delete_many()
            .filter(model::query::condition().eq(Column::DocId, doc_id).build())
            .filter(model::query::condition().eq(Column::UserId, user_id).build())
            .exec(db)
            .await?;
        Ok(())
    }
}
