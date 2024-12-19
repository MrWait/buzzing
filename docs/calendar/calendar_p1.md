# 日历业务功能 PRD — Phase 1

## 1. 概述

### 1.1 目标

对标飞书日历，完善日历业务功能，覆盖日历订阅管理、自建日历、日程 CRUD（含重复日程三维修改模式）、服务端日程提醒。

### 1.2 当前状态

| 模块 | 状态 |
|------|------|
| Proto 定义 | 基础结构已定义（Calendar, Schedule, CycleRule, ScheduleCycleRule），命令枚举已覆盖 CRUD |
| 后端 calendar_create | 已实现，含权限检查 |
| 后端 calendar_delete | 已实现，含权限检查 |
| 后端 calendar_get_list | 已实现，含自动创建默认日历 |
| 后端 calendar_subscribe | 基本实现，支持订阅/取消订阅 |
| 后端 calendar_search | 基本实现 |
| 后端 calendar_update | **未实现** — 返回空 |
| 后端 schedule_create | 部分实现 — 不含重复日程展开 |
| 后端 schedule_update | **未实现** — 返回空 |
| 后端 schedule_remove | 部分实现 — 不含重复日程 |
| 后端 schedule_gen_by_rule | **未实现** — 返回空 vec |
| 后端 Models (schedules) | 大部分方法返回 `Err(ModelError::EntityNotFound)` |
| 后端 提醒机制 | **没有** |
| Flutter 日历 UI | 基础占位，14 个视图文件，展示层委托给 `infinite_calendar_view` |
| Flutter 日历管理 | 基础列表展示，无颜色修改/开关/取消订阅 UI |
| SDK 日历 | 基础结构，完整逻辑待补充 |

---

## 2. 功能需求

### 2.1 日历订阅和管理

#### 2.1.1 功能列表

| 功能 | 描述 | 优先级 |
|------|------|--------|
| 日历列表展示 | 展示用户的日历列表，区分「我的日历」和「已订阅日历」 | P0 |
| 修改日历颜色 | 修改日历在 UI 上的显示颜色 | P0 |
| 开启/关闭日历 | 在日历列表中切换显示/隐藏某个日历的日程 | P0 |
| 取消订阅 | 取消订阅他人创建的日历 | P0 |
| 日历详情编辑 | 修改日历名称、描述、公开范围 | P1 |
| 删除自建日历 | 删除自己创建的日历及日历下所有日程 | P1 |
| 日历权限管理 | 修改订阅者的角色（访客/订阅者/编辑者/管理员） | P2 |

#### 2.1.2 数据模型变更

**`entity.Calendar` proto 已有字段：**

```
id          // 日历 ID
creater     // 创建者
tenant_id   // 租户
version     // 乐观锁
color       // 默认颜色
name        // 名称
desc        // 描述
is_default  // 是否默认日历
public      // 是否公开
enable      // 是否开启显示
subscribers // 订阅者列表
```

**`CalendarSubscribers.Subscriber` proto 已有字段：**
```
id              // 用户 ID
subscribe_time  // 订阅时间
role            // 角色 (Guest/Reader/Editor/Manager/Owner)
color           // 用户自定义日历颜色
```

**✅ 已有模型足够，无需修改 proto。**
**❌ 后端 `calendar_update` 需补全实现，处理 name/desc/color/public/enable 的更新。**

#### 2.1.3 API 接口

