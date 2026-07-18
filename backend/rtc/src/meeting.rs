use std::sync::LazyLock;
use std::collections::HashMap;
use tokio::sync::RwLock;

use loco_rs::{Error, Result, app::AppContext, prelude::*};
use prost::Message;
use tracing::debug;

use common::{BizHub, UserBrief, id_gen, pb_decode, current_ms};
use proto::idl::{meeting, command::Command, entity, error::ErrorCode};
use crate::models::meetings::{MeetingModel, Model as MeetingDbModel};
use crate::models::meeting_members::{MeetingMemberModel, Model as MemberDbModel};

static ROOM_ID_COUNTER: LazyLock<RwLock<HashMap<String, u64>>> = LazyLock::new(|| RwLock::new(HashMap::new()));

async fn generate_room_id() -> String {
    let ts = current_ms() as u64 / 1000;
    let mut counter = ROOM_ID_COUNTER.write().await;
    let seq = counter.entry("global".to_string()).or_insert(0);
    *seq += 1;
    let seq = *seq % 9999;
    format!("{}{:04}", ts % 100000000, seq)
}

async fn push_meeting_update(
    ctx: &AppContext,
    user_ids: &[i64],
    meeting_info: meeting::MeetingInfo,
    action: meeting::MeetingPushAction,
) -> Result<()> {
    if user_ids.is_empty() {
        return Ok(());
    }
    let biz = BizHub::get()?;
    let rid = id_gen(None);
    let push = meeting::MeetingPushUpdate {
        meeting: Some(meeting_info),
        action: action as i32,
    };
    biz.gateway
        .send_packet_to_user(ctx, user_ids, rid, Command::MeetingPushUpdate, push.encode_to_vec(), true)
        .await?;
    Ok(())
}

async fn meeting_info_from_model(
    db: &DatabaseConnection,
    model: &MeetingDbModel,
) -> Result<meeting::MeetingInfo> {
    let members = MeetingMemberModel::get_by_meeting_id(db, model.id).await
        .map_err(|e| Error::Message(e.to_string()))?;
    let member_ids: Vec<i64> = members.iter().map(|m| m.user_id).collect();
    let member_protos: Vec<meeting::MeetingMember> = members.into_iter().map(|m| MeetingMemberModel(m).into()).collect();
    let settings = serde_json::from_value::<meeting::MeetingSettings>(model.settings.clone())
        .unwrap_or_default();

    Ok(meeting::MeetingInfo {
        id: model.id,
        room_id: model.room_id.clone(),
        title: model.title.clone(),
        host_id: model.host_id,
        created_at: model.created_at,
        password: model.password.clone().unwrap_or_default(),
        status: if model.status == 1 {
            meeting::MeetingStatus::MeetingEnded as i32
        } else {
            meeting::MeetingStatus::MeetingActive as i32
        },
        scheduled_at: model.scheduled_at.unwrap_or(0),
        started_at: model.started_at,
        ended_at: model.ended_at.unwrap_or(0),
        tenant_id: model.tenant_id,
        member_ids,
        members: member_protos,
        settings: Some(settings),
        max_participants: model.max_participants,
    })
}

// ── MEETING_CREATE ──

