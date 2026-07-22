# M1: 开放平台基础 — 详细设计方案

> 设计目标：构建开放平台核心能力，包含 App 管理、Bot 消息、事件订阅三大子系统。
>
> 约定：开放平台 API 统一为 REST/JSON 风格，与客户端内 Protobuf 通信分离。

---

## 一、数据模型

### 1.1 open_apps 表

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `bigint PK` | Snowflake ID |
| `tenant_id` | `bigint` | 所属租户 |
| `name` | `varchar(128)` | 应用名称 |
| `description` | `text` | 应用描述 |
| `app_type` | `smallint` | 类型：1=Bot, 2=Webhook, 3=API only |
| `app_id` | `varchar(32) UNIQUE` | 公开标识 `app_xxx` |
| `app_secret` | `varchar(64)` | 密钥（加密存储） |
| `scopes` | `text[]` | 权限声明列表，如 `["im:message:write"]` |
| `owner_id` | `bigint` | 创建者用户 ID |
| `status` | `smallint` | 状态：0=禁用, 1=启用 |
| `created_at` | `timestamptz` | 创建时间 |
| `updated_at` | `timestamptz` | 更新时间 |
| `deleted_at` | `timestamptz` | 软删除时间 |

### 1.2 open_app_bots 表

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `bigint PK` | Snowflake ID |
| `app_id` | `bigint FK → open_apps.id` | 关联应用 |
| `bot_user_id` | `bigint FK → users.id` | Bot 用户 ID |
| `webhook_url` | `varchar(512)` | 事件回调 URL |
| `webhook_secret` | `varchar(64)` | Webhook 签名密钥 |
| `event_types` | `text[]` | 订阅事件类型列表 |
| `status` | `smallint` | 0=禁用, 1=启用 |
| `created_at` | `timestamptz` | 创建时间 |

### 1.3 users 表扩展

| 新增字段 | 类型 | 说明 |
|----------|------|------|
| `bot_app_id` | `bigint FK → open_apps.id NULL` | 非空时为 Bot 账号 |

- `users.type` 新增枚举值 `USER_TYPE_BOT = 3`
- Bot 用户无密码、不能登录、无个人信息
- Bot 用户头像使用应用图标自动生成

---

## 二、API 设计

### 2.1 Response 统一格式

```json
{
  "code": 0,
  "message": "success",
  "data": { ... }
}
```

错误码复用 `ErrorCode` Proto 枚举。

### 2.2 鉴权

**两种鉴权方式：**

| 方式 | Header | 用途 |
|------|--------|------|
| User JWT | `Authorization: Bearer <user_jwt>` | 应用管理（开发者后台） |
| Tenant Access Token | `Authorization: Bearer <tenant_token>` | Bot API 调用 |

**Tenant Access Token 签发：**

```
POST /openapi/auth/tenant_access_token
Content-Type: application/json

{
  "app_id": "app_xxxxx",
  "app_secret": "secret_xxxxx"
}
```

响应：

```json
{
  "code": 0,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "expire": 7200
  }
}
```

Token 载荷（JWT claims）：

```json
{
  "type": "openapp",
  "app_id": "app_xxxxx",
  "app_db_id": 12345,
  "tenant_id": 100,
  "scopes": ["im:message:write"],
  "exp": 1712345678,
  "iat": 1712338478
}
```

**AppAuth 提取器：** 自定义 axum extractor，验证 tenant_access_token → 返回 `AppBrief { app_id, app_db_id, tenant_id, scopes }`。

### 2.3 App 管理 API（User JWT 鉴权）

**创建应用：**

```
POST /openapi/v1/apps
Content-Type: application/json

{
  "name": "天气 Bot",
  "description": "每日推送天气预报",
  "app_type": 1
}
```

```json
{
  "code": 0,
  "data": {
    "id": 12345,
    "app_id": "app_a1b2c3d4",
    "app_secret": "sk_d7e8f9g0h1i2j3k4l5m6n7o8p9q0r1s2t3u4v5w6x7y8z9",
    "name": "天气 Bot",
    "app_type": 1,
    "scopes": [],
    "bot": {
      "bot_user_id": 98765,
      "webhook_url": null,
      "event_types": []
    },
    "status": 1
  }
}
```

> 创建应用的同时：生成 `app_id`（`app_` + 随机 8 字节 hex）、生成 `app_secret`（`sk_` + 随机 32 字节 hex）、创建 Bot 用户（当 `app_type = 1` 时）、创建 `open_app_bots` 记录。

