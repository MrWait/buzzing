use loco_rs::{model::ModelResult, prelude::*};
use prost::Message;
use sea_orm::{QueryOrder, PaginatorTrait};
pub use base::models::_entities::meetings::{ActiveModel, Column, Entity, Model};
use common::time::current_ms;
use proto::idl::meeting;
use proto::idl::entity;

#[derive(Debug)]
pub struct MeetingModel(pub Model);

impl MeetingModel {
    pub async fn get_by_room_id(db: &DatabaseConnection, room_id: &str) -> ModelResult<Option<Model>> {
        Ok(Entity::find()
            .filter(Column::RoomId.eq(room_id))
            .one(db)
            .await?)
    }

    pub async fn get_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Option<Model>> {
        Ok(Entity::find().filter(Column::Id.eq(id)).one(db).await?)
    }

    pub async fn create(db: &DatabaseConnection, src: &Model) -> ModelResult<Model> {
        let now = current_ms() as i64;
        let model = ActiveModel {
            id: ActiveValue::set(src.id),
            room_id: ActiveValue::set(src.room_id.clone()),
            title: ActiveValue::set(src.title.clone()),
            host_id: ActiveValue::set(src.host_id),
            password: ActiveValue::set(src.password.clone()),
            status: ActiveValue::set(0i16),
            scheduled_at: ActiveValue::set(src.scheduled_at),
            started_at: ActiveValue::set(now),
            ended_at: ActiveValue::set(None),
            tenant_id: ActiveValue::set(src.tenant_id),
            max_participants: ActiveValue::set(src.max_participants),
            settings: ActiveValue::set(src.settings.clone()),
            created_at: ActiveValue::set(now),
            updated_at: ActiveValue::set(now),
        }
        .insert(db)
        .await?;
        Ok(model)
    }

    pub async fn update_status(db: &DatabaseConnection, id: i64, status: i16) -> ModelResult<()> {
        let now = current_ms() as i64;
        let ended_at = if status == 1 { Some(now) } else { None };
        ActiveModel {
            id: ActiveValue::set(id),
            status: ActiveValue::set(status),
            ended_at: ActiveValue::set(ended_at),
            updated_at: ActiveValue::set(now),
            ..Default::default()
        }
        .update(db)
        .await?;
        Ok(())
    }

    pub async fn get_active_by_user(
        db: &DatabaseConnection,
        tenant_id: i64,
        user_id: i64,
        page: i32,
        page_size: i32,
    ) -> ModelResult<(Vec<Model>, i32)> {
        let offset = ((page - 1).max(0) * page_size) as u64;
        let limit = page_size.max(1) as u64;

        let meeting_ids = super::meeting_members::MeetingMemberModel::get_meeting_ids_by_user(db, user_id).await?;
        if meeting_ids.is_empty() {
            return Ok((vec![], 0));
        }

        let query = Entity::find()
            .filter(Column::TenantId.eq(tenant_id))
            .filter(Column::Status.eq(0i16))
            .filter(Column::Id.is_in(meeting_ids))
            .order_by_desc(Column::CreatedAt);

        let paginated = query.paginate(db, limit);
        let total = paginated.num_items().await?;
        let items = paginated.fetch_page((offset / limit.max(1)) as u64).await?;
        Ok((items, total as i32))
    }

    pub async fn get_list_by_filter(
        db: &DatabaseConnection,
        tenant_id: i64,
        filter: i32,
        page: i32,
        page_size: i32,
    ) -> ModelResult<(Vec<Model>, i32)> {
        let offset = ((page - 1).max(0) * page_size) as u64;
        let limit = page_size.max(1) as u64;

        let mut query = Entity::find()
            .filter(Column::TenantId.eq(tenant_id));

        match filter {
            2 => { query = query.filter(Column::Status.eq(1i16)); }
            3 => {
                query = query
                    .filter(Column::Status.eq(0i16))
                    .filter(Column::ScheduledAt.is_not_null());
            }
            _ => { return Ok((vec![], 0)); }
        }

        query = query.order_by_desc(Column::CreatedAt);
        let paginated = query.paginate(db, limit);
        let total = paginated.num_items().await?;
        let items = paginated.fetch_page((offset / limit.max(1)) as u64).await?;
        Ok((items, total as i32))
    }
}

impl From<MeetingModel> for meeting::MeetingInfo {
    fn from(m: MeetingModel) -> Self {
        Self {
            room_id: m.0.room_id,
            host_id: m.0.host_id,
            title: m.0.title,
            created_at: m.0.created_at,
            password: m.0.password.unwrap_or_default(),
            status: match m.0.status {
                1 => meeting::MeetingStatus::MeetingEnded as i32,
                _ => meeting::MeetingStatus::MeetingActive as i32,
            },
            id: m.0.id,
            scheduled_at: m.0.scheduled_at.unwrap_or(0),
            started_at: m.0.started_at,
            ended_at: m.0.ended_at.unwrap_or(0),
            tenant_id: m.0.tenant_id,
            members: vec![],
            settings: Some(meeting::MeetingSettings {
                mute_on_entry: false,
                allow_screen_share: true,
                record_enabled: false,
            }),
            max_participants: m.0.max_participants,
            member_ids: vec![],
        }
    }
}