| 命令 | 请求 | 响应 | 说明 |
|------|------|------|------|
| `CALENDAR_GET_LIST` | `CalendarGetListRequest` | `CalendarGetListResponse` | 获取用户订阅的全部日历 |
| `CALENDAR_CREATE` | `CalendarCreateRequest` | `CalendarCreateResponse` | 创建自建日历 |
| `CALENDAR_UPDATE` | `CalendarUpdateRequest` | `CalendarUpdateResponse` | **补全实现**：修改颜色、名称、描述、公开范围、开启/关闭 |
| `CALENDAR_DELETE` | `CalendarDeleteRequest` | `CalendarDeleteResponse` | 删除自建日历（仅 Owner） |
| `CALENDAR_SEARCH` | `CalendarSearchRequest` | `CalendarSearchResponse` | 搜索公开日历 |
| `CALENDAR_SUBSCRIBE` | `CalendarSubscribeRequest` | `CalendarSubscribeResponse` | 订阅/取消订阅 |
| `CALENDAR_PUSH_LIST` | `CalendarPushListRequest` | - | 服务端推送日历列表变更 |
| `CALENDAR_PUSH_UPDATE` | `CalendarPushUpdateRequest` | - | 服务端推送日历更新 |

**`calendar_update` 权限规则：**
- `RoleOwner` / `RoleManager`：可修改全部字段（name, desc, color, public）
- `RoleEditor`：不可修改 public、不可删除日历
- 每个订阅者可修改自己的 `color`（个人视图颜色）

#### 2.1.4 交互流程

```
用户侧栏 → 点击日历复选框 toggle enable
  → SdkController.invokeAsync(CALENDAR_UPDATE, Calendar{id, enable=false})
  → 服务端更新 calendars.enable 字段
  → 推送 PUSH_CALENDAR_UPDATE 给所有订阅者
  → 客户端刷新日历列表，隐藏该日历的日程

用户侧栏 → 右键日历 → 修改颜色
  → SdkController.invokeAsync(CALENDAR_UPDATE, Calendar{id, subscribers[me].color=新颜色})
  → 服务端更新 subscribers 中该用户的 color
  → 推送 PUSH_CALENDAR_UPDATE

用户侧栏 → 右键日历 → 取消订阅
  → SdkController.invokeAsync(CALENDAR_SUBSCRIBE, {id, subscribe=false})
  → 服务端从 subscribers 中移除该用户
  → 推送 PUSH_CALENDAR_UPDATE 给剩余订阅者
```

---

### 2.2 支持自建日历

#### 2.2.1 功能描述

用户可以在主日历之外创建多个自定义日历，用于分类管理日程（如：工作日历、家庭日历、个人日历）。

#### 2.2.2 功能列表

| 功能 | 描述 | 优先级 |
|------|------|--------|
| 创建日历 | 输入名称、描述、选择颜色、设置公开范围 | P0 |
| 编辑日历 | 修改名称、描述、颜色、公开范围 | P1 |
| 删除日历 | 删除自建日历及所有日程（仅 Owner） | P0 |

#### 2.2.3 数据模型

当前 `Calendar` proto 已支持 `is_default` 标识，新增日历时设置为 `is_default=false` 即可。无需模型变更。

#### 2.2.4 交互流程

```
用户点击「+ 新建日历」
  → 弹窗：输入名称、描述、颜色、公开范围
  → SdkController.invokeAsync(CALENDAR_CREATE, Calendar{...})
  → 服务端创建，自动将创建者设为 RoleOwner
  → 推送 PUSH_CALENDAR_LIST 给创建者
  → 客户端刷新日历列表
```

---

### 2.3 搜索日历并订阅

#### 2.3.1 功能描述

用户可以通过关键词搜索租户内的公开日历，查看日历详情并订阅。

#### 2.3.2 API

| 命令 | 说明 |
|------|------|
| `CALENDAR_SEARCH` | 按名称关键词搜索公开日历（已有基本实现） |
| `CALENDAR_SUBSCRIBE` | 订阅指定日历（已有基本实现） |

#### 2.3.3 交互流程

```
用户输入搜索关键词
  → SdkController.invokeAsync(CALENDAR_SEARCH, {key: "关键词"})
  → 服务端按 name like '%关键词%' 查询
  → 返回公开日历列表
  → 用户点击「订阅」
  → SdkController.invokeAsync(CALENDAR_SUBSCRIBE, {id, subscribe=true})
  → 服务端添加用户到 subscribers，角色 RoleReader
  → 推送 PUSH_CALENDAR_LIST
```

#### 2.3.4 限制

