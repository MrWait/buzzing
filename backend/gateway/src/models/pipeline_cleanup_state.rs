use loco_rs::{model::ModelResult, prelude::*};
use sea_orm::sea_query::OnConflict;
use sea_orm::{ConnectionTrait, Iterable};

pub use base::models::_entities::pipeline_cleanup_state::{
    ActiveModel, Column, Entity, Model,
};

// 单行表：固定主键 1，记录 pipeline TTL 清理的上次执行时间（unix 秒）。
pub const CLEANUP_STATE_ID: i16 = 1;

pub struct CleanupStateModel;

impl CleanupStateModel {
    /// 上次 TTL 清理执行时间（unix 秒），从未执行为 0。
    pub async fn get<C: ConnectionTrait>(db: &C) -> ModelResult<i64> {
        let row = Entity::find_by_id(CLEANUP_STATE_ID).one(db).await?;
        Ok(row.map(|r| r.last_run_at_secs).unwrap_or(0))
    }

    /// 记录本次 TTL 清理执行时间（upsert 单行）。
    pub async fn set<C: ConnectionTrait>(db: &C, last_run_at_secs: i64) -> ModelResult<()> {
        let model = ActiveModel {
            id: ActiveValue::Set(CLEANUP_STATE_ID),
            last_run_at_secs: ActiveValue::Set(last_run_at_secs),
            ..Default::default()
        };
        let pk = <Entity as EntityTrait>::PrimaryKey::iter();
        Entity::insert(model)
            .on_conflict(
                OnConflict::columns(pk.clone())
                    .update_columns([Column::LastRunAtSecs])
                    .to_owned(),
            )
            .exec(db)
            .await?;
        Ok(())
    }
}
