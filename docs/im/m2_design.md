# M2: 群管理功能深化 — 技术设计文档

> 基于 `docs/im/milestone.md` M2 规划设计。

---

## 1. 目标

将基础群聊升级为具备完整群管理能力的群系统，覆盖群资料、公告、角色权限、禁言、邀请机制、加群验证和成员管理。

---

## 2. 架构影响范围

| 层次 | 影响 |
|------|------|
| Proto | Chat 实体扩展字段；新增 Mute / JoinRequest / InviteLink / AnnouncementContent 消息；新增 12 个命令枚举 |
| 后端 | `chat_update` handler；`chat_set_announcement`（消息 id == chat_id 的 upsert）；mute/unmute 拦截；invite link 生成与验证；join request 审批流；`message_send` 增禁言检查；成员分页查询 |
| SDK | 新增对应 FFI handler，透传至后端 API |
| Flutter | 群资料编辑页、公告 banner、角色管理、禁言设置、邀请分享、加群验证、成员列表增强 |
| DB | 新增 3 张表（group_mutes / join_requests / invite_links），chats 表扩展 3 列 |

---

## 3. 核心设计决策

| 决策 | 方案 |
|------|------|
| **群公告存储** | 不建新表。公告 = 一条特殊消息 `(id == chat_id, tpy = ANNOUNCEMENT)`，写入 `messages` 表。首次发布时 INSERT，更新时 UPDATE，删除时 DELETE |
| **公告内容** | `AnnouncementContent { title, tpy, body }` 序列化后存入 `message.content`，复用餐消息体序列化方案 |
| **公告同步** | 零额外逻辑。公告走 entity sync 自动推送到所有成员，客户端取 `entity.messages[chat.id]` |
| **CMV 作用** | 仅成员列表位图。配合消息已读回执，记录已读成员（即使退群）。不存角色/权限/禁言 |
| **权限存储** | `chats.owner_id` + `chats.admin_ids`，不扩展 CMV |
| **禁言存储** | 全局禁言: `chats.global_mute_until`；个体禁言: `group_mutes` 表 |

---

## 4. 权限模型

```
OWNER (群主)          — 全部权限：编辑资料、公告、管理管理员、禁言、解散、审批
ADMIN (管理员)        — 编辑资料、公告、禁言（普通成员）、审批（如果 join_mode=approval）
MEMBER (普通成员)     — 发送消息（非禁言状态）、退群、查看资料/公告/成员列表
```

### 操作 × 角色矩阵

| 操作 | Owner | Admin | Member |
|------|-------|-------|--------|
| 编辑群名称/头像/简介 | ✓ | ✓ | ✗ |
| 发布/更新/删除公告 | ✓ | ✓ | ✗ |
| 设置/移除管理员 | ✓ | ✗ | ✗ |
| 转让群主 | ✓ | ✗ | ✗ |
| 全员禁言 | ✓ | ✓ | ✗ |
| 个体禁言 | ✓ | ✓ | ✗ |
| 邀请成员 (invite_only) | ✓ | ✓ | ✗ |
| 审批加群申请 | ✓ | ✓ | ✗ |
| 解散群 | ✓ | ✗ | ✗ |
| 发送消息 | ✓ 豁免禁言 | ✓ 豁免禁言 | 非禁言状态可用 |
| 退群 | ✓ | ✓ | ✓ |

---

## 5. 禁言模型

```
global_mute_until — 群级别全员禁言（截止时间），Owner/Admin 豁免
member + mute     — 个体禁言（截止时间），独立于全局禁言
message_send 拦截 — 发信时检查: 非 Owner/Admin → 检查全局禁言 → 检查个体禁言 → 拒绝
```

### 消息发送拦截逻辑 (伪代码)

```
fn check_mute(sender, chat):
    if sender is owner or admin: return OK

    if chat.global_mute_until > now:
        return ERROR("群聊已开启全员禁言")

    if group_mutes.exists(chat_id=chat.id, member_id=sender.id, muted_until > now):
        return ERROR("你已被禁言")

    return OK
```

---

## 6. 加群流程

