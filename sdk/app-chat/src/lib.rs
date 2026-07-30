mod api;
mod chat;
pub(crate) mod content;
mod database;
mod favorite;
mod feed;
mod invite;
mod join_request;
mod message;
mod message_database;
mod mute;
mod pin;
mod pipeline;
mod presence;
mod scheduler;
mod search;
mod thread;
mod translate;
mod typing;
mod voice;

use anyhow::Result;
use async_trait::async_trait;
use prost::Message;
use std::collections::HashSet;
use std::ops::DerefMut;
use std::sync::atomic::AtomicBool;
use std::sync::Arc;
use tokio::sync::mpsc::{unbounded_channel, UnboundedReceiver, UnboundedSender};
use tokio::sync::Mutex;
use tracing::{debug, warn};

use base_db::{DbConn};
use base_runtime::spawn;
use base_util::lock::{RwLock};
use message::PrefetchTask;
use proto::idl::{self, command::Command, entity};
use proto::{EntityChanged, EntityIds};
use service::account::{DeviceInfo, UserInfo};
use service::chat::BizChat;
use service::{AppTrait, BizHub, Event, InitRequest, LoginRequest};

mod constant {
    pub const FLAG_FEED_CURSOR: &str = "flag_feed_cursor";
    pub const FLAG_PIPE_CURSOR: &str = "flag_pipe_cursor";
}

#[derive(Debug, Clone)]
pub struct AppChat {
    // db
    db: DbConn,
    message_db: DbConn,

    // feed
    feed_sync_flag: Arc<AtomicBool>,
    feed_reentrant_flag: Arc<AtomicBool>,
    pipeline_sync_flag: Arc<AtomicBool>,

    // message
    stash_ids: Arc<RwLock<HashSet<i64>>>,
    task_tx: Arc<UnboundedSender<PrefetchTask>>,
    task_rx: Arc<Mutex<UnboundedReceiver<PrefetchTask>>>,
    // chat
}
impl AppChat {
    pub fn new() -> Self {
        let (tx, rx) = unbounded_channel::<PrefetchTask>();
        Self {
            db: DbConn::default(),
            message_db: DbConn::default(),

            feed_sync_flag: Arc::new(AtomicBool::new(false)),
            feed_reentrant_flag: Arc::new(AtomicBool::new(false)),
            pipeline_sync_flag: Arc::new(AtomicBool::new(false)),

            stash_ids: Arc::new(RwLock::new(HashSet::new())),
            task_tx: Arc::new(tx),
            task_rx: Arc::new(Mutex::new(rx)),
        }
    }

    pub fn init_db(&self, user_info: &UserInfo, device_info: &DeviceInfo) -> Result<()> {
        let conn = database::init_db(user_info, device_info)?;
        self.db.set(conn);

        let conn = message_database::init_db(user_info, device_info)?;
        self.message_db.set(conn);
        Ok(())
    }

    pub fn get() -> Result<Self> {
        let hub = BizHub::get()?;
        let chat = hub.chat.clone();
        chat.downcast_ref::<AppChat>()
            .ok_or(anyhow::anyhow!("error"))
            .cloned()
    }
}

pub struct StateChat {}

#[async_trait]
impl AppTrait for AppChat {
    fn init(&self, _req: &InitRequest) -> Result<()> {
        debug!("init app chat");
        debug!("init app chat finish");
        Ok(())
    }
    fn uninit(&self) -> Result<()> {
        Ok(())
    }

    fn login(&self, _req: &LoginRequest) -> Result<()> {
        let acc = BizHub::get()?.account.clone();
        let user_info = acc.get_user_info();
        let device_info = acc.get_device_info();

        if let Err(e) = self.init_db(&user_info, &device_info) {
            debug!("init chat db error: {:?}", e);
        }

        let _ = self.message_init();
        Ok(())
    }
    fn logout(&self) -> Result<()> {
        self.db.reset();
        self.message_db.reset();
        Ok(())
    }

