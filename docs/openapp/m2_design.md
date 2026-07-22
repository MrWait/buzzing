# M2: 开发者工具与 API 开放 — 详细设计方案

> 设计目标：开放平台标准化 REST API 供第三方调用，构建开发者控制台（Vue SPA），实现 OAuth 2.0 授权流程与出站 Webhook。
>
> 约定：所有 `/openapi/v1/*` 路由使用 REST/JSON，与客户端内 Protobuf 通信分离。Base URL 与 M1 统一。

---

## 一、API 开放网关

### 1.1 开放 API 总览

| 路由前缀 | 模块 | 鉴权方式 | 说明 |
|---------|------|---------|------|
| `/openapi/v1/im/*` | IM | Tenant Access Token | 群信息、成员列表、消息 |
| `/openapi/v1/user/*` | User | Tenant Access Token | 用户信息、部门、组织架构 |
| `/openapi/v1/calendar/*` | Calendar | Tenant Access Token | 日历、日程查询 |
| `/openapi/v1/files/*` | Files | Tenant Access Token | 文件上传、下载、查询 |
| `/openapi/v1/oauth/*` | OAuth | — | OAuth 2.0 授权端点 |

### 1.2 权限控制模型

应用注册时声明 `scopes`，调用 API 时 JWT 中携带 scopes，中间件校验：

| Scope | 权限 | 对应 API |
|-------|------|---------|
| `im:message:read` | 读取消息 | `GET /im/messages` |
| `im:message:write` | 发送/编辑消息 | `POST /im/messages`, `PATCH /im/messages/{id}` |
| `im:chat:read` | 读取群信息 | `GET /im/chats/{id}` |
| `im:chat:write` | 管理群 | `POST /im/chats`, `PUT /im/chats/{id}` |
| `user:info:read` | 读取用户信息 | `GET /user/users/{id}` |
| `user:dept:read` | 读取部门信息 | `GET /user/depts/{id}` |
| `calendar:event:read` | 读取日程 | `GET /calendar/events` |
| `calendar:event:write` | 创建/修改日程 | `POST /calendar/events` |
| `file:read` | 下载文件 | `GET /files/{id}` |
| `file:write` | 上传文件 | `POST /files/upload` |

### 1.3 IM API

**获取群信息：**
```
GET /openapi/v1/im/chats/{chat_id}
```
```json
{
  "code": 0,
  "data": {
    "id": 12345,
    "name": "项目群",
    "type": 2,
    "member_count": 10,
    "owner_id": 54321,
    "created_at": 1712345678000
  }
}
```

**获取群成员列表：**
```
GET /openapi/v1/im/chats/{chat_id}/members?page=1&page_size=50
```
```json
{
  "code": 0,
  "data": {
    "items": [
      { "user_id": 54321, "name": "张三", "role": "owner" },
      { "user_id": 54322, "name": "李四", "role": "member" }
    ],
    "total": 10
  }
}
```

**发送消息（Bot 现有 + 新增普通应用代用户发消息）：**

对于非 Bot 类型的应用（`app_type=3, API only`），支持代用户发送消息（需 `user_access_token`）：
```
POST /openapi/v1/im/messages
Authorization: Bearer <user_access_token>
{
  "chat_id": 12345,
  "msg_type": "text",
  "content": { "text": "Hello" }
}
```

实现：从 user_access_token 中提取 `user_id`，以该用户身份调用 `BizIm::send_message()`。

**查询消息历史：**
```
GET /openapi/v1/im/chats/{chat_id}/messages?page=1&page_size=20&before_id=100000
```

### 1.4 User API

**获取用户信息：**
```
GET /openapi/v1/user/users/{user_id}
```
```json
{
  "code": 0,
  "data": {
    "id": 54321,
    "name": "张三",
    "email": "zhangsan@example.com",
    "phone": "13800138000",
    "department_ids": [1, 2],
    "avatar_url": "https://..."
  }
}
```

