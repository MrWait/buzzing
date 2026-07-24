use sea_orm::{ColumnTrait, EntityTrait, PaginatorTrait, QueryFilter, QueryOrder};
use loco_rs::prelude::*;

use common::id_gen;

pub use base::models::_entities::open_app_versions::{
    ActiveModel, Column, Entity, Model,
};

#[derive(Debug)]
pub struct VersionModel(pub Model);

impl VersionModel {
    pub async fn create(
        db: &DatabaseConnection,
        app_id: i64,
        version: &str,
        release_notes: Option<&str>,
    ) -> ModelResult<Self> {
        let model = ActiveModel {
            id: ActiveValue::set(id_gen(Some(false))),
            app_id: ActiveValue::set(app_id),
            version: ActiveValue::set(version.to_string()),
            release_notes: ActiveValue::set(release_notes.map(|s| s.to_string())),
            status: ActiveValue::set(0i16),
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

    pub async fn find_by_status(
        db: &DatabaseConnection,
        status: i16,
        page: i32,
        page_size: i32,
    ) -> ModelResult<(Vec<Self>, i64)> {
        let paginator = Entity::find()
            .filter(Column::Status.eq(status))
            .order_by_desc(Column::Id)
            .paginate(db, page_size as u64);
        let total = paginator.num_items().await?;
        let items = paginator.fetch_page((page - 1).max(0) as u64).await?;
        Ok((items.into_iter().map(Self).collect(), total as i64))
    }

    pub async fn approve(
        db: &DatabaseConnection,
        id: i64,
        reviewed_by: i64,
    ) -> ModelResult<Option<Self>> {
        let m = Entity::find_by_id(id).one(db).await?;
        let Some(m) = m else { return Ok(None) };
        let mut active: ActiveModel = m.into();
        active.status = ActiveValue::set(1i16);
        active.reviewed_by = ActiveValue::set(Some(reviewed_by));
        active.reviewed_at = ActiveValue::set(Some(chrono::Utc::now().into()));
        let model = active.update(db).await?;
        Ok(Some(Self(model)))
    }

    pub async fn reject(
        db: &DatabaseConnection,
        id: i64,
        reviewed_by: i64,
        comment: &str,
    ) -> ModelResult<Option<Self>> {
        let m = Entity::find_by_id(id).one(db).await?;
        let Some(m) = m else { return Ok(None) };
        let mut active: ActiveModel = m.into();
        active.status = ActiveValue::set(2i16);
        active.review_comment = ActiveValue::set(Some(comment.to_string()));
        active.reviewed_by = ActiveValue::set(Some(reviewed_by));
        active.reviewed_at = ActiveValue::set(Some(chrono::Utc::now().into()));
        let model = active.update(db).await?;
        Ok(Some(Self(model)))
    }

    pub async fn publish(db: &DatabaseConnection, id: i64) -> ModelResult<Option<Self>> {
        let m = Entity::find_by_id(id).one(db).await?;
        let Some(m) = m else { return Ok(None) };
        let mut active: ActiveModel = m.into();
        active.status = ActiveValue::set(3i16);
        let model = active.update(db).await?;
        Ok(Some(Self(model)))
    }

    pub async fn set_status(db: &DatabaseConnection, id: i64, status: i16) -> ModelResult<Option<Self>> {
        let m = Entity::find_by_id(id).one(db).await?;
        let Some(m) = m else { return Ok(None) };
        let mut active: ActiveModel = m.into();
        active.status = ActiveValue::set(status);
        let model = active.update(db).await?;
        Ok(Some(Self(model)))
    }

    pub fn to_json(&self) -> serde_json::Value {
        serde_json::json!({
            "id": self.0.id,
            "app_id": self.0.app_id,
            "version": self.0.version,
            "release_notes": self.0.release_notes,
            "status": self.0.status,
            "review_comment": self.0.review_comment,
            "reviewed_by": self.0.reviewed_by,
            "reviewed_at": self.0.reviewed_at,
            "created_at": self.0.created_at,
        })
    }
}