```
┌─ FREE 模式 (join_mode=0) ─────────────────┐
│ 任何成员可邀请 / 任何用户可通过 invite link 加入│
└──────────────────────────────────────────────┘

┌─ APPROVAL 模式 (join_mode=1) ───────────────┐
│ 用户申请 → join_requests (pending)            │
│     → Admin 审批 (approve/reject)             │
│         → 通过: 加入群聊 + 通知用户           │
│         → 拒绝: 通知用户                      │
└──────────────────────────────────────────────┘

┌─ INVITE_ONLY 模式 (join_mode=2) ───────────┐
│ 仅 Owner/Admin 可邀请 / invite link 有效     │
│ 普通成员不可邀请                             │
└──────────────────────────────────────────────┘
```

---

## 7. Proto 设计

### 7.1 `entity.proto` — Chat 字段扩展 + MessageType

```protobuf
message Chat {
    // ... 现有字段 1-17 ...
    string description = 18;           // 群简介
    int32 join_mode = 19;             // 0=free, 1=approval, 2=invite_only
    int64 global_mute_until = 20;     // 0 = 未禁言, >0 = 截止 ms
}

// MessageType 新增:
// ANNOUNCEMENT = 16;

message AnnouncementContent {
    string title = 1;      // 公告标题
    int32 tpy = 2;         // 正文内容类型 (同 Message.tpy)
    bytes body = 3;        // 正文内容 (与 Message.content 相同序列化方案)
}
```

### 7.2 `mute.proto` — 禁言

```protobuf
syntax = "proto3";
package mute;
option go_package = "./proto";

message MuteMemberRequest {
    int64 chat_id = 1;
    int64 member_id = 2;
    int64 until_ms = 3;       // 截止时间戳, 0=解除禁言
}
message MuteMemberResponse {}

message GlobalMuteRequest {
    int64 chat_id = 1;
    int64 until_ms = 2;       // 0=解除全员禁言
}
message GlobalMuteResponse {}
```

### 7.3 `invite.proto` — 邀请链接

```protobuf
syntax = "proto3";
package invite;
option go_package = "./proto";

message InviteLink {
    int64 id = 1;
    int64 chat_id = 2;
    string chat_name = 3;
    string code = 4;
    int64 created_by = 5;
    int64 created_at = 6;
    int64 expires_at = 7;
    int32 max_uses = 8;
    int32 use_count = 9;
    bool is_active = 10;
}

message InviteLinkCreateRequest {
    int64 chat_id = 1;
    int64 expires_at = 2;
    int32 max_uses = 3;
}
message InviteLinkCreateResponse {
    string code = 1;
    string url = 2;
}

message InviteLinkJoinRequest {
    string code = 1;
}
message InviteLinkJoinResponse {
    int64 chat_id = 1;
    Chat chat = 2;
}

message InviteLinkRevokeRequest {
    string code = 1;
}
message InviteLinkRevokeResponse {}
```

### 7.4 `join_request.proto` — 加群申请

```protobuf
syntax = "proto3";
package join_request;
option go_package = "./proto";

message JoinRequest {
    int64 id = 1;
    int64 chat_id = 2;
    string chat_name = 3;
    int64 user_id = 4;
    string user_name = 5;
    int32 status = 6;        // 0=pending, 1=approved, 2=rejected
    int64 handler_id = 7;
    int64 handled_at = 8;
    int64 created_at = 9;
}

message JoinRequestCreateRequest {
    int64 chat_id = 1;
}
message JoinRequestCreateResponse {
    JoinRequest request = 1;
    entity.Entity entities = 2;
}

message JoinRequestApproveRequest {
    int64 request_id = 1;
}
message JoinRequestApproveResponse {
    entity.Entity entities = 1;
}

message JoinRequestRejectRequest {
    int64 request_id = 1;
}
message JoinRequestRejectResponse {}

message JoinRequestListRequest {
    int64 chat_id = 1;
    int32 status = 2;
    int32 page = 3;
    int32 page_size = 4;
}
message JoinRequestListResponse {
    repeated JoinRequest requests = 1;
    int32 total = 2;
}
```

### 7.5 `chat.proto` — 更新命令

