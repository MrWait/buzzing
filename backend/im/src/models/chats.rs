use loco_rs::{model::ModelResult, prelude::*};
use prost::Message;
use tracing::debug;

use super::{Cmv, cmvs, feeds};
pub use base::models::_entities::chats::{ActiveModel, Column, Entity, Model};
use common::current_ms;
use common::{EntityStatus, EntityType, Steper, cost, id_gen, peer_pair};
use proto::idl::entity;

#[derive(Debug)]
pub struct ChatModel(pub Model);

#[derive(prost::Message)]
pub struct ChatExtra {
    #[prost(int32, tag = "1")]
    pub color: i32,
    #[prost(string, tag = "2")]
    pub avatar: String,
}

impl ChatModel {
    pub async fn find_p2p_chat(
        db: &DatabaseConnection,
        user_id: i64,
        peer_id: i64,
    ) -> ModelResult<Model> {
        let (peer_a, peer_b) = peer_pair(user_id, peer_id);
        Entity::find()
            .filter(
                model::query::condition()
                    .eq(Column::PeerAId, peer_a)
                    .eq(Column::PeerBId, peer_b)
                    .build(),
            )
            .one(db)
            .await?
            .ok_or_else(|| ModelError::EntityNotFound)
    }

    async fn create_chat_with_feed(
        db: &DatabaseConnection,
        chat_id: i64,
        mut chat: ActiveModel,
        member_ids: &[i64],
    ) -> ModelResult<Model> {
        let mut step = Steper::new("create_chat_with_feed");

        let cmv_id = id_gen(None);
        let chat_cmv = super::Cmv::new(cmv_id, member_ids);
        let txn = db.begin().await?;
        step.s();

        chat.cmv = ActiveValue::set(chat_cmv.to());
        let _cmv = cmvs::ActiveModel {
            id: ActiveValue::set(cmv_id),
            cmv: ActiveValue::set(chat_cmv.cmv.to_vec()),
            chat_id: ActiveValue::set(chat_id),
            count: ActiveValue::set(chat_cmv.count),
            create_at_ms: ActiveValue::set(current_ms() as i64),
            ..Default::default()
        }
        .insert(&txn)
        .await?;
        step.s();

        let db_chat = chat.insert(&txn).await?;
        step.s();

        let feeds: Vec<_> = member_ids
            .iter()
            .map(|id| feeds::feeds::ActiveModel {
                entity_id: ActiveValue::set(chat_id),
                entity_type: ActiveValue::set(EntityType::Chat as i32),
                user_id: ActiveValue::set(*id),
                refer_id: ActiveValue::set(0),
                refer_pos: ActiveValue::set(0),
                refer_badge: ActiveValue::set(0),
                read_pos: ActiveValue::set(0),
                read_badge: ActiveValue::set(0),
                update_ms: ActiveValue::set(current_ms() as i64),
                rank_time_ms: ActiveValue::set(current_ms() as i64),
                version: ActiveValue::set(0),
                status: ActiveValue::set(EntityStatus::Normal as i32),
                is_top: ActiveValue::set(0),
                is_mute: ActiveValue::set(0),
                extra: ActiveValue::set(vec![]),
                ..Default::default()
            })
            .collect();
        debug!("insert new feeds: {:?}", feeds);
        step.s();

        feeds::Feeds::insert_many(feeds).exec(&txn).await?;

        step.s();
        txn.commit().await?;
        step.s();
        Ok(db_chat)
    }

    pub async fn create_p2p_chat(
        db: &DatabaseConnection,
        user_id: i64,
        peer_id: i64,
    ) -> ModelResult<Model> {
        let (peer_a, peer_b) = peer_pair(user_id, peer_id);
        let id = id_gen(None);
        let mut member_ids = vec![user_id];
        if user_id != peer_id {
            member_ids.push(peer_id);
        }
        let chat = ActiveModel {
            id: ActiveValue::set(id),
            r#type: ActiveValue::set(entity::ChatType::ChatP2p as i16),
            status: ActiveValue::set(EntityStatus::Normal as i16),
            name: ActiveValue::set("".to_string()),
            owner_id: ActiveValue::set(0),
            peer_a_id: ActiveValue::set(peer_a),
            peer_b_id: ActiveValue::set(peer_b),
            last_message_id: ActiveValue::set(0),
            last_message_pos: ActiveValue::set(0),
            last_message_badge: ActiveValue::set(0),
            admin_ids: ActiveValue::set(vec![]),
            version: ActiveValue::set(0),
            extra: ActiveValue::set(vec![]),
            ..Default::default()
        };

        Self::create_chat_with_feed(db, id, chat, &member_ids).await
    }

