# M3: 消息互动与体验增强 — 技术设计文档

> 基于 `docs/im/milestone.md` M3 规划设计。

---

## 1. 目标

提升消息互动能力和用户体验，覆盖 @提及、消息 Pin、评论 Thread、已读详情、输入指示、在线状态、消息删除 7 个功能。

---

## 2. 架构影响范围

| 层次 | 影响 |
|------|------|
| Proto | 新增 `pin.proto` / `thread.proto` / `presence.proto` / `typing.proto`；更新 `entity.proto`（Message 加 `thread_root_id`）；更新 `message.proto`（`DeleteMessage`） |
| 后端 | 新增 4 个 handler 模块（`pin.rs` / `thread.rs` / `presence.rs` / `typing.rs`）；修改 `message.rs`（解析 @mentions、Thread 回复、已读详情、删除） |
| SDK | 新增对应 FFI handler（pin / thread / presence / typing / delete） |
| Flutter | @渲染高亮 + @选择器、Pin banner + Pin/Unpin、Thread 面板 + 回复、已读详情弹窗、输入指示器、在线状态圆点、删除菜单 |
| DB | 新增 3 张表（`message_pins` / `chat_threads` / `user_presence`），messages 表加 1 列 |

---

## 3. 核心设计决策

| 决策 | 方案 |
|------|------|
| **@Mention 存储** | 沿用现有 `Message.at_user_ids`（`repeated int64`）字段。`@all` 通过 `user_id = -1` 表示。客户端发送时自行填充 `at_user_ids`，服务端仅透传写入 DB，不修改消息内容 |
| **@Mention 推送** | 正常推送给全体成员即可。客户端自行根据 `at_user_ids` 判断当前用户是否被 @，做对应 UI 提示 |
| **@Mention 渲染** | 客户端解析 `MessageText.mentions`（offset+length），在文本中高亮显示 |
| **消息 Pin** | 单表 `message_pins` 存储，每个群可 pin 多条消息，按 pin 时间倒序。Pin 操作推 entity sync |
| **消息 Thread** | Thread（评论串）是对某条消息的独立讨论，与引用回复（Quote Reply）是两条不同路径。Thread 回复 = 普通消息 + `thread_root_id` 指向根消息，复用水位线/已读/推送等既有逻辑。`chat_threads` 表缓存 thread 元数据（消息数、最后回复预览）。发送时自动更新元数据。详见下方 Thread 说明 |
| **已读详情** | 基于 CMV 位图 + `read_states` 字节码，查询消息已读/未读成员列表。只在显式请求时才计算（不推送给全部成员） |
| **输入指示器** | 纯实时通道，不入 DB。SDK 侧 300ms 节流，通过 WS 发送 `TYPING` 事件 → gateway fanout 给群内其他成员。客户端 3s 超时自动清除 |
| **在线状态** | 由 gateway 层管理（WS 连接上下线触发）。写入 `user_presence` 表持久化。SDK 可订阅关注用户的状态变更 |
| **消息删除** | 两种模式：local（仅自己不可见）、global（全员删除，置 `status=2`）。Global 仅消息发送者或 Owner/Admin 可操作 |

---

## 4. Proto 设计

### 4.1 `command.proto` — 新增命令枚举

```protobuf
// M3: 消息互动 (1134-1139, 1217-1220, 1351-1353, 1403-1404)
CHAT_PIN_MESSAGE          = 1134;
CHAT_UNPIN_MESSAGE        = 1135;
CHAT_GET_PINNED_MESSAGES  = 1136;
MESSAGE_GET_THREAD        = 1217;
MESSAGE_GET_READ_MEMBERS  = 1218;
USER_PRESENCE_UPDATE      = 1351;
PUSH_PRESENCE             = 1352;
TYPING                    = 1403;
PUSH_TYPING               = 1404;
```

> `MESSAGE_DELETE = 1206` 已定义，只需增补请求/响应消息。

### 4.2 `entity.proto` — Message 扩展

```protobuf
message Message {
    // ... 现有字段 1-11 ...
    // 12-19 保留
    // 20-24 现有 (content/summary/version/read_state/reactions)
    // 25-30 保留
    // 31-32 现有 (ref_message_id/ref_data)

    int64 thread_root_id = 33;    // Thread 根消息 ID，0=普通消息
}
```

### 4.3 新增 `pin.proto`

