# M3: Bot 高级能力 — 详细设计方案

> 设计目标：为 Bot 提供交互式消息卡片、互动回复、定时任务与群管理能力，使 Bot 体验从纯文本升级为富交互。
>
> 约定：交互式卡片消息由 Proto 定义、JSON 渲染，服务端以 `MessageType.INTERACTIVE_CARD = 17` 存储在 `messages` 表的 `msg_type` 字段。

---

## 一、交互式消息卡片

### 1.1 Proto 定义

**`proto/card.proto`（新增）：**

```protobuf
syntax = "proto3";
package card;

message CardHeader {
  string title = 1;
  string color = 2;    // "blue", "green", "red", "yellow", "grey", "default"
}

message CardText {
  string content = 1;
  bool markdown = 2;
}

message CardButton {
  string text = 1;
  string value = 2;    // 回调时回传
  string style = 3;    // "primary", "default", "danger"
  string url = 4;      // 可选，点击跳转 URL
}

message CardImage {
  string image_key = 1;  // store 文件 key
  string alt = 2;
  string title = 3;
}

message CardDivider {}

message CardElement {
  oneof element {
    CardText text = 1;
    CardButton button = 2;
    CardImage image = 3;
    CardDivider divider = 4;
  }
}

message InteractiveCard {
  CardHeader header = 1;
  repeated CardElement elements = 2;
  string template_id = 3;    // 可选，模板 ID 用于 Bot 快速生成
}
```

**`proto/entity.proto` 扩展：**

```protobuf
enum MessageType {
  // ... existing values
  INTERACTIVE_CARD = 17;
}
```

**`proto/openapp.proto` 扩展：**

```protobuf
message CardActionCallback {
  string app_id = 1;
  string action_value = 2;
  int64 message_id = 3;
  int64 user_id = 4;
  int64 chat_id = 5;
  string user_name = 6;
  string message_content = 7;  // 当前卡片 JSON
}
```

### 1.2 卡片 JSON 存储格式

服务端收到卡片消息后，将 `content` 序列化为 JSON 字符串存入 `messages.content`：

```json
{
  "header": {
    "title": "任务确认",
    "color": "blue"
  },
  "elements": [
    { "tag": "text", "content": "请确认以下任务已完成：" },
    { "tag": "text", "content": "- 需求评审 ✅", "markdown": true },
    { "tag": "divider": {} },
    { "tag": "button", "text": "确认完成", "value": "confirm_task", "style": "primary" },
    { "tag": "button", "text": "驳回", "value": "reject_task", "style": "danger" }
  ]
}
```

### 1.3 卡片渲染引擎（Flutter 客户端）

在 Flutter 中新增 `InteractiveCardWidget`：

```
buzzing/lib/
└── widgets/
    ├── message_card.dart         — 卡片渲染入口
    ├── card_header.dart          — 卡片标题栏（带颜色标识）
    ├── card_element.dart         — 元素分发
    ├── card_text_element.dart    — 文本元素
    ├── card_button_element.dart  — 按钮元素（含点击事件绑定）
    ├── card_image_element.dart   — 图片元素
    └── card_divider_element.dart — 分割线
```

渲染逻辑：
- `MessageWidget` 中判断 `msg_type == 17` → 渲染 `InteractiveCardWidget`
- `InteractiveCardWidget` 解析 `content` JSON → 构建 header + elements 列表
- 按钮点击 → 构造 `CardActionPacket` → 通过 WS 发送到服务端
- 服务端回调 Bot Webhook → Bot 返回新卡片内容 → 服务端推送 `card_update` 命令

**卡片呈现规格：**

| 元素 | 宽度 | 样式 |
|------|------|------|
| 卡片容器 | 客户端最大宽度 400px | 圆角 8px, 背景 #FFF, 阴影 |
| Header | 100% | 左竖条着色 + 标题文字 16sp bold |
| 文本 | 100% | 14sp, #333 |
| Markdown | 100% | 渲染行内 Markdown |
| 按钮 | 等分行内 | 圆角 6px, 主按钮品牌色, 次按钮灰色边框 |
| 图片 | 原比例最大 100% | 圆角 4px |
| 分割线 | 100% | 1px #E8E8E8 |

