use loco_rs::{Error, Result, app::AppContext};
use prost::Message;
use std::collections::HashMap;
use std::sync::{Arc, LazyLock};
use tokio::sync::RwLock;
use tracing::debug;

use super::{ChatContext, VecBool};
use crate::models::{Cmv, chats::ChatModel, cmvs, feeds::FeedModel, messages};
use common::{BizHub, CacheLoader, CommonCache, EntityIds, EntityStatus, UserBrief, UserEntity};
use common::{BizUser, EntityType, common_error, pb_decode};
use proto::idl::{chat, entity, error::ErrorCode};

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
        msg.badge = c.chat.last_message_badge as i32 + 1;
        msg.cmv_id = c.cmv.id;
        msg.cmv_count = c.cmv.count;
        msg.read_states = VecBool::with_zeros(c.cmv.count as u64).chunks;
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

                return Ok((ErrorCode::Ok as i32, resp.encode_to_vec()));
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

        return Ok((ErrorCode::Ok as i32, resp.encode_to_vec()));
    } else {
        debug!("create chat error: {:?}", chat);
        return Err(common_error("create chat error"));
    }
}

pub(crate) async fn chat_add_chatters(
    ctx: &AppContext,
    _brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<chat::AddChatChatterRequest>(&packet.payload)?;
    debug!("chat add chatters, req: {req:?}");
    let context = chat_cache_get(ctx, req.chat_id).await?;
    let mut user_ids = None;
    {
        let mut c = context.write().await;

        if c.chat.r#type == entity::ChatType::ChatP2p as i16 {
            return Ok((ErrorCode::ErrorNoPermision as i32, vec![]));
        }

        if c.cmv.add(&req.ids)? {
            ChatModel::update_cmv(&ctx.db, c.chat.id, None, None, &mut c.cmv).await?;
            // send packet to users
            user_ids = Some(c.cmv.ids());

            let _ = FeedModel::create_by_chat(&ctx.db, &c.chat, &req.ids).await;
        }
    }
    if let Some(ids) = user_ids {
        let _ = crate::feed::update_feed_status(ctx, req.chat_id, &ids, None).await;
    }
    debug!("chat add chatters done");
    Ok((0, vec![]))
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
            let _ = ChatModel::update_cmv(&ctx.db, c.chat.id, None, admin_ids, &mut c.cmv).await?;
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
    if let Some(ids) = user_ids {
        let _ = crate::feed::update_feed_status(ctx, req.chat_id, &ids, None).await;
    }
    debug!("chat delete chatters done");
    Ok((0, vec![]))
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

        let _ = ChatModel::update_cmv(&ctx.db, c.chat.id, owner_id, admin_ids, &mut c.cmv).await;
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
        let c = context.write().await;

        if c.chat.owner_id != brief.id || c.chat.r#type == entity::ChatType::ChatP2p as i16 {
            return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
        }

        let user_ids = c.cmv.ids();
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
