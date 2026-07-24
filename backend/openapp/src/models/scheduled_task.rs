use sea_orm::{ColumnTrait, EntityTrait, QueryFilter, QueryOrder};
use loco_rs::prelude::*;

use common::id_gen;

pub use base::models::_entities::open_app_scheduled_tasks::{
    ActiveModel, Column, Entity, Model,
};

#[derive(Debug)]
pub struct ScheduledTaskModel(pub Model);

impl ScheduledTaskModel {
    pub async fn create(
        db: &DatabaseConnection,
        app_id: i64,
        name: &str,
        cron_expr: &str,
        action_type: &str,
        action_config: serde_json::Value,
        chat_id: Option<i64>,
    ) -> ModelResult<Self> {
        let model = ActiveModel {
            id: ActiveValue::set(id_gen(Some(false))),
            app_id: ActiveValue::set(app_id),
            name: ActiveValue::set(name.to_string()),
            cron_expr: ActiveValue::set(cron_expr.to_string()),
            action_type: ActiveValue::set(action_type.to_string()),
            action_config: ActiveValue::set(action_config),
            chat_id: ActiveValue::set(chat_id),
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
            .order_by_desc(Column::Id)
            .all(db)
            .await?;
        Ok(items.into_iter().map(Self).collect())
    }

    pub async fn find_enabled(db: &DatabaseConnection) -> ModelResult<Vec<Self>> {
        let items = Entity::find()
            .filter(Column::Status.eq(1i16))
            .all(db)
            .await?;
        Ok(items.into_iter().map(Self).collect())
    }

    pub async fn update(
        db: &DatabaseConnection,
        id: i64,
        name: Option<&str>,
        cron_expr: Option<&str>,
        action_config: Option<serde_json::Value>,
        status: Option<i16>,
    ) -> ModelResult<Option<Self>> {
        let m = Entity::find_by_id(id).one(db).await?;
        let Some(m) = m else { return Ok(None) };
        let mut active: ActiveModel = m.into();
        if let Some(v) = name { active.name = ActiveValue::set(v.to_string()); }
        if let Some(v) = cron_expr { active.cron_expr = ActiveValue::set(v.to_string()); }
        if let Some(v) = action_config {
            active.action_config = ActiveValue::set(v);
        }
        if let Some(v) = status { active.status = ActiveValue::set(v); }
        let model = active.update(db).await?;
        Ok(Some(Self(model)))
    }

    pub async fn update_next_run(
        db: &DatabaseConnection,
        id: i64,
        last_run_at: chrono::DateTime<chrono::FixedOffset>,
        next_run_at: Option<chrono::DateTime<chrono::FixedOffset>>,
    ) -> ModelResult<()> {
        let m = Entity::find_by_id(id).one(db).await?;
        let Some(m) = m else { return Ok(()) };
        let mut active: ActiveModel = m.into();
        active.last_run_at = ActiveValue::set(Some(last_run_at));
        active.next_run_at = ActiveValue::set(next_run_at);
        active.update(db).await?;
        Ok(())
    }

    pub async fn delete(db: &DatabaseConnection, id: i64) -> ModelResult<bool> {
        let r = Entity::delete_by_id(id).exec(db).await?;
        Ok(r.rows_affected > 0)
    }

    pub async fn set_status(db: &DatabaseConnection, id: i64, status: i16) -> ModelResult<Option<Self>> {
        Self::update(db, id, None, None, None, Some(status)).await
    }

    pub fn to_json(&self) -> serde_json::Value {
        serde_json::json!({
            "id": self.0.id,
            "app_id": self.0.app_id,
            "name": self.0.name,
            "cron_expr": self.0.cron_expr,
            "action_type": self.0.action_type,
            "action_config": self.0.action_config,
            "chat_id": self.0.chat_id,
            "status": self.0.status,
            "last_run_at": self.0.last_run_at,
            "next_run_at": self.0.next_run_at,
            "created_at": self.0.created_at,
            "updated_at": self.0.updated_at,
        })
    }
}