- 仅搜索 `public=true` 的日历
- 搜索结果限制最多 50 条
- 已订阅的日历可标记 "已订阅" 状态
- 自己的日历不可订阅（已经是成员）

---

### 2.4 日程 CRUD

#### 2.4.1 功能列表

| 功能 | 描述 | 优先级 |
|------|------|--------|
| 创建单次日程 | 标题、时间、地点、描述、参与人、提醒 | P0 |
| 创建全天日程 | 与单次日程相同，但 `full_day=true`，无具体时间 | P0 |
| 创建重复日程 | 支持按天/周/月/年重复，支持结束条件 | P0 |
| 修改单次日程 | 修改标题、时间、地点等 | P0 |
| 修改重复日程（仅此次） | 修改后产生例外日程，与其他实例不同 | P0 |
| 修改重复日程（全部） | 修改后更新所有未来实例 | P0 |
| 修改重复日程（以后） | 修改后更新当前及未来实例，历史不变 | P0 |
| 删除单次日程 | 正常删除 | P0 |
| 删除重复日程（仅此次） | 删除该实例，标记为 exception cancelled | P0 |
| 删除重复日程（全部） | 删除整个重复日程系列 | P0 |
| 删除重复日程（以后） | 删除当前及未来实例，历史保留 | P0 |
| 拉取日程列表 | 按日历 ID + 时间范围拉取 | P0 |
| 拉取忙闲 | 按用户 ID + 时间范围返回忙闲时间段 | P0 |

#### 2.4.2 数据模型

**现有 proto `Schedule` 字段已完整覆盖：**

```
id, calendar_id, type, tenant_id, owner, version
summary_doc_id, room_id, chat_id
cycle_rule_id, start_time, end_time
color, public_permision, member_count
member_view_list, member_invite_other, member_alter_schedule
member_create_summary, member_create_meeting
need_checkin, show_as_idle, exception, full_day
location, archive, desc, title
member_ids (repeated int64)
notify_time (repeated int32, 提前分钟数)
cycle (ScheduleCycleRule)
```

**`CycleRule` proto 已覆盖：**

```
CycleNone = 0
CycleByDay = 1       // 按天
CycleByWeek = 2      // 按周
CycleByMonth = 3     // 按月（日期）
CycleByMonthWeek = 4 // 按月（星期几）
CycleByYear = 5      // 按年
```

**✅ 已有 proto 定义足够。** 需在 `Schedule` 新增一个字段处理重复日程修改模式：

```protobuf
// 新增字段到 Schedule
message Schedule {
  // ...原有字段...

  // 重复日程修改模式，仅客户端使用
  // 0: 仅此次, 1: 全部, 2: 以后
  int32 modify_scope = 32;
}
```

**例外日程处理：**

```
schedule.exception = true 表示该日程是重复日程的例外
exception 实例的 id 由原 cycle_rule_id 关联
删除"仅此次" = 在 cycleds.exceptions 数组中添加该实例 id
修改"仅此次" = 创建一个新 exception schedule，原实例标记为不可见
```

**DB 表 `cycleds` 已有结构：**

```
id, calendar_id, start_at, stop_at, rule (protobuf), exceptions (int64[]), template (protobuf), version, extra
```

- `exceptions` 数组存储已删除/例外的日程 ID 列表
- `rule` 存储 `CycleRule` protobuf 编码
- `template` 存储该重复日程的模板 `Schedule` protobuf 编码

#### 2.4.3 重复日程展开算法

**服务端 `schedule_gen_by_rule()` 需实现：**

```
输入: Schedule (含 cycle 字段)
输出: Vec<Schedule> (展开后的多个日程实例)

算法:
1. 解析 CycleRule，确定频率 (day/week/month/year) 和间隔
2. 从 start_time 开始，按规则逐次生成实例
3. 每个实例继承 template 的 title/desc/location/notify_time 等
4. 遇到 exceptions 列表中的 ID 则跳过
5. 直到 stop_at 或超出查询时间范围为止
6. 返回所有实例

约束:
- 单次展开最多返回 200 个实例
- 一次创建重复日程最多生成 365 个实例（防滥用）
- stop_at 为空则表示永不结束，按时间范围查询时动态展开
```

