#![allow(dead_code)]
mod chat;
mod feed;
mod message;
mod models;
mod setting;

use loco_rs::{Error, Result, app::AppContext};
use models::{chats::ChatModel, feeds::FeedModel};
use std::collections::HashMap;
use std::sync::Arc;
use tracing::debug;

use crate::models::{Cmv, chats, feeds};
use common::{EntityIds, ExternApp, UserBrief, UserEntity, VecBool};
use proto::idl::{command::Command, entity};

pub(crate) struct ChatContext {
    chat: chats::Model,
    cmv: Cmv,
    cmvs: HashMap<i64, VecBool>,
}
impl ChatContext {
    pub fn get_entity(&self) -> entity::Chat {
        // TODO
        let member_ids = self.cmv.ids();
        ChatModel(self.chat.clone()).into_entity(member_ids)
    }

    pub fn member_ids(&self) -> Vec<i64> {
        self.cmv.ids()
    }
}

#[derive(Clone)]
pub struct AppIm;
#[async_trait::async_trait]
impl ExternApp for AppIm {
    fn handled_command(&self) -> Vec<i32> {
        vec![
            // feed
            Command::FeedGetList as i32,
            Command::FeedRemove as i32,
            Command::FeedGetTopList as i32,
            Command::FeedActive as i32,
            Command::FeedSetTop as i32,
            Command::FeedSetMute as i32,
            // chat
            Command::ChatCreate as i32,
            Command::ChatAddChatters as i32,
            Command::ChatDeleteChatters as i32,
            Command::ChatGetByIds as i32,
            Command::ChatQuit as i32,
            Command::ChatDismiss as i32,
            // messagee
            Command::MessageSend as i32,
            Command::MessageRead as i32,
            Command::MessageRecall as i32,
            Command::MessageGetByIds as i32,
            Command::MessageGetByPos as i32,
            Command::MessageGetByRange as i32,
            Command::ReactionSet as i32,
            Command::MessageForward as i32,
            // favorite
            Command::FavoriteAdd as i32,
            Command::FavoriteGetList as i32,
            Command::FavoriteRemove as i32,
        ]
    }

    async fn handle_client_packet(
        &self,
        _cmd: i32,
        ctx: &AppContext,
        brief: &UserBrief,
        packet: &entity::Packet,
        ws: bool,
    ) -> Result<(i32, Vec<u8>)> {
        let cmd: Command = packet
            .cmd
            .try_into()
            .map_err(|_| Error::string("cmd parse error"))?;
        let (code, data) = match cmd {
            // feed
            Command::FeedGetList => feed::feed_get_list(ctx, brief, packet, ws).await?,
            Command::FeedRemove => feed::feed_remove(ctx, brief, packet, ws).await?,
            Command::FeedGetTopList => setting::top_list_get(ctx, brief, packet, ws).await?,
            Command::FeedActive => feed::feed_active(ctx, brief, packet, ws).await?,
            Command::FeedSetTop => feed::feed_set_top(ctx, brief, packet, ws).await?,
            Command::FeedSetMute => feed::feed_set_mute(ctx, brief, packet, ws).await?,

            // chat
            Command::ChatCreate => chat::chat_create(ctx, brief, packet, ws).await?,
            Command::ChatGetByIds => chat::chat_get_by_ids(ctx, brief, packet, ws).await?,
            Command::ChatAddChatters => chat::chat_add_chatters(ctx, brief, packet, ws).await?,
            Command::ChatDeleteChatters => {
                chat::chat_delete_chatters(ctx, brief, packet, ws).await?
            }
            Command::ChatQuit => chat::chat_quit(ctx, brief, packet, ws).await?,
            Command::ChatDismiss => chat::chat_dismiss(ctx, brief, packet, ws).await?,

            // messages
            Command::MessageSend => message::message_send(ctx, brief, packet, ws).await?,
            Command::MessageRead => message::message_read(ctx, brief, packet, ws).await?,
            Command::MessageRecall => message::message_recall(ctx, brief, packet, ws).await?,
            Command::MessageGetByIds => message::message_get_by_ids(ctx, brief, packet, ws).await?,
            Command::MessageGetByPos => message::message_get_by_pos(ctx, brief, packet, ws).await?,
            Command::MessageGetByRange => {
                message::message_get_by_range(ctx, brief, packet, ws).await?
            }
            Command::ReactionSet => message::reaction_set(ctx, brief, packet, ws).await?,
            Command::MessageForward => message::message_forward(ctx, brief, packet, ws).await?,

            Command::FavoriteAdd => setting::favorite_add(ctx, brief, packet, ws).await?,
            Command::FavoriteRemove => setting::favorite_remove(ctx, brief, packet, ws).await?,
            Command::FavoriteGetList => setting::favorite_get(ctx, brief, packet, ws).await?,

            _ => return Err(Error::NotFound),
        };
        Ok((code, data))
    }
}