    fn ffi_commands(&self) -> Vec<i32> {
        vec![
            // feed
            Command::FeedGetList as i32,
            Command::FeedRemove as i32,
            Command::FeedGetTopList as i32,
            Command::FeedActive as i32,
            Command::FeedSetTop as i32,
            Command::FeedSetMute as i32,
            Command::FeedGetByIds as i32,
            // chat
            Command::ChatCreate as i32,
            Command::ChatUpdate as i32,
            Command::ChatAddChatters as i32,
            Command::ChatDeleteChatters as i32,
            Command::ChatGetByIds as i32,
            Command::ChatQuit as i32,
            Command::ChatDismiss as i32,
            Command::ChatSetDraft as i32,
            Command::ChatGetDraft as i32,
            // message
            Command::MessageSend as i32,
            Command::MessageRead as i32,
            Command::MessageRecall as i32,
            // Command::MessageGetReadstate as i32,
            Command::MessageGetByIds as i32,
            Command::MessageGetByPos as i32,
            Command::MessageGetByRange as i32,
            Command::MessageCreateDraft as i32,
            Command::MessageGetAllDrafts as i32,
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
            // M3: presence
            Command::UserPresenceUpdate as i32,
            Command::UserPresenceSubscribe as i32,
            // M3: typing
            Command::Typing as i32,
            // M3: delete
            Command::MessageDelete as i32,
            // M4: search
            Command::SearchMessage as i32,
            Command::SearchChat as i32,
            Command::SearchUser as i32,
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

    fn net_commands(&self) -> Vec<i32> {
        vec![Command::PushMessages as i32, Command::PushFeedList as i32]
    }

    async fn on_ffi_command(&self, command: i32, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let cmd = Command::try_from(command)?;
        let ret = match cmd {
            // feed, chat
            Command::FeedGetList => self.feed_get_list(params),
            Command::FeedRemove => self.feed_remove(params).await,
            Command::FeedGetTopList => self.feed_get_top_list(params).await,
            Command::FeedActive => self.feed_active(params).await,
            Command::FeedSetTop => self.feed_set_top(params).await,
            Command::FeedSetMute => self.feed_set_mute(params).await,
            Command::FeedGetByIds => self.feed_get_by_ids(params).await,

            Command::ChatCreate => self.chat_create(params).await,
            Command::ChatUpdate => self.chat_update(params).await,
            Command::ChatAddChatters => self.chat_add_chatters(params).await,
            Command::ChatDeleteChatters => self.chat_delete_chatters(params).await,
            Command::ChatGetByIds => self.chat_get_by_ids(params).await,
            Command::ChatQuit => self.chat_quit(params).await,
            Command::ChatDismiss => self.chat_dismiss(params).await,
            Command::ChatSetDraft => self.chat_set_draft(params),
            Command::ChatGetDraft => self.chat_get_draft(params),

            // messages
            Command::MessageCreateDraft => self.message_create_draft(params),
            Command::MessageGetAllDrafts => self.message_get_all_drafts(params),
            Command::MessageRecall => self.message_recall(params).await,
            Command::MessageGetByIds => self.message_get_by_ids(params).await,
            Command::MessageGetByRange => self.message_get_by_chat(params).await,
            Command::MessageSend => self.message_send(params).await,
            Command::MessageForward => self.message_forward(params).await,

            // favorite
            Command::FavoriteAdd => self.favorite_add(params).await,
            Command::FavoriteRemove => self.favorite_remove(params).await,
            Command::FavoriteGetList => self.favorite_get_list(params).await,

            // M2: announcement
            Command::ChatSetAnnouncement => self.chat_set_announcement(params).await,
            Command::ChatDeleteAnnouncement => self.chat_delete_announcement(params).await,
            // M2: mute
            Command::ChatMuteMember => self.mute_member(params).await,
            Command::ChatGlobalMute => self.global_mute(params).await,
            // M2: invite
            Command::ChatInviteLinkCreate => self.invite_link_create(params).await,
            Command::ChatInviteLinkJoin => self.invite_link_join(params).await,
            Command::ChatInviteLinkRevoke => self.invite_link_revoke(params).await,
            // M2: join request
            Command::ChatJoinRequestCreate => self.join_request_create(params).await,
            Command::ChatJoinRequestApprove => self.join_request_approve(params).await,
            Command::ChatJoinRequestReject => self.join_request_reject(params).await,
            Command::ChatJoinRequestList => self.join_request_list(params).await,
            // M2: members
            Command::ChatGetMembers => self.chat_get_members(params).await,
            // M3: pin
            Command::ChatPinMessage => self.pin_message(params).await,
            Command::ChatUnpinMessage => self.unpin_message(params).await,
            Command::ChatGetPinnedMessages => self.get_pinned_messages(params).await,
            // M3: thread
            Command::MessageGetThread => self.get_thread(params).await,
            // M3: presence
            Command::UserPresenceUpdate => self.presence_update(params).await,
            Command::UserPresenceSubscribe => self.presence_subscribe(params).await,
            // M3: typing
            Command::Typing => self.send_typing(params).await,
            // M3: delete
            Command::MessageDelete => self.delete_message(params).await,
            // M4: search
            Command::SearchMessage => self.search_messages(params).await,
            Command::SearchChat => self.search_chats(params).await,
            Command::SearchUser => self.search_users(params).await,
            Command::SearchFiles => self.search_files(params).await,
            Command::GlobalSearch => self.global_search(params).await,
            // M5: voice
            Command::VoiceTranscribe => self.transcribe_voice(params).await,
            // M5: schedule
            Command::ScheduleMessage => self.schedule_message(params).await,
            Command::CancelSchedule => self.cancel_schedule(params).await,
            Command::GetScheduledMessages => self.get_scheduled_messages(params).await,
            // M5: translate
            Command::TranslateMessage => self.translate_message(params).await,
            Command::GetTranslationLanguages => self.get_translation_languages(params).await,

            _ => return Err(anyhow::anyhow!("not handled")),
        };

        if let Err(ref err) = ret {
            warn!("handle command error: {:?}", err);
        }
        ret
    }

    async fn on_net_command(&self, _source: i32, command: i32, params: &[u8]) -> Result<()> {
        let cmd = Command::try_from(command)?;
        match cmd {
            // feed, chat
            Command::PushFeedList => self.handle_push_feed_list(params),
            Command::PushMessages => self.handle_push_messages(params),
            _ => Err(anyhow::anyhow!("not handled")),
        }
    }

    fn on_event(&self, event: Event, _params: &[u8]) {
        match event {
            Event::EventLogin => {
                spawn(async {
                    if let Ok(hub) = BizHub::get() {
                        if let Some(chat) = hub.chat.downcast_ref::<AppChat>() {
                            chat.feed_sync().await;
                            chat.pipeline_sync().await;
                        }
                    }
                });
            }
            _ => {}
        }
    }
}

impl BizChat for AppChat {}

impl AppChat {
    pub(crate) fn fill_entity(
        &self,
        ids: &mut EntityIds,
        entity: &mut entity::Entity,
    ) -> Result<()> {
        ids.feed_ids.retain(|id| !entity.feeds.contains_key(id));
        debug!("fill entity, fill feed: {:?}", ids.feed_ids);
        self.feed_fill(ids, entity)?;
        entity.feeds.values().for_each(|feed| {
            ids.chat_ids.insert(feed.id);
            if feed.refer_id != 0 {
                ids.message_ids.insert(feed.refer_id);
            }
        });

        ids.chat_ids.retain(|id| !entity.chats.contains_key(id));
        debug!("fill entity, fill chat: {:?}", ids.chat_ids);
        self.chat_fill(ids, entity)?;
        entity.chats.values().for_each(|chat| {
            if ids.chat_deps.member {
                ids.user_ids.extend(chat.member_ids.iter());
            }
            ids.user_ids.insert(chat.owner_id);
            ids.user_ids.insert(chat.peer_a_id);
            ids.user_ids.insert(chat.peer_b_id);
        });

        ids.message_ids
            .retain(|id| !entity.messages.contains_key(id));
        debug!("fill entity, fill message: {:?}", ids.message_ids);
        self.fill_message(ids, entity)?;
        entity.messages.values().for_each(|message| {
            ids.user_ids.insert(message.from_id);
            ids.read_state_ids.insert(message.id);
            ids.user_ids.extend(message.at_user_ids.iter());
        });

        let _ = service::account::fill_entity(ids, entity, true);

        debug!(
            "fill entity, feeds: {:?}, chat: {:?}, message: {:?}, user: {:?}, missing: {:?}",
            entity.feeds.keys(),
            entity.chats.keys(),
            entity.messages.keys(),
            entity.users.keys(),
            ids
        );

        let missing_ids = ids.fill_vec();
        if !missing_ids.is_empty() {
            base_runtime::spawn(async move {
                if let Ok(hub) = BizHub::get() {
                    if let Some(chat) = hub.chat.downcast_ref::<AppChat>() {
                        let _ = chat.sync_entity(missing_ids).await;
                    }
                }
            });
        }
        Ok(())
    }

    pub(crate) fn save_entity(&self, entity: &entity::Entity) -> Result<()> {
        {
            let mut conn = self.db.inner()?;
            if !entity.feeds.is_empty() {
                debug!("feed batch save: {:?}", entity.feeds);
                if let Err(err) = database::feed::feed_batch_save(conn.deref_mut(), entity) {
                    warn!("feed batch save err: {:?}", err);
                }
            }
            if !entity.chats.is_empty() {
                debug!("chat batch save: {:?}", entity.chats);
                if let Err(err) = database::chat::chat_batch_save(conn.deref_mut(), entity) {
                    warn!("chat batch save err: {:?}", err);
                }
            }
        }
        {
            let mut conn = self.message_db.inner()?;
            if !entity.messages.is_empty() {
                debug!("message batch save: {:?}", entity.messages);
                if let Err(err) =
                    message_database::message::message_batch_save(conn.deref_mut(), entity)
                {
                    warn!("message batch save err: {:?}", err);
                }
            }
        }
        if !entity.users.is_empty() {}
        Ok(())
    }

    #[allow(dead_code)]
    pub(crate) fn handle_entity_changed(&self, params: &[u8]) -> Result<()> {
        let push = idl::pipeline::PushEntityChanged::decode(params)?;
        let mut changed = EntityChanged::default();
        changed.from_idl(&push.changes);
        debug!("handle entity changed: {:?}", changed);
        Ok(())
    }

    pub(crate) fn push_entity_changed(&self, _entity: &entity::Entity) -> Result<()> {
        // TODO
        Ok(())
    }

    pub(crate) async fn sync_entity(&self, ids: Vec<entity::EntityId>) -> Result<()> {
        let mut req = idl::pipeline::PullEntityRequest::default();
        req.ids = ids;
        let mut resp = api::pipe_pull_entity(&req).await?;
        self.save_entity(&resp.entity.get_or_insert_default())?;
        let _ = self.push_entity_changed(&resp.entity.get_or_insert_default());
        Ok(())
    }
}
