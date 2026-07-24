use sea_orm::{ColumnTrait, EntityTrait, QueryFilter, QueryOrder};
use loco_rs::prelude::*;

use common::id_gen;

pub use base::models::_entities::open_app_stats::{
    ActiveModel, Column, Entity, Model,
};

#[derive(Debug)]
pub struct ApiStatModel(pub Model);

impl ApiStatModel {
    pub async fn record_call(
        db: &DatabaseConnection,
        app_id: i64,
        endpoint: &str,
        latency_ms: i64,
        is_error: bool,
    ) -> ModelResult<()> {
        let today: chrono::DateTime<chrono::FixedOffset> =
            chrono::Utc::now().with_timezone(&chrono::FixedOffset::east_opt(0).unwrap());

        let existing = Entity::find()
            .filter(Column::AppId.eq(app_id))
            .filter(Column::Date.eq(today))
            .filter(Column::Endpoint.eq(endpoint))
            .one(db)
            .await?;

        if let Some(stat) = existing {
            let prev_call = stat.call_count;
            let prev_lat = stat.total_latency_ms;
            let prev_err = stat.error_count;
            let mut active: ActiveModel = stat.into();
            active.call_count = ActiveValue::set(prev_call + 1);
            active.total_latency_ms = ActiveValue::set(prev_lat + latency_ms);
            if is_error {
                active.error_count = ActiveValue::set(prev_err + 1);
            }
            active.update(db).await?;
        } else {
            ActiveModel {
                id: ActiveValue::set(id_gen(Some(false))),
                app_id: ActiveValue::set(app_id),
                date: ActiveValue::set(today),
                endpoint: ActiveValue::set(endpoint.to_string()),
                call_count: ActiveValue::set(1),
                error_count: ActiveValue::set(if is_error { 1 } else { 0 }),
                total_latency_ms: ActiveValue::set(latency_ms),
                ..Default::default()
            }
            .insert(db)
            .await?;
        }

        Ok(())
    }

    pub async fn record_event_push(
        db: &DatabaseConnection,
        app_id: i64,
        success: bool,
    ) -> ModelResult<()> {
        let today: chrono::DateTime<chrono::FixedOffset> =
            chrono::Utc::now().with_timezone(&chrono::FixedOffset::east_opt(0).unwrap());

        let existing = Entity::find()
            .filter(Column::AppId.eq(app_id))
            .filter(Column::Date.eq(today))
            .filter(Column::Endpoint.eq("event_push"))
            .one(db)
            .await?;

        if let Some(stat) = existing {
            let prev_push = stat.event_push_count;
            let prev_fail = stat.event_push_failed;
            let mut active: ActiveModel = stat.into();
            if success {
                active.event_push_count = ActiveValue::set(prev_push + 1);
            } else {
                active.event_push_failed = ActiveValue::set(prev_fail + 1);
            }
            active.update(db).await?;
        }

        Ok(())
    }

    pub async fn get_stats(
        db: &DatabaseConnection,
        app_id: i64,
        days: i32,
    ) -> ModelResult<Vec<Model>> {
        let since: chrono::DateTime<chrono::FixedOffset> = (chrono::Utc::now()
            - chrono::Duration::days(days as i64))
            .with_timezone(&chrono::FixedOffset::east_opt(0).unwrap());
        let stats = Entity::find()
            .filter(Column::AppId.eq(app_id))
            .filter(Column::Date.gte(since))
            .order_by_asc(Column::Date)
            .all(db)
            .await?;
        Ok(stats)
    }

    pub async fn get_daily_summary(
        db: &DatabaseConnection,
        app_id: i64,
        days: i32,
    ) -> ModelResult<Vec<Model>> {
        Self::get_stats(db, app_id, days).await
    }

    pub async fn get_tenant_overview(
        db: &DatabaseConnection,
        tenant_id: i64,
    ) -> ModelResult<(i64, i64)> {
        // aggregate all apps under tenant
        use base::models::_entities::open_apps::Entity as AppEntity;
        let apps = AppEntity::find()
            .filter(base::models::_entities::open_apps::Column::TenantId.eq(tenant_id))
            .all(db)
            .await?;
        let app_ids: Vec<i64> = apps.iter().map(|a| a.id).collect();

        let today: chrono::DateTime<chrono::FixedOffset> =
            chrono::Utc::now().with_timezone(&chrono::FixedOffset::east_opt(0).unwrap());
        let stats = Entity::find()
            .filter(Column::AppId.is_in(app_ids))
            .filter(Column::Date.eq(today))
            .all(db)
            .await?;

        let total_calls: i64 = stats.iter().map(|s| s.call_count as i64).sum();
        let total_errors: i64 = stats.iter().map(|s| s.error_count as i64).sum();
        Ok((total_calls, total_errors))
    }
}