pub(crate) async fn handle_create(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<meeting::MeetingCreateRequest>(&packet.payload)
        .map_err(|_| Error::Message("invalid create request".to_string()))?;
    let mut resp = meeting::MeetingCreateResponse::default();

    let id = id_gen(None);
    let room_id = generate_room_id().await;
    let now = current_ms() as i64;

    let password_hash = if !req.password.is_empty() {
        Some(bcrypt::hash(&req.password, 10).map_err(|e| Error::Message(e.to_string()))?)
    } else {
        None
    };

    let settings_json = serde_json::to_value(
        req.settings.as_ref().unwrap_or(&meeting::MeetingSettings {
            mute_on_entry: false,
            allow_screen_share: true,
            record_enabled: false,
        })
    ).map_err(|e| Error::Message(e.to_string()))?;

    let model = MeetingDbModel {
        id,
        room_id: room_id.clone(),
        title: req.title.clone(),
        host_id: brief.id,
        password: password_hash,
        status: 0i16,
        scheduled_at: if req.scheduled_at > 0 { Some(req.scheduled_at) } else { None },
        started_at: now,
        ended_at: None,
        tenant_id: brief.tenant_id,
        max_participants: if req.max_participants > 0 { req.max_participants } else { 4 },
        settings: settings_json,
        created_at: now,
        updated_at: now,
    };

    MeetingModel::create(&ctx.db, &model).await
        .map_err(|e| Error::Message(e.to_string()))?;

    MeetingMemberModel::create(&ctx.db, id, brief.id, 2i16).await
        .map_err(|e| Error::Message(e.to_string()))?;

    let meeting_info = meeting_info_from_model(&ctx.db, &model).await?;
    resp.meeting = Some(meeting_info);
    Ok((0, resp.encode_to_vec()))
}

// ── MEETING_JOIN ──

pub(crate) async fn handle_join(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<meeting::JoinMeetingRequest>(&packet.payload)
        .map_err(|_| Error::Message("invalid join request".to_string()))?;
    let mut resp = meeting::JoinMeetingResponse::default();

    let meeting = MeetingModel::get_by_room_id(&ctx.db, &req.room_id).await
        .map_err(|e| Error::Message(e.to_string()))?
        .ok_or_else(|| Error::Message("meeting not found".to_string()))?;

    if meeting.status != 0i16 {
        return Ok((ErrorCode::ErrorParamInvalid as i32, vec![]));
    }

    if let Some(ref pw) = meeting.password {
        if !bcrypt::verify(&req.password, pw).unwrap_or(false) {
            return Ok((ErrorCode::ErrorParamInvalid as i32, vec![]));
        }
    }

    let existing = MeetingMemberModel::get_by_user_and_meeting(&ctx.db, meeting.id, brief.id).await
        .map_err(|e| Error::Message(e.to_string()))?;
    if existing.is_none() {
        MeetingMemberModel::create(&ctx.db, meeting.id, brief.id, 0i16).await
            .map_err(|e| Error::Message(e.to_string()))?;
    }

    let meeting_info = meeting_info_from_model(&ctx.db, &meeting).await?;

    let info_for_push = meeting_info.clone();
    let ctx_clone = ctx.clone();
    tokio::spawn(async move {
        let _ = push_meeting_update(
            &ctx_clone,
            &[meeting.host_id],
            info_for_push,
            meeting::MeetingPushAction::MeetingPushJoined,
        ).await;
    });

    resp.meeting = Some(meeting_info);
    Ok((0, resp.encode_to_vec()))
}

// ── MEETING_LEAVE ──

pub(crate) async fn handle_leave(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<meeting::LeaveMeetingRequest>(&packet.payload)
        .map_err(|_| Error::Message("invalid leave request".to_string()))?;
    let resp = meeting::LeaveMeetingResponse {};

    let meeting = MeetingModel::get_by_room_id(&ctx.db, &req.room_id).await
        .map_err(|e| Error::Message(e.to_string()))?
        .ok_or_else(|| Error::Message("meeting not found".to_string()))?;

    MeetingMemberModel::update_status(&ctx.db, meeting.id, brief.id, 2i16).await
        .map_err(|e| Error::Message(e.to_string()))?;

    let active_count = MeetingMemberModel::get_active_count(&ctx.db, meeting.id).await
        .map_err(|e| Error::Message(e.to_string()))?;

    if active_count == 0 {
        MeetingModel::update_status(&ctx.db, meeting.id, 1i16).await
            .map_err(|e| Error::Message(e.to_string()))?;
    }

    let meeting_info = meeting_info_from_model(&ctx.db, &meeting).await?;
    let ctx_clone = ctx.clone();
    tokio::spawn(async move {
        let _ = push_meeting_update(
            &ctx_clone,
            &[meeting.host_id],
            meeting_info,
            meeting::MeetingPushAction::MeetingPushLeft,
        ).await;
    });

    Ok((0, resp.encode_to_vec()))
}

