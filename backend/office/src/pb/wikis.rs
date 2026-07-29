use loco_rs::{Error, Result, app::AppContext};
use prost::Message;
use sea_orm::{ActiveModelTrait, ActiveValue, ColumnTrait, EntityTrait, QueryFilter, QueryOrder, QuerySelect, QueryTrait};
use tracing::instrument;
use yrs::{Doc, ReadTxn, Transact};

use common::{id_gen, model::UserBrief};
use proto::idl::{error::ErrorCode, office};

use crate::models::documents::DocumentModel;
use crate::models::wiki_members::WikiMemberModel;
use crate::models::wiki_pins::WikiPinModel;
use crate::models::wikis::WikiModel;
use crate::permission::{require_wiki_role, WikiRole};

fn wiki_to_item(m: crate::models::wikis::Model) -> office::WikiItem {
    office::WikiItem {
        id: m.id.to_string(),
        name: m.name,
        description: m.description.unwrap_or_default(),
        icon: m.icon.unwrap_or_default(),
        cover: m.cover.unwrap_or_default(),
        creator_id: m.creator_id.to_string(),
        home_doc_id: m.home_doc_id.map(|v| v.to_string()).unwrap_or_default(),
        created_at: m.created_at.to_rfc3339(),
        updated_at: m.updated_at.to_rfc3339(),
    }
}

fn doc_to_pin_item(d: base::models::_entities::documents::Model) -> office::WikiPinItem {
    office::WikiPinItem {
        doc_id: d.id,
        title: d.title,
    }
}