### 1.4 卡片生命周期

```
[Bot]                    [Backend]                    [Client]              [User]
  |                          |                          |                     |
  |-- POST send_card ------->|                          |                     |
  |   (card JSON)           |-- 存储到 messages        |                     |
  |                          |-- push entity ---------->|                     |
  |                          |   (msg_type=17)          |-- 渲染卡片           |
  |                          |                          |                     |
  |                          |                          |<-- 点击按钮 ---------|
  |                          |                          |                     |
  |                          |<-- card_action ---------|                     |
  |                          |   (packet)               |                     |
  |                          |                          |                     |
  |                          |-- POST /webhook -------->|                     |
  |                          |   CardActionCallback     |                     |
  |<-- card_update ---------|                          |                     |
  |   (new card JSON)       |                          |                     |
  |                          |-- push entity ---------->|                     |
  |                          |   (card_update)          |-- 更新卡片渲染       |
```

### 1.5 服务端流程

**Bot 发送卡片消息：**

复用 M1 `POST /openapi/v1/bot/message` 接口，增加 `msg_type = "interactive_card"`：

```json
{
  "chat_id": 12345,
  "msg_type": "interactive_card",
  "content": {
    "header": { "title": "确认", "color": "blue" },
    "elements": [
      { "tag": "button", "text": "确认", "value": "ok", "style": "primary" }
    ]
  }
}
```

服务端处理：
1. 验证 content 符合 InteractiveCard schema
2. 序列化 JSON → `content` bytes
3. 设置 `msg_type = 17`
4. 调用 `BizIm::send_message()`

**卡片按钮回调处理：**

客户端点击按钮时发送命令 `CMD_CARD_ACTION = 2001`（新增命令码）：

```protobuf
message CardActionRequest {
  int64 message_id = 1;
  string action_value = 2;
  int64 chat_id = 3;
}

message CardActionResponse {
  bool success = 1;
}
```

服务端 `handle_client_packet` 收到 `CMD_CARD_ACTION`：
1. 解析请求 → 获取 `message_id`, `action_value`, `chat_id`, `user_id`
2. 查询消息记录 → 获取 `app_id`（消息发送者对应的 Bot 应用）
3. 查询 Bot webhook_url
4. 构造 `CardActionCallback` → POST 到 bot webhook
5. 返回成功（不等待回调）

若 Bot 需要更新卡片，调用卡片更新 API：

```
PATCH /openapi/v1/bot/card/{message_id}
{
  "content": {
    "header": { "title": "已确认", "color": "green" },
    "elements": [
      { "tag": "text", "content": "张三 已确认完成" },
      { "tag": "button", "text": "查看详情", "value": "view", "style": "primary" }
    ]
  }
}
```

更新逻辑：
1. 验证 `message_id` 属于该 Bot
2. 以卡片消息更新 `messages.content`（不改变 msg_type）
3. 推送 `CMD_CARD_UPDATE`（命令码 2002）→ 客户端更新 UI
4. **不生成新消息**，原地替换内容

### 1.6 命令码扩展

```protobuf
// card.proto 对应的命令码
CMD_CARD_ACTION = 2001;   // 客户端 → 服务端：按钮点击回调
CMD_CARD_UPDATE = 2002;   // 服务端 → 客户端：卡片内容更新推送
CMD_CARD_TEMPLATE = 2003; // 客户端 → 服务端：获取卡片模板
```

### 1.7 SDK 端扩展

在 `sdk/` 中新增卡片工具函数：

```rust
// sdk/src/biz/card.rs
pub struct CardBuilder {
    header: CardHeader,
    elements: Vec<CardElement>,
}

impl CardBuilder {
    pub fn new(title: &str, color: &str) -> Self;
    pub fn add_text(&mut self, content: &str, markdown: bool) -> &mut Self;
    pub fn add_button(&mut self, text: &str, value: &str, style: &str) -> &mut Self;
    pub fn add_image(&mut self, image_key: &str, alt: &str) -> &mut Self;
    pub fn add_divider(&mut self) -> &mut Self;
    pub fn build(&self) -> String;  // 输出 JSON string
}
```

