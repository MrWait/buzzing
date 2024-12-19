# 日历业务技术方案 — Part 2: 日程 CRUD 与重复日程

## 1. 概述

本部分覆盖 PRD 中 2.4（日程 CRUD）的全部功能，包括单次日程、全天日程、重复日程（含三维修改模式）。

## 2. 服务端实现

### 2.1 现有分析

| 功能 | 状态 | 问题 |
|------|------|------|
| `schedule_create` | ⚠️ 部分实现 | 权限校验 OK，但 `schedule_gen_by_rule()` 返回空 vec |
| `schedule_update` | ❌ 空实现 | 需补全三维修改模式 |
| `schedule_remove` | ⚠️ 部分实现 | `ScheduleModel::remove()` 返回 `Err`，需补全 |
| `schedule_pull_by_ids` | ⚠️ 部分实现 | `get_by_ids` 返回 `Err` |
| `schedule_pull_by_calendar_ids` | ⚠️ 部分实现 | `find_by_calendar_ids` 返回 `Err` |
| `schedule_pull_busy` | ⚠️ 部分实现 | 查询返回空 |
| `schedule_gen_by_rule` | ❌ 空实现 | 核心函数待实现 |

### 2.2 Proto 变更

`ScheduleUpdateRequest` 中的 `bool with_all` 改为 `int32 modify_scope`：

```protobuf
message ScheduleUpdateRequest {
    entity.Schedule schedule = 1;
    int32 modify_scope = 3; // 0: 仅此, 1: 全部, 2: 以后
}
```

`ScheduleRemoveRequest` 相同改动：

```protobuf
message ScheduleRemoveRequest {
    int64 id = 1;
    int64 cycle_id = 2;
    int32 modify_scope = 3; // 0: 仅此, 1: 全部, 2: 以后
}
```

**兼容性：** 旧客户端 `with_all=true` 对应 `modify_scope=1`（全部），`with_all=false` 对应 `modify_scope=0`（仅此）。

### 2.2a `exception_ids` → `exception_times`

重复日程的例外实例匹配方式由 ID 改为 start_time，避免按需展开时 ID 不连续导致无法匹配：

```protobuf
message ScheduleCycleRule {
    // ...
    repeated int64 exception_ids = 6;  // 改为:
    // repeated int64 exception_times = 6;  // 存例外实例的 start_time
}
```

展开实例时按 `start_time` 比对 `exception_times` 来判断跳过。

### 2.2b 新增 cycleds 表迁移 — 展开窗口字段

```rust
// 在 cycleds 表新增 expand_start / expand_end
manager
    .alter_table(
        Table::alter()
            .table(Cycleds::Table)
            .add_column_if_not_exists(big_integer(Cycleds::ExpandStart).null())
            .add_column_if_not_exists(big_integer(Cycleds::ExpandEnd).null())
            .to_owned(),
    )
    .await?;
```

### 2.2c 新增 `ScheduleDeletePush` 推送类型

批量日程删除不适合走公共 `PushEntityChanged`（无 cycle_rule_id 语义），新增日历专属推送类型：

```protobuf
// proto/calendar.proto

// 服务端→客户端：批量日程删除推送
message ScheduleDeletePush {
    repeated int64 ids = 1;           // 逐个删：实例 ID 列表
    int64 cycle_rule_id = 2;          // 批量删：删除整个 cycled 的所有实例
    int64 start_time = 3;             // 批量删：删除 cycle_rule_id 下 start_time >= 此值的实例
}
```

```protobuf
// proto/command.proto
enum Command {
    // ...
    PUSH_SCHEDULE_DELETE = 1618;
}
```

各系列操作的推送映射：

| 操作 | 推送 |
|------|------|
| 单实例取消 `remove(modify_scope=0)` | `ScheduleDeletePush{ids=[42]}` |
| 全部取消 `remove(modify_scope=1)` | `ScheduleDeletePush{cycle_rule_id=A}` |
| 以后取消 `remove(modify_scope=2)` | `ScheduleDeletePush{cycle_rule_id=A, start_time=T}` |
| 分裂 `update(modify_scope=2)` | `ScheduleDeletePush{cycle_rule_id=A, start_time=T}` + `SchedulePushUpdate` |
| 例外日程修改 `update(modify_scope=0)` | `ScheduleDeletePush{ids=[42]}` + `SchedulePushUpdate` |

### 2.3 重复日程展开算法

**策略变更：** 不再无限制展开所有实例，改用**按需展开 + 有限窗口预展开**。