    pub async fn update_last_message(
        db: &DatabaseConnection,
        chat: &Model,
        msg: &super::messages::Model,
    ) -> ModelResult<()> {
        cost!("update_last_message");
        let txn = db.begin().await?;
        let entity = ActiveModel {
            id: ActiveValue::set(chat.id),
            last_message_id: ActiveValue::set(msg.id),
            last_message_badge: ActiveValue::set(msg.badge),
            last_message_pos: ActiveValue::set(msg.pos),
            ..Default::default()
        };
        Entity::update(entity).exec(&txn).await?;

        let _message = super::messages::ActiveModel {
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
            // 版本字段取内存中已初始化的值（chat.rs update_last_message 里以 now_ms 初始化），
            // 不能写死 0：push_messages 推送按 id 从 DB 重查，版本为 0 会让各端版本守卫/脏标记失效
            version: ActiveValue::set(msg.version),
            readstate_version: ActiveValue::set(msg.readstate_version),
            reaction_version: ActiveValue::set(msg.reaction_version),
            thread_root_id: ActiveValue::set(msg.thread_root_id),
            cmv_id: ActiveValue::set(msg.cmv_id),
            cmv_count: ActiveValue::set(msg.cmv_count),
            read_count: ActiveValue::set(msg.read_count),
            read_states: ActiveValue::set(msg.read_states.clone()),
            reactions: ActiveValue::set(msg.reactions.clone()),
            extra: ActiveValue::set(vec![]),
            ..Default::default()
        }
        .insert(&txn)
        .await?;

        txn.commit().await?;
        Ok(())
    }

    pub async fn create_group_chat(
        db: &DatabaseConnection,
        user_id: i64,
        origin_chat: &entity::Chat,
    ) -> ModelResult<Model> {
        let id = id_gen(None);
        let extra = (ChatExtra {
            color: origin_chat.color,
            avatar: origin_chat.avatar.clone(),
        })
        .encode_to_vec();
        let chat = ActiveModel {
            id: ActiveValue::set(id),
            r#type: ActiveValue::set(entity::ChatType::ChatGroup as i16),
            status: ActiveValue::set(EntityStatus::Normal as i16),
            name: ActiveValue::set(origin_chat.name.clone()),
            owner_id: ActiveValue::set(user_id),
            peer_a_id: ActiveValue::set(0),
            peer_b_id: ActiveValue::set(0),
            last_message_id: ActiveValue::set(0),
            last_message_pos: ActiveValue::set(0),
            last_message_badge: ActiveValue::set(0),
            admin_ids: ActiveValue::set(vec![]),
            version: ActiveValue::set(0),
            extra: ActiveValue::set(extra),
            ..Default::default()
        };
        Self::create_chat_with_feed(db, id, chat, &origin_chat.member_ids).await
    }

    pub async fn get_chat(db: &DatabaseConnection, chat_id: i64) -> ModelResult<Model> {
        let chat = Entity::find()
            .filter(model::query::condition().eq(Column::Id, chat_id).build())
            .one(db)
            .await?;
        if let Some(chat) = chat {
            Ok(chat)
        } else {
            Err(ModelError::EntityNotFound)
        }
    }

    pub async fn get_by_ids(db: &DatabaseConnection, ids: Vec<i64>) -> ModelResult<Vec<Model>> {
        let chats = Entity::find()
            .filter(model::query::condition().is_in(Column::Id, ids).build())
            .all(db)
            .await?;
        debug!("chat get by ids, chats: {chats:?}");
        Ok(chats)
    }

