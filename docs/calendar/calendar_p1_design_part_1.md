# 日历业务技术方案 — Part 1: 日历管理与搜索订阅

## 1. 概述

本部分覆盖 PRD 中 2.1（日历订阅和管理）、2.2（自建日历）、2.3（搜索日历并订阅）三个功能。

## 2. 服务端实现

### 2.1 现有分析

| 功能 | 状态 | 问题 |
|------|------|------|
| `calendar_create` | ✅ 已实现 | 权限校验完整，但未同步到 `user2_calendars` 表 |
| `calendar_delete` | ⚠️ 有 bug | 条件 `cal.calendar.creator != brief.id || cal.calendar.id == brief.id` 逻辑错误，`id == brief.id` 时误返回 |
| `calendar_get_list` | ✅ 已实现 | 含自动创建默认日历逻辑 |
| `calendar_update` | ❌ 空实现 | 返回 `(0, vec![])`，需要补全 |
| `calendar_search` | ✅ 基本实现 | 按 name 模糊搜索 |
| `calendar_subscribe` | ⚠️ 部分实现 | 更新 subscribers 但未更新 `user2_calendars` |
| `push_calendar_to_users` | ✅ 已实现 | 推送 CalendarPushUpdate |

### 2.2 `calendar_update` 补全

**功能：** 修改日历名称、描述、颜色、公开范围、开启/关闭、更新订阅者个人颜色

**权限校验：**
- `RoleOwner` / `RoleManager`：可修改全部字段（name, desc, color, public）
- `RoleReader` / `RoleGuest`：仅可修改自己的 `subscribers[me].color`

**请求体判断策略：**
Calendar proto 已包含全部字段，通过 version 乐观锁判断变更。请求中的 Calendar 对象只包含有变更的字段：

```rust
pub(crate) async fn calendar_update(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<calendar::CalendarUpdateRequest>(&packet.payload)?;
    let src = req.calendar.ok_or(Error::string("no calendar"))?;

    let cal = CACHE_CALENDAR.get(ctx, &src.id).await?;
    let mut cal = cal.write().await;

    // 权限校验
    let my_role = cal.subscribers.subscribers.get(&brief.id)
        .map(|s| s.role)
        .unwrap_or(0);
    let is_manager = my_role >= entity::CalendarRole::RoleManager as i32;
    let is_owner = my_role >= entity::CalendarRole::RoleOwner as i32;

    // 根据权限应用变更
    if !src.name.is_empty() && is_manager {
        cal.calendar.name = Some(src.name.clone());
    }
    if src.color != 0 && is_manager {
        cal.calendar.color = src.color;
    }
    // public 字段只有 Owner 可修改
    if is_owner {
        cal.calendar.public = src.public;
        cal.calendar.enable = src.enable;
    }
    // 订阅者个人颜色
    if let Some(sub) = cal.subscribers.subscribers.get_mut(&brief.id) {
        sub.color = src.subscribers.as_ref()
            .and_then(|s| s.subscribers.get(&brief.id))
            .map(|s| s.color)
            .unwrap_or(sub.color);
    }

    let now = current_ms() as i64;
    cal.calendar.version = now;

    // 持久化
    CalendarModel::update(&ctx.db, &cal.calendar, &cal.subscribers).await?;

    // 推送变更
    let entity = cal.entity();
    let _ = push_calendar_to_users(ctx, &cal.user_ids(), entity).await;

    let mut resp = calendar::CalendarUpdateResponse::default();
    resp.calendar = Some(cal.entity());
    Ok((0, resp.encode_to_vec()))
}
```

**`CalendarModel::update` 实现：**

```rust
pub async fn update(
    db: &DatabaseConnection,
    model: &Model,
    subscribers: &entity::CalendarSubscribers,
) -> ModelResult<()> {
    ActiveModel {
        id: ActiveValue::set(model.id),
        name: ActiveValue::set(Some(model.name.clone())),
        desc: ActiveValue::set(Some(model.desc.clone())),
        color: ActiveValue::set(model.color),
        public: ActiveValue::set(model.public),
        subscriber: ActiveValue::set(
            serde_json::to_value(&subscribers.subscribers)
                .map_err(|_| ModelError::EntityNotFound)?,
        ),
        version: ActiveValue::set(model.version),
        ..Default::default()
    }
    .update(db)
    .await?;
    Ok(())
}
```

