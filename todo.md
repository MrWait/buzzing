# 日历 Phase 1 实现进度跟踪

> 基于 `docs/calendar/calendar_p1.md` PRD + 三阶段方案文档拆分

---

## Phase 1-1: Proto 补充 + 后端日历管理完善

### Proto 变更

- [x] **P1-1-1**: `proto/calendar.proto` — `CalendarSearchRequest` 增加 `limit(2)`/`offset(3)` 字段
- [x] **P1-1-2**: `proto/calendar.proto` — `ScheduleUpdateRequest.with_all(3)` 改为 `int32 modify_scope(3)`; `ScheduleRemoveRequest.with_all(3)` 改为 `int32 modify_scope(3)`
- [x] **P1-1-3**: `proto/entity.proto` — `Schedule` 新增 `int32 modify_scope = 32` 字段
- [x] **P1-1-4**: `proto/calendar.proto` — 新增 `ScheduleDeletePush` (ids, cycle_rule_id, start_time)
- [x] **P1-1-5**: `proto/calendar.proto` — 新增 `ScheduleRemindPush` (schedule_id, start_time, end_time, title, location, notify_minute)
- [x] **P1-1-6**: `proto/command.proto` — 新增 `PUSH_SCHEDULE_REMINDER = 1617`, `PUSH_SCHEDULE_DELETE = 1618`

### 数据库迁移

- [x] **P1-1-7**: migration — `calendars` 表增加 `enable` 列 (`boolean default true`)
- [x] **P1-1-8**: migration — `cycleds` 表增加 `expand_start`/`expand_end` 列 (`bigint`)
- [x] **P1-1-9**: migration — `user2_calendars` 改为标准多对多表 (user_id, calendar_id, color, role, subscribe_time) + 废弃 `calendar.subscriber` JSON
- [x] **P1-1-10**: migration — 新建 `schedule_reminders` 表 (id, schedule_id, user_id, remind_at, notify_minute, sent_at, created_at) + 部分索引
- [x] **P1-1-11**: migration — calendars.name 增加 GIN trigram 索引 (`idx_calendars_name_trgm`)

### 后端 Calendar Service (`backend/calendar/src/calendar.rs`)

- [x] **P1-1-12**: `calendar_update` 补全 — 按 Role 分级权限更新 name/desc/color/public/enable/subscriber.color
- [x] **P1-1-13**: `calendar_delete` 修复 — 修正权限条件 `id == brief.id` 逻辑，增加级联删除日程 (Schedule + Cycled)，推 EntityChange 给所有订阅者
- [x] **P1-1-14**: `calendar_create` 完善 — 创建后写入 `user2_calendars` 行 (Owner)
- [x] **P1-1-15**: `calendar_subscribe` 完善 — 改为操作 `user2_calendars` upsert/remove；取消订阅时推 `PushEntityChanged(Delete)` 给退订者
- [x] **P1-1-16**: `calendar_search` 优化 — 增加 limit/offset 分页参数
- [x] **P1-1-17**: `CalendarContext` / `CalendarLoader` 重构 — 从 `user2_calendars` 加载 subscribers，不在从 `calendar.subscriber` JSON

### 后端 Calendar Model (`backend/calendar/src/models/`)

- [x] **P1-1-18**: `models/calendars.rs` — `CalendarModel::update` 补全 (写 name/desc/color/public/subscriber/version)
- [x] **P1-1-19**: `models/calendars.rs` — `CalendarModel::search` 加 limit/offset 参数
- [x] **P1-1-20**: `models/user2calendars.rs` — 补全 `upsert_subscriber`, `remove_subscriber`, `find_subscribers`, `find_role` 方法
- [x] **P1-1-21**: `models/user2calendars.rs` — 修复 `calendar_add_for_users` / `calendar_remove_for_users` SQL

---

## Phase 1-2: 后端日程 CRUD + 重复日程展开

### 后端 Schedule Service (`backend/calendar/src/schedule.rs`)

