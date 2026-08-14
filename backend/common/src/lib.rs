pub mod asr;
pub mod cache;
pub mod config;
pub mod model;
pub mod presence;
pub mod service;
pub mod text_image;
pub mod translate;

use loco_rs::{Error, Result, model::ModelError};
use rand::Rng;
use serde::Deserialize;
use std::collections::HashSet;
use std::sync::atomic::{AtomicU8, AtomicU16, AtomicU64, Ordering};
use std::sync::{LazyLock, Mutex};
use std::time::{SystemTime, UNIX_EPOCH};

pub use asr::{AsrService, StubAsr, get_asr, init_asr};
pub use cache::{CacheLoader, CommonCache};
pub use entity::{EntityStatus, EntityType, Operate};
pub use model::{PresetColor, UserBrief};
pub use translate::{Language, StubTranslation, TranslateResult, TranslationService, get_translation, init_translation};
pub use presence::PRESENCE_SUBSCRIBERS;
use proto::idl::entity::{self, EntityId};
pub use service::{AppHub, BizHub, SendMode};
pub use service::{BizCalendar, BizGateway, BizIm, BizOffice, BizOpenApp, BizSetting, BizStore, BizUser, ExternApp};
pub use text_image::{extra_name, extra};
pub use time::*;
pub use vecbool::VecBool;

static INC: AtomicU64 = AtomicU64::new(0);
static BASE: AtomicU64 = AtomicU64::new(0);
static LOCK_BASE: LazyLock<Mutex<bool>> = LazyLock::new(|| Mutex::new(false));
static UNION_ID: AtomicU16 = AtomicU16::new(0);
static RID_BASE: AtomicU64 = AtomicU64::new(0);

// 2025-01-01 00:00:00
const SECS_BASE: u64 = 1736553600;

#[derive(PartialEq, Eq, Clone, Copy, Debug, Hash)]
pub enum BizType {
    Im = 1,
    Gateway = 2,
    Setting = 3,
    Calendar = 4,
    Todo = 5,
    Rtc = 6,
    Office = 7,
    User = 8,
    Store = 9,
}

#[derive(Debug, Default, Clone, Deserialize)]
pub struct Settings {
    pub gen_id: Option<bool>,
    pub storage: Option<String>,
    pub union_id: Option<u16>,
    pub client_config: Option<String>,
    pub union_hub: Option<String>,
    pub cert: Option<String>,
    pub cert_key: Option<String>,
    pub turn_secret: Option<String>,
    // pipeline TTL 清理：过期秒数（默认 30 天）与清理周期秒数（默认 24 小时）
    pub pipeline_ttl_seconds: Option<u64>,
    pub pipeline_cleanup_interval_seconds: Option<u64>,
}

#[derive(Debug, Default)]
pub struct UnionSetting {}

#[derive(Debug, Default, Clone)]
pub struct EntityIds {
    pub message_ids: HashSet<i64>,
    pub chat_ids: HashSet<i64>,
    pub feed_ids: HashSet<i64>,
    pub user_ids: HashSet<i64>,
    pub with_feed: bool,
    pub with_message: bool,
    pub broadcast: bool,
}
impl EntityIds {
    pub fn message_ids(&self) -> Vec<i64> {
        self.message_ids.iter().copied().collect()
    }
}

#[derive(Debug, Default)]
pub struct UserEntity {
    pub user_id: i64,
    pub entity_ids: EntityIds,
    pub entity: entity::Entity,
}

pub fn gen_i32() -> i32 {
    let id: i32 = rand::thread_rng().r#gen::<i32>();
    id
}

pub fn set_union_id(id: u16) {
    UNION_ID.store(id, Ordering::SeqCst);
}

// [12 bit, reserved]
// [32 bit, seconds after 2025-01-01]
// [20 bit, 0 ~ 1mb]
pub fn rid() -> i64 {
    let secs = if let Ok(t) = SystemTime::now().duration_since(UNIX_EPOCH) {
        t.as_secs() as u64 - SECS_BASE
    } else {
        0
    };

    let base = RID_BASE.fetch_add(1, Ordering::SeqCst);
    if base > 100_0000 {
        RID_BASE.store(1, Ordering::SeqCst);
    }
    (((secs & 0xFFFFFFFF) << 20) | (base & 0xFFFFF)) as i64
}

