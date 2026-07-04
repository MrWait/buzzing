# calendar — 日历/日程 CRUD + 重复日程

## 测试目标

验证日历和日程的完整生命周期：创建、查询、搜索、更新、订阅、删除。
验证重复日程的创建、展开、三维删除（仅此/全部/以后）。
验证日程忙闲查询。

## 测试用例

### P1-7-5: 日历 CRUD

#### 1. should get calendar list

- **命令**: `CALENDAR_GET_LIST` (1600)
- **请求**: `CalendarGetListRequest {}`
- **预期**: 返回 `CalendarGetListResponse`，`calendars` 为数组
- **验证点**: 返回码为 0

#### 2. should create a calendar

- **命令**: `CALENDAR_CREATE` (1601)
- **请求**: `CalendarCreateRequest { calendar: { name, desc, color, is_default } }`
- **预期**: 返回 `CalendarCreateResponse`，含创建的日历对象
- **验证点**: 返回的日历 name 与请求一致，id 非零

#### 3. should search calendars

- **命令**: `CALENDAR_SEARCH` (1604)
- **请求**: `CalendarSearchRequest { key: "test-calendar" }`
- **预期**: 返回 `CalendarSearchResponse`，`calendars` 为数组
- **验证点**: 返回码为 0

#### 4. should update a calendar

- **命令**: `CALENDAR_UPDATE` (1602)
- **请求**: `CalendarUpdateRequest { calendar: { id, name, desc } }`
- **预期**: 返回 `CalendarUpdateResponse`，含更新后的日历
- **验证点**: id 与请求一致

#### 5. should toggle calendar enable

- **命令**: `CALENDAR_UPDATE` (1602)
- **请求**: `CalendarUpdateRequest { calendar: { id, enable: false } }` → 再 `{ enable: true }`
- **预期**: 两次均返回成功
- **验证点**: enable 开关正常工作

#### 6. should change calendar color

- **命令**: `CALENDAR_UPDATE` (1602)
- **请求**: `CalendarUpdateRequest { calendar: { id, color: 0xFF3370FF } }`
- **预期**: 返回成功

#### 7. should subscribe/unsubscribe a calendar

- **命令**: `CALENDAR_SUBSCRIBE` (1605)
- **请求**: `CalendarSubscribeRequest { id, subscribe=true/false }`
- **预期**: 订阅和取消订阅均返回成功

### P1-7-6: 日程 CRUD + 重复日程

#### 8. should create a schedule

- **命令**: `SCHEDULE_CREATE` (1610)
- **请求**: `ScheduleCreateRequest { schedule: { calendar_id, title, start_time, end_time } }`
- **预期**: 返回 `ScheduleCreateResponse`，含创建的日程对象
- **验证点**: 返回的 schedule 的 id 非零

#### 9. should pull schedules by calendar IDs

- **命令**: `SCHEDULE_PULL_BY_CALENDAR_IDS` (1614)
- **请求**: `SchedulePullByCalendarIdsRequest { calendar_ids, start_time, end_time }`
- **预期**: 返回 `SchedulePullByCalendarIdsResponse`，`schedules` 为数组
- **验证点**: 能找到刚刚创建的日程

#### 10. should update a schedule (modify_scope=0: this event)

- **命令**: `SCHEDULE_UPDATE` (1612)
- **请求**: `ScheduleUpdateRequest { schedule: { id, calendar_id, title }, modify_scope: 0 }`
- **预期**: 返回 `ScheduleUpdateResponse`，含更新后的日程
- **验证点**: 仅当前实例被修改 (modify_scope=0)

#### 11. should create a recurring schedule (daily, interval 2)

- **命令**: `SCHEDULE_CREATE` (1610)
- **请求**: `ScheduleCreateRequest { schedule: { calendar_id, title, start_time, end_time, cycle: { rule: { cycle_type: 1, seq: 2 } } } }`
- **预期**: 返回成功，重复日程被创建并预展开
- **验证点**: schedule id 非零，后端 cycled 表有对应记录

#### 12. should pull recurring schedules and verify expansion count

- **命令**: `SCHEDULE_PULL_BY_CALENDAR_IDS` (1614)
- **请求**: `SchedulePullByCalendarIdsRequest { calendar_ids, start_time: now, end_time: now + 120d }`
- **预期**: 返回 50+ 个实例（每天隔 2 天 → 120 天窗口展开约 60 个）
- **验证点**: 展开数量足够

#### 13. should remove recurring schedule with modify_scope=1 (all)

- **命令**: `SCHEDULE_REMOVE` (1611)
- **请求**: `ScheduleRemoveRequest { id, modify_scope: 1 }`
- **预期**: 全部删除（cycled + 所有实例）
- **注意**: modify_scope=1 表示全部删除

#### 14. should pull busy schedules

- **命令**: `SCHEDULE_PULL_BUSY` (1615)
- **请求**: `SchedulePullBusyRequest { user_ids: [], start_time, end_time }`
- **预期**: 返回 `SchedulePullBusyResponse`

#### 15. should remove a schedule by id

- **命令**: `SCHEDULE_REMOVE` (1611)
- **请求**: `ScheduleRemoveRequest { id }`
- **预期**: 返回成功

#### 16. should delete the calendar

- **命令**: `CALENDAR_DELETE` (1603)
- **请求**: `CalendarDeleteRequest { id }`
- **预期**: 返回成功

## 约束

- 测试间共享 `createdCalendarId`、`createdScheduleId`、`recurringScheduleId`，严格按顺序执行
- 清理：测试结束时删除创建的日程、重复日程和日历
- 重复日程展开：间隔 2 天，120 天窗口展开约 60 个实例
