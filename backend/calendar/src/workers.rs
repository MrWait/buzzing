use common::time::current_ms;
use loco_rs::Result;
use loco_rs::app::AppContext;
use prost::Message;
use std::time::Duration;
use tokio::time::sleep;
use tracing::{debug, error, warn};

use crate::cycled;
use crate::models::cycleds::CycledModel;
use crate::models::schedule_reminders::ScheduleReminderModel;
use crate::models::schedules::{ScheduleModel, ScheduleExtra};

pub fn start_batch_remind_worker(ctx: &AppContext) {
    let ctx = ctx.clone();
    tokio::spawn(async move {
        loop {
            sleep(Duration::from_secs(3600)).await;
            debug!("batch_remind_worker: starting cycle");
            if let Err(e) = batch_remind_cycle(&ctx).await {
                error!("batch_remind_worker error: {e}");
            }
        }
    });
}

pub fn start_remind_worker(ctx: &AppContext) {
    let ctx = ctx.clone();
    tokio::spawn(async move {
        loop {
            sleep(Duration::from_secs(30)).await;
            debug!("remind_worker: starting cycle");
            if let Err(e) = remind_cycle(&ctx).await {
                error!("remind_worker error: {e}");
            }
        }
    });
}

/// 每小时运行：展开 cycled + 计算提醒 + 清理孤儿
async fn batch_remind_cycle(ctx: &AppContext) -> Result<()> {
    let now = current_ms() as i64;

    // 1. 找到需要重新展开的 cycled (expand_end 小于当前时间)
    let cycleds = CycledModel::find_cycleds_expand_end_before(&ctx.db, now).await?;

    for cycled in &cycleds {
        let template = CycledModel(cycled.clone()).template_as_schedule();
        let new_end = now + 120 * 86400_000i64;
        if let Err(e) = CycledModel::update_expand_end(&ctx.db, cycled.id, new_end).await {
            warn!("batch: update_expand_end failed for cycled {}: {e}", cycled.id);
            continue;
        }
        if let Ok(instances) = cycled::gen_by_rule(&template) {
            let mut reminders = Vec::new();
            for inst in &instances {
                if inst.start_time >= now && inst.start_time < now + 86400_000i64 * 30 {
                    for notify_min in &inst.notify_time {
                        let remind_at = inst.start_time - (*notify_min as i64 * 60_000);
                        if remind_at > now && remind_at < now + 3600_000i64 {
                            for uid in &inst.member_ids {
                                reminders.push((inst.id, *uid, remind_at, *notify_min));
                            }
                        }
                    }
                }
            }
            if !reminders.is_empty() {
                let _ = ScheduleReminderModel::batch_insert_ignore(&ctx.db, reminders).await;
            }
        }
    }

    // 2. 处理非重复日程的提醒生成
    let end_range = now + 3600_000i64;
    if let Ok(schedules) = ScheduleModel::find_by_start_time_range(&ctx.db, now, end_range).await {
        let mut reminders = Vec::new();
        for s in &schedules {
            for notify_min in schedule_notify_times(s) {
                let remind_at = s.start_time - (notify_min as i64 * 60_000);
                if remind_at > now && remind_at < end_range {
                    for uid in &s.member_ids {
                        reminders.push((s.id, *uid, remind_at, notify_min));
                    }
                }
            }
        }
        if !reminders.is_empty() {
            let _ = ScheduleReminderModel::batch_insert_ignore(&ctx.db, reminders).await;
        }
    }

    // 3. 清理过期孤儿行
    let _ = ScheduleReminderModel::cleanup_orphans(&ctx.db).await;

    debug!("batch_remind_cycle done");
    Ok(())
}

/// 每 30 秒运行：扫描到期提醒 + 推送
async fn remind_cycle(ctx: &AppContext) -> Result<()> {
    use common::BizHub;
    use proto::idl::{calendar, command::Command};

    let now = current_ms() as i64;
    let biz = match BizHub::get() {
        Ok(b) => b,
        Err(_) => return Ok(()),
    };

    let due = ScheduleReminderModel::find_due(&ctx.db, now).await?;
    if due.is_empty() {
        return Ok(());
    }

    for reminder in &due {
        if let Ok(schedules) = ScheduleModel::get_by_ids(&ctx.db, vec![reminder.schedule_id]).await {
            if let Some(schedule) = schedules.first() {
                let extra = ScheduleExtra::decode(schedule.extra.as_slice())
                    .unwrap_or_default();
                let push = calendar::ScheduleRemindPush {
                    schedule_id: reminder.schedule_id,
                    start_time: schedule.start_time,
                    end_time: schedule.end_time,
                    title: schedule.title.clone(),
                    location: String::new(),
                    notify_minute: reminder.notify_minute,
                    r#type: schedule.r#type,
                    room_id: extra.room_id,
                };
                let _ = biz
                    .gateway
                    .send_packet_to_user(
                        ctx,
                        &[reminder.user_id],
                        0,
                        Command::PushScheduleReminder,
                        push.encode_to_vec(),
                        true,
                    )
                    .await;
            }
        }
        let _ = ScheduleReminderModel::mark_sent(&ctx.db, reminder.id, now).await;
    }

    Ok(())
}

fn schedule_notify_times(s: &base::models::_entities::schedules::Model) -> Vec<i32> {
    let extra = ScheduleExtra::decode(s.extra.as_slice())
        .unwrap_or_default();
    extra.notify_time
}
