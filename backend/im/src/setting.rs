use loco_rs::{Result, app::AppContext};
use prost::Message;
use tracing::debug;

use common::pb_decode;
use common::{BizHub, UserBrief, common_error, id_gen, time::current_ms};
use proto::idl::{entity, error::ErrorCode, feed, message};

pub(crate) async fn favorite_add(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let mut req = pb_decode::<message::FavoriteAddRequest>(&packet.payload)?;
    debug!("setting add for user: {}", brief.id);
    let biz = BizHub::get()?;

    if let Some(mut favo) = req.favorite.take() {
        favo.id = id_gen(None);
        let now = current_ms() as i64;
        biz.setting
            .update_config(
                &ctx.db,
                brief.id,
                entity::SettingType::SettingFavorite as i32,
                Box::new(move |mut setting: entity::Setting| {
                    setting.version = now;
                    let mut favos = pb_decode::<entity::FavoriteList>(&setting.data)?;
                    favos.favorites.push(favo.clone());
                    setting.data = favos.encode_to_vec();
                    Ok(setting)
                }),
            )
            .await?;
    };

    Ok((0, vec![]))
}

pub(crate) async fn favorite_remove(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<message::FavoriteRemoveRequest>(&packet.payload)?;
    debug!("setting remove for user: {}, {req:?}", brief.id);
    let now = current_ms() as i64;

    let hub = BizHub::get()?;

    hub.setting
        .update_config(
            &ctx.db,
            brief.id,
            entity::SettingType::SettingFavorite as i32,
            Box::new(move |mut setting: entity::Setting| {
                setting.version = now;
                let mut favos = pb_decode::<entity::FavoriteList>(&setting.data)?;
                favos.favorites.retain(|f| f.id != req.id);
                setting.data = favos.encode_to_vec();
                Ok(setting)
            }),
        )
        .await?;
    Ok((0, vec![]))
}

pub(crate) async fn favorite_get(
    ctx: &AppContext,
    brief: &UserBrief,
    _packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    debug!("favorite get");
    let biz = BizHub::get()?;
    let setting = biz
        .setting
        .get_config(
            &ctx.db,
            brief.id,
            entity::SettingType::SettingFavorite as i32,
        )
        .await?
        .unwrap_or_default();

    let mut resp = message::GetFavoriteListResponse::default();
    resp.version = setting.version;
    resp.favorites = Some(pb_decode::<entity::FavoriteList>(&setting.data)?);

    debug!("favorite get, resp: {resp:?}");
    Ok((0, resp.encode_to_vec()))
}

pub(crate) async fn top_list_add(
    ctx: &AppContext,
    user_id: i64,
    id: i64,
) -> Result<entity::Setting> {
    let hub = BizHub::get()?;

    let setting = hub
        .setting
        .update_config(
            &ctx.db,
            user_id,
            entity::SettingType::SettingTopList as i32,
            Box::new(move |mut setting: entity::Setting| {
                let mut list = pb_decode::<entity::IdList>(&setting.data)?;
                if list.ids.len() > 50 {
                    return Err(common_error("top list full"));
                }
                list.ids.push(id);
                setting.data = list.encode_to_vec();
                Ok(setting)
            }),
        )
        .await?;
    Ok(setting)
}

pub(crate) async fn top_list_get(
    ctx: &AppContext,
    brief: &UserBrief,
    _packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let hub = BizHub::get()?;

    let setting = hub
        .setting
        .get_config(
            &ctx.db,
            brief.id,
            entity::SettingType::SettingTopList as i32,
        )
        .await?
        .unwrap_or(entity::Setting::default());
    debug!("get top list");
    let mut resp = feed::GetFeedTopListResponse::default();
    resp.version = setting.version;
    resp.ids = pb_decode::<entity::IdList>(&setting.data)?.ids;

    debug!("get top list, resp: {resp:?}");
    Ok((ErrorCode::Ok as i32, resp.encode_to_vec()))
}
