use loco_rs::{model::ModelResult, prelude::*};
use sea_orm::{ActiveValue, QueryOrder};

pub use base::models::_entities::wiki_pins::{ActiveModel as PinActive, Column, Entity, Model};

pub struct WikiPinModel;

impl WikiPinModel {
    pub async fn list_by_wiki(
        db: &DatabaseConnection,
        wiki_id: i64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(Column::WikiId.eq(wiki_id))
            .order_by_desc(Column::CreatedAt)
            .all(db)
            .await?)
    }

    pub async fn add_pin(
        db: &DatabaseConnection,
        id: i64,
        wiki_id: i64,
        doc_id: i64,
        pinned_by: i64,
        now_ms: i64,
    ) -> ModelResult<Model> {
        let m = PinActive {
            id: ActiveValue::Set(id),
            wiki_id: ActiveValue::Set(wiki_id),
            doc_id: ActiveValue::Set(doc_id),
            pinned_by: ActiveValue::Set(pinned_by),
            created_at: ActiveValue::Set(now_ms),
        };
        Ok(m.insert(db).await?)
    }

    pub async fn remove_pin(
        db: &DatabaseConnection,
        wiki_id: i64,
        doc_id: i64,
    ) -> ModelResult<()> {
        Entity::delete_many()
            .filter(Column::WikiId.eq(wiki_id))
            .filter(Column::DocId.eq(doc_id))
            .exec(db)
            .await?;
        Ok(())
    }
}