**查询时展开策略：**
- 查询时传入 `start_time` + `end_time` 查询范围
- 返回该时间范围内所有单次日程 + 重复日程展开的实例
- 展开时过滤 `exceptions` 中的已删除/例外 ID
- 例外日程（`exception=true`）优先于重复规则显示

#### 2.4.4 三维修改模式

| 模式 | 描述 | 实现方式 |
|------|------|----------|
| 仅此次 | 只修改当前实例 | 创建 exception schedule，记录到 cycleds.exceptions |
| 全部 | 修改所有实例（过去+未来） | 更新 schedule template 的字段，version 递增，清空 exceptions |
| 以后 | 修改当前及未来实例 | 当前实例时间点分裂：历史实例保持原 schedule，新 schedule 从当前时间开始生效 |

**`以后`模式的具体实现：**

```
1. 找到该重复日程的 cycled 记录
2. 设置 cycled.stop_at = 当前实例的 start_time（停止旧规则）
3. 创建新的 cycled 记录，start_at = 当前实例的 start_time
4. 新 cycled 使用修改后的 template
5. 旧 cycled 的 exceptions 中已有的历史例外保持不变
```

**`全部`模式的实现：**

```
1. 更新 schedule template 中的字段
2. 清空 cycleds.exceptions（所有历史例外被覆盖）
3. 递增 cycled.version
4. 从 start_at 重新生成所有实例
```

#### 2.4.5 API 补充

| 命令 | 请求 | 改动 |
|------|------|------|
| `SCHEDULE_CREATE` | `ScheduleCreateRequest` | 补全重复日程展开 |
| `SCHEDULE_UPDATE` | `ScheduleUpdateRequest` + `with_all` | 原 `with_all` 不够，需改为 `modify_scope` |
| `SCHEDULE_REMOVE` | `ScheduleRemoveRequest` + `modify_scope` | 原 `with_all` bool 改为 scope |
| `SCHEDULE_PULL_BY_CALENDAR_IDS` | 已有 | 补全查询实现 |

**修改 ScheduleRemoveRequest：**

```protobuf
message ScheduleRemoveRequest {
    int64 id = 1;
    int64 cycle_id = 2;
    // int32 modify_scope = 3; // 0: 仅此, 1: 全部, 2: 以后
    // 复用 with_all:
    // with_all=true  + cycle_id>0 => 删除全部
    // with_all=false + cycle_id>0 => 仅此次
    bool with_all = 3;
}
```

**修改 ScheduleUpdateRequest：**

```protobuf
message ScheduleUpdateRequest {
    entity.Schedule schedule = 1;
    // bool with_all = 3;
    int32 modify_scope = 3; // 0: 仅此, 1: 全部, 2: 以后
}
```

---

### 2.5 日程提醒

#### 2.5.1 功能描述

日程提醒由服务端维护和发起，避免客户端不在线导致漏提醒。提醒通过现有推送管道发送。

#### 2.5.2 数据模型

利用 `Schedule.notify_time` 字段，类型为 `repeated int32`，表示在日程开始前多少分钟提醒。

```
notify_time = [0, 10, 30]  // 表示在日程开始前 0分钟、10分钟、30分钟时各提醒一次
```

支持的时间选项（UI 选择器）：
- 0 分钟（准时）
- 5 分钟
- 10 分钟
- 15 分钟
- 30 分钟
- 1 小时
- 2 小时
- 1 天
- 2 天
- 1 周

#### 2.5.3 服务端提醒实现

**方案：定时扫描 + 推送**

