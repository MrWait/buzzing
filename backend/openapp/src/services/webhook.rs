use hmac::{Hmac, Mac};
use loco_rs::app::AppContext;
use sha2::Sha256;
use tracing::{error, info, warn};

use crate::models::bot::OpenAppBotModel;
use common::current_ms;

type HmacSha256 = Hmac<Sha256>;

/// 事件类型枚举
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum EventType {
    MessageReceive,
    GroupAddedBot,
    GroupRemovedBot,
}

impl EventType {
    pub fn as_str(&self) -> &'static str {
        match self {
            EventType::MessageReceive => "im.message.receive",
            EventType::GroupAddedBot => "im.group.added_bot",
            EventType::GroupRemovedBot => "im.group.removed_bot",
        }
    }

    pub fn from_str(s: &str) -> Option<Self> {
        match s {
            "im.message.receive" => Some(EventType::MessageReceive),
            "im.group.added_bot" => Some(EventType::GroupAddedBot),
            "im.group.removed_bot" => Some(EventType::GroupRemovedBot),
            _ => None,
        }
    }
}

/// 构建事件 payload
pub fn build_event_payload(
    app_id: &str,
    event_type: &str,
    payload: serde_json::Value,
) -> serde_json::Value {
    let seq = rand::random::<u64>();
    serde_json::json!({
        "event_id": generate_event_id(app_id, event_type, seq),
        "app_id": app_id,
        "type": event_type,
        "timestamp": current_ms() as i64,
        "payload": payload,
    })
}

/// 生成事件 ID
pub fn generate_event_id(app_id: &str, event_type: &str, seq: u64) -> String {
    use sha2::Digest;
    let input = format!("{app_id}.{event_type}.{seq}");
    let hash = sha2::Sha256::digest(input.as_bytes());
    let hex_str = hex::encode(&hash[..6]);
    format!("evt_{hex_str}")
}

/// Webhook 签名
pub fn sign_webhook(body: &str, secret: &str, timestamp: i64) -> String {
    let input = format!("{timestamp}.{body}");
    let mut mac = HmacSha256::new_from_slice(secret.as_bytes())
        .expect("HMAC key should be valid");
    mac.update(input.as_bytes());
    let result = mac.finalize();
    let code = hex::encode(result.into_bytes());
    format!("sha256={code}")
}

/// 分发事件到 Bot Webhook
/// 参数：app_id 是 open_apps 的 app_id 字符串（如 "app_xxx"）
pub async fn dispatch_event(
    ctx: &AppContext,
    app_db_id: i64,
    app_id_str: &str,
    event_type: EventType,
    payload: serde_json::Value,
) {
    let bot = match OpenAppBotModel::find_by_app(&ctx.db, app_db_id).await {
        Ok(Some(bot)) => bot,
        Ok(None) => {
            warn!("dispatch_event: bot config not found for app_db_id={app_db_id}");
            return;
        }
        Err(e) => {
            error!("dispatch_event: db error for app_db_id={app_db_id}: {e}");
            return;
        }
    };

    let webhook_url = bot.0.webhook_url.trim().to_string();
    if webhook_url.is_empty() {
        return;
    }

    let event_str = event_type.as_str().to_string();
    if !bot.0.event_types.contains(&event_str) {
        return;
    }

    let event_json = build_event_payload(app_id_str, &event_str, payload);
    let body = serde_json::to_string(&event_json).unwrap_or_default();
    let timestamp = current_ms() as i64;
    let signature = sign_webhook(&body, &bot.0.webhook_secret, timestamp);

    let retry_delays = [5u64, 30, 300];
    let client = reqwest::Client::builder()
        .timeout(std::time::Duration::from_secs(10))
        .build()
        .unwrap_or_default();

    for (attempt, delay) in retry_delays.iter().enumerate() {
        match client
            .post(&webhook_url)
            .header("Content-Type", "application/json")
            .header("X-Buzzing-Signature", &signature)
            .header("X-Buzzing-Timestamp", timestamp.to_string())
            .body(body.clone())
            .send()
            .await
        {
            Ok(resp) if resp.status().is_success() => {
                info!(
                    "webhook dispatched: app_id={app_db_id}, event={event_str}, attempt={}, status={}",
                    attempt + 1,
                    resp.status()
                );
                return;
            }
            Ok(resp) => {
                warn!(
                    "webhook non-2xx: app_id={app_db_id}, event={event_str}, attempt={}, status={}",
                    attempt + 1,
                    resp.status()
                );
            }
            Err(e) => {
                warn!(
                    "webhook send error: app_id={app_db_id}, event={event_str}, attempt={}: {e}",
                    attempt + 1,
                );
            }
        }

        if attempt < retry_delays.len() - 1 {
            tokio::time::sleep(std::time::Duration::from_secs(*delay)).await;
        }
    }

    error!("webhook dispatch failed after all retries: app_id={app_db_id}, event={event_str}");
}

/// 简单 HTTP POST 请求（用于 scheduled task 的 call_webhook 动作）
pub async fn send_http_request(
    url: &str,
    payload: &serde_json::Value,
    secret: &str,
) -> Result<(), reqwest::Error> {
    let body = serde_json::to_string(payload).unwrap_or_default();
    let timestamp = current_ms() as i64;
    let signature = if secret.is_empty() {
        String::new()
    } else {
        sign_webhook(&body, secret, timestamp)
    };

    let client = reqwest::Client::builder()
        .timeout(std::time::Duration::from_secs(10))
        .build()
        .unwrap_or_default();

    let mut req = client
        .post(url)
        .header("Content-Type", "application/json")
        .header("X-Buzzing-Timestamp", timestamp.to_string());
    if !signature.is_empty() {
        req = req.header("X-Buzzing-Signature", signature);
    }
    let resp = req.body(body).send().await?;
    info!(
        "scheduled webhook sent: url={}, status={}",
        url,
        resp.status()
    );
    Ok(())
}
