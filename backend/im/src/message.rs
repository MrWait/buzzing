use loco_rs::{Error, Result, app::AppContext};
use prost::Message;
use sea_orm::{ConnectionTrait, DbBackend, Statement};
use std::sync::{Arc, LazyLock};
use std::{collections::HashMap, collections::HashSet};
use tokio::sync::RwLock;
use tracing::debug;

use crate::models::messages::{MessageModel, Reactions, messages};
use common::time::{current_ms, date_time};
use common::{
    BizHub, CacheLoader, CommonCache, EntityIds, EntityStatus, UserBrief, UserEntity, VecBool,
};
use common::{common_error, id_gen, pb_decode, pb_default, rid};
use proto::idl::{command::Command, entity, error::ErrorCode, message, pipeline};

struct MessageContext {
    pub message: messages::Model,
    pub reactions: Reactions,
    pub read_state_cmv: VecBool,
}

impl MessageContext {
    pub fn from_message(src: &messages::Model) -> Self {
        let message = src.clone();
        message.into()
    }
}

impl From<messages::Model> for MessageContext {
    fn from(mut msg: messages::Model) -> Self {
        let reactions = pb_default::<Reactions>(&msg.reactions);
        let read_state_cmv =
            VecBool::with(msg.cmv_count as u64, std::mem::take(&mut msg.read_states));

        MessageContext {
            message: msg,
            reactions,
            read_state_cmv,
        }
    }
}

type EntryMessage = Arc<RwLock<MessageContext>>;
static CACHE_MESSAGE: LazyLock<CommonCache<i64, EntryMessage>> = LazyLock::new(|| {
    // Cache::builder()
    //     .max_capacity(20_0000)
    //     .time_to_live(Duration::from_secs(30 * 60))
    //     .time_to_idle(Duration::from_secs(10 * 60))
    //     .build()
    CommonCache::new(20_0000, Arc::new(Box::new(MessageLoader)))
});

struct MessageLoader;
#[async_trait::async_trait]
impl CacheLoader<i64, EntryMessage> for MessageLoader {
    async fn load(&self, ctx: &AppContext, ids: &[i64]) -> Result<HashMap<i64, EntryMessage>> {
        let mut result = HashMap::new();
        let mut db_messages = MessageModel::find_by_ids(&ctx.db, ids.to_vec()).await?;
        for message in db_messages.drain(..) {
            let id = message.id;
            result.insert(id, Arc::new(RwLock::new(message.into())));
        }
        Ok(result)
    }

    async fn get(&self, ctx: &AppContext, id: &i64) -> Result<EntryMessage> {
        let message = MessageModel::find_by_id(&ctx.db, *id).await?;
        Ok(Arc::new(RwLock::new(message.into())))
    }
}

async fn cache_message_load(ctx: &AppContext, ids: &[i64]) -> Result<HashMap<i64, EntryMessage>> {
    CACHE_MESSAGE.load(ctx, ids).await
}

async fn cache_get_message(ctx: &AppContext, id: i64) -> Result<EntryMessage> {
    CACHE_MESSAGE.get(ctx, &id).await
}

pub async fn fill_messages(
    ctx: &AppContext,
    entity_ids: &EntityIds,
    user_entity: &mut HashMap<i64, UserEntity>,
) -> Result<()> {
    let messages = MessageModel::find_by_ids(&ctx.db, entity_ids.message_ids()).await?;
    fill_messages_impl(ctx, messages, false, true, user_entity).await
}

/// 填充消息实体到 user_entity。`with_full` 控制已读/表情是否返回完整 top 列表（实时通道 top 5 截断，
/// pipeline 懒拉返回完整）；`include_content` 控制是否携带 `entity.messages` 内容——
/// 已读/表情独立推送与懒拉**不携带消息体**（消息体可能很大，见 docs/data_sync §5），仅填 readstates/reactions。
async fn fill_messages_impl(
    ctx: &AppContext,
    mut db_messages: Vec<messages::Model>,
    with_full: bool,
    include_content: bool,
    user_entity: &mut HashMap<i64, UserEntity>,
) -> Result<()> {
    let mut messages = HashMap::new();
    let mut chat_ids = HashSet::new();
    db_messages.drain(..).for_each(|msg| {
        chat_ids.insert(msg.chat_id);
        messages.entry(msg.chat_id).or_insert(Vec::new()).push(msg);
    });

    {
        let chat_ids: Vec<i64> = chat_ids.drain().collect();
        let _ = crate::chat::cache_chat_load(ctx, &chat_ids).await;
    }

    // per chat
    for (chat_id, msgs) in messages.iter() {
        let cmv = {
            let chat = super::chat::chat_cache_get(ctx, *chat_id).await?;
            let chat = chat.read().await;
            chat.cmv.clone()
        };

        // per message
        for message in msgs.iter() {
            let reactions = pb_default::<Reactions>(&message.reactions);
            let read_state = VecBool::with(message.cmv_count as u64, message.read_states.to_vec());
            let msg_id = message.id;

            // per user
            for (user_id, ref mut entity) in user_entity.iter_mut() {
                // only chat member read message
                if !cmv.contains_key(*user_id) {
                    continue;
                }
                let mut reactions = reactions.reactions.clone();
                for (_id, reaction) in reactions.iter_mut() {
                    if reaction.top_ids.contains(&user_id) {
                        reaction.me_read = true;
                    }
                    if !with_full {
                        reaction.top_ids.shrink_to(5);
                    }
                }

                let read_user_ids = cmv.extract(&read_state);
                let mut read_state = entity::ReadState::default();
                if read_user_ids.contains(&user_id) {
                    read_state.me_read = true;
                }
                if with_full {
                    read_state.top_read_ids = read_user_ids.clone();
                } else {
                    read_state.top_read_ids = read_user_ids.iter().take(5).copied().collect();
                }
                read_state.total = message.cmv_count;
                read_state.read_count = read_user_ids.len() as i32;
                read_state.unread_count = message.cmv_count - read_user_ids.len() as i32;
                // 已读 / 表情为独立实体（id = message_id），随 Entity.readstates / Entity.reactions 下发；
                // 内容仍来自 messages 行内 read_states / reactions 列，见 docs/data_sync §5。
                read_state.id = msg_id;
                read_state.version = message.readstate_version;
                entity.entity.readstates.insert(msg_id, read_state);
                entity
                    .entity
                    .reactions
                    .insert(msg_id, entity::Reactions {
                        id: msg_id,
                        reactions,
                        version: message.reaction_version,
                    });

                // 仅当 include_content 时携带消息体（大消息体避免随已读/表情反复下发）
                if include_content {
                    let msg: entity::Message = MessageModel(message.clone()).into();
                    entity.entity.messages.insert(msg_id, msg);
                }
            }
        }
    }

    Ok(())
}