- 预展开窗口：`[now - 30d, now + 90d]`
- 预展开窗口内实例写入选 `schedules` 表
- cycleds 表记录 `expand_start` / `expand_end` 标记已展开范围
- 查询超出窗口时，按需增量展开
- 例外匹配改为按 `start_time`（`exception_times`），而非实例 ID

```rust
const EXPAND_WINDOW_BEFORE: i64 = 30 * 24 * 3600 * 1000;  // 30 天毫秒
const EXPAND_WINDOW_AFTER: i64  = 90 * 24 * 3600 * 1000;  // 90 天毫秒

/// 按需展开指定时间范围内的实例
/// 输入: template, [expand_from, expand_to)
/// 输出: 展开后的 Schedule 列表
pub fn schedule_expand_range(
    template: &entity::Schedule,
    expand_from: i64,
    expand_to: i64,
) -> Result<Vec<entity::Schedule>> {
    let rule = template.cycle.as_ref().ok_or(Error::string("no cycle rule"))?;
    let cycle = rule.rule.as_ref().ok_or(Error::string("no cycle"))?;

    let start_at = rule.start_at;
    let stop_at = rule.stop_at;
    let exceptions: HashSet<i64> = rule.exception_times.iter().copied().collect();
    let window_end = if stop_at > 0 && stop_at < expand_to { stop_at } else { expand_to };

    let mut instances = Vec::new();
    let mut cursor = start_at.max(expand_from);
    if cursor < start_at { cursor = start_at; }
    let duration = template.end_time - template.start_time;

    // 最多安全限制
    let max_instances = (window_end - cursor) / (24 * 3600 * 1000) + 1;
    let max_instances = max_instances.min(400) as usize;

    while instances.len() < max_instances {
        if cursor >= window_end || (stop_at > 0 && cursor >= stop_at) {
            break;
        }
        if exceptions.contains(&cursor) {
            advance_cursor(&mut cursor, cycle)?;
            continue;
        }
        instances.push(entity::Schedule {
            id: id_gen(None),
            start_time: cursor,
            end_time: cursor + duration,
            cycle_rule_id: template.cycle_rule_id,
            calendar_id: template.calendar_id,
            title: template.title.clone(),
            // ... 继承其他模板字段
            ..Default::default()
        });
        advance_cursor(&mut cursor, cycle)?;
    }
    Ok(instances)
}

/// 创建一个新的重复日程时调用——预展开 120 天窗口
pub fn schedule_expand_initial(template: &entity::Schedule) -> Result<Vec<entity::Schedule>> {
    let now = current_ms();
    let from = now - EXPAND_WINDOW_BEFORE;
    let to   = now + EXPAND_WINDOW_AFTER;
    schedule_expand_range(template, from, to)
}

fn advance_cursor(cursor: &mut i64, rule: &entity::CycleRule) -> Result<()> {
    let cycle_type = rule.cycle_type;
    let seq = rule.seq.max(1) as i64;
    let week_seqs: HashSet<i32> = rule.week_seqs.iter().copied().collect();

    match cycle_type {
        CycleByDay => {
            *cursor += seq * 24 * 60 * 60 * 1000;
        }
        CycleByWeek => {
            let mut dt = DateTime::from_timestamp_millis(*cursor).unwrap();
            loop {
                dt = dt.checked_add_signed(chrono::Duration::days(1)).unwrap();
                let wday = dt.weekday().num_days_from_monday() as i32;
                if week_seqs.contains(&wday) {
                    *cursor = dt.timestamp_millis();
                    break;
                }
            }
        }
        CycleByMonth => {
            let mut dt = DateTime::from_timestamp_millis(*cursor).unwrap();
            let month = dt.month() + seq as u32;
            dt = if month > 12 {
                dt.with_year(dt.year() + 1).unwrap()
                   .with_month(month - 12).unwrap()
            } else {
                dt.with_month(month).unwrap()
            };
            let day = (seq as u32).min(last_day_of_month(dt.year(), dt.month()));
            dt = dt.with_day(day).unwrap();
            *cursor = dt.timestamp_millis();
        }
        _ => {
            *cursor += 30 * 24 * 60 * 60 * 1000;
        }
    }
    Ok(())
}
```

### 2.4 `schedule_create` 补全