---

## 二、Bot 互动回复

### 2.1 回复关联（线程）

Bot 发送消息时支持 `reply_to` 参数：

```json
{
  "chat_id": 12345,
  "msg_type": "text",
  "content": { "text": "这是回复" },
  "reply_to": 67890
}
```

服务端：将 `reply_to` 设置到 `Message` proto 的 `reply_to_id` 字段，客户端展示引用回复样式。

### 2.2 @提及感知

Bot 消息中自动检测 `@user_id` 语法：

- 事件推送 `im.message.receive` 的 payload 中增加 `mentions` 字段（M1 已有）
- Bot API `GET /openapi/v1/bot/messages` 返回消息时附带 `mentions` 列表
- Bot 发送消息时支持 `mention_all` 参数：

```json
{
  "chat_id": 12345,
  "msg_type": "text",
  "content": { "text": "@所有人 开会了" },
  "mention_all": true
}
```

### 2.3 表情回应（Reaction）事件

**新增事件类型：**

| 事件类型 | 触发时机 | payload 补充字段 |
|----------|---------|----------------|
| `im.message.reaction_added` | 用户对 Bot 消息添加 Reaction | `reaction_type`, `message_id` |
| `im.message.reaction_removed` | 用户对 Bot 消息移除 Reaction | `reaction_type`, `message_id` |

**Bot 发送 Reaction：**

```
POST /openapi/v1/bot/message/{message_id}/reactions
{
  "reaction_type": "👍"
}
```

**事件推送示例：**

```json
{
  "event_id": "evt_xxxxx",
  "app_id": "app_xxxxx",
  "type": "im.message.reaction_added",
  "timestamp": 1712345678000,
  "payload": {
    "message_id": 67890,
    "chat_id": 12345,
    "user_id": 54321,
    "user_name": "张三",
    "reaction_type": "👍"
  }
}
```

---

## 三、定时/周期任务

### 3.1 数据模型

`open_app_scheduled_tasks` 表：

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `bigint PK` | Snowflake ID |
| `app_id` | `bigint FK → open_apps.id` | 所属应用 |
| `name` | `varchar(128)` | 任务名称 |
| `cron_expr` | `varchar(64)` | Cron 表达式 |
| `action_type` | `varchar(32)` | 动作类型：`send_message`, `call_webhook` |
| `action_config` | `jsonb` | 动作配置（消息模板/URL + payload） |
| `chat_id` | `bigint` | 目标群聊（仅 send_message 时） |
| `status` | `smallint` | 0=禁用, 1=启用 |
| `last_run_at` | `timestamptz` | 上次执行时间 |
| `next_run_at` | `timestamptz` | 下次执行时间 |
| `created_at` | `timestamptz` | 创建时间 |
| `updated_at` | `timestamptz` | 更新时间 |

### 3.2 任务调度器

使用 `tokio-cron-scheduler` crate：

```rust
// backend/openapp/src/services/scheduler.rs

use tokio_cron_scheduler::JobScheduler;

pub struct TaskScheduler {
    sched: Arc<JobScheduler>,
}

impl TaskScheduler {
    pub async fn start(ctx: &AppContext) -> Self {
        let sched = JobScheduler::new().await.unwrap();
        sched.start().await.unwrap();
        
        // 启动时加载所有启用的定时任务
        let tasks = OpenAppScheduledTaskModel::find_enabled(ctx.db).await;
        for task in tasks {
            Self::register_job(&sched, ctx, task).await;
        }
        
        Self { sched: Arc::new(sched) }
    }
    
    async fn register_job(sched: &JobScheduler, ctx: &AppContext, task: ScheduledTask) {
        sched.add(Job::new_async(task.cron_expr.as_str(), move |_uuid, _lock| {
            Box::pin(async move {
                let ctx = /* ... */;
                match task.action_type.as_str() {
                    "send_message" => Self::execute_send_message(&ctx, &task).await,
                    "call_webhook" => Self::execute_call_webhook(&ctx, &task).await,
                    _ => {}
                }
                // 更新 last_run_at / next_run_at
            })
        })).await.unwrap();
    }
    
    async fn execute_send_message(ctx: &AppContext, task: &ScheduledTask) {
        // 根据 action_config 中的模板构造消息
        // 调用 BizIm::send_message() 发送到 task.chat_id
    }
    
    async fn execute_call_webhook(ctx: &AppContext, task: &ScheduledTask) {
        // POST action_config.url 发送 action_config.payload
    }
}
```

