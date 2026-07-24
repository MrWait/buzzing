use sea_orm::{ColumnTrait, EntityTrait, QueryFilter, QueryOrder};
use loco_rs::prelude::*;

pub use base::models::_entities::open_app_market_info::{
    ActiveModel, Column, Entity, Model,
};

#[derive(Debug)]
pub struct MarketInfoModel(pub Model);

impl MarketInfoModel {
    pub async fn find_by_app(db: &DatabaseConnection, app_id: i64) -> ModelResult<Option<Self>> {
        let m = Entity::find_by_id(app_id).one(db).await?;
        Ok(m.map(Self))
    }

    pub async fn upsert(
        db: &DatabaseConnection,
        app_id: i64,
        category: &str,
        short_description: &str,
        detailed_description: Option<&str>,
        developer_name: &str,
        developer_email: &str,
        support_url: &str,
        homepage_url: &str,
        permissions: Vec<String>,
    ) -> ModelResult<Self> {
        let existing = Entity::find_by_id(app_id).one(db).await?;
        if let Some(m) = existing {
            let mut active: ActiveModel = m.into();
            active.app_category = ActiveValue::set(category.to_string());
            active.short_description = ActiveValue::set(short_description.to_string());
            if let Some(v) = detailed_description {
                active.detailed_description = ActiveValue::set(Some(v.to_string()));
            }
            active.developer_name = ActiveValue::set(developer_name.to_string());
            active.developer_email = ActiveValue::set(developer_email.to_string());
            active.support_url = ActiveValue::set(support_url.to_string());
            active.homepage_url = ActiveValue::set(homepage_url.to_string());
            active.permissions = ActiveValue::set(permissions);
            let model = active.update(db).await?;
            Ok(Self(model))
        } else {
            let model = ActiveModel {
                app_id: ActiveValue::set(app_id),
                app_category: ActiveValue::set(category.to_string()),
                short_description: ActiveValue::set(short_description.to_string()),
                detailed_description: ActiveValue::set(detailed_description.map(|s| s.to_string())),
                developer_name: ActiveValue::set(developer_name.to_string()),
                developer_email: ActiveValue::set(developer_email.to_string()),
                support_url: ActiveValue::set(support_url.to_string()),
                homepage_url: ActiveValue::set(homepage_url.to_string()),
                permissions: ActiveValue::set(permissions),
                ..Default::default()
            }
            .insert(db)
            .await?;
            Ok(Self(model))
        }
    }

    pub async fn set_icon(db: &DatabaseConnection, app_id: i64, file_id: i64) -> ModelResult<()> {
        let m = Entity::find_by_id(app_id).one(db).await?;
        if let Some(m) = m {
            let mut active: ActiveModel = m.into();
            active.icon_file_id = ActiveValue::set(Some(file_id));
            active.update(db).await?;
        }
        Ok(())
    }

    pub async fn set_screenshots(
        db: &DatabaseConnection,
        app_id: i64,
        file_ids: Vec<i64>,
    ) -> ModelResult<()> {
        let m = Entity::find_by_id(app_id).one(db).await?;
        if let Some(m) = m {
            let mut active: ActiveModel = m.into();
            active.screenshots = ActiveValue::set(file_ids);
            active.update(db).await?;
        }
        Ok(())
    }

    pub async fn increment_install_count(db: &DatabaseConnection, app_id: i64) -> ModelResult<()> {
        let m = Entity::find_by_id(app_id).one(db).await?;
        if let Some(m) = m {
            let prev = m.install_count;
            let mut active: ActiveModel = m.into();
            active.install_count = ActiveValue::set(prev + 1);
            active.update(db).await?;
        }
        Ok(())
    }

    pub fn to_json(&self) -> serde_json::Value {
        serde_json::json!({
            "app_id": self.0.app_id,
            "category": self.0.app_category,
            "icon_file_id": self.0.icon_file_id,
            "screenshots": self.0.screenshots,
            "short_description": self.0.short_description,
            "detailed_description": self.0.detailed_description,
            "developer_name": self.0.developer_name,
            "developer_email": self.0.developer_email,
            "support_url": self.0.support_url,
            "homepage_url": self.0.homepage_url,
            "permissions": self.0.permissions,
            "install_count": self.0.install_count,
            "rating_avg": self.0.rating_avg,
            "rating_count": self.0.rating_count,
            "is_featured": self.0.is_featured,
            "created_at": self.0.created_at,
            "updated_at": self.0.updated_at,
        })
    }
}