**批量获取用户信息：**
```
POST /openapi/v1/user/users/batch
{
  "user_ids": [54321, 54322, 54323]
}
```

**获取部门列表：**
```
GET /openapi/v1/user/depts?page=1&page_size=50
```

**获取部门详情：**
```
GET /openapi/v1/user/depts/{dept_id}
```

**获取部门成员：**
```
GET /openapi/v1/user/depts/{dept_id}/members?page=1&page_size=50
```

### 1.5 Calendar API

**获取日历列表：**
```
GET /openapi/v1/calendar/calendars
```

**查询日程：**
```
GET /openapi/v1/calendar/events?start=1712345678000&end=1712432078000
```

**创建日程：**
```
POST /openapi/v1/calendar/events
{
  "title": "项目评审",
  "start_time": 1712345678000,
  "end_time": 1712355678000,
  "attendees": [54321, 54322]
}
```

### 1.6 Files API

**上传文件：**
```
POST /openapi/v1/files/upload
Content-Type: multipart/form-data
file: <binary>
```

复用现有 `POST /api/files/upload` 逻辑，返回 file_id。

**下载文件：**
```
GET /openapi/v1/files/{file_id}
```

复用现有 `GET /api/files/{id}` 逻辑（透明代理）。

**查询文件信息：**
```
GET /openapi/v1/files/{file_id}/info
```

### 1.7 API 错误码扩展

在 `error.proto` 增补开放平台错误码：

| 错误码 | 值 | 说明 |
|--------|-----|------|
| `ErrorOpenApiScopeDenied` | 21001 | Scope 权限不足 |
| `ErrorOpenApiRateLimit` | 21002 | API 调用频率超限 |
| `ErrorOpenApiTokenExpired` | 21003 | Access Token 过期 |
| `ErrorOpenApiAuthFailed` | 21004 | 鉴权失败 |
| `ErrorOpenApiAppDisabled` | 21005 | 应用已被禁用 |
| `ErrorOpenApiNotFound` | 21006 | 资源不存在 |

### 1.8 中间件扩展

现有 `AppAuth` extractor 增强，增加 scope 校验函数：

```rust
impl AppAuth {
    /// 校验是否拥有指定 scope，无权限返回 ErrorOpenApiScopeDenied
    pub fn require_scope(&self, required: &str) -> Result<(), OpenAppError> {
        if self.scopes.contains(&required.to_string()) {
            Ok(())
        } else {
            Err(OpenAppError::ScopeDenied(required.to_string()))
        }
    }
}
```

每个开放 API handler 入口调用 `auth.require_scope("im:message:read")?;`。

---

## 二、开发者后台（Vue SPA）

### 2.1 页面结构

在 `frontend/src/` 中新增目录：

```
frontend/src/
├── views/open/
│   ├── OpenLayout.vue          — 开放平台布局（侧边导航）
│   ├── apps/
│   │   ├── AppList.vue         — 应用列表页
│   │   ├── AppCreate.vue       — 创建应用页
│   │   ├── AppDetail.vue       — 应用详情页
│   │   └── AppBotConfig.vue    — Bot 配置页（Webhook + 事件订阅）
│   ├── oauth/
│   │   └── Authorize.vue       — OAuth 授权确认页
│   └── stats/
│       └── ApiStats.vue        — API 调用统计页
├── services/
│   ├── openapp.ts              — 开放平台 API 调用
│   └── oauth.ts                — OAuth API 调用
└── stores/
    └── openapp.ts              — 开放平台状态管理
```

### 2.2 路由定义

在 `frontend/src/router/index.ts` 中新增：

```typescript
{
  path: '/open',
  component: () => import('@/layouts/ModuleLayout.vue'),
  beforeEnter: tenantGuard,
  children: [
    { path: '', redirect: { name: 'OpenAppList' } },
    { path: 'apps', name: 'OpenAppList', component: () => import('@/views/open/apps/AppList.vue') },
    { path: 'apps/create', name: 'OpenAppCreate', component: () => import('@/views/open/apps/AppCreate.vue') },
    { path: 'apps/:appId', name: 'OpenAppDetail', component: () => import('@/views/open/apps/AppDetail.vue') },
    { path: 'apps/:appId/bot', name: 'OpenAppBotConfig', component: () => import('@/views/open/apps/AppBotConfig.vue') },
    { path: 'stats', name: 'OpenApiStats', component: () => import('@/views/open/stats/ApiStats.vue') },
  ]
}
```

