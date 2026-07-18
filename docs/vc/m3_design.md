# M3 Design: 会议生命周期管理 + 日历集成

> 对应 `milestones.md` 中 M3 阶段，需结合 `m1_prd.md` 的需求条目。
> 本文档细化架构设计、数据流、DB schema、模块职责后，再拆分出 todo.md 中的工作项。

---

## 1. 整体架构

### 1.1 当前状态

```
[WS JSON 信令]    ←── 实时视频通信 (M1/M2)
[Proto 命令]      ←── (M2-6 已定义占位，但未实现)
[内存 Room 模型]  ←── signaling.rs, 重启即丢失
[无数据库]        ←── meeting 数据无持久化
```

### 1.2 M3 目标状态

```
                  ┌──────────────────────┐
                  │   Gateway HTTP/Proto  │  ←── MEETING_CREATE / JOIN / ...
                  └────────┬─────────────┘
                           │
          ┌────────────────┼────────────────┐
          ▼                ▼                ▼
   ┌────────────┐  ┌────────────┐  ┌──────────────┐
   │ AppRtc     │  │ Signaling  │  │ Push (IM)    │
   │ CRUD 处理  │  │ WS 实时通信 │  │ 通知分发      │
   └─────┬──────┘  └─────┬──────┘  └──────────────┘
         │                │
         ▼                ▼
   ┌──────────┐    ┌──────────┐
   │PostgreSQL│    │ In-Memory│
   │  持久化   │    │ Room     │
   └──────────┘    └──────────┘
```

### 1.3 关键设计决策

| 决策 | 方案 |
|------|------|
| 实时信令 vs CRUD | WS JSON 信令只负责房间漫游；Proto 命令做 DB CRUD，互不阻塞 |
| 房间 ↔ 会议关系 | 会议（meeting）是业务概念，房间（room）是实时通信概念。会议创建时自动分配 room_id，客户端加入会议后通过 WS `join` {room_id} 进入房间 |
| 持久化时机 | MEETING_CREATE 写入 DB；MEETING_JOIN/LEAVE/END 同时更新 DB；WS `join`/`leave` 只操作内存（幂等） |
| 密码方案 | 服务端 bcrypt 哈希存储，MEETING_JOIN 时校验 |
| 通知方式 | 会议状态变更通过 IM Push 模块推送（gateway.send_packet_to_user），复用现有推送通道 |
| Web 端复用 | 前端直接调 gateway HTTP /api/v1 发送 proto 命令，与 Flutter 走相同协议 |

---

## 2. 数据库设计

### 2.1 新增表

```sql
-- 会议主表
CREATE TABLE meetings (
    id            BIGINT PRIMARY KEY,           -- Snowflake
    room_id       VARCHAR(64) NOT NULL UNIQUE,  -- 用于 WS 房间连接
    title         VARCHAR(256) NOT NULL DEFAULT '',
    host_id       BIGINT NOT NULL,              -- 创建者 user_id
    password      VARCHAR(128),                 -- bcrypt hash, NULL=无密码
    status        SMALLINT NOT NULL DEFAULT 0,  -- 0=active, 1=ended
    scheduled_at  TIMESTAMP,                    -- NULL=即时会议
    started_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    ended_at      TIMESTAMP,
    tenant_id     BIGINT NOT NULL,
    max_participants INT NOT NULL DEFAULT 4,
    settings      JSONB NOT NULL DEFAULT '{}',  -- muteOnEntry, allowScreenShare, etc.
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 会议成员表
CREATE TABLE meeting_members (
    id          BIGINT PRIMARY KEY,             -- Snowflake
    meeting_id  BIGINT NOT NULL REFERENCES meetings(id),
    user_id     BIGINT NOT NULL,
    role        SMALLINT NOT NULL DEFAULT 0,    -- 0=participant, 1=co-host, 2=host
    status      SMALLINT NOT NULL DEFAULT 0,    -- 0=invited, 1=joined, 2=left, 3=kicked
    joined_at   TIMESTAMP,
    left_at     TIMESTAMP,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_meetings_tenant_id ON meetings(tenant_id);
CREATE INDEX idx_meeting_members_meeting_id ON meeting_members(meeting_id);
CREATE INDEX idx_meeting_members_user_id ON meeting_members(user_id);
```

