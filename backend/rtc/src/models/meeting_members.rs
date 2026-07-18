use loco_rs::{model::ModelResult, prelude::*};
pub use base::models::_entities::meeting_members::{ActiveModel, Column, Entity, Model};
use common::time::current_ms;
use sea_orm::PaginatorTrait;

#[derive(Debug)]
pub struct MeetingMemberModel(pub Model);

impl MeetingMemberModel {
    pub async fn create(db: &DatabaseConnection, meeting_id: i64, user_id: i64, role: i16) -> ModelResult<Model> {
        let now = current_ms() as i64;
        let id = common::id_gen(None);
        let model = ActiveModel {
            id: ActiveValue::set(id),
            meeting_id: ActiveValue::set(meeting_id),
            user_id: ActiveValue::set(user_id),
            role: ActiveValue::set(role),
            status: ActiveValue::set(1i16),
            joined_at: ActiveValue::set(Some(now)),
            left_at: ActiveValue::set(None),
            created_at: ActiveValue::set(now),
        }
        .insert(db)
        .await?;
        Ok(model)
    }

    pub async fn get_by_meeting_id(db: &DatabaseConnection, meeting_id: i64) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(Column::MeetingId.eq(meeting_id))
            .all(db)
            .await?)
    }

    pub async fn get_meeting_ids_by_user(db: &DatabaseConnection, user_id: i64) -> ModelResult<Vec<i64>> {
        let members = Entity::find()
            .filter(Column::UserId.eq(user_id))
            .filter(Column::Status.eq(1i16))
            .all(db)
            .await?;
        Ok(members.into_iter().map(|m| m.meeting_id).collect())
    }

    pub async fn get_active_count(db: &DatabaseConnection, meeting_id: i64) -> ModelResult<u64> {
        Ok(Entity::find()
            .filter(Column::MeetingId.eq(meeting_id))
            .filter(Column::Status.eq(1i16))
            .count(db)
            .await?)
    }

    pub async fn get_by_user_and_meeting(
        db: &DatabaseConnection,
        meeting_id: i64,
        user_id: i64,
    ) -> ModelResult<Option<Model>> {
        Ok(Entity::find()
            .filter(Column::MeetingId.eq(meeting_id))
            .filter(Column::UserId.eq(user_id))
            .one(db)
            .await?)
    }

    pub async fn update_status(
        db: &DatabaseConnection,
        meeting_id: i64,
        user_id: i64,
        status: i16,
    ) -> ModelResult<()> {
        let now = current_ms() as i64;
        let member = Entity::find()
            .filter(Column::MeetingId.eq(meeting_id))
            .filter(Column::UserId.eq(user_id))
            .one(db)
            .await?;
        if let Some(m) = member {
            ActiveModel {
                id: ActiveValue::set(m.id),
                status: ActiveValue::set(status),
                left_at: ActiveValue::set(if status >= 2 { Some(now) } else { None }),
                ..Default::default()
            }
            .update(db)
            .await?;
        }
        Ok(())
    }

    pub async fn update_role(db: &DatabaseConnection, meeting_id: i64, user_id: i64, role: i16) -> ModelResult<()> {
        let member = Entity::find()
            .filter(Column::MeetingId.eq(meeting_id))
            .filter(Column::UserId.eq(user_id))
            .one(db)
            .await?;
        if let Some(m) = member {
            ActiveModel {
                id: ActiveValue::set(m.id),
                role: ActiveValue::set(role),
                ..Default::default()
            }
            .update(db)
            .await?;
        }
        Ok(())
    }

    pub async fn bulk_end_by_meeting(db: &DatabaseConnection, meeting_id: i64) -> ModelResult<()> {
        let now = current_ms() as i64;
        let members = Entity::find()
            .filter(Column::MeetingId.eq(meeting_id))
            .filter(Column::Status.eq(1i16))
            .all(db)
            .await?;
        for m in members {
            ActiveModel {
                id: ActiveValue::set(m.id),
                status: ActiveValue::set(2i16),
                left_at: ActiveValue::set(Some(now)),
                ..Default::default()
            }
            .update(db)
            .await?;
        }
        Ok(())
    }
}

impl From<MeetingMemberModel> for meeting::MeetingMember {
    fn from(m: MeetingMemberModel) -> Self {
        let inner = m.0;
        Self {
            user_id: inner.user_id,
            role: inner.role as i32,
            status: inner.status as i32,
            joined_at: inner.joined_at.unwrap_or(0),
            left_at: inner.left_at.unwrap_or(0),
        }
    }
}

use proto::idl::meeting;