### 2.3 页面功能

**应用列表页（AppList.vue）：**
- 表格展示应用中名称、app_id、类型、状态、创建时间
- 「创建应用」按钮 → 跳转创建页
- 每行操作：查看详情、启用/禁用、删除
- 分页

**创建应用页（AppCreate.vue）：**
- 表单：应用名称、描述、类型（Bot / API only）
- 提交后显示 app_id + app_secret（仅展示一次，提示开发者保存）

**应用详情页（AppDetail.vue）：**
- 基本信息编辑（名称、描述）
- 显示 app_id（只读）、app_secret（可点击查看）
- 轮换密钥按钮（二次确认）
- 权限声明（Scopes）：可选列表，勾选后提交更新
- Bot 配置入口（仅 Bot 类型显示）
- 删除应用（二次确认）

**Bot 配置页（AppBotConfig.vue）：**
- Webhook URL 输入 + 测试回调按钮
- 事件订阅开关列表：
  - `im.message.receive` — 收到消息
  - `im.group.added_bot` — 被加入群聊
  - `im.group.removed_bot` — 被移出群聊
- Webhook 签名密钥显示（可重新生成）

**API 调用统计页（ApiStats.vue）：**
- 按应用选择查看
- 调用次数趋势图（日/周/月）
- 错误率、平均延时
- 使用 ECharts 或 Chart.js 渲染

### 2.4 API 调用统计实现

后端新增统计表：

```sql
CREATE TABLE open_app_stats (
    id bigint PK,
    app_id bigint FK → open_apps.id,
    date date NOT NULL,
    endpoint varchar(128),
    call_count int DEFAULT 0,
    error_count int DEFAULT 0,
    total_latency_ms bigint DEFAULT 0,
    UNIQUE (app_id, date, endpoint)
);
```

- 中间件在每次 API 调用后异步更新统计（+1 call_count，累加 latency）
- 错误响应时 error_count +1
- 查询时按日期聚合

### 2.5 开发者后台 API（User JWT 鉴权）

新增 Vue 后台专用 API（在 `openapp` 模块中）：

| 端点 | 方法 | 说明 |
|------|------|------|
| `/openapi/v1/apps/stats/{app_id}?period=day` | GET | 获取调用统计 |
| `/openapi/v1/apps/stats/{app_id}/error_logs` | GET | 获取错误日志 |

---

## 三、OAuth 2.0 授权

### 3.1 数据模型

`open_app_authorizations` 表：

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `bigint PK` | Snowflake ID |
| `app_id` | `bigint FK → open_apps.id` | 应用 ID |
| `user_id` | `bigint FK → users.id` | 授权用户 |
| `tenant_id` | `bigint` | 租户 ID |
| `scopes` | `text[]` | 授权的作用域 |
| `status` | `smallint` | 0=已撤销, 1=有效 |
| `created_at` | `timestamptz` | 授权时间 |
| `updated_at` | `timestamptz` | 更新时间 |

`open_app_user_tokens` 表：

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `bigint PK` | Snowflake ID |
| `authorization_id` | `bigint FK` | 授权记录 ID |
| `access_token` | `varchar(512)` | 加密存储 |
| `refresh_token` | `varchar(512)` | 加密存储 |
| `scopes` | `text[]` | 作用域 |
| `access_expire_at` | `timestamptz` | Access Token 过期时间 |
| `refresh_expire_at` | `timestamptz` | Refresh Token 过期时间（30 天） |
| `created_at` | `timestamptz` | 创建时间 |

### 3.2 授权流程

