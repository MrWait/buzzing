# 日历业务技术方案 — Part 3: 日程提醒系统

## 1. 概述

覆盖 PRD 2.5（日程提醒）的全部功能：
- 支持多提醒规则（5 分钟前、10 分钟前、30 分钟前等）
- 服务端主动推送提醒到各终端
- 提醒去重（已提醒的不重复提醒）
- 支撑周期性日程的按实例提醒

## 2. 设计决策

| 选项 | 选择 | 理由 |
|------|------|------|
| 提醒队列生成 | **`schedule_reminders` 专表 + 每小时批处理（BatchWorker）** | 避免 CRUD 路径的写放大；仅生成未来 2 小时内的 remind_at 记录 |
| 提醒扫描 | **每 30 秒查 `schedule_reminders`** | 索引范围扫描，单次 < 1ms |
| 去重方式 | **`schedule_reminders.sent_at`** | 发送后原地 UPDATE sent_at，无需单独去重表 |
| 推送命令 | **新增 `PUSH_SCHEDULE_REMINDER = 1617`** | 独立命令便于客户端处理 |
| cycled 展开 | **BatchWorker 中按需展开** | 每小时展开一次 `expand_end < now+3h` 的 cycled，为提醒预生成实例 |

## 3. 数据库变更

### 3.1 新增 `schedule_reminders` 表（migration）

```rust
// backend/migration/src/m202507xx_xxxxxx_schedule_reminders.rs

#[derive(Iden)]
enum ScheduleReminders {
    Table,
    Id,           // bigint PK
    ScheduleId,   // bigint, schedules.id
    UserId,       // bigint, 被提醒用户
    RemindAt,     // bigint, 计算值: start_time - notify_minute * 60000
    NotifyMinute, // int, notify_time 值（如 10 表示提前 10 分钟）
    SentAt,       // bigint, NULL=待发送, 非NULL=已发送时间戳
    CreatedAt,    // bigint, 行创建时间
}

create table schedule_reminders (
    id bigint primary key,
    schedule_id bigint not null,
    user_id bigint not null,
    remind_at bigint not null,
    notify_minute int not null,
    sent_at bigint,
    created_at bigint not null
);
-- 核心扫描索引：仅索引待发送行
create index idx_remind_at_sent on schedule_reminders(remind_at, sent_at)
    where sent_at is null;
-- 清理用
create index idx_schedule_id on schedule_reminders(schedule_id);
```

### 3.2 `ScheduleExtra` 中 `notify_time` 的存储

已有设计——`ScheduleExtra` 结构体的 `notify_time` 字段（`repeated int32`）序列化存入 `Schedules` 表的 `Extra` 二进制列。

```protobuf
message Schedule {
    // ...
    repeated int32 notify_time = 30;  // 提前分钟数数组
}
```

BatchWorker 读取 `schedules.Extra` 解码出 `notify_time`，计算 `remind_at` 后写入 `schedule_reminders`。提醒扫描只查 `schedule_reminders` 表，完全不碰 `schedules.Extra`。

## 4. 服务端实现

采用两个 Worker 协作：

```
BatchWorker（每小时）     RemindWorker（每 30 秒）
  │                         │
  ├─ cycled 按需展开        ├─ SELECT FROM schedule_reminders
  ├─ 计算 remind_at         │   WHERE remind_at BETWEEN ? AND ?
  ├─ INSERT 到              │     AND sent_at IS NULL
  │  schedule_reminders     ├─ 发送推送
  ├─ 清理过期/孤儿行         ├─ UPDATE sent_at = now
  │                         │
  └──── 写出数据 ──────────→ └──── 读取数据
```

CRUD 路径仅对**未来 2 小时内触发的提醒**做即时写入（spawn 异步任务），避免因 BatchWorker 调度间隔漏通知。超出 2 小时的由 BatchWorker 兜底。写放大从 O(实例×提醒×成员) 降为 O(1×提醒×成员)。

### 4.1 BatchWorker — 每小时生成提醒行

