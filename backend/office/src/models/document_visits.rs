use loco_rs::{model::ModelResult, prelude::*};
use sea_orm::{ActiveValue, Condition, QueryOrder, QuerySelect};

pub use base::models::_entities::document_visits::{ActiveModel, Column, Entity, Model};

pub struct DocumentVisitModel;

impl DocumentVisitModel {
    /// 记录一次访问：存在则更新 visited_at，否则新建
    pub async fn upsert(
        db: &DatabaseConnection,
        id_if_new: i64,
        user_id: i64,
        document_id: i64,
    ) -> ModelResult<Model> {
        let now = common::time::current_ms() as i64;
        let existing = Entity::find()
            .filter(
                Condition::all()
                    .add(Column::UserId.eq(user_id))
                    .add(Column::DocumentId.eq(document_id)),
            )
            .one(db)
            .await?;
        if let Some(m) = existing {
            let mut am: ActiveModel = m.into();
            am.visited_at = ActiveValue::set(now);
            Ok(am.update(db).await?)
        } else {
            let am = ActiveModel {
                id: ActiveValue::set(id_if_new),
                user_id: ActiveValue::set(user_id),
                document_id: ActiveValue::set(document_id),
                visited_at: ActiveValue::set(now),
                ..Default::default()
            };
            Ok(am.insert(db).await?)
        }
    }

    /// 用户最近访问的文档 (visited_at 倒序)
    pub async fn list_recent(
        db: &DatabaseConnection,
        user_id: i64,
        limit: u64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(Column::UserId.eq(user_id))
            .order_by_desc(Column::VisitedAt)
            .limit(limit)
            .all(db)
            .await?)
    }
}
