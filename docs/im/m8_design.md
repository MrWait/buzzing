# M8: 多设备与离线体验 — 设计方案

> 目标：实现多设备消息同步、离线消息保障、草稿跨设备同步、设备管理。

---

## 1. 概述

### 1.1 当前状态

| 能力 | 状态 | 说明 |
|------|------|------|
| Pipeline 离线队列 | 部分实现 | DB 已写、拉取 API 有、实体填充为空实现 |
| 消息漫游 | ❌ 缺失 | 无按 Feed/时间拉取历史消息 API |
| 草稿同步 | ❌ 缺失 | Chat 草稿是空实现，Message 草稿纯本地 |
| 设备管理 | ❌ 缺失 | 无设备注册、无 session 管理、无踢下线 |
| 推送 token | ❌ 缺失 | 无 APNs/FCM token 注册 |
| 增量同步 | ❌ 缺失 | 无 version 对比、无 delta 拉取 |

### 1.2 M8 目标

将当前纯本地、无设备概念的单机体验升级为 **多设备一致的协同体验**：

```
┌─────────────────────────────────────────────┐
│              服务端                           │
│  ┌──────────┐ ┌──────────┐ ┌──────────────┐ │
│  │ Pipeline │ │ Draft DB │ │ Device/Sess  │ │
│  │ 离线队列  │ │ 草稿存储  │ │ 设备管理      │ │
│  └──────────┘ └──────────┘ └──────────────┘ │
│  ┌──────────────────────────────────────┐   │
│  │  Entity Sync (version-based delta)   │   │
│  └──────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
          ↕ HTTP/WS
┌──────────┴──────────┐
│       SDK            │
│  ┌────┐ ┌────┐ ┌───┐│
│  │本地DB│ │草稿 │ │设备││
│  └────┘ └────┘ └───┘│
│  Pipeline 自动拉取  │
└─────────────────────┘
          ↕ FFI
┌──────────┴──────────┐
│     Flutter 客户端    │
│  设备管理页 / 漫游    │
└─────────────────────┘
```

---

## 2. 详细设计

### 2.1 设备管理 (M8-A)

#### 2.1.1 Proto

新增 `proto/device.proto`:

```protobuf
syntax = "proto3";
package device;
import "entity.proto";

message DeviceInfo {
    string device_id = 1;       // SDK 生成的唯一设备 ID
    string device_name = 2;     // "iPhone 15 Pro"
    string device_type = 3;     // "ios" / "android" / "windows" / "macos" / "linux"
    string app_version = 4;
    string os_version = 5;
    int64 login_time_ms = 6;
    int64 last_active_ms = 7;
    bool is_current = 8;        // 当前设备
    string push_token = 9;      // APNs/FCM token
    int32 push_type = 10;       // 1=APNs, 2=FCM, 3=华为, 4=小米...
}

message RegisterDeviceRequest {
    DeviceInfo device = 1;
}

message RegisterDeviceResponse {}

message GetDevicesRequest {}

message GetDevicesResponse {
    repeated DeviceInfo devices = 1;
}

message KickoffDeviceRequest {
    string device_id = 1;
}

message KickoffDeviceResponse {}

message PushDeviceKickoff {
    string device_id = 1;
}
```

**Command 枚举补充**:

| Command | 值 | 方向 |
|---------|-----|------|
| `DEVICE_REGISTER` | 1060 | C→S |
| `DEVICE_GET_LIST` | 1061 | C→S |
| `DEVICE_KICKOFF` | 1062 | C→S |
| `PUSH_DEVICE_KICKOFF` | 1005 | S→C (已有) |

#### 2.1.2 DB 迁移

新建 `devices` 表：

```sql
CREATE TABLE devices (
    id BIGINT PRIMARY KEY,                  -- Snowflake
    user_id BIGINT NOT NULL,                -- 用户 ID
    device_id VARCHAR(64) NOT NULL UNIQUE,  -- SDK 生成
    device_name VARCHAR(128) NOT NULL DEFAULT '',
    device_type VARCHAR(16) NOT NULL DEFAULT '',
    app_version VARCHAR(32) NOT NULL DEFAULT '',
    os_version VARCHAR(32) NOT NULL DEFAULT '',
    push_token VARCHAR(256) DEFAULT '',
    push_type SMALLINT DEFAULT 0,
    login_time_ms BIGINT NOT NULL,
    last_active_ms BIGINT NOT NULL,
    is_deleted SMALLINT DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX idx_devices_user_id ON devices(user_id);
```

#### 2.1.3 后端 Handler

| Handler | 逻辑 |
|---------|------|
| `register_device` | upsert devices 表；返回成功 |
| `get_devices` | 查询当前用户的所有设备，标记 is_current |
| `kickoff_device` | 设置 is_deleted=1，通过 WS 向目标设备推送 `PushDeviceKickoff` |
| WS 连接鉴权 | 连接时读取 `device_id` header，更新 `last_active_ms` |
| WebSocket 断开 | 清理 `gateway_connections`，不删 device 记录 |

