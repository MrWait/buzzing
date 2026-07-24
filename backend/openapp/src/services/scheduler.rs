use std::sync::Arc;

use loco_rs::app::AppContext;
use chrono::Timelike;
use tokio_cron_scheduler::{Job, JobScheduler, JobSchedulerError};
use tracing::{error, info, warn};

use common::BizHub;

use crate::models::scheduled_task::ScheduledTaskModel;

pub struct TaskScheduler {
    sched: Arc<JobScheduler>,
}

impl TaskScheduler {
    pub async fn start(ctx: &AppContext) -> Result<Self, JobSchedulerError> {
        let sched = JobScheduler::new().await?;

        // Load all enabled tasks
        let tasks = match ScheduledTaskModel::find_enabled(&ctx.db).await {
            Ok(t) => t,
            Err(e) => {
                warn!("Failed to load scheduled tasks: {e}");
                Vec::new()
            }
        };

        let ctx_arc = Arc::new(ctx.clone());

        let task_count = tasks.len();
        for task in tasks {
            Self::register_job_inner(&sched, ctx_arc.clone(), task).await;
        }
        sched.start().await?;
        info!("Task scheduler started with {} tasks", task_count);

        Ok(Self {
            sched: Arc::new(sched),
        })
    }

    pub async fn register_job(&self, ctx: &AppContext, task_id: i64) {
        let task = match ScheduledTaskModel::find_by_id(&ctx.db, task_id).await {
            Ok(Some(t)) => t,
            _ => return,
        };
        let ctx_arc = Arc::new(ctx.clone());
        Self::register_job_inner(&self.sched, ctx_arc, task).await;
    }

    async fn register_job_inner(
        sched: &JobScheduler,
        ctx: Arc<AppContext>,
        task: ScheduledTaskModel,
    ) {
        let task_id = task.0.id;
        let cron_expr = task.0.cron_expr.clone();
        let action_type = task.0.action_type.clone();
        let action_config = task.0.action_config.clone();
        let chat_id = task.0.chat_id;
        let app_id = task.0.app_id;

        let jid = match Job::new_async(cron_expr.as_str(), move |_uuid, _lock| {
            let ctx = ctx.clone();
            let action_type = action_type.clone();
            let action_config = action_config.clone();
            Box::pin(async move {
                info!("Executing scheduled task {task_id}: {action_type}");
                match action_type.as_str() {
                    "send_message" => {
                        Self::execute_send_message(&ctx, app_id, chat_id, &action_config).await;
                    }
                    "call_webhook" => {
                        Self::execute_call_webhook(&ctx, &action_config).await;
                    }
                    _ => warn!("Unknown action_type: {action_type}"),
                }

                // Update last_run_at
                let now = chrono::Utc::now();
                if let Err(e) = ScheduledTaskModel::update_next_run(
                    &ctx.db,
                    task_id,
                    now.into(),
                    None,
                )
                .await
                {
                    error!("Failed to update next_run for task {task_id}: {e}");
                }
            })
        }) {
            Ok(j) => {
                if let Err(e) = sched.add(j).await {
                    error!("Failed to add job for task {task_id}: {e}");
                }
            }
            Err(e) => {
                error!("Failed to create job for task {task_id}: {e}");
            }
        };
    }

    pub async fn remove_job(&self, _task_id: i64) {
        // tokio-cron-scheduler doesn't support removing by job id easily
        // For now, we log and rely on next restart to reload
        info!("Job removal requested (reload on restart)");
    }

    async fn execute_send_message(
        ctx: &AppContext,
        app_id: i64,
        chat_id: Option<i64>,
        action_config: &serde_json::Value,
    ) {
        let Some(chat_id) = chat_id else {
            warn!("send_message task requires chat_id");
            return;
        };

        let config = action_config;

        let msg_type_str = config.get("msg_type").and_then(|v| v.as_str()).unwrap_or("text");
        let content = config.get("content").cloned().unwrap_or_default();

        // Replace template variables
        let now = chrono::Local::now();
        let content_str = serde_json::to_string(&content).unwrap_or_default();
        let content_str = content_str
            .replace("{{date}}", &now.format("%Y-%m-%d").to_string())
            .replace("{{time}}", &now.format("%H:%M:%S").to_string())
            .replace("{{weekday}}", &now.format("%A").to_string());

        let msg_type = match msg_type_str {
            "markdown" => 15i32,
            "interactive_card" => 17i32,
            _ => 13i32, // text
        };

        let hub = match BizHub::get() {
            Ok(h) => h,
            Err(_) => {
                warn!("BizHub not available");
                return;
            }
        };

        // Use app's bot user id
        let bot_user_id = match crate::models::bot::OpenAppBotModel::find_by_app(&ctx.db, app_id).await
        {
            Ok(Some(bot)) => bot.0.bot_user_id,
            _ => {
                warn!("Bot user not found for app {app_id}");
                return;
            }
        };

        let brief = common::UserBrief {
            id: bot_user_id,
            pid: String::new(),
            aid: 0,
            tenant_id: 0,
        };

        if let Err(e) = hub
            .im
            .send_message(
                ctx,
                &brief,
                bot_user_id,
                chat_id,
                msg_type,
                content_str.into_bytes(),
                "".to_string(),
            )
            .await
        {
            error!("Failed to send scheduled message: {e}");
        }
    }

    async fn execute_call_webhook(ctx: &AppContext, action_config: &serde_json::Value) {
        use crate::services::webhook;

        let _ = ctx;
        let config = action_config;

        let url = config.get("url").and_then(|v| v.as_str()).unwrap_or("");
        let payload = config.get("payload").cloned().unwrap_or(serde_json::Value::Null);

        if url.is_empty() {
            warn!("call_webhook task missing url");
            return;
        }

        let _ = webhook::send_http_request(url, &payload, "").await;
    }
}