// [ 32 bit, seconds after 2025-01-01]
// [ 12 bit, cluster id, 0~4096]
// [ 20 bit, 0~1mb ]
// Some(true): for bot, Some(false): for user
pub fn id_gen(user: Option<bool>) -> i64 {
    let union_id = UNION_ID.load(Ordering::SeqCst);
    let secs = if let Ok(t) = SystemTime::now().duration_since(UNIX_EPOCH) {
        let mut secs = t.as_secs() as u64;
        let mut base = BASE.load(Ordering::SeqCst);
        if base < secs {
            if let Ok(_) = LOCK_BASE.lock() {
                base = BASE.load(Ordering::SeqCst);
                secs = t.as_secs() as u64;
                if base < secs {
                    BASE.store(secs, Ordering::SeqCst);
                }
            }
        }
        secs as u64
    } else {
        0
    };
    let mut inc;

    match user {
        Some(bot) => {
            inc = INC.fetch_add(2, Ordering::SeqCst);
            inc += 2;
            if (inc & 1 == 1) && !bot {
                inc -= 1;
            }

            if (inc & 1 == 0) && bot {
                inc -= 1;
            }
        }
        _ => {
            inc = INC.fetch_add(1, Ordering::SeqCst);
            inc += 1;
        }
    }
    ((((union_id as u64) & 0xFFF) << 52)
        | (((secs - SECS_BASE) & 0xFFFFFFFF) << 20)
        | (inc as u64 & 0xFFFFF)) as i64
}

pub mod time {
    use loco_rs::prelude::DateTimeWithTimeZone;
    use std::time::{SystemTime, UNIX_EPOCH};
    pub fn current_ms() -> u128 {
        SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .and_then(|duration| Ok(duration.as_millis()))
            .unwrap_or(0)
    }

    pub fn current_s() -> u64 {
        SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .and_then(|duration| Ok(duration.as_secs()))
            .unwrap_or(0)
    }

    pub fn date_time(time_ms: i64) -> DateTimeWithTimeZone {
        chrono::DateTime::<chrono::Utc>::from_timestamp_millis(time_ms)
            .unwrap()
            .into()
    }

    pub fn time2day(time_ms: i64) -> i32 {
        (time_ms / (1000 * 3600 * 24)) as i32
    }

    pub fn day2time(day: i32) -> i64 {
        (day as i64) * 1000 * 3600 * 24
    }
}

pub struct Cost<'a> {
    name: &'a str,
    now: std::time::Instant,
}
impl<'a> Cost<'a> {
    pub fn new(name: &'a str) -> Cost<'a> {
        Cost {
            name,
            now: std::time::Instant::now(),
        }
    }
}
impl Drop for Cost<'_> {
    fn drop(&mut self) {
        tracing::debug!(
            "[cost], name: {}  {}",
            self.name,
            self.now.elapsed().as_micros()
        );
    }
}

#[macro_export]
macro_rules! cost {
    ($e:expr) => {
        let __cost = $crate::Cost::new($e);
        scopeguard::defer! { drop(__cost); }
    };
}

#[inline(always)]
pub fn common_error(content: &str) -> Error {
    Error::Message(content.to_string())
}

#[inline(always)]
pub fn db_error(content: &str) -> ModelError {
    ModelError::Message(content.to_string())
}

#[inline]
pub fn peer_pair(id_a: i64, id_b: i64) -> (i64, i64) {
    if id_a > id_b {
        (id_b, id_a)
    } else {
        (id_a, id_b)
    }
}

pub mod lock {
    pub use parking_lot::{MappedMutexGuard, Mutex, MutexGuard, RwLock};
}

#[inline(always)]
pub fn pb_decode<T>(data: &[u8]) -> Result<T>
where
    T: prost::Message + Default,
{
    T::decode(data).map_err(|_| Error::string("parse error"))
}

#[inline(always)]
pub fn pb_default<T>(data: &[u8]) -> T
where
    T: prost::Message + Default,
{
    T::decode(data).ok().unwrap_or_default()
}

pub struct Steper<'a> {
    pub tag: &'a str,
    step: AtomicU8,
}
impl<'a> Steper<'a> {
    pub fn new(tag: &'a str) -> Self {
        Self {
            tag,
            step: AtomicU8::new(0),
        }
    }

    pub fn s(&self) {
        self.step.fetch_add(1, Ordering::Relaxed);
        tracing::debug!("{}, step: {}", self.tag, self.step.load(Ordering::Relaxed));
    }
}
