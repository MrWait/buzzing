use loco_rs::{model::ModelResult, prelude::*};
use prost::Message;
use sea_orm::{PaginatorTrait, QueryOrder};
use std::collections::HashMap;
use tracing::debug;

use crate::models::VecBool;
pub use base::models::_entities::messages::{self, ActiveModel, Column, Entity, Model};
use common::time::date_time;
use proto::idl::entity;

#[derive(Clone, Message)]
pub struct Reactions {
    #[prost(map = "int32, message", tag = "1")]
    pub reactions: HashMap<i32, entity::Reaction>,
}
impl Reactions {
    pub fn set(&mut self, index: i32, user_id: i64) -> bool {
        if let Some(ref mut reaction) = self.reactions.get_mut(&index) {
            if reaction.top_ids.contains(&user_id) {
                reaction.top_ids.retain(|id| *id != user_id);
            } else {
                reaction.top_ids.push(user_id);
            }
            reaction.total = reaction.top_ids.len() as i32;
        } else {
            self.reactions.insert(
                index,
                entity::Reaction {
                    total: 1,
                    me_read: false,
                    top_ids: vec![user_id],
                },
            );
        }
        true
    }
}

#[derive(Debug)]
pub struct MessageModel(pub Model);

impl MessageModel {
    pub async fn create_message(
        db: &DatabaseConnection,
        _user_id: i64,
        msg: &Model,
    ) -> ModelResult<Model> {
        let message = ActiveModel {
            id: ActiveValue::set(msg.id),
            r#type: ActiveValue::set(msg.r#type),
            chat_id: ActiveValue::set(msg.chat_id),
            from_id: ActiveValue::set(msg.from_id),
            pos: ActiveValue::set(msg.pos),
            badge: ActiveValue::set(msg.badge),
            status: ActiveValue::set(msg.status as i16),
            client_id: ActiveValue::set(msg.client_id),
            at_user_ids: ActiveValue::set(msg.at_user_ids.clone()),
            content: ActiveValue::set(msg.content.clone()),
            summary: ActiveValue::set(msg.summary.clone()),
            version: ActiveValue::set(0),
            ref_message_id: ActiveValue::set(msg.ref_message_id),
            ref_data: ActiveValue::set(msg.ref_data.clone()),
            cmv_id: ActiveValue::set(msg.cmv_id),
            cmv_count: ActiveValue::set(msg.cmv_count),
            read_count: ActiveValue::set(msg.read_count),
            read_states: ActiveValue::set(msg.read_states.clone()),
            reactions: ActiveValue::set(msg.reactions.clone()),
            extra: ActiveValue::set(vec![]),
            ..Default::default()
        }
        .insert(db)
        .await?;
        Ok(message)
    }

    pub async fn find_by_ids(db: &DatabaseConnection, ids: Vec<i64>) -> ModelResult<Vec<Model>> {
        let messages = Entity::find()
            .filter(model::query::condition().is_in(Column::Id, ids).build())
            .all(db)
            .await?;
        Ok(messages)
    }

    pub async fn find_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Model> {
        Entity::find()
            .filter(model::query::condition().eq(Column::Id, id).build())
            .one(db)
            .await?
            .ok_or(ModelError::EntityNotFound)
    }

    pub async fn find_by_pos(
        db: &DatabaseConnection,
        chat_id: i64,
        pos: Vec<i32>,
    ) -> ModelResult<Vec<Model>> {
        let messages = Entity::find()
            .filter(
                model::query::condition()
                    .eq(Column::ChatId, chat_id)
                    .is_in(Column::Pos, pos.to_vec())
                    .build(),
            )
            .all(db)
            .await?;
        debug!("find message by pos: {:?}, {:?}", chat_id, pos,);
        Ok(messages)
    }