```protobuf
syntax = "proto3";
package pin;
option go_package = "./proto";

message PinMessageRequest {
    int64 chat_id = 1;
    int64 message_id = 2;
}
message PinMessageResponse {
    entity.Entity entities = 1;
}

message UnpinMessageRequest {
    int64 chat_id = 1;
    int64 message_id = 2;
}
message UnpinMessageResponse {
    entity.Entity entities = 1;
}

message GetPinnedMessagesRequest {
    int64 chat_id = 1;
}
message GetPinnedMessagesResponse {
    repeated entity.Message messages = 1;
}
```

### 4.4 新增 `thread.proto`

```protobuf
syntax = "proto3";
package thread;
option go_package = "./proto";

message GetThreadRequest {
    int64 chat_id = 1;
    int64 root_message_id = 2;
    int32 page = 3;
    int32 page_size = 4;
}
message GetThreadResponse {
    repeated entity.Message messages = 1;
    int32 total = 2;
}
```

### 4.5 新增 `presence.proto`

```protobuf
syntax = "proto3";
package presence;
option go_package = "./proto";

message PresenceUpdateRequest {
    int32 status = 1;       // 0=offline, 1=online, 2=away, 3=busy
    string status_text = 2; // 自定义状态文字
}
message PresenceUpdateResponse {}

message PushPresence {
    int64 user_id = 1;
    int32 status = 2;
    string status_text = 3;
    int64 last_seen_ms = 4;
}

message PresenceSubscribeRequest {
    repeated int64 user_ids = 1;
}
message PresenceSubscribeResponse {}
```

### 4.6 新增 `typing.proto`

```protobuf
syntax = "proto3";
package typing;
option go_package = "./proto";

message TypingRequest {
    int64 chat_id = 1;
}

message PushTyping {
    int64 chat_id = 1;
    int64 user_id = 2;
    string user_name = 3;
    int64 expire_at_ms = 4;  // 超时时间，客户端 0 重设
}
```

### 4.7 `message.proto` — 补充 DeleteMessage

```protobuf
message DeleteMessageRequest {
    int64 message_id = 1;
    int32 mode = 2;       // 0=local, 1=global
}
message DeleteMessageResponse {
    entity.Entity entities = 1;  // global 时推变更
}
```

---

## 5. DB 设计

### 5.1 `message_pins` 表

```sql
CREATE TABLE message_pins (
    id BIGINT PRIMARY KEY,
    chat_id BIGINT NOT NULL REFERENCES chats(id),
    message_id BIGINT NOT NULL,
    pinned_by BIGINT NOT NULL,
    pinned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(chat_id, message_id)
);
CREATE INDEX idx_message_pins_chat ON message_pins(chat_id);
```

### 5.2 messages 表增加 `thread_root_id` 列

```sql
ALTER TABLE messages ADD COLUMN thread_root_id BIGINT NOT NULL DEFAULT 0;
CREATE INDEX idx_messages_thread_root ON messages(chat_id, thread_root_id);
```

### 5.3 `chat_threads` 表

```sql
CREATE TABLE chat_threads (
    id BIGINT PRIMARY KEY,
    chat_id BIGINT NOT NULL REFERENCES chats(id),
    root_message_id BIGINT NOT NULL,
    message_count INT4 NOT NULL DEFAULT 0,
    last_message_at TIMESTAMPTZ,
    last_message_id BIGINT,
    last_message_summary TEXT NOT NULL DEFAULT '',
    last_message_from_id BIGINT,
    UNIQUE(chat_id, root_message_id)
);
CREATE INDEX idx_chat_threads_root ON chat_threads(chat_id, root_message_id);
```

### 5.4 `user_presence` 表

