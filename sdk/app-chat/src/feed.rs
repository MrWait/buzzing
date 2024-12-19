use anyhow::Result;
use prost::Message as _;
use std::ops::DerefMut;
use std::sync::atomic::Ordering;
use tracing::{debug, instrument, warn};

use base_db::meta::MetaTable;
use base_util::{gen_i32, thread_id};
use proto::idl::{command::Command, entity, error::ErrorCode, feed};
use proto::EntityIds;
use service::network::common_request;

use crate::{database, AppChat};

impl AppChat {
    #[instrument(skip(self), fields(sid=gen_i32(), tid=thread_id()))]
    pub(crate) async fn feed_sync(&self) {
        if self.feed_sync_flag.load(Ordering::Relaxed) {
            debug!("feed was syncing");
            self.feed_reentrant_flag.store(true, Ordering::Relaxed);
            return;
        }
        self.feed_sync_flag.store(true, Ordering::Relaxed);
        let now = std::time::Instant::now();

        debug!("start sync feed");
        loop {
            if let Err(err) = self.feed_sync_impl().await {
                warn!("feed sync error: {:?}", err);
                tokio::time::sleep(std::time::Duration::from_secs(5)).await;
                continue;
            }
            if !self.feed_reentrant_flag.load(Ordering::Relaxed) {
                break;
            }
            self.feed_reentrant_flag.store(false, Ordering::Relaxed);
        }

        debug!("feed sync finish, cost: {:?}", now.elapsed().as_millis());
        self.feed_sync_flag.store(false, Ordering::Relaxed);
    }

    async fn feed_sync_impl(&self) -> Result<()> {
        let prev_cursor;
        {
            let mut conn = self.db.inner()?;
            let cursor = MetaTable::meta(conn.deref_mut()).get(crate::constant::FLAG_FEED_CURSOR);
            prev_cursor = cursor
                .and_then(|cursor| Ok(cursor.parse::<i64>()))
                .unwrap_or(Ok(0))
                .unwrap_or(0);
        }

        let mut cursor = std::i64::MAX;
        let mut max_cursor = 0;
        loop {
            let mut req = feed::PullFeedListRequest::default();
            req.cursor = cursor;
            req.count = 50;
            req.prev_cursor = prev_cursor;
            debug!("pull feed req: {:?}", req);
            let mut ack = crate::api::feed_get_list(&req).await?;
            debug!("pull feed list ack: {:?}", ack);

            let entity = &ack.entity.get_or_insert_default();

            self.save_entity(entity)?;
            let mut ids = Vec::new();
            entity.feeds.iter().for_each(|(id, feed)| {
                ids.push(*id);
                max_cursor = std::cmp::max(max_cursor, feed.update_time_ms);
            });

            let _ = self.feed_push_by_ids(&ids);

            if !ack.has_more {
                break;
            }
            cursor = ack.cursor;
        }

        debug!("feed sync finish, max cursor: {:?}", max_cursor);
        {
            let conn = self.db.inner()?;
            let _ = MetaTable::meta(&conn)
                .insert(crate::constant::FLAG_FEED_CURSOR, &max_cursor.to_string());
        }

        Ok(())
    }

    pub(crate) fn feed_fill(&self, ids: &mut EntityIds, entity: &mut entity::Entity) -> Result<()> {
        {
            let conn = self.db.inner()?;
            let feed_ids: Vec<_> = ids.feed_ids.iter().copied().collect();
            database::feed::feed_get_by_ids(&conn, &feed_ids, entity)?;
        }
        ids.feed_ids.retain(|id| !entity.feeds.contains_key(id));
        debug!("feed fill: {:?}", entity);
        Ok(())
    }

    pub(crate) fn feed_push_by_ids(&self, ids: &[i64]) -> Result<()> {
        let mut req = feed::PushFeedList::default();
        let mut entity_ids = EntityIds::default();
        entity_ids.feed_ids.extend(ids.iter());
        self.fill_entity(&mut entity_ids, &mut req.entity.get_or_insert_default())?;
        debug!("push feed to client: {:?}", req);
        let _ = service::ffi::ffi_push(Command::PushFeedList as i32, req.encode_to_vec());
        Ok(())
    }

