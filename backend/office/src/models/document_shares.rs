use loco_rs::{model::ModelError, model::ModelResult, prelude::*};
use sea_orm::{ActiveValue, Condition};

pub use base::models::_entities::document_shares::{ActiveModel, Column, Entity, Model};

pub struct DocumentShareModel;

impl DocumentShareModel {
    pub async fn get_by_token(
        db: &DatabaseConnection,
        token: &str,
    ) -> ModelResult<Option<Model>> {
        Ok(Entity::find()
            .filter(Column::Token.eq(token))
            .one(db)
            .await?)
    }

    pub async fn get_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Option<Model>> {
        Ok(Entity::find_by_id(id).one(db).await?)
    }

    pub async fn list_by_doc(
        db: &DatabaseConnection,
        doc_id: i64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(
                Condition::all()
                    .add(Column::DocumentId.eq(doc_id))
                    .add(Column::RevokedAt.is_null()),
            )
            .all(db)
            .await?)
    }

    pub async fn create(db: &DatabaseConnection, params: ActiveModel) -> ModelResult<Model> {
        Ok(params.insert(db).await?)
    }

    pub async fn revoke(db: &DatabaseConnection, id: i64) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?
            .into();
        model.revoked_at = ActiveValue::set(Some(chrono::Utc::now().into()));
        Ok(model.update(db).await?)
    }

    pub async fn increment_visit(db: &DatabaseConnection, id: i64) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?
            .into();
        let cur = match model.visit_count {
            ActiveValue::Set(v) | ActiveValue::Unchanged(v) => v,
            _ => 0,
        };
        model.visit_count = ActiveValue::set(cur + 1);
        Ok(model.update(db).await?)
    }
}
