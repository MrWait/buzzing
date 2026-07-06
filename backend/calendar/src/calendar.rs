use common::time::current_ms;
use loco_rs::{Error, Result, app::AppContext};
use prost::Message;
use proto::idl::pipeline;
use std::collections::HashMap;
use std::sync::{Arc, LazyLock};
use tokio::sync::RwLock;
use tracing::{debug, warn};

use crate::models::calendars::{self, CalendarModel};
use crate::models::user2calendars::{self, User2CalendarModel};
use common::{
    BizHub, CacheLoader, CommonCache, Operate, PresetColor, UserBrief, id_gen, pb_decode,
};
use proto::idl::{calendar, command::Command, entity, error::ErrorCode};

pub struct CalendarContext {
    pub calendar: calendars::Model,
    pub subscribers: entity::CalendarSubscribers,
}
impl TryFrom<calendars::Model> for CalendarContext {
    type Error = Error;
    fn try_from(mut calendar: calendars::Model) -> Result<Self> {
        let subscribers = serde_json::from_value::<HashMap<i64, entity::calendar::Subscriber>>(
            calendar.subscriber.take(),
        )?;
        Ok(CalendarContext {
            calendar,
            subscribers: entity::CalendarSubscribers { subscribers },
        })
    }
}
impl CalendarContext {
    pub fn user_ids(&self) -> Vec<i64> {
        self.subscribers.subscribers.keys().copied().collect()
    }

    pub fn entity(&self) -> entity::Calendar {
        let mut calendar: entity::Calendar = CalendarModel(self.calendar.clone()).into();
        calendar.subscribers = Some(self.subscribers.clone());
        calendar
    }
}

type CacheCalendar = Arc<RwLock<CalendarContext>>;
pub static CACHE_CALENDAR: LazyLock<CommonCache<i64, CacheCalendar>> =
    LazyLock::new(|| CommonCache::new(10000, Arc::new(Box::new(CalendarLoader))));

struct CalendarLoader;
#[async_trait::async_trait]
impl CacheLoader<i64, CacheCalendar> for CalendarLoader {
    async fn load(&self, ctx: &AppContext, ids: &[i64]) -> Result<HashMap<i64, CacheCalendar>> {
        let mut result = HashMap::new();
        let mut calendars = CalendarModel::get_by_ids(&ctx.db, ids.to_vec()).await?;
        for cal in calendars.drain(..) {
            let id = cal.id;
            if let Ok(cal) = cal.try_into() {
                result.insert(id, Arc::new(RwLock::new(cal)));
            }
        }
        Ok(result)
    }

    async fn get(&self, ctx: &AppContext, id: &i64) -> Result<CacheCalendar> {
        let calendar = CalendarModel::get_by_id(&ctx.db, *id).await?;
        debug!("cache get calendar, model: {calendar:?}");
        let calendar = calendar.ok_or(Error::NotFound)?;
        Ok(Arc::new(RwLock::new(calendar.try_into()?)))
    }
}

async fn push_calendar_to_users(
    ctx: &AppContext,
    user_ids: &[i64],
    calendar: entity::Calendar,
) -> Result<()> {
    let biz = BizHub::get()?;
    let rid = id_gen(None);
    let push = calendar::CalendarPushUpdateRequest {
        calendar: Some(calendar),
    };
    let _ = biz
        .gateway
        .send_packet_to_user(
            ctx,
            user_ids,
            rid,
            Command::CalendarPushUpdate,
            push.encode_to_vec(),
            true,
        )
        .await?;
    Ok(())
}

pub(crate) async fn create_user_default(
    ctx: &AppContext,
    user_id: i64,
    tenant_id: i64,
    user_name: &str,
) -> Result<calendars::Model> {
    let now = current_ms() as i64;
    let mut subscribers = HashMap::new();
    subscribers.insert(
        user_id,
        entity::calendar::Subscriber {
            id: user_id,
            subscribe_time: now,
            role: entity::CalendarRole::RoleOwner as i32,
            color: PresetColor::rand().into(),
        },
    );
    let subscribers = entity::CalendarSubscribers { subscribers };
    let mut calendar = entity::Calendar {
        id: user_id,
        is_default: true,
        name: user_name.to_owned(),
        creater: user_id,
        tenant_id,
        version: now,
        subscribers: Some(subscribers),
        ..Default::default()
    };
    let cal = CalendarModel::create(&ctx.db, &calendar).await?;
    Ok(cal)
}

