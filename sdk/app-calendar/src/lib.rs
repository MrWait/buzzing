mod calendar;
mod database;
mod schedule;

use anyhow::Result;
use async_trait::async_trait;
use base_runtime::spawn;
use tracing::{debug, instrument};

use base_db::DbConn;
use base_util::{gen_i32, thread_id};
use proto::idl;
use proto::idl::command::Command;
use service::{AppTrait, BizCalendar, BizHub, Event, InitRequest, LoginRequest};

pub mod constant {
    pub const KEY_CALENDAR_INIT: &str = "calendar_init";
}

#[derive(Debug, Clone)]
pub struct AppCalendar {
    db: DbConn,
}
impl AppCalendar {
    pub fn new() -> Self {
        AppCalendar {
            db: DbConn::default(),
        }
    }
}

#[async_trait]
impl AppTrait for AppCalendar {
    fn init(&self, _req: &InitRequest) -> Result<()> {
        Ok(())
    }
    fn uninit(&self) -> Result<()> {
        Ok(())
    }

    fn login(&self, _req: &LoginRequest) -> Result<()> {
        let acc = BizHub::get()?.account.clone();
        let user_info = acc.get_user_info();
        let device_info = acc.get_device_info();

        match database::init_db(&user_info, &device_info) {
            Ok(db) => self.db.set(db),
            Err(err) => debug!("init chat db error: {err:?}"),
        }

        Ok(())
    }
    fn logout(&self) -> Result<()> {
        self.db.reset();
        Ok(())
    }

    fn ffi_commands(&self) -> Vec<i32> {
        vec![
            // calendar
            Command::CalendarCreate as i32,
            Command::CalendarDelete as i32,
            Command::CalendarGetList as i32,
            Command::CalendarUpdate as i32,
            Command::CalendarSearch as i32,
            Command::CalendarSubscribe as i32,
            // schedule
            Command::ScheduleCreate as i32,
            Command::ScheduleRemove as i32,
            Command::ScheduleUpdate as i32,
            Command::SchedulePullBusy as i32,
            Command::SchedulePullByIds as i32,
            Command::SchedulePullByCalendarIds as i32,
        ]
    }

    fn net_commands(&self) -> Vec<i32> {
        vec![
            // calendar
            Command::CalendarPushList as i32,
            Command::CalendarPushUpdate as i32,
            // schedule
            Command::SchedulePushUpdate as i32,
            Command::PushScheduleUpdateByRange as i32,
            // push（1057 PUSH_ENTITY_CHANGE 由 BizHub::invoke_net_command 特化统一分发，
            // 本 service 经 AppTrait::handle_entity_changed 按 EntityType 接收）
            Command::PushScheduleDelete as i32,
            Command::PushScheduleReminder as i32,
        ]
    }

    async fn on_ffi_command(&self, command: i32, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let cmd = Command::try_from(command)?;
        let ret = match cmd {
            Command::CalendarCreate => self.calendar_create(params).await,
            Command::CalendarDelete => self.calendar_delete(params).await,
            Command::CalendarGetList => self.calendar_get_list(params).await,
            Command::CalendarUpdate => self.calendar_update(params).await,
            Command::CalendarSearch => self.calendar_search(params).await,
            Command::CalendarSubscribe => self.calendar_subscribe(params).await,

            Command::ScheduleCreate => self.schedule_create(params).await,
            Command::ScheduleRemove => self.schedule_remove(params).await,
            Command::ScheduleUpdate => self.schedule_update(params).await,
            Command::SchedulePullBusy => self.schedule_pull_busy(params).await,
            Command::SchedulePullByIds => self.schedule_pull_by_ids(params).await,
            Command::SchedulePullByCalendarIds => self.schedule_pull_by_calendar_ids(params).await,
            _ => return Err(anyhow::anyhow!("not handled")),
        };

        ret
    }
    async fn on_net_command(&self, _source: i32, command: i32, params: &[u8]) -> Result<()> {
        let cmd = Command::try_from(command)?;
        match cmd {
            Command::CalendarPushList => self.handle_push_calendar_list(params).await,
            Command::CalendarPushUpdate => self.handle_push_calendar(params).await,
            Command::SchedulePushUpdate => self.handle_push_schedule_update(params).await,
            Command::PushScheduleUpdateByRange => self.handle_push_schedule_update_by_range(params).await,
            Command::PushScheduleDelete => self.handle_push_schedule_delete(params).await,
            Command::PushScheduleReminder => self.handle_push_schedule_reminder(params).await,
            _ => return Err(anyhow::anyhow!("not handled")),
        }
    }
    fn on_event(&self, event: Event, _params: &[u8]) {
        match event {
            Event::EventLogin => {
                spawn(async move {
                    let _ = calendar_list_sync().await;
                });
            }
            _ => {}
        }
    }

    /// 处理实体变更（PUSH_ENTITY_CHANGE，由 BizHub::invoke_net_command 特化分发进来）。
    /// Calendar(21)/Schedule(22)：
    /// - Delete → 本地直删（在线直删 + 离线 pipeline 回放直删）；
    /// - Update → 标记本地脏（下次 Calendar/Schedule 拉取时刷新，见 calendar_list_sync / schedule_pull_by_ids）。
    fn handle_entity_changed(&self, changes: &[idl::entity::EntityChange]) -> Result<()> {
        use idl::entity::{EntityType, Operate};
        debug!("handle entity changed: {changes:?}");
        let conn = self.db.inner()?;
        for change in changes {
            let op = Operate::from_i32(change.operate).unwrap_or(Operate::None);
            match op {
                Operate::Delete if change.r#type == EntityType::Calendar as i32 => {
                    database::calendar::calendar_remove_local(&conn, change.id)?;
                }
                Operate::Delete if change.r#type == EntityType::Schedule as i32 => {
                    database::schedule::schedule_remove_local(&conn, change.id)?;
                }
                Operate::Update if change.r#type == EntityType::Calendar as i32 => {
                    database::calendar::calendar_mark_dirty(&conn, &[change.id])?;
                }
                Operate::Update if change.r#type == EntityType::Schedule as i32 => {
                    database::schedule::schedule_mark_dirty(&conn, &[change.id])?;
                }
                _ => {}
            }
        }
        Ok(())
    }
}

impl BizCalendar for AppCalendar {}

#[instrument(fields(sid=gen_i32(), tid=thread_id()))]
async fn calendar_list_sync() -> Result<()> {
    debug!("start sync calendar list");
    let biz = BizHub::get()?;
    if let Some(cal) = biz.calendar.downcast_ref::<AppCalendar>() {
        let _ = cal.calendar_list_sync().await;
    } else {
        debug!("no calendar instance");
    };
    Ok(())
}
