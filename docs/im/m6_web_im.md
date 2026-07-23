# M6: Web 端 IM — 设计方案

> 对应里程碑 `docs/im/milestone.md` Milestone 6

## 1. 概述

在现有 Vue3 SPA 中实现完整的 Web IM 能力。目标是与 Flutter 客户端对齐功能，
共享同一套后端 API 和 proto 协议。

### 1.1 目标功能

| 功能 | 说明 |
|------|------|
| 会话列表 | 与 Flutter 对齐的 Feed 渲染，置顶/免打扰/未读计数 |
| 消息收发 | TEXT/IMAGE/FILE/RICH_TEXT/MARKDOWN/FORWARD，支持回复 |
| 富文本输入 | Quill.js 编辑器，Delta JSON 格式与 Flutter 一致 |
| 图片/文件上传 | 复用 store 模块的上传接口，Dio 改为 Axios |
| @ 提及 | 成员搜索 + 插入 Mention |
| 已读/Reaction | 展示 + 交互 |
| 群管理 | 群资料页、公告、禁言、成员列表（只读展示，编辑引导到桌面端） |
| 实时推送 | WebSocket 接收新消息、Feed 变更、Presence、Typing |
| 日历 | 基础日历视图（复用 meeting/office 布局） |

### 1.2 非目标

- 视频会议（已有 Meeting 模块）
- 协同文档（已有 Office 模块）
- 群管理编辑操作（仅展示，编辑引导到桌面端，减少 M6 范围）
- 搜索功能（M4 已完成服务端，前端可后续补充）
- 多设备管理
- 离线消息

---

## 2. 架构

### 2.1 通信方案

采用**双通道**策略：

| 通道 | 用途 | 协议 | 端点 |
|------|------|------|------|
| HTTP `/api/v1` | 请求-响应（发送消息、拉取列表、Crud 操作） | protobuf over multipart/form-data | `POST /api/v1`（通过 Vite proxy → `localhost:5150`） |
| WebSocket | 实时推送（新消息、Feed 变更、Presence、Typing） | binary protobuf `entity.Packet` 帧 | `wss://host:8889/ws`（直连 gateway） |

#### 2.1.1 HTTP 请求模式

复用 `meetingApi.ts` 的 `protoRequest()` 模式：

```
POST /api/v1
Headers:
  Authorization: Bearer <token>
  cmd: <Command enum value>
  rid: <request id>
Content-Type: multipart/form-data; boundary=xxx
Body: protobuf-encoded request message

Response:
  Status: 200
  Header code: 0 (success) or ErrorCode
  Body: protobuf-encoded entity.Packet { payload: <response message> }
```

#### 2.1.2 WebSocket 推送模式

与后端 gateway 建立二进制 WebSocket 连接：

1. **握手**：HTTP Upgrade 请求携带 `x-buzzing-token` header（JWT）
2. **帧格式**：每个消息是 protobuf 编码的 `entity.Packet`
3. **心跳**：服务端每 15s 发 `WebSocket Ping`，客户端回复 `Pong`
4. **推送类型**：
   - `PUSH_MESSAGES (1211)` — 新消息
   - `PUSH_FEED_LIST (1111)` — Feed 变更
   - `PUSH_PRESENCE (1352)` — 在线状态
   - `PUSH_TYPING (1404)` — 输入状态
   - `PUSH_REACTIONS (1215)` — Reaction 变更
   - `PUSH_ENTITY_CHANGE (1057)` — 实体变更通知
5. **重连**：断线后指数退避重连（1s → 2s → 4s → 8s → 16s max）

### 2.2 页面路由

```
/im                    → IM 首页/会话列表（重定向到 /im/feed）
/im/feed              → 会话列表（左侧面板）
/im/chat/:chatId      → 聊天会话（右侧面板，带会话列表）
/im/chat/:chatId/thread/:msgId  → 消息 Thread
```

路由统一使用 `authGuard` + `tenantGuard`。

### 2.3 布局

采用三栏自适应布局（参考主流 IM Web 端）：