### 2.3 `calendar_delete` 修复

修复 `calendar_delete` 的条件判断：

```rust
// 当前错误逻辑
if cal.calendar.creator != brief.id || cal.calendar.id == brief.id {
    return Ok((ErrorCode::ErrorParamInvalid as i32, ...));
}

// 修正：仅创建者可删除，且不允许删除默认日历
if cal.calendar.id == brief.id {
    return Ok((ErrorCode::ErrorNoPermision as i32, ...)); // 不能删除主日历
}
if cal.calendar.creator != brief.id {
    let role = cal.subscribers.subscribers.get(&brief.id)
        .map(|s| s.role).unwrap_or(0);
    if role < entity::CalendarRole::RoleOwner as i32 {
        return Ok((ErrorCode::ErrorNoPermision as i32, ...));
    }
}
```

同时删除需级联删除该日历下的所有日程和 cycled 记录：

```rust
// 删除日程
ScheduleModel::remove_by_calendar_id(&ctx.db, cal.calendar.id).await?;
// 删除 cycled
CycledModel::remove_by_calendar_id(&ctx.db, cal.calendar.id).await?;
```

### 2.4 `calendar_subscribe` 完善

当前 `calendar_subscribe` 通过写入 `calendar.subscriber` JSON 来管理订阅。规范化后改为操作 `user2_calendars` 行：

```rust
pub(crate) async fn calendar_subscribe(
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<calendar::CalendarSubscribeRequest>(&packet.payload)?;
    let mut resp = calendar::CalendarSubscribeResponse::default();

    // 订阅：校验公开
    if req.subscribe {
        let cal = CACHE_CALENDAR.get(ctx, &req.id).await?;
        let is_public = cal.read().await.calendar.public;
        if !is_public {
            return Ok((ErrorCode::ErrorNoPermision as i32, vec![]));
        }
        // 写 user2_calendars（一行）
        User2CalendarModel::upsert_subscriber(
            &ctx.db, brief.id, req.id,
            PresetColor::rand().into(),
            entity::CalendarRole::RoleGuest as i32,
        ).await?;
    } else {
        // 取消订阅：删除行
        User2CalendarModel::remove_subscriber(
            &ctx.db, brief.id, req.id,
        ).await?;
    }

    // 刷新缓存
    CACHE_CALENDAR.remove(&req.id).await?;

    // 推送变更
    let entity = {
        let cal = CACHE_CALENDAR.get(ctx, &req.id).await?;
        let cal = cal.read().await;
        cal.entity()
    };
    let user_ids = {
        let cal = CACHE_CALENDAR.get(ctx, &req.id).await?;
        cal.read().await.subscriber_ids.clone()
    };
    let _ = push_calendar_to_users(ctx, &user_ids, entity).await;

    Ok((0, resp.encode_to_vec()))
}
```

```rust
// User2CalendarModel 新增方法
impl User2CalendarModel {
    pub async fn upsert_subscriber(...) -> ModelResult<()> {
        // INSERT INTO user2_calendars (user_id, calendar_id, color, role, subscribe_time)
        // VALUES (?, ?, ?, ?, ?)
        // ON CONFLICT (user_id, calendar_id) DO UPDATE SET role = ?, subscribe_time = ?
    }

    pub async fn remove_subscriber(db, user_id, calendar_id) -> ModelResult<()> {
        // DELETE FROM user2_calendars WHERE user_id = ? AND calendar_id = ?
    }

    pub async fn find_subscribers(db, calendar_id) -> ModelResult<HashMap<i64, Subscriber>> {
        // SELECT * FROM user2_calendars WHERE calendar_id = ?
    }

    pub async fn find_role(db, user_id, calendar_id) -> ModelResult<i32> {
        // SELECT role FROM user2_calendars WHERE user_id = ? AND calendar_id = ?
    }
}
```

### 2.5 `calendar_create` 完善

创建日历后向 `user2_calendars` 写入创建者（Owner）的行：

```rust
// 在 calendar_create 末尾补充（替代旧 subscriber JSON 写入）
let _ = User2CalendarModel::upsert_subscriber(
    &ctx.db, brief.id, id,
    PresetColor::rand().into(),
    entity::CalendarRole::RoleOwner as i32,
).await;
```

### 2.6 数据库迁移 — `calendars` 表扩展