```rust
pub(crate) async fn schedule_create(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    // ... 权限校验（已有）...

    let id = id_gen(None);
    let now = current_ms() as i64;
    schedule.id = id;
    schedule.owner = brief.id;
    schedule.tenant_id = brief.tenant_id;
    schedule.version = now;

    // 处理重复日程
    if let Some(ref mut rule) = schedule.cycle {
        rule.id = id;
        rule.calendar_id = schedule.calendar_id;
        rule.version = now;

        // 预展开 120 天窗口
        let now_ms = current_ms();
        let expand_start = now_ms - EXPAND_WINDOW_BEFORE;
        let expand_end   = now_ms + EXPAND_WINDOW_AFTER;

        let instances = schedule_expand_initial(&schedule)?;

        // 保存 cycled 记录（含 expand_start / expand_end）
        CycledModel::create_with_expand(
            &ctx.db, &schedule, expand_start, expand_end,
        ).await?;

        // 展开的实例写入 schedules 表
        ScheduleModel::create(&ctx.db, &instances).await?;
    } else {
        // 单次日程
        ScheduleModel::create(&ctx.db, &[schedule.clone()]).await?;
    }

    // 推送
    let _ = push_schedule_to_users(ctx, &schedule.member_ids, vec![schedule]).await;
    Ok((0, resp.encode_to_vec()))
}
```

### 2.5 `schedule_update` — 三维修改模式

#### 设计思路

```
单次日程（cycle_rule_id == 0）:
  → 直接更新该日程

重复日程：
  modify_scope=0 (仅此):
    → 在 cycleds.exceptions 中添加当前实例 ID
    → 创建一个新的 exception schedule（exception=true）
    → 新 schedule 包含修改后的字段
  modify_scope=1 (全部):
    → 更新 cycled.template 中的字段
    → 清空 cycleds.exceptions（覆盖所有历史例外）
    → 按新 template 重新展开所有实例
    → 删除旧实例，插入新实例
  modify_scope=2 (以后):
    → 分裂 cycled：旧 cycled.stop_at = 当前实例 start_time
    → 新 cycled.start_at = 当前实例 start_time，使用新 template
    → 旧 cycled 的 exceptions 保持不变
```

```rust
pub(crate) async fn schedule_update(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<calendar::ScheduleUpdateRequest>(&packet.payload)?;
    let src = req.schedule.ok_or(Error::string("no schedule"))?;

    // 权限校验
    let calendar = CACHE_CALENDAR.get(ctx, &src.calendar_id).await?;
    let cal = calendar.read().await;
    let my_role = cal.subscribers.subscribers.get(&brief.id)
        .map(|s| s.role).unwrap_or(0);
    if my_role < entity::CalendarRole::RoleEditor as i32 {
        return Ok((ErrorCode::ErrorNoPermision as i32, vec![]));
    }
    drop(cal);

    let modify_scope = req.modify_scope; // 0:仅此 1:全部 2:以后
    let now = current_ms() as i64;

    if src.cycle_rule_id == 0 {
        // 单次日程：直接更新
        ScheduleModel::update(&ctx.db, &src).await?;
    } else if modify_scope == 0 {
        // 仅此次：创建例外日程
        let exception = entity::Schedule {
            id: id_gen(None),
            exception: true,
            cycle_rule_id: src.cycle_rule_id,
            ..src.clone()
        };
        // 在 cycleds.exception_times 中添加原始实例的 start_time
        CycledModel::add_exception_time(&ctx.db, src.cycle_rule_id, src.start_time).await?;
        ScheduleModel::create(&ctx.db, &[exception]).await?;
    } else if modify_scope == 1 {
        // 全部：检测变更类型，决定是否重建
        let old_template = CycledModel::get_template(&ctx.db, src.cycle_rule_id).await?;
        let time_changed = src.start_time != old_template.start_time
            || src.end_time != old_template.end_time
            || src.cycle != old_template.cycle;  // RRULE 变更

        if time_changed {
            // 时间相关字段变更 → DELETE + REINSERT
            CycledModel::update_template(&ctx.db, src.cycle_rule_id, &src, now).await?;
            CycledModel::clear_exception_times(&ctx.db, src.cycle_rule_id).await?;
            ScheduleModel::remove_by_cycle_id(&ctx.db, src.cycle_rule_id).await?;

            let now_ms = current_ms();
            let expand_start = now_ms - EXPAND_WINDOW_BEFORE;
            let expand_end   = now_ms + EXPAND_WINDOW_AFTER;

            let instances = schedule_expand_range(&src, expand_start, expand_end)?;
            ScheduleModel::create(&ctx.db, &instances).await?;
            CycledModel::update_expand_range(&ctx.db, src.cycle_rule_id, expand_start, expand_end).await?;
        } else {
            // 仅 metadata 变更（title/desc/color/location 等）→ 原地 UPDATE
            CycledModel::update_template(&ctx.db, src.cycle_rule_id, &src, now).await?;
            ScheduleModel::update_by_cycle_rule_id(
                &ctx.db, src.cycle_rule_id, &src,
            ).await?;
            // expand 窗口不变，无需重建
        }
    } else if modify_scope == 2 {
        // 以后：分裂 cycled
        let old_cycled = CycledModel::get_by_id(&ctx.db, src.cycle_rule_id).await?;
        CycledModel::update_stop_at(&ctx.db, src.cycle_rule_id, src.start_time).await?;
        CycledModel::update_expand_end(&ctx.db, src.cycle_rule_id, src.start_time).await?;
        // 删除当前及未来实例（保留过去实例）
        ScheduleModel::remove_future_by_cycle(&ctx.db, src.cycle_rule_id, src.start_time).await?;

        let new_id = id_gen(None);
        let now_ms = current_ms();
        let expand_to = (src.start_time + EXPAND_WINDOW_AFTER).min(
            if src.cycle.as_ref().and_then(|r| r.stop_at).unwrap_or(0) > 0 {
                src.cycle.as_ref().unwrap().stop_at
            } else { i64::MAX }
        );
        // 新 cycled 从分裂点开始展开 90 天
        CycledModel::create_split_with_expand(
            &ctx.db, new_id, src.cycle_rule_id, &src, src.start_time, expand_to, now,
        ).await?;

        let mut template = src;
        template.cycle_rule_id = new_id;
        let instances = schedule_expand_range(&template, src.start_time, expand_to)?;
        ScheduleModel::create(&ctx.db, &instances).await?;
    }

    // 推送变更
    let _ = push_schedule_to_users(ctx, &src.member_ids, vec![src]).await;
    let mut resp = calendar::ScheduleUpdateResponse::default();
    Ok((0, resp.encode_to_vec()))
}
```