```
┌─────────────────────────────────────────────────┐
│  ModuleLayout: TopBar (模块导航)                  │
├──────────┬──────────────────┬────────────────────┤
│  Panel A │  Panel B         │  Panel C           │
│  会话列表 │  消息列表         │  详情/Thread       │
│  ~300px  │  flex: 1         │  ~320px (可选)     │
│          │                  │                    │
│  FeedList │  ChatView        │  DetailPanel       │
│  (路由  ) │  (路由           │  (路由             │
│  自带)    │  自带)           │  可选)             │
├──────────┴──────────────────┴────────────────────┤
│  HubLayout: 底部状态栏                           │
└─────────────────────────────────────────────────┘
```

- **移动端**（<768px）：单栏，通过路由切换视图
- **桌面端**（≥768px）：三栏同时展示

### 2.4 状态管理

新建 Pinia store `stores/im.ts`，管理：

```typescript
interface IMState {
  // 连接状态
  connected: boolean
  connecting: boolean
  
  // 数据
  feeds: Map<number, Feed>
  chats: Map<number, Chat>
  messages: Map<number, Message[]>
  users: Map<number, User>
  
  // 当前会话
  currentChatId: number | null
  messagePos: number
  
  // UI 状态
  loadingFeeds: boolean
  loadingMessages: boolean
  typingUsers: Map<number, { userId: number; userName: string; expireAt: number }>
}
```

### 2.5 Proto 管理

新建 `services/im/proto.ts` 集中管理 protobuf 加载和编码/解码。
所有 proto 文件通过 Vite `?raw` 导入并注册到同一个 `protobuf.Root`。

---

## 3. 组件树

```
App.vue
└── RouterView
    └── ModuleLayout (TopBar: "IM")
        └── ImHome.vue (桌面端三栏布局)
            ├── FeedPanel.vue (左侧 ~300px)
            │   ├── FeedSearchBar.vue
            │   ├── FeedList.vue
            │   │   └── FeedItem.vue (×N)
            │   └── FeedSkeleton.vue (loading)
            ├── ChatPanel.vue (中间 flex:1)
            │   ├── ChatHeader.vue (群名/用户 + 更多)
            │   ├── MessageList.vue
            │   │   ├── MessageBubble.vue (×N)
            │   │   │   ├── TextMessage.vue
            │   │   │   ├── ImageMessage.vue
            │   │   │   ├── FileMessage.vue
            │   │   │   ├── MarkdownMessage.vue
            │   │   │   ├── ForwardMessage.vue
            │   │   │   ├── SystemMessage.vue
            │   │   │   └── ReplyDecorator.vue (if ref_message_id)
            │   │   ├── DateSeparator.vue
            │   │   └── LoadingIndicator.vue (顶部加载更多)
            │   └── MessageInput.vue
            │       ├── ReplyPreview.vue (引用回复)
            │       ├── RichTextEditor.vue (Quill.js)
            │       └── ToolbarActions.vue (发送/表情/图片/文件)
            └── DetailPanel.vue (右侧 ~320px)
                ├── ThreadView.vue (消息 Thread)
                └── GroupProfile.vue (群资料只读)
```

### 3.1 消息渲染策略

根据 `Message.tpy` (MessageType) 分发：

```typescript
const messageComponents: Record<number, Component> = {
  1: TextMessage,       // TEXT
  2: ImageMessage,      // IMAGE
  3: FileMessage,       // FILE
  4: MarkdownMessage,   // RICH_TEXT_QUILL (老版本)
  11: RichTextMessage,  // RICH_TEXT_QUILL
  12: SystemMessage,    // MEETING_INVITE
  13: MarkdownMessage,  // MARKDOWN
  14: ForwardMessage,   // FORWARD
  15: SystemMessage,    // SYSTEM
  16: TextMessage,      // ANNOUNCEMENT
}
```

### 3.2 文件上传

使用 Axios 直接调用 store 模块的上传接口（不走 protobuf gateway）：

```
POST /api/files/upload
Content-Type: multipart/form-data
Authorization: Bearer <token>
Body: FormData { file: File }

Response: { id, key, url, mime_type, size, width?, height?, thumbnail_key? }
```