pub(crate) async fn calendar_create(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let mut req = pb_decode::<calendar::CalendarCreateRequest>(&packet.payload)?;
    debug!("create calendar request: {req:?}");
    if req.calendar.is_none() {
        return Ok((ErrorCode::ErrorParamInvalid as i32, vec![]));
    }
    let src = req.calendar.get_or_insert_default();
    let id = id_gen(None);
    let now = current_ms() as i64;
    src.is_default = false;
    src.creater = brief.id;
    src.id = id;
    src.subscribers.get_or_insert_default().subscribers.insert(
        brief.id,
        entity::calendar::Subscriber {
            subscribe_time: now,
            id: brief.id,
            color: PresetColor::rand().into(),
            role: entity::CalendarRole::RoleOwner as i32,
        },
    );
    debug!("create calendar, model: {src:?}");
    let mut resp = calendar::CalendarCreateResponse::default();
    let calendar = CalendarModel::create(&ctx.db, src).await?;
    let _ = User2CalendarModel::upsert_subscriber(
        &ctx.db, brief.id, id,
        PresetColor::rand().into(),
        entity::CalendarRole::RoleOwner as i32,
    ).await;
    let cal_entity: entity::Calendar = CalendarModel(calendar.clone()).into();
    let user_ids = cal_entity
        .subscribers
        .as_ref()
        .and_then(|s| Some(s.subscribers.keys().copied().collect::<Vec<i64>>()))
        .unwrap_or_default();

    CACHE_CALENDAR
        .insert(id, Arc::new(RwLock::new(calendar.try_into()?)))
        .await?;
    resp.calendar = Some(cal_entity.clone());
    debug!("create calendar, resp: {resp:?}");
    let ctx_clone = ctx.clone();
    tokio::spawn(async move {
        if let Err(err) = push_calendar_to_users(&ctx_clone, &user_ids, cal_entity).await {
            warn!("push calendar to users error: {err:?}");
        } else {
            debug!("push calendar to users finish: {user_ids:?}");
        }
    });

    Ok((0, resp.encode_to_vec()))
}

pub(crate) async fn calendar_delete(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<calendar::CalendarDeleteRequest>(&packet.payload)?;
    let mut resp = calendar::CalendarDeleteResponse::default();
    debug!("calendar delete, req: {req:?}");

    // 不允许删除默认日历
    if req.id == brief.id {
        return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
    }

    let calendar = CACHE_CALENDAR.get(ctx, &req.id).await?;
    let now = current_ms() as i64;
    let user_ids: Vec<i64>;
    {
        let cal = calendar.read().await;
        // 仅创建者或 RoleOwner 可删除
        if cal.calendar.creator != brief.id {
            let role = cal.subscribers.subscribers.get(&brief.id)
                .map(|s| s.role).unwrap_or(0);
            if role < entity::CalendarRole::RoleOwner as i32 {
                return Ok((ErrorCode::ErrorNoPermision as i32, resp.encode_to_vec()));
            }
        }
        user_ids = cal.user_ids();
    }

    // 级联删除日程和 cycled
    crate::models::schedules::ScheduleModel::remove_by_calendar_id(&ctx.db, req.id).await?;
    crate::models::cycleds::CycledModel::remove_by_calendar_id(&ctx.db, req.id).await?;
    User2CalendarModel::calendar_remove_for_users(&ctx.db, user_ids.clone(), req.id).await?;
    CalendarModel::delete(&ctx.db, req.id).await?;
    let _ = CACHE_CALENDAR.remove(&req.id).await;

    // 推 EntityChange 给所有订阅者
    let biz = BizHub::get()?;
    let mut push = pipeline::PushEntityChanged::default();
    let sid = id_gen(None);
    push.changes.push(entity::EntityChange {
        id: req.id,
        version: now,
        r#type: entity::EntityType::Calendar as i32,
        operate: Operate::Delete as i32,
    });
    let _ = biz
        .gateway
        .send_packet_to_user(
            ctx,
            &user_ids,
            sid,
            Command::PushEntityChange,
            push.encode_to_vec(),
            true,
        )
        .await;
    Ok((0, resp.encode_to_vec()))
}

pub(crate) async fn calendar_search(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<calendar::CalendarSearchRequest>(&packet.payload)?;
    debug!("search calendar, req: {req:?}");
    let mut resp = calendar::CalendarSearchResponse::default();
    let limit_val = if req.limit > 0 { req.limit as u64 } else { 20 };
    let offset_val = if req.offset > 0 { req.offset as u64 } else { 0 };
    let mut calendars = CalendarModel::search(&ctx.db, &req.key, brief.tenant_id, limit_val, offset_val).await?;
    resp.calendars = calendars
        .drain(..)
        .map(|c| CalendarModel(c).into())
        .collect();
    debug!("search calendar, resp: {resp:?}");
    Ok((0, resp.encode_to_vec()))
}

