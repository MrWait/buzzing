use loco_rs::{Error, Result, app::AppContext};
use prost::Message;
use tracing::debug;

use crate::models::users;
use common::{model::UserBrief, pb_decode};
use proto::idl::{entity, user, error::ErrorCode};

fn mask_phone(phone: &str) -> String {
    if phone.is_empty() {
        return String::new();
    }
    let digits: String = phone.chars().filter(|c| c.is_ascii_digit()).collect();
    if digits.len() <= 4 {
        return phone.to_string();
    }
    let prefix = if phone.starts_with("+") {
        let plus_len = phone.len() - digits.len();
        &phone[..plus_len]
    } else {
        ""
    };
    let visible_start = 3.min(digits.len());
    let visible_end = digits.len().saturating_sub(4);
    if visible_start >= visible_end {
        return phone.to_string();
    }
    let masked = format!(
        "{}{}{}{}{}",
        prefix,
        &digits[..visible_start],
        "****",
        &digits[visible_end..],
        ""
    );
    masked
}

pub async fn get_by_ids(
    ctx: &AppContext,
    _brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<user::GetUserByIdsRequest>(&packet.payload)?;
    debug!("user get by ids, req: {req:?}");
    let mut resp = user::GetUserByIdsResponse::default();

    if req.ids.is_empty() {
        return Ok((ErrorCode::Success as i32, resp.encode_to_vec()));
    }

    let user_account_pairs = users::UserModel::find_by_ids_with_account(&ctx.db, &req.ids).await?;

    let superiors: Vec<i64> = user_account_pairs
        .iter()
        .map(|(u, _)| u.superior_id)
        .filter(|&id| id > 0)
        .collect();
    let superior_models = if superiors.is_empty() {
        vec![]
    } else {
        users::UserModel::find_by_ids(&ctx.db, &superiors).await?
    };
    let superior_map: std::collections::HashMap<i64, String> = superior_models
        .into_iter()
        .map(|u| (u.id, u.name.clone()))
        .collect();

    resp.users = user_account_pairs
        .into_iter()
        .map(|(user_model, account)| {
            let mut u: entity::User = users::UserModel(user_model).into();
            u.phone = mask_phone(&account.phone);
            if let Some(superior_name) = superior_map.get(&u.superior_id) {
                u.superior_name = superior_name.clone();
            }
            u
        })
        .collect();

    debug!("user get by ids, resp: {resp:?}");

    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}
