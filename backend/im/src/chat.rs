use loco_rs::{Result, app::AppContext};
use prost::Message;
use std::collections::HashMap;
use std::sync::{Arc, LazyLock};
use tokio::sync::RwLock;
use tracing::debug;

use loco_rs::prelude::DateTimeWithTimeZone;
use super::{ChatContext, VecBool};
use sea_orm::{ActiveValue, EntityTrait};
use crate::models::{Cmv, chats::{ChatModel, ActiveModel, Entity as ChatEntity}, cmvs, feeds::FeedModel, messages};
use common::{BizHub, CacheLoader, CommonCache, EntityIds, EntityStatus, UserBrief};
use common::{common_error, pb_decode, rid, time::current_ms};
use proto::idl::{chat, command::Command, entity, error::ErrorCode, message};

type CacheChat = Arc<RwLock<ChatContext>>;
static CACHE_CHAT: LazyLock<CommonCache<i64, CacheChat>> =
    LazyLock::new(|| CommonCache::new(10000, Arc::new(Box::new(ChatLoader))));

struct ChatLoader;
#[async_trait::async_trait]
impl CacheLoader<i64, CacheChat> for ChatLoader {
    async fn load(&self, ctx: &AppContext, ids: &[i64]) -> Result<HashMap<i64, CacheChat>> {
        let mut result = HashMap::new();
        let mut db_chats = ChatModel::get_by_ids(&ctx.db, ids.to_vec()).await?;
        for chat in db_chats.drain(..) {
            let chat_id = chat.id;
            let cmv = match Cmv::from(&chat.cmv) {
                Ok(cmv) => cmv,
                Err(_) => continue,
            };
            let cmv_id = cmv.id;
            let cur = cmv.cmv.clone();
            let mut context = ChatContext {
                chat: chat,
                cmv,
                cmvs: HashMap::new(),
            };
            context.cmvs.insert(cmv_id, cur);
            result.insert(chat_id, Arc::new(RwLock::new(context)));
        }
        Ok(result)
    }

    async fn get(&self, ctx: &AppContext, id: &i64) -> Result<CacheChat> {
        let chat = ChatModel::get_chat(&ctx.db, *id).await?;
        let cmv = Cmv::from(&chat.cmv)?;
        let mut context = ChatContext {
            chat,
            cmv,
            cmvs: HashMap::new(),
        };

        context.cmvs.insert(context.cmv.id, context.cmv.cmv.clone());
        Ok(Arc::new(RwLock::new(context)))
    }
}

pub async fn cache_cmv_load(ctx: &AppContext, chat_id: i64, cmv_ids: &[i64]) -> Result<CacheChat> {
    let mut missing = Vec::new();
    let cache = CACHE_CHAT.get(ctx, &chat_id).await?;
    {
        let chat = cache.read().await;
        for id in cmv_ids.iter() {
            if !chat.cmvs.contains_key(id) {
                missing.push(*id);
            }
        }
    }
    if missing.is_empty() {
        return Ok(cache);
    }
    let mut cmvs = cmvs::CmvModel::find_by_ids(&ctx.db, &missing).await?;
    {
        let mut chat = cache.write().await;

        for cmv in cmvs.drain(..) {
            chat.cmvs
                .entry(cmv.id)
                // TODO chunks
                .or_insert(VecBool::with(cmv.count as u64, vec![]));
        }
    }
    Ok(cache)
}

pub async fn cache_chat_load(ctx: &AppContext, ids: &[i64]) -> Result<HashMap<i64, CacheChat>> {
    CACHE_CHAT.load(ctx, ids).await
}

pub(crate) async fn chat_cache_get(
    ctx: &AppContext,
    chat_id: i64,
) -> Result<Arc<RwLock<ChatContext>>> {
    CACHE_CHAT.get(ctx, &chat_id).await
}

pub(crate) async fn chat_get_all_user_ids(ctx: &AppContext, id: i64) -> Result<Vec<i64>> {
    let chat = chat_cache_get(ctx, id).await?;
    let chat = chat.read().await;
    Ok(chat.cmv.ids())
}