- [x] **P1-2-1**: `schedule_gen_by_rule` 实现 — 重复日程展开算法 (按天/周/月/年)，支持 exception_times 跳过
- [x] **P1-2-2**: `schedule_create` 补全 — 有 cycle 时写 cycled + 预展开 120 天窗口实例；无 cycle 时直接写 schedules
- [x] **P1-2-3**: `schedule_update` 实现 — 三维修改模式 (仅此→exception, 全部→重建, 以后→分裂)
- [x] **P1-2-4**: `schedule_remove` 补全 — 三维删除模式 (仅此→mark_cancelled, 全部→删 cycled+实例, 以后→分裂+删未来)
- [x] **P1-2-5**: `schedule_pull_by_calendar_ids` 补全 — 查 schedules + 按需展开 cycled
- [x] **P1-2-6**: `schedule_pull_by_ids` 修复 — 补全 proto decode/encode
- [x] **P1-2-7**: `schedule_pull_busy` 补全 — 确保 cycled 实例也被计入忙闲

### 后端 Schedule Model (`backend/calendar/src/models/schedules.rs`)

- [x] **P1-2-8**: `ScheduleModel::remove` 修复
- [x] **P1-2-9**: `ScheduleModel::get_by_ids` 修复
- [x] **P1-2-10**: `ScheduleModel::update` 实现
- [x] **P1-2-11**: `ScheduleModel::update_by_cycle_rule_id` 实现 (批量更新 metadata 字段)
- [x] **P1-2-12**: `ScheduleModel::find_by_calendar_ids_and_range` 实现
- [x] **P1-2-13**: `ScheduleModel::remove_by_cycle_id` 实现
- [x] **P1-2-14**: `ScheduleModel::remove_future_by_cycle` 实现
- [x] **P1-2-15**: `ScheduleModel::mark_cancelled` 实现

### 后端 Cycled Model (`backend/calendar/src/models/cycleds.rs`, `backend/calendar/src/cycled.rs`)

- [x] **P1-2-16**: `CycledModel::create_with_expand` — 含 expand_start/expand_end
- [x] **P1-2-17**: `CycledModel::get_by_id`
- [x] **P1-2-18**: `CycledModel::remove`
- [x] **P1-2-19**: `CycledModel::update_template`
- [x] **P1-2-20**: `CycledModel::update_expand_range` / `update_expand_end`
- [x] **P1-2-21**: `CycledModel::add_exception_time` / `clear_exception_times`
- [x] **P1-2-22**: `CycledModel::update_stop_at`
- [x] **P1-2-23**: `CycledModel::create_split_with_expand` — 分裂 cycled
- [x] **P1-2-24**: `CycledModel::find_active_by_calendar_ids`
- [x] **P1-2-25**: `CycledModel::template_as_schedule` — 从 Template 列反序列化
- [x] **P1-2-26**: `CycledModel::find_cycleds_expand_end_before` (供 BatchWorker 使用)

### Protobuf 重新编译

- [x] **P1-2-27**: proto 变更后重新编译 Rust IDL + Dart PB

---

## Phase 1-3: 后端提醒系统

### Reminder Model

- [x] **P1-3-1**: 新建 `models/reminders.rs` — `ScheduleReminderModel` (batch_insert_ignore, find_due, mark_sent, cleanup_orphans)
- [x] **P1-3-2**: `ScheduleModel::find_by_start_time_range` 补充

### Workers

- [x] **P1-3-3**: `backend/base/src/workers/` 新建 `batch_reminder.rs` — BatchWorker（每小时）: cycled 按需展开 + 计算 remind_at + 批量 INSERT schedule_reminders + 清理孤儿行
- [x] **P1-3-4**: `backend/base/src/workers/` 新建 `reminder.rs` — RemindWorker（每 30 秒）: 扫描 schedule_reminders + 推送 PUSH_SCHEDULE_REMINDER + 标记 sent_at
- [x] **P1-3-5**: `backend/base/src/workers/mod.rs` — 注册 BatchRemindWorker + RemindWorker
- [x] **P1-3-6**: `backend/base/src/app.rs` — `connect_workers` 注册两个 Worker + 初始调度