### 2.6 `schedule_remove` 补全

```rust
pub(crate) async fn schedule_remove(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<calendar::ScheduleRemoveRequest>(&packet.payload)?;

    if req.cycle_id == 0 {
        // 单次日程
        ScheduleModel::remove(&ctx.db, req.id).await?;
    } else if req.modify_scope == 0 {
        // 仅此：标记为 exception（不真正删除）
        CycledModel::add_exception(&ctx.db, req.cycle_id, req.id).await?;
        ScheduleModel::mark_cancelled(&ctx.db, req.id).await?;
    } else if req.modify_scope == 1 {
        // 全部：删除 cycled 和所有实例
        CycledModel::remove(&ctx.db, req.cycle_id).await?;
        ScheduleModel::remove_by_cycle_id(&ctx.db, req.cycle_id).await?;
    } else if req.modify_scope == 2 {
        // 以后：分裂 + 删除未来
        CycledModel::update_stop_at(&ctx.db, req.cycle_id, req.start_time).await?;
        ScheduleModel::remove_future_by_cycle(&ctx.db, req.cycle_id, req.start_time).await?;
    }

    // 推送
    let mut push = pipeline::PushEntityChanged::default();
    push.changes.push(entity::EntityChange { /* ... */ });
    // 通过 BizGateway 推送
    Ok((0, resp.encode_to_vec()))
}
```

### 2.7 查询展开策略

**策略变更：** 查询仅走 `schedules` 表，不再实时展开 cycled。只有当查询范围超过 cycled 的 `expand_end` / `expand_start` 时，才触发按需增量展开。

### 2.7a 并发展开锁策略

多个客户端同时翻到 `expand_end` 之外的时间范围时，可能重复展开同一个 cycled：

```
Request A: 检查 expand_end → 不足，决定展开
Request B: 检查 expand_end → 不足，决定展开
A: 计算实例 → INSERT → UPDATE expand_end
B: 计算实例 → INSERT → UPDATE expand_end  ❌ 重复
```

**方案：唯一约束 + 双检。**

```sql
-- DB 层兜底：防止重复行
CREATE UNIQUE INDEX idx_schedules_cycle_start
  ON schedules(cycle_rule_id, start_time);
```

```rust
// 双检：写前重新读 expand_end
let instances = schedule_expand_range(&template, need_start, need_end)?;
if instances.is_empty() {
    continue;
}

// 双检：如果有其他请求已推进 expand_end，丢弃本次结果
let recheck = CycledModel::get_by_id(&ctx.db, cycled.id).await?;
if recheck.expand_end.unwrap_or(0) >= need_end {
    continue;
}

ScheduleModel::create_or_ignore(&ctx.db, &instances).await?;
// ON CONFLICT (cycle_rule_id, start_time) DO NOTHING
// 极端并发下重复 INSERT 被静默忽略

CycledModel::update_expand_range(
    &ctx.db, cycled.id, expand_start, need_end,
).await?;
```

双检消除绝大多数并发浪费，唯一约束作为 DB 层安全网保证数据零重复。

