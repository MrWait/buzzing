use loco_rs::{model::ModelResult, prelude::*};
use sea_orm::{Iterable, QueryOrder, entity::prelude::*};
use sea_query::{OnConflict, extension::postgres::PgExpr};
use std::collections::HashSet;
use tracing::debug;

pub use base::models::_entities::feeds::{self, ActiveModel, Column, Entity, Model};
use common::{EntityIds, EntityStatus, EntityType, time::current_ms};
use proto::idl::entity;

pub type Feeds = Entity;
#[derive(Debug)]
pub struct FeedModel(pub Model);

impl FeedModel {
    pub async fn create_feed(
        db: &DatabaseConnection,
        entity_id: i64,
        typ: EntityType,
        member_ids: &[i64],
    ) -> ModelResult<()> {
        let txn = db.begin().await?;

        let feeds = Feeds::find()
            .filter(
                model::query::condition()
                    .eq(Column::EntityId, entity_id)
                    .is_in(Column::UserId, member_ids.iter().map(|id| *id))
                    .build(),
            )
            .all(&txn)
            .await?;
        debug!("get feed in db: {:?}", feeds);
        let mut member_ids = member_ids.iter().cloned().collect::<HashSet<i64>>();
        feeds.iter().for_each(|feed| {
            member_ids.remove(&feed.user_id);
        });
        if member_ids.is_empty() {
            return Ok(());
        }

        let feeds: Vec<_> = member_ids
            .iter()
            .map(|id| ActiveModel {
                entity_id: ActiveValue::set(entity_id),
                entity_type: ActiveValue::set(typ as i32),
                user_id: ActiveValue::set(*id),
                refer_id: ActiveValue::set(0),
                refer_pos: ActiveValue::set(0),
                refer_badge: ActiveValue::set(0),
                read_pos: ActiveValue::set(0),
                read_badge: ActiveValue::set(0),
                update_ms: ActiveValue::set(current_ms() as i64),
                rank_time_ms: ActiveValue::set(current_ms() as i64),
                version: ActiveValue::set(0),
                status: ActiveValue::set(entity::EntityStatus::Normal as i32),
                is_top: ActiveValue::set(0),
                is_mute: ActiveValue::set(0),
                extra: ActiveValue::set(vec![]),
                ..Default::default()
            })
            .collect();
        debug!("insert new feeds: {:?}", feeds);
        Feeds::insert_many(feeds).exec(&txn).await?;
        txn.commit().await?;

        // Feeds::update_many()
        //     .col_expr(
        //         Column::IsMute,
        //         Expr::col(Column::IsMute).sub("1"),
        //     )
        //     .exec(db)
        //     .await?;

        Ok(())
    }

    pub async fn create_by_chat(
        db: &DatabaseConnection,
        chat: &super::chats::Model,
        user_ids: &[i64],
    ) -> ModelResult<()> {
        let now = current_ms() as i64;
        let feeds: Vec<_> = user_ids
            .iter()
            .map(|id| ActiveModel {
                entity_id: ActiveValue::set(chat.id),
                entity_type: ActiveValue::set(EntityType::Chat as i32),
                user_id: ActiveValue::set(*id),
                refer_id: ActiveValue::set(chat.last_message_id),
                refer_pos: ActiveValue::set(chat.last_message_pos as i32),
                refer_badge: ActiveValue::set(chat.last_message_badge as i32),
                read_pos: ActiveValue::set(chat.last_message_pos as i32),
                read_badge: ActiveValue::set(chat.last_message_badge as i32),
                update_ms: ActiveValue::set(now),
                rank_time_ms: ActiveValue::set(now),
                version: ActiveValue::set(0),
                status: ActiveValue::set(EntityStatus::Normal as i32),
                is_top: ActiveValue::set(0),
                is_mute: ActiveValue::set(0),
                extra: ActiveValue::set(vec![]),
                ..Default::default()
            })
            .collect();

        let pk = <Entity as EntityTrait>::PrimaryKey::iter();
        Entity::insert_many(feeds)
            .on_conflict(
                OnConflict::columns(pk.clone())
                    .update_columns([
                        Column::ReferId,
                        Column::ReferPos,
                        Column::ReferBadge,
                        Column::ReadBadge,
                        Column::ReadPos,
                        Column::UpdateMs,
                        Column::RankTimeMs,
                        Column::Status,
                        Column::IsTop,
                        Column::IsMute,
                    ])
                    .to_owned(),
            )
            .exec(db)
            .await?;
        Ok(())
    }