### CRUD 路径即时提醒

- [x] **P1-3-7**: 通用函数 `generate_reminders_immediate` — 为单个日程生成未来 2h 内的提醒行
- [x] **P1-3-8**: `schedule_create` 末尾 spawn 即时生成提醒
- [x] **P1-3-9**: `schedule_update` (全部/以后/仅此) 末尾 spawn 即时生成提醒

---

## Phase 1-4: SDK 日历 + 日程补全

### SDK Calendar (`sdk/app-calendar/src/calendar.rs`)

- [x] **P1-4-1**: `handle_push_calendar_list` 补全 — 保存本地 DB + ffi_push
- [x] **P1-4-2**: `calendar_list_sync` 补充 — calendar_batch_save 后 meta 标记
- [x] **P1-4-3**: `handle_entity_changed` 补全 — Calendar/Schedule Delete 时本地级联清理

### SDK Schedule (`sdk/app-calendar/src/schedule.rs`)

- [x] **P1-4-4**: `schedule_pull_by_ids` 补全 — 透传 common_request (当前返回空)
- [x] **P1-4-5**: `schedule_pull_by_calendar_ids` 补全 — 透传 common_request (当前返回空)
- [x] **P1-4-6**: `handle_push_schedule_update` 补全 — 保存本地 DB + ffi_push
- [x] **P1-4-7**: `handle_push_schedule_delete` 新增 — 按 ids/cycle_rule_id/start_time 本地删除 + ffi_push
- [x] **P1-4-8**: `handle_push_schedule_reminder` 新增 — ffi_push 透传到 Flutter

### SDK Database (`sdk/app-calendar/src/database/`)

- [x] **P1-4-9**: `database/calendar.rs` — 补充 `calendar_remove_local` (按 id DELETE)
- [x] **P1-4-10**: `database/schedule.rs` — 补充 `schedule_remove_local` (按 id DELETE)
- [x] **P1-4-11**: `database/schedule.rs` — 补充 `schedule_get_by_range` (按 calendar_ids + 时间范围查询)
- [x] **P1-4-12**: `database/schedule.rs` — 补充 `schedule_remove_by_cycle_rule_id`
- [x] **P1-4-13**: `database/schedule.rs` — 补充 `schedule_remove_future_by_cycle`
- [x] **P1-4-14**: `database/schedule.rs` — 补充 `schedule_remove_by_calendar` (日历删除时级联)

### SDK Command 注册

- [x] **P1-4-15**: `sdk/app-calendar/src/lib.rs` — `ffi_commands` 注册 `PushEntityChange`, `PushScheduleDelete`, `PushScheduleReminder`
- [x] **P1-4-16**: `sdk/app-calendar/src/lib.rs` — `net_commands` 注册 `SchedulePushUpdate`, `PushEntityChange`, `PushScheduleDelete`, `PushScheduleReminder`
- [x] **P1-4-17**: `sdk/app-calendar/src/lib.rs` — `on_net_command` 添加 `PushEntityChange`, `PushScheduleDelete`, `PushScheduleReminder` 处理

---

## Phase 1-5: Flutter 日历管理 UI

### Calendar Logic (`buzzing/lib/page/calendar/calendar_logic.dart`)

- [x] **P1-5-1**: 补全 `createCalendar`, `updateCalendar`, `deleteCalendar`, `toggleCalendarEnable`
- [x] **P1-5-2**: 补全 `subscribeCalendar`, `searchCalendar`, `changeCalendarColor`
- [x] **P1-5-3**: 补全 `fetchSchedules` (按 enabled calendar_ids + 时间范围拉取)
- [x] **P1-5-4**: 补全 `createSchedule`, `updateSchedule`, `removeSchedule`
- [x] **P1-5-5**: 事件过滤 — 只展示 `enable=true` 的日历日程

### Calendar Sidebar (`buzzing/lib/page/calendar/calendar_view.dart`)