**查询应用列表：**

```
GET /openapi/v1/apps?page=1&page_size=20
```

**查询应用详情：**

```
GET /openapi/v1/apps/{app_id}
```

**修改应用：**

```
PUT /openapi/v1/apps/{app_id}
{
  "name": "...",
  "description": "...",
  "scopes": ["im:message:write"]
}
```

**删除应用：**

```
DELETE /openapi/v1/apps/{app_id}
```

（软删除，同时禁用 Bot 用户）

**轮换密钥：**

```
POST /openapi/v1/apps/{app_id}/rotate_secret
```

```json
{
  "code": 0,
  "data": { "app_secret": "sk_new_secret..." }
}
```

### 2.4 Bot 配置 API（User JWT 鉴权）

**配置 Webhook：**

```
PUT /openapi/v1/apps/{app_id}/bot
{
  "webhook_url": "https://example.com/callback",
  "event_types": ["im.message.receive", "im.group.added_bot"]
}
```

### 2.5 Bot 消息 API（Tenant Access Token 鉴权）

**消息类型：**

| msg_type | content 格式 | 说明 |
|----------|-------------|------|
| `text` | `{ "text": "hello" }` | 纯文本 |
| `markdown` | `{ "markdown": "**bold**" }` | Markdown |
| `image` | `{ "image_key": "store_file_id" }` | 图片（先上传到 store） |
| `file` | `{ "file_key": "store_file_id" }` | 文件（先上传到 store） |

**发送消息：**

```
POST /openapi/v1/bot/message
{
  "chat_id": 12345,
  "msg_type": "text",
  "content": { "text": "Hello from Bot!" }
}
```

```json
{
  "code": 0,
  "data": { "message_id": 67890 }
}
```

实现流程：
1. 解析请求，构造 `Message` proto（设置 `from_id = bot_user_id`, `chat_id`, `content`）
2. 通过 `BizIm::send_message()` 调用 IM 模块发送消息
3. 返回 message_id

**编辑消息：**

```
PATCH /openapi/v1/bot/message/{message_id}
{
  "msg_type": "text",
  "content": { "text": "Updated content" }
}
```

**撤回消息：**

```
POST /openapi/v1/bot/message/{message_id}/recall
```

---

## 三、事件订阅（Webhook）

### 3.1 事件列表（M1 支持）

| 事件类型 | 触发时机 | 说明 |
|----------|---------|------|
| `im.message.receive` | 有人 @Bot 或给 Bot 发私聊 | 推送消息内容 |
| `im.group.added_bot` | Bot 被加入群聊 | 推送群信息 |
| `im.group.removed_bot` | Bot 被移出群聊 | 推送群信息 |

### 3.2 事件推送格式

```json
{
  "event_id": "evt_a1b2c3d4e5f6",
  "app_id": "app_xxxxx",
  "type": "im.message.receive",
  "timestamp": 1712345678000,
  "payload": {
    "message_id": 67890,
    "chat_id": 12345,
    "chat_type": 2,
    "sender": {
      "user_id": 54321,
      "name": "张三"
    },
    "msg_type": "text",
    "content": { "text": "@Bot 天气怎么样？" },
    "mentions": ["98765"]
  }
}
```

### 3.3 签名验证

```
X-Buzzing-Signature: sha256=<HMAC-SHA256(request_body, webhook_secret)>
X-Buzzing-Timestamp: 1712345678000
```

开发者验证流程：
1. 拼接 `timestamp + "." + request_body`
2. 用 `webhook_secret` 做 HMAC-SHA256
3. 对比 `X-Buzzing-Signature` header

### 3.4 重试策略

| 重试次数 | 等待时间 |
|----------|---------|
| 1 | 5 秒 |
| 2 | 30 秒 |
| 3 | 300 秒（5 分钟） |

- 超时时间：10 秒
- 非 2xx 响应视为失败
- 3 次重试均失败 → 丢弃事件，记录错误日志

### 3.5 事件去重

- `event_id` = HMAC-SHA256(`app_id + type + timestamp + seq`)[:12]
- 开发者应记录已处理 `event_id`，幂等处理

---

## 四、后端模块结构

### 4.1 Cargo.toml