```sql
CREATE TABLE user_presence (
    user_id BIGINT PRIMARY KEY,
    status SMALLINT NOT NULL DEFAULT 0,
    status_text TEXT NOT NULL DEFAULT '',
    last_seen_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

## 6. 后端 API 设计

### 6.1 Step 2 — @Mention

**Handler**: 修改 `message_send` in `backend/im/src/message.rs`

**流程**:
1. 客户端发送 `Message` 时已自行填充 `at_user_ids`；服务端透传写入 `messages` 表
2. 推送时正常推送给全体成员
3. 客户端收到消息后，自行比对 `at_user_ids` 判断是否被 @

**约束**:
- `@all` 默认所有群成员均可使用，后续通过群设置 `allow_at_all` 字段（写入 `chats` 表）控制权限
- `at_user_ids` 上限 50 个（不含 @all）

### 6.2 Step 3 — Message Pin

**Handler**: 新增 `backend/im/src/pin.rs`

| 操作 | 方法 | 权限 |
|------|------|------|
| Pin | `pin_message` | 群内成员均可 |
| Unpin | `unpin_message` | Pin 操作者 / Owner/Admin |
| List | `get_pinned_messages` | 群内成员 |

**Pin 流程**: 验证 message 属于 chat → INSERT `message_pins` → 推 entity sync（将 message 置入 `pinned` 状态）
**Unpin 流程**: DELETE from `message_pins` → 推 entity sync
**List 流程**: JOIN `message_pins` + `messages` 按 `pinned_at DESC` 查询

### 6.3 Step 4 — Thread（评论串）

#### Thread vs 引用回复（Quote Reply）

| 维度 | 引用回复 | Thread 评论串 |
|------|---------|---------------|
| 展示位置 | 主消息流 inline 展示 | 独立面板，右侧滑出 |
| 关系 | 一对一的回复关系 | 一对多，围绕根消息的独立讨论 |
| `ref_message_id` | ✅ 指向被回复消息 | 非 Thread 用途 |
| `thread_root_id` | 0 | ✅ 指向 Thread 根消息 |
| 消息流可见性 | 所有成员在主列表可见 | 仅 Thread 面板内可见 |

两者是正交功能，可同时存在（例：在 Thread 回复中引用另一条消息）。

#### Thread 数据模型

```
Thread 根消息（普通消息，无 thread_root_id）
    ├── 回复 1（thread_root_id = 根消息.id）
    ├── 回复 2（thread_root_id = 根消息.id）
    └── 回复 3（thread_root_id = 根消息.id）
```

- Thread = 根消息 + 一组 `thread_root_id == 根消息.id` 的回复消息
- 不允许多层嵌套，所有回复平铺，`thread_root_id` 始终指向最顶层根消息
- 回复消息也是普通 `Message`，复用水位线/已读/Reaction/推送等既有逻辑

#### chat_threads 元数据表作用

- `message_count`：Thread 内回复总数，用于 UI 展示「N 条回复」
- `last_message_*`：最后一条回复的预览，用于 Feed 或 Thread 列表展示
- `message_send` 检测 `thread_root_id > 0` 时，原子更新该表

#### Handler

**Handler**: 新增 `backend/im/src/thread.rs`

**Thread 回复发送**: 通过 `MESSAGE_SEND` 发送，携带 `thread_root_id`
- `message_send` 检测 `thread_root_id > 0` → 更新 `chat_threads`（`message_count++`, `last_message_*`）

**查询 Thread**:
- `get_thread` → 按 `chat_id + thread_root_id` 查询 messages，分页（按 `pos` 正序）

### 6.4 Step 5 — 已读详情

**Handler**: 新增 `message_get_read_members` in `message.rs`

**流程**:
1. 从消息的 `cmv_id` 读取 CMV
2. 从 `read_states` 字节码解析每位成员的已读状态
3. JOIN `users` 表获取成员名称和头像
4. 返回 `read_users` / `unread_users` 列表

### 6.5 Step 6 — Typing

**Handler**: `backend/gateway/src/` 或 `backend/im/src/typing.rs`

**流程**:
1. 客户端发送 `TYPING` → `{ chat_id }`
2. 服务端查询 chat 成员列表
3. fanout `PUSH_TYPING` → `{ chat_id, user_id, user_name, expire_at_ms }` 给其他成员
4. SDK 侧 300ms 节流，连续 typing 只发一次
5. 客户端 3s 未收到新 `PUSH_TYPING` 自动清除指示

### 6.6 Step 7 — Presence

**Handler**: 后端 `user` 模块或 `gateway` 层

**流程**:
1. 用户建立 WS 连接 → `user_presence` 标记 `status=1(online)`
2. 用户断开 WS 连接 → `status=0(offline)`, `last_seen_at=NOW()`
3. 用户手动设置状态 → `PRESENCE_UPDATE` → update DB → push 给订阅者
4. 其他用户通过 `PUSH_PRESENCE` 接收状态变更
5. 新增 `PresenceSubscribe` 来订阅关注用户的状态

### 6.7 Step 8 — Message Delete

**Handler**: 新增 `message_delete` in `message.rs`

**流程**:
- **local 模式**: 客户端本地移除，不发请求
- **global 模式**: 验证权限（发送者 or Owner/Admin）→ `messages.status = 2(DELETED)` → 推 entity sync

---

## 7. SDK & Flutter 策略

### SDK
- 所有新命令走 `api::common_request` 透传至后端
- 注册到 `ffi_commands()` + `on_ffi_command()` dispatch
- Typing 专用节流逻辑：`last_typing_time` 检查，300ms 内不重复发送
- Presence 订阅管理：维护 `subscribed_user_ids` 集合

### Flutter @Mention
- **输入**: 完善 `MentionPopup`，读取群成员列表作为候选；支持 `@all`
- **发送**: `onSendMessage` 提取 `MessageText.mentions`，填充 `at_user_ids`
- **渲染**: `message.dart` 解析 `MessageText.mentions`，用高亮样式渲染提及部分
- **全部 @**: 检测 `@all` 关键字，匹配 `user_id = -1`

### Flutter Pin
- **Banner**: `ChatHeader` 下方展示 pin 消息列表（类似公告，但可多条）
- **操作**: 消息长按菜单 → "Pin 消息" / "取消 Pin"
- **图标**: 已 pin 消息右侧显示 📌 角标

### Flutter Thread
- **入口**: 消息长按菜单 → "回复" → 选择 "回复到 Thread"
- **Thread 面板**: 右侧滑出面板，显示根消息 + Thread 内消息列表 + 输入框
- **指示**: 有 Thread 回复的消息显示「N 条回复」链接

### Flutter 已读详情
- **入口**: 点击消息的已读状态区域（如 "3 人已读"）
- **弹窗**: `showModalBottomSheet` 展示已读/未读成员列表

### Flutter Typing
- **展示**: `ChatHeader` 下方，输入框上方，显示 "XXX 正在输入..."

### Flutter Presence
- **展示**: 聊天列表头像右下角绿色圆点（在线）、灰色圆点（离线）
- **P2P 聊天**: 头部显示在线/离线/最后在线时间

### Flutter 删除
- **菜单**: 消息长按菜单 → "删除"
- **确认**: 弹窗确认 → 调用 `message_delete(mode=1)` 或本地移除

---

## 8. 依赖图

```
Step 0 (Proto 定义 — 所有 M3 proto)
    │
    ▼