```rust
// 新增 migration: 增加 enable 字段
manager
    .alter_table(
        Table::alter()
            .table(Calendars::Table)
            .add_column_if_not_exists(boolean(Calendars::Enable).default(true))
            .to_owned(),
    )
    .await?;
```

### 2.7 `calendar_search` 优化

**问题：** 当前 `LIKE '%keyword%'` 全表扫描、无 LIMIT/OFFSET、数据量大时拖垮 DB。

**优化：GIN trigram 索引 + 分页。**

```sql
-- 1. 启用扩展
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 2. GIN 索引（支持模糊搜索加速）
CREATE INDEX idx_calendars_name_trgm ON calendars USING gin (name gin_trgm_ops);
```

```protobuf
// proto/calendar.proto
message CalendarSearchRequest {
    string key = 1;
    int32 limit = 2;   // 新增，默认 20
    int32 offset = 3;  // 新增
}
```

```rust
// CalendarModel
pub async fn search(
    db: &DatabaseConnection,
    key: &str,
    limit: u64,
    offset: u64,
) -> ModelResult<Vec<Model>> {
    Entity::find()
        .filter(Column::Name.contains(key)) // 触发 trigram 索引
        .limit(limit)
        .offset(offset)
        .all(db)
        .await
        .map_err(|e| ModelError::DbErr(e))
}
```

`pg_trgm` 的 `gin_trgm_ops` 索引对 `LIKE '%keyword%'` 和 `ILIKE` 均可加速，支持中文（按字 trigram）。

### 2.8 数据库迁移 — `user2_calendars` 规范化 + 废弃 `calendar.subscriber`

**问题：** `calendar.subscriber` 聚合 JSON 存所有订阅者信息，改一个人的 `color`/`role` 需重写整个 JSON。`user2_calendars` 同样以 JSON 存储冗余信息，双向写放大。

**方案：将 `user2_calendars` 改为标准多对多表，每订阅一行。**

```sql
-- 新建表（替代旧 user2_calendars + 替代 calendar.subscriber）
CREATE TABLE user2_calendars (
    user_id         BIGINT NOT NULL REFERENCES users(id),
    calendar_id     BIGINT NOT NULL REFERENCES calendars(id),
    color           INT NOT NULL DEFAULT 0,
    role            INT NOT NULL DEFAULT 0,   -- CalendarRole
    subscribe_time  BIGINT NOT NULL,
    PRIMARY KEY (user_id, calendar_id)
);
CREATE INDEX idx_u2c_calendar ON user2_calendars(calendar_id);
```

**`calendar.subscriber` JSON 列废弃**，不再作为订阅者数据源。

**`CACHE_CALENDAR` 加载方式变更：**

```rust
pub struct CalendarContext {
    pub calendar: calendars::Model,
    pub subscribers: HashMap<i64, entity::calendar::Subscriber>,
    pub subscriber_ids: Vec<i64>,
}

struct CalendarLoader;
#[async_trait]
impl CacheLoader<i64, CacheCalendar> for CalendarLoader {
    async fn get(&self, ctx: &AppContext, id: &i64) -> Result<CacheCalendar> {
        let calendar = CalendarModel::get_by_id(&ctx.db, *id).await?
            .ok_or(Error::NotFound)?;
        // 从 user2_calendars 加载订阅者信息
        let subscribers = User2CalendarModel::find_subscribers(
            &ctx.db, *id,
        ).await?;
        let subscriber_ids = subscribers.keys().copied().collect();
        Ok(Arc::new(RwLock::new(CalendarContext {
            calendar,
            subscribers,
            subscriber_ids,
        })))
    }
}
```

**权限校验改为查 user2_calendars：**

```rust
// 原来：
let role = cal.subscribers.subscribers.get(&brief.id).map(|s| s.role);

// 改为：
let role = cal.subscribers.get(&brief.id).map(|s| s.role);

// 或直接查表（缓存 miss 时）：
let role = User2CalendarModel::find_role(&ctx.db, brief.id, calendar_id).await?;
```

## 3. SDK 实现

### 3.1 现有分析

SDK `app-calendar` 中大部分方法已实现为转发到服务端的 `common_request` 模式。需要补全：

