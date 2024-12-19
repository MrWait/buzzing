use std::collections::HashMap;

use loco_rs::{model::ModelResult, prelude::*};
use prost::Message as _;
use sea_orm::Statement;
use tracing::debug;

pub use base::models::_entities::user2_calendars::{ActiveModel, Column, Entity, Model};
use common::time::{current_ms, date_time};
use common::{EntityStatus, EntityType, cost, id_gen, peer_pair};
use proto::idl::entity;

pub type User2CalendarEntry = HashMap<i64, entity::calendar::Subscriber>;
pub type User2ScheduleEntry = HashMap<i32, Vec<i64>>;
pub struct User2CalendarList {
    pub id: i64,
    pub version: i64,
    pub calendars: User2CalendarEntry,
    pub schedules: User2ScheduleEntry,
}

#[derive(Debug)]
pub struct User2CalendarModel(pub Model);

impl User2CalendarModel {
    pub async fn get_by_ids(
        db: &DatabaseConnection,
        ids: Vec<i64>,
    ) -> ModelResult<Vec<User2CalendarList>> {
        let mut user2calendars = Entity::find()
            .filter(model::query::condition().is_in(Column::UserId, ids).build())
            .all(db)
            .await?;

        Ok(user2calendars.drain(..).map(|m| m.into()).collect())
    }

    pub async fn get_by_user_id(
        db: &DatabaseConnection,
        id: i64,
    ) -> ModelResult<Option<User2CalendarList>> {
        let user2calendar = Entity::find()
            .filter(model::query::condition().eq(Column::UserId, id).build())
            .one(db)
            .await?;
        Ok(user2calendar.map(|m| m.into()))
    }

    pub async fn calendar_add_for_users(
        db: &DatabaseConnection,
        user_ids: Vec<i64>,
        calendar_id: i64,
        time: i64,
    ) -> ModelResult<()> {
        let result = db.execute(Statement::from_string(
            sea_orm::DatabaseBackend::Postgres,
            "UPDATE `` SET ``;",
        ));
        Ok(())
    }

    pub async fn calendar_remove_for_users(
        db: &DatabaseConnection,
        user_ids: Vec<i64>,
        calendar_id: i64,
    ) -> ModelResult<()> {
        Ok(())
    }

    pub async fn schedule_add_for_users() {}

    pub async fn schedule_remove_for_users() {}
}

impl From<Model> for User2CalendarList {
    fn from(value: Model) -> Self {
        let calendars =
            serde_json::from_value::<User2CalendarEntry>(value.calendars).unwrap_or(HashMap::new());
        let schedules =
            serde_json::from_value::<User2ScheduleEntry>(value.schedules).unwrap_or(HashMap::new());

        Self {
            id: value.user_id,
            calendars,
            schedules,
            version: value.version,
        }
    }
}

impl Into<Model> for User2CalendarList {
    fn into(self) -> Model {
        Model {
            user_id: self.id,
            version: self.version,
            schedules: serde_json::to_value(&self.schedules).unwrap_or_default(),
            calendars: serde_json::to_value(&self.calendars).unwrap_or_default(),
            created_at: DateTimeWithTimeZone::default(),
            updated_at: DateTimeWithTimeZone::default(),
        }
    }
}