### 2.2 Sea-ORM Entity

新增 `base/model/migration`，创建 migration 文件：
```
backend/base/migration/src/m2025xxxx_meetings.rs
```

Entity 生成（手动编写 `_entities/meetings.rs` 和 `_entities/meeting_members.rs`），遵循与 `calendars` 相同的 `ActiveModel`/`Column`/`Entity`/`Model` 模式。

---

## 3. Proto 扩展

### 3.1 meeting.proto 新增消息

```protobuf
// --- M3 additions to meeting.proto ---

message MeetingCreateRequest {
    string title = 1;
    string password = 2;
    int64 scheduled_at = 3;
    int32 max_participants = 4;
    MeetingSettings settings = 5;
}

message MeetingSettings {
    bool mute_on_entry = 1;
    bool allow_screen_share = 2;
    bool record_enabled = 3;
}

message MeetingCreateResponse {
    MeetingInfo meeting = 1;
}

message MeetingGetListRequest {
    MeetingListFilter filter = 1;
    int32 page = 2;
    int32 page_size = 3;
}

enum MeetingListFilter {
    MEETING_LIST_UNSPECIFIED = 0;
    MEETING_LIST_ACTIVE = 1;
    MEETING_LIST_HISTORY = 2;
    MEETING_LIST_SCHEDULED = 3;
}

message MeetingGetListResponse {
    repeated MeetingInfo meetings = 1;
    int32 total = 2;
}

// Push 通知
message MeetingPushUpdate {
    MeetingInfo meeting = 1;
    MeetingPushAction action = 2;
}

enum MeetingPushAction {
    MEETING_PUSH_UNSPECIFIED = 0;
    MEETING_PUSH_JOINED = 1;
    MEETING_PUSH_LEFT = 2;
    MEETING_PUSH_ENDED = 3;
    MEETING_PUSH_KICKED = 4;
    MEETING_PUSH_ROLE_CHANGED = 5;
    MEETING_PUSH_INVITED = 6;
    MEETING_PUSH_REMINDER = 7;
}

message MeetingMember {
    int64 user_id = 1;
    int32 role = 2;
    int32 status = 3;
    int64 joined_at = 4;
    int64 left_at = 5;
}

// MeetingInfo 新增字段（追加到现有定义）
// 现有: room_id, host_id, member_ids, title, created_at, password, status
// 新增: id, scheduled_at, started_at, ended_at, tenant_id, members, settings, max_participants
```

### 3.2 MeetingInfo 更新

现有 `MeetingInfo` 追加 M3 字段。注意 protobuf 字段号不能重复：

```protobuf
message MeetingInfo {
    string room_id = 1;
    int64 host_id = 2;
    repeated int64 member_ids = 3;
    string title = 4;
    int64 created_at = 5;
    string password = 6;
    MeetingStatus status = 7;
    // M3 additions
    int64 id = 8;
    int64 scheduled_at = 9;
    int64 started_at = 10;
    int64 ended_at = 11;
    int64 tenant_id = 12;
    repeated MeetingMember members = 13;
    MeetingSettings settings = 14;
    int32 max_participants = 15;
}
```

### 3.3 message.proto 新增

```protobuf
message MeetingInvite {
    string room_id = 1;
    int64 meeting_id = 2;
    string title = 3;
    int64 host_id = 4;
    string host_name = 5;
}
```

---

## 4. 后端实现（AppRtc）

### 4.1 新增依赖

`backend/rtc/Cargo.toml` 添加：
- `sea-orm` workspace 引用
- `base` workspace 引用（entities）
- `bcrypt`（密码哈希校验）

### 4.2 处理流程

所有命令通过 `AppRtc::handle_client_packet()` 进入，模式如下：

