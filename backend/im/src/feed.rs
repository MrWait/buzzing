use loco_rs::{Error, Result, app::AppContext};
use prost::Message as _;
use std::collections::HashMap;
use tracing::{debug, instrument, warn};

// use base::models::_entities::feeds;
use crate::models::feeds;
use common::{BizHub, EntityIds, EntityStatus, UserBrief, UserEntity, rid};
use common::{gen_i32, pb_decode, pb_default};
use proto::idl::{command::Command, entity, error::ErrorCode, feed};

pub(crate) async fn update_last_message(
    ctx: &AppContext,
    member_ids: &[i64],
    msg: &entity::Message,
) -> Result<()> {
    feeds::FeedModel::update_by_new_message(&ctx.db, member_ids, msg).await?;
    Ok(())
}

pub(crate) async fn push_feed_to_user_impl(
    ctx: &AppContext,
    user_id: i64,
    mut feeds: Vec<entity::Feed>,
) -> Result<()> {
    let gateway = BizHub::get()?.gateway.clone();
    let mut push = feed::PushFeedList::default();
    push.entity
        .get_or_insert_default()
        .feeds
        .extend(feeds.drain(..).map(|feed| (feed.id, feed)));
    let _ = gateway
        .send_packet_to_user(
            ctx,
            &vec![user_id],
            rid(),
            Command::PushFeedList,
            push.encode_to_vec(),
            false,
        )
        .await;

    Ok(())
}

#[instrument(skip(ctx, chat_ids), fields(sid=gen_i32()))]
pub(crate) async fn push_feed_by_ids(ctx: &AppContext, mut chat_ids: Vec<i64>) -> Result<()> {
    debug!("push feeds, ids: {chat_ids:?}");
    let mut entity_ids = EntityIds::default();
    let mut entity = entity::Entity::default();
    entity_ids.chat_ids.extend(chat_ids.drain(..));
    entity_ids.with_feed = true;
    entity_ids.with_message = true;
    entity_ids.broadcast = true;
    let mut user_entity: HashMap<i64, UserEntity> = HashMap::new();

    crate::fill_entity(ctx, &mut entity_ids, &mut entity, &mut user_entity).await?;
    for (user_id, ue) in user_entity.drain() {
        let mut push = feed::PushFeedList::default();
        push.entity = Some(ue.entity);
        debug!("push feed to user: {user_id}, push: {push:?}");
        let gateway = BizHub::get()?.gateway.clone();
        let _ = gateway
            .send_packet_to_user(
                ctx,
                &vec![user_id],
                rid(),
                Command::PushFeedList,
                push.encode_to_vec(),
                false,
            )
            .await;
    }
    Ok(())
}

pub(crate) async fn push_entity(
    ctx: &AppContext,
    user_ids: &[i64],
    entity: entity::Entity,
) -> Result<()> {
    let gateway = BizHub::get()?.gateway.clone();
    for chunk in user_ids.chunks(100) {
        let mut push = feed::PushFeedList::default();
        push.entity = Some(entity.clone());
        let _ = gateway
            .send_packet_to_user(
                ctx,
                chunk,
                rid(),
                Command::PushFeedList,
                push.encode_to_vec(),
                false,
            )
            .await;
    }
    Ok(())
}

pub(crate) async fn push_feed_to_user(
    ctx: &AppContext,
    mut feeds: Vec<feeds::Model>,
) -> Result<()> {
    for feed in feeds.drain(..) {
        let user_id = feed.user_id;
        let f = feeds::FeedModel(feed).into();
        let _ = push_feed_to_user_impl(ctx, user_id, vec![f]).await;
    }
    Ok(())
}

pub(crate) async fn feed_update_read_pos(
    ctx: &AppContext,
    chat_id: i64,
    user_id: i64,
    pos: i32,
    read_badge: i32,
) -> Result<()> {
    let feed = feeds::FeedModel::update_read_pos(&ctx.db, chat_id, user_id, pos, read_badge).await?;
    let Some(feed) = feed else {
        // 防回退未推进（pos 未前进或 feed 不存在），不广播
        return Ok(());
    };
    // 会话已读位置变更：向该用户所有在线设备广播 Feed 实体子集（不改变排序）
    push_feed_read_status(ctx, user_id, &feed).await
}