```toml
[package]
name = "openapp"
version = "0.1.0"
edition.workspace = true

[dependencies]
common = { path = "../common" }
proto = { path = "../proto" }
base = { path = "../base" }

loco-rs.workspace = true
axum.workspace = true
sea-orm.workspace = true
serde.workspace = true
serde_json.workspace = true
tokio.workspace = true
uuid.workspace = true
prost.workspace = true
hmac = "0.12"
sha2 = "0.10"
hex = "0.4"
reqwest = { workspace = true, features = ["json"] }
rand = "0.8"
```

### 4.2 src/lib.rs

```rust
pub struct AppOpenApp;

#[async_trait]
impl ExternApp for AppOpenApp {
    fn routes(&self, ctx: &AppContext) -> Vec<Routes> {
        vec![
            Routes::new()
                .prefix("/openapi/v1")
                // Auth (no auth required)
                .add("/auth/tenant_access_token", post(handlers::auth::tenant_access_token))
                // App management (User JWT auth)
                .add("/apps", post(handlers::app::create))
                .add("/apps", get(handlers::app::list))
                .add("/apps/{app_id}", get(handlers::app::get))
                .add("/apps/{app_id}", put(handlers::app::update))
                .add("/apps/{app_id}", delete(handlers::app::delete))
                .add("/apps/{app_id}/rotate_secret", post(handlers::app::rotate_secret))
                .add("/apps/{app_id}/bot", put(handlers::app::update_bot))
                // Bot messages (Tenant Access Token auth)
                .add("/bot/message", post(handlers::bot::send_message))
                .add("/bot/message/{message_id}", patch(handlers::bot::edit_message))
                .add("/bot/message/{message_id}/recall", post(handlers::bot::recall_message)),
        ]
    }

    async fn handle_client_packet(&self, ...) -> Result<...> {
        Err(Error::NotFound) // No protobuf commands
    }
}
```

### 4.3 模块文件树

```
backend/openapp/src/
├── lib.rs
│   ├── struct AppOpenApp
│   └── impl ExternApp for AppOpenApp (fn routes, fn handled_command)
│
├── middleware.rs
│   ├── pub struct AppAuth(pub AppBrief)
│   ├── impl<S> FromRequestParts<S> for AppAuth
│   │   └── Extracts Bearer token → validates JWT → returns AppBrief
│   └── pub struct AppBrief { app_id: String, app_db_id: i64, tenant_id: i64, scopes: Vec<String> }
│
├── error.rs
│   └── OpenAppError enum, Into<Response> impl
│
├── handlers/
│   ├── mod.rs
│   ├── auth.rs
│   │   └── pub async fn tenant_access_token(JWT or Json) → Response
│   ├── app.rs
│   │   ├── pub async fn create(UserJWT, State, Json) → Response
│   │   ├── pub async fn list(UserJWT, State, Query) → Response
│   │   ├── pub async fn get(UserJWT, State, Path) → Response
│   │   ├── pub async fn update(UserJWT, State, Path, Json) → Response
│   │   ├── pub async fn delete(UserJWT, State, Path) → Response
│   │   ├── pub async fn rotate_secret(UserJWT, State, Path) → Response
│   │   └── pub async fn update_bot(UserJWT, State, Path, Json) → Response
│   └── bot.rs
│       ├── pub async fn send_message(AppAuth, State, Json) → Response
│       ├── pub async fn edit_message(AppAuth, State, Path, Json) → Response
│       └── pub async fn recall_message(AppAuth, State, Path) → Response
│
├── models/
│   ├── mod.rs
│   ├── app.rs
│   │   └── OpenAppModel — CRUD for open_apps table
│   └── bot.rs
│       └── OpenAppBotModel — CRUD for open_app_bots table
│
└── services/
    ├── mod.rs
    ├── auth.rs
    │   ├── pub fn generate_app_id() → String
    │   ├── pub fn generate_app_secret() → String
    │   ├── pub fn generate_tenant_token(AppBrief, secret, expire) → String
    │   └── pub fn validate_tenant_token(token, secret) → Result<AppBrief>
    └── webhook.rs
        ├── pub async fn dispatch_event(app_db_id, event_type, payload) → Result
        │   ├── Load app bot config (webhook_url, webhook_secret)
        │   ├── Build event payload + sign
        │   ├── POST with retry (exponential backoff, max 3)
        │   └── Log result
        └── pub fn sign_webhook(body, secret, timestamp) → String
```

### 4.4 BizIm 跨模块接口

在 `common/src/service.rs` 的 `BizHub` 中新增：