// ── MEETING_END ──

pub(crate) async fn handle_end(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<meeting::EndMeetingRequest>(&packet.payload)
        .map_err(|_| Error::Message("invalid end request".to_string()))?;
    let resp = meeting::EndMeetingResponse {};

    let meeting = MeetingModel::get_by_room_id(&ctx.db, &req.room_id).await
        .map_err(|e| Error::Message(e.to_string()))?
        .ok_or_else(|| Error::Message("meeting not found".to_string()))?;

    if meeting.host_id != brief.id {
        return Ok((ErrorCode::ErrorNoPermision as i32, vec![]));
    }

    MeetingModel::update_status(&ctx.db, meeting.id, 1i16).await
        .map_err(|e| Error::Message(e.to_string()))?;

    MeetingMemberModel::bulk_end_by_meeting(&ctx.db, meeting.id).await
        .map_err(|e| Error::Message(e.to_string()))?;

    let member_ids: Vec<i64> = MeetingMemberModel::get_by_meeting_id(&ctx.db, meeting.id).await
        .map_err(|e| Error::Message(e.to_string()))?
        .into_iter().map(|m| m.user_id).collect();

    let meeting_info = meeting_info_from_model(&ctx.db, &meeting).await?;
    let ctx_clone = ctx.clone();
    tokio::spawn(async move {
        let _ = push_meeting_update(
            &ctx_clone,
            &member_ids,
            meeting_info,
            meeting::MeetingPushAction::MeetingPushEnded,
        ).await;
    });

    Ok((0, resp.encode_to_vec()))
}

// ── MEETING_GET_INFO ──

pub(crate) async fn handle_get_info(
    ctx: &AppContext,
    _brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<meeting::GetMeetingInfoRequest>(&packet.payload)
        .map_err(|_| Error::Message("invalid get_info request".to_string()))?;
    let mut resp = meeting::GetMeetingInfoResponse::default();

    let meeting = MeetingModel::get_by_room_id(&ctx.db, &req.room_id).await
        .map_err(|e| Error::Message(e.to_string()))?
        .ok_or_else(|| Error::Message("meeting not found".to_string()))?;

    let meeting_info = meeting_info_from_model(&ctx.db, &meeting).await?;
    resp.meeting = Some(meeting_info);
    Ok((0, resp.encode_to_vec()))
}

// ── MEETING_GET_LIST ──

pub(crate) async fn handle_get_list(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<meeting::MeetingGetListRequest>(&packet.payload)
        .map_err(|_| Error::Message("invalid get_list request".to_string()))?;
    let mut resp = meeting::MeetingGetListResponse::default();

    let page = if req.page > 0 { req.page } else { 1 };
    let page_size = if req.page_size > 0 { req.page_size } else { 20 };
    let filter = req.filter;

    let (models, total) = if filter == meeting::MeetingListFilter::MeetingListActive as i32 {
        MeetingModel::get_active_by_user(&ctx.db, brief.tenant_id, brief.id, page, page_size).await
            .map_err(|e| Error::Message(e.to_string()))?
    } else {
        MeetingModel::get_list_by_filter(&ctx.db, brief.tenant_id, filter, page, page_size).await
            .map_err(|e| Error::Message(e.to_string()))?
    };

    let mut meetings = Vec::with_capacity(models.len());
    for m in models {
        let info = meeting_info_from_model(&ctx.db, &m).await?;
        meetings.push(info);
    }

    resp.meetings = meetings;
    resp.total = total;
    Ok((0, resp.encode_to_vec()))
}