#### 2.1.4 SDK

| 方法 | 说明 |
|------|------|
| `register_device` | 启动时/登录后自动调用 |
| `get_devices` | 查询设备列表 |
| `kickoff_device` | 踢下线指定设备 |
| `on_push_kickoff` | 收到 `PushDeviceKickoff` 后主动断开 WS、清除 token、触发 logout |

#### 2.1.5 Flutter

- 设备管理页 `device_management_page.dart`：展示设备列表 + 踢下线按钮
- 当前设备标记 "当前设备" 不可踢
- 设置页入口

---

### 2.2 草稿跨设备同步 (M8-B)

#### 2.2.1 Proto

**Chat Draft** 已有 proto (`chat.proto:SetChatDraftRequest/GetChatDraftRequest`)，需要补充 `PullChatDraftsRequest/Response` 用于拉取所有草稿。

```protobuf
// 新增 chat.proto
message PullChatDraftsRequest {}

message PullChatDraftsResponse {
    repeated ChatDraft drafts = 1;
    map<int64, int64> versions = 2;  // chat_id → version
}

message ChatDraft {
    int64 chat_id = 1;
    string content = 2;
    int64 time_ms = 3;
    int64 version = 4;
}
```

**Message Draft** 已有 proto (`message.proto:CreateMessageDraftRequest`)，需补充拉取 API：

```protobuf
// 新增 message.proto
message PullMessageDraftsRequest {}

message PullMessageDraftsResponse {
    repeated DraftMessage drafts = 1;
}

message DraftMessage {
    int64 client_id = 1;
    int64 chat_id = 2;
    entity.Message message = 3;
    int64 version = 4;
}
```

#### 2.2.2 DB 迁移

**chat_drafts 表**：

```sql
CREATE TABLE chat_drafts (
    chat_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    content TEXT NOT NULL DEFAULT '',
    time_ms BIGINT NOT NULL DEFAULT 0,
    version BIGINT NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (chat_id, user_id)
);
```

**message_drafts 表**：

```sql
CREATE TABLE message_drafts (
    client_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    chat_id BIGINT NOT NULL,
    message_data BYTEA NOT NULL,
    version BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (client_id, user_id)
);
```

#### 2.2.3 后端 Handler

| Handler | 逻辑 |
|---------|------|
| `set_chat_draft` | upsert chat_drafts 表，递增 version |
| `get_chat_draft` | 查询单个 chat 的 draft |
| `pull_chat_drafts` | 查询用户所有 chat drafts，返回版本 map |
| `create_message_draft` | 写入 message_drafts 表 |
| `delete_message_draft` | 删除 message_drafts 记录 |
| `pull_message_drafts` | 查询用户所有 message drafts |
| `sync_drafts` (推) | 登录/重连后自动调用 pull 拉取全量草稿 |

**同步策略**：乐观锁 version 比较。当本地 version < 服务端 version 时，用服务端覆盖本地；本地 version > 服务端 version 时，推送本地到服务端。

#### 2.2.4 SDK

| 方法 | 说明 |
|------|------|
| `chat_set_draft` | 发送到服务端 (当前是 stub) |
| `chat_get_draft` | 从服务端拉 (当前是 stub) |
| `sync_chat_drafts` | 登录后/打开会话时调用 |
| `message_create_draft` | 已有实现，补充服务端持久化 |
| `sync_message_drafts` | 登录后拉取服务端未完成草稿 |

#### 2.2.5 Flutter

- 草稿同步在后台自动进行，用户无感知
- 多设备间切换时草稿自动保持最新

---

### 2.3 增量同步 (M8-C)

#### 2.3.1 设计原则

基于已有的 `version` 字段，实现 **version-based delta sync**：

| 实体 | version 策略 | 备注 |
|------|-------------|------|
| Chat | 每次更新 +1 | 已有 version 字段 |
| Message | 每次更新 +1 | 已有 version 字段 |
| Feed | 每次更新 +1 | 已有 version 字段 |
| User | 每次更新 +1 | 已有 version 字段 |

**同步流程**：
1. 客户端登录后，携带本地各实体类型的 `max_version`
2. 服务端返回增量变更
3. 客户端应用变更到本地 DB
4. 服务端可通过 `PushEntityChanged` 实时推送变更

#### 2.3.2 Proto

已有的 `pipeline.proto:PushEntityChanged` 和 `PullEntityRequest/Response` 基本够用，需要补充：

```protobuf
// 新增 pipeline.proto
message DeltaSyncRequest {
    int64 feed_version = 1;     // 本地最大 feed version
    int64 chat_version = 2;     // 本地最大 chat version
    int64 message_version = 3;  // 本地最大 message version
    int64 user_version = 4;     // 本地最大 user version
}

message DeltaSyncResponse {
    repeated entity.EntityChange changes = 1;
    entity.Entity entity = 2;        // 变更的实体数据
    int64 feed_version = 3;
    int64 chat_version = 4;
    int64 message_version = 5;
    int64 user_version = 6;
}
```