/// 推送消息实体到在线用户（PushMessages，pipe=false）。
/// `include_content`：内容变更（发送/撤回/删除/语音）传 true 携带 `entity.messages`；
/// 已读/表情等独立实体变更传 false，只携带 `entity.readstates` / `entity.reactions`，
/// 避免大消息体随已读/表情反复下发（见 docs/data_sync §5）。
pub(crate) async fn push_messages(
    ctx: &AppContext,
    _brief: &UserBrief,
    user_ids: &[i64],
    message_ids: &[i64],
    include_content: bool,
) -> Result<()> {
    let entity_ids = EntityIds {
        message_ids: message_ids.iter().copied().collect(),
        ..Default::default()
    };

    let mut pushs: Vec<_> = user_ids
        .iter()
        .map(|id| (*id, message::PushMessages::default()))
        .collect();
    let mut user_entity: HashMap<i64, UserEntity> = user_ids
        .iter()
        .map(|id| {
            let mut entity = UserEntity::default();
            entity.user_id = *id;
            (*id, entity)
        })
        .collect();
    {
        let messages = MessageModel::find_by_ids(&ctx.db, entity_ids.message_ids()).await?;
        let _ = fill_messages_impl(ctx, messages, false, include_content, &mut user_entity).await;
    }

    for (id, push) in pushs.iter_mut() {
        // 将 fill_messages 为每个用户填好的 entity 写入 push 载荷
        if let Some(ue) = user_entity.get(id) {
            push.entity = Some(ue.entity.clone());
        }
        let hub = BizHub::get()?;
        let sid = id_gen(None);
        let _ = hub
            .gateway
            .send_packet_to_user(
                ctx,
                &vec![*id],
                sid,
                Command::PushMessages,
                push.encode_to_vec(),
                false,
            )
            .await;
    }
    Ok(())
}

/// 推送消息已读实体到在线用户（PUSH_MESSAGE_READSTATE=1212，pipe=false）。
/// 载荷为 PushReadMessageRequest{ entity }，只携带 entity.readstates（key=message_id），
/// 不下发消息体/表情（与 1211 消息内容变更通道区分，见 docs/data_sync §5）。
pub(crate) async fn push_message_readstate(
    ctx: &AppContext,
    user_ids: &[i64],
    message_ids: &[i64],
) -> Result<()> {
    let entity_ids = EntityIds {
        message_ids: message_ids.iter().copied().collect(),
        ..Default::default()
    };

    let mut pushs: Vec<_> = user_ids
        .iter()
        .map(|id| (*id, message::PushReadMessageRequest::default()))
        .collect();
    let mut user_entity: HashMap<i64, UserEntity> = user_ids
        .iter()
        .map(|id| {
            let mut entity = UserEntity::default();
            entity.user_id = *id;
            (*id, entity)
        })
        .collect();
    {
        let messages = MessageModel::find_by_ids(&ctx.db, entity_ids.message_ids()).await?;
        let _ = fill_messages_impl(ctx, messages, false, false, &mut user_entity).await;
    }

    for (id, push) in pushs.iter_mut() {
        // 将 fill_messages 为每个用户填好的 entity 写入 push 载荷
        if let Some(ue) = user_entity.get(id) {
            push.entity = Some(ue.entity.clone());
        }
        let hub = BizHub::get()?;
        let sid = id_gen(None);
        let _ = hub
            .gateway
            .send_packet_to_user(
                ctx,
                &vec![*id],
                sid,
                Command::PushMessageReadstate,
                push.encode_to_vec(),
                false,
            )
            .await;
    }
    Ok(())
}

