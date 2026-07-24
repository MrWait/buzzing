use sea_orm::{ColumnTrait, PaginatorTrait, QueryFilter, QueryOrder};
use loco_rs::prelude::*;
use tracing::info;

use crate::services::auth;
use common::{EntityStatus, id_gen};

pub use base::models::_entities::open_apps::{ActiveModel, Column, Entity, Model};
use base::models::_entities::{open_app_bots, users};

#[derive(Debug)]
pub struct OpenAppModel(pub Model);

impl OpenAppModel {
    /// 创建应用，同步创建 Bot 用户和 Bot 配置
    /// 返回 (model, raw_secret, bot_user_id)
    pub async fn create(
        db: &DatabaseConnection,
        owner_id: i64,
        tenant_id: i64,
        name: &str,
        description: &str,
        app_type: i16,
    ) -> ModelResult<(Self, String, Option<i64>)> {
        let id = id_gen(Some(false));
        let app_id = auth::generate_app_id();
        let raw_secret = auth::generate_app_secret();
        let secret_hash = auth::hash_secret(&raw_secret);

        info!("create openapp: id={id}, app_id={app_id}, type={app_type}");

        let bot_user_id = if app_type == 1 {
            let bot_id = Self::create_bot_user(db, id, tenant_id, name).await?;
            Some(bot_id)
        } else {
            None
        };

        let model = ActiveModel {
            id: ActiveValue::set(id),
            tenant_id: ActiveValue::set(tenant_id),
            name: ActiveValue::set(name.to_string()),
            description: ActiveValue::set(description.to_string()),
            app_type: ActiveValue::set(app_type),
            app_id: ActiveValue::set(app_id.clone()),
            app_secret: ActiveValue::set(secret_hash),
            scopes: ActiveValue::set(vec![]),
            owner_id: ActiveValue::set(owner_id),
            status: ActiveValue::set(EntityStatus::Normal as i16),
            ..Default::default()
        }
        .insert(db)
        .await?;

        if let Some(bot_uid) = bot_user_id {
            open_app_bots::ActiveModel {
                id: ActiveValue::set(id_gen(Some(false))),
                app_id: ActiveValue::set(id),
                bot_user_id: ActiveValue::set(bot_uid),
                webhook_url: ActiveValue::set("".to_string()),
                webhook_secret: ActiveValue::set(auth::generate_app_secret()),
                event_types: ActiveValue::set(vec![]),
                status: ActiveValue::set(EntityStatus::Normal as i16),
                ..Default::default()
            }
            .insert(db)
            .await?;
        }

        Ok((Self(model), raw_secret, bot_user_id))
    }

    /// 查询返回时携带明文 secret 的包装（仅创建/轮换时使用）
    pub fn with_secret(&self, raw_secret: &str) -> serde_json::Value {
        serde_json::json!({
            "id": self.0.id.to_string(),
            "app_id": self.0.app_id,
            "app_secret": raw_secret,
            "name": self.0.name,
            "description": self.0.description,
            "app_type": self.0.app_type,
            "scopes": self.0.scopes,
            "owner_id": self.0.owner_id,
            "status": self.0.status,
            "created_at": self.0.created_at,
            "updated_at": self.0.updated_at,
        })
    }

    /// 转为 JSON 值（无 secret）
    pub fn to_json(&self) -> serde_json::Value {
        serde_json::json!({
            "id": self.0.id.to_string(),
            "app_id": self.0.app_id,
            "name": self.0.name,
            "description": self.0.description,
            "app_type": self.0.app_type,
            "scopes": self.0.scopes,
            "owner_id": self.0.owner_id,
            "status": self.0.status,
            "created_at": self.0.created_at,
            "updated_at": self.0.updated_at,
        })
    }

    pub async fn find_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Option<Self>> {
        let app = Entity::find_by_id(id)
            .filter(Column::DeletedAt.is_null())
            .one(db)
            .await?;
        Ok(app.map(Self))
    }

    pub async fn find_by_app_id(db: &DatabaseConnection, app_id: &str) -> ModelResult<Option<Self>> {
        let app = Entity::find()
            .filter(
                sea_orm::Condition::all()
                    .add(Column::AppId.eq(app_id))
                    .add(Column::DeletedAt.is_null()),
            )
            .one(db)
            .await?;
        Ok(app.map(Self))
    }

