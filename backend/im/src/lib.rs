#![allow(dead_code)]
mod chat;
mod feed;
mod invite;
mod join_request;
mod message;
mod models;
mod mute;
mod pin;
mod presence;
mod scheduler;
mod search;
mod setting;
mod thread;
mod translate;
mod typing;
mod voice;

use loco_rs::{Error, Result, app::AppContext};
use models::{chats::ChatModel, feeds::FeedModel};
use prost::Message;
use std::collections::HashMap;
use std::sync::Arc;
use tokio::runtime::Handle;
use tracing::debug;

use crate::models::{Cmv, chats, feeds};
use common::{EntityIds, ExternApp, UserBrief, UserEntity, VecBool};
use proto::idl::{self, command::Command, entity, error::ErrorCode};

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
    fn serve(&self, ctx: &AppContext) {
        let ctx = ctx.clone();
        tokio::spawn(async move {
            let svc = scheduler::SchedulerService::new();
            svc.set_ctx(ctx).await;
            svc.run().await;
        });
    }

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
            Command::ChatUpdate as i32,
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
            // pipeline 实体变更通道：懒拉实体内容（消息已读/read_state/reaction 归并到 MESSAGE 实体）
            Command::PipelinePullEntity as i32,
            Command::MessageGetByRange as i32,
            Command::ReactionSet as i32,
            Command::MessageForward as i32,
            // favorite
            Command::FavoriteAdd as i32,
            Command::FavoriteGetList as i32,
            Command::FavoriteRemove as i32,
            // M2: announcement
            Command::ChatSetAnnouncement as i32,
            Command::ChatDeleteAnnouncement as i32,
            // M2: mute
            Command::ChatMuteMember as i32,
            Command::ChatGlobalMute as i32,
            // M2: invite
            Command::ChatInviteLinkCreate as i32,
            Command::ChatInviteLinkJoin as i32,
            Command::ChatInviteLinkRevoke as i32,
            // M2: join request
            Command::ChatJoinRequestCreate as i32,
            Command::ChatJoinRequestApprove as i32,
            Command::ChatJoinRequestReject as i32,
            Command::ChatJoinRequestList as i32,
            // M2: members
            Command::ChatGetMembers as i32,
            // M3: pin
            Command::ChatPinMessage as i32,
            Command::ChatUnpinMessage as i32,
            Command::ChatGetPinnedMessages as i32,
            // M3: thread
            Command::MessageGetThread as i32,
            // M3: read members
            Command::MessageGetReadMembers as i32,
            // M3: typing
            Command::Typing as i32,
            // M3: presence
            Command::UserPresenceUpdate as i32,
            Command::UserPresenceSubscribe as i32,
            // M3: delete
            Command::MessageDelete as i32,
            // M4: search
            Command::SearchUser as i32,
            Command::SearchMessage as i32,
            Command::SearchChat as i32,
            Command::SearchFiles as i32,
            Command::GlobalSearch as i32,
            // M5: voice
            Command::VoiceTranscribe as i32,
            // M5: schedule
            Command::ScheduleMessage as i32,
            Command::CancelSchedule as i32,
            Command::GetScheduledMessages as i32,
            // M5: translate
            Command::TranslateMessage as i32,
            Command::GetTranslationLanguages as i32,
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
            Command::ChatUpdate => chat::chat_update(ctx, brief, packet, ws).await?,
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
            Command::PipelinePullEntity => message::pipeline_pull_entity(ctx, brief, packet, ws).await?,
            Command::MessageGetByRange => {
                message::message_get_by_range(ctx, brief, packet, ws).await?
            }
            Command::ReactionSet => message::reaction_set(ctx, brief, packet, ws).await?,
            Command::MessageForward => message::message_forward(ctx, brief, packet, ws).await?,

            Command::FavoriteAdd => setting::favorite_add(ctx, brief, packet, ws).await?,
            Command::FavoriteRemove => setting::favorite_remove(ctx, brief, packet, ws).await?,
            Command::FavoriteGetList => setting::favorite_get(ctx, brief, packet, ws).await?,

            // M2: announcement
            Command::ChatSetAnnouncement => {
                chat::chat_set_announcement(ctx, brief, packet, ws).await?
            }
            Command::ChatDeleteAnnouncement => {
                chat::chat_delete_announcement(ctx, brief, packet, ws).await?
            }
            // M2: mute
            Command::ChatMuteMember => mute::mute_member(ctx, brief, packet, ws).await?,
            Command::ChatGlobalMute => mute::global_mute(ctx, brief, packet, ws).await?,
            // M2: invite
            Command::ChatInviteLinkCreate => {
                invite::invite_link_create(ctx, brief, packet, ws).await?
            }
            Command::ChatInviteLinkJoin => invite::invite_link_join(ctx, brief, packet, ws).await?,
            Command::ChatInviteLinkRevoke => {
                invite::invite_link_revoke(ctx, brief, packet, ws).await?
            }
            // M2: join request
            Command::ChatJoinRequestCreate => {
                join_request::join_request_create(ctx, brief, packet, ws).await?
            }
            Command::ChatJoinRequestApprove => {
                join_request::join_request_approve(ctx, brief, packet, ws).await?
            }
            Command::ChatJoinRequestReject => {
                join_request::join_request_reject(ctx, brief, packet, ws).await?
            }
            Command::ChatJoinRequestList => {
                join_request::join_request_list(ctx, brief, packet, ws).await?
            }
            // M2: members
            Command::ChatGetMembers => chat::get_members(ctx, brief, packet, ws).await?,
            // M3: pin
            Command::ChatPinMessage => pin::pin_message(ctx, brief, packet, ws).await?,
            Command::ChatUnpinMessage => pin::unpin_message(ctx, brief, packet, ws).await?,
            Command::ChatGetPinnedMessages => {
                pin::get_pinned_messages(ctx, brief, packet, ws).await?
            }
            // M3: thread
            Command::MessageGetThread => thread::get_thread(ctx, brief, packet, ws).await?,
            // M3: read members
            Command::MessageGetReadMembers => {
                message::message_get_read_members(ctx, brief, packet, ws).await?
            }
            // M3: typing
            Command::Typing => typing::handle_typing(ctx, brief, packet, ws).await?,
            // M3: presence
            Command::UserPresenceUpdate => {
                presence::handle_presence_update(ctx, brief, packet, ws).await?
            }
            Command::UserPresenceSubscribe => {
                presence::handle_presence_subscribe(ctx, brief, packet, ws).await?
            }
            // M3: delete
            Command::MessageDelete => message::message_delete(ctx, brief, packet, ws).await?,
            // M4: search
            Command::SearchMessage => search::search_messages(ctx, brief, packet, ws).await?,
            Command::SearchChat => search::search_chats(ctx, brief, packet, ws).await?,
            Command::SearchUser => search::search_users(ctx, brief, packet, ws).await?,
            Command::SearchFiles => search::search_files(ctx, brief, packet, ws).await?,
            Command::GlobalSearch => search::global_search(ctx, brief, packet, ws).await?,
            // M5: voice
            Command::VoiceTranscribe => voice::transcribe_voice(ctx, brief, packet, ws).await?,
            // M5: schedule
            Command::ScheduleMessage => scheduler::schedule_message(ctx, brief, packet, ws).await?,
            Command::CancelSchedule => scheduler::cancel_schedule(ctx, brief, packet, ws).await?,
            Command::GetScheduledMessages => {
                scheduler::get_scheduled_messages(ctx, brief, packet, ws).await?
            }
            // M5: translate
            Command::TranslateMessage => {
                translate::translate_message(ctx, brief, packet, ws).await?
            }
            Command::GetTranslationLanguages => {
                translate::get_translation_languages(ctx, brief, packet, ws).await?
            }

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