    pub async fn feed_set_status(
        db: &DatabaseConnection,
        id: i64,
        members: &[i64],
        status: Option<i32>,
    ) -> ModelResult<Vec<Model>> {
        let now = current_ms() as i64;
        let feed = ActiveModel {
            update_ms: ActiveValue::set(now),
            status: status
                .and_then(|s| Some(ActiveValue::set(s)))
                .unwrap_or(ActiveValue::NotSet),
            ..Default::default()
        };
        let _ = Feeds::update_many()
            .set(feed)
            .filter(
                model::query::condition()
                    .eq(Column::EntityId, id)
                    .is_in(Column::UserId, members.to_vec())
                    .build(),
            )
            .exec(db)
            .await?;
        let feeds = Feeds::find()
            .filter(
                model::query::condition()
                    .eq(Column::EntityId, id)
                    .is_in(Column::UserId, members.to_vec())
                    .build(),
            )
            .all(db)
            .await?;
        Ok(feeds)
    }

    pub async fn feed_set_top(
        db: &DatabaseConnection,
        id: i64,
        members: &[i64],
        top: i32,
    ) -> ModelResult<Vec<Model>> {
        let now = current_ms() as i64;
        let feed = ActiveModel {
            update_ms: ActiveValue::set(now),
            is_top: ActiveValue::set(top),
            ..Default::default()
        };
        let _ = Feeds::update_many()
            .set(feed)
            .filter(
                model::query::condition()
                    .eq(Column::EntityId, id)
                    .is_in(Column::UserId, members.to_vec())
                    .build(),
            )
            .exec(db)
            .await?;
        let feeds = Feeds::find()
            .filter(
                model::query::condition()
                    .eq(Column::EntityId, id)
                    .is_in(Column::UserId, members.to_vec())
                    .build(),
            )
            .all(db)
            .await?;
        Ok(feeds)
    }

    pub async fn feed_set_mute(
        db: &DatabaseConnection,
        id: i64,
        members: &[i64],
        mute: i32,
    ) -> ModelResult<Vec<Model>> {
        let now = current_ms() as i64;
        let feed = ActiveModel {
            update_ms: ActiveValue::set(now),
            is_mute: ActiveValue::set(mute),
            ..Default::default()
        };
        let _ = Feeds::update_many()
            .set(feed)
            .filter(
                model::query::condition()
                    .eq(Column::EntityId, id)
                    .is_in(Column::UserId, members.to_vec())
                    .build(),
            )
            .exec(db)
            .await?;
        let feeds = Feeds::find()
            .filter(
                model::query::condition()
                    .eq(Column::EntityId, id)
                    .is_in(Column::UserId, members.to_vec())
                    .build(),
            )
            .all(db)
            .await?;
        Ok(feeds)
    }

    pub async fn find_by_user_id() -> ModelResult<()> {
        Err(ModelError::EntityNotFound)
    }

    pub async fn update_by_chat_id() -> ModelResult<()> {
        Err(ModelError::EntityNotFound)
    }

    pub async fn feed_get_list(
        db: &DatabaseConnection,
        user_id: i64,
        max: i64,
        min: i64,
        count: i32,
        entity: &mut entity::Entity,
    ) -> Result<()> {
        debug!("feed get list, user_id: {} {} {}", user_id, min, max);
        let mut feeds = Feeds::find()
            .filter(
                model::query::condition()
                    .eq(Column::UserId, user_id)
                    .between(Column::UpdateMs, min, max)
                    .build(),
            )
            .order_by_desc(Column::UpdateMs)
            .paginate(db, count as u64);
        if let Some(mut feed) = feeds.fetch_and_next().await? {
            debug!("load feed from db: {:?}, {}", feed, user_id);
            entity
                .feeds
                .extend(feed.drain(..).map(|f| (f.entity_id, Self(f).into())));
        }
        debug!("feed get list finish");
        Ok(())
    }

    pub async fn feed_get_by_ids(
        db: &DatabaseConnection,
        ids: Vec<i64>,
        cursor: i64,
        count: i32,
    ) -> Result<Vec<Model>> {
        debug!("feed get by ids: {ids:?}, cursor: {cursor}, count: {count}");
        let mut query = Feeds::find()
            .filter(
                model::query::condition()
                    .is_in(Column::EntityId, ids)
                    .gt(Column::UserId, cursor)
                    .build(),
            )
            .order_by_asc(Column::UserId)
            .paginate(db, count as u64);
        if let Some(feeds) = query.fetch_and_next().await? {
            debug!("fetch feed from db, count: {}", feeds.len());
            return Ok(feeds);
        } else {
            return Ok(vec![]);
        }
    }