// ── MEETING_KICK ──

pub(crate) async fn handle_kick(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<meeting::KickMeetingRequest>(&packet.payload)
        .map_err(|_| Error::Message("invalid kick request".to_string()))?;
    let resp = meeting::KickMeetingResponse {};

    let meeting = MeetingModel::get_by_room_id(&ctx.db, &req.room_id).await
        .map_err(|e| Error::Message(e.to_string()))?
        .ok_or_else(|| Error::Message("meeting not found".to_string()))?;

    if meeting.host_id != brief.id {
        return Ok((ErrorCode::ErrorNoPermision as i32, vec![]));
    }
    if req.target_id == meeting.host_id {
        return Ok((ErrorCode::ErrorParamInvalid as i32, vec![]));
    }

    MeetingMemberModel::update_status(&ctx.db, meeting.id, req.target_id, 3i16).await
        .map_err(|e| Error::Message(e.to_string()))?;

    let meeting_info = meeting_info_from_model(&ctx.db, &meeting).await?;
    let ctx_clone = ctx.clone();
    let info_clone = meeting_info.clone();
    tokio::spawn(async move {
        let _ = push_meeting_update(
            &ctx_clone,
            &[req.target_id],
            info_clone,
            meeting::MeetingPushAction::MeetingPushKicked,
        ).await;
    });

    Ok((0, resp.encode_to_vec()))
}

// ── MEETING_SET_ROLE ──

pub(crate) async fn handle_set_role(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<meeting::SetRoleRequest>(&packet.payload)
        .map_err(|_| Error::Message("invalid set_role request".to_string()))?;
    let resp = meeting::SetRoleResponse {};

    let meeting = MeetingModel::get_by_room_id(&ctx.db, &req.room_id).await
        .map_err(|e| Error::Message(e.to_string()))?
        .ok_or_else(|| Error::Message("meeting not found".to_string()))?;

    if meeting.host_id != brief.id {
        return Ok((ErrorCode::ErrorNoPermision as i32, vec![]));
    }

    MeetingMemberModel::update_role(&ctx.db, meeting.id, req.target_id, req.role as i16).await
        .map_err(|e| Error::Message(e.to_string()))?;

    let meeting_info = meeting_info_from_model(&ctx.db, &meeting).await?;
    let ctx_clone = ctx.clone();
    tokio::spawn(async move {
        let _ = push_meeting_update(
            &ctx_clone,
            &[req.target_id],
            meeting_info,
            meeting::MeetingPushAction::MeetingPushRoleChanged,
        ).await;
    });

    Ok((0, resp.encode_to_vec()))
}

// ── MEETING_INVITE ──

pub(crate) async fn handle_invite(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<meeting::InviteMeetingRequest>(&packet.payload)
        .map_err(|_| Error::Message("invalid invite request".to_string()))?;
    let resp = meeting::InviteMeetingResponse {};

    let meeting = MeetingModel::get_by_room_id(&ctx.db, &req.room_id).await
        .map_err(|e| Error::Message(e.to_string()))?
        .ok_or_else(|| Error::Message("meeting not found".to_string()))?;

    let invite = meeting::MeetingInvite {
        room_id: req.room_id.clone(),
        meeting_id: meeting.id,
        title: meeting.title.clone(),
        host_id: brief.id,
        host_name: String::new(),
    };

    let biz = BizHub::get()?;
    let rid = id_gen(None);
    let push = meeting::MeetingPushUpdate {
        meeting: Some(meeting_info_from_model(&ctx.db, &meeting).await?),
        action: meeting::MeetingPushAction::MeetingPushInvited as i32,
    };
    biz.gateway
        .send_packet_to_user(&ctx, &req.target_ids, rid, Command::MeetingPushUpdate, push.encode_to_vec(), true)
        .await?;

    Ok((0, resp.encode_to_vec()))
}