```
[Third-Party App]                    [Buzzing OAuth]                     [User Browser]
      |                                      |                               |
      |-- 1. Redirect to authorize URL ----->|                               |
      |   /openapi/v1/oauth/authorize?       |                               |
      |   response_type=code&                |                               |
      |   client_id=app_xxx&                 |                               |
      |   redirect_uri=https://...&          |                               |
      |   scope=im:message:read&             |                               |
      |   state=random_state                 |                               |
      |                                      |-- 2. User登录检查 ---->      |
      |                                      |<-- 已登录或无 ---------------|
      |                                      |                               |
      |                                      |-- 3. 展示授权页面 ---------->|
      |                                      |   (应用名、权限列表等)        |
      |                                      |<-- 用户点击"授权" -----------|
      |                                      |                               |
      |                                      |-- 4. 生成 authorization_code |
      |<-- 5. 302 Redirect to --------------|                               |
      |   redirect_uri?code=xxx&state=xxx   |                               |
      |                                      |                               |
      |-- 6. POST /openapi/v1/oauth/token ->|                               |
      |   grant_type=authorization_code&     |                               |
      |   code=xxx&                          |                               |
      |   client_id=app_xxx&                 |                               |
      |   client_secret=sk_xxx               |                               |
      |                                      |-- 7. 验证 code + secret      |
      |                                      |-- 8. 签发 token pair          |
      |<-- { access_token, refresh_token,    |                               |
      |      expire_in, scope } -------------|                               |
```

### 3.3 端点设计

**授权页面（Vue SPA 内嵌）：**
```
GET /openapi/v1/oauth/authorize?response_type=code&client_id=app_xxx&redirect_uri=...&scope=...&state=...
```

- 用户未登录 → 重定向到登录页
- 已登录 → 展示确认页 → 确认后生成 `authorization_code`（有效期 10 分钟）
- 302 重定向到 `redirect_uri?code=xxx&state=xxx`

**换取 Token：**
```
POST /openapi/v1/oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code&code=xxx&client_id=app_xxx&client_secret=sk_xxx
```

```json
{
  "code": 0,
  "data": {
    "access_token": "ua_eyJhbGciOiJIUzI1NiIs...",
    "token_type": "Bearer",
    "expires_in": 7200,
    "refresh_token": "ur_xxxxx",
    "scope": "im:message:read"
  }
}
```

User Access Token 载荷（JWT）：

```json
{
  "type": "user_access",
  "user_id": 54321,
  "app_id": "app_xxx",
  "tenant_id": 100,
  "scopes": ["im:message:read"],
  "exp": 1712345678,
  "iat": 1712338478
}
```

**刷新 Token：**
```
POST /openapi/v1/oauth/token
grant_type=refresh_token&refresh_token=ur_xxxxx&client_id=app_xxx&client_secret=sk_xxx
```

### 3.4 用户授权管理

在设置页新增「已授权应用」列表：
- 展示用户已授权的应用
- 可查看授权 scopes
- 可撤销授权（撤销后该应用对应 token 立即失效）

撤销 API：
```
DELETE /openapi/v1/oauth/authorizations/{authorization_id}
```
（User JWT 鉴权，仅本人或管理员可操作）

### 3.5 OAuth 错误码

| code | message | 说明 |
|------|---------|------|
| 21010 | `invalid_request` | 缺少必要参数 |
| 21011 | `invalid_client` | client_id 无效 |
| 21012 | `invalid_grant` | code/token 无效或已过期 |
| 21013 | `unauthorized_client` | 应用无权请求该 scope |
| 21014 | `redirect_uri_mismatch` | redirect_uri 不匹配 |
| 21015 | `access_denied` | 用户拒绝授权 |

---

## 四、Webhook 出站（Outgoing Webhook）

### 4.1 概念

出站 Webhook 允许群聊中通过关键词触发，将消息 POST 到开发者配置的 URL，并将返回结果展示在群聊中。

### 4.2 数据模型