```rust
pub(crate) async fn schedule_pull_by_calendar_ids(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<calendar::SchedulePullByCalendarIdsRequest>(&packet.payload)?;

    // 1. 查 schedules 表（含已展开的重复日程实例、单次日程、例外日程）
    let mut schedules = ScheduleModel::find_by_calendar_ids_and_range(
        &ctx.db,
        req.calendar_ids.clone(),
        req.start_time,
        req.end_time,
    ).await?;

    // 2. 检查是否有 cycled 的展开窗口未覆盖查询范围 → 按需展开
    let cycleds = CycledModel::find_active_by_calendar_ids(
        &ctx.db,
        req.calendar_ids.clone(),
    ).await?;

    for cycled in cycleds {
        let expand_end = cycled.expand_end.unwrap_or(0);
        let expand_start = cycled.expand_start.unwrap_or(0);

        if req.start_time >= expand_start && req.end_time <= expand_end {
            continue; // 已覆盖，跳过
        }

        // 按需展开缺失范围
        let template = cycled.template_as_schedule();
        let need_start = req.start_time.min(expand_start);
        let need_end   = req.end_time.max(expand_end);

        let instances = schedule_expand_range(
            &template, need_start, need_end,
        )?;

        if !instances.is_empty() {
            ScheduleModel::create(&ctx.db, &instances).await?;
            // 更新展开窗口
            CycledModel::update_expand_range(
                &ctx.db, cycled.id, need_start, need_end.max(expand_end),
            ).await?;
        }

        // 过滤出查询范围内的实例加入结果
        for inst in instances {
            if inst.start_time < req.end_time && inst.end_time > req.start_time {
                schedules.push(inst);
            }
        }
    }

    Ok((0, resp.encode_to_vec()))
}
```

### 2.8 数据库 Model 补全

**ScheduleModel 需补全的方法：**

```rust
impl ScheduleModel {
    // 已存在但返回 Err
    pub async fn remove(db: &DatabaseConnection, id: i64) -> ModelResult<Model> { /* ... */ }
    pub async fn get_by_ids(db: &DatabaseConnection, ids: Vec<i64>) -> ModelResult<Vec<Model>> { /* ... */ }
    pub async fn get_by_cycle_id(db: &DatabaseConnection, id: i64) -> ModelResult<Vec<Model>> { /* ... */ }
    pub async fn remove_by_cycle_id(db: &DatabaseConnection, id: i64) -> ModelResult<Vec<Model>> { /* ... */ }

    // 新增
    pub async fn update(db: &DatabaseConnection, schedule: &entity::Schedule) -> ModelResult<()> { /* ... */ }

    /// 批量更新同一 cycled 下所有实例的 metadata 字段（title/desc/color/location 等）
    /// 不更新时间相关字段（start_time/end_time），避免重建实例
    pub async fn update_by_cycle_rule_id(
        db: &DatabaseConnection, cycle_rule_id: i64, template: &entity::Schedule,
    ) -> ModelResult<()> {
        // UPDATE schedules SET
        //   title = ?, desc = ?, color = ?, location = ?,
        //   notify_time = ?, version = ?
        // WHERE cycle_rule_id = ?
    }

    pub async fn find_by_calendar_ids_and_range(/* ... */) -> ModelResult<Vec<Model>> { /* ... */ }
    pub async fn remove_future_by_cycle(db: &DatabaseConnection, cycle_id: i64, from_time: i64) -> ModelResult<()> { /* ... */ }
    pub async fn mark_cancelled(db: &DatabaseConnection, id: i64) -> ModelResult<()> { /* ... */ }
}
```

**CycledModel 需补全的方法：**

