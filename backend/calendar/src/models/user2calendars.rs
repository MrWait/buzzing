use std::collections::HashMap;

use loco_rs::{model::ModelResult, prelude::*};
use tracing::debug;

pub use base::models::_entities::user2_calendars::{ActiveModel, Column, Entity, Model};
use common::time::current_ms;
use proto::idl::entity;

#[derive(Debug)]
pub struct User2CalendarModel(pub Model);

impl User2CalendarModel {
    pub async fn get_by_user_id(
        db: &DatabaseConnection,
        user_id: i64,
    ) -> ModelResult<Vec<Model>> {
        let rows = Entity::find()
            .filter(model::query::condition().eq(Column::UserId, user_id).build())
            .all(db)
            .await?;
        Ok(rows)
    }

    pub async fn get_by_calendar_id(
        db: &DatabaseConnection,
        calendar_id: i64,
    ) -> ModelResult<Vec<Model>> {
        let rows = Entity::find()
            .filter(model::query::condition().eq(Column::CalendarId, calendar_id).build())
            .all(db)
            .await?;
        Ok(rows)
    }

    pub async fn upsert_subscriber(
        db: &DatabaseConnection,
        user_id: i64,
        calendar_id: i64,
        color: i32,
        role: i32,
    ) -> ModelResult<()> {
        let now = current_ms() as i64;
        ActiveModel {
            user_id: ActiveValue::set(user_id),
            calendar_id: ActiveValue::set(calendar_id),
            color: ActiveValue::set(color),
            role: ActiveValue::set(role),
            subscribe_time: ActiveValue::set(now),
        }
        .insert(db)
        .await?;
        Ok(())
    }

    pub async fn remove_subscriber(
        db: &DatabaseConnection,
        user_id: i64,
        calendar_id: i64,
    ) -> ModelResult<()> {
        Entity::delete_many()
            .filter(model::query::condition().eq(Column::UserId, user_id).build())
            .filter(model::query::condition().eq(Column::CalendarId, calendar_id).build())
            .exec(db)
            .await?;
        Ok(())
    }

    pub async fn find_subscribers(
        db: &DatabaseConnection,
        calendar_id: i64,
    ) -> ModelResult<HashMap<i64, entity::calendar::Subscriber>> {
        let rows = Self::get_by_calendar_id(db, calendar_id).await?;
        let mut map = HashMap::new();
        for row in rows {
            map.insert(
                row.user_id,
                entity::calendar::Subscriber {
                    id: row.user_id,
                    subscribe_time: row.subscribe_time,
                    role: row.role,
                    color: row.color,
                },
            );
        }
        Ok(map)
    }

    pub async fn find_role(
        db: &DatabaseConnection,
        user_id: i64,
        calendar_id: i64,
    ) -> ModelResult<i32> {
        let row = Entity::find()
            .filter(model::query::condition().eq(Column::UserId, user_id).build())
            .filter(model::query::condition().eq(Column::CalendarId, calendar_id).build())
            .one(db)
            .await?;
        Ok(row.map(|r| r.role).unwrap_or(0))
    }

    pub async fn calendar_remove_for_users(
        db: &DatabaseConnection,
        user_ids: Vec<i64>,
        calendar_id: i64,
    ) -> ModelResult<()> {
        Entity::delete_many()
            .filter(model::query::condition().is_in(Column::UserId, user_ids).build())
            .filter(model::query::condition().eq(Column::CalendarId, calendar_id).build())
            .exec(db)
            .await?;
        Ok(())
    }
}