```rust
#[async_trait]
pub trait BizIm: Send + Sync {
    async fn send_message(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        from_id: i64,
        chat_id: i64,
        msg_type: i32,
        content: Vec<u8>,
        summary: String,
    ) -> ModelResult<i64>;
    async fn edit_message(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        message_id: i64,
        content: Vec<u8>,
        summary: String,
    ) -> ModelResult<()>;
    async fn recall_message(
        &self,
        ctx: &AppContext,
        brief: &UserBrief,
        message_id: i64,
    ) -> ModelResult<()>;
}
```

在 `backend/im/src/lib.rs` 中实现该 trait，在 `BizHub` 中注册。

---

## 五、消息流

### Bot 发送消息流程

```
[Developer App]                    [Buzzing OpenAPI]                    [IM Module]                [Clients]
      |                                   |                                |                          |
      |-- POST /openapi/v1/bot/message -->|                                |                          |
      |   Authorization: tenant_token    |                                |                          |
      |                                   |-- AppAuth 验证 token          |                          |
      |                                   |-- 查询 app → 获取 bot_user_id |                          |
      |                                   |-- 构造 Message proto          |                          |
      |                                   |-- BizIm::send_message() ------>|                          |
      |                                   |                                |-- 写入 DB + cache        |
      |                                   |                                |-- push_entity 推送 ------->|
      |                                   |<-- message_id ----------------|                          |
      |<-- { message_id: 67890 } --------|                                |                          |
```

### Bot 接收消息（事件推送）流程

```
[User Client]                   [IM Module]                    [OpenAPI]                      [Developer Webhook]
      |                              |                            |                                |
      |-- Send Message (protobuf) -->|                            |                                |
      |                              |-- message_send            |                                |
      |                              |-- 检查 chat 中是否有 Bot   |                                |
      |                              |-- 有 → 异步通知 OpenAPI --|                                |
      |                              |                            |-- webhook::dispatch_event()    |
      |                              |                            |-- 签名 HMAC-SHA256            |
      |                              |                            |-- POST https://dev/callback ->|
      |                              |                            |<-- 200 OK --------------------|
```

> Bot 接收消息检测：在 `message_send` 完成后，检查目标 chat 的成员中是否有 `type = USER_TYPE_BOT` 的用户，若有则异步触发事件推送。

---

## 六、事件注册与推送机制

在 `IM` 模块中插入事件钩子：

```rust
// message_send 末尾 added
if has_bot_in_chat(&ctx, &chat_id).await {
    let _ = trigger_bot_events(ctx, chat_id, &message).await;
}
```

`trigger_bot_events` 函数：
1. 遍历 chat 成员中所有 `type = USER_TYPE_BOT` 的用户
2. 查询 `open_app_bots` 确认 Bot 是否订阅了 `im.message.receive` 事件
3. 若订阅 → 通过 `BizOpenApp::dispatch_event()` 推送到 Bot Webhook

异步推送使用 `tokio::spawn`，不阻塞主消息流。

---

## 七、安全设计

### 7.1 app_secret 存储
- 使用 `argon2` 或 `bcrypt` 哈希后存储
- 仅在创建和轮换时明文返回
- 数据库中存储哈希值

### 7.2 Rate Limiting
- Bot 消息发送：每个 app 每分钟最多 60 条（可配置）
- Token 签发：每个 app 每分钟最多 10 次
- 使用 `moka` 本地缓存实现（非精确但性能好）

### 7.3 鉴权检查清单

| 端点 | 鉴权方式 | 额外检查 |
|------|---------|---------|
| `POST /auth/tenant_access_token` | 无（Body 中 app_id + app_secret） | app 状态为启用 |
| `POST /apps` | User JWT | 用户有开发者权限 |
| `GET /apps` | User JWT | 仅返回当前租户的应用 |
| `PUT /apps/{id}` | User JWT | app.owner_id == current_user OR admin |
| `DELETE /apps/{id}` | User JWT | 同上 |
| `POST /bot/message` | Tenant Access Token | app 类型为 Bot、app 已启用 |

---

## 八、依赖关系

```
backend/openapp
  ├── common (ExternApp, BizHub, AppHub, utils)
  ├── proto (Command, ErrorCode, entity types)
  └── base (sea-orm entities, DB connection)

backend/im (via BizIm)
  └── openapp (dispatch_event) — async call
```

**循环依赖处理：** `im` 调用 `openapp::dispatch_event` 通过 BizHub 异步调用，`openapp` 调用 `im::send_message` 通过 BizIm 异步调用。两种依赖均通过 `common` 中的 trait 接口解耦，无编译期循环依赖。
