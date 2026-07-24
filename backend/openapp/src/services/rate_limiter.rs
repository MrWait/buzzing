use moka::sync::Cache;
use std::sync::LazyLock;
use std::time::Duration;

/// 速率限制器，基于滑动窗口计数器
pub struct RateLimiter {
    cache: Cache<String, u32>,
    max_requests: u32,
    window_secs: u64,
}

impl RateLimiter {
    pub fn new(max_requests: u32, window_secs: u64) -> Self {
        Self {
            cache: Cache::builder()
                .time_to_live(Duration::from_secs(window_secs))
                .build(),
            max_requests,
            window_secs,
        }
    }

    /// 检查是否允许请求
    /// 返回 true = 允许，false = 被限流
    pub fn check(&self, key: &str) -> bool {
        let count = self.cache.get(key).unwrap_or(0);
        if count >= self.max_requests {
            return false;
        }
        self.cache.insert(key.to_string(), count + 1);
        true
    }
}

/// Bot 消息发送限流：每 app 每分钟 60 条
pub static MESSAGE_RATE_LIMITER: LazyLock<RateLimiter> =
    LazyLock::new(|| RateLimiter::new(60, 60));

/// Token 签发限流：每 app 每分钟 10 次
pub static TOKEN_RATE_LIMITER: LazyLock<RateLimiter> =
    LazyLock::new(|| RateLimiter::new(10, 60));