pub(crate) async fn chat_cache_get_by_ids(
    ctx: &AppContext,
    entity_ids: &mut EntityIds,
    entity: &mut entity::Entity,
) -> Result<()> {
    entity_ids.chat_ids.remove(&0);
    if entity_ids.chat_ids.is_empty() {
        return Ok(());
    }
    debug!("chat cache get by ids: {:?}", entity_ids.chat_ids);
    let ids: Vec<_> = entity_ids.chat_ids.iter().copied().collect();
    let chats = cache_chat_load(ctx, &ids).await?;
    for id in ids.iter() {
        if let Some(chat) = chats.get(&id) {
            let chat = chat.read().await;
            let member_ids = chat.cmv.ids();
            entity
                .chats
                .insert(*id, ChatModel(chat.chat.clone()).into_entity(member_ids));
        }
    }
    entity_ids
        .chat_ids
        .retain(|id| !entity.chats.contains_key(id));

    entity.chats.iter().for_each(|(_id, c)| {
        if c.last_message_id != 0 {
            entity_ids.message_ids.insert(c.last_message_id);
        }
    });
    Ok(())
}

pub(crate) async fn update_last_message(
    ctx: &AppContext,
    _brief: &UserBrief,
    msg: &mut messages::Model,
) -> Result<Vec<i64>> {
    // get cache
    let context = chat_cache_get(ctx, msg.chat_id).await?;
    let mut member_ids = Vec::new();
    {
        let mut c = context.write().await;
        msg.pos = c.chat.last_message_pos as i32 + 1;
        // badge_count 枚举（见 data_sync §6.1）：仅系统消息不 +badge，其余逐条 +1
        msg.badge = if msg.r#type == entity::MessageType::System as i16 {
            c.chat.last_message_badge as i32
        } else {
            c.chat.last_message_badge as i32 + 1
        };
        msg.cmv_id = c.cmv.id;
        msg.cmv_count = c.cmv.count;
        // 创建消息时直接初始化实体版本与已读状态（见 docs/data_sync §5）：
        // - version / readstate_version / reaction_version 用当前时间初始化，保证 PULL_ENTITY
        //   至少返回有效版本，版本合并守卫（excluded.version >= incoming_version）能正常清脏，
        //   避免「无已读」场景下实体版本为 0、脏标记版本守卫失败导致反复拉取。
        // - 发送者对自己发出的消息视为已读（me_read=true、read_count 计入发送者），
        //   已读/表情独立实体始终存在且带版本，不再返回空。
        let now_ms = current_ms() as i64;
        let mut read_state = VecBool::with_zeros(c.cmv.count as u64);
        let _ = c.cmv.set(&mut read_state, &[msg.from_id]);
        msg.read_count = read_state.iter().filter(|b| *b).count() as i32;
        msg.read_states = read_state.chunks;
        msg.version = now_ms;
        msg.readstate_version = now_ms;
        msg.reaction_version = now_ms;
        if c.chat.r#type == entity::ChatType::ChatP2p as i16 {
            member_ids.push(c.chat.peer_a_id);
            member_ids.push(c.chat.peer_b_id);
        } else {
            member_ids = c.cmv.ids();
        }
        ChatModel::update_last_message(&ctx.db, &c.chat, &msg).await?;
        c.chat.last_message_badge = msg.badge as i32;
        c.chat.last_message_pos = msg.pos as i32;
        c.chat.last_message_id = msg.id;
    }

    Ok(member_ids)
}

