use loco_rs::{model::ModelError, model::ModelResult, prelude::*};
use sea_orm::{Condition, QueryOrder};

pub use base::models::_entities::document_spaces::{ActiveModel, Column, Entity, Model};

#[derive(Debug)]
pub struct DocumentSpaceModel(pub Model);

impl DocumentSpaceModel {
    pub async fn get_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Option<Model>> {
        Ok(Entity::find_by_id(id).one(db).await?)
    }

    /// 未归档的空间，按 sort_order 排序
    pub async fn get_by_creator(
        db: &DatabaseConnection,
        creator: i64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(
                Condition::all()
                    .add(Column::Creator.eq(creator))
                    .add(Column::ArchivedAt.is_null()),
            )
            .order_by_asc(Column::SortOrder)
            .order_by_asc(Column::CreatedAt)
            .all(db)
            .await?)
    }

    /// 已归档的空间列表
    pub async fn list_archived(
        db: &DatabaseConnection,
        creator: i64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(
                Condition::all()
                    .add(Column::Creator.eq(creator))
                    .add(Column::ArchivedAt.is_not_null()),
            )
            .order_by_desc(Column::ArchivedAt)
            .all(db)
            .await?)
    }

    pub async fn create(db: &DatabaseConnection, params: ActiveModel) -> ModelResult<Model> {
        Ok(params.insert(db).await?)
    }

    pub async fn update_name(
        db: &DatabaseConnection,
        id: i64,
        name: String,
    ) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?
            .into();
        model.name = ActiveValue::set(name);
        Ok(model.update(db).await?)
    }

    /// 更新元数据 (icon/color/sort_order)
    pub async fn update_meta(
        db: &DatabaseConnection,
        id: i64,
        name: Option<String>,
        icon: Option<Option<String>>,
        color: Option<Option<String>>,
        sort_order: Option<i32>,
    ) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?
            .into();
        if let Some(n) = name {
            model.name = ActiveValue::set(n);
        }
        if let Some(i) = icon {
            model.icon = ActiveValue::set(i);
        }
        if let Some(c) = color {
            model.color = ActiveValue::set(c);
        }
        if let Some(s) = sort_order {
            model.sort_order = ActiveValue::set(s);
        }
        Ok(model.update(db).await?)
    }

    /// 归档 / 取消归档
    pub async fn set_archived(
        db: &DatabaseConnection,
        id: i64,
        archived: bool,
    ) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?
            .into();
        model.archived_at = ActiveValue::set(if archived {
            Some(chrono::Utc::now().into())
        } else {
            None
        });
        Ok(model.update(db).await?)
    }

    pub async fn delete(db: &DatabaseConnection, id: i64) -> ModelResult<()> {
        Entity::delete_by_id(id).exec(db).await?;
        Ok(())
    }
}
