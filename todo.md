# 日历模块性能优化清单

## 优先级说明

| 标记 | 含义 |
|------|------|
| 🔴 P0 | 上线前必须修复，否则性能不可接受 |
| 🟠 P1 | 预计成为瓶颈，应在上线前/后一周内优化 |
| 🟡 P2 | 可上线后按需优化 |
| 🔵 P3 | 低优先级，可推迟 |

---

## P0

| # | 问题 | 方案 | 状态 |
|---|------|------|------|
| 1 | **`notify_time` 在 Extra BLOB 中** — 提醒扫描无法用 SQL 索引过滤 `notify_time`，需全表读取 schedules 后再反序列化 Extra 列 | **已设计：** `schedule_reminders` 专表 + BatchWorker（每小时）+ RemindWorker（每 30 秒）；提醒扫描 `remind_at` 索引范围查询，不碰 Extra 列 | ✅ 已设计 |
| 2 | ~~**`schedule_pull_by_calendar_ids` 实时展开 cycled** — 每次客户端请求都实时计算展开，CPU 浪费严重~~ | **已解决：** 按需展开方案，查询直接走 schedules 表；仅 `expand_end` 不足时触发一次展开 | ✅ 已设计 |

## P1

| # | 问题 | 方案 | 状态 |
|---|------|------|------|
| 3 | **`schedule_update` modify_scope=1 全量 DELETE+REINSERT** — 用户频繁编辑（如改颜色反复点保存）触发每次 ~120 条 DELETE+INSERT | **已设计：** 检测 time_changed（start_time/end_time/cycle 变化时重建），否则走 `update_by_cycle_rule_id` 原地 UPDATE metadata 字段 | ✅ 已设计 |
| 4 | **`reminder_logs` 逐条 INSERT + 无清理** — 每个 `(schedule_id, user_id, notify_minute)` 分开执行 SELECT+INSERT；表只增不删无限膨胀 | **已解决：** `reminder_logs` 替换为 `schedule_reminders` + `batch_insert_ignore` + 每小时 `cleanup_orphans` | ✅ 已设计 |

## P2

| # | 问题 | 方案 | 状态 |
|---|------|------|------|
| 5 | **`schedule_expand_range` 每次展开创建新 HashSet + id_gen** — `week_seqs` 和 `exception_times` 每次调用都重建 HashSet；每次实例都调 `id_gen`（含 DB 写入） | `id_gen` 为纯内存操作，非 DB 写入；HashSet ≤7 元素重建可忽略；最坏 400 次调用 ~几十微秒。非瓶颈 | ❌ 不需要 |
| 6 | **`calendar_search` 无索引无分页** — `LIKE '%keyword%'` 全表扫描，无 LIMIT | **已设计：** GIN trgm 索引 + `limit/offset` 分页参数 | ✅ 已设计 |
| 7 | **`calendar_update` subscribers JSON 全量写** — 修改个人颜色重写全部订阅者数据 | **已设计：** `user2_calendars` 改为标准多对多表（每订阅一行），`calendar.subscriber` JSON 废弃，CACHE_CALENDAR 改从 `user2_calendars` 加载 | ✅ 已设计 |

## P3

| # | 问题 | 方案 | 状态 |
|---|------|------|------|
| 8 | **`CACHE_CALENDAR` 读写锁竞争** — `write().await` 阻塞所有读 | 用 RwLock 写时 copy-on-write 或改用 moka 的细粒度失效 | ❌ 待观察 |
| 9 | **空扫描周期浪费** — 凌晨无日程时仍每 30s 执行 SQL | 已由 `schedule_reminders` 专表 + 部分索引消除，空窗口只需 B-tree seek | ❌ 不需要 |
| 10 | **cycled 展开无结束日期时的最大实例限制** — 400 限制在极端高频场景（每秒 1 次）仍可能产生大量实例 | 按需展开天然限制窗口（初始 120 天，增量仅查询范围），最小步长 1 天；400 安全网不会被触及 | ❌ 不需要 |
| 11 | **离线同步方案** — 用 pipeline 承载所有增量变更，重连只 drain pipeline，不做全量拉取 | **已设计：** §6 of Part 1；全量拉取仅限全新安装和 pipeline 数据丢失 | ✅ 已设计 |
| 12 | **pipeline 表无数据过期机制** — `pipelines` 表只增不删，长期运行后无限膨胀，影响离线用户重连时的拉取性能 | 定期清理（删除 `created_at < now - 30d` 或用户已读的旧记录）；或在 pipeline 表加 TTL 过期策略 | ❌ 待设计 |