pub(crate) async fn chat_create(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let mut req = pb_decode::<chat::CreateChatRequest>(&packet.payload)?;
    debug!("chat create req: {:?}", req);
    let mut chat = req.chat.get_or_insert_default();
    let mut member_ids = Vec::new();
    let mut resp = chat::CreateChatResponse::default();

    let chat = match chat.chat_type {
        _ if entity::ChatType::ChatP2p as i32 == chat.chat_type => {
            // check p2p chat exists
            let peer_id = if chat.peer_a_id == brief.id {
                chat.peer_b_id
            } else {
                chat.peer_a_id
            };
            member_ids.push(peer_id);
            if brief.id != peer_id {
                member_ids.push(brief.id);
            }
            debug!("create p2p chat, member: {:?}", member_ids);
            if let Ok(chat) = ChatModel::find_p2p_chat(&ctx.db, brief.id, peer_id).await {
                debug!("p2p chat already exists: {:?}", chat);
                resp.chat_id = chat.id as i64;
                resp.entities
                    .get_or_insert(entity::Entity::default())
                    .chats
                    .insert(chat.id as i64, ChatModel(chat).into_entity(vec![]));

                return Ok((ErrorCode::Success as i32, resp.encode_to_vec()));
            }
            ChatModel::create_p2p_chat(&ctx.db, brief.id, peer_id).await
        }
        _ if entity::ChatType::ChatGroup as i32 == chat.chat_type => {
            if !chat.member_ids.contains(&brief.id) {
                chat.member_ids.insert(0, brief.id);
            }
            if chat.name.is_empty() {
                let ids: Vec<i64> = chat.member_ids.iter().take(4).copied().collect();
                let biz = BizHub::get()?;
                let users = biz.user.get_user_by_ids(ctx, ids).await?;
                for u in users.iter() {
                    chat.name += &format!("{},", u.name);
                }
                chat.name.pop();
                if member_ids.len() > 4 {
                    chat.name += "...More";
                }
            }
            ChatModel::create_group_chat(&ctx.db, brief.id, chat).await
        }
        _ => {
            return Err(common_error("chat type erorr"));
        }
    };
    debug!("create feed for user: {:?}", member_ids);
    if let Ok(chat) = chat {
        let chat: entity::Chat = ChatModel(chat).into_entity(member_ids);
        let chat_id = chat.id;
        resp.chat_id = chat.id;
        resp.entities
            .get_or_insert(entity::Entity::default())
            .chats
            .insert(chat.id as i64, chat);
        let ctx_clone = ctx.clone();
        tokio::spawn(async move {
            let _ = crate::feed::push_feed_by_ids(&ctx_clone, vec![chat_id]).await;
        });

        return Ok((ErrorCode::Success as i32, resp.encode_to_vec()));
    } else {
        debug!("create chat error: {:?}", chat);
        return Err(common_error("create chat error"));
    }
}

/// chat 实体变更版本：单调递增（取 max(prev+1, now_ms)），保证 pipeline 变更通道去重/防回退。
pub(crate) fn bump_chat_version(prev: i64) -> i64 {
    let now = current_ms() as i64;
    if prev < now {
        now
    } else {
        prev + 1
    }
}

pub(crate) async fn chat_add_chatters(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<chat::AddChatChatterRequest>(&packet.payload)?;
    debug!("chat add chatters, req: {req:?}");
    let context = chat_cache_get(ctx, req.chat_id).await?;
    let mut user_ids = None;
    let mut changed_version = 0i64;
    {
        let mut c = context.write().await;

        if c.chat.r#type == entity::ChatType::ChatP2p as i16 {
            return Ok((ErrorCode::ErrorNoPermision as i32, vec![]));
        }

        // M2 Step 6.3: join_mode 权限检查
        if c.chat.join_mode == 2 {
            let is_owner = c.chat.owner_id == brief.id;
            let is_admin = c.chat.admin_ids.contains(&brief.id);
            if !is_owner && !is_admin {
                return Ok((ErrorCode::ErrorNoPermision as i32, vec![]));
            }
        }

        if c.cmv.add(&req.ids)? {
            c.chat.version = bump_chat_version(c.chat.version);
            changed_version = c.chat.version;
            ChatModel::update_cmv(
                &ctx.db,
                c.chat.id,
                changed_version,
                None,
                None,
                &mut c.cmv,
            )
            .await?;
            // send packet to users
            user_ids = Some(c.cmv.ids());

            let _ = FeedModel::create_by_chat(&ctx.db, &c.chat, &req.ids).await;
        }
    }
    // Bot 事件触发：检查添加的成员中是否有 Bot
    let added_ids = req.ids.clone();
    if !added_ids.is_empty() {
        let ctx_clone = ctx.clone();
        let chat_id = req.chat_id;
        tokio::spawn(async move {
            if let Err(e) = trigger_bot_added_event(&ctx_clone, chat_id, &added_ids).await {
                tracing::debug!("trigger bot added event error: {e}");
            }
        });
    }

    if let Some(ids) = user_ids {
        let _ = crate::feed::update_feed_status(ctx, req.chat_id, &ids, None).await;
        // 群成员变更属 chat 实体变更：走 pipeline 实体变更通道（离线端 mark dirty + 拉取）
        if changed_version > 0 {
            let _ = crate::message::push_entity_changed(
                ctx,
                &ids,
                &[req.chat_id],
                changed_version,
                entity::Operate::Update,
                entity::EntityType::Chat,
            )
            .await;
        }
    }
    debug!("chat add chatters done");
    Ok((0, vec![]))
}