    pub(crate) fn feed_update_by_messages(&self, entity: &mut entity::Entity) -> Result<()> {
        let mut need_push = false;
        {
            let mut conn = self.db.inner()?;
            let feed_ids: Vec<_> = entity.messages.values().map(|m| m.chat_id).collect();
            let _ = database::feed::feed_get_by_ids(&conn, &feed_ids, entity)?;
            let mut updated = entity::Entity::default();
            for msg in entity.messages.values() {
                if let Some(conv) = entity.feeds.get_mut(&msg.chat_id) {
                    if conv.refer_pos < msg.pos {
                        conv.refer_pos = msg.pos;
                        conv.refer_id = msg.id;
                        conv.refer_badge = msg.badge_count;
                        conv.badge = conv.refer_badge - conv.read_badge;
                        conv.rank_time_ms = msg.create_time_ms;

                        updated.feeds.insert(conv.id, conv.clone());

                        need_push = true;
                    }
                }
            }
            if !updated.feeds.is_empty() {
                database::feed::feed_batch_save(conn.deref_mut(), &updated)?;
            }
        }

        let mut entity_id = EntityIds::default();
        self.fill_entity(&mut entity_id, entity)?;
        if need_push {
            let mut req = feed::PushFeedList::default();
            req.entity = Some(entity.clone());
            debug!("push feed to client: {:?}", req);
            let _ = service::ffi::ffi_push(Command::PushFeedList as i32, req.encode_to_vec());
        }

        Ok(())
    }

    pub(crate) fn feed_get_list(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = feed::PullFeedListRequest::decode(params)?;
        let mut resp = feed::PullFeedListResponse::default();
        debug!("feed get list, req: {req:?}");
        {
            let conn = self.db.inner()?;
            database::feed::feed_get_by_cursor(
                &conn,
                req.cursor,
                req.count,
                &mut resp.entity.get_or_insert_default(),
            )?;
        }

        let mut entity_ids = EntityIds::default();
        let _ = self.fill_entity(&mut entity_ids, &mut resp.entity.get_or_insert_default());
        debug!("get feed list, resp: {:?}", resp);
        Ok((ErrorCode::Ok as i32, resp.encode_to_vec()))
    }

    pub async fn feed_remove(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = feed::RemoveFeedRequest::decode(params)?;
        debug!("feed remove, req: {req:?}");
        let resp: feed::RemoveFeedResponse =
            common_request(Command::FeedRemove as i32, req.encode_to_vec(), None).await?;
        Ok((0, resp.encode_to_vec()))
    }

    pub async fn feed_active(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = feed::ActiveFeedRequest::decode(params)?;
        debug!("feed active, req: {req:?}");
        let resp: feed::ActiveFeedResponse =
            common_request(Command::FeedActive as i32, req.encode_to_vec(), None).await?;
        Ok((0, resp.encode_to_vec()))
    }

    pub async fn feed_set_top(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = feed::SetFeedTopRequest::decode(params)?;
        debug!("feed set top, req: {req:?}");
        let resp: feed::SetFeedTopResponse =
            common_request(Command::FeedSetTop as i32, req.encode_to_vec(), None).await?;

        Ok((0, resp.encode_to_vec()))
    }

    pub async fn feed_set_mute(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = feed::SetFeedMuteRequest::decode(params)?;
        debug!("feed set mute, req: {req:?}");
        let resp: feed::SetFeedMuteResponse =
            common_request(Command::FeedSetMute as i32, req.encode_to_vec(), None).await?;

        Ok((0, resp.encode_to_vec()))
    }

    pub async fn feed_get_top_list(&self, _params: &[u8]) -> Result<(i32, Vec<u8>)> {
        Ok((0, vec![]))
    }

    pub async fn feed_get_by_ids(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = feed::PullFeedByIdsRequest::decode(params)?;
        let mut resp = feed::PullFeedByIdsResponse::default();
        debug!("feed get by ids: {req:?}");

        let entity = resp.entity.get_or_insert_default();
        {
            let conn = self.db.inner()?;
            database::feed::feed_get_by_ids(&conn, &req.ids, entity)?;
        }

        if !entity.feeds.is_empty() {
            let mut ids = EntityIds::default();
            let _ = self.fill_entity(&mut ids, entity);
        }

        debug!("feed get by ids, resp: {resp:?}");
        Ok((0, resp.encode_to_vec()))
    }

    pub fn handle_push_feed_list(&self, params: &[u8]) -> Result<()> {
        let mut req = feed::PushFeedList::decode(params)?;
        debug!("handle push feed list: {req:?}");
        if let Some(entity) = req.entity {
            let ids: Vec<i64> = entity.feeds.keys().copied().collect();
            self.save_entity(&entity)?;
            let _ = self.feed_push_by_ids(&ids);
        }
        Ok(())
    }
}