```
┌─────────────────────────────────────────────┐
│               Reminder Worker                 │
│                                               │
│  每 30 秒扫描一次：                            │
│  SELECT * FROM schedules                      │
│  WHERE start_time BETWEEN now AND now+7days   │
│    AND notify_time IS NOT NULL                │
│                                               │
│  对每个日程，检查是否有未发送的提醒：           │
│  当前时间 + notify_time[i] ≈ start_time       │
│                                               │
│  若匹配则：                                   │
│  1. 生成提醒消息 PushNotice                    │
│  2. 通过 BizGateway 推送给所有 member_ids     │
│  3. 记录到提醒发送表（防重复）                 │
└─────────────────────────────────────────────┘
```

**提醒去重方案 — 新建 `reminder_logs` 表：**

```
reminder_logs:
  id          PK
  schedule_id 日程 ID
  notify_min  提醒提前分钟数 (0/10/30 等)
  user_id     推送目标
  sent_at     发送时间
  created_at
  
  UNIQUE KEY: (schedule_id, notify_min, user_id)
```

**提醒消息推送：**

使用已有的 `PUSH_NOTICE` 命令（Command=1009），通过 `BizGateway::send_packet_to_user()` 发送。

```protobuf
// PushNotice 消息扩展
message PushNotice {
    int64 schedule_id = 1;
    string title = 2;
    string summary = 3;
    int64 start_time = 4;
    int32 notify_before_minutes = 5;
}
```

**重复日程的提醒展开：**
- 重复日程不展开存入 schedules 表，但提醒时需展开计算
- 对于 `cycle_rule_id > 0` 的日程，Reminder Worker 需按 cycle_rule 展开实例
- 展开后判断当前时间是否匹配某个实例的 `start_time - notify_time[i]`
- 展开范围：从当前时间到当前时间 + 7天
- 限制：最多展开 365 个实例（与创建时一致）

#### 2.5.4 提醒触发流程

```
Reminder Worker (后台任务)
  ↓
扫描 schedules + cycleds
  ↓
展开重复日程实例（时间范围内）
  ↓
检查 remind_logs 表去重
  ↓
生成 PushNotice
  ↓
BizGateway::send_packet_to_user()
  ↓
WebSocket / Pipeline → 客户端
  ↓
客户端处理：显示通知弹窗 / 系统通知
```

#### 2.5.5 配置项

```toml
[reminder]
scan_interval_sec = 30        # 扫描间隔
scan_window_days = 7          # 扫描提前天数
max_instances_per_cycle = 365 # 单次重复日程最多展开数
```

---

## 3. 技术实现计划

### 3.1 阶段划分

| 阶段 | 内容 | 工时估计 |
|------|------|----------|
| Phase 1-1 | Proto 补充 + 后端日历管理（update/delete）完善 | 3 天 |
| Phase 1-2 | 后端日程 CRUD 完善 + 重复日程展开算法 | 5 天 |
| Phase 1-3 | 后端提醒系统 | 4 天 |
| Phase 1-4 | 客户端日历管理 UI（列表、颜色、开关、新建、搜索） | 4 天 |
| Phase 1-5 | 客户端日程 CRUD UI + 重复规则选择器 | 5 天 |
| Phase 1-6 | 客户端提醒展示 + 端到端联调 | 3 天 |

### 3.2 Proto 变更清单

| 文件 | 变更 |
|------|------|
| `proto/entity.proto` | `Schedule` 新增 `modify_scope` 字段，`PushNotice` 消息 |
| `proto/calendar.proto` | `ScheduleUpdateRequest` 的 `with_all` → `modify_scope`，`ScheduleRemoveRequest` 保持兼容 |
| `proto/command.proto` | 已有命令足够，无需新增 |

### 3.3 后端变更清单