/// Bot 被加入群聊事件
async fn trigger_bot_added_event(ctx: &AppContext, chat_id: i64, added_ids: &[i64]) -> Result<()> {
    let bots = crate::message::find_bot_users(ctx, added_ids).await?;
    if bots.is_empty() {
        return Ok(());
    }
    let hub = match common::BizHub::get() {
        Ok(h) => h,
        Err(_) => return Ok(()),
    };
    for (_bot_user_id, app_db_id, app_id_str) in bots {
        let payload = serde_json::json!({
            "chat_id": chat_id,
        });
        let payload_str = serde_json::to_string(&payload).unwrap_or_default();
        let _ = hub.openapp.dispatch_event(
            ctx, app_db_id, &app_id_str, "im.group.added_bot", &payload_str,
        ).await;
    }
    Ok(())
}

pub(crate) async fn chat_delete_chatters(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<chat::RemoveChatChatterRequest>(&packet.payload)?;
    debug!("chat delete chatters, req: {req:?}");
    let context = chat_cache_get(ctx, req.chat_id).await?;
    // let mut member_ids = Vec::new();
    let mut user_ids = None;
    let mut changed_version = 0i64;
    {
        let mut c = context.write().await;
        let mut admin_ids = None;
        if c.chat.r#type == entity::ChatType::ChatP2p as i16
            || !(c.chat.owner_id == brief.id || c.chat.admin_ids.contains(&brief.id))
        {
            return Ok((ErrorCode::ErrorNoPermision as i32, vec![]));
        }
        if c.cmv.remove(&req.ids)? {
            {
                let admin_len = c.chat.admin_ids.len();
                c.chat.admin_ids.retain(|id| !req.ids.contains(id));
                if admin_len != c.chat.admin_ids.len() {
                    admin_ids = Some(c.chat.admin_ids.clone());
                }
            }
            c.chat.version = bump_chat_version(c.chat.version);
            changed_version = c.chat.version;
            let _ = ChatModel::update_cmv(
                &ctx.db,
                c.chat.id,
                changed_version,
                None,
                admin_ids,
                &mut c.cmv,
            )
            .await?;
            user_ids = Some(c.cmv.ids());
        }
    }
    let _ = crate::feed::update_feed_status(
        ctx,
        req.chat_id,
        &req.ids,
        Some(EntityStatus::DeletePending as i32),
    )
    .await;
    // Bot 事件触发：检查移除的成员中是否有 Bot
    let removed_ids = req.ids.clone();
    if !removed_ids.is_empty() {
        let ctx_clone = ctx.clone();
        let chat_id = req.chat_id;
        tokio::spawn(async move {
            if let Err(e) = trigger_bot_removed_event(&ctx_clone, chat_id, &removed_ids).await {
                tracing::debug!("trigger bot removed event error: {e}");
            }
        });
    }

    if let Some(ids) = user_ids {
        let _ = crate::feed::update_feed_status(ctx, req.chat_id, &ids, None).await;
        // 群成员变更属 chat 实体变更：走 pipeline 实体变更通道（离线端 mark dirty + 拉取）
        if changed_version > 0 {
            let _ = crate::message::push_entity_changed(
                ctx,
                &ids,
                &[req.chat_id],
                changed_version,
                entity::Operate::Update,
                entity::EntityType::Chat,
            )
            .await;
        }
    }
    debug!("chat delete chatters done");
    Ok((0, vec![]))
}