```rust
impl CycledModel {
    pub async fn create_with_expand(
        db: &DatabaseConnection, template: &entity::Schedule,
        expand_start: i64, expand_end: i64,
    ) -> ModelResult<Model> { /* 写入 expand_start/expand_end */ }

    pub async fn get_by_id(db: &DatabaseConnection, id: i64) -> ModelResult<Model> { /* ... */ }
    pub async fn remove(db: &DatabaseConnection, id: i64) -> ModelResult<()> { /* ... */ }

    pub async fn update_template(
        db: &DatabaseConnection, id: i64, schedule: &entity::Schedule, version: i64,
    ) -> ModelResult<()> { /* ... */ }

    pub async fn update_expand_range(
        db: &DatabaseConnection, id: i64, expand_start: i64, expand_end: i64,
    ) -> ModelResult<()> { /* ... */ }

    pub async fn update_expand_end(
        db: &DatabaseConnection, id: i64, expand_end: i64,
    ) -> ModelResult<()> { /* ... */ }

    // exception_ids → exception_times（按 start_time）
    pub async fn add_exception_time(
        db: &DatabaseConnection, id: i64, exception_start_time: i64,
    ) -> ModelResult<()> { /* 追加到 Exceptions 数组 */ }

    pub async fn clear_exception_times(
        db: &DatabaseConnection, id: i64,
    ) -> ModelResult<()> { /* 清空 Exceptions 数组 */ }

    pub async fn update_stop_at(
        db: &DatabaseConnection, id: i64, stop_at: i64,
    ) -> ModelResult<()> { /* ... */ }

    pub async fn create_split_with_expand(
        db: &DatabaseConnection, new_id: i64, old_id: i64,
        template: &entity::Schedule, start_at: i64, expand_end: i64, version: i64,
    ) -> ModelResult<()> { /* ... */ }

    /// 查询指定 calendar_ids 下所有 active cycled（不含 expand_end < start_time 的已过期）
    pub async fn find_active_by_calendar_ids(
        db: &DatabaseConnection, calendar_ids: Vec<i64>,
    ) -> ModelResult<Vec<Model>> { /* ... */ }

    pub fn template_as_schedule(&self) -> entity::Schedule { /* 从 Template 列反序列化 */ }
}
```

## 3. SDK 实现

### 3.1 现有方法补全

SDK 侧大部分方法已实现为 `common_request` 透传，需补全：

```rust
// schedule_pull_by_ids 返回空，需补全
pub async fn schedule_pull_by_ids(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
    let req = calendar::SchedulePullByIdsRequest::decode(param)?;
    let ack = common_request::<calendar::SchedulePullByIdsResponse>(
        Command::SchedulePullByIds as i32,
        req.encode_to_vec(), None,
    ).await?;
    Ok((0, ack.encode_to_vec()))
}

// schedule_pull_by_calendar_ids 返回空，需补全
pub async fn schedule_pull_by_calendar_ids(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
    let req = calendar::SchedulePullByCalendarIdsRequest::decode(param)?;
    let ack = common_request::<calendar::SchedulePullByCalendarIdsResponse>(
        Command::SchedulePullByCalendarIds as i32,
        req.encode_to_vec(), None,
    ).await?;
    Ok((0, ack.encode_to_vec()))
}
```

### 3.2 本地缓存

SDK 本地缓存日程数据用于离线查看：

```rust
// database/schedule.rs

// 批量保存日程（全量替换）
pub fn schedule_batch_save(conn: &Connection, schedules: &[entity::Schedule]) -> Result<()> {
    // BEGIN
    // DELETE FROM schedules WHERE calendar_id IN (?)
    // 遍历 INSERT OR REPLACE
    // COMMIT
}

// 按时间范围查询本地日程
pub fn schedule_get_by_range(conn: &Connection, calendar_ids: &[i64], start: i64, end: i64) -> Result<Vec<entity::Schedule>> {
    // SELECT * FROM schedules
    // WHERE calendar_id IN (?) AND start_time < ? AND end_time > ?
    // ORDER BY start_time
}

// 删除日程（收到推送后）
pub fn schedule_remove_local(conn: &Connection, id: i64) -> Result<()> {
    // DELETE FROM schedules WHERE id = ?
}
```

### 3.3 `handle_push_schedule_update` 补全

```rust
pub async fn handle_push_schedule_update(&self, param: &[u8]) -> Result<()> {
    let push = calendar::SchedulePushUpdateRequest::decode(param)?;
    debug!("handle push schedule update, count: {}", push.schedules.len());
    let db = self.db.inner()?;
    database::schedule::schedule_batch_save(&db, &push.schedules)?;
    let _ = ffi_push(Command::SchedulePushUpdate as i32, param.to_vec());
    Ok(())
}
```

### 3.4 `handle_push_schedule_delete` 新增

```rust
pub async fn handle_push_schedule_delete(&self, param: &[u8]) -> Result<()> {
    let push = calendar::ScheduleDeletePush::decode(param)?;
    let db = self.db.inner()?;
    if push.cycle_rule_id > 0 {
        if push.start_time > 0 {
            database::schedule::schedule_remove_future_by_cycle(&db, push.cycle_rule_id, push.start_time)?;
        } else {
            database::schedule::schedule_remove_by_cycle_rule_id(&db, push.cycle_rule_id)?;
        }
    } else {
        for id in push.ids {
            database::schedule::schedule_remove_local(&db, id)?;
        }
    }
    let _ = ffi_push(Command::PushScheduleDelete as i32, param.to_vec());
    Ok(())
}
```