**Command 补充**:
| Command | 值 | 方向 |
|---------|-----|------|
| `DELTA_SYNC` | 1052 | C→S |

#### 2.3.3 后端

**Query 逻辑**：
```sql
-- 查找 version > $user_feed_version 的 feeds
SELECT * FROM feeds WHERE user_id = $1 AND version > $2 ORDER BY version LIMIT 100;
-- 同理 chat + message + user
```

**`PushEntityChanged` 推送**：服务端在实体变更时，除了 pipeline 记录，还发 `PushEntityChanged`。已连接的客户端收到后按需拉取增量。

#### 2.3.4 SDK

- 本地 DB 各表记录当前 `max_version`
- 登录后调用 `delta_sync` 拉取增量
- 收到 `PushEntityChanged` 后触发局部刷新

#### 2.3.5 `pipeline_pull_entity` 实现

当前是空实现 `Ok((0, vec![]))`，需填充：

```rust
// 接收 PullEntityRequest { ids: [EntityId { id, type }] }
// 按 type 分发查询：
//   USER=1    → users 表
//   CHAT=2    → chats 表 + cmv 解析 member_ids
//   MESSAGE=15 → messages 表
//   FEED=6    → feeds 表
// 组装成 entity::Entity 返回
```

---

### 2.4 消息漫游 (M8-D)

#### 2.4.1 设计

**当前问题**：消息只在 SDK 本地 DB 缓存。当用户在新设备登录、重装 App、或清除本地数据后，看不到历史消息。

**方案**：服务端已有全量 `messages` 表（消息发出即持久化）。新增 API 按 **Feed + pos** 拉取历史消息。

#### 2.4.2 Proto

```protobuf
// 新增 feed.proto（或 message.proto）
message RoamMessagesRequest {
    int64 chat_id = 1;
    int32 pos = 2;          // 起始 pos (0 = 最新)
    int32 count = 3;        // 拉取数量，默认 50
    int32 direction = 4;    // 0=向前(更新), 1=向后(更旧)
}

message RoamMessagesResponse {
    repeated entity.Message messages = 1;
    int32 next_pos = 2;     // 下次拉取的 pos
    bool has_more = 3;
}
```

**Command 补充**:
| Command | 值 | 方向 |
|---------|-----|------|
| `MESSAGE_ROAM` | 1210 | C→S |

#### 2.4.3 后端

```sql
-- 向前拉取 (direction=0, 自 pos 向更大方向)
SELECT * FROM messages
WHERE chat_id = $1 AND pos >= $2
ORDER BY pos ASC LIMIT $3;

-- 向后拉取 (direction=1, 自 pos 向更小方向)
SELECT * FROM messages
WHERE chat_id = $1 AND pos < $2
ORDER BY pos DESC LIMIT $3;
```

#### 2.4.4 SDK

- 当本地消息不足时（比如跳转到很旧的消息），自动调用 `roam_messages`
- 拉取后保存到本地 `message.db`

#### 2.4.5 Flutter

- 消息列表加载更多时自动触发漫游
- 无新 UI 变更

---

### 2.5 推送 Token 注册 (M8-E)

#### 2.5.1 Proto

```protobuf
// 新增 device.proto
message RegisterPushTokenRequest {
    string device_id = 1;
    string token = 2;       // APNs/FCM token
    int32 push_type = 3;    // 1=APNs, 2=FCM, 3=华为, 4=小米...
}

message RegisterPushTokenResponse {}
```

**Command 补充**:
| Command | 值 | 方向 |
|---------|-----|------|
| `REGISTER_PUSH_TOKEN` | 1063 | C→S |

#### 2.5.2 后端

- 更新 `devices` 表的 `push_token`/`push_type` 字段
- 预留推送下发接口（实际推送通道接入在后续版本实现）

---

## 3. 实现顺序

```
M8-A: 设备管理       → 基础，先做 (其他功能依赖 device_id)
M8-B: 草稿同步       → 独立，可并行
M8-C: 增量同步       → 依赖 A
M8-D: 消息漫游       → 依赖 A + C
M8-E: 推送 Token    → 依赖 A
```

**建议执行顺序**:
1. M8-A: 设备注册 + 列表 + 踢下线 (全栈)
2. M8-C: pipeline_pull_entity 实现 + DeltaSync
3. M8-B: Chat Draft + Message Draft 服务端持久化 + 同步
4. M8-D: 消息漫游 API + SDK 侧自动调用
5. M8-E: 推送 token 注册
6. Flutter 设备管理页

---

## 4. 安全性

| 场景 | 措施 |
|------|------|
| 设备注册 | 必须携带有效 JWT token |
| 踢下线 | 只有当前用户可踢自己的其他设备 |
| WebSocket 绑定 | 连接时携带 device_id，gateway 记录 conn↔device 映射 |
| 推送 token | 存在 devices 表，按设备隔离 |
| Draft 访问 | 只能读写当前用户的草稿 |
