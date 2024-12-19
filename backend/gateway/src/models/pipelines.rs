use loco_rs::{model::ModelResult, prelude::*};
use sea_orm::PaginatorTrait;

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
}

impl Into<entity::Packet> for PipelineModel {
    fn into(self) -> entity::Packet {
        entity::Packet::default()
    }
}