/// Bot 被移出群聊事件
async fn trigger_bot_removed_event(ctx: &AppContext, chat_id: i64, removed_ids: &[i64]) -> Result<()> {
    let bots = crate::message::find_bot_users(ctx, removed_ids).await?;
    if bots.is_empty() {
        return Ok(());
    }
    let hub = match common::BizHub::get() {
        Ok(h) => h,
        Err(_) => return Ok(()),
    };
    for (_bot_user_id, app_db_id, app_id_str) in bots {
        let payload = serde_json::json!({
            "chat_id": chat_id,
        });
        let payload_str = serde_json::to_string(&payload).unwrap_or_default();
        let _ = hub.openapp.dispatch_event(
            ctx, app_db_id, &app_id_str, "im.group.removed_bot", &payload_str,
        ).await;
    }
    Ok(())
}

pub(crate) async fn chat_update(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<chat::UpdateChatRequest>(&packet.payload)?;
    debug!("chat update, req: {req:?}");
    let context = chat_cache_get(ctx, req.chat_id).await?;
    let mut resp = chat::UpdateChatResponse::default();
    let mut changed = false;
    {
        let mut c = context.write().await;

        if c.chat.r#type == entity::ChatType::ChatP2p as i16 {
            return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
        }

        let is_owner = c.chat.owner_id == brief.id;
        let is_admin = c.chat.admin_ids.contains(&brief.id);
        if !is_owner && !is_admin {
            return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
        }

        if !req.name.is_empty() && req.name != c.chat.name {
            c.chat.name = req.name.clone();
            changed = true;
        }
        if !req.description.is_empty() && req.description != c.chat.description {
            c.chat.description = req.description.clone();
            changed = true;
        }
        if req.join_mode > 0 && req.join_mode != c.chat.join_mode as i32 {
            c.chat.join_mode = req.join_mode as i16;
            changed = true;
        }

        let current_extra = crate::models::chats::ChatExtra::decode(
            c.chat.extra.as_slice(),
        )
        .unwrap_or_default();
        if !req.avatar.is_empty() && req.avatar != current_extra.avatar {
            let new_extra = crate::models::chats::ChatExtra {
                color: current_extra.color,
                avatar: req.avatar.clone(),
            };
            c.chat.extra = new_extra.encode_to_vec();
            changed = true;
        }

        if is_owner {
            if req.owner_id > 0 && req.owner_id != c.chat.owner_id {
                c.chat.owner_id = req.owner_id;
                changed = true;
            }
            if !req.admin_ids_add.is_empty() {
                for id in req.admin_ids_add.iter() {
                    if !c.chat.admin_ids.contains(id) {
                        c.chat.admin_ids.push(*id);
                    }
                }
                changed = true;
            }
            if !req.admin_ids_remove.is_empty() {
                let old_len = c.chat.admin_ids.len();
                c.chat.admin_ids.retain(|id| !req.admin_ids_remove.contains(id));
                if c.chat.admin_ids.len() != old_len {
                    changed = true;
                }
            }
        }

        if changed {
            c.chat.version = bump_chat_version(c.chat.version);
            let active = ActiveModel {
                id: ActiveValue::set(c.chat.id),
                name: ActiveValue::set(c.chat.name.clone()),
                description: ActiveValue::set(c.chat.description.clone()),
                extra: ActiveValue::set(c.chat.extra.clone()),
                owner_id: ActiveValue::set(c.chat.owner_id),
                admin_ids: ActiveValue::set(c.chat.admin_ids.clone()),
                cmv: ActiveValue::set(c.chat.cmv.clone()),
                version: ActiveValue::set(c.chat.version),
                join_mode: ActiveValue::set(c.chat.join_mode),
                ..Default::default()
            };
            ChatEntity::update(active)
                .exec(&ctx.db)
                .await
                .map_err(|e| common_error(&format!("update chat error: {e}")))?;
        }
    }

    {
        let c = context.read().await;
        let member_ids = c.cmv.ids();
        let mut entity = entity::Entity::default();
        entity.chats.insert(req.chat_id, c.get_entity());
        let _ = crate::feed::push_entity(ctx, &member_ids, entity).await;
        // chat 详情变更（名称/描述/权限等）属 chat 实体变更：走 pipeline 实体变更通道
        let e = resp.entities.get_or_insert_default();
        e.chats.insert(req.chat_id, c.get_entity());

        if changed {
            let _ = crate::message::push_entity_changed(
                ctx,
                &member_ids,
                &[req.chat_id],
                c.chat.version,
                entity::Operate::Update,
                entity::EntityType::Chat,
            )
            .await;
        }
    }

    debug!("chat update done");
    Ok((0, resp.encode_to_vec()))
}