// ─── BizIm 实现 ──────────────────────────────────────────────
#[async_trait::async_trait]
impl common::BizIm for AppIm {
    async fn get_chat(
        &self,
        ctx: &AppContext,
        _brief: &UserBrief,
        chat_id: i64,
    ) -> Result<entity::Chat> {
        let context = chat::chat_cache_get(ctx, chat_id)
            .await
            .map_err(|_| Error::NotFound)?;
        let c = context.read().await;
        Ok(c.get_entity())
    }

    async fn list_chat_members(
        &self,
        ctx: &AppContext,
        _brief: &UserBrief,
        chat_id: i64,
        _page: i32,
        _page_size: i32,
    ) -> Result<Vec<i64>> {
        let ids = chat::chat_get_all_user_ids(ctx, chat_id).await?;
        Ok(ids)
    }

    async fn list_messages(
        &self,
        _ctx: &AppContext,
        _brief: &UserBrief,
        _chat_id: i64,
        _page: i32,
        _page_size: i32,
        _before_id: Option<i64>,
    ) -> Result<entity::Entity> {
        // TODO: implement paginated message history query
        Err(Error::NotFound)
    }

    async fn create_bot_chat(
        &self,
        _ctx: &AppContext,
        _brief: &UserBrief,
        _name: &str,
        _desc: &str,
        _member_ids: &[i64],
    ) -> Result<i64> {
        // TODO: implement via chat::chat_create
        Err(Error::NotFound)
    }

