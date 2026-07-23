use loco_rs::{model::ModelResult, prelude::*};
use sea_orm::{QueryOrder, QuerySelect};
use sea_orm::sea_query::Query;

pub use base::models::_entities::wikis::{ActiveModel, Column, Entity, Model};

pub struct WikiModel;

impl WikiModel {
    pub async fn get_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Option<Model>> {
        Ok(Entity::find_by_id(id).one(db).await?)
    }

    /// 租户下所有知识库
    pub async fn list_by_tenant(
        db: &DatabaseConnection,
        tenant_id: i64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(Column::TenantId.eq(tenant_id))
            .order_by_desc(Column::CreatedAt)
            .all(db)
            .await?)
    }

    /// 用户参与的知识库（通过 wiki_members 或 creator）
    pub async fn list_accessible(
        db: &DatabaseConnection,
        tenant_id: i64,
        user_id: i64,
    ) -> ModelResult<Vec<Model>> {
        use base::models::_entities::wiki_members::Column as WmCol;
        use sea_orm::Condition;
        // 返回用户创建的 + 被添加为成员的知识库
        Ok(Entity::find()
            .filter(Column::TenantId.eq(tenant_id))
            .filter(
                Condition::any()
                    .add(Column::CreatorId.eq(user_id))
                    .add(
                        Column::Id.in_subquery(
                            Query::select()
                                .column(WmCol::WikiId)
                                .from(base::models::_entities::wiki_members::Entity)
                                .and_where(WmCol::UserId.eq(user_id))
                                .take(),
                        ),
                    ),
            )
            .order_by_desc(Column::CreatedAt)
            .all(db)
            .await?)
    }

    pub async fn create(db: &DatabaseConnection, params: ActiveModel) -> ModelResult<Model> {
        Ok(params.insert(db).await?)
    }

    pub async fn update(db: &DatabaseConnection, id: i64, params: ActiveModel) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(loco_rs::model::ModelError::EntityNotFound)?
            .into();
        if let ActiveValue::Set(v) = params.name {
            model.name = ActiveValue::Set(v);
        }
        if let ActiveValue::Set(v) = params.description {
            model.description = ActiveValue::Set(v);
        }
        if let ActiveValue::Set(v) = params.icon {
            model.icon = ActiveValue::Set(v);
        }
        if let ActiveValue::Set(v) = params.cover {
            model.cover = ActiveValue::Set(v);
        }
        Ok(model.update(db).await?)
    }

    pub async fn delete(db: &DatabaseConnection, id: i64) -> ModelResult<()> {
        Entity::delete_by_id(id).exec(db).await?;
        Ok(())
    }
}