#[instrument(skip(ctx, brief, _packet))]
pub(crate) async fn list(
    ctx: &AppContext,
    brief: &UserBrief,
    _packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let wikis = WikiModel::list_accessible(&ctx.db, brief.tenant_id, brief.id).await?;
    let items: Vec<office::WikiItem> = wikis.into_iter().map(wiki_to_item).collect();
    let resp = office::WikiListResponse { items };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn create(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::WikiCreateRequest>(&packet.payload)?;
    let id = id_gen(None);
    let now = common::time::current_ms() as i64;
    let now_chrono = chrono::Utc::now();

    let _ = WikiModel::create(
        &ctx.db,
        crate::models::wikis::ActiveModel {
            id: ActiveValue::Set(id),
            tenant_id: ActiveValue::Set(brief.tenant_id),
            name: ActiveValue::Set(req.name.clone()),
            description: ActiveValue::Set(if req.description.is_empty() {
                None
            } else {
                Some(req.description)
            }),
            icon: ActiveValue::Set(if req.icon.is_empty() {
                None
            } else {
                Some(req.icon)
            }),
            cover: ActiveValue::Set(if req.cover.is_empty() {
                None
            } else {
                Some(req.cover)
            }),
            creator_id: ActiveValue::Set(brief.id),
            home_doc_id: ActiveValue::Set(None),
            created_at: ActiveValue::Set(now_chrono.into()),
            updated_at: ActiveValue::Set(now_chrono.into()),
        },
    )
    .await?;
    WikiMemberModel::add_member(&ctx.db, id, brief.id, 3, now).await?;

    let doc_id = id_gen(None);
    let empty_yjs = {
        let doc = Doc::new();
        doc.transact()
            .encode_state_as_update_v1(&Default::default())
    };
    use sea_orm::ActiveValue as AV;
    use base::models::_entities::wikis::{Column as WCol, Entity as WEnt};
    DocumentModel::create(
        &ctx.db,
        base::models::_entities::documents::ActiveModel {
            id: AV::set(doc_id),
            wiki_id: AV::set(Some(id)),
            tenant_id: AV::set(brief.tenant_id),
            creator: AV::set(brief.id),
            title: AV::set(req.name),
            doc_type: AV::set(1),
            version: AV::set(now),
            content: AV::set(empty_yjs),
            parent_id: AV::set(None),
            icon: AV::set(None),
            ..Default::default()
        },
    )
    .await?;

    let mut wm: crate::models::wikis::ActiveModel = WEnt::find_by_id(id)
        .one(&ctx.db)
        .await?
        .ok_or(Error::NotFound)?
        .into();
    wm.home_doc_id = AV::set(Some(doc_id));
    wm.update(&ctx.db).await?;

    let model = WikiModel::get_by_id(&ctx.db, id)
        .await?
        .ok_or(Error::NotFound)?;
    let resp = office::WikiCreateResponse {
        item: Some(wiki_to_item(model)),
    };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn get(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::WikiGetRequest>(&packet.payload)?;
    require_wiki_role(ctx, brief.id, req.wiki_id, WikiRole::Viewer).await?;
    let wiki = WikiModel::get_by_id(&ctx.db, req.wiki_id)
        .await?
        .ok_or(Error::NotFound)?;
    let members = WikiMemberModel::list_by_wiki(&ctx.db, req.wiki_id).await?;
    let resp = office::WikiGetResponse {
        detail: Some(office::WikiDetailItem {
            wiki: Some(wiki_to_item(wiki)),
            member_count: members.len() as i32,
        }),
    };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn update(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::WikiUpdateRequest>(&packet.payload)?;
    require_wiki_role(ctx, brief.id, req.wiki_id, WikiRole::Admin).await?;
    let model = WikiModel::update(
        &ctx.db,
        req.wiki_id,
        crate::models::wikis::ActiveModel {
            id: sea_orm::ActiveValue::NotSet,
            tenant_id: sea_orm::ActiveValue::NotSet,
            name: sea_orm::ActiveValue::Set(if req.name.is_empty() {
                String::new()
            } else {
                req.name
            }),
            description: sea_orm::ActiveValue::Set(if req.description.is_empty() {
                None
            } else {
                Some(req.description)
            }),
            icon: sea_orm::ActiveValue::Set(if req.icon.is_empty() {
                None
            } else {
                Some(req.icon)
            }),
            cover: sea_orm::ActiveValue::Set(if req.cover.is_empty() {
                None
            } else {
                Some(req.cover)
            }),
            creator_id: sea_orm::ActiveValue::NotSet,
            home_doc_id: sea_orm::ActiveValue::NotSet,
            created_at: sea_orm::ActiveValue::NotSet,
            updated_at: sea_orm::ActiveValue::NotSet,
        },
    )
    .await?;
    let resp = office::WikiUpdateResponse {
        item: Some(wiki_to_item(model)),
    };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn delete(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::WikiDeleteRequest>(&packet.payload)?;
    require_wiki_role(ctx, brief.id, req.wiki_id, WikiRole::Owner).await?;
    let wiki = WikiModel::get_by_id(&ctx.db, req.wiki_id)
        .await?
        .ok_or(Error::NotFound)?;
    if let Some(home_doc_id) = wiki.home_doc_id {
        DocumentModel::purge(&ctx.db, home_doc_id).await?;
    }
    WikiModel::delete(&ctx.db, req.wiki_id).await?;
    let resp = office::WikiDeleteResponse { ok: true };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn member_list(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::WikiMemberListRequest>(&packet.payload)?;
    require_wiki_role(ctx, brief.id, req.wiki_id, WikiRole::Viewer).await?;
    let members = WikiMemberModel::list_by_wiki(&ctx.db, req.wiki_id).await?;
    let items: Vec<office::WikiMemberItem> = members
        .into_iter()
        .map(|m| office::WikiMemberItem {
            wiki_id: m.wiki_id.to_string(),
            user_id: m.user_id.to_string(),
            role: m.role as i32,
            joined_at: m.joined_at,
        })
        .collect();
    let resp = office::WikiMemberListResponse { items };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn member_add(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::WikiMemberAddRequest>(&packet.payload)?;
    require_wiki_role(ctx, brief.id, req.wiki_id, WikiRole::Admin).await?;
    let user_id: i64 = req
        .user_id
        .parse()
        .map_err(|_| Error::string("invalid user_id"))?;
    let now = common::time::current_ms() as i64;
    let m = WikiMemberModel::add_member(&ctx.db, req.wiki_id, user_id, req.role as i16, now).await?;
    let resp = office::WikiMemberAddResponse {
        item: Some(office::WikiMemberItem {
            wiki_id: m.wiki_id.to_string(),
            user_id: m.user_id.to_string(),
            role: m.role as i32,
            joined_at: m.joined_at,
        }),
    };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn member_remove(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::WikiMemberRemoveRequest>(&packet.payload)?;
    require_wiki_role(ctx, brief.id, req.wiki_id, WikiRole::Admin).await?;
    let user_id: i64 = req
        .user_id
        .parse()
        .map_err(|_| Error::string("invalid user_id"))?;
    WikiMemberModel::remove_member(&ctx.db, req.wiki_id, user_id).await?;
    let resp = office::WikiMemberRemoveResponse { ok: true };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn pin_list(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::WikiPinListRequest>(&packet.payload)?;
    require_wiki_role(ctx, brief.id, req.wiki_id, WikiRole::Viewer).await?;
    let pins = WikiPinModel::list_by_wiki(&ctx.db, req.wiki_id).await?;
    let mut doc_ids: Vec<i64> = pins.iter().map(|p| p.doc_id).collect();
    doc_ids.dedup();
    let docs = if doc_ids.is_empty() {
        vec![]
    } else {
        DocumentModel::get_by_ids(&ctx.db, &doc_ids).await?
    };
    let items: Vec<office::WikiPinItem> = docs.into_iter().map(doc_to_pin_item).collect();
    let resp = office::WikiPinListResponse { items };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn pin_add(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::WikiPinAddRequest>(&packet.payload)?;
    require_wiki_role(ctx, brief.id, req.wiki_id, WikiRole::Editor).await?;
    let now = common::time::current_ms() as i64;
    WikiPinModel::add_pin(&ctx.db, id_gen(None), req.wiki_id, req.doc_id, brief.id, now).await?;
    let resp = office::WikiPinAddResponse { ok: true };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn pin_remove(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::WikiPinRemoveRequest>(&packet.payload)?;
    require_wiki_role(ctx, brief.id, req.wiki_id, WikiRole::Editor).await?;
    WikiPinModel::remove_pin(&ctx.db, req.wiki_id, req.doc_id).await?;
    let resp = office::WikiPinRemoveResponse { ok: true };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}

#[instrument(skip(ctx, brief, packet))]
pub(crate) async fn recent(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &proto::idl::entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = common::pb_decode::<office::WikiRecentListRequest>(&packet.payload)?;
    require_wiki_role(ctx, brief.id, req.wiki_id, WikiRole::Viewer).await?;
    use base::models::_entities::documents::Column as DocCol;
    let docs = base::models::_entities::documents::Entity::find()
        .filter(DocCol::WikiId.eq(req.wiki_id))
        .filter(DocCol::TrashedAt.is_null())
        .order_by_desc(DocCol::UpdatedAt)
        .limit(20)
        .all(&ctx.db)
        .await?;
    let items: Vec<office::GetDocResponse> = docs
        .into_iter()
        .map(|d| crate::pb::docs::model_to_get_resp_simple(d))
        .collect();
    let resp = office::WikiRecentListResponse { items };
    Ok((ErrorCode::Success as i32, resp.encode_to_vec()))
}