/// 实体变更走 pipeline 实体变更通道（PUSH_ENTITY_CHANGE，pipe=true 持久化）。
/// 只推轻量 EntityChange{id,type,version,operate}，不携带实体内容；SDK 收到后 mark dirty + 按需懒拉。
/// operate：Update（已读/reaction/内容变更）、Delete（撤回/删除）等，见 entity.Operate。
pub(crate) async fn push_entity_changed(
    ctx: &AppContext,
    user_ids: &[i64],
    message_ids: &[i64],
    version: i64,
    operate: entity::Operate,
    entity_type: entity::EntityType,
) -> Result<()> {
    if user_ids.is_empty() || message_ids.is_empty() {
        return Ok(());
    }
    let mut changes = Vec::new();
    for id in message_ids {
        changes.push(entity::EntityChange {
            id: *id,
            r#type: entity_type as i32,
            version,
            operate: operate as i32,
        });
    }
    let hub = BizHub::get()?;
    let sid = id_gen(None);
    let push = pipeline::PushEntityChanged {
        changes,
        ..Default::default()
    };
    let _ = hub
        .gateway
        .send_packet_to_user(
            ctx,
            user_ids,
            sid,
            Command::PushEntityChange,
            push.encode_to_vec(),
            true,
        )
        .await;
    Ok(())
}

pub(crate) async fn message_send(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let mut req = pb_decode::<message::SendMessageRequest>(&packet.payload)?;
    let mut resp = message::SendMessageResponse::default();
    let mut push = message::PushMessages::default();
    let id = id_gen(None);

    debug!("user send message, req: {:?}", req);

    // M2 Step 4.3: 禁言检查 (Owner/Admin 豁免)
    let _chat_context = super::chat::chat_cache_get(ctx, req.message.as_ref().map(|m| m.chat_id).unwrap_or(0)).await?;
    {
        let c = _chat_context.read().await;
        if c.chat.r#type == entity::ChatType::ChatGroup as i16 {
            let is_owner = c.chat.owner_id == brief.id;
            let is_admin = c.chat.admin_ids.contains(&brief.id);
            if !is_owner && !is_admin {
                // 检查全局禁言
                if let Some(mute_until) = c.chat.global_mute_until {
                    if mute_until.timestamp_millis() > current_ms() as i64 {
                        return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
                    }
                }
                // 检查个体禁言
                let mute_rows = ctx.db.query_all(Statement::from_sql_and_values(
                    DbBackend::Postgres,
                    "SELECT 1 FROM group_mutes WHERE chat_id = $1 AND member_id = $2 AND muted_until > NOW() LIMIT 1",
                    vec![c.chat.id.into(), brief.id.into()],
                )).await.map_err(|e| common_error(&format!("mute check error: {e}")))?;
                if !mute_rows.is_empty() {
                    return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
                }
            }
        }
    }

    let mut message = req.message.take().ok_or(Error::string("bad request"))?;
    message.id = id;
    message.from_id = brief.id;
    let now_ms = current_ms() as i64;
    message.create_time_ms = now_ms;
    message.update_time_ms = now_ms;

    // ─── Step 2: @Mention parsing + @all validation ─────────────────
    if !message.content.is_empty() {
        if let Ok(text) = entity::MessageText::decode(message.content.as_slice()) {
            let mut at_ids = Vec::new();
            let mut has_at_all = false;
            for mention in text.mentions.iter() {
                if mention.user_id == -1 {
                    has_at_all = true;
                } else if mention.user_id > 0 && !at_ids.contains(&mention.user_id) {
                    at_ids.push(mention.user_id);
                }
            }
            if has_at_all {
                let c = _chat_context.read().await;
                if c.chat.r#type == entity::ChatType::ChatGroup as i16 {
                    let allow = ctx.db.query_one(Statement::from_sql_and_values(
                        DbBackend::Postgres,
                        "SELECT allow_at_all FROM chats WHERE id = $1",
                        vec![c.chat.id.into()],
                    )).await.map_err(|e| common_error(&format!("query allow_at_all error: {e}")))?
                    .and_then(|row| row.try_get::<bool>("", "allow_at_all").ok())
                    .unwrap_or(true);
                    if !allow {
                        return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
                    }
                }
                // Expand @all to all member IDs
                let c2 = _chat_context.read().await;
                at_ids = c2.cmv.ids();
            }
            message.at_user_ids = at_ids;
        }
    }

    // debug!("step 1.1");
    let mut message = MessageModel::from(message).0;

    // ─── Step 4: Thread meta tracking ────────────────────────────────
    if message.thread_root_id > 0 {
        let user_name = if let Ok(hub) = BizHub::get() {
            hub.user.get_user_by_id(ctx, brief.id).await.map(|u| u.name).unwrap_or_default()
        } else {
            String::new()
        };
        let summary = if message.summary.is_empty() {
            format!("[回复] {}", user_name)
        } else {
            message.summary.clone()
        };
        let _ = ctx.db.execute(Statement::from_sql_and_values(
            DbBackend::Postgres,
            r#"
            INSERT INTO chat_threads (id, chat_id, root_message_id, message_count, last_message_at, last_message_id, last_message_summary, last_message_from_id)
            VALUES ($1, $2, $3, 1, NOW(), $4, $5, $6)
            ON CONFLICT (chat_id, root_message_id) DO UPDATE SET
                message_count = chat_threads.message_count + 1,
                last_message_at = NOW(),
                last_message_id = $4,
                last_message_summary = $5,
                last_message_from_id = $6
            "#,
            vec![
                id_gen(None).into(),
                message.chat_id.into(),
                message.thread_root_id.into(),
                message.id.into(),
                summary.into(),
                brief.id.into(),
            ],
        )).await;
    }

    debug!("start insert message: {:?}", message);
    let member_ids = super::chat::update_last_message(ctx, brief, &mut message).await?;
    // debug!("step 1.2");
    // let message = MessageModel::create_message(&ctx.db, brief.id, &message).await?;
    let _ = CACHE_MESSAGE
        .insert(message.id, Arc::new(RwLock::new(message.clone().into())))
        .await;
    let message = MessageModel(message).into();
    debug!("create message success: {:?}", message);
    super::feed::update_last_message(ctx, &member_ids, &message).await?;
    // 发送者发出本会话最新消息：把其已读游标推进到本条消息（read_badge=本条 badge_count）。
    // 发送者必然已读到最新位置，多端一致：任一设备发送，本账号该会话即视为已读、未读归零。
    // 已读位置由服务端权威持久化，但**不推送** PUSH_FEED_READ_STATUS：新消息已随 PushMessages
    // 下发到发送者各端，各端 SDK 应用这条自家消息时本地同步推进已读（见 SDK feed_update_by_messages），
    // 避免多余推送。防回退：若本账号 read_pos 已更高则 update_read_pos 不推进。
    if let Err(e) = super::feed::feed_update_read_pos_local(
        ctx,
        message.chat_id,
        brief.id,
        message.pos as i32,
        message.badge_count as i32,
    )
    .await
    {
        debug!("update sender feed read pos error: {e}");
    }
    resp.id = message.id;
    resp.entity
        .get_or_insert_default()
        .messages
        .insert(message.id, message.clone());
    push.entity
        .get_or_insert_default()
        .messages
        .insert(message.id, message.clone());

    if let Ok(hub) = BizHub::get() {
        debug!("push message to users: {:?}", member_ids);
        let sid = rid();
        hub.gateway
            .send_packet_to_user(
                ctx,
                &member_ids,
                sid,
                Command::PushMessages,
                push.encode_to_vec(),
                false,
            )
            .await?;
    }

    // Bot 事件触发：检查 chat 中是否有 Bot 用户
    let msg_chat_id = message.chat_id;
    let msg_id = message.id;
    let msg_from_id = message.from_id;
    let msg_content = message.content.clone();
    let msg_type = message.tpy;
    let ctx_clone = ctx.clone();
    tokio::spawn(async move {
        if let Err(e) = trigger_bot_message_event(&ctx_clone, msg_chat_id, msg_id, msg_from_id, msg_content, msg_type).await {
            debug!("trigger bot event error: {e}");
        }
    });

    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