| 文件 | 变更 |
|------|------|
| `backend/calendar/src/calendar.rs` | 补全 `calendar_update` 实现 |
| `backend/calendar/src/calendar.rs` | `calendar_delete` 增加级联删除日程 |
| `backend/calendar/src/schedule.rs` | 补全 `schedule_update` 实现（三维修改模式） |
| `backend/calendar/src/schedule.rs` | 补全 `schedule_remove` 实现（重复日程三种模式） |
| `backend/calendar/src/schedule.rs` | 实现 `schedule_gen_by_rule()` |
| `backend/calendar/src/schedule.rs` | 补全 `get_by_ids/find_by_user_ids/find_by_calendar_ids` |
| `backend/calendar/src/models/schedules.rs` | 补全所有 Model 方法实现 |
| `backend/calendar/src/models/cycleds.rs` | 补全 CycledModel 方法 |
| `backend/calendar/src/models/calendars.rs` | 补全 `update` 方法 |
| `backend/calendar/src/reminder.rs` | **新建** — 提醒 Worker |
| `backend/base/src/app.rs` | 注册 Reminder Worker |
| `backend/common/src/service.rs` | 新增 `PushNotice` 相关推送方法 |
| `backend/migration/src/` | 新建 `m2025xxxx_xxxxxx_reminder_logs.rs` |

### 3.4 SDK 变更清单

| 文件 | 变更 |
|------|------|
| `sdk/app-calendar/src/` | 补全所有日历命令的本地处理 |
| `sdk/app-network/src/` | 处理 `PUSH_NOTICE` 推送 |

### 3.5 客户端变更清单

| 文件 | 变更 |
|------|------|
| `buzzing/lib/page/calendar/calendar_view.dart` | 改造侧栏日历列表（颜色标识、复选框开关、右键菜单） |
| `buzzing/lib/page/calendar/calendar_logic.dart` | 补全日历管理逻辑（创建、搜索、订阅、修改颜色） |
| `buzzing/lib/widget/calendar_creator.dart` | 改进创建日历 UI |
| `buzzing/lib/widget/schedule_creator.dart` | 改进创建日程 UI（支持重复规则、提醒时间、全天切換） |
| `buzzing/lib/page/calendar/` | 新增日程编辑页（含重复日程三维修改模式选择） |
| `buzzing/lib/controller/sdk_controller.dart` | 处理 `PUSH_NOTICE` |
| 新增文件 | 日历搜索弹窗、日历设置页、日程详情页 |

---

## 4. 非功能需求

### 4.1 性能

- 日程列表查询（按时间范围）响应时间 < 200ms（单用户单日历）
- 重复日程展开单次 < 50ms
- 提醒扫描频率 30s 一次，单次扫描 < 5s

### 4.2 安全

- 日历操作校验：仅 `RoleOwner`/`RoleManager` 可删除日历和修改公开范围
- 日程操作校验：`RoleEditor` 及以上可创建日程
- 日历搜索仅返回 `public=true` 的日历

### 4.3 兼容性

- Proto 变更向前兼容（新增字段使用 optional）
- `ScheduleUpdateRequest.with_all` 保持旧代码兼容
- SDK 版本检测，旧版 SDK 不支持的新功能自动降级

---

## 5. 附录

### 5.1 飞书日历角色对照

| 角色 | 权限 |
|------|------|
| Owner (5) | 管理日历、删除日历、修改公开范围 |
| Manager (4) | 管理日历、删除日历 |
| Editor (3) | 创建/编辑/删除日程 |
| Reader (2) | 查看日程详情 |
| FreeBusyReader (1) | 仅看忙闲 |
| Guest (0) | 仅订阅 |

### 5.2 重复规则 RRULE 对照

| CycleType | 含义 | 示例 |
|-----------|------|------|
| CycleByDay | 每 N 天 | seq=1 → 每 1 天 |
| CycleByWeek | 每周星期 X | week_seqs=[1,3] → 每周一、三 |
| CycleByMonth | 每月第 N 天 | seq=15 → 每月 15 号 |
| CycleByMonthWeek | 每月第 N 个星期 X | seq=2, week_seqs=[1] → 每月第二个周一 |
| CycleByYear | 每年 | seq=对应日期 |

### 5.3 日程修改模式枚举

```dart
enum ModifyScope {
  thisOnly,  // 仅此次
  all,       // 全部
  future,    // 以后
}
```