```rust
fn handle_client_packet(&self, ctx: &AppContext, brief: &UserBrief, packet: &entity::Packet, ws: bool) -> Result<(i32, Vec<u8>)> {
    match packet.cmd() {
        Command::MeetingCreate => self.handle_create(ctx, brief, packet, ws),
        Command::MeetingJoin => self.handle_join(ctx, brief, packet, ws),
        Command::MeetingLeave => self.handle_leave(ctx, brief, packet, ws),
        Command::MeetingEnd => self.handle_end(ctx, brief, packet, ws),
        Command::MeetingGetInfo => self.handle_get_info(ctx, brief, packet, ws),
        Command::MeetingGetList => self.handle_get_list(ctx, brief, packet, ws),
        Command::MeetingKick => self.handle_kick(ctx, brief, packet, ws),
        Command::MeetingSetRole => self.handle_set_role(ctx, brief, packet, ws),
        Command::MeetingInvite => self.handle_invite(ctx, brief, packet, ws),
        _ => Ok((1, vec![])), // unhandled
    }
}
```

### 4.3 各命令行为

| 命令 | 输入 | 输出 | 副作用 |
|------|------|------|--------|
| MEETING_CREATE | MeetingCreateRequest | MeetingCreateResponse | INSERT meetings, INSERT meeting_members (host) |
| MEETING_JOIN | JoinMeetingRequest | JoinMeetingResponse | Validate password, INSERT meeting_members |
| MEETING_LEAVE | LeaveMeetingRequest | LeaveMeetingResponse | UPDATE meeting_members.left_at; if last → END |
| MEETING_END | EndMeetingRequest | EndMeetingResponse | UPDATE meetings.status=ended, ended_at=NOW; push to all members |
| MEETING_GET_INFO | GetMeetingInfoRequest | GetMeetingInfoResponse | SELECT meetings + members |
| MEETING_GET_LIST | MeetingGetListRequest | MeetingGetListResponse | SELECT by tenant_id + user_id, filter by status |
| MEETING_KICK | KickMeetingRequest | KickMeetingResponse | UPDATE member status=kicked; push to target |
| MEETING_SET_ROLE | SetRoleRequest | SetRoleResponse | UPDATE member.role; push to target |
| MEETING_INVITE | InviteMeetingRequest | InviteMeetingResponse | Push MeetingInvite to target users via IM |

### 4.4 Push 通知

复用 `BizHub::gateway.send_packet_to_user` 模式（与 calendar/im 相同）：

```rust
let push = MeetingPushUpdate { meeting: info.into(), action: MeetingPushAction::Joined.into() };
biz.gateway.send_packet_to_user(ctx, &[target_user_id], rid, Command::MeetingPushUpdate, push.encode_to_vec(), true)?;
```

需要新增 `MEETING_PUSH_UPDATE = 1809` 到 command.proto。

### 4.5 与 WS Signaling 的交互

| 场景 | Proto 命令 | WS 消息 |
|------|-----------|---------|
| 创建会议 | MEETING_CREATE → 写入 DB | 客户端收到 response 后，再发 WS `join` 加入房间 |
| 加入会议 | MEETING_JOIN → 校验密码 + 写入 DB | 客户端收到 response 后，再发 WS `join` 加入房间 |
| 离开会议 | MEETING_LEAVE → 更新 DB | 客户端先发 WS `leave`，再发 MEETING_LEAVE |
| 结束会议 | MEETING_END → 更新 DB | 服务端通过 Push 通知所有成员离开房间 |
| 踢出成员 | MEETING_KICK → 更新 DB | 服务端 Push + 可选 WS 推送 kick 消息 |

> **注意**：MEETING_CREATE/MEETING_JOIN 只在 `handle_client_packet(ws=false)` 时处理（HTTP 请求）；
> 实际的 WS `join` 仍然走 `signaling.rs` 内存房间模型。两个系统通过 `room_id` 关联。

---

## 5. SDK 实现

### 5.1 新建 crate

```
sdk/app-meeting/
  Cargo.toml
  src/
    lib.rs          ← AppMeeting (AppTrait), BizMeeting trait
    service.rs      ← MeetingService impl
```

遵循 `app-calendar` 模式：
- `BizMeeting` trait 定义所有 meeting 方法
- `AppMeeting` 实现 `AppTrait`，注册 `ffi_commands()` + `net_commands()`
- `MeetingService` 实现 `BizMeeting`，内部调用 `ctx.invoke(Cmd, req_proto_bytes)`