### 3.3 Bot 注册定时任务 API

Bot 通过 API 注册定时任务：

```
POST /openapi/v1/bot/scheduled_tasks
{
  "name": "每日早报",
  "cron_expr": "0 9 * * *",
  "action_type": "send_message",
  "chat_id": 12345,
  "action_config": {
    "msg_type": "markdown",
    "content": { "markdown": "## 🌅 早报\n\n日期: {{date}}\n天气: 晴\n新闻: ..." }
  }
}
```

字段说明：
- `cron_expr`：标准 5 段 cron（分 时 日 月 周）
- `action_config.content` 支持模板变量：`{{date}}`, `{{time}}`, `{{weekday}}`
- `call_webhook` 类型的 `action_config.url` 输出到 Bot 配置的 webhook_url

**查询定时任务：**
```
GET /openapi/v1/bot/scheduled_tasks?page=1&page_size=20
```

**修改定时任务：**
```
PUT /openapi/v1/bot/scheduled_tasks/{task_id}
```

**删除定时任务：**
```
DELETE /openapi/v1/bot/scheduled_tasks/{task_id}
```

**暂停/恢复任务：**
```
POST /openapi/v1/bot/scheduled_tasks/{task_id}/pause
POST /openapi/v1/bot/scheduled_tasks/{task_id}/resume
```

### 3.4 开发者后台管理

在 Bot 配置页新增「定时任务」Tab：
- 任务列表展示（名称、cron 表达式、状态、下次执行时间）
- 新增/编辑定时任务表单
- 操作：暂停/恢复/删除

---

## 四、Bot 管理能力

### 4.1 Bot 创建群聊

```
POST /openapi/v1/bot/chats
{
  "name": "项目协作群",
  "description": "用于项目讨论",
  "member_ids": [54321, 54322, 54323]
}
```

返回 `chat_id`。创建后 Bot 自动加入群聊。

实现：
1. 调用 IM 模块 `create_chat` 逻辑，设置 Bot 为群主
2. 添加指定 members
3. 返回 `chat_id`

### 4.2 Bot 邀请/移除成员

```
POST /openapi/v1/bot/chats/{chat_id}/members
{
  "member_ids": [54324, 54325]
}
```

```
DELETE /openapi/v1/bot/chats/{chat_id}/members
{
  "member_ids": [54321]
}
```

实现：调用 IM 模块 `add_chatters` / `remove_chatters`，以 Bot 用户身份执行。

### 4.3 Bot 设置群公告

```
PUT /openapi/v1/bot/chats/{chat_id}/announcement
{
  "announcement": "这是群公告内容"
}
```

### 4.4 权限声明

Bot 管理类 API 需要在 **OAuth 授权/应用安装** 时声明权限：

```json
{
  "scope": "bot:chat:write",
  "description": "创建和管理群聊",
  "required": true
}
```

新增 Bot 管理 scope：

| Scope | 权限说明 |
|-------|---------|
| `bot:chat:write` | 创建群聊、管理群成员 |
| `bot:chat:read` | 读取群信息 |
| `bot:announcement:write` | 设置群公告 |

Bot 调用管理 API 时，需确认应用已获得对应 scope（通过 Tenant Access Token 的 scopes 字段校验）。

### 4.5 安全与限制

- Bot 每个自然日最多创建 50 个群聊（防滥用）
- Bot 创建的群聊必须包含 Bot 自身
- Bot 不能将其他 Bot 移出群聊
- Bot 不能删除群聊（仅可解散自己创建的群，需额外 `bot:chat:admin` scope）

---

## 五、后端模块扩展

### 5.1 模块文件树扩展

