use loco_rs::{model::ModelResult, prelude::*};
use sea_orm::{ConnectionTrait, PaginatorTrait, QueryOrder};

pub use base::models::_entities::pipelines::{self, ActiveModel, Entity};
use proto::idl::entity;

pub type Pipelines = Entity;

#[allow(dead_code)]
#[derive(Debug)]
pub struct PipelineModel(pub pipelines::Model);

// implement your read-oriented logic here
impl PipelineModel {
    pub async fn find_by_sid(
        db: &DatabaseConnection,
        user_id: i64,
        sid: i64,
        limit: u64,
    ) -> ModelResult<Vec<Self>> {
        let mut pipes = Entity::find()
            .filter(
                model::query::condition()
                    .eq(pipelines::Column::UserId, user_id)
                    .gt(pipelines::Column::Sid, sid)
                    .build(),
            )
            .order_by_asc(pipelines::Column::Sid)
            .paginate(db, limit)
            .fetch()
            .await?;
        Ok(pipes.drain(..).map(|p| Self(p).into()).collect())
    }

    pub async fn save_packet(
        db: &DatabaseConnection,
        user_ids: &[i64],
        sid: i64,
        cmd: i32,
        body: &[u8],
    ) -> ModelResult<()> {
        let pipes: Vec<ActiveModel> = user_ids
            .iter()
            .map(|id| ActiveModel {
                user_id: ActiveValue::set(*id),
                sid: ActiveValue::set(sid),
                command: ActiveValue::set(cmd),
                data: ActiveValue::set(body.to_vec()),
                ..Default::default()
            })
            .collect();
        let res = Pipelines::insert_many(pipes).exec(db).await?;
        tracing::debug!("save packets ok: {res:?}");
        Ok(())
    }

    /// 用户当前最大 sid（全新安装/过期重置时返回，表示无需回放已有数据），无行为 0。
    pub async fn find_max_sid(db: &DatabaseConnection, user_id: i64) -> ModelResult<i64> {
        let row = Entity::find()
            .filter(
                model::query::condition()
                    .eq(pipelines::Column::UserId, user_id)
                    .build(),
            )
            .order_by_desc(pipelines::Column::Sid)
            .one(db)
            .await?;
        Ok(row.map(|r| r.sid).unwrap_or(0))
    }

    /// TTL 清理：查询 created_at 早于 cutoff_ms 的行，返回 (user_id, sid) 集合。
    /// 注意：拉取不再删除数据（多设备共享），清理仅由 TTL worker 执行。
    pub async fn find_expired<C: ConnectionTrait>(
        db: &C,
        cutoff_ms: i64,
    ) -> ModelResult<Vec<(i64, i64)>> {
        let rows = Entity::find()
            .filter(
                model::query::condition()
                    .lt(pipelines::Column::CreatedAt, common::time::date_time(cutoff_ms))
                    .build(),
            )
            .all(db)
            .await?;
        Ok(rows.into_iter().map(|r| (r.user_id, r.sid)).collect())
    }

    /// TTL 清理：删除 created_at 早于 cutoff_ms 的所有行。
    pub async fn delete_expired<C: ConnectionTrait>(
        db: &C,
        cutoff_ms: i64,
    ) -> ModelResult<()> {
        Entity::delete_many()
            .filter(
                model::query::condition()
                    .lt(pipelines::Column::CreatedAt, common::time::date_time(cutoff_ms))
                    .build(),
            )
            .exec(db)
            .await?;
        Ok(())
    }
}

impl Into<entity::Packet> for PipelineModel {
    fn into(self) -> entity::Packet {
        entity::Packet {
            rid: self.0.sid,
            code: 0,
            cmd: self.0.command,
            http: false,
            payload: self.0.data,
        }
    }
}