pub(crate) async fn chat_get_by_ids(
    ctx: &AppContext,
    _brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<chat::GetChatByIdsRequest>(&packet.payload)?;
    let mut resp = chat::GetChatByIdsResponse::default();

    debug!("chat get by ids, req: {req:?}");
    let _ = cache_chat_load(ctx, &req.ids).await;
    let entity = resp.entities.get_or_insert_default();
    for id in req.ids.iter() {
        let chat = chat_cache_get(ctx, *id).await?;
        let chat = chat.read().await;
        entity.chats.insert(
            *id,
            ChatModel(chat.chat.clone()).into_entity(chat.cmv.ids()),
        );
    }
    debug!("chat get by ids, resp: {resp:?}");
    Ok((0, resp.encode_to_vec()))
}

pub(crate) async fn chat_quit(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<chat::QuitChatRequest>(&packet.payload)?;
    debug!("chat quit, req: {req:?}");
    let context = chat_cache_get(ctx, req.chat_id).await?;
    // let mut member_ids = Vec::new();
    let user_ids;
    let mut changed_version = 0i64;
    {
        let mut c = context.write().await;
        let mut owner_id = None;
        let mut admin_ids = None;

        if c.chat.r#type == entity::ChatType::ChatP2p as i16 || !c.cmv.contains_key(brief.id) {
            return Ok((ErrorCode::ErrorNoPermision as i32, vec![]));
        }
        if c.chat.admin_ids.contains(&brief.id) {
            c.chat.admin_ids.retain(|id| *id != brief.id);
            admin_ids = Some(c.chat.admin_ids.clone());
        }
        if c.chat.owner_id == brief.id {
            c.chat.owner_id = *c.chat.admin_ids.first().unwrap_or(&0);
            owner_id = Some(0);
        }
        let _ = c.cmv.remove(&vec![brief.id])?;
        if c.chat.owner_id == 0 {
            c.chat.owner_id = *c.cmv.ids().first().unwrap_or(&0);
            owner_id = Some(0);
        }
        if owner_id.is_some() {
            owner_id = Some(c.chat.owner_id);
        }
        assert_ne!(c.chat.owner_id, 0);

        c.chat.version = bump_chat_version(c.chat.version);
        changed_version = c.chat.version;
        let _ = ChatModel::update_cmv(
            &ctx.db,
            c.chat.id,
            changed_version,
            owner_id,
            admin_ids,
            &mut c.cmv,
        )
        .await;
        user_ids = c.cmv.ids();
    }

    let _ = crate::feed::update_feed_status(
        ctx,
        req.chat_id,
        &vec![brief.id],
        Some(EntityStatus::Deleted as i32),
    )
    .await;
    let _ = crate::feed::update_feed_status(ctx, req.chat_id, &user_ids, None).await;
    // 退群后剩余成员收到 chat 实体变更（成员列表更新）
    let _ = crate::message::push_entity_changed(
        ctx,
        &user_ids,
        &[req.chat_id],
        changed_version,
        entity::Operate::Update,
        entity::EntityType::Chat,
    )
    .await;
    debug!("chat quit");
    Ok((0, vec![]))
}

pub(crate) async fn chat_dismiss(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<chat::DismissChatRequest>(&packet.payload)?;
    debug!("chat dismiss, req: {req:?}");
    let resp = chat::DismissChatResponse::default();
    let context = chat_cache_get(ctx, req.chat_id).await?;
    {
        let mut c = context.write().await;

        if c.chat.owner_id != brief.id || c.chat.r#type == entity::ChatType::ChatP2p as i16 {
            return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
        }

        c.chat.version = bump_chat_version(c.chat.version);
        let user_ids = c.cmv.ids();
        // 解散群聊属 chat 实体变更：向所有成员推 Chat Delete（离线端回放后本地清除群）
        let _ = crate::message::push_entity_changed(
            ctx,
            &user_ids,
            &[req.chat_id],
            c.chat.version,
            entity::Operate::Delete,
            entity::EntityType::Chat,
        )
        .await;
        super::feed::update_feed_status(
            ctx,
            req.chat_id,
            &user_ids,
            Some(EntityStatus::DismissPending as i32),
        )
        .await?;
    }
    debug!("chat dismiss");
    Ok((0, vec![]))
}

