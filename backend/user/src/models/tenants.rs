use loco_rs::{model::ModelResult, prelude::*};
use prost::Message;
use sea_orm::ActiveValue;
use tracing::debug;

pub use base::models::_entities::tenants::{self, ActiveModel, Entity, Model};
use base::models::_entities::{accounts, depts, users};
use common::{EntityStatus, id_gen};
use proto::idl::entity;
pub type Tenants = Entity;

#[derive(Debug)]
pub struct TenantModel(pub Model);

#[derive(prost::Message)]
struct TenantExtra {
    #[prost(string, tag = "1")]
    pub avatar: String,
}

impl TenantModel {
    pub async fn find_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Self> {
        let tenant = Entity::find()
            .filter(
                model::query::condition()
                    .eq(tenants::Column::Id, id)
                    .build(),
            )
            .one(db)
            .await?;
        Ok(Self(tenant.ok_or_else(|| ModelError::EntityNotFound)?))
    }

    pub async fn find_by_ids(db: &DatabaseConnection, ids: Vec<i64>) -> ModelResult<Vec<Model>> {
        let mut tenants = Entity::find()
            .filter(
                model::query::condition()
                    .is_in(tenants::Column::Id, ids)
                    .build(),
            )
            .all(db)
            .await?;
        Ok(tenants)
    }

    pub async fn create(
        db: &DatabaseConnection,
        name: &str,
        account: &accounts::Model,
        avatar: String,
    ) -> ModelResult<(Self, users::Model)> {
        let tenant_id = id_gen(None);
        let user_id = id_gen(Some(false));
        let dept_id = id_gen(None);
        debug!("create tenant, id: {tenant_id}, owner: {user_id}, dept_id: {dept_id}");
        let txn = db.begin().await?;

        let extra = (TenantExtra { avatar }).encode_to_vec();
        let tenant = ActiveModel {
            id: ActiveValue::set(tenant_id),
            name: ActiveValue::set(name.to_string()),
            owner_id: ActiveValue::set(user_id),
            root_dept_id: ActiveValue::set(dept_id),
            managers: ActiveValue::set(vec![user_id]),
            version: ActiveValue::set(0),
            extra: ActiveValue::set(extra),
            ..Default::default()
        }
        .insert(&txn)
        .await?;
        let _user = users::ActiveModel {
            id: ActiveValue::set(user_id),
            a_id: ActiveValue::set(account.id),
            name: ActiveValue::set(account.name.to_string()),
            tenant_id: ActiveValue::set(tenant_id),
            dept_id: ActiveValue::set(dept_id),
            pid: ActiveValue::set(Uuid::new_v4()),
            api_key: ActiveValue::set(Uuid::new_v4().to_string()),
            status: ActiveValue::set(EntityStatus::Normal as i16),
            r#type: ActiveValue::set(entity::UserType::Personal as i16),
            tenant_permision: ActiveValue::set(entity::TenantPermision::SuperAdmin as i16),
            avatar: ActiveValue::set(account.avatar.clone()),
            version: ActiveValue::set(0),
            extra: ActiveValue::set(vec![]),
            ..Default::default()
        }
        .insert(&txn)
        .await?;

        let _dept = depts::ActiveModel {
            id: ActiveValue::set(dept_id),
            parent_id: ActiveValue::set(0),
            name: ActiveValue::set(name.to_string()),
            tenant_id: ActiveValue::set(tenant_id),
            member_ids: ActiveValue::set(Vec::new()),
            sub_ids: ActiveValue::set(Vec::new()),
            version: ActiveValue::set(0),
            extra: ActiveValue::set(vec![]),
            ..Default::default()
        }
        .insert(&txn)
        .await?;
        txn.commit().await?;
        Ok((Self(tenant), _user))
    }
}

impl From<tenants::Model> for TenantModel {
    fn from(value: tenants::Model) -> Self {
        Self(value)
    }
}

impl Into<entity::Tenant> for TenantModel {
    fn into(self) -> entity::Tenant {
        let extra = TenantExtra::decode(self.0.extra.as_slice()).unwrap_or_default();
        entity::Tenant {
            id: self.0.id,
            owner_id: self.0.owner_id,
            name: self.0.name,
            root_department_id: self.0.root_dept_id,
            version: self.0.version,
            avatar: extra.avatar,
        }
    }
}