    pub async fn find_by_tenant(
        db: &DatabaseConnection,
        tenant_id: i64,
        page: i32,
        page_size: i32,
    ) -> ModelResult<(Vec<Self>, i64)> {
        let paginator = Entity::find()
            .filter(
                sea_orm::Condition::all()
                    .add(Column::TenantId.eq(tenant_id))
                    .add(Column::DeletedAt.is_null()),
            )
            .order_by_desc(Column::Id)
            .paginate(db, page_size as u64);
        let total = paginator.num_items().await?;
        let items = paginator.fetch_page((page - 1).max(0) as u64).await?;
        Ok((items.into_iter().map(Self).collect(), total as i64))
    }

    pub async fn update(
        db: &DatabaseConnection,
        app_id: &str,
        name: Option<&str>,
        description: Option<&str>,
        scopes: Option<Vec<String>>,
    ) -> ModelResult<Option<Self>> {
        let app = Self::find_by_app_id(db, app_id).await?;
        let Some(app) = app else {
            return Ok(None);
        };
        let mut active: ActiveModel = app.0.into();
        if let Some(name) = name {
            active.name = ActiveValue::set(name.to_string());
        }
        if let Some(description) = description {
            active.description = ActiveValue::set(description.to_string());
        }
        if let Some(scopes) = scopes {
            active.scopes = ActiveValue::set(scopes);
        }
        let model = active.update(db).await?;
        Ok(Some(Self(model)))
    }

    pub async fn soft_delete(db: &DatabaseConnection, app_id: &str) -> ModelResult<bool> {
        let app = Self::find_by_app_id(db, app_id).await?;
        let Some(app) = app else {
            return Ok(false);
        };
        let app_db_id = app.0.id;
        let mut active: ActiveModel = app.0.into();
        active.deleted_at = ActiveValue::set(Some(chrono::Utc::now().into()));
        active.status = ActiveValue::set(EntityStatus::Deleted as i16);
        active.update(db).await?;

        // 禁用 Bot 用户
        if let Ok(Some(bot)) = crate::models::bot::OpenAppBotModel::find_by_app(db, app_db_id).await {
            let db_user = users::Entity::find_by_id(bot.0.bot_user_id).one(db).await?;
            if let Some(u) = db_user {
                let mut u_active: users::ActiveModel = u.into();
                u_active.status = ActiveValue::set(EntityStatus::Deleted as i16);
                u_active.update(db).await?;
            }
        }

        Ok(true)
    }

    pub async fn rotate_secret(db: &DatabaseConnection, app_id: &str) -> ModelResult<Option<String>> {
        let app = Self::find_by_app_id(db, app_id).await?;
        let Some(app) = app else {
            return Ok(None);
        };
        let raw_secret = auth::generate_app_secret();
        let secret_hash = auth::hash_secret(&raw_secret);
        let mut active: ActiveModel = app.0.into();
        active.app_secret = ActiveValue::set(secret_hash);
        active.update(db).await?;
        Ok(Some(raw_secret))
    }

    /// 创建 Bot 用户
    pub async fn create_bot_user(
        db: &DatabaseConnection,
        app_db_id: i64,
        tenant_id: i64,
        name: &str,
    ) -> ModelResult<i64> {
        let id = id_gen(Some(false));
        info!("create bot user: id={id}, app_id={app_db_id}, tenant={tenant_id}");

        let bot_user = users::ActiveModel {
            id: ActiveValue::set(id),
            name: ActiveValue::set(format!("{name}_Bot")),
            a_id: ActiveValue::set(0),
            tenant_id: ActiveValue::set(tenant_id),
            pid: ActiveValue::set(uuid::Uuid::new_v4()),
            api_key: ActiveValue::set(uuid::Uuid::new_v4().to_string()),
            status: ActiveValue::set(EntityStatus::Normal as i16),
            r#type: ActiveValue::set(proto::idl::entity::UserType::Bot as i16),
            bot_app_id: ActiveValue::set(Some(app_db_id)),
            dept_id: ActiveValue::set(0),
            tenant_permision: ActiveValue::set(0),
            avatar: ActiveValue::set(None),
            version: ActiveValue::set(0),
            extra: ActiveValue::set(vec![]),
            ..Default::default()
        }
        .insert(db)
        .await?;

        Ok(bot_user.id)
    }

    pub async fn disable_bot_user(db: &DatabaseConnection, app_db_id: i64) -> ModelResult<()> {
        if let Ok(Some(bot)) = crate::models::bot::OpenAppBotModel::find_by_app(db, app_db_id).await {
            let u = users::Entity::find_by_id(bot.0.bot_user_id)
                .one(db)
                .await?;
            if let Some(user) = u {
                let mut active: users::ActiveModel = user.into();
                active.status = ActiveValue::set(EntityStatus::Deleted as i16);
                active.update(db).await?;
            }
        }
        Ok(())
    }
}
