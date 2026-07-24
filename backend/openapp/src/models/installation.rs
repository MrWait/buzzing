use sea_orm::{ColumnTrait, EntityTrait, PaginatorTrait, QueryFilter, QueryOrder};
use loco_rs::prelude::*;

use common::id_gen;

pub use base::models::_entities::open_app_installations::{
    ActiveModel, Column, Entity, Model,
};

#[derive(Debug)]
pub struct InstallationModel(pub Model);

impl InstallationModel {
    pub async fn create(
        db: &DatabaseConnection,
        app_id: i64,
        tenant_id: i64,
        installer_id: i64,
        scopes: Vec<String>,
    ) -> ModelResult<Self> {
        let model = ActiveModel {
            id: ActiveValue::set(id_gen(Some(false))),
            app_id: ActiveValue::set(app_id),
            tenant_id: ActiveValue::set(tenant_id),
            installer_id: ActiveValue::set(installer_id),
            scopes: ActiveValue::set(scopes),
            status: ActiveValue::set(1i16),
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

    pub async fn find_by_tenant(
        db: &DatabaseConnection,
        tenant_id: i64,
    ) -> ModelResult<Vec<Self>> {
        let items = Entity::find()
            .filter(Column::TenantId.eq(tenant_id))
            .filter(Column::Status.is_in(vec![1i16, 0i16]))
            .order_by_desc(Column::Id)
            .all(db)
            .await?;
        Ok(items.into_iter().map(Self).collect())
    }

    pub async fn find_by_app_tenant(
        db: &DatabaseConnection,
        app_id: i64,
        tenant_id: i64,
    ) -> ModelResult<Option<Self>> {
        let m = Entity::find()
            .filter(Column::AppId.eq(app_id))
            .filter(Column::TenantId.eq(tenant_id))
            .filter(Column::Status.eq(1i16))
            .one(db)
            .await?;
        Ok(m.map(Self))
    }

    pub async fn set_status(db: &DatabaseConnection, id: i64, status: i16) -> ModelResult<bool> {
        let m = Entity::find_by_id(id).one(db).await?;
        let Some(m) = m else { return Ok(false) };
        let mut active: ActiveModel = m.into();
        active.status = ActiveValue::set(status);
        if status == 2 {
            active.uninstalled_at = ActiveValue::set(Some(chrono::Utc::now().into()));
        }
        active.update(db).await?;
        Ok(true)
    }

    pub async fn count_by_tenant(db: &DatabaseConnection, tenant_id: i64) -> ModelResult<i64> {
        let count = Entity::find()
            .filter(Column::TenantId.eq(tenant_id))
            .filter(Column::Status.eq(1i16))
            .count(db)
            .await?;
        Ok(count as i64)
    }

    pub async fn count_active(db: &DatabaseConnection) -> ModelResult<i64> {
        let count = Entity::find()
            .filter(Column::Status.eq(1i16))
            .count(db)
            .await?;
        Ok(count as i64)
    }

    pub fn to_json(&self) -> serde_json::Value {
        serde_json::json!({
            "id": self.0.id,
            "app_id": self.0.app_id,
            "tenant_id": self.0.tenant_id,
            "installer_id": self.0.installer_id,
            "scopes": self.0.scopes,
            "status": self.0.status,
            "installed_at": self.0.installed_at,
            "uninstalled_at": self.0.uninstalled_at,
        })
    }
}
