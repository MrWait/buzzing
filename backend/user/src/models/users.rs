use loco_rs::{auth::jwt, prelude::*};
use tracing::{debug, info, warn};

pub use base::models::_entities::users::{ActiveModel, Column, Entity, Model};
use base::models::_entities::{accounts, tenants};
use common::{EntityStatus, UserBrief, id_gen};
use proto::idl::entity;

#[derive(Debug)]
pub struct UserModel(pub Model);

impl UserModel {
    pub fn generate_jwt(&self, secret: &str, expiration: &u64) -> ModelResult<String> {
        let info = UserBrief {
            id: self.0.id,
            pid: self.0.pid.to_string(),
            aid: self.0.a_id,
            tenant_id: self.0.tenant_id,
        };
        Ok(jwt::JWT::new(secret).generate_token(
            *expiration,
            info.to_string(),
            serde_json::Map::new(),
        )?)
    }

    /// finds a user by the provided pid
    ///
    /// # Errors
    ///
    /// When could not find user  or DB query error
    pub async fn find_by_pid(db: &DatabaseConnection, pid: &str) -> ModelResult<Self> {
        let parse_uuid = Uuid::parse_str(pid).map_err(|e| ModelError::Any(e.into()))?;
        let user = Entity::find()
            .filter(
                model::query::condition()
                    .eq(Column::Pid, parse_uuid)
                    .build(),
            )
            .one(db)
            .await?;
        Ok(Self(user.ok_or_else(|| ModelError::EntityNotFound)?))
    }

    pub async fn find_by_ids(db: &DatabaseConnection, ids: &[i64]) -> ModelResult<Vec<Model>> {
        let users = Entity::find()
            .filter(
                model::query::condition()
                    .is_in(Column::Id, ids.to_vec())
                    .build(),
            )
            .all(db)
            .await?;
        Ok(users)
    }

    pub async fn find_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Option<Model>> {
        let user = Entity::find()
            .filter(model::query::condition().eq(Column::Id, id).build())
            .one(db)
            .await?;
        Ok(user)
    }

    /// finds a user by the provided api key
    ///
    /// # Errors
    ///
    /// When could not find user by the given token or DB query error
    pub async fn find_by_api_key(db: &DatabaseConnection, api_key: &str) -> ModelResult<Self> {
        let user = Entity::find()
            .filter(
                model::query::condition()
                    .eq(Column::ApiKey, api_key)
                    .build(),
            )
            .one(db)
            .await?;
        Ok(user.ok_or_else(|| ModelError::EntityNotFound)?.into())
    }

    pub async fn create_default_with_account(
        db: &DatabaseConnection,
        account: &accounts::Model,
    ) -> ModelResult<Self> {
        let txn = db.begin().await?;

        if let Some(user) = Entity::find()
            .filter(
                model::query::condition()
                    .eq(Column::AId, account.id)
                    .build(),
            )
            .one(&txn)
            .await?
        {
            return Ok(user.into());
        }
        let id = id_gen(Some(false));
        tracing::info!("create new user: {}", id);

        let user = ActiveModel {
            id: ActiveValue::set(id),
            name: ActiveValue::set(account.name.to_string()),
            a_id: ActiveValue::set(account.id),
            tenant_id: ActiveValue::set(0),
            pid: ActiveValue::set(Uuid::new_v4()),
            api_key: ActiveValue::set(Uuid::new_v4().to_string()),
            status: ActiveValue::set(EntityStatus::Normal as i16),
            r#type: ActiveValue::set(entity::UserType::Personal as i16),
            dept_id: ActiveValue::set(0),
            tenant_permision: ActiveValue::set(entity::TenantPermision::Normal as i16),
            avatar: ActiveValue::set(account.avatar.clone()),
            version: ActiveValue::set(0),
            extra: ActiveValue::set(vec![]),
            ..Default::default()
        }
        .insert(&txn)
        .await?;
        txn.commit().await?;
        Ok(user.into())
    }

