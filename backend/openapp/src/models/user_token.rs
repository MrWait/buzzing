use sea_orm::{ColumnTrait, EntityTrait, QueryFilter};
use loco_rs::prelude::*;

use common::id_gen;

pub use base::models::_entities::open_app_user_tokens::{
    ActiveModel, Column, Entity, Model,
};

#[derive(Debug)]
pub struct UserTokenModel(pub Model);

impl UserTokenModel {
    pub async fn create(
        db: &DatabaseConnection,
        authorization_id: i64,
        access_token: &str,
        refresh_token: &str,
        scopes: Vec<String>,
        access_expire_at: chrono::DateTime<chrono::FixedOffset>,
        refresh_expire_at: chrono::DateTime<chrono::FixedOffset>,
    ) -> ModelResult<Self> {
        let model = ActiveModel {
            id: ActiveValue::set(id_gen(Some(false))),
            authorization_id: ActiveValue::set(authorization_id),
            access_token: ActiveValue::set(access_token.to_string()),
            refresh_token: ActiveValue::set(refresh_token.to_string()),
            scopes: ActiveValue::set(scopes),
            access_expire_at: ActiveValue::set(access_expire_at),
            refresh_expire_at: ActiveValue::set(refresh_expire_at),
            ..Default::default()
        }
        .insert(db)
        .await?;
        Ok(Self(model))
    }

    pub async fn find_by_access_token(
        db: &DatabaseConnection,
        access_token: &str,
    ) -> ModelResult<Option<Self>> {
        let m = Entity::find()
            .filter(Column::AccessToken.eq(access_token))
            .one(db)
            .await?;
        Ok(m.map(Self))
    }

    pub async fn find_by_refresh_token(
        db: &DatabaseConnection,
        refresh_token: &str,
    ) -> ModelResult<Option<Self>> {
        let m = Entity::find()
            .filter(Column::RefreshToken.eq(refresh_token))
            .one(db)
            .await?;
        Ok(m.map(Self))
    }

    pub async fn invalidate_by_authorization(
        db: &DatabaseConnection,
        authorization_id: i64,
    ) -> ModelResult<()> {
        Entity::delete_many()
            .filter(Column::AuthorizationId.eq(authorization_id))
            .exec(db)
            .await?;
        Ok(())
    }

    pub async fn set_refresh_token(
        db: &DatabaseConnection,
        id: i64,
        new_refresh_token: &str,
        new_refresh_expire: chrono::DateTime<chrono::FixedOffset>,
        new_access_token: &str,
        new_access_expire: chrono::DateTime<chrono::FixedOffset>,
    ) -> ModelResult<()> {
        let m = Entity::find_by_id(id).one(db).await?;
        let Some(m) = m else { return Ok(()) };
        let mut active: ActiveModel = m.into();
        active.refresh_token = ActiveValue::set(new_refresh_token.to_string());
        active.refresh_expire_at = ActiveValue::set(new_refresh_expire);
        active.access_token = ActiveValue::set(new_access_token.to_string());
        active.access_expire_at = ActiveValue::set(new_access_expire);
        active.update(db).await?;
        Ok(())
    }
}