| 方法 | 状态 | 改动 |
|------|------|------|
| `calendar_list_sync` | ✅ 已实现 | 无需改动 |
| `calendar_create` | ✅ 已实现 | 需补充本地缓存 |
| `calendar_delete` | ✅ 已实现 | 需补充本地缓存删除 |
| `calendar_get_list` | ✅ 已实现 | 从本地 DB 读取 |
| `calendar_update` | ✅ 已实现 | 需补充本地缓存更新 |
| `calendar_search` | ✅ 已实现 | 直接转发到服务端 |
| `calendar_subscribe` | ✅ 已实现 | 需补充本地缓存更新 |
| `handle_push_calendar` | ✅ 已实现 | 更新本地 DB 后推送到 Flutter |
| `handle_push_calendar_list` | ⚠️ 空实现 | 需补全 |

### 3.2 本地缓存策略

**原则：** 日历列表数据量小（一般 < 50 个），每次收到推送全量替换本地缓存。

```rust
// calendar_save: 插入或更新单个日历
pub fn calendar_save(conn: &Connection, calendar: &entity::Calendar) -> Result<()> {
    // INSERT OR REPLACE INTO calendars (id, name, color, is_default, public, enable, desc, creater, tenant_id, version, subscriber_json)
    // VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11)
}

// calendar_batch_save: 全量替换
pub fn calendar_batch_save(conn: &Connection, calendars: &[entity::Calendar]) -> Result<()> {
    // BEGIN TRANSACTION
    // DELETE FROM calendars
    // 遍历 INSERT
    // COMMIT
}

// calendar_remove: 删除单个日历
pub fn calendar_remove(conn: &Connection, id: i64) -> Result<()> {
    // DELETE FROM calendars WHERE id = ?1
}
```

### 3.3 `handle_push_calendar_list` 补全

```rust
pub async fn handle_push_calendar_list(&self, param: &[u8]) -> Result<()> {
    let push = calendar::CalendarPushListRequest::decode(param)?;
    debug!("handle push calendar list, {push:?}");
    let db = self.db.inner()?;
    database::calendar::calendar_batch_save(&db, &push.calendars)?;
    let _ = ffi_push(Command::CalendarPushList as i32, push.encode_to_vec());
    Ok(())
}
```

## 4. Flutter 客户端实现

### 4.1 日历侧栏重构

**当前文件：** `buzzing/lib/page/calendar/calendar_view.dart`（CalendarDeck + CalendarList）

**改造为三部分：**

```
CalendarDeck
├── CalendarNavigator (日期导航, 已实现)
├── CalendarSearchBar (搜索框, 当前是 TextField)
└── CalendarSidebar (日历列表)
    ├── "我的日历" 分组
    │   ├── 默认日历 (不可取消订阅)
    │   ├── 自建日历 (可编辑/删除)
    │   └── [+ 新建日历] 按钮
    └── "已订阅日历" 分组
        ├── 订阅的日历 (可取消订阅/修改颜色)
        └── [+ 搜索日历] 按钮
```

### 4.2 日历列表项 UI

每个日历项展示：

```
┌────────────────────────────────┐
│ ● [color_dot] 日历名称    [✓]  │  ← 颜色圆点 + 名称 + 启用复选框
│   (右键菜单弹出)                │
└────────────────────────────────┘
```

**右键菜单（PopupMenuButton）：**

| 菜单项 | 显示条件 | 操作 |
|--------|----------|------|
| 修改颜色 | 始终显示 | 打开颜色选择器 |
| 编辑日历 | Owner/Manager | 编辑名称、描述等 |
| 取消订阅 | 非 Owner | 确认后取消订阅 |
| 删除日历 | Owner | 确认后删除 |
| 公开范围 | Owner | 切换 public |

### 4.3 CalendarLogic 补充