```rust
// backend/base/src/workers/batch_reminder.rs

const MAX_NOTIFY_MINUTES: i64 = 7 * 24 * 60;  // 最大提前 1 周
const BATCH_WINDOW_HOURS: i64 = 2;             // 仅生成未来 2 小时的提醒

pub struct BatchRemindWorker {
    pub ctx: AppContext,
}

#[async_trait]
impl BackgroundWorker<BatchRemindWorkerArgs> for BatchRemindWorker {
    async fn perform(&self, _args: BatchRemindWorkerArgs) -> Result<()> {
        let ctx = &self.ctx;
        let now = current_ms();
        let scan_end = now + (MAX_NOTIFY_MINUTES + BATCH_WINDOW_HOURS * 60) * 60 * 1000;
        let remind_window_end = now + BATCH_WINDOW_HOURS * 3600 * 1000;

        // 1. 按需展开 cycled（expand_end < remind_window_end + buffer）
        let cycleds = CycledModel::find_cycleds_expand_end_before(
            &ctx.db, remind_window_end + EXPAND_WINDOW_AFTER,
        ).await?;
        for cycled in cycleds {
            let template = cycled.template_as_schedule();
            let expand_to = (now + EXPAND_WINDOW_AFTER)
                .min(template.cycle.as_ref().and_then(|r| r.stop_at).unwrap_or(i64::MAX));
            let instances = schedule_expand_range(&template, cycled.expand_end.unwrap_or(now), expand_to)?;
            if !instances.is_empty() {
                ScheduleModel::create(&ctx.db, &instances).await?;
                CycledModel::update_expand_end(&ctx.db, cycled.id, expand_to).await?;
            }
        }

        // 2. 读取日程计算 remind_at
        //    start_time IN [now, scan_end] 的日程
        let schedules = ScheduleModel::find_by_start_time_range(
            &ctx.db, now, scan_end,
        ).await?;

        // 3. 批量 INSERT schedule_reminders
        let mut rows = Vec::new();
        for schedule in &schedules {
            let notify_times: Vec<i32> = schedule.notify_time;  // 从 Extra 解码
            if notify_times.is_empty() { continue; }
            for nmin in &notify_times {
                let remind_at = schedule.start_time - (*nmin as i64 * 60 * 1000);
                if remind_at > remind_window_end { continue; }  // 2h 以外的下次再说
                if remind_at < now - 3600_000 { continue; }     // 已过期的不要
                for user_id in &schedule.member_ids {
                    rows.push((schedule.id, *user_id, remind_at, *nmin));
                }
            }
        }

        // 4. 批量写入（ON CONFLICT DO NOTHING）
        ScheduleReminderModel::batch_insert_ignore(&ctx.db, &rows).await?;

        // 5. 清理孤儿行和被删除日程的行
        ScheduleReminderModel::cleanup_orphans(&ctx.db).await?;

        Ok(())
    }
}
```

### 4.2 RemindWorker — 每 30 秒扫描发送

```rust
// backend/base/src/workers/reminder.rs

const SCAN_WINDOW_SECS: i64 = 15 * 60;  // 扫描未来 15 分钟

pub struct RemindWorker {
    pub ctx: AppContext,
}

#[async_trait]
impl BackgroundWorker<RemindWorkerArgs> for RemindWorker {
    async fn perform(&self, _args: RemindWorkerArgs) -> Result<()> {
        let ctx = &self.ctx;
        let now = current_ms();
        let window_end = now + SCAN_WINDOW_SECS * 1000;

        // 唯一操作：查 schedule_reminders 表
        // 无需解析 Extra、无需展开 cycled
        let rows = ScheduleReminderModel::find_due(
            &ctx.db, now, window_end,
        ).await?;

        for row in rows {
            let rid = id_gen(None);
            let push = calendar::ScheduleRemindPush {
                schedule_id: row.schedule_id,
                start_time: row.start_time,
                end_time: row.end_time,
                title: row.title,
                location: row.location,
                notify_minute: row.notify_minute,
            };
            let biz = BizHub::get()?;
            let _ = biz.gateway.send_packet_to_user(
                ctx, &[row.user_id], rid,
                Command::PushScheduleReminder,
                push.encode_to_vec(), true,
            ).await;

            // 标记已发送
            ScheduleReminderModel::mark_sent(&ctx.db, row.id, now).await?;
        }

        Ok(())
    }
}
```

`find_due` 的 SQL 只需一次索引范围扫描：

```sql
SELECT sr.*, s.title, s.start_time, s.end_time, s.location
FROM schedule_reminders sr
JOIN schedules s ON s.id = sr.schedule_id
WHERE sr.remind_at BETWEEN ? AND ?
  AND sr.sent_at IS NULL;
```

