use sea_orm::{ColumnTrait, EntityTrait, QueryFilter};
use loco_rs::prelude::*;

use common::id_gen;

pub use base::models::_entities::open_app_outgoing_webhooks::{
    ActiveModel, Column, Entity, Model,
};

#[derive(Debug)]
pub struct OutgoingWebhookModel(pub Model);

impl OutgoingWebhookModel {
    pub async fn create(
        db: &DatabaseConnection,
        app_id: i64,
        chat_id: i64,
        name: &str,
        command: &str,
        webhook_url: &str,
        webhook_secret: &str,
    ) -> ModelResult<Self> {
        let model = ActiveModel {
            id: ActiveValue::set(id_gen(Some(false))),
            app_id: ActiveValue::set(app_id),
            chat_id: ActiveValue::set(chat_id),
            name: ActiveValue::set(name.to_string()),
            command: ActiveValue::set(command.to_string()),
            webhook_url: ActiveValue::set(webhook_url.to_string()),
            webhook_secret: ActiveValue::set(webhook_secret.to_string()),
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

    pub async fn find_by_app(
        db: &DatabaseConnection,
        app_id: i64,
    ) -> ModelResult<Vec<Self>> {
        let items = Entity::find()
            .filter(Column::AppId.eq(app_id))
            .all(db)
            .await?;
        Ok(items.into_iter().map(Self).collect())
    }

    pub async fn find_by_chat(
        db: &DatabaseConnection,
        chat_id: i64,
    ) -> ModelResult<Vec<Self>> {
        let items = Entity::find()
            .filter(Column::ChatId.eq(chat_id))
            .filter(Column::Status.eq(1i16))
            .all(db)
            .await?;
        Ok(items.into_iter().map(Self).collect())
    }

    pub async fn update(
        db: &DatabaseConnection,
        id: i64,
        name: Option<&str>,
        command: Option<&str>,
        webhook_url: Option<&str>,
        status: Option<i16>,
    ) -> ModelResult<Option<Self>> {
        let m = Entity::find_by_id(id).one(db).await?;
        let Some(m) = m else { return Ok(None) };
        let mut active: ActiveModel = m.into();
        if let Some(v) = name { active.name = ActiveValue::set(v.to_string()); }
        if let Some(v) = command { active.command = ActiveValue::set(v.to_string()); }
        if let Some(v) = webhook_url { active.webhook_url = ActiveValue::set(v.to_string()); }
        if let Some(v) = status { active.status = ActiveValue::set(v); }
        let model = active.update(db).await?;
        Ok(Some(Self(model)))
    }

    pub async fn delete(db: &DatabaseConnection, id: i64) -> ModelResult<bool> {
        let r = Entity::delete_by_id(id).exec(db).await?;
        Ok(r.rows_affected > 0)
    }

    pub fn to_json(&self) -> serde_json::Value {
        serde_json::json!({
            "id": self.0.id,
            "app_id": self.0.app_id,
            "chat_id": self.0.chat_id,
            "name": self.0.name,
            "command": self.0.command,
            "webhook_url": self.0.webhook_url,
            "status": self.0.status,
            "created_at": self.0.created_at,
        })
    }
}
