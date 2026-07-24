use sea_orm::{ColumnTrait, DatabaseConnection, EntityTrait, QueryFilter, ActiveValue};
use loco_rs::prelude::*;

use crate::services::auth;
use common::EntityStatus;

pub use base::models::_entities::open_app_bots::{ActiveModel, Column, Entity, Model};

#[derive(Debug)]
pub struct OpenAppBotModel(pub Model);

impl OpenAppBotModel {
    /// 创建 Bot 配置（在创建应用时调用）
    pub async fn create_for_app(
        db: &DatabaseConnection,
        app_id: i64,
        bot_user_id: i64,
    ) -> ModelResult<Self> {
        let model = ActiveModel {
            id: ActiveValue::set(common::id_gen(Some(false))),
            app_id: ActiveValue::set(app_id),
            bot_user_id: ActiveValue::set(bot_user_id),
            webhook_url: ActiveValue::set("".to_string()),
            webhook_secret: ActiveValue::set(auth::generate_app_secret()),
            event_types: ActiveValue::set(vec![]),
            status: ActiveValue::set(EntityStatus::Normal as i16),
            ..Default::default()
        }
        .insert(db)
        .await?;
        Ok(Self(model))
    }

    pub async fn find_by_app(db: &DatabaseConnection, app_id: i64) -> ModelResult<Option<Self>> {
        let bot = Entity::find()
            .filter(Column::AppId.eq(app_id))
            .one(db)
            .await?;
        Ok(bot.map(Self))
    }

    pub async fn update_webhook(
        db: &DatabaseConnection,
        app_id: i64,
        webhook_url: &str,
        event_types: &[String],
    ) -> ModelResult<Option<Self>> {
        let bot = Self::find_by_app(db, app_id).await?;
        let Some(bot) = bot else {
            return Ok(None);
        };
        let mut active: ActiveModel = bot.0.into();
        active.webhook_url = ActiveValue::set(webhook_url.to_string());
        active.event_types = ActiveValue::set(event_types.to_vec());
        let model = active.update(db).await?;
        Ok(Some(Self(model)))
    }

    pub async fn delete_by_app(db: &DatabaseConnection, app_id: i64) -> ModelResult<()> {
        Entity::delete_many()
            .filter(Column::AppId.eq(app_id))
            .exec(db)
            .await?;
        Ok(())
    }

    pub fn to_json(&self) -> serde_json::Value {
        serde_json::json!({
            "id": self.0.id,
            "app_id": self.0.app_id,
            "bot_user_id": self.0.bot_user_id,
            "webhook_url": self.0.webhook_url,
            "webhook_secret": self.0.webhook_secret,
            "event_types": self.0.event_types,
            "status": self.0.status,
            "created_at": self.0.created_at,
        })
    }
}