```dart
class CalendarLogic extends GetxController {
  // ... 现有字段

  // 日历 CRUD
  Future<void> createCalendar(String name, String desc, int color, bool public) async {
    var req = CalendarCreateRequest(calendar: Calendar(
      name: name,
      desc: desc,
      color: color,
      public: public,
    ));
    var result = await sdk.invokeAsync(Command.CALENDAR_CREATE, req.writeToBuffer());
    if (result.data != null) {
      await refreshCalendarList();
    }
  }

  Future<void> updateCalendar(Calendar calendar) async {
    var req = CalendarUpdateRequest(calendar: calendar);
    var result = await sdk.invokeAsync(Command.CALENDAR_UPDATE, req.writeToBuffer());
  }

  Future<void> deleteCalendar(Int64 id) async {
    var req = CalendarDeleteRequest(id: id);
    var result = await sdk.invokeAsync(Command.CALENDAR_DELETE, req.writeToBuffer());
    if (result.data != null) {
      await refreshCalendarList();
    }
  }

  Future<void> toggleCalendarEnable(Calendar calendar, bool enable) async {
    calendar.enable = enable;
    await updateCalendar(calendar);
  }

  Future<void> subscribeCalendar(Int64 id, bool subscribe) async {
    var req = CalendarSubscribeRequest(id: id, subscribe: subscribe);
    var result = await sdk.invokeAsync(Command.CALENDAR_SUBSCRIBE, req.writeToBuffer());
    if (result.data != null) {
      await refreshCalendarList();
    }
  }

  Future<List<Calendar>> searchCalendar(String key) async {
    var req = CalendarSearchRequest(key: key);
    var result = await sdk.invokeAsync(Command.CALENDAR_SEARCH, req.writeToBuffer());
    if (result.data != null) {
      var resp = CalendarSearchResponse.fromBuffer(result.data!);
      return resp.calendars;
    }
    return [];
  }

  Future<void> changeCalendarColor(Int64 calendarId, int color) async {
    // 更新当前用户的 subscribers.color
    var cal = originCalendarList.firstWhere((c) => c.id == calendarId);
    cal.subscribers.subscribers[sdk.userId]!.color = color;
    await updateCalendar(cal);
  }
}
```

### 4.4 日历创建对话框

**文件：** `buzzing/lib/widget/calendar_creator.dart`（已有）

改进内容：
- 名称输入框（必填）
- 描述输入框（可选）
- 颜色选择器（预设颜色列表 + 自定义）
- 公开范围开关（是否公开）
- 创建按钮

### 4.5 颜色选择器

```dart
class ColorPicker extends StatelessWidget {
  final int selectedColor;
  final ValueChanged<int> onColorChanged;

  // 预设颜色列表（对应飞书默认色板）
  static const colors = [0xFF0000, 0xFF8C00, 0xFFFFD700, 0x00AA00,
                          0x0000FF, 0x8B00FF, 0xFF1493, 0x00CED1];

  // 圆形颜色按钮网格布局
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: colors.map((color) => GestureDetector(
        onTap: () => onColorChanged(color),
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: Color(color),
            shape: BoxShape.circle,
            border: selectedColor == color
                ? Border.all(color: Colors.black, width: 2)
                : null,
          ),
        ),
      )).toList(),
    );
  }
}
```

### 4.6 日历搜索弹窗

```dart
class CalendarSearchDialog extends StatelessWidget {
  final ctl = Get.find<CalendarLogic>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('搜索日历'),
      content: Column(
        children: [
          TextField(
            controller: ctl.calendarSearchInput,
            decoration: InputDecoration(hintText: '输入日历名称'),
            onSubmitted: (value) async {
              var results = await ctl.searchCalendar(value);
              // 展示搜索结果列表
            },
          ),
          // 搜索结果列表：名称 + 创建者 + [已订阅/订阅] 按钮
        ],
      ),
    );
  }
}
```

### 4.7 事件过滤

根据日历的 `enable` 状态，在日程拉取和展示时过滤：

```dart
// calendar_logic.dart
var enabledCalendarIds = originCalendarList
    .where((c) => c.enable)
    .map((c) => c.id)
    .toList();

// 拉取日程时仅拉取启用的日历
var req = SchedulePullByCalendarIdsRequest(
  calendarIds: enabledCalendarIds,
  startTime: startTime,
  endTime: endTime,
);
```

## 5. 数据流

### 5.1 修改日历颜色

```
用户右键 → 选择颜色
  → CalendarLogic.changeCalendarColor(id, color)
  → SdkController.invokeAsync(CALENDAR_UPDATE, Calendar{id, subscribers[me].color})
  → SDK common_request → 服务端 calendar_update
  → 更新 DB subscribers JSON
  → 推送 CalendarPushUpdate 给所有订阅者
  → SDK handle_push_calendar → 更新本地 SQLite
  → ffi_push → Flutter CalendarLogic.onPushCalendarList
  → GetBuilder UI 刷新
```

### 5.2 搜索并订阅日历

