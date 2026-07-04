use loco_rs::{model::ModelResult, prelude::*};
use prost::Message;
use sea_query::Expr;
use tracing::debug;

pub use base::models::_entities::schedules::{ActiveModel, Column, Entity, Model};
use common::time::current_ms;
use common::{EntityStatus, EntityType, cost, id_gen, peer_pair};
use proto::idl::{calendar, entity};

#[derive(Debug)]
pub struct ScheduleModel(pub Model);

#[derive(prost::Message)]
pub(crate) struct ScheduleExtra {
    #[prost(int64, tag = "1")]
    pub room_id: i64,
    #[prost(int64, tag = "2")]
    pub summary_doc_id: i64,
    #[prost(int64, tag = "3")]
    pub chat_id: i64,
    #[prost(bool, tag = "4")]
    pub member_view_list: bool,
    #[prost(bool, tag = "5")]
    pub member_invite_other: bool,
    #[prost(bool, tag = "6")]
    pub member_alter_schedule: bool,
    #[prost(bool, tag = "7")]
    pub member_create_summary: bool,
    #[prost(bool, tag = "8")]
    pub member_create_meeting: bool,
    #[prost(bool, tag = "9")]
    pub need_checkin: bool,
    #[prost(int32, tag = "10")]
    pub color: i32,
    #[prost(string, tag = "11")]
    pub archive: String,
    #[prost(string, tag = "12")]
    pub location: String,
    #[prost(int32, repeated, tag = "13")]
    pub notify_time: Vec<i32>,
    #[prost(string, tag = "14")]
    pub desc: String,
    #[prost(message, optional, tag = "15")]
    pub cycle_rule: Option<entity::ScheduleCycleRule>,
}

impl ScheduleModel {
    pub async fn create(
        db: &DatabaseConnection,
        src: &[entity::Schedule],
    ) -> ModelResult<Vec<Model>> {
        let models: Vec<ActiveModel> = src
            .iter()
            .map(|s| {
                let extra = ScheduleExtra {
                    room_id: s.room_id,
                    summary_doc_id: s.summary_doc_id,
                    chat_id: s.chat_id,
                    member_alter_schedule: s.member_alter_schedule,
                    member_create_meeting: s.member_create_meeting,
                    member_create_summary: s.member_create_summary,
                    member_invite_other: s.member_invite_other,
                    member_view_list: s.member_view_list,
                    need_checkin: s.need_checkin,
                    color: s.color,
                    archive: s.archive.clone(),
                    location: s.location.clone(),
                    notify_time: s.notify_time.clone(),
                    desc: s.desc.clone(),
                    ..Default::default()
                };
                ActiveModel {
                    id: ActiveValue::set(s.id),
                    calendar_id: ActiveValue::set(s.calendar_id),
                    r#type: ActiveValue::set(s.r#type),
                    tenant_id: ActiveValue::set(s.tenant_id),
                    owner: ActiveValue::set(s.owner),
                    version: ActiveValue::set(s.version),
                    extra: ActiveValue::set(extra.encode_to_vec()),
                    title: ActiveValue::set(s.title.clone()),
                    exception: ActiveValue::set(s.exception),
                    full_day: ActiveValue::set(s.full_day),
                    show_as_idle: ActiveValue::set(s.show_as_idle),
                    public_permission: ActiveValue::set(s.public_permision),
                    start_time: ActiveValue::set(s.start_time),
                    end_time: ActiveValue::set(s.end_time),
                    member_count: ActiveValue::set(s.member_count),
                    member_ids: ActiveValue::set(s.member_ids.clone()),
                    cycle_rule_id: ActiveValue::set(0),
                    cycle_end_time: ActiveValue::set(0),
                    ..Default::default()
                }
            })
            .collect();
        let txn = db.begin().await?;
        let schedules = Entity::insert_many(models)
            .exec_with_returning_many(&txn)
            .await?;
        txn.commit().await?;
        Ok(schedules)
    }

    pub async fn remove(db: &DatabaseConnection, id: i64) -> ModelResult<Model> {
        let schedule = Entity::find_by_id(id).one(db).await?
            .ok_or(ModelError::EntityNotFound)?;
        Entity::delete_by_id(id).exec(db).await?;
        Ok(schedule)
    }