```rust
// database/schedule.rs 补充
pub fn schedule_remove_by_cycle_rule_id(conn: &Connection, cycle_rule_id: i64) -> Result<()> {
    conn.execute("DELETE FROM schedules WHERE cycle_rule_id = ?1", params![cycle_rule_id])?;
    Ok(())
}

pub fn schedule_remove_future_by_cycle(conn: &Connection, cycle_rule_id: i64, from_time: i64) -> Result<()> {
    conn.execute(
        "DELETE FROM schedules WHERE cycle_rule_id = ?1 AND start_time >= ?2",
        params![cycle_rule_id, from_time],
    )?;
    Ok(())
}
```

## 4. Flutter 客户端实现

### 4.1 日程创建页面

**现有文件：** `buzzing/lib/widget/schedule_creator.dart`

**改造内容：**

```
ScheduleCreator
├── 标题输入框
├── 日历选择器（下拉选择已有日历）
├── 全天日程切换开关
├── 时间选择器
│   ├── 非全天：开始时间 + 结束时间（DateTimePicker）
│   └── 全天：开始日期 + 结束日期
├── 重复规则选择器
│   ├── 不重复
│   ├── 每天
│   ├── 每周（可选择星期几）
│   ├── 每月（可选择日期）
│   ├── 每年
│   └── 自定义（高级选项：间隔、结束条件）
├── 提醒时间选择器（多选）
│   ├── 准时 / 5分钟前 / 10分钟前 / 30分钟前
│   ├── 1小时前 / 2小时前 / 1天前 / 2天前 / 1周前
├── 地点输入框
├── 描述输入框
└── 保存按钮
```

### 4.2 重复规则选择器

```dart
class RecurrencePicker extends StatefulWidget {
  // 返回 CycleRule / ScheduleCycleRule
}

class _RecurrencePickerState extends State<RecurrencePicker> {
  CycleType _cycleType = CycleType.cycleNone;
  int _interval = 1;
  Set<int> _weekDays = {}; // 0=Mon ... 6=Sun
  int? _monthDay;
  RecurrenceEnd _endType = RecurrenceEnd.never;
  DateTime? _endDate;
  int? _endCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 频率下拉选择
        DropdownButton<CycleType>(value: _cycleType, items: [...]),
        // 间隔（仅在非 none 时显示）
        if (_cycleType != CycleType.cycleNone)
          Row(children: [
            Text('每'),
            DropdownButton<int>(value: _interval, items: [1,2,3,...]),
            Text(_cycleType == CycleType.cycleByDay ? '天' : '周'),
          ]),
        // 星期选择（仅在按周时显示）
        if (_cycleType == CycleType.cycleByWeek)
          WeekdaySelector(selected: _weekDays, onChanged: (d) => setState(...)),
        // 结束条件
        if (_cycleType != CycleType.cycleNone)
          RecurrenceEndSelector(...),
      ],
    );
  }
}
```

### 4.3 日程详情/编辑页

```dart
class ScheduleDetailPage extends StatelessWidget {
  final entity.Schedule schedule;

  // 展示日程详情
  // 如果是重复日程：底部显示修改模式选择器
  //   [仅此次] [全部] [以后]
  // 点击保存时传入 modify_scope
}
```

### 4.4 修改模式弹窗

```dart
class ModifyScopeDialog {
  static Future<int?> show(BuildContext context) {
    // 弹出：仅此次 | 全部 | 以后
    // 返回 0/1/2
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('修改重复日程'),
        content: Column(
          children: [
            ListTile(title: Text('仅此次'), onTap: () => Navigator.pop(ctx, 0)),
            ListTile(title: Text('全部'), onTap: () => Navigator.pop(ctx, 1)),
            ListTile(title: Text('以后'), onTap: () => Navigator.pop(ctx, 2)),
          ],
        ),
      ),
    );
  }
}
```

### 4.5 CalendarLogic 日程方法补全

