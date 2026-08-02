use loco_rs::{model::ModelError, model::ModelResult, prelude::*};
use sea_orm::{ActiveValue, Condition, QueryOrder, QuerySelect};

pub use base::models::_entities::documents::{ActiveModel, Column, Entity, Model};

#[derive(Debug)]
pub struct DocumentModel(pub Model);

impl DocumentModel {
    pub async fn get_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Option<Model>> {
        Ok(Entity::find_by_id(id).one(db).await?)
    }

    /// 知识库下未删除的文档
    pub async fn get_by_wiki_id(
        db: &DatabaseConnection,
        wiki_id: i64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(
                Condition::all()
                    .add(Column::WikiId.eq(Some(wiki_id)))
                    .add(Column::TrashedAt.is_null()),
            )
            .all(db)
            .await?)
    }

    /// 个人文档树（wiki_id IS NULL）
    pub async fn get_personal_tree(
        db: &DatabaseConnection,
        creator: i64,
        tenant_id: i64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(
                Condition::all()
                    .add(Column::WikiId.is_null())
                    .add(Column::Creator.eq(creator))
                    .add(Column::TenantId.eq(tenant_id))
                    .add(Column::TrashedAt.is_null()),
            )
            .order_by_desc(Column::CreatedAt)
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

    /// 知识库下未删除的全部文档（用于内存组装树）
    pub async fn get_wiki_tree_flat(
        db: &DatabaseConnection,
        wiki_id: i64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(
                Condition::all()
                    .add(Column::WikiId.eq(Some(wiki_id)))
                    .add(Column::TrashedAt.is_null()),
            )
            .order_by_desc(Column::CreatedAt)
            .all(db)
            .await?)
    }

    /// 回收站列表
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

    /// 当前用户创建的文档（未删除）
    pub async fn get_by_creator(
        db: &DatabaseConnection,
        user_id: i64,
        tenant_id: i64,
    ) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(
                Condition::all()
                    .add(Column::Creator.eq(user_id))
                    .add(Column::TenantId.eq(tenant_id))
                    .add(Column::TrashedAt.is_null()),
            )
            .order_by_desc(Column::UpdatedAt)
            .all(db)
            .await?)
    }

    /// 与当前用户共享的文档（用户有访问权限但不是创建者）
    pub async fn get_shared_with_user(
        db: &DatabaseConnection,
        user_id: i64,
        _tenant_id: i64,
    ) -> ModelResult<Vec<Model>> {
        use sea_orm::QuerySelect;
        use base::models::_entities::wiki_members;
        // 查询用户有权限的知识库 ID 列表
        let wiki_ids: Vec<i64> = wiki_members::Entity::find()
            .select_only()
            .column(wiki_members::Column::WikiId)
            .filter(
                Condition::all()
                    .add(wiki_members::Column::UserId.eq(user_id))
                    .add(wiki_members::Column::Role.gte(0)),
            )
            .into_tuple::<i64>()
            .all(db)
            .await?;
        if wiki_ids.is_empty() {
            return Ok(vec![]);
        }
        Ok(Entity::find()
            .filter(
                Condition::all()
                    .add(Column::WikiId.is_in(wiki_ids))
                    .add(Column::WikiId.is_not_null())
                    .add(Column::Creator.ne(user_id))
                    .add(Column::TrashedAt.is_null()),
            )
            .order_by_desc(Column::UpdatedAt)
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

    /// 超过 `days` 天的回收站文档
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

    pub async fn trash(db: &DatabaseConnection, id: i64) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?
            .into();
        model.trashed_at = ActiveValue::set(Some(chrono::Utc::now().into()));
        Ok(model.update(db).await?)
    }

    pub async fn restore(db: &DatabaseConnection, id: i64) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?
            .into();
        model.trashed_at = ActiveValue::set(None);
        Ok(model.update(db).await?)
    }

    pub async fn purge(db: &DatabaseConnection, id: i64) -> ModelResult<()> {
        Entity::delete_by_id(id).exec(db).await?;
        Ok(())
    }

    /// 移动到新父级
    pub async fn move_to(
        db: &DatabaseConnection,
        id: i64,
        parent_id: Option<Option<i64>>,
    ) -> ModelResult<Model> {
        let mut model: ActiveModel = Entity::find_by_id(id)
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)?
            .into();
        if let Some(p) = parent_id {
            model.parent_id = ActiveValue::set(p);
        }
        Ok(model.update(db).await?)
    }

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

    pub async fn delete(db: &DatabaseConnection, id: i64) -> ModelResult<()> {
        Self::trash(db, id).await?;
        Ok(())
    }

    /// 追溯文档父链，返回 [root, ..., current] 顺序
    /// 个人空间：遇到 parent_id == user_id 时插入虚拟根节点（个人空间）并停止
    /// 知识库：文档链尾部插入 wiki 根节点（id=wiki_id, title=wiki 名称）
    pub async fn get_doc_path(
        db: &DatabaseConnection,
        doc_id: i64,
        user_id: i64,
    ) -> ModelResult<Vec<crate::controllers::docs::WalkItem>> {
        use std::collections::HashSet;
        let mut items = Vec::new();
        let mut cursor = Some(doc_id);
        let mut visited = HashSet::new();
        let mut wiki_id: Option<i64> = None;
        while let Some(id) = cursor {
            if !visited.insert(id) {
                break;
            }
            // 虚拟根节点：parent_id 指向 user_id
            if id == user_id {
                items.push(crate::controllers::docs::WalkItem {
                    id: user_id.to_string(),
                    title: "个人空间".to_string(),
                    icon: None,
                    kind: "user".to_string(),
                });
                break;
            }
            let doc = match Entity::find_by_id(id).one(db).await? {
                Some(d) => d,
                None => break,
            };
            if wiki_id.is_none() {
                wiki_id = doc.wiki_id;
            }
            items.push(crate::controllers::docs::WalkItem {
                id: doc.id.to_string(),
                title: doc.title,
                icon: doc.icon.clone(),
                kind: "doc".to_string(),
            });
            cursor = doc.parent_id;
        }
        items.reverse();
        // 知识库文档：在文档链最前面插入 wiki 根节点
        if let Some(wid) = wiki_id {
            if let Some(wiki) = crate::models::wikis::WikiModel::get_by_id(db, wid).await? {
                items.insert(
                    0,
                    crate::controllers::docs::WalkItem {
                        id: wid.to_string(),
                        title: wiki.name,
                        icon: wiki.icon,
                        kind: "wiki".to_string(),
                    },
                );
            }
        }
        Ok(items)
    }
}