```
用户输入关键词 → 点击搜索
  → CalendarLogic.searchCalendar(key)
  → SdkController.invokeAsync(CALENDAR_SEARCH, {key})
  → 服务端 calendar_search → 返回公开日历列表
  → 客户端展示搜索结果
  → 用户点击「订阅」
  → CalendarLogic.subscribeCalendar(id, true)
  → 服务端 calendar_subscribe → 添加订阅者
  → 推送 CalendarPushList 给新订阅者
  → 客户端刷新日历列表
```

## 6. 离线同步

**原则：** 所有日历变更（create/update/delete/subscribe）都以 `pipe=true` 走 `send_packet_to_user`，在 pipeline 表持久化。客户端重连后唯一要做的是 drain pipeline，无需全量同步。

### 6.1 推送覆盖矩阵

| 操作 | 推送命令 | pipe | SDK 处理 |
|------|---------|------|---------|
| `calendar_create` | `CalendarPushUpdate` | ✅ | `calendar_save` (INSERT) |
| `calendar_update` | `CalendarPushUpdate` | ✅ | `calendar_save` (UPDATE) |
| `calendar_delete` | `PushEntityChange` + `EntityType::Calendar` | ✅ | `calendar_remove_local` |
| `calendar_subscribe` | `CalendarPushUpdate`(含更新后 subscribers) | ✅ | `calendar_save` (UPDATE) |

### 6.2 重连协议

```rust
// SDK 重连回调
async fn on_reconnect(&self) -> Result<()> {
    // 唯一一件事：收 pipeline
    let packets = self.pull_pipeline(self.last_sid).await?;
    for p in packets {
        self.dispatch_push(p.cmd, &p.payload).await?;
        // CalendarPushUpdate    → calendar_save (INSERT OR REPLACE)
        // SchedulePushUpdate    → schedule_batch_save
        // ScheduleDeletePush    → schedule_remove_local / batch delete
        // PushEntityChange      → calendar_remove_local
        self.last_sid = p.rid.max(self.last_sid);
    }
    // 不再全量拉取
    Ok(())
}
```

`dispatch_push` 由下层的 `PipelinePullPacket` 命令完成拉取和分发：

```rust
// 客户端→服务端：拉取 pipeline
async fn pull_pipeline(&self, since_sid: i64) -> Result<Vec<entity::Packet>> {
    let req = pipeline::PullPipelineRequest {
        sid: since_sid,
        count: 100,  // 分批拉取
    };
    let (_, data) = common_request(
        Command::PipelinePullPacket as i32,
        req.encode_to_vec(),
        None,
    ).await?;
    let resp = pipeline::PullPipelineResponse::decode(&data)?;
    Ok(resp.packets)
}
```

### 6.3 全量拉取的唯二场景

| 场景 | 触发条件 |
|------|---------|
| 全新安装（首次启动） | SDK 初始化时本地 calendars 表为空 → 调用 `calendar_get_list` 做初始填充 |
| pipeline 数据丢失 | `pipeline_pull` 返回 `gap_detected` 标记 → fallback 全量拉取 |

### 6.4 Push 幂等性

SDK 本地 DB 处理推送时全部使用 `INSERT OR REPLACE`：

```rust
pub fn calendar_save(conn: &Connection, calendar: &entity::Calendar) -> Result<()> {
    conn.execute(
        "INSERT OR REPLACE INTO calendars (id, name, color, ...) VALUES (?1, ?2, ?3, ...)",
        params![calendar.id, calendar.name, calendar.color, ...],
    )?;
    Ok(())
}
```

重连后 pipeline 可能重复送达已推送过的包，`INSERT OR REPLACE` 天然幂等，无需额外去重。
```

### 6.5 日历删除/取消订阅的状态同步

日历删除和取消订阅都需要客户端本地级联清理日历及其日程数据。两者都通过 `PushEntityChanged` 事件通知。

#### 6.5.1 推送分发

| 场景 | 推送方 | 推送内容 | 接收方 |
|------|--------|---------|--------|
| 创建日历 | 服务端 `calendar_create` | `CalendarPushUpdate` | 新订阅者 |
| 删除日历 | 服务端 `calendar_delete` | `PushEntityChanged(Calendar, Delete)` + `(Schedule, Delete)` | 所有订阅者 |
| 更新日历 | 服务端 `calendar_update` | `CalendarPushUpdate` | 所有订阅者 |
| 订阅日历 | 服务端 `calendar_subscribe(true)` | `CalendarPushUpdate` | 所有订阅者（含新订阅者） |
| 取消订阅 | 服务端 `calendar_subscribe(false)` | `CalendarPushUpdate` → 剩余订阅者<br>`PushEntityChanged(Calendar, Delete)` → **退订者** | 分别推送 |
| 多端同步 | SDK `on_reconnect` | drain pipeline | 本用户 |

#### 6.5.2 服务端改动

**`calendar_subscribe(false)` 补充推送：**

```rust
// 推给剩余订阅者
let remaining = calendar.user_ids();
push_calendar_to_users(ctx, &remaining, entity).await;