`open_app_outgoing_webhooks` 表：

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `bigint PK` | Snowflake ID |
| `app_id` | `bigint FK → open_apps.id` | 关联应用 |
| `chat_id` | `bigint FK → chats.id` | 绑定的群聊 |
| `name` | `varchar(64)` | 名称 |
| `command` | `varchar(64)` | 触发关键词（如 `/weather`） |
| `webhook_url` | `varchar(512)` | 回调 URL |
| `webhook_secret` | `varchar(64)` | 签名密钥 |
| `status` | `smallint` | 0=禁用, 1=启用 |
| `created_at` | `timestamptz` | 创建时间 |

### 4.3 触发流程

```
[User sends "/weather 北京"]          [IM Module]                    [Developer Webhook]
          |                                |                                |
          |-- 发送消息 (protobuf) -------->|                                |
          |                                |-- 消息入库                     |
          |                                |-- 检查 chat 是否有出站Webhook     |
          |                                |-- 匹配 command "/weather"      |
          |                                |-- POST /webhook-url --------->|
          |                                |   { "command": "/weather",     |
          |                                |     "params": "北京",          |
          |                                |     "user_id": 54321,         |
          |                                |     "chat_id": 12345,         |
          |                                |     "message_id": 67890 }     |
          |                                |<-- 200 { "text": "北京: 晴,20°C" }|
          |                                |-- 自动发送 Bot 回复 ------------>|
          |<-- 收到回复消息 --------------|                                |
```

### 4.4 出站 Webhook Bot 机制

每个出站 Webhook 自动创建一个 Bot 用户（与 M1 Bot 机制相同），用于发送回复消息。开发者只需返回消息内容，平台负责将回复发回群聊。

### 4.5 响应格式

开发者 Webhook 返回 JSON：

```json
{
  "msg_type": "text",
  "content": { "text": "北京: 晴, 20°C" }
}
```

支持 `msg_type`：`text`, `markdown`, `image`（需传 file_key）。

### 4.6 开发者后台配置

在 Bot 配置页中增加「出站 Webhook」Tab：
- 可添加多个出站 Webhook
- 每个配置：名称、触发关键词、Webhook URL
- 绑定到指定群聊（可选择群聊）
- 支持启用/禁用

---

## 五、前端模块 — 子模块路由与 API 注册

### 5.1 路由注册

M2 新增的路由在 `openapp` 模块的 `lib.rs` 中注册（延续 M1 的 `routes()` 方法）：

```rust
fn routes(&self, ctx: &AppContext) -> Vec<Routes> {
    vec![
        Routes::new()
            .prefix("/openapi/v1")
            // M1 routes (existing)
            .add("/auth/tenant_access_token", post(handlers::auth::tenant_access_token))
            .add("/apps", post(handlers::app::create))
            // ... M1 routes ...
            
            // M2.1 — Open API Gateway
            .add("/im/chats/{chat_id}", get(handlers::open_api::get_chat))
            .add("/im/chats/{chat_id}/members", get(handlers::open_api::list_chat_members))
            .add("/im/messages", post(handlers::open_api::send_message))
            .add("/im/chats/{chat_id}/messages", get(handlers::open_api::list_messages))
            .add("/user/users/{user_id}", get(handlers::open_api::get_user))
            .add("/user/users/batch", post(handlers::open_api::batch_get_users))
            .add("/user/depts", get(handlers::open_api::list_depts))
            .add("/user/depts/{dept_id}", get(handlers::open_api::get_dept))
            .add("/user/depts/{dept_id}/members", get(handlers::open_api::list_dept_members))
            .add("/calendar/calendars", get(handlers::open_api::list_calendars))
            .add("/calendar/events", get(handlers::open_api::list_events))
            .add("/calendar/events", post(handlers::open_api::create_event))
            .add("/files/upload", post(handlers::open_api::upload_file))
            .add("/files/{file_id}", get(handlers::open_api::get_file))
            .add("/files/{file_id}/info", get(handlers::open_api::get_file_info))
            
            // M2.2 — OAuth
            .add("/oauth/authorize", get(handlers::oauth::authorize))
            .add("/oauth/authorize", post(handlers::oauth::confirm_authorize))
            .add("/oauth/token", post(handlers::oauth::token))
            .add("/oauth/authorizations", delete(handlers::oauth::revoke_authorization))
            
            // M2.3 — App stats (Developer Console)
            .add("/apps/stats/{app_id}", get(handlers::open_api::get_app_stats))
            .add("/apps/stats/{app_id}/error_logs", get(handlers::open_api::get_error_logs))
            
            // M2.4 — Outgoing Webhook
            .add("/apps/{app_id}/outgoing_webhooks", post(handlers::app::create_outgoing_webhook))
            .add("/apps/{app_id}/outgoing_webhooks/{webhook_id}", put(handlers::app::update_outgoing_webhook))
            .add("/apps/{app_id}/outgoing_webhooks/{webhook_id}", delete(handlers::app::delete_outgoing_webhook))
            .add("/apps/{app_id}/outgoing_webhooks", get(handlers::app::list_outgoing_webhooks)),
    ]
}
```