### 4.2a CRUD 路径即时生成提醒

BatchWorker 每小时运行一次，存在最大 **1 小时间隙**。若用户在 BatchWorker 刚结束后创建了一个提醒在 5 分钟后触发的日程，等待 1 小时会漏通知。

**解法：CRUD handler 末尾 spawn 异步任务，即时生成 `remind_at` 在未来 2 小时内触发的提醒行。**

```rust
// backend/calendar/src/schedule.rs

/// 通用函数：为单个日程生成近 2 小时内的提醒行
/// 超出 2 小时的不处理，留给 BatchWorker
pub async fn generate_reminders_immediate(
    ctx: &AppContext, schedule: &entity::Schedule,
) -> Result<()> {
    let now = current_ms();
    let window_end = now + 2 * 3600 * 1000;
    let notify_times: Vec<i32> = schedule.notify_time;  // 从 Extra 解码
    if notify_times.is_empty() { return Ok(()); }

    let mut rows = Vec::new();
    for nmin in &notify_times {
        let remind_at = schedule.start_time - (*nmin as i64 * 60 * 1000);
        if remind_at < now - 60_000 { continue; }       // 已过期
        if remind_at > window_end { continue; }          // 超出 2h → 留给 BatchWorker
        for user_id in &schedule.member_ids {
            rows.push((schedule.id, *user_id, remind_at, *nmin));
        }
    }
    if rows.is_empty() { return Ok(()); }
    ScheduleReminderModel::batch_insert_ignore(&ctx.db, &rows).await?;
    Ok(())
}
```

在 CRUD handler 末尾 spawn：

```rust
// schedule_create 末尾
schedule.id = id;
// ... 写入 DB ...
tokio::spawn({
    let ctx = ctx.clone();
    let s = schedule.clone();
    async move { let _ = generate_reminders_immediate(&ctx, &s).await; }
});

// schedule_update modify_scope=1（全部）末尾
// 旧实例 → BatchWorker 清理孤儿行
// 新实例 → 即时生成近 2h 提醒
tokio::spawn({
    let ctx = ctx.clone();
    let new_schedules = instances.clone();
    async move {
        for s in new_schedules {
            let _ = generate_reminders_immediate(&ctx, &s).await;
        }
    }
});

// schedule_update modify_scope=0（仅此 例外）末尾
tokio::spawn({
    let ctx = ctx.clone();
    let exception = exception.clone();
    async move { let _ = generate_reminders_immediate(&ctx, &exception).await; }
});
```

**删除操作不处理**——被删实例的提醒行由 BatchWorker 的 `cleanup_orphans` 在下次运行时清理。

### 4.3 Worker 注册与调度

```rust
// backend/base/src/app.rs

async fn connect_workers(ctx: &AppContext, queue: &Queue) -> Result<()> {
    queue.register(DownloadWorker::build(ctx)).await?;
    queue.register(BatchRemindWorker::build(ctx)).await?;
    queue.register(RemindWorker::build(ctx)).await?;
    // 初始调度
    queue.push(BatchRemindWorkerArgs {}, Workers::delay(0)).await?;
    queue.push(RemindWorkerArgs {}, Workers::delay(0)).await?;
    Ok(())
}
```

Worker 内部使用自调度实现定时循环：

```rust
#[async_trait]
impl BackgroundWorker<BatchRemindWorkerArgs> for BatchRemindWorker {
    async fn perform(&self, _args: BatchRemindWorkerArgs) -> Result<()> {
        generate_reminder_rows(&self.ctx).await?;
        self.ctx.queue
            .push(BatchRemindWorkerArgs {}, Workers::delay(3600_000))
            .await?;
        Ok(())
    }
}

#[async_trait]
impl BackgroundWorker<RemindWorkerArgs> for RemindWorker {
    async fn perform(&self, _args: RemindWorkerArgs) -> Result<()> {
        scan_and_send(&self.ctx).await?;
        self.ctx.queue
            .push(RemindWorkerArgs {}, Workers::delay(30_000))
            .await?;
        Ok(())
    }
}
```

### 4.4 Model 方法