上传成功后，将返回的 `fileId` 填入 `Message.files`，然后通过 protobuf gateway 发送消息。

---

## 4. 实施步骤

### Step 1: 基础设施 — 路由 / Layout / Proto 加载

- 新建 `services/im/proto.ts` — 集中加载 proto 文件
- 新建 `services/im/api.ts` — 封装 `protoRequest()` 和所有 IM API 函数
- 新建 `services/im/ws.ts` — WebSocket 客户端类，处理连接/重连/心跳/推送分发
- 新建 `stores/im.ts` — Pinia store，管理所有 IM 数据和连接状态
- 新建 `views/im/ImHome.vue` — 三栏布局容器
- 注册 IM 路由

### Step 2: 会话列表 (Feed)

- `FeedPanel.vue` — 左侧面板容器
- `FeedItem.vue` — 会话条目（头像、名称、最后消息、未读计数、时间）
- 实现 `PUSH_FEED_LIST` 推送处理 → 更新 store
- 实现 Feed 拉取 `pullFeedList()` → 首次加载 + 分页

### Step 3: 消息基础 — 消息列表 + 发送文本

- `ChatPanel.vue` — 聊天面板容器
- `ChatHeader.vue` — 会话头部（返回、名称、更多按钮）
- `MessageList.vue` — 消息列表（滚动加载、自动滚动到底部）
- 消息气泡基类 + `TextMessage.vue`
- `MessageInput.vue` — 文本输入框 + 发送按钮
- 实现 `sendMessage()` → 发送 TEXT 消息
- 实现 `PUSH_MESSAGES` 推送处理 → 追加到消息列表

### Step 4: 富文本输入 + 回复

- `RichTextEditor.vue` — 集成 Quill.js，Delta JSON 格式
- 回复预览 `ReplyPreview.vue` — 引用消息预览 + 取消
- 实现 `RICH_TEXT_QUILL`（tpy=11）消息发送

### Step 5: 图片/文件消息

- 上传组件 `FileUploader.vue` — 文件选择 + 进度
- `ImageMessage.vue` — 图片预览（缩略图 → 原图）
- `FileMessage.vue` — 文件展示（图标 + 文件名 + 大小 + 下载）
- 实现 file upload → send 流程

### Step 6: 富文本消息渲染

- `RichTextMessage.vue` — Quill Delta → HTML 渲染
- `MarkdownMessage.vue` — Markdown 渲染（使用 marked 或类似库）

### Step 7: 消息交互 — Reaction + 已读 + 更多操作

- Reaction 展示 + 点击切换
- 已读状态展示（消息底部小图标）
- 消息长按/右键菜单 — 回复/转发/收藏/撤回/删除
- 转发消息 UI

### Step 8: @ 提及 + Typing + Presence

- @ 提及弹出层 `MentionPicker.vue` — 成员搜索
- 输入状态推送 + 展示 "正在输入..."
- 在线状态展示（头像绿点）

### Step 9: 消息 Thread

- `ThreadView.vue` — 右侧面板 Thread 消息列表
- 从消息进入 Thread，展示父消息 + 回复列表
- 发送 Thread 回复

### Step 10: 群资料页（只读）

- `GroupProfile.vue` — 右侧面板展示群信息
- 群公告、成员列表（分页）、禁言状态
- 编辑操作引导到桌面端

### Step 11: 基础日历

- 日历视图（简单版）— 月视图列表
- 日程展示

### Step 12: 打磨

- 加载状态、空状态、错误状态
- 滚动加载更多
- 消息未送达/发送中状态
- WS 重连状态提示

---

## 5. 关键 API 清单