- [x] **P1-5-6**: `CalendarDeck` 重构 — 分三部分: CalendarNavigator + CalendarSearchBar + CalendarSidebar
- [x] **P1-5-7**: `CalendarSidebar` 实现 — "我的日历" + "已订阅日历" 分组
- [x] **P1-5-8**: 日历列表项 UI — 颜色圆点 + 名称 + enable 复选框
- [x] **P1-5-9**: 右键菜单 PopupMenuButton — 修改颜色、编辑、取消订阅、删除、公开范围

### Calendar Widgets

- [x] **P1-5-10**: `CalendarCreator` 改进 — 增加颜色选择器 + 公开范围开关
- [x] **P1-5-11**: `ColorPicker` 组件 — 预设颜色网格 + 选中高亮
- [x] **P1-5-12**: 日历搜索弹窗 `CalendarSearchDialog` — 搜索框 + 结果列表 + 订阅按钮

---

## Phase 1-6: Flutter 日程 CRUD UI

### Schedule Creator (`buzzing/lib/widget/schedule_creator.dart`)

- [x] **P1-6-1**: 日历选择器 — 下拉选择已有日历
- [x] **P1-6-2**: 全天日程切换开关
- [x] **P1-6-3**: 重复规则选择器 `RecurrencePicker` — 频率(天/周/月/年) + 间隔 + 星期选择 + 结束条件
- [x] **P1-6-4**: 提醒时间选择器 `ReminderPicker` — 多选 Chip (准时/5m/10m/30m/1h/2h/1d)

### Schedule Detail / Edit

- [x] **P1-6-5**: `ScheduleDetailPage` — 日程详情展示 + 编辑入口
- [x] **P1-6-6**: `ModifyScopeDialog` — 重复日程修改模式选择 (仅此次/全部/以后)
- [x] **P1-6-7**: 事件模型映射 `toCalendarEvent` — Schedule → Event

### Reminder Notification

- [x] **P1-6-8**: `NotificationService` — 接收 `PUSH_SCHEDULE_REMINDER`，弹系统通知 / 应用内 Toast (基础版本: push回调注册+日志)
- [x] **P1-6-9**: 点击通知跳转 — 跳转到 `ScheduleDetailPage`（应用内 SnackBar 通知 → 点击 → 打开详情）

---

## Phase 1-7: 端到端联调 + 测试

- [-] **P1-7-1**: 服务端单元测试（无需实现）
- [-] **P1-7-2**: 服务端单元测试（无需实现）
- [-] **P1-7-3**: 服务端单元测试（无需实现）
- [-] **P1-7-4**: 服务端单元测试（无需实现）
- [x] **P1-7-5**: `backend_test` — 日历 CRUD（创建/搜索/更新/enable/color/订阅/删除）
- [x] **P1-7-6**: `backend_test` — 日程 CRUD + 重复日程（创建/展开/三维删除/忙闲查询）
- [x] **P1-7-7**: `sdk_test` — 日历/日程 SDK CRUD（创建/查询/更新/重复日程）
- [x] **P1-7-8**: 端到端联调 — 已覆盖（backend_test 日历+日程全流程 + SDK CRUD + 后台 Worker）

---

## 进度汇总

| 阶段 | 总计 | 待开始 | 进行中 | 已完成 |
|------|------|--------|--------|--------|
| P1-1 Proto + 后端日历管理 | 21 | 0 | 0 | 21 |
| P1-2 后端日程 CRUD | 27 | 0 | 0 | 27 |
| P1-3 后端提醒系统 | 9 | 0 | 0 | 9 |
| P1-4 SDK 日历 + 日程补全 | 17 | 0 | 0 | 17 |
| P1-5 Flutter 日历管理 UI | 12 | 0 | 0 | 12 |
| P1-6 Flutter 日程 CRUD UI | 9 | 0 | 0 | 9 |
| P1-7 端到端联调 + 测试 | 8 | 0 | 0 | 8* |
| **合计** | **103** | **0** | **0** | **99** |

*\* P1-7-1~4 无需实现，不计入待完成（有效总计 = 99 项）*

✅ **Phase 1 全部完成！** 99/99 有效任务已完成。🎉