    pub async fn feed_get_by_ids_for_user(
        db: &DatabaseConnection,
        user_id: i64,
        entity_ids: &EntityIds,
        entity: &mut entity::Entity,
    ) -> Result<()> {
        debug!(
            "feed get by ids, user_id: {}, ids: {:?}",
            user_id, entity_ids.feed_ids
        );
        let ids: Vec<_> = entity_ids.feed_ids.iter().copied().collect();
        let feeds = Feeds::find()
            .filter(
                model::query::condition()
                    .eq(Column::UserId, user_id)
                    .is_in(Column::EntityId, ids)
                    .build(),
            )
            .all(db)
            .await;
        feeds.and_then(|mut feeds| {
            entity
                .feeds
                .extend(feeds.drain(..).map(|f| (f.entity_id, Self(f).into())));
            Ok(())
        })?;
        Ok(())
    }

    pub async fn feed_get_by_ids_for_users(
        db: &DatabaseConnection,
        user_ids: Vec<i64>,
        entity_ids: &EntityIds,
    ) -> Result<Vec<Model>> {
        debug!(
            "feed get by ids, user_ids: {:?}, ids: {:?}",
            user_ids, entity_ids.feed_ids
        );
        let ids: Vec<_> = entity_ids.feed_ids.iter().copied().collect();
        let feeds = Feeds::find()
            .filter(
                model::query::condition()
                    .is_in(Column::UserId, user_ids)
                    .is_in(Column::EntityId, ids)
                    .build(),
            )
            .all(db)
            .await?;
        Ok(feeds)
    }

    pub async fn update_read_pos(
        db: &DatabaseConnection,
        chat_id: i64,
        user_id: i64,
        pos: i32,
    ) -> ModelResult<Vec<Model>> {
        let now = current_ms() as i64;

        let feed = Feeds::find()
            .filter(
                model::query::condition()
                    .eq(Column::EntityId, chat_id)
                    .eq(Column::UserId, user_id)
                    .build(),
            )
            .one(db)
            .await?;

        let Some(db_feed) = feed else {
            return Ok(vec![]);
        };

        let read_badge = if pos >= db_feed.refer_pos {
            db_feed.refer_badge
        } else {
            db_feed.read_badge
        };

        let model = ActiveModel {
            read_pos: ActiveValue::set(pos),
            read_badge: ActiveValue::set(read_badge),
            update_ms: ActiveValue::set(now),
            ..Default::default()
        };

        Feeds::update_many()
            .set(model)
            .filter(
                model::query::condition()
                    .eq(Column::EntityId, chat_id)
                    .eq(Column::UserId, user_id)
                    .build(),
            )
            .exec(db)
            .await?;

        let feeds = Feeds::find()
            .filter(
                model::query::condition()
                    .eq(Column::EntityId, chat_id)
                    .eq(Column::UserId, user_id)
                    .build(),
            )
            .all(db)
            .await?;
        Ok(feeds)
    }

    pub async fn update_by_new_message(
        db: &DatabaseConnection,
        member_ids: &[i64],
        msg: &entity::Message,
    ) -> ModelResult<()> {
        let feed = ActiveModel {
            refer_badge: ActiveValue::set(msg.badge_count),
            refer_id: ActiveValue::set(msg.id),
            refer_pos: ActiveValue::set(msg.pos),
            rank_time_ms: ActiveValue::set(msg.create_time_ms),
            update_ms: ActiveValue::set(msg.create_time_ms),
            ..Default::default()
        };
        Feeds::update_many()
            .set(feed)
            .filter(
                model::query::condition()
                    .eq(Column::EntityId, msg.chat_id)
                    .is_in(Column::UserId, member_ids.to_vec())
                    .build(),
            )
            .exec(db)
            .await?;
        Ok(())
    }
}

impl Into<entity::Feed> for FeedModel {
    fn into(self) -> entity::Feed {
        entity::Feed {
            id: self.0.entity_id,
            r#type: self.0.entity_type,
            refer_id: self.0.refer_id,
            refer_pos: self.0.refer_pos,
            refer_badge: self.0.refer_badge,
            read_pos: self.0.read_pos,
            read_badge: self.0.read_badge,
            update_time_ms: self.0.update_ms,
            rank_time_ms: self.0.rank_time_ms,
            version: self.0.version,
            badge: 0,
            is_top: self.0.is_top,
            is_mute: self.0.is_mute,
            status: self.0.status,
        }
    }
}

impl From<entity::Feed> for FeedModel {
    fn from(value: entity::Feed) -> Self {
        Self(Model {
            created_at: DateTimeWithTimeZone::default(),
            updated_at: DateTimeWithTimeZone::default(),
            entity_id: value.id,
            entity_type: value.r#type,
            user_id: 0,
            refer_id: value.refer_id,
            refer_badge: value.refer_badge,
            refer_pos: value.refer_pos,
            read_pos: value.read_pos,
            read_badge: value.read_badge,
            update_ms: value.update_time_ms,
            rank_time_ms: value.rank_time_ms,
            version: value.version,
            is_top: value.is_top,
            is_mute: value.is_mute,
            status: value.status,
            extra: vec![],
        })
    }
}