| 功能 | Command | Request | Response |
|------|---------|---------|----------|
| 拉取 Feed | 1100 | `feed.PullFeedListRequest` | `feed.PullFeedListResponse` |
| 进入会话 | 1102 | `chat.EnterChatRequest` | `chat.EnterChatResponse` |
| 发送消息 | 1203 | `message.SendMessageRequest` | `message.SendMessageResponse` |
| 拉取消息 | 1213 | `message.GetMessageByRangeRequest` | `message.GetMessageByRangeResponse` |
| 设置 Reaction | 1214 | `message.SetReactionRequest` | `message.SetReactionResponse` |
| 转发消息 | 1216 | `message.ForwardMessageRequest` | `message.ForwardMessageResponse` |
| 撤回消息 | 1204 | `message.RevokeMessageRequest` | `message.RevokeMessageResponse` |
| 收藏消息 | 1500 | `message.FavoriteMessageRequest` | `message.FavoriteMessageResponse` |
| 获取 Thread | 1208 | `thread.GetMessageThreadRequest` | `thread.GetMessageThreadResponse` |
| 发送 Typing | 1403 | `typing.TypingRequest` | `typing.TypingResponse` |
| 更新 Presence | 1351 | `presence.PresenceUpdateRequest` | `presence.PresenceUpdateResponse` |
| 获取用户 | 1300 | `user.GetUserByIdsRequest` | `user.GetUserByIdsResponse` |

---

## 6. 推送消息清单

| Push | Command | Payload | 处理逻辑 |
|------|---------|---------|---------|
| PUSH_MESSAGES | 1211 | `message.PushMessages` | 追加消息到 store，更新 Feed badge |
| PUSH_FEED_LIST | 1111 | `feed.PushFeedList` | 更新 Feed 列表（新增/更新/删除） |
| PUSH_REACTIONS | 1215 | `message.PushReactions` | 更新消息的 Reaction 数据 |
| PUSH_MESSAGE_READSTATE | 1212 | `message.PushMessageReadState` | 更新消息已读状态 |
| PUSH_PRESENCE | 1352 | `presence.PushPresence` | 更新用户在线状态 |
| PUSH_TYPING | 1404 | `typing.PushTyping` | 显示/隐藏输入指示器 |
| PUSH_ENTITY_CHANGE | 1057 | `entity.EntityChange` | 触发实体重新加载 |
| PUSH_USER_INFO | 1302 | `user.GetUserByIdsResponse` | 更新用户信息 |

---

## 7. 与 Flutter 客户端的差异

| 项目 | Flutter | SPA |
|------|---------|-----|
| 通信 | SDK (Rust) → WS/HTTP | Axios + native WebSocket |
| Proto 编码 | 编译期生成 `.pb.dart` | 运行时 `protobufjs` 解析 |
| 富文本 | flutter_quill | Quill.js |
| 上传 | Dio (dart) | Axios (js) |
| 状态管理 | Riverpod | Pinia |
| 路由 | go_router | vue-router |
| 本地化 | i18n (slang) | 硬编码中文 |
| 群管理编辑 | 完整 CRUD | 只读展示，引导到桌面端 |

---

## 8. 文件结构

```
frontend/src/
├── services/
│   ├── im/
│   │   ├── proto.ts           # Proto 加载与编码/解码
│   │   ├── api.ts              # IM HTTP API (protoRequest wrapper)
│   │   └── ws.ts               # WebSocket 客户端
├── stores/
│   └── im.ts                   # IM Pinia store
├── views/
│   └── im/
│       ├── ImHome.vue           # 三栏布局容器
│       ├── feed/
│       │   ├── FeedPanel.vue
│       │   ├── FeedList.vue
│       │   └── FeedItem.vue
│       ├── chat/
│       │   ├── ChatPanel.vue
│       │   ├── ChatHeader.vue
│       │   ├── MessageList.vue
│       │   ├── MessageInput.vue
│       │   ├── message-types/
│       │   │   ├── TextMessage.vue
│       │   │   ├── ImageMessage.vue
│       │   │   ├── FileMessage.vue
│       │   │   ├── MarkdownMessage.vue
│       │   │   ├── RichTextMessage.vue
│       │   │   ├── ForwardMessage.vue
│       │   │   └── SystemMessage.vue
│       │   └── components/
│       │       ├── ReplyPreview.vue
│       │       ├── ReactionBar.vue
│       │       ├── ReadState.vue
│       │       └── MentionPicker.vue
│       └── detail/
│           ├── DetailPanel.vue
│           ├── ThreadView.vue
│           └── GroupProfile.vue
├── router/
│   └── index.ts                # 添加 IM 路由
```