```rust
// ScheduleReminderModel（新建）

impl ScheduleReminderModel {
    /// 批量写入，重复行忽略
    pub async fn batch_insert_ignore(
        db: &DatabaseConnection,
        rows: &[(i64, i64, i64, i32)],  // (schedule_id, user_id, remind_at, notify_minute)
    ) -> ModelResult<()> {
        // INSERT INTO schedule_reminders (id, schedule_id, user_id, remind_at, notify_minute, created_at)
        // SELECT $1, $2, $3, $4, $5, $6
        // WHERE NOT EXISTS (SELECT 1 FROM schedule_reminders WHERE schedule_id=$2 AND user_id=$3 AND notify_minute=$5)
    }

    /// 查询待发送的提醒行（联表 schedules 取展示字段）
    pub async fn find_due(
        db: &DatabaseConnection,
        now: i64,
        window_end: i64,
    ) -> ModelResult<Vec<RemindDueRow>> {
        // SELECT sr.id, sr.schedule_id, sr.user_id, sr.notify_minute,
        //        s.title, s.start_time, s.end_time, s.location
        // FROM schedule_reminders sr
        // JOIN schedules s ON s.id = sr.schedule_id
        // WHERE sr.remind_at BETWEEN ? AND ?
        //   AND sr.sent_at IS NULL
    }

    pub async fn mark_sent(
        db: &DatabaseConnection,
        id: i64,
        sent_at: i64,
    ) -> ModelResult<()> {
        // UPDATE schedule_reminders SET sent_at = ? WHERE id = ?
    }

    /// 清理孤儿行（被删除日程的记录）和已过期的行
    pub async fn cleanup_orphans(db: &DatabaseConnection) -> ModelResult<()> {
        // DELETE FROM schedule_reminders
        // WHERE schedule_id NOT IN (SELECT id FROM schedules WHERE version > 0)
        //    OR remind_at < ?  -- 已过期未发送的
    }
}

// ScheduleModel 补充

impl ScheduleModel {
    /// 查询 start_time 在时间范围内的日程（含 Extra 列）
    pub async fn find_by_start_time_range(
        db: &DatabaseConnection,
        start: i64,
        end: i64,
    ) -> ModelResult<Vec<entity::Schedule>> {
        // SELECT * FROM schedules
        // WHERE start_time BETWEEN ? AND ?
        //   AND version > 0
        //   AND member_ids IS NOT NULL
    }
}
```

### 4.5 提醒状态维护

CRUD 路径仅做即时生成（近 2h 提醒），超出范围的由 BatchWorker 兜底。删除路径不做任何处理，由 BatchWorker 清理孤儿行。

| 操作 | 即时生成（近 2h） | BatchWorker 兜底 |
|------|------------------|-----------------|
| 创建日程 | ✅ spawn 生成新实例的 reminder | 补充未来 2h 之外的 |
| 更新（全部） | ✅ spawn 生成新实例的 reminder | 清理旧实例的孤儿行 + 补充范围外 |
| 更新（分裂） | ✅ spawn 生成新 cycled 实例的 reminder | 同左 |
| 更新（仅此例外） | ✅ spawn 生成例外实例的 reminder | 补充范围外 |
| 删除（全部） | ❌ | 清理孤儿行 |
| 删除（分裂后） | ❌ | 清理孤儿行 |
| 删除（仅此） | ❌ | 孤儿行清理 + exception_times 跳过 |

## 5. Proto 变更

### 5.1 新增命令

```protobuf
// proto/command.proto

enum Command {
    // ...
    PUSH_SCHEDULE_REMINDER = 1617;
}
```

### 5.2 新增推送消息

```protobuf
// proto/calendar.proto

// 服务端→客户端：日程提醒推送
message ScheduleRemindPush {
    int64 schedule_id = 1;
    int64 start_time = 2;
    int64 end_time = 3;
    string title = 4;
    string location = 5;
    int32 notify_minute = 6; // 提前多少分钟
}
```

## 6. SDK 实现

### 6.1 提醒推送处理

```rust
// sdk/app-calendar/src/reminder.rs

pub async fn handle_push_schedule_reminder(&self, param: &[u8]) -> Result<()> {
    let push = calendar::ScheduleRemindPush::decode(param)?;
    debug!("schedule reminder: id={}, title={}", push.schedule_id, push.title);

    // 通过 FFI 推送给 Flutter 客户端
    let _ = ffi_push(Command::PushScheduleReminder as i32, param.to_vec());
    Ok(())
}
```

### 6.2 注册命令处理

