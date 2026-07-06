use loco_rs::{model::ModelResult, prelude::*};
use prost::Message as _;
use sea_orm::{QueryTrait, Statement};
use sea_query::extension::postgres::PgExpr;
use sea_query::{Expr, Query};
use std::any::Any;
use std::collections::HashMap;
use tracing::debug;

pub use base::models::_entities::calendars::{ActiveModel, Column, Entity, Model};
use common::time::current_ms;
use common::{EntityStatus, EntityType, cost, id_gen, peer_pair};
use proto::idl::entity;

#[derive(Debug)]
pub struct CalendarModel(pub Model);
type Subscribers = HashMap<i64, entity::calendar::Subscriber>;

impl CalendarModel {
    pub async fn get_by_ids(db: &DatabaseConnection, ids: Vec<i64>) -> ModelResult<Vec<Model>> {
        let calendars = Entity::find()
            .filter(model::query::condition().is_in(Column::Id, ids).build())
            .all(db)
            .await?;
        Ok(calendars)
    }

    pub async fn get_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Option<Model>> {
        let calendars = Entity::find()
            .filter(model::query::condition().eq(Column::Id, id).build())
            .one(db)
            .await?;
        Ok(calendars)
    }

    pub async fn get_by_user_id(db: &DatabaseConnection, user_id: i64) -> ModelResult<Vec<Model>> {
        let query = Entity::find()
            .filter(Expr::col(Column::Subscriber).contains(user_id.to_string()))
            .build(sea_orm::DatabaseBackend::Postgres)
            .to_string();
        debug!("get by user id, query; {query:?}");
        // let calendars = Entity::find()
        //     .filter(Expr::col(Column::Subscriber).contains(user_id.to_string()))
        //     .all(db)
        //     .await?;
        // let calendars = Entity::find()
        //     .from_raw_sql(Statement::from_sql_and_values(
        //         sea_orm::DatabaseBackend::Postgres,
        //         format!(
        //             r#"SELECT * from "calendars" WHERE "subscriber" ? '{}'"#,
        //             user_id.to_string()
        //         ),
        //         [],
        //     ))
        //     .into_model::<Model>()
        //     .all(db)
        //     .await?;
        let calendars = Entity::find()
            .filter(Expr::cust_with_values(
                "subscriber ? $1",
                [user_id.to_string()],
            ))
            .all(db)
            .await?;
        Ok(calendars)
    }

    pub async fn create(db: &DatabaseConnection, src: &entity::Calendar) -> ModelResult<Model> {
        let default_sub = Subscribers::default();
        let subscriber = src
            .subscribers
            .as_ref()
            .map(|s| &s.subscribers)
            .unwrap_or(&default_sub);
        debug!("create calendar, subscriber: {subscriber:?}");
        let calendar = ActiveModel {
            id: ActiveValue::set(src.id),
            creator: ActiveValue::set(src.creater),
            tenant_id: ActiveValue::set(src.tenant_id),
            public: ActiveValue::set(src.public),
            is_defalut: ActiveValue::set(src.is_default),
            enable: ActiveValue::set(src.enable),
            color: ActiveValue::set(src.color),
            name: ActiveValue::set(Some(src.name.clone())),
            desc: ActiveValue::set(Some(src.desc.clone())),
            version: ActiveValue::set(src.version),
            subscriber: ActiveValue::set(
                serde_json::to_value(subscriber).map_err(|_| ModelError::EntityNotFound)?,
            ),
            extra: ActiveValue::set(vec![]),
            ..Default::default()
        }
        .insert(db)
        .await?;
        Ok(calendar)
    }

    pub async fn update(
        db: &DatabaseConnection,
        model: &Model,
        subscribers: &entity::CalendarSubscribers,
    ) -> ModelResult<()> {
        ActiveModel {
            id: ActiveValue::set(model.id),
            name: ActiveValue::set(model.name.clone()),
            desc: ActiveValue::set(model.desc.clone()),
            color: ActiveValue::set(model.color),
            public: ActiveValue::set(model.public),
            enable: ActiveValue::set(model.enable),
            subscriber: ActiveValue::set(
                serde_json::to_value(&subscribers.subscribers)
                    .map_err(|_| ModelError::EntityNotFound)?,
            ),
            version: ActiveValue::set(model.version),
            ..Default::default()
        }
        .update(db)
        .await?;
        Ok(())
    }

    pub async fn update_subscribers(
        db: &DatabaseConnection,
        id: i64,
        subscribers: &entity::CalendarSubscribers,
    ) -> ModelResult<()> {
        ActiveModel {
            id: ActiveValue::set(id),
            subscriber: ActiveValue::set(
                serde_json::to_value(&subscribers.subscribers)
                    .map_err(|_| ModelError::EntityNotFound)?,
            ),
            ..Default::default()
        }
        .update(db)
        .await?;
        Ok(())
    }

    pub async fn delete(db: &DatabaseConnection, id: i64) -> ModelResult<()> {
        let _ = Entity::delete_by_id(id).exec(db).await?;
        Ok(())
    }

    pub async fn search(
        db: &DatabaseConnection,
        key: &str,
        tenant_id: i64,
        limit_val: u64,
        offset_val: u64,
    ) -> ModelResult<Vec<Model>> {
        let all = Entity::find()
            .filter(model::query::condition()
                .contains(Column::Name, key)
                .eq(Column::TenantId, tenant_id)
                .build())
            .all(db)
            .await?;
        let calendars: Vec<Model> = all
            .into_iter()
            .skip(offset_val as usize)
            .take(limit_val as usize)
            .collect();
        Ok(calendars)
    }
}

impl Into<entity::Calendar> for CalendarModel {
    fn into(self) -> entity::Calendar {
        let cal = self.0;
        let subscribers = serde_json::from_value::<Subscribers>(cal.subscriber).unwrap_or_default();
        entity::Calendar {
            id: cal.id,
            creater: cal.creator,
            tenant_id: cal.tenant_id,
            version: cal.version,
            color: cal.color,
            name: cal.name.unwrap_or_default(),
            desc: cal.desc.unwrap_or_default(),
            is_default: cal.is_defalut,
            public: cal.public,
            enable: cal.enable,
            subscribers: Some(entity::CalendarSubscribers { subscribers }),
        }
    }
}
