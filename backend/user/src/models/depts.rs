use loco_rs::model::{self, ModelError, ModelResult};
use loco_rs::prelude::*;
use sea_orm::ActiveValue;
use std::collections::HashSet;

pub use base::models::_entities::depts::{self, ActiveModel, Entity};
use common::id_gen;
use proto::idl::entity;

pub type Depts = Entity;

#[derive(Debug)]
pub struct Model(pub depts::Model);

impl Model {
    pub async fn find_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Self> {
        let dept = depts::Entity::find()
            .filter(model::query::condition().eq(depts::Column::Id, id).build())
            .one(db)
            .await?;
        Ok(Self(dept.ok_or_else(|| ModelError::EntityNotFound)?))
    }

    pub async fn find_by_ids(db: &DatabaseConnection, ids: &[i64]) -> ModelResult<Vec<Self>> {
        let mut depts = depts::Entity::find()
            .filter(
                model::query::condition()
                    .is_in(depts::Column::Id, ids.iter().cloned())
                    .build(),
            )
            .all(db)
            .await?;
        Ok(depts.drain(..).map(|d| Self(d)).collect())
    }
    pub async fn find_by_parent_id(
        db: &DatabaseConnection,
        parent_id: i64,
    ) -> ModelResult<Vec<Self>> {
        let mut depts = depts::Entity::find()
            .filter(
                model::query::condition()
                    .eq(depts::Column::ParentId, parent_id)
                    .build(),
            )
            .all(db)
            .await?;
        // check if still sub dept
        let mut outdate_ids = HashSet::new();
        depts.retain(|dept| {
            if dept.parent_id != parent_id {
                outdate_ids.insert(dept.id);
                false
            } else {
                true
            }
        });

        if !outdate_ids.is_empty() {
            // remove from
            let dept = depts::Entity::find()
                .filter(
                    model::query::condition()
                        .eq(depts::Column::Id, parent_id)
                        .build(),
                )
                .one(db)
                .await?
                .ok_or(ModelError::EntityNotFound)?;
            let mut sub_ids = dept.sub_ids.clone();
            let mut dept = dept.into_active_model();
            sub_ids.retain(|id| !outdate_ids.contains(id));
            dept.sub_ids = ActiveValue::set(sub_ids);
            dept.save(db).await?;
        }
        Ok(depts.drain(..).map(|d| Self(d)).collect())
    }

    pub async fn create(
        db: &DatabaseConnection,
        name: &str,
        parent_id: i64,
        tenant_id: i64,
    ) -> ModelResult<Self> {
        let id = id_gen(None);
        let dept = depts::ActiveModel {
            id: ActiveValue::set(id),
            parent_id: ActiveValue::set(parent_id),
            name: ActiveValue::set(name.to_string()),
            tenant_id: ActiveValue::set(tenant_id),
            extra: ActiveValue::set(vec![]),
            ..Default::default()
        }
        .insert(db)
        .await?;
        Ok(Self(dept))
    }

    pub async fn join_dept(
        db: &DatabaseConnection,
        parent_id: i64,
        dept_ids: &[i64],
    ) -> ModelResult<()> {
        let txn = db.begin().await?;
        let dept = depts::ActiveModel {
            parent_id: ActiveValue::set(parent_id),
            ..Default::default()
        };
        depts::Entity::update(dept)
            .filter(
                model::query::condition()
                    .is_in(depts::Column::Id, dept_ids.iter().cloned())
                    .build(),
            )
            .exec(&txn)
            .await?;
        let dept = depts::Entity::find()
            .filter(
                model::query::condition()
                    .eq(depts::Column::Id, parent_id)
                    .build(),
            )
            .one(&txn)
            .await?
            .ok_or(ModelError::EntityNotFound)?;
        let mut sub_ids = dept.sub_ids.clone();
        let mut dept = dept.into_active_model();
        sub_ids.extend_from_slice(dept_ids);
        dept.sub_ids = ActiveValue::set(sub_ids);
        dept.save(&txn).await?;

        txn.commit().await?;
        Err(ModelError::EntityNotFound)
    }

    pub async fn move_dept(
        _db: &DatabaseConnection,
        _dept_ids: &[i64],
        _parent_id: i64,
    ) -> ModelResult<()> {
        Err(ModelError::EntityNotFound)
    }

    pub async fn join_users(
        _db: &DatabaseConnection,
        _id: i64,
        _user_ids: &[i64],
    ) -> ModelResult<()> {
        Err(ModelError::EntityNotFound)
    }

    pub async fn move_user(
        _db: &DatabaseConnection,
        _user_ids: &[i64],
        _parent_id: i64,
    ) -> ModelResult<()> {
        Err(ModelError::EntityNotFound)
    }

    pub async fn update() -> ModelResult<()> {
        Ok(())
    }

    pub async fn delete() -> ModelResult<()> {
        Ok(())
    }
}

impl Into<entity::Department> for Model {
    fn into(self) -> entity::Department {
        entity::Department {
            id: self.0.id,
            parent_id: self.0.parent_id,
            tenant_id: self.0.tenant_id,
            member_ids: self.0.member_ids,
            sub_department_ids: self.0.sub_ids,
            name: self.0.name,
            version: self.0.version,
        }
    }
}

impl From<depts::Model> for Model {
    fn from(value: depts::Model) -> Self {
        Self(value)
    }
}
