mod calendar;
mod database;
mod schedule;

use anyhow::Result;
use async_trait::async_trait;
use base_runtime::spawn;
use tracing::{debug, instrument};

use base_db::DbConn;
use base_util::{gen_i32, thread_id};
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