    pub async fn get_by_ids(db: &DatabaseConnection, ids: Vec<i64>) -> ModelResult<Vec<Model>> {
        let schedules = Entity::find()
            .filter(model::query::condition().is_in(Column::Id, ids).build())
            .all(db)
            .await?;
        Ok(schedules)
    }

    pub async fn get_by_cycle_id(db: &DatabaseConnection, id: i64) -> ModelResult<Vec<Model>> {
        let schedules = Entity::find()
            .filter(model::query::condition().eq(Column::CycleRuleId, id).build())
            .all(db)
            .await?;
        Ok(schedules)
    }

    pub async fn remove_by_cycle_id(db: &DatabaseConnection, id: i64) -> ModelResult<Vec<Model>> {
        let schedules = Self::get_by_cycle_id(db, id).await?;
        Entity::delete_many()
            .filter(model::query::condition().eq(Column::CycleRuleId, id).build())
            .exec(db)
            .await?;
        Ok(schedules)
    }

    pub async fn remove_by_calendar_id(db: &DatabaseConnection, id: i64) -> ModelResult<Vec<Model>> {
        let schedules = Entity::find()
            .filter(model::query::condition().eq(Column::CalendarId, id).build())
            .all(db)
            .await?;
        Entity::delete_many()
            .filter(model::query::condition().eq(Column::CalendarId, id).build())
            .exec(db)
            .await?;
        Ok(schedules)
    }

    pub async fn find_by_user_ids(
        db: &DatabaseConnection,
        user_ids: Vec<i64>,
        start_time: i64,
        end_time: i64,
    ) -> ModelResult<Vec<Model>> {
        let schedules = Entity::find()
            .filter(Column::StartTime.lt(end_time))
            .filter(Column::EndTime.gt(start_time))
            .all(db)
            .await?;
        Ok(schedules
            .into_iter()
            .filter(|s| s.member_ids.iter().any(|uid| user_ids.contains(uid)))
            .collect())
    }

    pub async fn find_by_calendar_ids(
        db: &DatabaseConnection,
        calendar_ids: Vec<i64>,
        start_time: i64,
        end_time: i64,
    ) -> ModelResult<Vec<Model>> {
        let schedules = Entity::find()
            .filter(model::query::condition().is_in(Column::CalendarId, calendar_ids).build())
            .filter(model::query::condition().gte(Column::EndTime, start_time).build())
            .filter(model::query::condition().lte(Column::StartTime, end_time).build())
            .all(db)
            .await?;
        Ok(schedules)
    }

    pub async fn update(
        db: &DatabaseConnection,
        id: i64,
        src: &entity::Schedule,
    ) -> ModelResult<Model> {
        let extra = ScheduleExtra {
            room_id: src.room_id,
            summary_doc_id: src.summary_doc_id,
            chat_id: src.chat_id,
            member_alter_schedule: src.member_alter_schedule,
            member_create_meeting: src.member_create_meeting,
            member_create_summary: src.member_create_summary,
            member_invite_other: src.member_invite_other,
            member_view_list: src.member_view_list,
            need_checkin: src.need_checkin,
            color: src.color,
            archive: src.archive.clone(),
            location: src.location.clone(),
            notify_time: src.notify_time.clone(),
            desc: src.desc.clone(),
            ..Default::default()
        };
        let schedule = ActiveModel {
            id: ActiveValue::set(id),
            calendar_id: ActiveValue::set(src.calendar_id),
            r#type: ActiveValue::set(src.r#type),
            version: ActiveValue::set(src.version),
            extra: ActiveValue::set(extra.encode_to_vec()),
            title: ActiveValue::set(src.title.clone()),
            exception: ActiveValue::set(src.exception),
            full_day: ActiveValue::set(src.full_day),
            show_as_idle: ActiveValue::set(src.show_as_idle),
            public_permission: ActiveValue::set(src.public_permision),
            start_time: ActiveValue::set(src.start_time),
            end_time: ActiveValue::set(src.end_time),
            member_count: ActiveValue::set(src.member_count),
            member_ids: ActiveValue::set(src.member_ids.clone()),
            ..Default::default()
        }
        .update(db)
        .await?;
        Ok(schedule)
    }

