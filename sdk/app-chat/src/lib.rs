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
use std::sync::atomic::{AtomicBool, Ordering};
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
        debug!("app chat logout, clear runtime state");
        self.db.reset();
        self.message_db.reset();

        // 复位同步标志：feed_sync / pipeline_sync 可能被 base_runtime::stop 中途取消，
        // 导致标志停留在 true，下次登录时 sync 会直接 early-return 从而永久不再同步。
        self.feed_sync_flag.store(false, Ordering::Relaxed);
        self.feed_reentrant_flag.store(false, Ordering::Relaxed);
        self.pipeline_sync_flag.store(false, Ordering::Relaxed);

        // 清理草稿暂存 id 集合，避免上一个用户的消息 id 泄漏到下一个用户
        {
            let mut stash_ids = self.stash_ids.write();
            stash_ids.clear();
        }

        // 排空预取队列，避免下次登录后继续预取上一个用户的会话
        if let Ok(mut rx) = self.task_rx.try_lock() {
            let mut dropped = 0;
            while rx.try_recv().is_ok() {
                dropped += 1;
            }
            if dropped > 0 {
                debug!("drop {} pending prefetch task on logout", dropped);
            }
        } else {
            warn!("prefetch task queue busy, skip draining on logout");
        }

        Ok(())
    }

    fn ffi_commands(&self) -> Vec<i32> {
        vec![
            // feed
            Command::FeedGetList as i32,
            Command::FeedGetBadgeCount as i32,
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
            Command::MessageGetReadMembers as i32,
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
        vec![
            Command::PushMessages as i32,
            Command::PushMessageReadstate as i32,
            Command::PushFeedList as i32,
            Command::PushFeedReadStatus as i32,
            Command::PushEntityChange as i32,
        ]
    }

    async fn on_ffi_command(&self, command: i32, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let cmd = Command::try_from(command)?;
        let ret = match cmd {
            // feed, chat
            Command::FeedGetList => self.feed_get_list(params),
            Command::FeedGetBadgeCount => self.feed_get_badge_count(params),
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
            Command::MessageRead => self.message_read(params).await,
            Command::MessageForward => self.message_forward(params).await,
            Command::MessageGetReadMembers => self.get_read_members(params).await,

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
            Command::PushMessageReadstate => self.handle_push_message_readstate(params),
            Command::PushFeedReadStatus => self.handle_push_feed_read_status(params),
            // pipeline 实体变更通道（消息内容/已读/表情按 READSTATE/REACTION 独立实体分发）
            Command::PushEntityChange => self.handle_entity_changed(params),
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
        // 确认消息落库前清理对应本地 stash：服务端消息 client_id 命中本机关存的
        // stash 缓存时，删除 stash 行（id == client_id），避免 pos range 拉取重复上屏。
        self.clean_stash_by_confirmed(entity)?;
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
            // 内容 / 已读 / 表情三路落库（共用 messages 行，见 docs/data_sync §5）
            if !entity.messages.is_empty()
                || !entity.readstates.is_empty()
                || !entity.reactions.is_empty()
            {
                debug!("message batch save: {:?}", entity.messages.keys().collect::<Vec<_>>());
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

    /// 确认消息落库前的 stash 清理：服务端确认消息携带 client_id，与本地草稿 stash
    /// （id == client_id, status=FAIL）关联。当该消息 id 已变为服务端新 id（id != client_id）
    /// 时，说明是已确认消息，删除对应本地 stash 行并移出缓存，避免本地与确认消息重复上屏。
    fn clean_stash_by_confirmed(&self, entity: &entity::Entity) -> Result<()> {
        let stash_guard = self.stash_ids.read();
        let stash: Vec<i64> = entity
            .messages
            .values()
            .filter(|msg| msg.client_id != 0 && msg.id != msg.client_id)
            .map(|msg| msg.client_id)
            .filter(|client_id| stash_guard.contains(client_id))
            .collect();
        drop(stash_guard);
        if stash.is_empty() {
            return Ok(());
        }
        debug!("clean stash by confirmed messages: {stash:?}");
        {
            let conn = self.message_db.inner()?;
            let _ = message_database::message::message_delete_by_ids(&conn, &stash)?;
        }
        let mut stash_guard = self.stash_ids.write();
        for id in &stash {
            stash_guard.remove(id);
        }
        Ok(())
    }

    /// 处理实体变更推送（PUSH_ENTITY_CHANGE）。逐项检查实体类型并分别标记本地脏：
    /// Message→消息内容脏、Readstate→已读脏、Reaction→表情脏、Chat→会话脏。
    /// 仅标记不拉取：全量补齐统一在 pipeline 同步完成后进行（pipeline_sync_impl），
    /// 实时通道的 PushMessages/PushFeedList 会携带最新数据落库自动清脏。见 docs/data_sync §5。
    pub(crate) fn handle_entity_changed(&self, params: &[u8]) -> Result<()> {
        let push = idl::pipeline::PushEntityChanged::decode(params)?;
        let mut changed = EntityChanged::default();
        changed.from_idl(&push.changes);
        debug!("handle entity changed: {:?}", changed);

        // 收集各类型的 (id, version) 对：update 逐条携带各自版本，delete 无版本记为 0。
        // 同一类型多条变更 version 可能不同，不能退化为单一 version（见 docs/data_sync §5）。
        let collect = |t: i32| -> Vec<(i64, i64)> {
            let mut v: Vec<(i64, i64)> = Vec::new();
            if let Some(updates) = changed.entity_update.get(&t) {
                v.extend(updates.iter().copied());
            }
            if let Some(deletes) = changed.entity_delete.get(&t) {
                v.extend(deletes.iter().map(|id| (*id, 0)));
            }
            v
        };

        let msg_updates = collect(idl::entity::EntityType::Message as i32);
        let readstate_updates = collect(idl::entity::EntityType::Readstate as i32);
        let reaction_updates = collect(idl::entity::EntityType::Reaction as i32);
        let chat_ids: Vec<i64> = changed
            .entity_update
            .get(&(idl::entity::EntityType::Chat as i32))
            .map(|v| v.iter().map(|(id, _)| *id).collect())
            .unwrap_or_default();

        if !msg_updates.is_empty() || !readstate_updates.is_empty() || !reaction_updates.is_empty() {
            let mut conn = self.message_db.inner()?;
            if !msg_updates.is_empty() {
                message_database::message::message_mark_dirty(
                    conn.deref_mut(),
                    &msg_updates,
                    idl::entity::EntityType::Message as i32,
                )?;
            }
            if !readstate_updates.is_empty() {
                message_database::message::message_mark_dirty(
                    conn.deref_mut(),
                    &readstate_updates,
                    idl::entity::EntityType::Readstate as i32,
                )?;
            }
            if !reaction_updates.is_empty() {
                message_database::message::message_mark_dirty(
                    conn.deref_mut(),
                    &reaction_updates,
                    idl::entity::EntityType::Reaction as i32,
                )?;
            }
        }
        if !chat_ids.is_empty() {
            let conn = self.db.inner()?;
            database::chat::chat_mark_dirty(&conn, &chat_ids)?;
        }
        Ok(())
    }

    /// 统一实体 ingest 入口（方案 A，见 docs/data_sync §5）：
    /// 跨模块落库 + 按 map 非空派生客户端通知。实时推送（PushMessages / PushFeedList）
    /// 与实体懒拉补齐（push_entity_changed）都收敛到此，避免跨模块处理入口分散在多个命令 handler。
    ///
    /// 派生规则：
    /// - messages / readstates / reactions 非空 → PushMessages（消息区 UI）；新消息同时推进会话未读/角标
    /// - feeds 非空 → PushFeedList（按 id 重取完整实体）；chats 非空但无 feeds → PushFeedList 透传（如 chat 名称/成员变更）
    /// - users 透传：不落库，随上述任一通知折叠下发（SDK 用户缓存归 app-account 模块）
    ///
    /// 注：未来服务端可合成统一 `PushEntity` 命令，SDK 侧入口不变（此处即唯一跨模块入口）。
    pub(crate) fn handle_push_entity(&self, entity: &entity::Entity) -> Result<()> {
        debug!(
            "handle push entity, feeds: {:?}, chats: {:?}, messages: {:?}, readstates: {:?}, reactions: {:?}, users: {:?}",
            entity.feeds.keys().collect::<Vec<_>>(),
            entity.chats.keys().collect::<Vec<_>>(),
            entity.messages.keys().collect::<Vec<_>>(),
            entity.readstates.keys().collect::<Vec<_>>(),
            entity.reactions.keys().collect::<Vec<_>>(),
            entity.users.keys().collect::<Vec<_>>(),
        );

        // 1. 跨模块落库（feeds/chats/messages/readstates/reactions；users 透传不落库）
        self.save_entity(entity)?;

        // 2. 消息区通知：消息 + 已读 + 表情。新消息经 feed_update_by_messages 推进会话未读/角标
        //    （内部按需 push PushFeedList），已读/表情为独立实体、只做轻量消息区刷新。
        if !entity.messages.is_empty()
            || !entity.readstates.is_empty()
            || !entity.reactions.is_empty()
        {
            let mut e = entity.clone();
            if !entity.messages.is_empty() {
                let _ = self.feed_update_by_messages(&mut e);
            }
            e.feeds.clear();
            let mut req = idl::message::PushMessages::default();
            req.entity = Some(e);
            let _ = service::ffi::ffi_push(Command::PushMessages as i32, req.encode_to_vec());
        }

        // 3. 会话区通知：feed 变更按 id 重取完整实体；纯 chat 变更（无 feed）直接透传
        if !entity.feeds.is_empty() {
            let ids: Vec<i64> = entity.feeds.keys().copied().collect();
            let _ = self.feed_push_by_ids(&ids);
        } else if !entity.chats.is_empty() {
            let mut req = idl::feed::PushFeedList::default();
            req.entity = Some(entity.clone());
            let _ = service::ffi::ffi_push(Command::PushFeedList as i32, req.encode_to_vec());
        }
        Ok(())
    }

    /// 实体懒拉完成后的通知：统一收敛到 handle_push_entity（消息/已读/表情→PushMessages，会话→PushFeedList）。
    pub(crate) fn push_entity_changed(&self, entity: &entity::Entity) -> Result<()> {
        self.handle_push_entity(entity)
    }

    pub(crate) async fn sync_entity(&self, ids: Vec<entity::EntityId>) -> Result<()> {
        if ids.is_empty() {
            return Ok(());
        }
        let mut req = idl::pipeline::PullEntityRequest::default();
        req.ids = ids;
        let mut resp = api::pipe_pull_entity(&req).await?;
        // 落库 + 客户端通知统一在 handle_push_entity 内完成
        let _ = self.handle_push_entity(&resp.entity.get_or_insert_default());
        Ok(())
    }

    /// 汇总本地脏实体（消息内容/已读/表情 + 会话），供 pipeline 同步完成后统一拉取补齐。
    pub(crate) fn collect_dirty_entities(&self) -> Result<Vec<entity::EntityId>> {
        let mut ids = Vec::new();
        {
            let conn = self.message_db.inner()?;
            ids.extend(message_database::message::message_get_dirty(&conn)?);
        }
        {
            let conn = self.db.inner()?;
            ids.extend(database::chat::chat_get_dirty(&conn)?);
        }
        debug!("collect dirty entities: {:?}", ids);
        Ok(ids)
    }
}