/// 向单个用户广播会话已读位置子集推送 `PUSH_FEED_READ_STATUS`（见 data_sync §3.1）
async fn push_feed_read_status(ctx: &AppContext, user_id: i64, feed: &feeds::Model) -> Result<()> {
    let gateway = BizHub::get()?.gateway.clone();
    let push = feed::PushFeedReadStatus {
        feed_id: feed.entity_id,
        chat_id: feed.entity_id,
        read_pos: feed.read_pos as i64,
        read_badge: feed.read_badge as i64,
        update_time_ms: feed.update_ms,
    };
    let _ = gateway
        .send_packet_to_user(
            ctx,
            &vec![user_id],
            rid(),
            Command::PushFeedReadStatus,
            push.encode_to_vec(),
            false,
        )
        .await;
    Ok(())
}

pub(crate) async fn update_feed_status(
    ctx: &AppContext,
    chat_id: i64,
    user_ids: &[i64],
    status: Option<i32>,
) -> Result<()> {
    let feeds = feeds::FeedModel::feed_set_status(&ctx.db, chat_id, user_ids, status).await?;
    let _ = push_feed_to_user(ctx, feeds).await;

    Ok(())
}

pub(crate) async fn feed_get_list(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<feed::PullFeedListRequest>(&packet.payload)?;
    debug!("get feed cards, req: {:?}", req);
    let mut resp = feed::PullFeedListResponse::default();

    let mut entity = entity::Entity::default();

    let ok = {
        feeds::FeedModel::feed_get_list(
            &ctx.db,
            brief.id,
            req.cursor,
            req.prev_cursor,
            req.count,
            &mut entity,
        )
        .await
    };
    match ok {
        Ok(_) => {
            let mut user_entity: HashMap<i64, UserEntity> = HashMap::new();
            let mut entity_ids = EntityIds::default();
            resp.has_more = entity.feeds.len() as i32 == req.count;

            resp.cursor = *entity.feeds.keys().max().unwrap_or(&req.cursor);
            entity_ids.chat_ids.extend(entity.feeds.keys());
            entity_ids
                .message_ids
                .extend(entity.feeds.values().map(|f| f.refer_id));
            entity_ids.with_message = true;
            user_entity.insert(
                brief.id,
                UserEntity {
                    user_id: brief.id,
                    entity_ids: entity_ids.clone(),
                    entity,
                },
            );

            let mut entity = entity::Entity::default();
            let _ = super::fill_entity(ctx, &mut entity_ids, &mut entity, &mut user_entity).await;
            resp.entity = user_entity.remove(&brief.id).map(|ue| ue.entity);
            debug!("get feed resp: {:?}", resp);
        }
        Err(err) => {
            warn!("get feed list error: {:?}", err);
        }
    }

    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

pub(crate) async fn feed_remove(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<feed::RemoveFeedRequest>(&packet.payload)?;
    let resp = feed::RemoveFeedResponse::default();
    debug!("feed remove: {req:?}");
    let mut ids = EntityIds::default();
    let mut entity = entity::Entity::default();
    ids.feed_ids.insert(req.id);
    feeds::FeedModel::feed_get_by_ids_for_user(&ctx.db, brief.id, &ids, &mut entity).await?;
    if let Some(feed) = entity.feeds.get(&req.id) {
        let feeds = vec![feed.clone()];
        let new_status = match feed.status {
            val if val == EntityStatus::Normal as i32 => EntityStatus::Invisible as i32,
            val if val == EntityStatus::DeletePending as i32 => EntityStatus::Deleted as i32,
            val if val == EntityStatus::DismissPending as i32 => EntityStatus::Deleted as i32,
            _ => feed.status,
        };

        if new_status != feed.status {
            let db_feeds = feeds::FeedModel::feed_set_status(
                &ctx.db,
                req.id,
                &vec![brief.id],
                Some(new_status),
            )
            .await?;
            let _ = push_feed_to_user(ctx, db_feeds).await;
        } else {
            let _ = push_feed_to_user_impl(ctx, brief.id, feeds).await;
        }
    }
    debug!("feed remove: {resp:?}");
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

pub(crate) async fn feed_active(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<feed::ActiveFeedRequest>(&packet.payload)?;
    let resp = feed::ActiveFeedResponse::default();
    debug!("feed active: {req:?}");
    let mut ids = EntityIds::default();
    let mut entity = entity::Entity::default();
    ids.feed_ids.insert(req.id);
    feeds::FeedModel::feed_get_by_ids_for_user(&ctx.db, brief.id, &ids, &mut entity).await?;
    if let Some(feed) = entity.feeds.get(&req.id) {
        let feeds = vec![feed.clone()];
        let new_status = match feed.status {
            val if val == EntityStatus::Invisible as i32 => EntityStatus::Normal as i32,
            _ => feed.status,
        };

        if new_status != feed.status {
            let db_feeds = feeds::FeedModel::feed_set_status(
                &ctx.db,
                req.id,
                &vec![brief.id],
                Some(new_status),
            )
            .await?;
            let _ = push_feed_to_user(ctx, db_feeds).await;
        } else {
            let _ = push_feed_to_user_impl(ctx, brief.id, feeds).await;
        }
    }
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

pub(crate) async fn feed_set_top(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<feed::SetFeedTopRequest>(&packet.payload)?;
    let resp = feed::SetFeedTopResponse::default();
    debug!("feed set top: {req:?}");
    let mut ids = EntityIds::default();
    let mut entity = entity::Entity::default();
    ids.feed_ids.insert(req.id);
    feeds::FeedModel::feed_get_by_ids_for_user(&ctx.db, brief.id, &ids, &mut entity).await?;
    if let Some(feed) = entity.feeds.get(&req.id) {
        let is_top = !(feed.is_top == 0);
        if is_top != req.top {
            if let Ok(setting) = super::setting::top_list_add(ctx, brief.id, req.id).await {
                let db_feeds = feeds::FeedModel::feed_set_top(
                    &ctx.db,
                    req.id,
                    &vec![brief.id],
                    req.top.into(),
                )
                .await?;
                if let Ok(hub) = BizHub::get() {
                    let _ = hub
                        .gateway
                        .send_packet_to_user(
                            ctx,
                            &vec![brief.id],
                            rid(),
                            Command::PushSetting,
                            setting.encode_to_vec(),
                            false,
                        )
                        .await;
                }
                let _ = push_feed_to_user(ctx, db_feeds).await;
            }
        } else {
            let _ = push_feed_to_user_impl(ctx, brief.id, vec![feed.clone()]).await;
        }
    }

    debug!("feed set top: {resp:?}");
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

pub(crate) async fn feed_set_mute(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<feed::SetFeedMuteRequest>(&packet.payload)?;
    let resp = feed::SetFeedMuteResponse::default();
    debug!("feed set mute: {req:?}");
    let mut ids = EntityIds::default();
    let mut entity = entity::Entity::default();
    ids.feed_ids.insert(req.id);
    feeds::FeedModel::feed_get_by_ids_for_user(&ctx.db, brief.id, &ids, &mut entity).await?;
    if let Some(feed) = entity.feeds.get(&req.id) {
        let is_mute = !(feed.is_mute == 0);
        if is_mute != req.mute {
            let db_feeds =
                feeds::FeedModel::feed_set_mute(&ctx.db, req.id, &vec![brief.id], req.mute.into())
                    .await?;

            let _ = push_feed_to_user(ctx, db_feeds).await;
        } else {
            let _ = push_feed_to_user_impl(ctx, brief.id, vec![feed.clone()]).await;
        }
    }
    debug!("feed set mute: {resp:?}");
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}