    pub async fn update_by_cycle_rule_id(
        db: &DatabaseConnection,
        cycle_rule_id: i64,
        src: &entity::Schedule,
    ) -> ModelResult<()> {
        let now = src.version;
        let extra = ScheduleExtra {
            room_id: src.room_id,
            summary_doc_id: src.summary_doc_id,
            chat_id: src.chat_id,
            member_alter_schedule: src.member_alter_schedule,
            member_create_meeting: src.member_create_meeting,
            member_create_summary: src.member_create_summary,
            member_invite_other: src.member_invite_other,
            member_view_list: src.member_view_list,
            need_checkin: src.need_checkin,
            color: src.color,
            archive: src.archive.clone(),
            location: src.location.clone(),
            notify_time: src.notify_time.clone(),
            desc: src.desc.clone(),
            ..Default::default()
        };
        Entity::update_many()
            .col_expr(Column::Version, Expr::value(now))
            .col_expr(Column::Extra, Expr::value(extra.encode_to_vec()))
            .col_expr(Column::Title, Expr::value(src.title.clone()))
            .col_expr(Column::FullDay, Expr::value(src.full_day))
            .col_expr(Column::ShowAsIdle, Expr::value(src.show_as_idle))
            .col_expr(Column::PublicPermission, Expr::value(src.public_permision))
            .col_expr(Column::MemberCount, Expr::value(src.member_count))
            .col_expr(Column::MemberIds, Expr::value(src.member_ids.clone()))
            .filter(Column::CycleRuleId.eq(cycle_rule_id))
            .exec(db)
            .await?;
        Ok(())
    }

    pub async fn remove_future_by_cycle(
        db: &DatabaseConnection,
        cycle_rule_id: i64,
        start_time: i64,
    ) -> ModelResult<Vec<Model>> {
        let schedules = Entity::find()
            .filter(Column::CycleRuleId.eq(cycle_rule_id))
            .filter(Column::StartTime.gte(start_time))
            .all(db)
            .await?;
        Entity::delete_many()
            .filter(Column::CycleRuleId.eq(cycle_rule_id))
            .filter(Column::StartTime.gte(start_time))
            .exec(db)
            .await?;
        Ok(schedules)
    }

    pub async fn find_by_start_time_range(
        db: &DatabaseConnection,
        start_time_start: i64,
        start_time_end: i64,
    ) -> ModelResult<Vec<Model>> {
        let schedules = Entity::find()
            .filter(Column::StartTime.gte(start_time_start))
            .filter(Column::StartTime.lt(start_time_end))
            .all(db)
            .await?;
        Ok(schedules)
    }

    pub async fn mark_cancelled(db: &DatabaseConnection, id: i64) -> ModelResult<Model> {
        let now = current_ms() as i64;
        let schedule = ActiveModel {
            id: ActiveValue::set(id),
            exception: ActiveValue::set(true),
            version: ActiveValue::set(now),
            ..Default::default()
        }
        .update(db)
        .await?;
        Ok(schedule)
    }
}

impl Into<entity::Schedule> for ScheduleModel {
    fn into(self) -> entity::Schedule {
        let extra = ScheduleExtra::decode(self.0.extra.as_slice()).unwrap_or_default();
        entity::Schedule {
            id: self.0.id,
            calendar_id: self.0.calendar_id,
            r#type: self.0.r#type,
            tenant_id: self.0.tenant_id,
            owner: self.0.owner,
            version: self.0.version,
            summary_doc_id: extra.summary_doc_id,
            room_id: extra.room_id,
            chat_id: extra.chat_id,
            cycle_rule_id: self.0.cycle_rule_id,
            start_time: self.0.start_time,
            end_time: self.0.end_time,
            member_count: self.0.member_count,
            color: extra.color,
            public_permision: self.0.public_permission,
            full_day: self.0.full_day,
            member_view_list: extra.member_view_list,
            member_invite_other: extra.member_invite_other,
            member_alter_schedule: extra.member_alter_schedule,
            member_create_summary: extra.member_create_summary,
            member_create_meeting: extra.member_create_meeting,
            need_checkin: extra.need_checkin,
            show_as_idle: self.0.show_as_idle,
            exception: self.0.exception,
            title: self.0.title,
            location: extra.location,
            archive: extra.archive,
            desc: extra.desc,
            member_ids: self.0.member_ids,
            notify_time: extra.notify_time,
            cycle: extra.cycle_rule,
            modify_scope: 0,
        }
    }
}
impl Into<entity::user_schedule_brief::Brief> for ScheduleModel {
    fn into(self) -> entity::user_schedule_brief::Brief {
        entity::user_schedule_brief::Brief::default()
    }
}