### 5.2 模块文件扩展

```
backend/openapp/src/
├── lib.rs
├── middleware.rs
├── error.rs
├── handlers/
│   ├── mod.rs
│   ├── auth.rs            (M1)
│   ├── app.rs             (M1 + M2 outgoing webhook)
│   ├── bot.rs             (M1)
│   ├── open_api.rs        (M2 新增 — 开放 API 网关 handlers)
│   │   ├── get_chat, list_chat_members
│   │   ├── send_message, list_messages
│   │   ├── get_user, batch_get_users
│   │   ├── list_depts, get_dept, list_dept_members
│   │   ├── list_calendars, list_events, create_event
│   │   ├── upload_file, get_file, get_file_info
│   │   └── get_app_stats, get_error_logs
│   └── oauth.rs           (M2 新增 — OAuth handlers)
│       ├── authorize (GET — 展示授权页)
│       ├── confirm_authorize (POST — 用户确认)
│       ├── token (POST — 换取/刷新 token)
│       └── revoke_authorization (DELETE)
├── models/
│   ├── mod.rs
│   ├── app.rs             (M1)
│   ├── bot.rs             (M1)
│   ├── authorization.rs   (M2 新增)
│   ├── user_token.rs      (M2 新增)
│   ├── api_stat.rs        (M2 新增)
│   └── outgoing_webhook.rs (M2 新增)
└── services/
    ├── mod.rs
    ├── auth.rs            (M1)
    ├── webhook.rs         (M1 + M2 outgoing webhook 签名)
    └── oauth.rs           (M2 新增)
        ├── generate_authorization_code()
        ├── exchange_code_for_token()
        ├── refresh_token()
        ├── validate_user_access_token()
        └── revoke_authorization()
```

---

## 六、BizXxx 跨模块交互

M2 开放 API 网关需要调用 IM、User、Calendar、Store 模块能力，通过 BizHub 路由：

| 开放 API | 底层调用 | BizHub 接口 |
|----------|---------|-------------|
| `GET /im/chats/{id}` | `BizIm::get_chat()` | 新增 |
| `GET /im/chats/{id}/members` | `BizIm::list_chat_members()` | 新增 |
| `POST /im/messages` | `BizIm::send_message()` (M1 已有) | 已有 |
| `GET /im/chats/{id}/messages` | `BizIm::list_messages()` | 新增 |
| `GET /user/users/{id}` | `BizUser::get_user_by_id()` | 已有 |
| `POST /user/users/batch` | `BizUser::get_user_by_ids()` | 已有 |
| `GET /user/depts` | `BizUser::list_depts()` | 新增 |
| `GET /user/depts/{id}` | `BizUser::get_dept()` | 新增 |
| `GET /user/depts/{id}/members` | `BizUser::list_dept_members()` | 新增 |
| `GET /calendar/calendars` | `BizCalendar::list_calendars()` | 新增 |
| `GET /calendar/events` | `BizCalendar::list_events()` | 新增 |
| `POST /calendar/events` | `BizCalendar::create_event()` | 新增 |
| `POST /files/upload` | 复用 `store` 模块现有 route | 直接路由 |
| `GET /files/{id}` | 复用 `store` 模块现有 route | 直接路由 |

