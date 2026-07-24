use sea_orm::{ColumnTrait, EntityTrait, QueryFilter};
use loco_rs::prelude::*;

use common::id_gen;

pub use base::models::_entities::open_app_authorizations::{
    ActiveModel, Column, Entity, Model,
};

#[derive(Debug)]
pub struct AuthorizationModel(pub Model);

impl AuthorizationModel {
    pub async fn create(
        db: &DatabaseConnection,
        app_id: i64,
        user_id: i64,
        tenant_id: i64,
        scopes: Vec<String>,
    ) -> ModelResult<Self> {
        let model = ActiveModel {
            id: ActiveValue::set(id_gen(Some(false))),
            app_id: ActiveValue::set(app_id),
            user_id: ActiveValue::set(user_id),
            tenant_id: ActiveValue::set(tenant_id),
            scopes: ActiveValue::set(scopes),
            status: ActiveValue::set(1i16),
            ..Default::default()
        }
        .insert(db)
        .await?;
        Ok(Self(model))
    }

    pub async fn find_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Option<Self>> {
        let m = Entity::find_by_id(id).one(db).await?;
        Ok(m.map(Self))
    }

    pub async fn find_by_app_user(
        db: &DatabaseConnection,
        app_id: i64,
        user_id: i64,
    ) -> ModelResult<Option<Self>> {
        let m = Entity::find()
            .filter(Column::AppId.eq(app_id))
            .filter(Column::UserId.eq(user_id))
            .filter(Column::Status.eq(1i16))
            .one(db)
            .await?;
        Ok(m.map(Self))
    }

    pub async fn revoke(db: &DatabaseConnection, id: i64) -> ModelResult<bool> {
        let m = Entity::find_by_id(id).one(db).await?;
        let Some(m) = m else {
            return Ok(false);
        };
        let mut active: ActiveModel = m.into();
        active.status = ActiveValue::set(0i16);
        active.update(db).await?;
        Ok(true)
    }

    pub fn to_json(&self) -> serde_json::Value {
        serde_json::json!({
            "id": self.0.id,
            "app_id": self.0.app_id,
            "user_id": self.0.user_id,
            "tenant_id": self.0.tenant_id,
            "scopes": self.0.scopes,
            "status": self.0.status,
            "created_at": self.0.created_at,
            "updated_at": self.0.updated_at,
        })
    }
}
