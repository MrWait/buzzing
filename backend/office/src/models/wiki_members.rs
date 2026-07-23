use loco_rs::{model::ModelResult, prelude::*};
use sea_orm::ActiveValue;

pub use base::models::_entities::wiki_members::{ActiveModel as WikiMemberActive, Column, Entity, Model};

pub struct WikiMemberModel;

impl WikiMemberModel {
    pub async fn list_by_wiki(
        db: &DatabaseConnection,
        wiki_id: i64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(Column::WikiId.eq(wiki_id))
            .all(db)
            .await?)
    }

    pub async fn get_member(
        db: &DatabaseConnection,
        wiki_id: i64,
        user_id: i64,
    ) -> ModelResult<Option<Model>> {
        Ok(Entity::find()
            .filter(Column::WikiId.eq(wiki_id))
            .filter(Column::UserId.eq(user_id))
            .one(db)
            .await?)
    }

    pub async fn add_member(
        db: &DatabaseConnection,
        wiki_id: i64,
        user_id: i64,
        role: i16,
        now_ms: i64,
    ) -> ModelResult<Model> {
        let m = WikiMemberActive {
            wiki_id: ActiveValue::Set(wiki_id),
            user_id: ActiveValue::Set(user_id),
            role: ActiveValue::Set(role),
            joined_at: ActiveValue::Set(now_ms),
        };
        Ok(m.insert(db).await?)
    }

    pub async fn update_role(
        db: &DatabaseConnection,
        wiki_id: i64,
        user_id: i64,
        role: i16,
    ) -> ModelResult<Model> {
        let mut model: WikiMemberActive = Entity::find()
            .filter(Column::WikiId.eq(wiki_id))
            .filter(Column::UserId.eq(user_id))
            .one(db)
            .await?
            .ok_or(loco_rs::model::ModelError::EntityNotFound)?
            .into();
        model.role = ActiveValue::Set(role);
        Ok(model.update(db).await?)
    }

    pub async fn remove_member(
        db: &DatabaseConnection,
        wiki_id: i64,
        user_id: i64,
    ) -> ModelResult<()> {
        Entity::delete_many()
            .filter(Column::WikiId.eq(wiki_id))
            .filter(Column::UserId.eq(user_id))
            .exec(db)
            .await?;
        Ok(())
    }
}
