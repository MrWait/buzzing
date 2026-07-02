# calendar — 日历/日程 CRUD

## 测试目标

验证日历和日程的完整生命周期：创建、查询、搜索、更新、订阅、删除。

## 测试用例

### 1. should get calendar list

- **命令**: `CALENDAR_GET_LIST` (1600)
- **请求**: `CalendarGetListRequest {}`
- **预期**: 返回 `CalendarGetListResponse`，`calendars` 为数组
- **验证点**: 返回码为 0

### 2. should create a calendar

- **命令**: `CALENDAR_CREATE` (1601)
- **请求**: `CalendarCreateRequest { calendar: { name, desc, color, is_default } }`
- **预期**: 返回 `CalendarCreateResponse`，含创建的日历对象
- **验证点**: 返回的日历 name 与请求一致，id 非零

### 3. should search calendars

- **命令**: `CALENDAR_SEARCH` (1604)
- **请求**: `CalendarSearchRequest { key: "test-calendar" }`
- **预期**: 返回 `CalendarSearchResponse`，`calendars` 为数组
- **验证点**: 返回码为 0
- **注意**: 搜索范围为所有可见日历

### 4. should update a calendar

- **命令**: `CALENDAR_UPDATE` (1602)
- **请求**: `CalendarUpdateRequest { calendar: { id, name, desc } }`
- **预期**: 返回空响应（服务端实现未返回更新后的日历对象）
- **验证点**: 返回码为 0
- **⚠️ 已知问题**: 服务端返回 0 字节响应，`calendar` 字段为 null

### 5. should create a schedule

- **命令**: `SCHEDULE_CREATE` (1610)
- **请求**: `ScheduleCreateRequest { schedule: { calendar_id, title, start_time, end_time } }`
- **预期**: 返回 `ScheduleCreateResponse`，含创建的日程对象
- **验证点**: 返回的 schedule 的 id 非零

### 6. should pull schedules by calendar IDs

- **命令**: `SCHEDULE_PULL_BY_CALENDAR_IDS` (1614)
- **请求**: `SchedulePullByCalendarIdsRequest { calendar_ids, start_time, end_time }`
- **预期**: 返回 `SchedulePullByCalendarIdsResponse`，`schedules` 为数组
- **⚠️ 已知问题**: 服务端返回 JSON `{"error":"Bad Request"}` 而非 protobuf

### 7. should update a schedule

- **命令**: `SCHEDULE_UPDATE` (1612)
- **请求**: `ScheduleUpdateRequest { schedule: { id, calendar_id, title }, with_all=false }`
- **预期**: 返回空响应（服务端实现未返回更新后的日程对象）
- **⚠️ 已知问题**: 服务端返回 0 字节响应，`schedule` 字段为 null

### 8. should subscribe/unsubscribe a calendar

- **命令**: `CALENDAR_SUBSCRIBE` (1605)
- **请求**: `CalendarSubscribeRequest { id, subscribe=true/false }`
- **预期**: 订阅和取消订阅均返回成功

### 9. should delete the schedule

- **命令**: `SCHEDULE_REMOVE` (1611)
- **请求**: `ScheduleRemoveRequest { id }`
- **预期**: 返回成功

### 10. should delete the calendar

- **命令**: `CALENDAR_DELETE` (1603)
- **请求**: `CalendarDeleteRequest { id }`
- **预期**: 返回成功

## 约束

- 测试间共享 `createdCalendarId` 和 `createdScheduleId`，严格按顺序执行
- 清理：测试结束时删除创建的日程和日历
- 不测试循环日程（cycle rule）
