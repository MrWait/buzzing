use loco_rs::{model::ModelError, model::ModelResult, prelude::*};
use sea_orm::{ActiveValue, Condition, QueryOrder, QuerySelect};

pub use base::models::_entities::documents::{ActiveModel, Column, Entity, Model};

#[derive(Debug)]
pub struct DocumentModel(pub Model);

impl DocumentModel {
    pub async fn get_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Option<Model>> {
        Ok(Entity::find_by_id(id).one(db).await?)
    }

    /// 空间下未删除的文档
    pub async fn get_by_space_id(
        db: &DatabaseConnection,
        space_id: i64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(
                Condition::all()
                    .add(Column::SpaceId.eq(space_id))
                    .add(Column::TrashedAt.is_null()),
            )
            .all(db)
            .await?)
    }

    /// 某父页面下的直接子页面
    pub async fn get_children(
        db: &DatabaseConnection,
        parent_id: i64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(
                Condition::all()
                    .add(Column::ParentId.eq(parent_id))
                    .add(Column::TrashedAt.is_null()),
            )
            .all(db)
            .await?)
    }

    /// 空间下未删除的全部文档（用于内存组装树）
    pub async fn get_space_tree_flat(
        db: &DatabaseConnection,
        space_id: i64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(
                Condition::all()
                    .add(Column::SpaceId.eq(space_id))
                    .add(Column::TrashedAt.is_null()),
            )
            .order_by_desc(Column::CreatedAt)
            .all(db)
            .await?)
    }

    /// 回收站列表 (tenant + creator = user 且 trashed_at 非空)
    pub async fn list_trashed(
        db: &DatabaseConnection,
        tenant_id: i64,
        creator: i64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(
                Condition::all()
                    .add(Column::TenantId.eq(tenant_id))
                    .add(Column::Creator.eq(creator))
                    .add(Column::TrashedAt.is_not_null()),
            )
            .order_by_desc(Column::TrashedAt)
            .all(db)
            .await?)
    }

    /// 按 ID 批量查询
    pub async fn get_by_ids(
        db: &DatabaseConnection,
        ids: &[i64],
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(Column::Id.is_in(ids.iter().copied()))
            .all(db)
            .await?)
    }

    /// 超过 `days` 天的回收站文档 (定时 purge 使用)
    pub async fn list_expired_trashed(
        db: &DatabaseConnection,
        expired_before: chrono::DateTime<chrono::Utc>,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(Column::TrashedAt.lt(expired_before))
            .limit(500)
            .all(db)
            .await?)
    }

    pub async fn create(db: &DatabaseConnection, params: ActiveModel) -> ModelResult<Model> {
        Ok(params.insert(db).await?)
    }

    pub async fn update_title(
        db: &DatabaseConnection,
        id: i64,
        title: String,
        version: i64,
    ) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?
            .into();
        model.title = ActiveValue::set(title);
        model.version = ActiveValue::set(version);
        Ok(model.update(db).await?)
    }

    pub async fn update_content(
        db: &DatabaseConnection,
        id: i64,
        content: Vec<u8>,
        version: i64,
    ) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?
            .into();
        model.content = ActiveValue::set(content);
        model.version = ActiveValue::set(version);
        Ok(model.update(db).await?)
    }

    /// 软删除：设置 trashed_at
    pub async fn trash(db: &DatabaseConnection, id: i64) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?
            .into();
        model.trashed_at = ActiveValue::set(Some(chrono::Utc::now().into()));
        Ok(model.update(db).await?)
    }

    /// 恢复：清空 trashed_at
    pub async fn restore(db: &DatabaseConnection, id: i64) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?
            .into();
        model.trashed_at = ActiveValue::set(None);
        Ok(model.update(db).await?)
    }

    /// 永久删除
    pub async fn purge(db: &DatabaseConnection, id: i64) -> ModelResult<()> {
        Entity::delete_by_id(id).exec(db).await?;
        Ok(())
    }

    /// 移动到新空间 / 新父级
    pub async fn move_to(
        db: &DatabaseConnection,
        id: i64,
        space_id: Option<i64>,
        parent_id: Option<Option<i64>>,
    ) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?
            .into();
        if let Some(sp) = space_id {
            model.space_id = ActiveValue::set(sp);
        }
        if let Some(p) = parent_id {
            model.parent_id = ActiveValue::set(p);
        }
        Ok(model.update(db).await?)
    }

    /// 更新元数据 icon / cover
    pub async fn update_meta(
        db: &DatabaseConnection,
        id: i64,
        icon: Option<Option<String>>,
        cover: Option<Option<String>>,
    ) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?
            .into();
        if let Some(i) = icon {
            model.icon = ActiveValue::set(i);
        }
        if let Some(c) = cover {
            model.cover = ActiveValue::set(c);
        }
        Ok(model.update(db).await?)
    }

    /// 兼容旧调用：等价于软删除
    pub async fn delete(db: &DatabaseConnection, id: i64) -> ModelResult<()> {
        Self::trash(db, id).await?;
        Ok(())
    }
}