```protobuf
// 替换原 UpdateChatRequest
message UpdateChatRequest {
    int64 chat_id = 1;
    string name = 2;              // 非空即更新
    string avatar = 3;            // 非空即更新
    string description = 4;       // 非空即更新
    int64 owner_id = 5;           // >0 即更新（仅 Owner）
    repeated int64 admin_ids_add = 6;    // 新增管理员
    repeated int64 admin_ids_remove = 7; // 移除管理员
}
message UpdateChatResponse {
    entity.Entity entities = 1;
}

// 群公告（消息 id = chat_id）
message SetAnnouncementRequest {
    int64 chat_id = 1;
    string title = 2;
    int32 tpy = 3;              // 正文类型
    bytes body = 4;             // 正文内容
    string summary = 5;         // 摘要预览
}
message SetAnnouncementResponse {
    entity.Entity entities = 1;
}
message DeleteAnnouncementRequest {
    int64 chat_id = 1;
}
message DeleteAnnouncementResponse {
    entity.Entity entities = 1;
}

// 分页成员列表
message GetMembersRequest {
    int64 chat_id = 1;
    int32 page = 2;
    int32 page_size = 3;
    string keyword = 4;
}
message GetMembersResponse {
    repeated MemberItem members = 1;
    int32 total = 2;
}
message MemberItem {
    int64 user_id = 1;
    string name = 2;
    string avatar = 3;
    int32 role = 4;       // 0=member, 1=admin, 2=owner
}
```

### 7.6 `command.proto` — 新增命令枚举

```protobuf
enum Command {
    // ... 现有命令 ...

    // M2: 群管理 (1121-1132)
    CHAT_SET_ANNOUNCEMENT    = 1121;   // 创建/更新公告
    CHAT_DELETE_ANNOUNCEMENT = 1122;   // 删除公告
    CHAT_MUTE_MEMBER         = 1123;
    CHAT_GLOBAL_MUTE         = 1124;
    CHAT_INVITE_LINK_CREATE  = 1125;
    CHAT_INVITE_LINK_JOIN    = 1126;
    CHAT_INVITE_LINK_REVOKE  = 1127;
    CHAT_JOIN_REQUEST_CREATE = 1128;
    CHAT_JOIN_REQUEST_APPROVE= 1129;
    CHAT_JOIN_REQUEST_REJECT = 1130;
    CHAT_JOIN_REQUEST_LIST   = 1131;
    CHAT_GET_MEMBERS         = 1132;
}
```

---

## 8. DB 设计

### 8.1 chats 表扩展

```sql
ALTER TABLE chats ADD COLUMN description TEXT NOT NULL DEFAULT '';
ALTER TABLE chats ADD COLUMN join_mode SMALLINT NOT NULL DEFAULT 0;
ALTER TABLE chats ADD COLUMN global_mute_until TIMESTAMPTZ;
```

### 8.2 group_mutes 表

```sql
CREATE TABLE group_mutes (
    id BIGINT PRIMARY KEY,
    chat_id BIGINT NOT NULL REFERENCES chats(id),
    member_id BIGINT NOT NULL,
    muted_until TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX idx_group_mutes_chat_member ON group_mutes(chat_id, member_id);
```

### 8.3 join_requests 表

```sql
CREATE TABLE join_requests (
    id BIGINT PRIMARY KEY,
    chat_id BIGINT NOT NULL REFERENCES chats(id),
    user_id BIGINT NOT NULL,
    status SMALLINT NOT NULL DEFAULT 0,
    handler_id BIGINT,
    handled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_join_requests_chat_id ON join_requests(chat_id);
CREATE INDEX idx_join_requests_status ON join_requests(status);
```

### 8.4 invite_links 表

```sql
CREATE TABLE invite_links (
    id BIGINT PRIMARY KEY,
    chat_id BIGINT NOT NULL REFERENCES chats(id),
    code TEXT NOT NULL UNIQUE,
    created_by BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    max_uses INT4 NOT NULL DEFAULT 0,
    use_count INT4 NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true
);
CREATE INDEX idx_invite_links_code ON invite_links(code);
```

---

## 9. 后端 API 设计

### 9.1 Step 0 — CHAT_UPDATE

- **Handler**: `chat_update` in `backend/im/src/chat.rs`
- **权限**: Owner/Admin 可更新资料；仅 Owner 可变更 owner_id/admin_ids
- **流程**: 解析 `UpdateChatRequest` → 更新 `chats` 表 → 更新缓存 → 推 entity sync 给所有成员
- **前置修复**: `ChatModel::update_cmv` 需真正将 `owner_id`/`admin_ids` 写入 DB

### 9.2 Step 3 — 群公告 (messages 表)

- **Handler**: `chat_set_announcement` / `chat_delete_announcement` in `chat.rs`
- **权限**: Owner/Admin
- **Set 流程**: 查询 `id == chat_id` 是否存在 → INSERT or UPDATE `messages` 表 → 推 entity sync
- **Delete 流程**: DELETE from `messages WHERE id = chat_id` → 推 entity sync
- **公告 content**: `AnnouncementContent { title, tpy, body }` protobuf 序列化