// ─── Step 3: Announcement ───────────────────────────────────────────

pub(crate) async fn chat_set_announcement(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<chat::SetAnnouncementRequest>(&packet.payload)?;
    debug!("set announcement, req: {req:?}");
    let context = chat_cache_get(ctx, req.chat_id).await?;
    let mut resp = chat::SetAnnouncementResponse::default();

    let member_ids;
    {
        let c = context.read().await;
        if c.chat.r#type == entity::ChatType::ChatP2p as i16 {
            return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
        }
        let is_owner = c.chat.owner_id == brief.id;
        let is_admin = c.chat.admin_ids.contains(&brief.id);
        if !is_owner && !is_admin {
            return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
        }
        member_ids = c.cmv.ids();
    }

    let content = entity::AnnouncementContent {
        title: req.title.clone(),
        tpy: req.tpy,
        body: req.body.clone(),
    };
    let content_bytes = content.encode_to_vec();
    let now_ms = current_ms() as i64;
    let now = DateTimeWithTimeZone::from(
        chrono::DateTime::<chrono::Utc>::from_timestamp_millis(now_ms).unwrap(),
    );

    // 公告消息存 messages 表（id == chat_id）。messages 全部业务列为 NOT NULL，
    // 此处通过 ORM 全量填充后 upsert，避免原生 SQL 遗漏 NOT NULL 列。
    let active = messages::ActiveModel {
        id: ActiveValue::set(req.chat_id),
        chat_id: ActiveValue::set(req.chat_id),
        r#type: ActiveValue::set(entity::MessageType::Announcement as i16),
        from_id: ActiveValue::set(brief.id),
        content: ActiveValue::set(content_bytes.clone()),
        summary: ActiveValue::set(req.summary.clone()),
        pos: ActiveValue::set(0),
        badge: ActiveValue::set(0),
        status: ActiveValue::set(EntityStatus::Normal as i16),
        client_id: ActiveValue::set(0),
        at_user_ids: ActiveValue::set(vec![]),
        version: ActiveValue::set(now_ms),
        cmv_id: ActiveValue::set(0),
        cmv_count: ActiveValue::set(0),
        read_count: ActiveValue::set(0),
        read_states: ActiveValue::set(vec![]),
        reactions: ActiveValue::set(vec![]),
        extra: ActiveValue::set(vec![]),
        thread_root_id: ActiveValue::set(0),
        created_at: ActiveValue::set(now.clone()),
        updated_at: ActiveValue::set(now),
        ..Default::default()
    };
    let on_conflict = sea_orm::sea_query::OnConflict::column(messages::Column::Id)
        .update_columns([
            messages::Column::Type,
            messages::Column::FromId,
            messages::Column::Content,
            messages::Column::Summary,
            messages::Column::Status,
            messages::Column::Version,
            messages::Column::UpdatedAt,
        ])
        .to_owned();
    messages::Entity::insert(active)
        .on_conflict(on_conflict)
        .exec(&ctx.db)
        .await
        .map_err(|e| common_error(&format!("upsert announcement error: {e}")))?;

    let announcement_entity = entity::Message {
        tpy: entity::MessageType::Announcement as i32,
        id: req.chat_id,
        chat_id: req.chat_id,
        from_id: brief.id,
        create_time_ms: now_ms,
        update_time_ms: now_ms,
        content: content_bytes,
        summary: req.summary,
        ..Default::default()
    };

    {
        let e = resp.entities.get_or_insert_default();
        e.messages.insert(req.chat_id, announcement_entity.clone());
        let c = context.read().await;
        e.chats.insert(req.chat_id, c.get_entity());
    }

    // 公告走消息 pipeline（PushMessages）+ pipeline 持久化广播给所有成员
    let _ = push_announcement(ctx, &member_ids, req.chat_id).await;

    debug!("set announcement done");
    Ok((0, resp.encode_to_vec()))
}

