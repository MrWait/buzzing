use sea_orm::{ColumnTrait, EntityTrait, PaginatorTrait, QueryFilter, QueryOrder};
use loco_rs::prelude::*;

use common::id_gen;

pub use base::models::_entities::open_app_reviews::{
    ActiveModel, Column, Entity, Model,
};

#[derive(Debug)]
pub struct ReviewModel(pub Model);

impl ReviewModel {
    pub async fn create(
        db: &DatabaseConnection,
        app_id: i64,
        user_id: i64,
        tenant_id: i64,
        rating: i16,
        content: Option<&str>,
    ) -> ModelResult<Self> {
        let model = ActiveModel {
            id: ActiveValue::set(id_gen(Some(false))),
            app_id: ActiveValue::set(app_id),
            user_id: ActiveValue::set(user_id),
            tenant_id: ActiveValue::set(tenant_id),
            rating: ActiveValue::set(rating),
            content: ActiveValue::set(content.map(|s| s.to_string())),
            ..Default::default()
        }
        .insert(db)
        .await?;
        Ok(Self(model))
    }

    pub async fn find_by_app(
        db: &DatabaseConnection,
        app_id: i64,
        page: i32,
        page_size: i32,
    ) -> ModelResult<(Vec<Self>, i64)> {
        let paginator = Entity::find()
            .filter(Column::AppId.eq(app_id))
            .order_by_desc(Column::Id)
            .paginate(db, page_size as u64);
        let total = paginator.num_items().await?;
        let items = paginator.fetch_page((page - 1).max(0) as u64).await?;
        Ok((items.into_iter().map(Self).collect(), total as i64))
    }

    pub async fn find_by_user(
        db: &DatabaseConnection,
        app_id: i64,
        user_id: i64,
        tenant_id: i64,
    ) -> ModelResult<Option<Self>> {
        let m = Entity::find()
            .filter(Column::AppId.eq(app_id))
            .filter(Column::UserId.eq(user_id))
            .filter(Column::TenantId.eq(tenant_id))
            .one(db)
            .await?;
        Ok(m.map(Self))
    }

    pub async fn reply(
        db: &DatabaseConnection,
        id: i64,
        reply_content: &str,
    ) -> ModelResult<Option<Self>> {
        let m = Entity::find_by_id(id).one(db).await?;
        let Some(m) = m else { return Ok(None) };
        let mut active: ActiveModel = m.into();
        active.reply_content = ActiveValue::set(Some(reply_content.to_string()));
        active.reply_at = ActiveValue::set(Some(chrono::Utc::now().into()));
        let model = active.update(db).await?;
        Ok(Some(Self(model)))
    }

    pub async fn get_rating_summary(
        db: &DatabaseConnection,
        app_id: i64,
    ) -> ModelResult<serde_json::Value> {
        let all = Entity::find()
            .filter(Column::AppId.eq(app_id))
            .all(db)
            .await?;

        let total = all.len() as i64;
        if total == 0 {
            return Ok(serde_json::json!({
                "average": 0.0,
                "total": 0,
                "distribution": { "1": 0, "2": 0, "3": 0, "4": 0, "5": 0 }
            }));
        }

        let sum: i64 = all.iter().map(|r| r.rating as i64).sum();
        let average = sum as f64 / total as f64;

        let mut dist = [0i64; 5];
        for r in &all {
            let idx = (r.rating - 1).max(0).min(4) as usize;
            dist[idx] += 1;
        }

        Ok(serde_json::json!({
            "average": (average * 10.0).round() / 10.0,
            "total": total,
            "distribution": {
                "1": dist[0], "2": dist[1], "3": dist[2], "4": dist[3], "5": dist[4]
            }
        }))
    }

    pub fn to_json(&self) -> serde_json::Value {
        serde_json::json!({
            "id": self.0.id,
            "app_id": self.0.app_id,
            "user_id": self.0.user_id,
            "tenant_id": self.0.tenant_id,
            "rating": self.0.rating,
            "content": self.0.content,
            "reply_content": self.0.reply_content,
            "reply_at": self.0.reply_at,
            "created_at": self.0.created_at,
            "updated_at": self.0.updated_at,
        })
    }
}