pub(crate) async fn calendar_get_list(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    debug!("get calendar list");
    let mut resp = calendar::CalendarGetListResponse::default();
    let mut list = CalendarModel::get_by_user_id(&ctx.db, brief.id).await?;
    debug!("get calendars from db: {:?}", list);
    let mut has_default = false;
    for c in list.drain(..) {
        if c.id == brief.id {
            has_default = true;
        }

        resp.calendars.push(CalendarModel(c).into());
    }

    if !has_default {
        debug!("try create  ");
        let user = BizHub::get()?.user.get_user_by_id(&ctx, brief.id).await?;
        let calendar = create_user_default(ctx, brief.id, brief.tenant_id, &user.name).await?;
        resp.calendars.push(CalendarModel(calendar).into());
    }

    debug!("get calendar list, resp: {:?}", resp);
    Ok((0, resp.encode_to_vec()))
}

pub(crate) async fn calendar_subscribe(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<calendar::CalendarSubscribeRequest>(&packet.payload)?;
    let mut resp = calendar::CalendarSubscribeResponse::default();
    debug!("calendar subscribe, req: {req:?}");

    let cal = CACHE_CALENDAR.get(ctx, &req.id).await?;
    let (now, user_ids, entity);
    {
        let mut calendar = cal.write().await;
        now = current_ms() as i64;
        if req.subscribe && !calendar.subscribers.subscribers.contains_key(&brief.id) {
            // TODO: check if already sub
            calendar.subscribers.subscribers.insert(
                brief.id,
                entity::calendar::Subscriber {
                    id: brief.id,
                    subscribe_time: now,
                    role: entity::CalendarRole::RoleGuest as i32,
                    color: PresetColor::rand().into(),
                },
            );

            debug!("calendar subscribed: {:?}", calendar.subscribers);
            let _ = User2CalendarModel::upsert_subscriber(
                &ctx.db, brief.id, req.id,
                PresetColor::rand().into(),
                entity::CalendarRole::RoleGuest as i32,
            ).await;
        } else if !req.subscribe && calendar.subscribers.subscribers.contains_key(&brief.id) {
            calendar.subscribers.subscribers.remove(&brief.id);
            let _ = User2CalendarModel::remove_subscriber(&ctx.db, brief.id, req.id).await;

            // 推 EntityChange(Delete) 给退订者（pipe 持久化）
            let biz = BizHub::get()?;
            let mut push = pipeline::PushEntityChanged::default();
            push.changes.push(entity::EntityChange {
                id: req.id,
                version: now,
                r#type: entity::EntityType::Calendar as i32,
                operate: Operate::Delete as i32,
            });
            let _ = biz.gateway.send_packet_to_user(
                ctx, &[brief.id], id_gen(None),
                Command::PushEntityChange, push.encode_to_vec(), true,
            ).await;
        }

        CalendarModel::update_subscribers(&ctx.db, req.id, &calendar.subscribers).await?;
        user_ids = calendar.user_ids();
        entity = calendar.entity();
    }

    let _ = push_calendar_to_users(ctx, &user_ids, entity).await;

    Ok((0, resp.encode_to_vec()))
}

pub(crate) async fn calendar_update(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<calendar::CalendarUpdateRequest>(&packet.payload)?;
    let src = req.calendar.ok_or(Error::string("no calendar"))?;

    let cal = CACHE_CALENDAR.get(ctx, &src.id).await?;
    let mut cal = cal.write().await;

    // 权限校验
    let my_role = cal.subscribers.subscribers.get(&brief.id)
        .map(|s| s.role)
        .unwrap_or(0);
    let is_manager = my_role >= entity::CalendarRole::RoleManager as i32;
    let is_owner = my_role >= entity::CalendarRole::RoleOwner as i32;

    // 根据权限应用变更
    if !src.name.is_empty() && is_manager {
        cal.calendar.name = Some(src.name.clone());
    }
    if src.color != 0 && is_manager {
        cal.calendar.color = src.color;
    }
    if is_owner {
        cal.calendar.public = src.public;
        cal.calendar.enable = src.enable;
    }
    // 订阅者个人颜色
    if let Some(sub) = cal.subscribers.subscribers.get_mut(&brief.id) {
        if let Some(ref subscribers) = src.subscribers {
            if let Some(my_sub) = subscribers.subscribers.get(&brief.id) {
                sub.color = my_sub.color;
            }
        }
    }

    let now = current_ms() as i64;
    cal.calendar.version = now;

    // 持久化
    CalendarModel::update(&ctx.db, &cal.calendar, &cal.subscribers).await?;

    // 推送变更
    let entity = cal.entity();
    let _ = push_calendar_to_users(ctx, &cal.user_ids(), entity).await;

    let mut resp = calendar::CalendarUpdateResponse::default();
    resp.calendar = Some(cal.entity());
    Ok((0, resp.encode_to_vec()))
}