    async fn add_chat_members(
        &self,
        _ctx: &AppContext,
        _brief: &UserBrief,
        _chat_id: i64,
        _member_ids: &[i64],
    ) -> Result<()> {
        // TODO: implement via chat::chat_add_chatters
        Err(Error::NotFound)
    }

    async fn remove_chat_members(
        &self,
        _ctx: &AppContext,
        _brief: &UserBrief,
        _chat_id: i64,
        _member_ids: &[i64],
    ) -> Result<()> {
        Err(Error::NotFound)
    }

    async fn set_chat_announcement(
        &self,
        _ctx: &AppContext,
        _brief: &UserBrief,
        _chat_id: i64,
        _announcement: &str,
    ) -> Result<()> {
        Err(Error::NotFound)
    }

    async fn add_message_reaction(
        &self,
        _ctx: &AppContext,
        _brief: &UserBrief,
        _message_id: i64,
        _reaction: &str,
    ) -> Result<()> {
        Err(Error::NotFound)
    }

    async fn remove_message_reaction(
        &self,
        _ctx: &AppContext,
        _brief: &UserBrief,
        _message_id: i64,
        _reaction: &str,
    ) -> Result<()> {
        Err(Error::NotFound)
    }
    async fn send_message(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        from_id: i64,
        chat_id: i64,
        msg_type: i32,
        content: Vec<u8>,
        summary: String,
    ) -> Result<i64> {
        let now_ms = common::current_ms() as i64;
        let msg = entity::Message {
            id: 0,
            from_id,
            chat_id,
            tpy: msg_type as i32,
            content,
            summary,
            create_time_ms: now_ms,
            ..Default::default()
        };
        let req = idl::message::SendMessageRequest {
            client_id: 0,
            message: Some(msg),
        };
        let body = req.encode_to_vec();
        let packet = entity::Packet {
            cmd: Command::MessageSend as i32,
            payload: body,
            ..Default::default()
        };
        let (code, data) = message::message_send(ctx, brief, &packet, false)
            .await
            .map_err(|_| Error::InternalServerError)?;
        if code != ErrorCode::Success as i32 {
            return Err(Error::InternalServerError);
        }
        let resp = idl::message::SendMessageResponse::decode(data.as_slice())
            .map_err(|_| Error::InternalServerError)?;
        Ok(resp.id)
    }

    async fn edit_message(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        message_id: i64,
        content: Vec<u8>,
        summary: String,
    ) -> Result<()> {
        // 编辑消息：构建 EditMessageRequest 调用现有逻辑
        // 目前 IM 模块没有单独的消息编辑命令，使用 MessageSend 的追加逻辑
        // 实际应当调用消息更新方法，暂用 message_recall + message_send 替代
        // TODO: 后续实现独立的消息编辑 API
        let _ = (ctx, brief, message_id, content, summary);
        Err(Error::NotFound)
    }

    async fn recall_message(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        message_id: i64,
    ) -> Result<()> {
        let req = idl::message::RecallMessageRequest { id: message_id };
        let body = req.encode_to_vec();
        let packet = entity::Packet {
            cmd: Command::MessageRecall as i32,
            payload: body,
            ..Default::default()
        };
        let (code, _) = message::message_recall(ctx, brief, &packet, false)
            .await
            .map_err(|_| Error::InternalServerError)?;
        if code != ErrorCode::Success as i32 {
            return Err(Error::InternalServerError);
        }
        Ok(())
    }
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