pub(crate) async fn message_read(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<message::MessageReadRequest>(&packet.payload)?;
    let resp = message::MessageReadResponse::default();
    debug!("message read, req: {:?}", req);
    // 会话已读位置（max_pos + 透传的 max_badge_count → feed），见 data_sync §6.2 / §6.3
    if req.max_pos != 0 {
        super::feed::feed_update_read_pos(
            ctx,
            req.chat_id,
            brief.id,
            req.max_pos,
            req.max_badge_count,
        )
        .await?;
    }
    // 消息级已读实体（精确 message_ids → read state），两套语义独立、互不派生
    if !req.message_ids.is_empty() {
        let messages = cache_message_load(ctx, &req.message_ids).await?;
        let mut cmv_ids = Vec::new();
        let mut msg_cmv_ids = HashMap::new();
        for (_id, msg) in messages.iter() {
            let msg = msg.read().await;
            cmv_ids.push(msg.message.cmv_id);
            msg_cmv_ids.insert(msg.message.id, msg.message.cmv_id);
        }

        let chat = super::chat::cache_cmv_load(ctx, req.chat_id, &cmv_ids).await?;

        let mut changed_ids = HashSet::new();
        let mut changed_message_ids = HashSet::new();

        // 已读实体版本：一次取值用于 set_read 落库与 push_entity_changed 推送，保证两者一致
        // （readstate_version 单调），客户端版本守卫（excluded.version >= version）恒满足、脏标记可清。
        let read_ts = current_ms() as i64;

        for (id, _cmv_id) in msg_cmv_ids.iter() {
            // careful, maybe cause deadlock
            let mut changed = false;
            let msg = messages.get(id).ok_or(common_error("message not found"))?;
            let mut msg = msg.write().await;
            {
                let chat = chat.read().await;
                if chat.cmv.set(&mut msg.read_state_cmv, &vec![brief.id]) {
                    changed = true;
                }
            };
            if changed {
                msg.message.version = read_ts;
                MessageModel::set_read(&ctx.db, *id, read_ts, &msg.read_state_cmv).await?;
                changed_ids.insert(brief.id);
                changed_ids.insert(msg.message.from_id);
                changed_message_ids.insert(*id);
            }
        }

        if !changed_ids.is_empty() {
            let changed_ids: Vec<_> = changed_ids.iter().copied().collect();
            let changed_message_ids: Vec<_> = changed_message_ids.iter().copied().collect();
            // 已读独立实体走 PUSH_MESSAGE_READSTATE（1212），只携带 entity.readstates
            push_message_readstate(ctx, &changed_ids, &changed_message_ids).await?;
            // 已读实体变更走 pipeline 实体变更通道（持久化，离线端重连回放后 mark dirty + 懒拉）
            push_entity_changed(
                ctx,
                &changed_ids,
                &changed_message_ids,
                read_ts,
                entity::Operate::Update,
                entity::EntityType::Readstate,
            )
            .await?;
        }
    }
    debug!("message read, resp: {:?}", resp);
    Ok((ErrorCode::Success as i32, vec![]))
}