```dart
class CalendarLogic extends GetxController {
  // ... 现有方法

  // 创建日程
  Future<Int64?> createSchedule(entity.Schedule schedule) async {
    var req = ScheduleCreateRequest(schedule: schedule);
    var result = await sdk.invokeAsync(Command.SCHEDULE_CREATE, req.writeToBuffer());
    if (result.data != null) {
      var resp = ScheduleCreateResponse.fromBuffer(result.data!);
      return resp.schedule?.id;
    }
    return null;
  }

  // 更新日程
  Future<bool> updateSchedule(entity.Schedule schedule, {int modifyScope = 0}) async {
    var req = ScheduleUpdateRequest(
      schedule: schedule,
      modifyScope: modifyScope,
    );
    var result = await sdk.invokeAsync(Command.SCHEDULE_UPDATE, req.writeToBuffer());
    return result.data != null;
  }

  // 删除日程
  Future<bool> removeSchedule(Int64 id, {Int64? cycleId, int modifyScope = 0}) async {
    var req = ScheduleRemoveRequest(
      id: id,
      cycleId: cycleId ?? Int64(0),
      modifyScope: modifyScope,
    );
    var result = await sdk.invokeAsync(Command.SCHEDULE_REMOVE, req.writeToBuffer());
    return result.data != null;
  }

  // 拉取日程
  Future<void> fetchSchedules(Int64 startTime, Int64 endTime) async {
    var enabledIds = originCalendarList
        .where((c) => c.enable)
        .map((c) => c.id)
        .toList();
    var req = SchedulePullByCalendarIdsRequest(
      calendarIds: enabledIds,
      startTime: startTime,
      endTime: endTime,
    );
    var result = await sdk.invokeAsync(
      Command.SCHEDULE_PULL_BY_CALENDAR_IDS,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = SchedulePullByCalendarIdsResponse.fromBuffer(result.data!);
      // 更新 eventController 的日程数据
      eventController.calendarData.addEvents(resp.schedules.map(toEvent).toList());
      eventController.updateCalendarData((data) {});
    }
  }
}
```

### 4.6 事件映射

```dart
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

Event toCalendarEvent(entity.Schedule schedule) {
  return Event(
    id: schedule.id.toInt(),
    startTime: DateTime.fromMillisecondsSinceEpoch(schedule.startTime.toInt()),
    endTime: DateTime.fromMillisecondsSinceEpoch(schedule.endTime.toInt()),
    title: schedule.title,
    description: schedule.desc,
    isFullDay: schedule.fullDay,
    color: Color(schedule.color),
    // 额外数据
    extra: {
      'calendar_id': schedule.calendarId,
      'cycle_rule_id': schedule.cycleRuleId,
      'exception': schedule.exception,
      'notify_time': schedule.notifyTime,
    },
  );
}
```

## 5. 数据流

### 5.1 创建重复日程

```
用户填写 → 选择"每周一、三" → 点击保存
  → CalendarLogic.createSchedule(schedule)
  → SDK → 服务端 schedule_create
  → 创建 cycled 记录 (template + rule, expand_start=now-30d, expand_end=now+90d)
  → schedule_expand_initial() 展开 120 天窗口内的实例
  → 批量插入 schedules（~100 条，视间隔而定）
  → 推送 SchedulePushUpdate 给所有参与人
  → 各客户端更新本地缓存 → UI 刷新
```

### 5.2 查询日程（触发按需展开）

```
用户翻到 6 个月后的日期
  → CalendarLogic.fetchSchedules(q_start, q_end)
  → SDK → 服务端 schedule_pull_by_calendar_ids
  → 1) schedules 表直接查 → 未覆盖
  → 2) 检查 cycled: q_end > expand_end → 触发按需展开
  → 3) schedule_expand_range(template, expand_end, q_end)
  → 4) INSERT INTO schedules
  → 5) UPDATE cycled SET expand_end = q_end
  → 6) 合并结果返回
  → 客户端渲染
```

### 5.3 修改重复日程（全部）

```
用户修改标题 → 选择"全部"
  → CalendarLogic.updateSchedule(schedule, modifyScope: 1)
  → SDK → 服务端 schedule_update
  → CycledModel.update_template() 更新模板
  → CycledModel.clear_exception_times() 清空例外
  → 删除 cycled 下所有实例
  → 按 expand 窗口 [now-30d, now+90d] 重新展开
  → 插入新实例 + 更新 expand_start/expand_end
  → 推送给所有参与人
```

### 5.4 修改重复日程（以后）

```
用户修改时间 → 选择"以后"
  → CalendarLogic.updateSchedule(schedule, modifyScope: 2)
  → SDK → 服务端 schedule_update
  → 旧 cycled.stop_at = 分裂点, expand_end = 分裂点
  → 删除旧 cycled 的当前及未来实例（保留过去）
  → 新 cycled: expand_start = 分裂点, expand_end = 分裂点+90d
  → 新 cycled 展开 90 天实例 → INSERT
  → 推送给所有参与人
```

### 5.5 侧拉/刷新（重复打开同一范围）

```
用户今日打开日历
  → schedule_pull_by_calendar_ids(q_start=today, q_end=today+1month)
  → schedules 表直接查到 ~120 条实例
  → expand_start <= today && today+1month <= expand_end → 跳过展开
  → 0 次展开计算, 0 次 cycled 遍历
  → 立即返回
```