```
backend/openapp/src/
├── lib.rs                       (M1 + M2 + M3 routes)
├── middleware.rs
├── error.rs
├── handlers/
│   ├── mod.rs
│   ├── auth.rs, app.rs, bot.rs  (M1)
│   ├── open_api.rs              (M2)
│   ├── oauth.rs                 (M2)
│   └── card.rs                  (M3 新增)
│       ├── send_card (通过 bot/message 复用)
│       ├── update_card
│       └── handle_card_action
├── models/
│   ├── mod.rs
│   ├── app.rs, bot.rs           (M1)
│   ├── authorization.rs, user_token.rs, api_stat.rs, outgoing_webhook.rs (M2)
│   └── scheduled_task.rs        (M3 新增)
├── services/
│   ├── mod.rs
│   ├── auth.rs, webhook.rs      (M1)
│   ├── oauth.rs                 (M2)
│   └── scheduler.rs             (M3 新增)
│       ├── TaskScheduler struct
│       ├── start/stop/reload
│       ├── register_job / remove_job
│       └── execute_send_message / execute_call_webhook
```

### 5.2 Cargo.toml 新增依赖

```toml
tokio-cron-scheduler = "0.11"
```

### 5.3 新增 BizIm 接口（M3）

```rust
#[async_trait]
pub trait BizIm: Send + Sync {
    // M1 + M2 已有接口...
    
    // M3 新增
    async fn create_bot_chat(ctx: &AppContext, brief: &UserBrief, name: &str, desc: &str, member_ids: &[i64]) -> ModelResult<i64>;
    async fn add_chat_members(ctx: &AppContext, brief: &UserBrief, chat_id: i64, member_ids: &[i64]) -> ModelResult<()>;
    async fn remove_chat_members(ctx: &AppContext, brief: &UserBrief, chat_id: i64, member_ids: &[i64]) -> ModelResult<()>;
    async fn set_chat_announcement(ctx: &AppContext, brief: &UserBrief, chat_id: i64, announcement: &str) -> ModelResult<()>;
    async fn add_message_reaction(ctx: &AppContext, brief: &UserBrief, message_id: i64, reaction: &str) -> ModelResult<()>;
    async fn remove_message_reaction(ctx: &AppContext, brief: &UserBrief, message_id: i64, reaction: &str) -> ModelResult<()>;
}
```

---

## 六、消息流时序

### 卡片按钮点击 → 回调 Bot → 更新卡片

```
[User Client]              [Backend]                    [Bot Webhook]
      |                        |                             |
      |-- CMD_CARD_ACTION ---->|                             |
      |   (message_id,        |                             |
      |    action_value,      |                             |
      |    chat_id)           |                             |
      |                        |-- 查找消息 → 获取 app_id   |
      |                        |-- 查询 bot webhook_url     |
      |                        |                             |
      |                        |-- POST card_callback ------>|
      |                        |   { action_value, user_id, |
      |                        |     message_id, chat_id }   |
      |                        |                             |
      |                        |<-- 200 OK (异步)            |
      |<-- CMD_CARD_ACTION ----|                             |
      |   RESP (success)      |                             |
      |                        |                             |
      |                        |   [Bot 处理业务逻辑后]      |
      |                        |<-- PATCH /bot/card/{id} ---|
      |                        |   (new card JSON)           |
      |                        |-- 更新 messages.content    |
      |<-- CMD_CARD_UPDATE ---|                             |
      |   (new card JSON)     |                             |
      |-- 重新渲染卡片 -------|                             |
```

---

## 七、实施顺序建议

```
Phase A: 交互式卡片（核心）
  Step 1: Proto 定义（card.proto + entity.proto 扩展）
  Step 2: 服务端卡片发送/更新 API + card_action 回调
  Step 3: Flutter 卡片渲染组件
  Step 4: SDK CardBuilder 工具

Phase B: 互动回复
  Step 5: 回复关联 + @提及增强
  Step 6: Reaction 事件 + API

Phase C: 定时任务
  Step 7: DB migration + scheduler service
  Step 8: Bot CRUD API for scheduled tasks

Phase D: Bot 管理
  Step 9: BizIm 接口扩展 + bot 管理 API
  Step 10: 权限 scope 校验
```