#[allow(dead_code)]
pub(crate) struct UserFeedContext {
    feeds: HashMap<i64, Arc<entity::Feed>>,
    feed_sort: Vec<(i64, Arc<entity::Feed>)>,
}

pub(crate) async fn fill_entity(
    ctx: &AppContext,
    entity_ids: &mut EntityIds,
    entity: &mut entity::Entity,
    user_entity: &mut HashMap<i64, UserEntity>,
) -> Result<()> {
    // fill chat
    if !entity_ids.chat_ids.is_empty() {
        let mut chat_ids: Vec<i64> = entity_ids.chat_ids.iter().copied().collect();
        chat_ids.retain(|id| !entity.chats.contains_key(id));
        if !chat_ids.is_empty() {
            match chat::cache_chat_load(ctx, &chat_ids).await {
                Ok(chats) => {
                    for (id, chat) in chats {
                        let chat = chat.read().await;
                        let chat = chat.get_entity();
                        entity.chats.insert(id, chat);
                    }
                }
                Err(err) => {
                    debug!("cache chat load error: {err:?}");
                }
            }
        }
    }

    debug!("read chat from db: {:?}", entity.chats);

    for (c_id, c) in entity.chats.iter() {
        if entity_ids.with_feed {
            entity_ids.feed_ids.insert(*c_id);
        }
        for id in c.member_ids.iter() {
            if entity_ids.broadcast {
                let _ = user_entity.entry(*id).or_default();
            }
            if let Some(ue) = user_entity.get_mut(&id) {
                ue.entity.chats.insert(*c_id, c.clone());
                if entity_ids.with_feed {
                    ue.entity_ids.feed_ids.insert(*c_id);
                }
                if entity_ids.with_message {
                    ue.entity_ids.message_ids.insert(c.last_message_id);
                }
                debug!("fill for user, {id:?}, ids: {:?}", ue.entity_ids);
            }
        }
    }

    let user_ids: Vec<i64> = user_entity.keys().copied().collect();
    debug!("fill entity for users, {user_ids:?}");
    if user_ids.is_empty() {
        return Ok(());
    }

    // fill feeds
    if !entity_ids.feed_ids.is_empty() {
        match feeds::FeedModel::feed_get_by_ids_for_users(&ctx.db, user_ids.clone(), entity_ids)
            .await
        {
            Ok(mut feeds) => {
                feeds.drain(..).for_each(|feed| {
                    let target_id = feed.user_id;
                    if entity_ids.with_message {
                        entity_ids.message_ids.insert(feed.refer_id);
                    }
                    let f: entity::Feed = FeedModel(feed).into();
                    if let Some(ue) = user_entity.get_mut(&target_id) {
                        if entity_ids.with_message {
                            ue.entity_ids.message_ids.insert(f.refer_id);
                            entity_ids.feed_ids.insert(f.id);
                        }
                        if ue.entity_ids.feed_ids.contains(&f.id) {
                            ue.entity.feeds.insert(f.id, f);
                        }
                    }
                });
            }
            Err(err) => {
                debug!("feed get by ids for users error: {err:?}");
            }
        }
    }

    // feed message
    entity_ids.message_ids.remove(&0);
    if !entity_ids.message_ids.is_empty() {
        debug!("fill message for users: {:?}", entity_ids.message_ids);
        let _ = message::fill_messages(ctx, entity_ids, user_entity).await;
    }

    Ok(())
}