**BizIm 新增接口：**
```rust
#[async_trait]
pub trait BizIm: Send + Sync {
    // M1 已有
    async fn send_message(...) -> ModelResult<i64>;
    async fn edit_message(...) -> ModelResult<()>;
    async fn recall_message(...) -> ModelResult<()>;
    
    // M2 新增
    async fn get_chat(ctx: &AppContext, brief: &UserBrief, chat_id: i64) -> ModelResult<ChatInfo>;
    async fn list_chat_members(ctx: &AppContext, brief: &UserBrief, chat_id: i64, page: i32, page_size: i32) -> ModelResult<MemberList>;
    async fn list_messages(ctx: &AppContext, brief: &UserBrief, chat_id: i64, page: i32, page_size: i32, before_id: Option<i64>) -> ModelResult<MessageList>;
}
```

**BizUser 新增接口：**
```rust
#[async_trait]
pub trait BizUser: Send + Sync {
    // 已有
    async fn get_user_by_id(...) -> ModelResult<UserBrief>;
    async fn get_user_by_ids(...) -> ModelResult<Vec<UserBrief>>;
    
    // M2 新增
    async fn list_depts(ctx: &AppContext, brief: &UserBrief, tenant_id: i64) -> ModelResult<Vec<DeptInfo>>;
    async fn get_dept(ctx: &AppContext, brief: &UserBrief, dept_id: i64) -> ModelResult<DeptInfo>;
    async fn list_dept_members(ctx: &AppContext, brief: &UserBrief, dept_id: i64, page: i32, page_size: i32) -> ModelResult<MemberList>;
}
```

**BizCalendar 新增接口：**
```rust
#[async_trait]
pub trait BizCalendar: Send + Sync {
    // 已有
    async fn create_user_default(...) -> ModelResult<()>;
    
    // M2 新增
    async fn list_calendars(ctx: &AppContext, brief: &UserBrief, tenant_id: i64) -> ModelResult<Vec<CalendarInfo>>;
    async fn list_events(ctx: &AppContext, brief: &UserBrief, calendar_id: i64, start: i64, end: i64) -> ModelResult<Vec<EventInfo>>;
    async fn create_event(ctx: &AppContext, brief: &UserBrief, calendar_id: i64, event: CreateEventReq) -> ModelResult<i64>;
}
```

---

## 七、安全设计

### 7.1 User Access Token
- JWT 签名使用 loco-rs JWT secret（与系统统一）
- 有效期：2 小时（access_token）、30 天（refresh_token）
- Refresh Token 为不透明字符串（随机 32 字节 hex），存入 DB

### 7.2 API 调用频率控制
- 应用级别：每个 app 每分钟最多 600 次 API 调用（可配置）
- 用户级别：每个 user 每分钟最多 600 次（通过 user_access_token）
- Bot 消息发送保留 M1 的独立 Rate Limit（60 条/分钟）
- 使用 `moka::Cache` 实现

### 7.3 OAuth 安全措施
- authorization_code 有效期 10 分钟，单次使用
- refresh_token 可轮换（每次刷新返回新的 refresh_token，旧 token 失效）
- redirect_uri 必须精确匹配注册时配置的 URI
- state 参数防 CSRF 攻击

### 7.4 Webhook 出站安全
- 支持 IP 白名单（可选）：仅允许来自白名单 IP 的请求触发
- 响应验证：仅接受 content-type `application/json` 的 2xx 响应
- 超时控制：5 秒超时
- 敏感词过滤：在 trigger 参数中去除 token、secret 等敏感关键词

---

## 八、数据库迁移

### M2.1 open_app_authorizations