// 公告消息批量广播（含离线 pipeline 持久化）：
// 公告载荷对全体成员一致（无已读/回执），一次编码、一次调用广播给所有成员，
// pipe=true 将包写入 pipelines 表，离线成员重连后经 PIPELINE_PULL_PACKET 回放。
pub(crate) async fn push_announcement(
    ctx: &AppContext,
    member_ids: &[i64],
    chat_id: i64,
) -> Result<()> {
    let Some(model) = messages::Entity::find_by_id(chat_id)
        .one(&ctx.db)
        .await
        .map_err(|e| common_error(&format!("push announcement error: {e}")))? else {
        debug!("push announcement skipped, message not found: {chat_id}");
        return Ok(());
    };
    let msg: entity::Message = messages::MessageModel(model).into();
    let mut push = message::PushMessages::default();
    push.entity
        .get_or_insert_default()
        .messages
        .insert(chat_id, msg);
    let hub = BizHub::get()?;
    hub.gateway
        .send_packet_to_user(
            ctx,
            member_ids,
            rid(),
            Command::PushMessages,
            push.encode_to_vec(),
            true,
        )
        .await?;
    Ok(())
}

pub(crate) async fn chat_delete_announcement(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<chat::DeleteAnnouncementRequest>(&packet.payload)?;
    debug!("delete announcement, req: {req:?}");
    let context = chat_cache_get(ctx, req.chat_id).await?;
    let resp = chat::DeleteAnnouncementResponse::default();

    let member_ids;
    {
        let c = context.read().await;
        if c.chat.r#type == entity::ChatType::ChatP2p as i16 {
            return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
        }
        let is_owner = c.chat.owner_id == brief.id;
        let is_admin = c.chat.admin_ids.contains(&brief.id);
        if !is_owner && !is_admin {
            return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
        }
        member_ids = c.cmv.ids();
    }

        // 软删除公告：置 status = Deleted，保留 row 以便消息 pipeline 广播删除状态
    let now = current_ms() as i64;
    messages::MessageModel::set_status(&ctx.db, req.chat_id, now, EntityStatus::Deleted as i16)
        .await
        .map_err(|e| common_error(&format!("delete announcement error: {e}")))?;

    let _ = push_announcement(ctx, &member_ids, req.chat_id).await;

    debug!("delete announcement done");
    Ok((0, resp.encode_to_vec()))
}

// ─── Step 7: Member list pagination ─────────────────────────────────

pub(crate) async fn get_members(
    ctx: &AppContext,
    _brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<chat::GetMembersRequest>(&packet.payload)?;
    debug!("get members, req: {req:?}");
    let context = chat_cache_get(ctx, req.chat_id).await?;
    let mut resp = chat::GetMembersResponse::default();

    let member_ids;
    {
        let c = context.read().await;
        member_ids = c.cmv.ids();
    }

    let page = if req.page <= 0 { 1 } else { req.page };
    let page_size = if req.page_size <= 0 { 50 } else { req.page_size.min(200) };
    let offset = ((page - 1) * page_size) as usize;

    let mut filtered: Vec<i64> = if req.keyword.is_empty() {
        member_ids
    } else {
        let biz = BizHub::get()?;
        let users = biz.user.get_user_by_ids(ctx, member_ids.clone()).await?;
        let kw = req.keyword.to_lowercase();
        member_ids.into_iter().filter(|id| {
            users.iter().any(|u| u.id == *id && u.name.to_lowercase().contains(&kw))
        }).collect()
    };

    let total = filtered.len() as i32;
    resp.total = total;
    let paged: Vec<i64> = filtered.drain(offset..).take(page_size as usize).collect();
    if paged.is_empty() {
        return Ok((0, resp.encode_to_vec()));
    }

    let biz = BizHub::get()?;
    let users = biz.user.get_user_by_ids(ctx, paged.clone()).await?;
    let c = context.read().await;
    for uid in paged {
        let role = if uid == c.chat.owner_id {
            2
        } else if c.chat.admin_ids.contains(&uid) {
            1
        } else {
            0
        };
        let user = users.iter().find(|u| u.id == uid);
        resp.members.push(chat::MemberItem {
            user_id: uid,
            name: user.map(|u| u.name.clone()).unwrap_or_default(),
            avatar: user.map(|u| u.avatar.clone()).unwrap_or_default(),
            role,
        });
    }

    debug!("get members done, total: {}", total);
    Ok((0, resp.encode_to_vec()))
}