pub(crate) async fn message_forward(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<message::ForwardMessageRequest>(&packet.payload)?;
    debug!("message forward, req: {req:?}");

    let source_msgs = MessageModel::find_by_ids(&ctx.db, req.message_ids.clone()).await?;
    let mut source_map: HashMap<i64, messages::Model> = HashMap::new();
    for msg in source_msgs {
        source_map.insert(msg.id, msg);
    }

    // resolve sender names for ForwardItem
    let sender_ids: Vec<i64> = source_map.values().map(|m| m.from_id).collect();
    let sender_names: HashMap<i64, String> = if let Ok(hub) = BizHub::get() {
        hub.user
            .get_user_by_ids(ctx, sender_ids)
            .await
            .unwrap_or_default()
            .into_iter()
            .map(|u| (u.id, u.name))
            .collect()
    } else {
        HashMap::new()
    };

    let now = current_ms() as i64;
    let mut resp = message::ForwardMessageResponse::default();
    let mut result_msgs = Vec::new();
    let mut created_ids = Vec::new();

    if req.forward_type == 0 {
        // single forward: copy each source message
        for src_id in &req.message_ids {
            let Some(src) = source_map.get(src_id) else { continue };

            let msg = entity::Message {
                id: id_gen(None),
                chat_id: req.chat_id,
                from_id: brief.id,
                tpy: src.r#type as i32,
                content: src.content.clone(),
                summary: src.summary.clone(),
                create_time_ms: now,
                update_time_ms: now,
                ..Default::default()
            };

            let mut model = MessageModel::from(msg).0;
            let member_ids =
                super::chat::update_last_message(ctx, brief, &mut model).await?;
            CACHE_MESSAGE
                .insert(model.id, Arc::new(RwLock::new(model.clone().into())))
                .await;
            let created: entity::Message = MessageModel(model.clone()).into();
            super::feed::update_last_message(ctx, &member_ids, &created).await?;

            created_ids.push(created.id);
            result_msgs.push(created);
        }
    } else {
        // merged forward: create one FORWARD message
        let mut items = Vec::new();
        for src_id in &req.message_ids {
            let Some(src) = source_map.get(src_id) else { continue };
            let user_name = sender_names
                .get(&src.from_id)
                .cloned()
                .unwrap_or_default();
            items.push(entity::ForwardItem {
                user_id: src.from_id,
                user_name,
                tpy: src.r#type as i32,
                summary: src.summary.clone(),
                message_id: src.id,
            });
        }

        let chat_name = match super::chat::chat_cache_get(ctx, req.source_chat_id).await {
            Ok(c) => c.read().await.chat.name.clone(),
            Err(_) => String::new(),
        };

        let item_count = items.len();
        let forward_content = entity::MessageForward {
            r#type: 1, // merged
            chat_id: req.source_chat_id,
            chat_name,
            message_count: item_count as i32,
            items,
            ..Default::default()
        };

        let summary = format!("转发了 {} 条消息", item_count);

        let msg = entity::Message {
            id: id_gen(None),
            chat_id: req.chat_id,
            from_id: brief.id,
            tpy: entity::MessageType::Forward as i32,
            content: forward_content.encode_to_vec(),
            summary,
            create_time_ms: now,
            update_time_ms: now,
            ..Default::default()
        };

        let mut model = MessageModel::from(msg).0;
        let member_ids = super::chat::update_last_message(ctx, brief, &mut model).await?;
        CACHE_MESSAGE
            .insert(model.id, Arc::new(RwLock::new(model.clone().into())))
            .await;
        let created: entity::Message = MessageModel(model.clone()).into();
        super::feed::update_last_message(ctx, &member_ids, &created).await?;

        created_ids.push(created.id);
        result_msgs.push(created);
    }

    // push new messages to chat members
    if let Ok(member_ids) = super::chat::chat_get_all_user_ids(ctx, req.chat_id).await {
        let _ = push_messages(ctx, brief, &member_ids, &created_ids, true).await;
    }

    resp.count = result_msgs.len() as i32;
    resp.entity
        .get_or_insert_default()
        .messages
        .extend(result_msgs.into_iter().map(|m| (m.id, m)));

    debug!("message forward, resp count: {}", resp.count);
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

pub(crate) async fn message_recall(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<message::RecallMessageRequest>(&packet.payload)?;
    debug!("message recall, req: {req:?}");

    let resp = message::RecallMessageResponse::default();
    let chat_id;
    {
        let message = cache_get_message(&ctx, req.id).await?;
        let mut message = message.write().await;
        chat_id = message.message.chat_id;
        if message.message.status == EntityStatus::Normal as i16
            || message.message.status == EntityStatus::Deleted as i16
        {
            let now = current_ms() as i64;
            message.message.status = EntityStatus::Recall as i16;
            message.message.version = now;
            MessageModel::set_status(&ctx.db, req.id, now, EntityStatus::Recall as i16).await?;
        }
    }

    if let Ok(user_ids) = super::chat::chat_get_all_user_ids(ctx, chat_id).await {
        let _ = push_messages(ctx, brief, &user_ids, &vec![req.id], true).await;
        // 撤回属实体变更：走 pipeline 实体变更通道（离线端 mark dirty + 懒拉），见 docs/data_sync §5
        let _ = push_entity_changed(
            ctx,
            &user_ids,
            &vec![req.id],
            current_ms() as i64,
            entity::Operate::Delete,
            entity::EntityType::Message,
        )
        .await;
    }
    debug!("message recall, resp: {resp:?}");

    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

pub(crate) async fn message_get_by_ids(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<message::GetMessageByIdsRequest>(&packet.payload)?;
    debug!("message get by ids, req: {req:?}");
    let mut resp = message::GetMessageByIdsResponse::default();
    let messages = MessageModel::find_by_ids(&ctx.db, req.ids).await?;
    let mut map = HashMap::new();
    map.insert(brief.id, UserEntity::default());
    let _ = fill_messages_impl(ctx, messages, req.with_full, true, &mut map).await;
    resp.entity = map.remove(&brief.id).map(|ue| ue.entity);
    debug!("message get by ids, resp: {resp:?}");
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

/// pipeline 实体变更通道的按需懒拉：根据 {entity_id, type, version} 拉取实体内容（含完整 read_state）。
/// 支持 Message / Readstate / Reaction（存储共用 messages 行，按需经 Entity.readstates / Entity.reactions 下发）与 Chat 实体。
/// SDK 收到 PUSH_ENTITY_CHANGE 后 mark dirty，同步完成后统一拉取补齐实体，见 docs/data_sync §5。
pub(crate) async fn pipeline_pull_entity(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<pipeline::PullEntityRequest>(&packet.payload)?;
    debug!("pipeline pull entity, req: {req:?}");
    let mut resp = pipeline::PullEntityResponse::default();
    if req.ids.is_empty() {
        return Ok((ErrorCode::Success as i32, resp.encode_to_vec()));
    }

    // 消息类实体（Message/Readstate/Reaction）存储共用 messages 行，
    // fill_messages_impl 会把内容放 Entity.messages，已读/表情放 Entity.readstates / Entity.reactions
    // 消息类实体：MESSAGE 类型拉取时携带消息体；READSTATE/REACTION 类型只返回
    // entity.readstates / entity.reactions（不含大消息体，见 docs/data_sync §5）。
    let content_ids: std::collections::HashSet<i64> = req
        .ids
        .iter()
        .filter(|id| id.r#type == entity::EntityType::Message as i32)
        .map(|id| id.id)
        .collect();
    let side_ids: Vec<i64> = req
        .ids
        .iter()
        .filter(|id| {
            matches!(
                id.r#type,
                x if x == entity::EntityType::Readstate as i32
                    || x == entity::EntityType::Reaction as i32
            )
        })
        .map(|id| id.id)
        .collect();
    let side_only: Vec<i64> = side_ids
        .iter()
        .copied()
        .filter(|id| !content_ids.contains(id))
        .collect();

    let mut map = HashMap::new();
    map.insert(brief.id, UserEntity::default());
    if !content_ids.is_empty() {
        let messages = MessageModel::find_by_ids(&ctx.db, content_ids.into_iter().collect()).await?;
        let _ = fill_messages_impl(ctx, messages, true, true, &mut map).await;
    }
    if !side_only.is_empty() {
        let messages = MessageModel::find_by_ids(&ctx.db, side_only).await?;
        let _ = fill_messages_impl(ctx, messages, true, false, &mut map).await;
    }
    resp.entity = map.remove(&brief.id).map(|ue| ue.entity);

    // Chat 实体：拉取 chat 详情（含成员列表）
    let chat_ids: Vec<i64> = req
        .ids
        .iter()
        .filter(|id| id.r#type == entity::EntityType::Chat as i32)
        .map(|id| id.id)
        .collect();
    if !chat_ids.is_empty() {
        let _ = super::chat::cache_chat_load(ctx, &chat_ids).await;
        let entity = resp.entity.get_or_insert_default();
        for id in chat_ids {
            if let Ok(chat) = super::chat::chat_cache_get(ctx, id).await {
                let chat = chat.read().await;
                entity.chats.insert(
                    id,
                    crate::models::chats::ChatModel(chat.chat.clone()).into_entity(chat.cmv.ids()),
                );
            }
        }
    }

    debug!(
        "pipeline pull entity, resp: {:?}",
        resp.entity.as_ref().map(|e| e.messages.keys().collect::<Vec<_>>())
    );
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

pub(crate) async fn message_get_by_pos(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<message::GetMessageByPosRequest>(&packet.payload)?;
    let mut resp = message::GetMessageByPosResponse::default();
    debug!("get message by pos, req: {:?}", req);
    let entity = &mut resp.entity.get_or_insert_default();
    let messages = MessageModel::find_by_pos(&ctx.db, req.chat_id, req.pos).await?;
    debug!("get messages: {messages:?}");
    let mut map = HashMap::new();
    map.insert(brief.id, UserEntity::default());
    let _ = fill_messages_impl(ctx, messages, false, true, &mut map).await;
    resp.entity = map.remove(&brief.id).map(|ue| ue.entity);
    debug!("get message by pos, resp: {:?}", resp);
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

pub(crate) async fn message_get_by_range(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<message::GetMessageByRangeRequest>(&packet.payload)?;
    let mut resp = message::GetMessageByRangeResponse::default();
    debug!("get message by range, req: {:?}", req);
    let mut pos = req.pos;
    let mut count = req.count;
    if req.direct == entity::Direct::Down as i32 || req.direct == entity::Direct::Both as i32 {
        pos = std::cmp::max(1, req.pos - req.count);
    }
    if req.direct == entity::Direct::Both as i32 {
        count *= 2;
    }
    let messages = MessageModel::find_by_range(&ctx.db, req.chat_id, pos, count).await?;
    let mut map = HashMap::new();
    map.insert(brief.id, UserEntity::default());
    let _ = fill_messages_impl(ctx, messages, false, true, &mut map).await;
    resp.entity = map.remove(&brief.id).map(|ue| ue.entity);
    debug!("get message by range, resp: {:?}", resp);
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

pub(crate) async fn reaction_set(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<message::SetMessageReactitonRequest>(&packet.payload)?;
    debug!("reaction set, req: {:?}", req);
    let resp = message::SetMessageReactitonResponse::default();
    let chat_id;
    // reaction 实体版本：置为当前时间，落库（reaction_version 单调）与 push 用同一值，
    // 保证客户端版本守卫（excluded.reaction_version >= version）恒满足、脏标记可清。
    let mut reaction_ts: i64 = 0;

    {
        let message = cache_get_message(ctx, req.message_id).await?;
        let mut message = message.write().await;
        chat_id = message.message.chat_id;
        if message.reactions.set(req.reaction, brief.id) {
            let now = current_ms() as i64;
            reaction_ts = now;
            message.message.updated_at = date_time(now);

            MessageModel::set_reaction(&ctx.db, message.message.id, &message.reactions, now)
                .await?;
        }
    }
    // 无实际变更（重复添加相同表情）时不下发实体变更，避免携带高于现有 reaction_version 的脏标记
    if reaction_ts == 0 {
        debug!("reaction no change, skip push: {req:?}");
        let resp = message::SetMessageReactitonResponse::default();
        return Ok((ErrorCode::Success as i32, resp.encode_to_vec()));
    }
    let mut user_ids = vec![];
    {
        if let Ok(chat) = super::chat::chat_cache_get(ctx, chat_id).await {
            user_ids = chat.read().await.cmv.ids();
        }
    }
    if !user_ids.is_empty() {
        let _ = push_messages(ctx, brief, &user_ids, &vec![req.message_id], false).await;
        // reaction 属实体变更：走 pipeline 实体变更通道（离线端 mark dirty + 懒拉），见 docs/data_sync §5
        let _ = push_entity_changed(
            ctx,
            &user_ids,
            &vec![req.message_id],
            reaction_ts,
            entity::Operate::Update,
            entity::EntityType::Reaction,
        )
        .await;
    }

    debug!("reaction set, resp: {resp:?}");
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

// ─── Step 5: GetReadMembers ──────────────────────────────────────────

pub(crate) async fn message_get_read_members(
    ctx: &AppContext,
    _brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<message::GetReadMembersRequest>(&packet.payload)?;
    debug!("get read members, req: {req:?}");
    // 已读详情：全量返回（仅 ID 级数据、量小）。已读状态最多承载到 ~2000 人的群，超过后仅展示 at 成员，
    // 超大群（几万+）需要独立方案，后续单独处理。
    let mut resp = message::GetReadMembersResponse::default();

    let msg_ctx = cache_get_message(ctx, req.message_id).await?;
    let (chat_id, cmv_count, read_chunks) = {
        let msg = msg_ctx.read().await;
        (msg.message.chat_id, msg.message.cmv_count, msg.message.read_states.clone())
    };

    let chat = super::chat::chat_cache_get(ctx, chat_id).await?;
    let cmv = { chat.read().await.cmv.clone() };

    let read_state = VecBool::with(cmv_count as u64, read_chunks);
    let read_ids: std::collections::HashSet<i64> = cmv.extract(&read_state).into_iter().collect();
    let all_ids = cmv.ids();

    let users = if let Ok(hub) = BizHub::get() {
        hub.user.get_user_by_ids(ctx, all_ids.clone()).await.unwrap_or_default()
    } else {
        Vec::new()
    };
    let user_map: std::collections::HashMap<i64, _> = users.into_iter().map(|u| (u.id, u)).collect();

    for uid in all_ids {
        let is_read = read_ids.contains(&uid);
        let user = user_map.get(&uid);
        resp.members.push(message::ReadMemberItem {
            user_id: uid,
            name: user.map(|u| u.name.clone()).unwrap_or_default(),
            avatar: user.map(|u| u.avatar.clone()).unwrap_or_default(),
            is_read,
        });
    }

    debug!("get read members done, count: {}", resp.members.len());
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

// ─── Step 8: DeleteMessage ───────────────────────────────────────────

pub(crate) async fn message_delete(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<message::DeleteMessageRequest>(&packet.payload)?;
    debug!("delete message, req: {req:?}");
    let resp = message::DeleteMessageResponse::default();

    if req.mode == 0 {
        // local delete — nothing to do server-side
        return Ok((ErrorCode::Success as i32, resp.encode_to_vec()));
    }

    // global delete — verify permission
    let msg_ctx = cache_get_message(ctx, req.message_id).await?;
    let chat_id = { msg_ctx.read().await.message.chat_id };

    let chat = super::chat::chat_cache_get(ctx, chat_id).await?;
    {
        let c = chat.read().await;
        if c.chat.r#type == entity::ChatType::ChatGroup as i16 {
            let is_owner = c.chat.owner_id == brief.id;
            let is_admin = c.chat.admin_ids.contains(&brief.id);
            if !is_owner && !is_admin {
                return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
            }
        }
    }

    // Set status = Deleted (2)
    let now = current_ms() as i64;
    {
        let mut msg = msg_ctx.write().await;
        msg.message.status = EntityStatus::Deleted as i16;
        msg.message.version = now;
    }
    MessageModel::set_status(&ctx.db, req.message_id, now, EntityStatus::Deleted as i16).await?;

    // Push to all chat members (删除属内容变更，携带消息体 tombstone)
    if let Ok(user_ids) = super::chat::chat_get_all_user_ids(ctx, chat_id).await {
        let _ = push_messages(ctx, brief, &user_ids, &vec![req.message_id], true).await;
        // 删除属实体变更：走 pipeline 实体变更通道（离线端 mark dirty + 懒拉），见 docs/data_sync §5
        let _ = push_entity_changed(
            ctx,
            &user_ids,
            &vec![req.message_id],
            now,
            entity::Operate::Delete,
            entity::EntityType::Message,
        )
        .await;
    }

    debug!("delete message done");
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

// ─── Bot 事件触发 ─────────────────────────────────────────────

/// 消息发送后，检查 chat 中是否有 Bot 用户，触发 im.message.receive 事件
pub(crate) async fn trigger_bot_message_event(
    ctx: &AppContext,
    chat_id: i64,
    message_id: i64,
    from_id: i64,
    content: Vec<u8>,
    msg_type: i32,
) -> Result<()> {
    let member_ids = super::chat::chat_get_all_user_ids(ctx, chat_id).await?;
    if member_ids.is_empty() {
        return Ok(());
    }

    // 查询在线 Bot 用户
    let bots = find_bot_users(ctx, &member_ids).await?;
    if bots.is_empty() {
        return Ok(());
    }

    let hub = match BizHub::get() {
        Ok(h) => h,
        Err(_) => return Ok(()),
    };

    for (bot_user_id, app_db_id, app_id_str) in bots {
        let payload = serde_json::json!({
            "message_id": message_id,
            "chat_id": chat_id,
            "chat_type": 2,
            "sender": {
                "user_id": from_id,
            },
            "msg_type": msg_type,
            "content": serde_json::Value::Null,
        });
        let payload_str = serde_json::to_string(&payload).unwrap_or_default();
        let _ = hub.openapp.dispatch_event(
            ctx, app_db_id, &app_id_str, "im.message.receive", &payload_str,
        ).await;
    }

    Ok(())
}

/// 查询成员列表中哪些是 Bot 用户
pub(crate) async fn find_bot_users(
    ctx: &AppContext,
    member_ids: &[i64],
) -> Result<Vec<(i64, i64, String)>> {
    use sea_orm::{ColumnTrait, EntityTrait, QueryFilter};
    use base::models::_entities::users;

    let bots = users::Entity::find()
        .filter(
            sea_orm::Condition::all()
                .add(users::Column::Id.is_in(member_ids.iter().copied()))
                .add(users::Column::Type.eq(proto::idl::entity::UserType::Bot as i16))
                .add(users::Column::Status.eq(common::EntityStatus::Normal as i16)),
        )
        .all(&ctx.db)
        .await?;

    let mut result = Vec::new();
    for bot in bots {
        let app_db_id = bot.bot_app_id.unwrap_or(0);
        if app_db_id == 0 {
            continue;
        }
        // 查询 app_id 字符串
        if let Ok(Some(app)) = base::models::_entities::open_apps::Entity::find_by_id(app_db_id)
            .one(&ctx.db)
            .await
        {
            result.push((bot.id, app_db_id, app.app_id));
        }
    }
    Ok(result)
}
