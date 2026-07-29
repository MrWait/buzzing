use loco_rs::{Error, Result, app::AppContext};
use prost::Message;
use sea_orm::{ColumnTrait, EntityTrait, QueryFilter};
use tracing::instrument;

use common::model::UserBrief;
use proto::idl::{error::ErrorCode, office};

use crate::models::document_members::DocumentMemberModel;
use crate::permission::{require_role, Role};

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn list(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::MemberListRequest>(&packet.payload)?;
    require_role(ctx, brief.id, req.doc_id, Role::Viewer).await?;
    let members = DocumentMemberModel::get_members(&ctx.db, req.doc_id).await?;

    let user_ids: Vec<i64> = members.iter().map(|m| m.user_id).collect();
    let users = if user_ids.is_empty() {
        vec![]
    } else {
        use base::models::_entities::users::{Column as UCol, Entity as UsersEntity};
        UsersEntity::find()
            .filter(UCol::Id.is_in(user_ids.clone()))
            .all(&ctx.db)
            .await?
    };

    let items: Vec<office::MemberItem> = members
        .into_iter()
        .map(|m| {
            let user = users.iter().find(|u| u.id == m.user_id);
            let role = Role::from_i32(m.role);
            office::MemberItem {
                user_id: m.user_id.to_string(),
                name: user
                    .map(|u| u.name.clone())
                    .unwrap_or_else(|| String::from("未知用户")),
                avatar: user.and_then(|u| u.avatar.clone()).unwrap_or_default(),
                role: m.role,
                role_label: role.label().to_string(),
                joined_at: m.joined_at,
            }
        })
        .collect();
    let resp = office::MemberListResponse { items };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn add(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::MemberAddRequest>(&packet.payload)?;
    require_role(ctx, brief.id, req.doc_id, Role::Owner).await?;
    let user_id: i64 = req
        .user_id
        .parse()
        .map_err(|_| Error::string("invalid user_id"))?;
    if DocumentMemberModel::get_one(&ctx.db, req.doc_id, user_id)
        .await?
        .is_some()
    {
        DocumentMemberModel::update_role(&ctx.db, req.doc_id, user_id, req.role).await?;
    } else {
        DocumentMemberModel::add_member(&ctx.db, req.doc_id, user_id, req.role).await?;
    }
    let resp = office::MemberAddResponse { ok: true };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn update(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::MemberUpdateRequest>(&packet.payload)?;
    require_role(ctx, brief.id, req.doc_id, Role::Owner).await?;
    let user_id: i64 = req
        .user_id
        .parse()
        .map_err(|_| Error::string("invalid user_id"))?;
    DocumentMemberModel::update_role(&ctx.db, req.doc_id, user_id, req.role).await?;
    let resp = office::MemberUpdateResponse { ok: true };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn remove(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::MemberRemoveRequest>(&packet.payload)?;
    require_role(ctx, brief.id, req.doc_id, Role::Owner).await?;
    let user_id: i64 = req
        .user_id
        .parse()
        .map_err(|_| Error::string("invalid user_id"))?;
    DocumentMemberModel::remove_member(&ctx.db, req.doc_id, user_id).await?;
    let resp = office::MemberRemoveResponse { ok: true };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}