    pub async fn find_by_range(
        db: &DatabaseConnection,
        chat_id: i64,
        pos: i32,
        count: i32,
    ) -> ModelResult<Vec<Model>> {
        let mut messages = Entity::find()
            .filter(
                model::query::condition()
                    .eq(Column::ChatId, chat_id)
                    .gte(Column::Pos, pos)
                    .build(),
            )
            .order_by_asc(Column::Pos)
            .paginate(db, count as u64);
        if let Some(messages) = messages.fetch_and_next().await? {
            debug!("find message by pos: {:?}, {:?}", chat_id, pos,);
            return Ok(messages);
        }

        Ok(vec![])
    }

    pub async fn message_get(db: &DatabaseConnection, id: i64) -> ModelResult<entity::Message> {
        Entity::find()
            .filter(model::query::condition().eq(Column::Id, id).build())
            .one(db)
            .await?
            .and_then(|msg| Some(Self(msg).into()))
            .ok_or(ModelError::EntityNotFound)
    }

    pub async fn set_read(
        db: &DatabaseConnection,
        id: i64,
        version: i64,
        read_state: &VecBool,
    ) -> ModelResult<()> {
        let message = ActiveModel {
            id: ActiveValue::set(id),
            read_states: ActiveValue::set(read_state.encode_to_vec()),
            version: ActiveValue::set(version),
            ..Default::default()
        };
        Entity::update(message).exec(db).await?;
        Ok(())
    }

    pub async fn set_reaction(
        db: &DatabaseConnection,
        id: i64,
        reactions: &Reactions,
        update_ms: i64,
    ) -> ModelResult<()> {
        let message = ActiveModel {
            id: ActiveValue::set(id),
            reactions: ActiveValue::set(reactions.encode_to_vec()),
            updated_at: ActiveValue::set(date_time(update_ms)),
            version: ActiveValue::set(update_ms),
            ..Default::default()
        };
        Entity::update(message).exec(db).await?;
        Ok(())
    }

    pub async fn set_status(db: &DatabaseConnection, id: i64, ts: i64, status: i16) -> Result<()> {
        let message = ActiveModel {
            id: ActiveValue::set(id),
            status: ActiveValue::set(status),
            version: ActiveValue::set(ts),
            ..Default::default()
        };
        Entity::update(message).exec(db).await?;
        Ok(())
    }
}

impl Into<entity::Message> for MessageModel {
    fn into(self) -> entity::Message {
        entity::Message {
            id: self.0.id,
            tpy: self.0.r#type as i32,
            chat_id: self.0.chat_id,
            from_id: self.0.from_id,
            pos: self.0.pos,
            badge_count: self.0.badge,
            status: self.0.status as i32,
            create_time_ms: self.0.created_at.timestamp_millis(),
            update_time_ms: self.0.updated_at.timestamp_millis(),
            at_user_ids: self.0.at_user_ids,
            content: self.0.content,
            summary: self.0.summary,
            client_id: self.0.client_id,
            version: self.0.version,
            reactions: std::collections::HashMap::new(),
            read_state: None,
            ref_message_id: self.0.ref_message_id,
            ref_data: if self.0.ref_data.is_empty() {
                None
            } else {
                entity::MessageReference::decode(self.0.ref_data.as_slice()).ok()
            },
        }
    }
}

impl From<entity::Message> for MessageModel {
    fn from(mut message: entity::Message) -> Self {
        Self(Model {
            created_at: date_time(message.create_time_ms),
            updated_at: date_time(message.update_time_ms),
            id: message.id,
            r#type: message.tpy as i16,
            chat_id: message.chat_id,
            from_id: message.from_id,
            pos: message.pos,
            badge: message.badge_count,
            status: message.status as i16,
            client_id: message.client_id,
            at_user_ids: std::mem::take(&mut message.at_user_ids),
            content: std::mem::take(&mut message.content),
            summary: std::mem::take(&mut message.summary),
            version: message.version,
            ref_message_id: message.ref_message_id,
            ref_data: message
                .ref_data
                .take()
                .map(|r| r.encode_to_vec())
                .unwrap_or_default(),
            cmv_id: 0,
            cmv_count: 0,
            read_count: 0,
            read_states: vec![],
            reactions: vec![],
            extra: vec![],
        })
    }
}