### 5.2 BizMeeting trait

```rust
#[async_trait]
pub trait BizMeeting: Send + Sync {
    async fn create(&self, req: MeetingCreateRequest) -> Result<MeetingCreateResponse>;
    async fn join(&self, req: JoinMeetingRequest) -> Result<JoinMeetingResponse>;
    async fn leave(&self, req: LeaveMeetingRequest) -> Result<LeaveMeetingResponse>;
    async fn end(&self, req: EndMeetingRequest) -> Result<EndMeetingResponse>;
    async fn get_info(&self, req: GetMeetingInfoRequest) -> Result<GetMeetingInfoResponse>;
    async fn get_list(&self, req: MeetingGetListRequest) -> Result<MeetingGetListResponse>;
    async fn kick(&self, req: KickMeetingRequest) -> Result<KickMeetingResponse>;
    async fn set_role(&self, req: SetRoleRequest) -> Result<SetRoleResponse>;
    async fn invite(&self, req: InviteMeetingRequest) -> Result<InviteMeetingResponse>;
    // Push handler
    async fn on_push_update(&self, push: MeetingPushUpdate);
}
```

### 5.3 注册到 Service

`sdk/service/src/lib.rs` 追加：
```rust
pub mod app_meeting;
pub use app_meeting::*;

// BizHub 新增字段
pub meeting: Arc<Box<dyn BizMeeting>>,

// UnionClientConfig.features 已有 "meeting"
```

---

## 6. Flutter 客户端

### 6.1 API 调用层

创建 `meeting_api.dart`（遵循 calendar 的 `calendar_api.dart` 模式），每个 proto 命令对应一个方法：

```dart
class MeetingApi {
  Future<MeetingCreateResponse> create(MeetingCreateRequest req) => _invoke(Command.MEETING_CREATE, req);
  Future<JoinMeetingResponse> join(JoinMeetingRequest req) => _invoke(Command.MEETING_JOIN, req);
  // ...
}
```

### 6.2 MeetingLogic 扩展

现有 `meeting_logic.dart` 只需扩展 Mesh 通话相关。新增 `meeting_home_logic.dart` 管理会议列表/创建/历史。

| 文件 | 新增内容 |
|------|---------|
| `meeting_logic.dart` | 现有不变（Mesh 通话逻辑） |
| `meeting_home_logic.dart` | 会议列表、创建/预定会议、加入会议、历史记录 |

### 6.3 页面/组件

| 页面/组件 | 说明 |
|-----------|------|
| `MeetingHomePage` | 主入口：显示「创建会议」「加入会议」「预定会议」按钮 + 进行中会议列表 + 历史会议列表 |
| `MeetingCreateSheet` | 底部弹出：标题、密码、设置（静音入会等）|
| `MeetingJoinDialog` | 弹窗：输入会议号 + 密码 |
| `MeetingScheduleSheet` | 预定会议表单：标题、时间、密码、设置，创建时同步写日历日程 |
| `MeetingHistoryList` | 历史会议列表，可查看详情（成员、时长、录制回放入口）|
| `ParticipantPanel` | 会中参会者侧栏：名单 + 角色标识 + 主持人操作菜单（静音/踢出/转让主持）|
| `HostControls` | 主持人控制栏：全体静音、锁定会议、结束会议 |

### 6.4 日历集成

| 场景 | 行为 |
|------|------|
| 创建会议时关联日程 | MeetingCreateSheet 可选「添加到日历」→ 调用 `ScheduleApi.create` 创建日程 |
| 日历详情入会 | 日程详情页显示「加入会议」按钮（schedule.room_id 非空）|
| 日程到点提醒 | 利用日历已有提醒机制，提醒文字含会议链接 |
| 日历触发会议创建 | 创建日历日程时勾选「同时创建会议」→ 先 create meeting, 再 create schedule |

---

## 7. IM 集成

| 场景 | 行为 |
|------|------|
| 邀请消息 | 会前/会中通过 IM 发送 MeetingInvite 卡片消息（含 room_id、title、host_name）|
| 点击入会 | IM 消息卡片点击 → 解析 room_id → 调用 MEETING_JOIN → 进入 MeetingRoomView |
| 群聊发起会议 | 群聊 + 按钮 → 创建会议 → 自动发送 invite 到群聊 |
| 会中分享到 IM | 会中控制栏分享按钮 → 选择聊天 → 发送 invite 卡片 |