// 额外推 EntityChange(Calendar, Delete) 给退订者（含离线管道）
let mut push = pipeline::PushEntityChanged::default();
push.changes.push(entity::EntityChange {
    id: req.id,
    r#type: entity::EntityType::Calendar as i32,
    operate: Operate::Delete as i32,
});
let biz = BizHub::get()?;
biz.gateway.send_packet_to_user(
    ctx, &[brief.id], sid,
    Command::PushEntityChange, push.encode_to_vec(), true,
).await?;
```

**`calendar_delete` 补充日程级联删除推送：**

```rust
// 删除日历 + 级联日程
ScheduleModel::remove_by_calendar_id(&ctx.db, cal.calendar.id).await?;
CycledModel::remove_by_calendar_id(&ctx.db, cal.calendar.id).await?;

// 推日程删除给所有订阅者
let mut push = pipeline::PushEntityChanged::default();
push.changes.push(entity::EntityChange {
    id: cal.calendar.id,
    r#type: entity::EntityType::Calendar as i32,
    operate: Operate::Delete as i32,
});
for schedule_id in deleted_schedule_ids {
    push.changes.push(entity::EntityChange {
        id: schedule_id,
        r#type: entity::EntityType::Schedule as i32,
        operate: Operate::Delete as i32,
    });
}
// ... send_packet_to_user
```

#### 6.5.3 SDK 改动

**`handle_entity_changed` 补全：**

```rust
// sdk/app-calendar/src/lib.rs
pub(crate) fn handle_entity_changed(&self, params: &[u8]) -> Result<()> {
    let push = PushEntityChanged::decode(params)?;
    let db = self.db.inner()?;
    for change in push.changes {
        match change.r#type() {
            EntityType::Calendar => {
                if change.operate() == Operate::Delete {
                    database::calendar::calendar_remove_local(&db, change.id)?;
                    database::schedule::schedule_remove_by_calendar(&db, change.id)?;
                    let _ = ffi_push(Command::PushEntityChange as i32, params.to_vec());
                }
            }
            EntityType::Schedule => {
                if change.operate() == Operate::Delete {
                    database::schedule::schedule_remove_local(&db, change.id)?;
                    let _ = ffi_push(Command::PushEntityChange as i32, params.to_vec());
                }
            }
            _ => {}
        }
    }
    Ok(())
}
```

#### 6.5.4 时序示例

**场景：用户 B 离线期间被管理者从日历中移除**

```
T1: 管理者从日历 X 中移除用户 B
  → 服务端更新 subscribers（移除 B）
  → 推 CalendarPushUpdate 给剩余订阅者
  → 推 EntityChange(Calendar, Delete) 给 B（pipe=true → pipeline 表）

T2: 用户 B 重连
  → drain pipeline
  → 收到 EntityChange(Calendar, Delete, calendar_id=X)
  → SDK: calendar_remove_local(X), schedule_remove_by_calendar(X)
  → ffi_push → Flutter 日历列表移除 X
```

**场景：用户 B 在线时自行取消订阅**

```
T1: 用户 B 发送 calendar_subscribe(subscribe=false)
  → 服务端处理成功，返回 OK
  → SDK 收到成功响应，本地删除日历 X 及其日程（无需等推送）
  → 服务端推 CalendarPushUpdate 给剩余订阅者
  → 服务端推 EntityChange(Calendar, Delete) 给 B（冗余但无害）
```
```

### 6.6 日程离线同步

日程变更的离线同步同样走 pipeline，推送类型包括 `SchedulePushUpdate`（新增/更新）和 `ScheduleDeletePush`（批量删除）。

详见 `docs/calendar/calendar_p1_design_part_2.md` §2.2c（Proto 定义）和 §3.4（SDK 处理）。
