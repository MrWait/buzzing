use loco_rs::{model::ModelResult, prelude::*};
use prost::Message;
use tracing::debug;

pub use base::models::_entities::cycleds::{ActiveModel, Column, Entity, Model};
use common::time::current_ms;
use common::{EntityStatus, EntityType, cost, id_gen, peer_pair};
use proto::idl::entity;

#[derive(Debug)]
pub struct CycledModel(pub Model);

impl CycledModel {
    pub async fn get_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Option<Model>> {
        let cycled = Entity::find_by_id(id).one(db).await?;
        Ok(cycled)
    }

    pub async fn remove(db: &DatabaseConnection, id: i64) -> ModelResult<()> {
        Entity::delete_by_id(id).exec(db).await?;
        Ok(())
    }

    pub async fn remove_by_calendar_id(db: &DatabaseConnection, calendar_id: i64) -> ModelResult<Vec<Model>> {
        let cycleds = Entity::find()
            .filter(model::query::condition().eq(Column::CalendarId, calendar_id).build())
            .all(db)
            .await?;
        Entity::delete_many()
            .filter(model::query::condition().eq(Column::CalendarId, calendar_id).build())
            .exec(db)
            .await?;
        Ok(cycleds)
    }

    pub async fn create_with_expand(
        db: &DatabaseConnection,
        template: &entity::Schedule,
        expand_start: i64,
        expand_end: i64,
    ) -> ModelResult<Model> {
        let rule = template.cycle.as_ref().ok_or(ModelError::EntityNotFound)?;
        let now = current_ms() as i64;
        let cycled = ActiveModel {
            id: ActiveValue::set(rule.id),
            calendar_id: ActiveValue::set(template.calendar_id),
            start_at: ActiveValue::set(rule.start_at),
            stop_at: ActiveValue::set(rule.stop_at),
            rule: ActiveValue::set(rule.rule.as_ref().map(|r| r.encode_to_vec()).unwrap_or_default()),
            exceptions: ActiveValue::set(rule.exception_times.clone()),
            template: ActiveValue::set(template.encode_to_vec()),
            version: ActiveValue::set(now),
            extra: ActiveValue::set(vec![]),
            expand_start: ActiveValue::set(Some(expand_start)),
            expand_end: ActiveValue::set(Some(expand_end)),
            ..Default::default()
        }
        .insert(db)
        .await?;
        Ok(cycled)
    }

    pub async fn update_template(
        db: &DatabaseConnection,
        id: i64,
        schedule: &entity::Schedule,
        version: i64,
    ) -> ModelResult<()> {
        let rule = schedule.cycle.as_ref();
        ActiveModel {
            id: ActiveValue::set(id),
            start_at: ActiveValue::set(rule.map(|r| r.start_at).unwrap_or(0)),
            stop_at: ActiveValue::set(rule.map(|r| r.stop_at).unwrap_or(0)),
            rule: ActiveValue::set(
                rule.and_then(|r| r.rule.as_ref()).map(|r| r.encode_to_vec()).unwrap_or_default(),
            ),
            exceptions: ActiveValue::set(rule.map(|r| r.exception_times.clone()).unwrap_or_default()),
            template: ActiveValue::set(schedule.encode_to_vec()),
            version: ActiveValue::set(version),
            ..Default::default()
        }
        .update(db)
        .await?;
        Ok(())
    }

    pub async fn update_expand_range(
        db: &DatabaseConnection,
        id: i64,
        expand_start: i64,
        expand_end: i64,
    ) -> ModelResult<()> {
        ActiveModel {
            id: ActiveValue::set(id),
            expand_start: ActiveValue::set(Some(expand_start)),
            expand_end: ActiveValue::set(Some(expand_end)),
            ..Default::default()
        }
        .update(db)
        .await?;
        Ok(())
    }

    pub async fn update_expand_end(
        db: &DatabaseConnection,
        id: i64,
        expand_end: i64,
    ) -> ModelResult<()> {
        ActiveModel {
            id: ActiveValue::set(id),
            expand_end: ActiveValue::set(Some(expand_end)),
            ..Default::default()
        }
        .update(db)
        .await?;
        Ok(())
    }

    pub async fn update_stop_at(
        db: &DatabaseConnection,
        id: i64,
        stop_at: i64,
    ) -> ModelResult<()> {
        ActiveModel {
            id: ActiveValue::set(id),
            stop_at: ActiveValue::set(stop_at),
            ..Default::default()
        }
        .update(db)
        .await?;
        Ok(())
    }

    pub async fn add_exception_time(
        db: &DatabaseConnection,
        id: i64,
        exception_start_time: i64,
    ) -> ModelResult<()> {
        let cycled = Self::get_by_id(db, id).await?
            .ok_or(ModelError::EntityNotFound)?;
        let mut exceptions = cycled.exceptions;
        if !exceptions.contains(&exception_start_time) {
            exceptions.push(exception_start_time);
        }
        ActiveModel {
            id: ActiveValue::set(id),
            exceptions: ActiveValue::set(exceptions),
            ..Default::default()
        }
        .update(db)
        .await?;
        Ok(())
    }

    pub async fn clear_exception_times(
        db: &DatabaseConnection,
        id: i64,
    ) -> ModelResult<()> {
        ActiveModel {
            id: ActiveValue::set(id),
            exceptions: ActiveValue::set(vec![]),
            ..Default::default()
        }
        .update(db)
        .await?;
        Ok(())
    }

    pub async fn create_split_with_expand(
        db: &DatabaseConnection,
        new_id: i64,
        _old_id: i64,
        template: &entity::Schedule,
        start_at: i64,
        expand_end: i64,
        version: i64,
    ) -> ModelResult<Model> {
        let rule = template.cycle.as_ref();
        let cycled = ActiveModel {
            id: ActiveValue::set(new_id),
            calendar_id: ActiveValue::set(template.calendar_id),
            start_at: ActiveValue::set(start_at),
            stop_at: ActiveValue::set(rule.map(|r| r.stop_at).unwrap_or(0)),
            rule: ActiveValue::set(
                rule.and_then(|r| r.rule.as_ref()).map(|r| r.encode_to_vec()).unwrap_or_default(),
            ),
            exceptions: ActiveValue::set(vec![]),
            template: ActiveValue::set(template.encode_to_vec()),
            version: ActiveValue::set(version),
            extra: ActiveValue::set(vec![]),
            expand_start: ActiveValue::set(Some(start_at)),
            expand_end: ActiveValue::set(Some(expand_end)),
            ..Default::default()
        }
        .insert(db)
        .await?;
        Ok(cycled)
    }

    pub async fn find_active_by_calendar_ids(
        db: &DatabaseConnection,
        calendar_ids: Vec<i64>,
    ) -> ModelResult<Vec<Model>> {
        let cycleds = Entity::find()
            .filter(model::query::condition().is_in(Column::CalendarId, calendar_ids).build())
            .all(db)
            .await?;
        Ok(cycleds)
    }

    pub async fn find_cycleds_expand_end_before(
        db: &DatabaseConnection,
        end_before: i64,
    ) -> ModelResult<Vec<Model>> {
        let cycleds = Entity::find()
            .filter(
                model::query::condition()
                    .lt(Column::ExpandEnd, end_before)
                    .build(),
            )
            .all(db)
            .await?;
        Ok(cycleds)
    }

    pub fn template_as_schedule(&self) -> entity::Schedule {
        entity::Schedule::decode(self.0.template.as_slice()).unwrap_or_default()
    }
}