IM 消息类型 `MeetingInvite` 在 `message.proto` 定义，后端新增 `send_meeting_invite` 处理。

---

## 8. Web 前端

### 8.1 新增页面/组件

| 页面/组件 | 说明 |
|-----------|------|
| `MeetingHomeView.vue` | 会议首页：创建/加入/预定入口 + 进行中列表 + 历史列表 |
| `ScheduleMeetingDialog.vue` | 预定会议表单弹窗 |
| `MeetingHistory.vue` | 历史会议列表组件 |
| `ParticipantList.vue` | 会中参会者列表（Web 端）|

### 8.2 路由

```
/meeting          → MeetingHomeView (ModuleLayout)
/meeting/:roomId  → MeetingRoomView (FullscreenLayout, 已有)
```

### 8.3 新增 Store 方法

`stores/meeting.ts` 追加：
```typescript
function createMeeting(req: MeetingCreateRequest): Promise<MeetingCreateResponse>
function joinMeeting(roomId: string, password?: string): Promise<JoinMeetingResponse>
function leaveMeeting(roomId: string): Promise<void>
function endMeeting(roomId: string): Promise<void>
function getMeetingInfo(roomId: string): Promise<MeetingInfo>
function getMeetingList(filter: MeetingListFilter): Promise<MeetingGetListResponse>
function kickMember(roomId: string, targetId: number): Promise<void>
function setRole(roomId: string, targetId: number, role: number): Promise<void>
function inviteMembers(roomId: string, targetIds: number[]): Promise<void>
```

### 8.4 Hub 入口

`HubView.vue` 添加会议入口卡片（与 Flutter 端一致），链接到 `/meeting`。

---

## 9. 工作项分解

（详见 todo.md 中 M3 章节）

### 3.1 后端 DB + 迁移
### 3.2 后端 Proto 扩展 + 编译
### 3.3 后端 Handler 实现（9 个命令）
### 3.4 后端 Push 通知
### 3.5 SDK app-meeting crate
### 3.6 Flutter 会议管理 UI
### 3.7 Flutter 日历集成
### 3.8 Flutter IM 集成
### 3.9 Web 前端会议管理
### 3.10 测试

---

## 10. 风险与注意事项

| 风险 | 缓解 |
|------|------|
| WS signaling.rs 的 in-memory room 与 DB meeting 状态不一致 | WS join/leave 不写 DB，只由 proto 命令写入；客户端保证先 proto 命令后 WS 消息的顺序 |
| bcrypt 密码校验增加延迟 | 只有 MEETING_JOIN 需要校验，可在 50ms 内完成，无感知 |
| Push 通知可靠性 | 复用现有 IM push 通道，走 gateway.send_packet_to_user |
| 表设计不足 | meetings.settings 使用 JSONB 保留扩展性，新增设置项无需迁移 |
| 与 M2 代码冲突 | M3 工作主要在 lib.rs 和新增文件，signaling.rs 不动 |

---

## 11. 交付物清单

- [ ] PostgreSQL meetings + meeting_members 表（migration）
- [ ] Sea-ORM entity 定义
- [ ] meeting.proto 扩展（新增消息 + MeetingInfo 追加字段）
- [ ] message.proto MeetingInvite 消息
- [ ] command.proto 追加 MEETING_PUSH_UPDATE = 1809
- [ ] AppRtc 9 个命令的完整 handler 实现
- [ ] Push 通知发送（MeetingPushUpdate）
- [ ] SDK app-meeting crate（BizMeeting trait + MeetingService）
- [ ] Flutter 会议管理（列表/创建/预定/历史）
- [ ] Flutter 会中参会者面板 + 主持人控制
- [ ] Flutter 日历集成
- [ ] Flutter IM 集成
- [ ] Web 前端会议首页 + 创建/预定/历史
- [ ] Web 前端会中参会者列表
- [ ] Hub 会议入口卡片
- [ ] 集成测试覆盖核心场景