```rust
// sdk/app-calendar/src/lib.rs 或 schedule.rs 中注册

pub fn register_calendar_commands(handler: &mut HandlerMap) {
    handler.register(Command::CalendarCreate as i32, ..., schedule_create);
    // ...
    handler.register(Command::PushScheduleReminder as i32, handle_push_schedule_reminder);
}
```

## 7. Flutter 客户端实现

### 7.1 提醒接收

```dart
// buzzing/lib/service/notification_service.dart

class NotificationService extends GetxService {
  // 注册推送回调
  void register() {
    sdk.onCommand(Command.PUSH_SCHEDULE_REMINDER, (data) {
      final push = ScheduleRemindPush.fromBuffer(data);
      _showNotification(push);
    });
  }

  void _showNotification(ScheduleRemindPush push) {
    // 使用 flutter_local_notifications 或系统级通知
    // 如果 App 在前台，弹内嵌 Toast/Banner
    // 如果 App 在后台，弹系统通知栏
    final title = '日程提醒: ${push.title}';
    final body = '${_formatTime(push.startTime)} ~ ${_formatTime(push.endTime)}';
    if (push.location.isNotEmpty) {
      body += '\n地点: ${push.location}';
    }
    FlutterLocalNotificationsPlugin().show(
      push.scheduleId.toInt(),
      title,
      body,
      notificationDetails,
    );
  }
}
```

### 7.2 点击通知跳转

```dart
// 用户点击通知时跳转到日程详情页
final initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
final initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
  iOS: DarwinInitializationSettings(),
);
FlutterLocalNotificationsPlugin().initialize(
  initializationSettings,
  onDidReceiveNotificationResponse: (response) {
    final scheduleId = int.parse(response.payload!);
    Get.to(() => ScheduleDetailPage(scheduleId: scheduleId));
  },
);
```

### 7.3 日程编辑页的提醒选择器

```dart
// buzzing/lib/widget/schedule_reminder_picker.dart

class ReminderPicker extends StatelessWidget {
  final List<int> selectedMinutes; // 如 [10, 30]
  final ValueChanged<List<int>> onChanged;

  static const options = {
    0: '准时',
    5: '5 分钟前',
    10: '10 分钟前',
    15: '15 分钟前',
    30: '30 分钟前',
    60: '1 小时前',
    120: '2 小时前',
    1440: '1 天前',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: options.entries.map((e) {
        final selected = selectedMinutes.contains(e.key);
        return FilterChip(
          label: Text(e.value),
          selected: selected,
          onSelected: (add) {
            final updated = List<int>.from(selectedMinutes);
            if (add && !selected) {
              updated.add(e.key);
            } else if (!add && selected) {
              updated.remove(e.key);
            }
            if (updated.length <= 5) { // 最多 5 个提醒
              onChanged(updated);
            }
          },
        );
      }).toList(),
    );
  }
}
```

## 8. 数据流

```
即时生成（CRUD 路径 spawn）
  → 创建/修改日程后立即触发
  → 解码 Extra.notify_time → 计算 remind_at
  → 仅未来 2 小时内的 → INSERT INTO schedule_reminders
  → 超出 2h 的不处理

批处理（每小时）
  → cycled 按需展开（expand_end < now+3h 的）
  → SELECT schedules WHERE start_time IN [now, now+max_notify_min+2h]
  → 解码 Extra.notify_time → 计算 remind_at
  → INSERT INTO schedule_reminders (ON CONFLICT DO NOTHING)
  → 清理孤儿行（已过期、被删实例的行）

提醒扫描（每 30 秒）
  → SELECT sr.*, s.title, s.start_time, s.end_time, s.location
      FROM schedule_reminders sr JOIN schedules s
      WHERE sr.remind_at BETWEEN ? AND ?
        AND sr.sent_at IS NULL
  → 对每行：
    → gateway.send_packet_to_user(cmd=PUSH_SCHEDULE_REMINDER)
    → pipeline 表持久化（离线到齐后补发）
    → WS 实时推送
    → UPDATE sr.sent_at = now

客户端收到推送：
  → SDK handle_push_schedule_reminder
  → FFI 通知 Flutter
  → NotificationService._showNotification
  → 系统通知栏 / 应用内 Toast

用户点击通知：
  → onDidReceiveNotificationResponse
  → Get.to(ScheduleDetailPage)
```