    pub async fn create_with_tenant(
        db: &DatabaseConnection,
        account: &accounts::Model,
        tenant: &tenants::Model,
        dept_id: i64,
    ) -> ModelResult<Self> {
        info!("create new user {} in tenant: {}", account.id, tenant.id);
        match Entity::find()
            .filter(
                model::query::condition()
                    .eq(Column::AId, account.id)
                    .build(),
            )
            .all(db)
            .await
        {
            Ok(users) => {
                for user in users {
                    if user.tenant_id == tenant.id {
                        return Ok(user.into());
                    }
                }
            }
            Err(err) => {
                warn!("query user error, err: {err:?}");
                return Err(ModelError::DbErr(err));
            }
        }
        debug!("insert new");
        let id = id_gen(Some(false));

        let user = ActiveModel {
            id: ActiveValue::set(id),
            name: ActiveValue::set(account.name.to_string()),
            a_id: ActiveValue::set(account.id),
            tenant_id: ActiveValue::set(tenant.id),
            pid: ActiveValue::set(Uuid::new_v4()),
            api_key: ActiveValue::set(Uuid::new_v4().to_string()),
            status: ActiveValue::set(EntityStatus::Normal as i16),
            r#type: ActiveValue::set(entity::UserType::Personal as i16),
            dept_id: ActiveValue::set(dept_id),
            tenant_permision: ActiveValue::set(entity::TenantPermision::Normal as i16),
            version: ActiveValue::set(0),
            avatar: ActiveValue::set(account.avatar.clone()),
            extra: ActiveValue::set(vec![]),
            ..Default::default()
        }
        .insert(db)
        .await
        .map_err(|err| {
            debug!("insert error: {err:?}");
            err
        })?;
        debug!("create user ok: {:?}", user);
        Ok(Self(user))
    }

    pub async fn find_by_aid(db: &DatabaseConnection, aid: i64) -> ModelResult<Vec<Self>> {
        if let Ok(mut users) = Entity::find()
            .filter(model::query::condition().eq(Column::AId, aid).build())
            .all(db)
            .await
        {
            return Ok(users.drain(..).map(|u| u.into()).collect());
        }

        Ok(vec![])
    }

    pub async fn find_by_dept_id(db: &DatabaseConnection, dept_id: i64) -> ModelResult<Vec<Self>> {
        if dept_id == 0 {
            return Ok(Vec::new());
        }
        let mut users = Entity::find()
            .filter(
                model::query::condition()
                    .eq(Column::DeptId, dept_id)
                    .build(),
            )
            .all(db)
            .await?;
        Ok(users.drain(..).map(|u| u.into()).collect())
    }

    pub async fn find_by_ids_with_account(
        db: &DatabaseConnection,
        ids: &[i64],
    ) -> ModelResult<Vec<(Model, accounts::Model)>> {
        use sea_orm::*;
        let users = Entity::find()
            .filter(Column::Id.is_in(ids.to_vec()))
            .all(db)
            .await?;
        let account_ids: Vec<i64> = users.iter().map(|u| u.a_id).collect();
        let accounts = accounts::Entity::find()
            .filter(accounts::Column::Id.is_in(account_ids))
            .all(db)
            .await?;
        let account_map: std::collections::HashMap<i64, accounts::Model> =
            accounts.into_iter().map(|a| (a.id, a)).collect();
        let result = users
            .into_iter()
            .filter_map(|u| {
                let a = account_map.get(&u.a_id)?;
                Some((u, a.clone()))
            })
            .collect();
        Ok(result)
    }

    pub async fn exit_chat(
        _db: &DatabaseConnection,
        _user_id: i64,
        _chat_id: i64,
    ) -> ModelResult<()> {
        Err(ModelError::EntityNotFound)
    }
}

impl Into<entity::User> for UserModel {
    fn into(self) -> entity::User {
        entity::User {
            id: self.0.id,
            name: self.0.name,
            avatar: self.0.avatar.unwrap_or_default(),
            tenant_id: self.0.tenant_id,
            status: self.0.status as i32,
            version: self.0.version,
            dept_id: self.0.dept_id,
            phone: String::new(),
            email: self.0.email,
            position: self.0.position,
            city: self.0.city,
            superior_id: self.0.superior_id,
            superior_name: String::new(),
        }
    }
}

impl From<Model> for UserModel {
    fn from(value: Model) -> Self {
        Self(value)
    }
}