### 9.3 Step 4 — 禁言

- **Mute member**: `mute_member` → upsert `group_mutes`
- **Global mute**: `global_mute` → update `chats.global_mute_until`
- **发送拦截**: `message_send` 增加禁言检查（Owner/Admin 豁免）

### 9.4 Step 5 — 邀请链接

- **Create**: Owner/Admin → 生成唯一 code (nanoid/base62) → insert `invite_links`
- **Join**: 验证 code → check active/expires/max_uses → `cmv.add()` → incr use_count
- **Revoke**: Owner/Admin → `is_active = false`

### 9.5 Step 6 — 加群验证

- **Create**: 用户申请 → insert `join_requests(status=pending)` → 通知 admin
- **Approve**: Admin → update status + `cmv.add()` + 推变更
- **Reject**: Admin → update status → 通知申请者
- **List**: Admin → 分页查询 pending 请求

### 9.6 Step 7 — 成员分页

- **Handler**: `get_members` → 从 `cmv.ids()` 获取成员列表 → 分页 + join users 表搜索

---

## 10. SDK & Flutter 策略

### SDK
- 所有新命令走 `api::common_request` 透传至后端
- 注册到 `ffi_commands()` + `on_ffi_command()` dispatch

### Flutter 公告
- **Banner**: `ChatHeader` 下方读取 `entity.messages[chatId]`，`tpy == ANNOUNCEMENT` 时渲染
- **内容复用**: 公告 body 通过 `_buildContent()` 同一套渲染（Quill / Markdown / Text）
- **编辑**: Owner/Admin 可见→弹窗标题+富文本编辑器→调用 `setAnnouncement`
- **消息列表过滤**: `MessageView` 排除 `id == chatId` 的消息

### Flutter 群资料
- `ChatHeader` 更多按钮 → "群资料" → `GroupProfilePage`
- Owner/Admin 可编辑名称/头像/简介/二维码；其他角色只读
- 头像上传复用 store `/api/files/upload`

### Flutter 其他
- 角色管理、禁言、邀请、加群验证、成员列表均走独立页面/弹窗，通过 `im.sdk.invokeAsync()` 调用

---

## 11. 依赖图

```
Step 0 (CHAT_UPDATE 路由 + update_cmv 修复)
    │
    ▼
Step 1 (Proto 定义)
    │
    ▼
Step 2 (DB Migration)
    │
    ┌────────────────┬───────────────┬───────────────┬────────────────┐
    ▼                ▼               ▼               ▼                ▼
Step 3          Step 4          Step 5          Step 6           Step 7
(公告 upsert    (禁言)          (邀请链接)      (加群验证)        (成员分页)
 至 messages)
    │                │               │               │              │
    └────────────────┴───────────────┴───────────────┴──────────────┘
                                    │
                                    ▼
                              Step 8 (SDK)
                                    │
                                    ▼
            ┌───────────────────────┼───────────────────────┐
            ▼                       ▼                       ▼
      Step 9-10               Step 11-14              Step 15
    (群资料+公告)          (角色+禁言+邀请+验证)     (成员列表)
            │                       │                       │
            └───────────────────────┼───────────────────────┘
                                    ▼
                              Step 16 (测试)
```

---

## 12. 分支策略

```bash
git checkout -b feat/m2-group-management

# Phase 1: 基础设施
git commit -m "feat(im): step 0 chat_update route + update_cmv fix"

# Phase 2: Proto + DB
git commit -m "feat(proto): step 1 M2 proto definitions"
git commit -m "feat(db): step 2 M2 migrations"

# Phase 3-7: 后端功能
git commit -m "feat(im): step 3 announcement (messages-based) + set/delete"
git commit -m "feat(im): step 4 group mute + send intercept"
git commit -m "feat(im): step 5 invite link"
git commit -m "feat(im): step 6 join request approval"
git commit -m "feat(im): step 7 paginated member list"

# Phase 8: SDK
git commit -m "feat(sdk): step 8 M2 FFI handlers"

# Phase 9-15: Flutter
git commit -m "feat(flutter): step 9-10 group profile + announcement UI"
git commit -m "feat(flutter): step 11-14 roles + mute + invite + join UI"
git commit -m "feat(flutter): step 15 member list enhancement"

# Phase 16: 测试
git commit -m "test(im): step 16 M2 tests"
```
