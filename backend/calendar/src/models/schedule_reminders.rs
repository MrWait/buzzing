use loco_rs::{model::ModelResult, prelude::*};
use sea_query::Expr;

pub use base::models::_entities::schedule_reminders::{ActiveModel, Column, Entity, Model};
use common::time::current_ms;
use common::id_gen;

#[derive(Debug)]
pub struct ScheduleReminderModel;

impl ScheduleReminderModel {
    pub async fn batch_insert_ignore(
        db: &DatabaseConnection,
        reminders: Vec<(i64, i64, i64, i32)>,
    ) -> ModelResult<()> {
        for (schedule_id, user_id, remind_at, notify_minute) in reminders {
            let id = id_gen(None);
            let now = current_ms() as i64;
            let exists = Entity::find()
                .filter(Column::ScheduleId.eq(schedule_id))
                .filter(Column::UserId.eq(user_id))
                .filter(Column::RemindAt.eq(remind_at))
                .one(db)
                .await?;
            if exists.is_some() {
                continue;
            }
            ActiveModel {
                id: ActiveValue::set(id),
                schedule_id: ActiveValue::set(schedule_id),
                user_id: ActiveValue::set(user_id),
                remind_at: ActiveValue::set(remind_at),
                notify_minute: ActiveValue::set(notify_minute),
                sent_at: ActiveValue::set(None),
                created_at: ActiveValue::set(now),
            }
            .insert(db)
            .await?;
        }
        Ok(())
    }

    pub async fn find_due(db: &DatabaseConnection, before: i64) -> ModelResult<Vec<Model>> {
        let reminders = Entity::find()
            .filter(Column::RemindAt.lte(before))
            .filter(Column::SentAt.is_null())
            .all(db)
            .await?;
        Ok(reminders)
    }

    pub async fn mark_sent(db: &DatabaseConnection, id: i64, sent_at: i64) -> ModelResult<()> {
        ActiveModel {
            id: ActiveValue::set(id),
            sent_at: ActiveValue::set(Some(sent_at)),
            ..Default::default()
        }
        .update(db)
        .await?;
        Ok(())
    }

    pub async fn cleanup_orphans(db: &DatabaseConnection) -> ModelResult<u64> {
        let cutoff = (current_ms() - 7 * 86400_000) as i64;
        let result = Entity::delete_many()
            .filter(Column::SentAt.is_not_null())
            .filter(Column::SentAt.lt(cutoff))
            .exec(db)
            .await?;
        Ok(result.rows_affected)
    }
}
