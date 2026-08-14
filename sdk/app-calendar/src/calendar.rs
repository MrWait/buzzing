use std::ops::DerefMut;

use anyhow::Result;
use base_db::meta::MetaTable;
use prost::Message as _;
use tracing::debug;

use crate::{constant::*, database, AppCalendar};
use proto::idl::{calendar, command::Command};
use service::{ffi::ffi_push, network::common_request};

impl AppCalendar {
    pub async fn calendar_list_sync(&self) -> Result<()> {
        let exist = {
            let conn = self.db.inner()?;
            MetaTable::meta(&conn)
                .get(KEY_CALENDAR_INIT)
                .map(|_| true)
                .unwrap_or(false)
        };
        debug!("calendar list exist: {exist}");
        if exist {
            return Ok(());
        }

        let req = calendar::CalendarGetListRequest::default();
        let ack = common_request::<calendar::CalendarGetListResponse>(
            Command::CalendarGetList as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;

        debug!("calendar list sync, resp: {ack:?}");
        {
            let mut conn = self.db.inner()?;
            let _ = database::calendar::calendar_batch_save(conn.deref_mut(), &ack.calendars)?;
            let _ = MetaTable::meta(&conn).insert(KEY_CALENDAR_INIT, "true")?;
        }

        let push = calendar::CalendarPushListRequest {
            calendars: ack.calendars,
        };

        let _ = ffi_push(Command::CalendarPushList as i32, push.encode_to_vec());

        Ok(())
    }

    pub async fn calendar_create(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = calendar::CalendarCreateRequest::decode(param)?;
        debug!("create calendar, req: {req:?}");
        let ack = common_request::<calendar::CalendarCreateResponse>(
            Command::CalendarCreate as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        debug!("create calendar, resp: {ack:?}");
        Ok((0, ack.encode_to_vec()))
    }

    pub async fn calendar_delete(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = calendar::CalendarDeleteRequest::decode(param)?;
        debug!("delete calendar, req: {req:?}");
        let ack = common_request::<calendar::CalendarDeleteResponse>(
            Command::CalendarDelete as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((0, ack.encode_to_vec()))
    }

    pub async fn calendar_get_list(&self, _param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let mut resp = calendar::CalendarGetListResponse::default();
        debug!("calendar get list");
        {
            let conn = self.db.inner()?;
            resp.calendars = database::calendar::calendar_get_all(&conn)?;
        }
        debug!("calendar get list, resp: {resp:?}");
        Ok((0, resp.encode_to_vec()))
    }

    pub async fn calendar_update(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = calendar::CalendarUpdateRequest::decode(param)?;
        debug!("update calendar, req: {req:?}");
        let ack = common_request::<calendar::CalendarUpdateResponse>(
            Command::CalendarUpdate as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((0, ack.encode_to_vec()))
    }

    pub async fn calendar_search(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = calendar::CalendarSearchRequest::decode(param)?;
        debug!("search calendar, req: {req:?}");
        let ack = common_request::<calendar::CalendarSearchResponse>(
            Command::CalendarSearch as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        debug!("search calendar, resp: {ack:?}");
        Ok((0, ack.encode_to_vec()))
    }

    pub async fn calendar_subscribe(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = calendar::CalendarSubscribeRequest::decode(param)?;
        debug!("subscribe calendar, req: {req:?}");
        let ack = common_request::<calendar::CalendarSubscribeResponse>(
            Command::CalendarSubscribe as i32,
            req.encode_to_vec(),
            None,
        )
        .await?;
        Ok((0, ack.encode_to_vec()))
    }

    pub async fn handle_push_calendar(&self, param: &[u8]) -> Result<()> {
        let push = calendar::CalendarPushUpdateRequest::decode(param)?;
        let mut list = calendar::CalendarPushListRequest::default();
        debug!("handle push calendar: {push:?}");
        if let Some(calendar) = push.calendar.as_ref() {
            let db = self.db.inner()?;
            database::calendar::calendar_save(&db, calendar)?;
            list.calendars = database::calendar::calendar_get_all(&db)?;
        }

        let _ = ffi_push(Command::CalendarPushList as i32, list.encode_to_vec());

        Ok(())
    }

    pub async fn handle_push_calendar_list(&self, param: &[u8]) -> Result<()> {
        let push = calendar::CalendarPushListRequest::decode(param)?;
        debug!("handle push calendar list, {push:?}");
        // 保存到本地 DB
        if !push.calendars.is_empty() {
            let mut conn = self.db.inner()?;
            database::calendar::calendar_batch_save(conn.deref_mut(), &push.calendars)?;
        }
        // ffi_push 透传到 Flutter
        let _ = ffi_push(Command::CalendarPushList as i32, param.to_vec());
        Ok(())
    }
}