Step 1 (DB Migration — pins / threads / presence 表 + messages 加列)
    │
    ┌──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────┐
    ▼          ▼          ▼          ▼          ▼          ▼          ▼          ▼
Step 2    Step 3    Step 4    Step 5    Step 6    Step 7    Step 8
(@Mention  (Pin)     (Thread)  (已读详情) (Typing)   (Presence) (删除)
 后端)                                                              
    │          │          │          │          │          │          │
    └──────────┴──────────┴──────────┴──────────┴──────────┴──────────┘
                                  │
                                  ▼
                            Step 9 (SDK — 所有新命令)
                                  │
                                  ▼
          ┌────────┬───────┬──────┬──────┬──────┬──────┬──────┐
          ▼        ▼       ▼      ▼      ▼      ▼      ▼      ▼
       Step 10  Step 11 Step 12 Step 13 Step 14 Step 14 Step 15
       (@渲染+  (Pin     (Thread (已读    (Typing  (Presence (删除
         选择器)   UI)      UI)    详情)     UI)      UI)     UI)
          │        │       │      │       │       │       │
          └────────┴───────┴──────┴───────┴───────┴───────┘
                                  │
                                  ▼
                            Step 16 (测试)
```

---

## 9. 依赖与风险

| # | 风险 | 缓解方案 |
|---|------|---------|
| 1 | **Thread 嵌套查询 N+1** — 递归 CTE 或逐条查 | 限制嵌套层数 1 级（仅根消息+回复，不允许多层 Thread） |
| 2 | **输入指示器高频推送** — 每次按键推 WS | SDK 侧 300ms 节流，合并推送 |
| 3 | **已读详情精确度** — 大群 1000+ 人位图膨胀 | CMV 位图压缩存储，只返回前 100 条已读/未读记录，附加 total 计数 |
| 4 | **删除消息反向同步** — 已同步到其他设备的消息删除 | global delete 通过 entity sync 推送，status=2 标记已删除，客户端渲染灰条 |

---

## 10. 步骤拆解

各步骤按顺序依赖 Proto → DB → 后端 → SDK → Flutter 逐层实现，具体任务见 `todo.md`。
