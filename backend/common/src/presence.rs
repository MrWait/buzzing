use dashmap::DashMap;
use std::collections::HashSet;
use std::sync::LazyLock;

/// user_id → set of watcher user_ids
pub static PRESENCE_SUBSCRIBERS: LazyLock<DashMap<i64, HashSet<i64>>> =
    LazyLock::new(|| DashMap::new());