    /// 解散群聊落库：chats 实体标记 Deleted + 持久化版本号。
    /// 配合 message_send 已解散校验，避免解散后群聊继续收发消息（缓存逐出后从 DB 重载也保持解散态）。
    pub async fn update_dismissed(
        db: &DatabaseConnection,
        chat_id: i64,
        version: i64,
    ) -> ModelResult<()> {
        let active = ActiveModel {
            id: ActiveValue::set(chat_id),
            status: ActiveValue::set(EntityStatus::Deleted as i16),
            version: ActiveValue::set(version),
            ..Default::default()
        };
        Entity::update(active)
            .exec(db)
            .await?;
        Ok(())
    }
    pub async fn update_cmv(
        db: &DatabaseConnection,
        chat_id: i64,
        version: i64,
        owner_id: Option<i64>,
        admin_ids: Option<Vec<i64>>,
        cmv: &mut Cmv,
    ) -> ModelResult<()> {
        cmv.id = id_gen(None);
        let txn = db.begin().await?;
        let mut active = ActiveModel {
            id: ActiveValue::set(chat_id),
            cmv: ActiveValue::set(cmv.to()),
            version: ActiveValue::set(version),
            ..Default::default()
        };
        if let Some(oid) = owner_id {
            active.owner_id = ActiveValue::set(oid);
        }
        if let Some(aids) = admin_ids {
            active.admin_ids = ActiveValue::set(aids);
        }
        let _chat = active.update(&txn).await?;

        let _cmv = cmvs::ActiveModel {
            id: ActiveValue::set(cmv.id),
            chat_id: ActiveValue::set(chat_id),
            cmv: ActiveValue::set(cmv.cmv().to_vec()),
            count: ActiveValue::set(cmv.count),
            ..Default::default()
        }
        .insert(&txn)
        .await?;

        txn.commit().await?;
        Ok(())
    }

    pub fn into_entity(self, member_ids: Vec<i64>) -> entity::Chat {
        let extra = ChatExtra::decode(self.0.extra.as_slice()).unwrap_or_default();
        entity::Chat {
            create_at_ms: self.0.created_at.timestamp_millis(),
            update_at_ms: self.0.updated_at.timestamp_millis(),
            id: self.0.id,
            chat_type: self.0.r#type as i32,
            status: self.0.status as i32,
            name: self.0.name,
            owner_id: self.0.owner_id,
            peer_a_id: self.0.peer_a_id,
            peer_b_id: self.0.peer_b_id,
            member_ids,
            last_message_id: self.0.last_message_id,
            last_message_pos: self.0.last_message_pos as i32,
            last_message_badge_count: self.0.last_message_badge as i32,
            admin_ids: self.0.admin_ids,
            version: self.0.version,
            color: extra.color,
            avatar: extra.avatar,
            description: self.0.description.clone(),
            join_mode: self.0.join_mode as i32,
            global_mute_until: self.0.global_mute_until.map(|t| t.timestamp_millis()).unwrap_or(0),
        }
    }
}

impl From<entity::Chat> for ChatModel {
    fn from(value: entity::Chat) -> Self {
        let extra = (ChatExtra {
            color: value.color,
            avatar: value.avatar,
        })
        .encode_to_vec();
        Self(Model {
            allow_at_all: true,
            created_at: DateTimeWithTimeZone::from(
                chrono::DateTime::<chrono::Utc>::from_timestamp_millis(value.create_at_ms).unwrap(),
            ),
            updated_at: DateTimeWithTimeZone::from(
                chrono::DateTime::<chrono::Utc>::from_timestamp_millis(value.update_at_ms).unwrap(),
            ),
            id: value.id,
            r#type: value.chat_type as i16,
            status: value.status as i16,
            name: value.name,
            owner_id: value.owner_id,
            peer_a_id: value.peer_a_id,
            peer_b_id: value.peer_b_id,
            cmv: vec![],
            last_message_id: value.last_message_id,
            last_message_pos: value.last_message_pos,
            last_message_badge: value.last_message_badge_count,
            admin_ids: value.admin_ids,
            version: value.version,
            extra,
            description: value.description,
            join_mode: value.join_mode as i16,
global_mute_until: if value.global_mute_until > 0 {
                Some(DateTimeWithTimeZone::from(
                    chrono::DateTime::<chrono::Utc>::from_timestamp_millis(value.global_mute_until).unwrap()
                ))
            } else {
                None
            },
        })
    }
}