```sql
CREATE TABLE open_app_authorizations (
    id BIGINT PRIMARY KEY,
    app_id BIGINT NOT NULL REFERENCES open_apps(id),
    user_id BIGINT NOT NULL REFERENCES users(id),
    tenant_id BIGINT NOT NULL,
    scopes TEXT[] NOT NULL DEFAULT '{}',
    status SMALLINT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_oauth_app_user ON open_app_authorizations(app_id, user_id);
```

### M2.2 open_app_user_tokens

```sql
CREATE TABLE open_app_user_tokens (
    id BIGINT PRIMARY KEY,
    authorization_id BIGINT NOT NULL REFERENCES open_app_authorizations(id),
    access_token VARCHAR(512) NOT NULL,
    refresh_token VARCHAR(512) NOT NULL,
    scopes TEXT[] NOT NULL DEFAULT '{}',
    access_expire_at TIMESTAMPTZ NOT NULL,
    refresh_expire_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_token_authorization ON open_app_user_tokens(authorization_id);
CREATE UNIQUE INDEX idx_token_access ON open_app_user_tokens(access_token);
CREATE UNIQUE INDEX idx_token_refresh ON open_app_user_tokens(refresh_token);
```

### M2.3 open_app_stats

```sql
CREATE TABLE open_app_stats (
    id BIGINT PRIMARY KEY,
    app_id BIGINT NOT NULL REFERENCES open_apps(id),
    date DATE NOT NULL,
    endpoint VARCHAR(128) NOT NULL,
    call_count INT DEFAULT 0,
    error_count INT DEFAULT 0,
    total_latency_ms BIGINT DEFAULT 0,
    UNIQUE (app_id, date, endpoint)
);
```

### M2.4 open_app_outgoing_webhooks

```sql
CREATE TABLE open_app_outgoing_webhooks (
    id BIGINT PRIMARY KEY,
    app_id BIGINT NOT NULL REFERENCES open_apps(id),
    chat_id BIGINT NOT NULL,
    name VARCHAR(64) NOT NULL,
    command VARCHAR(64) NOT NULL,
    webhook_url VARCHAR(512) NOT NULL,
    webhook_secret VARCHAR(64) NOT NULL,
    status SMALLINT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_outgoing_app ON open_app_outgoing_webhooks(app_id);
CREATE INDEX idx_outgoing_chat ON open_app_outgoing_webhooks(chat_id);
```

### M2.5 open_apps 表扩展

```sql
ALTER TABLE open_apps ADD COLUMN redirect_uris TEXT[] DEFAULT '{}';
```

用于 OAuth 授权时验证 redirect_uri。

---

## 九、依赖与实现顺序

```
外层循环（4 个阶段可组合）：
┌─────────────────────────────────────────────────────┐
│ Phase A: API 开放网关（Step 0-3）                    │
│   Step 0: 错误码扩展 + 中间件 scope 校验             │
│   Step 1: BizIm/BizUser/BizCalendar trait 扩展       │
│   Step 2: 各模块实现新增 BizXxx 接口                 │
│   Step 3: open_api.rs handlers 实现 + 路由注册       │
├─────────────────────────────────────────────────────┤
│ Phase B: 开发者后台 Vue SPA（Step 4-5）              │
│   Step 4: App 路由 + 页面组件（List/Create/Detail）   │
│   Step 5: Bot 配置页 + API 调用统计页 + store        │
├─────────────────────────────────────────────────────┤
│ Phase C: OAuth 2.0（Step 6-8）                       │
│   Step 6: 数据库迁移 + model                         │
│   Step 7: service/oauth.rs 实现                     │
│   Step 8: handlers/oauth.rs + 前端授权确认页         │
├─────────────────────────────────────────────────────┤
│ Phase D: 出站 Webhook + 统计（Step 9-10）             │
│   Step 9: outgoing_webhook model + handler          │
│   Step 10: IM 模块插入出站 Webhook 触发钩子          │
└─────────────────────────────────────────────────────┘
```
