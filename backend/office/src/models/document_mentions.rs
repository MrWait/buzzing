use loco_rs::{model::ModelResult, prelude::*};
use sea_orm::ActiveValue;

pub use base::models::_entities::document_mentions::{ActiveModel, Column, Entity, Model};

pub struct DocumentMentionModel;

impl DocumentMentionModel {
    /// 列出文档中所有提及
    pub async fn list_by_doc(db: &DatabaseConnection, doc_id: i64) -> ModelResult<Vec<Model>> {
        Ok(Entity::find()
            .filter(Column::DocId.eq(doc_id))
            .all(db)
            .await?)
    }

    /// 覆盖写入：删除旧记录后批量插入
    pub async fn replace(
        db: &DatabaseConnection,
        doc_id: i64,
        mentioned_by: i64,
        mentions: Vec<(String, String)>, // (mentioned_type, mentioned_id)
        now_ms: i64,
    ) -> ModelResult<()> {
        // 删除旧记录
        Entity::delete_many()
            .filter(Column::DocId.eq(doc_id))
            .exec(db)
            .await?;
        // 插入新记录
        for (mtype, mid) in mentions {
            let id = common::id_gen(None);
            let am = ActiveModel {
                id: ActiveValue::Set(id),
                doc_id: ActiveValue::Set(doc_id),
                mentioned_type: ActiveValue::Set(mtype),
                mentioned_id: ActiveValue::Set(mid),
                mentioned_by: ActiveValue::Set(mentioned_by),
                created_at: ActiveValue::Set(now_ms),
            };
            am.insert(db).await?;
        }
        Ok(())
    }
}
