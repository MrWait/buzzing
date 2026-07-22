# Open Platform — 实施进度追踪总表

> M1 设计文档见 `docs/openapp/m1_design.md`
> M2 设计文档见 `docs/openapp/m2_design.md`
> M3 设计文档见 `docs/openapp/m3_design.md`
> M4 设计文档见 `docs/openapp/m4_design.md`
>
> 每完成一步在 `[ ]` 前打 `[x]`。

---

## M1: 开放平台基础

### Step 0: Proto & DB 基础

- [x] **0.1** Proto — `entity.proto` 新增 `UserType::USER_TYPE_BOT = 3`
- [x] **0.2** Proto — 新增 `openapp.proto` 定义 `OpenApp`, `OpenAppBot`, `BotMessageRequest`, `BotEventPayload` 等消息
- [x] **0.3** DB Migration — `m20260722_100001_open_apps` 创建 `open_apps` 表
- [x] **0.4** DB Migration — `m20260722_100002_open_app_bots` 创建 `open_app_bots` 表
- [x] **0.5** DB Migration — `m20260722_100003_users_bot_app_id` `users` 表新增 `bot_app_id`
- [x] **0.6** Proto yaml + lib.rs — 将 `openapp.proto` 加入 `backend/proto/proto.yaml` 和 `src/lib.rs`
- [ ] **0.7** 生成 sea-orm entity — `sea-orm-cli generate entity -o backend/base/src/models/_entities`（需要 DB 连接）
- [x] **0.8** SDK proto lib.rs — 将 `openapp.proto` 加入 `sdk/proto/proto.yaml` 和 `src/lib.rs`

### Step 1: 模块脚手架

- [x] **1.1** 创建 `backend/openapp/Cargo.toml`（依赖 common, proto, base）
- [x] **1.2** 创建 `backend/openapp/src/lib.rs` — 实现 `ExternApp`，注册 REST 路由
- [x] **1.3** 创建 `backend/openapp/src/error.rs` — `OpenAppError` 枚举 + `IntoResponse`
- [x] **1.4** 创建 `backend/openapp/src/middleware.rs` — `AppAuth` extractor + `AppBrief`
- [x] **1.5** 创建 `backend/openapp/src/models/mod.rs` 子模块声明
- [x] **1.6** 创建 `backend/openapp/src/handlers/mod.rs` 子模块声明
- [x] **1.7** 创建 `backend/openapp/src/services/mod.rs` 子模块声明
- [x] **1.8** `backend/Cargo.toml` — 将 `openapp` 加入 workspace members
- [x] **1.9** `backend/app/src/main.rs` — 在 `AppHub` 中注册 `AppOpenApp`

### Step 2: 鉴权系统

- [x] **2.1** `backend/openapp/src/services/auth.rs` — 工具函数：
  - `generate_app_id()` / `generate_app_secret()` — 随机 ID 和密钥生成
  - `hash_secret()` / `verify_secret()` — SHA-256 哈希/验证
  - `generate_tenant_token(AppBrief)` — 签发 JWT（含 token_type=openapp 标记）
  - `validate_tenant_token(token)` → `Result<AppBrief>` — 验证 JWT
- [x] **2.2** `backend/openapp/src/middleware.rs` — 完善 `AppAuth` extractor：
  - 提取 `Authorization: Bearer <token>` → 验证 → 返回 `AppBrief`
  - 使用 loco-rs JWT secret 签名，与现有系统一致
- [x] **2.3** `backend/openapp/src/handlers/auth.rs` — `POST /auth/tenant_access_token`：
  - 接收 `{ app_id, app_secret }` → 验证 app 存在/启用/secret 匹配
  - 签发 tenant_access_token → 返回 `{ token, expire }`
- [x] **2.4** 新增 sea-orm entity — `open_apps` + `open_app_bots` 手动创建并注册到 mod.rs/prelude.rs
- [x] **2.5** `users.rs` 实体新增 `bot_app_id` 字段

### Step 3: App 管理

- [ ] **3.1** `backend/openapp/src/models/app.rs` — `OpenAppModel`：
  - `create(db, owner_id, tenant_id, name, description, app_type)` → app + bot_user_id
  - `find_by_id(db, id)` / `find_by_app_id(db, app_id)`
  - `find_by_tenant(db, tenant_id, page, page_size)`
  - `update(db, app_id, fields)`
  - `soft_delete(db, app_id)`
  - `rotate_secret(db, app_id)` → new_secret
- [ ] **3.2** `backend/openapp/src/models/bot.rs` — `OpenAppBotModel`：
  - `create_for_app(db, app_id, bot_user_id)`
  - `find_by_app(db, app_id)`
  - `update_webhook(db, app_id, webhook_url, event_types)`
  - `delete_by_app(db, app_id)`
- [ ] **3.3** 创建 Bot 用户辅助函数 — `create_bot_user(db, app_id, tenant_id, name)`：
  - 写入 `users` 表，`type = USER_TYPE_BOT (3)`, `bot_app_id = app_id`
  - 生成 snowflake ID
  - 返回 `bot_user_id`
- [ ] **3.4** `backend/openapp/src/handlers/app.rs` — 应用 CRUD：
  - `POST /apps` — 创建应用（自动创建 Bot 用户 + Bot 配置）
  - `GET /apps` — 列表（当前租户，分页）
  - `GET /apps/{app_id}` — 详情
  - `PUT /apps/{app_id}` — 修改
  - `DELETE /apps/{app_id}` — 删除（软删除 + 禁用 Bot 用户）
  - `POST /apps/{app_id}/rotate_secret` — 轮换密钥
  - `PUT /apps/{app_id}/bot` — 配置 Webhook + 订阅事件

### Step 4: Bot 消息收发

- [ ] **4.1** 在 `common/src/service.rs` 中新增 `BizIm` trait：
  - `send_message(ctx, brief, from_id, chat_id, msg_type, content, summary) → Result<i64>`
  - `edit_message(ctx, brief, message_id, content, summary) → Result<()>`
  - `recall_message(ctx, brief, message_id) → Result<()>`
- [ ] **4.2** 在 `backend/im/src/lib.rs` 中实现 `BizIm` trait：
  - `send_message` — 构造 `Message` proto，调用 `message_send` 内部逻辑
  - `edit_message` — 调用 `message_edit` 内部逻辑
  - `recall_message` — 调用现有 `message_recall` 逻辑
- [ ] **4.3** 在 `backend/app/src/main.rs` 的 `BizHub` 中注册 `BizIm` 实现
- [ ] **4.4** `backend/openapp/src/handlers/bot.rs` — Bot 消息 API：
  - `POST /bot/message` — 发送消息
    - 验证 app 类型为 Bot、已启用
    - 查询 app 获取 bot_user_id
    - 解析 `msg_type` + `content`
    - 序列化 content 为 bytes
    - 调用 `BizIm::send_message`
    - 返回 `{ message_id }`
  - `PATCH /bot/message/{message_id}` — 编辑消息
  - `POST /bot/message/{message_id}/recall` — 撤回消息

### Step 5: 事件订阅（Webhook）

- [ ] **5.1** `backend/openapp/src/services/webhook.rs` — Webhook 推送服务：
  - `parse_event_type(event_type_str) → EventType` 枚举
  - `build_event_payload(app_id, event_type, payload) → serde_json::Value`
  - `sign_webhook(body: &str, secret: &str, timestamp: i64) → String`（HMAC-SHA256）
  - `dispatch_event(ctx, app_db_id, event_type, payload)`：
    1. 查询 `open_app_bots` 获取 `webhook_url` + `webhook_secret`
    2. 检查 `event_types` 是否包含该事件
    3. 构建事件 JSON（含 `event_id`, `app_id`, `type`, `timestamp`, `payload`）
    4. 计算签名 → 设置 `X-Buzzing-Signature`, `X-Buzzing-Timestamp`
    5. POST 到 `webhook_url`（超时 10 秒）
    6. 非 2xx → 重试（5s → 30s → 300s 指数退避）
    7. 3 次均失败 → 记录错误日志，丢弃
  - `generate_event_id(app_id, event_type, seq) → String`
- [ ] **5.2** 在 IM 模块中插入事件触发钩子：
  - `backend/im/src/message.rs` 的 `message_send` 末尾：
    - 检查 chat 成员中是否有 Bot 用户
    - 若有 → 异步调用 `BizOpenApp::dispatch_event()`
  - `backend/im/src/chat.rs` 的 `chat_add_member` / `add_chatters`：
    - 检查加入的成员中是否有 Bot 用户
    - 若有 → 异步推送 `im.group.added_bot` 事件
    - 若移除 Bot → 推送 `im.group.removed_bot` 事件
- [ ] **5.3** 在 `common/src/service.rs` 中新增 `BizOpenApp` trait：
  - `dispatch_event(ctx, app_db_id, event_type, payload) → Result<()>`
- [ ] **5.4** 在 `backend/openapp/src/lib.rs` 中实现 `BizOpenApp` trait
- [ ] **5.5** 在 `backend/app/src/main.rs` 的 `BizHub` 中注册 `BizOpenApp` 实现

### Step 6: Rate Limiting & 安全加固

- [ ] **6.1** 消息发送频率限制：
  - 使用 `moka::Cache` 实现 per-app rate limiter
  - 配置：每分钟 60 条（默认）
  - 超限返回 `ErrorCode::ErrorRateLimit`
- [ ] **6.2** Token 签发频率限制：
  - 每 app 每分钟最多 10 次
- [ ] **6.3** app_secret 哈希存储：
  - 使用 `argon2` crate 哈希
  - 仅在创建和轮换时明文返回
- [ ] **6.4** Tenant Access Token 缓存：
  - 每次验证 token 不查 DB（JWT 无状态）
  - Token 黑名单（可选）：用户撤销 token 时加入黑名单

### Step 7: Flutter 开发者控制台

- [ ] **7.1** 在 Flutter 开发者设置页中增加「开放平台」入口
- [ ] **7.2** 应用列表页 — 展示当前租户的应用
- [ ] **7.3** 创建应用页 — 表单（名称、描述、类型）
- [ ] **7.4** 应用详情页 — 基本信息、app_id/app_secret 展示、Webhook 配置

### Step 8: 集成测试

- [ ] **8.1** 后端测试 — App CRUD 全流程（创建/查询/修改/删除/轮换密钥）
- [ ] **8.2** 后端测试 — 鉴权测试（正确的 app_id/app_secret → token，错误的 → 拒绝）
- [ ] **8.3** 后端测试 — Bot 发送消息（创建 Bot → 发消息 → 验证消息入库）
- [ ] **8.4** 后端测试 — 事件订阅（配置 Webhook → Bot 接收消息 → 验证回调）
- [ ] **8.5** `backend_test` spec 文件 — 新增 `openapp` 测试描述

---

## M2: 开发者工具与 API 开放

### Step 9: 错误码与 Scope 校验（M2 Phase A）

- [ ] **9.1** Proto — `error.proto` 新增开放平台错误码：
  - `ErrorOpenApiScopeDenied = 21001`
  - `ErrorOpenApiRateLimit = 21002`
  - `ErrorOpenApiTokenExpired = 21003`
  - `ErrorOpenApiAuthFailed = 21004`
  - `ErrorOpenApiAppDisabled = 21005`
  - `ErrorOpenApiNotFound = 21006`
- [ ] **9.2** OAuth 错误码：
  - `ErrorOAuthInvalidRequest = 21010`
  - `ErrorOAuthInvalidClient = 21011`
  - `ErrorOAuthInvalidGrant = 21012`
  - `ErrorOAuthUnauthorizedClient = 21013`
  - `ErrorOAuthRedirectMismatch = 21014`
  - `ErrorOAuthAccessDenied = 21015`
- [ ] **9.3** `AppAuth` extractor 增加 `require_scope(&self, scope: &str) → Result<()>` 方法
- [ ] **9.4** `openapps` 表新增 `redirect_uris` 字段迁移

### Step 10: BizXxx 跨模块接口扩展（M2 Phase A）

- [ ] **10.1** `common/src/service.rs` — `BizIm` trait 新增：
  - `get_chat(ctx, brief, chat_id) → Result<ChatInfo>`
  - `list_chat_members(ctx, brief, chat_id, page, page_size) → Result<MemberList>`
  - `list_messages(ctx, brief, chat_id, page, page_size, before_id) → Result<MessageList>`
- [ ] **10.2** `common/src/service.rs` — `BizUser` trait 新增：
  - `list_depts(ctx, brief, tenant_id) → Result<Vec<DeptInfo>>`
  - `get_dept(ctx, brief, dept_id) → Result<DeptInfo>`
  - `list_dept_members(ctx, brief, dept_id, page, page_size) → Result<MemberList>`
- [ ] **10.3** `common/src/service.rs` — `BizCalendar` trait 新增：
  - `list_calendars(ctx, brief, tenant_id) → Result<Vec<CalendarInfo>>`
  - `list_events(ctx, brief, calendar_id, start, end) → Result<Vec<EventInfo>>`
  - `create_event(ctx, brief, calendar_id, event) → Result<i64>`
- [ ] **10.4** `backend/im/src/lib.rs` — 实现 `BizIm` 新增接口
- [ ] **10.5** `backend/user/src/lib.rs` — 实现 `BizUser` 新增接口
- [ ] **10.6** `backend/calendar/src/lib.rs` — 实现 `BizCalendar` 新增接口

### Step 11: 开放 API 网关 Handlers（M2 Phase A）

- [ ] **11.1** 创建 `backend/openapp/src/handlers/open_api.rs` — IM 开放 API：
  - `GET /im/chats/{chat_id}` — 获取群信息（scope: `im:chat:read`）
  - `GET /im/chats/{chat_id}/members` — 成员列表（scope: `im:chat:read`）
  - `POST /im/messages` — 代用户发消息（scope: `im:message:write`）
  - `GET /im/chats/{chat_id}/messages` — 消息历史（scope: `im:message:read`）
- [ ] **11.2** `open_api.rs` — User 开放 API：
  - `GET /user/users/{user_id}` — 用户信息（scope: `user:info:read`）
  - `POST /user/users/batch` — 批量用户（scope: `user:info:read`）
  - `GET /user/depts` — 部门列表（scope: `user:dept:read`）
  - `GET /user/depts/{dept_id}` — 部门详情（scope: `user:dept:read`）
  - `GET /user/depts/{dept_id}/members` — 部门成员（scope: `user:dept:read`）
- [ ] **11.3** `open_api.rs` — Calendar 开放 API：
  - `GET /calendar/calendars` — 日历列表（scope: `calendar:event:read`）
  - `GET /calendar/events` — 日程查询（scope: `calendar:event:read`）
  - `POST /calendar/events` — 创建日程（scope: `calendar:event:write`）
- [ ] **11.4** `open_api.rs` — Files 开放 API（透明代理到 store 现有 route）：
  - `POST /files/upload` — 上传文件（scope: `file:write`）
  - `GET /files/{file_id}` — 下载文件（scope: `file:read`）
  - `GET /files/{file_id}/info` — 文件信息（scope: `file:read`）
- [ ] **11.5** 在 `middleware.rs` 中插入 API 调用统计中间件（异步更新 `open_app_stats`）

### Step 12: 数据库迁移 — M2（M2 Phase A）

- [ ] **12.1** DB Migration — `m20260723_100004_open_app_stats` 创建 `open_app_stats` 表
- [ ] **12.2** DB Migration — `m20260723_100005_open_apps_redirect_uris` `open_apps` 表新增 `redirect_uris`

### Step 13: Vue SPA 开发者后台 — 应用管理（M2 Phase B）

- [ ] **13.1** 创建 `frontend/src/services/openapp.ts` — 开放平台 API 调用封装
- [ ] **13.2** 创建 `frontend/src/stores/openapp.ts` — Pinia store（应用列表、当前应用）
- [ ] **13.3** 路由注册 — 在 `router/index.ts` 中新增 `/open/*` 路由
- [ ] **13.4** 创建 `frontend/src/views/open/apps/AppList.vue` — 应用列表页（表格 + 创建按钮 + 分页）
- [ ] **13.5** 创建 `frontend/src/views/open/apps/AppCreate.vue` — 创建应用页（表单 + app_secret 展示）
- [ ] **13.6** 创建 `frontend/src/views/open/apps/AppDetail.vue` — 详情页（编辑 + secret 查看/轮换 + scope 选择）
- [ ] **13.7** 创建 `frontend/src/views/open/apps/AppBotConfig.vue` — Bot 配置页（Webhook + 事件订阅开关）
- [ ] **13.8** 创建 `frontend/src/views/open/stats/ApiStats.vue` — API 调用统计页（趋势图 + 错误率）

### Step 14: OAuth 2.0 授权（M2 Phase C）

- [ ] **14.1** DB Migration — `m20260723_100006_open_app_authorizations` 创建 `open_app_authorizations` 表
- [ ] **14.2** DB Migration — `m20260723_100007_open_app_user_tokens` 创建 `open_app_user_tokens` 表
- [ ] **14.3** 创建 `backend/openapp/src/models/authorization.rs` — `OpenAppAuthorizationModel`
- [ ] **14.4** 创建 `backend/openapp/src/models/user_token.rs` — `OpenAppUserTokenModel`
- [ ] **14.5** 创建 `backend/openapp/src/services/oauth.rs` — OAuth 核心逻辑：
  - `generate_authorization_code()` / `validate_authorization_code()`
  - `exchange_code_for_token()` → 签发 access_token + refresh_token
  - `refresh_token()` → 轮换 refresh_token
  - `validate_user_access_token()` → 解析 JWT 返回 UserBrief
  - `revoke_authorization()` → 撤销授权 + 失效所有 token
- [ ] **14.6** 创建 `backend/openapp/src/handlers/oauth.rs` — OAuth 端点：
  - `GET /oauth/authorize` — 参数验证 + 重定向到确认页（Vue SPA）
  - `POST /oauth/authorize` — 用户确认授权 → 生成 code
  - `POST /oauth/token` — 换取/刷新 token（支持 authorization_code 和 refresh_token）
  - `DELETE /oauth/authorizations/{id}` — 撤销授权
- [ ] **14.7** 创建 `frontend/src/views/open/oauth/Authorize.vue` — OAuth 授权确认页（应用信息 + 权限列表 + 确认/拒绝按钮）
- [ ] **14.8** 在 Flutter 设置页中增加「已授权应用」列表 + 撤销功能

### Step 15: 出站 Webhook（M2 Phase D）

- [ ] **15.1** DB Migration — `m20260723_100008_open_app_outgoing_webhooks` 创建 `open_app_outgoing_webhooks` 表
- [ ] **15.2** 创建 `backend/openapp/src/models/outgoing_webhook.rs` — CRUD model
- [ ] **15.3** `backend/openapp/src/handlers/app.rs` 增补出站 Webhook 管理 API：
  - `POST /apps/{app_id}/outgoing_webhooks`
  - `PUT /apps/{app_id}/outgoing_webhooks/{webhook_id}`
  - `DELETE /apps/{app_id}/outgoing_webhooks/{webhook_id}`
  - `GET /apps/{app_id}/outgoing_webhooks`
- [ ] **15.4** 在 IM 模块消息发送流程中插入出站 Webhook 触发钩子：
  - 消息入库后检查 chat 是否绑定出站 Webhook
  - 匹配 command → POST 到 webhook_url
  - 获取响应 → 以 Bot 身份发送回复消息
- [ ] **15.5** Outgoing Webhook 的前端配置 UI（在 AppBotConfig.vue 中新增 Tab）

### Step 16: API 调用统计（M2 Phase D）

- [ ] **16.1** 在 `middleware.rs` 中实现 API 调用统计中间件（每请求异步更新 stat）
- [ ] **16.2** 创建 `backend/openapp/src/models/api_stat.rs` — `OpenAppStatModel`
- [ ] **16.3** `open_api.rs` 增补统计查询端点：
  - `GET /apps/stats/{app_id}?period=day` — 调用统计
  - `GET /apps/stats/{app_id}/error_logs` — 错误日志

### Step 17: M2 集成测试

- [ ] **17.1** 后端测试 — IM 开放 API（群信息/成员/消息历史/代发消息）
- [ ] **17.2** 后端测试 — User 开放 API（用户信息/部门/成员）
- [ ] **17.3** 后端测试 — Calendar 开放 API（日历/日程）
- [ ] **17.4** 后端测试 — OAuth 2.0 全流程（authorize → code → token → refresh → revoke）
- [ ] **17.5** 后端测试 — 出站 Webhook 触发流程
- [ ] **17.6** 后端测试 — Scope 鉴权校验（无权限调用返回 21001）
- [ ] **17.7** `backend_test` spec 文件 — 新增 M2 测试描述

---

## M3: Bot 高级能力

### Step 18: 交互式卡片 Proto 与 API（M3 Phase A）

- [ ] **18.1** Proto — 新增 `proto/card.proto`：
  - `CardHeader`, `CardText`, `CardButton`, `CardImage`, `CardDivider`, `CardElement`, `InteractiveCard`
- [ ] **18.2** Proto — `entity.proto` `MessageType` 新增 `INTERACTIVE_CARD = 17`
- [ ] **18.3** Proto — `openapp.proto` 新增 `CardActionCallback` 消息
- [ ] **18.4** Proto — `command.proto` 新增命令码：
  - `CMD_CARD_ACTION = 2001`
  - `CMD_CARD_UPDATE = 2002`
  - `CMD_CARD_TEMPLATE = 2003`
- [ ] **18.5** 在 `openapp` 中注册命令码处理（`handled_command` 返回 `[2001, 2002, 2003]`）
- [ ] **18.6** `backend/openapp/src/handlers/card.rs` — 卡片 API：
  - 卡片消息发送（通过 `POST /bot/message` + `msg_type=interactive_card` 复用 M1 接口）
  - `PATCH /bot/card/{message_id}` — 更新卡片内容（不生成新消息，原地替换）
  - `CMD_CARD_ACTION` 处理 — 按钮点击 → 回调 Bot Webhook → 返回确认

### Step 19: 卡片 Flutter 渲染（M3 Phase A）

- [ ] **19.1** 创建 `buzzing/lib/widgets/message_card.dart` — 卡片渲染入口（判断 msg_type=17 时渲染）
- [ ] **19.2** 创建 `card_header.dart` — 标题栏组件（颜色竖条 + 标题文字）
- [ ] **19.3** 创建 `card_element.dart` — 元素分发器（按 tag 分发到各组件）
- [ ] **19.4** 创建 `card_text_element.dart` — 文本元素（支持 Markdown 渲染）
- [ ] **19.5** 创建 `card_button_element.dart` — 按钮元素（绑定点击事件，发送 CMD_CARD_ACTION）
- [ ] **19.6** 创建 `card_image_element.dart` — 图片元素（从 store 加载图片）
- [ ] **19.7** 创建 `card_divider_element.dart` — 分割线组件
- [ ] **19.8** 实现 `CMD_CARD_UPDATE` 处理 — 客户端收到后原地刷新卡片（不闪烁或重排）

### Step 20: SDK CardBuilder（M3 Phase A）

- [ ] **20.1** 创建 `sdk/src/biz/card.rs` — `CardBuilder` 工具：
  - `new(title, color)` / `add_text(content, markdown)` / `add_button(text, value, style)` / `add_image(image_key, alt)` / `add_divider()` / `build() → String`
- [ ] **20.2** 在 `sdk/src/lib.rs` 中导出 card 模块

### Step 21: Bot 互动回复（M3 Phase B）

- [ ] **21.1** Bot 消息支持 `reply_to` 参数 → 设置 `Message.reply_to_id`
- [ ] **21.2** Bot 消息支持 `mention_all` 参数 → 设置 `Message.mentions` 为全体成员
- [ ] **21.3** 事件推送 `im.message.receive` payload 中增加 `reactions` 字段
- [ ] **21.4** 新增事件类型 `im.message.reaction_added` / `im.message.reaction_removed`
- [ ] **21.5** Bot Reaction API：
  - `POST /bot/message/{message_id}/reactions` — 添加 Reaction
  - `DELETE /bot/message/{message_id}/reactions` — 移除 Reaction
- [ ] **21.6** IM 模块插入 Reaction 事件触发钩子（`add_reaction` / `remove_reaction` 时判断消息发送者是否为 Bot）

### Step 22: 定时/周期任务（M3 Phase C）

- [ ] **22.1** DB Migration — `m20260723_100009_open_app_scheduled_tasks` 创建 `open_app_scheduled_tasks` 表
- [ ] **22.2** 创建 `backend/openapp/src/models/scheduled_task.rs` — `OpenAppScheduledTaskModel`
- [ ] **22.3** Cargo.toml — 添加 `tokio-cron-scheduler = "0.11"` 依赖
- [ ] **22.4** 创建 `backend/openapp/src/services/scheduler.rs` — `TaskScheduler`：
  - `start(ctx)` — 启动调度器，加载所有启用的任务
  - `register_job(task)` — 注册单个 cron job
  - `remove_job(task_id)` — 移除 job
  - `reload(ctx)` — 重载所有任务
  - `execute_send_message(ctx, task)` — 按模板发消息
  - `execute_call_webhook(ctx, task)` — 回调 webhook
- [ ] **22.5** 在 `AppOpenApp::serve()` 中启动 `TaskScheduler`
- [ ] **22.6** Bot 定时任务管理 API：
  - `POST /bot/scheduled_tasks` — 创建
  - `GET /bot/scheduled_tasks` — 列表
  - `PUT /bot/scheduled_tasks/{task_id}` — 修改
  - `DELETE /bot/scheduled_tasks/{task_id}` — 删除
  - `POST /bot/scheduled_tasks/{task_id}/pause` — 暂停
  - `POST /bot/scheduled_tasks/{task_id}/resume` — 恢复
- [ ] **22.7** Vue SPA 定时任务管理 UI（在 Bot 配置页新增 Tab）

### Step 23: Bot 管理能力（M3 Phase D）

- [ ] **23.1** `common/src/service.rs` — `BizIm` trait 新增：
  - `create_bot_chat(ctx, brief, name, desc, member_ids) → Result<i64>`
  - `add_chat_members(ctx, brief, chat_id, member_ids) → Result<()>`
  - `remove_chat_members(ctx, brief, chat_id, member_ids) → Result<()>`
  - `set_chat_announcement(ctx, brief, chat_id, announcement) → Result<()>`
  - `add_message_reaction(ctx, brief, message_id, reaction) → Result<()>`
  - `remove_message_reaction(ctx, brief, message_id, reaction) → Result<()>`
- [ ] **23.2** `backend/im/src/lib.rs` — 实现 `BizIm` 管理类接口
- [ ] **23.3** Bot 管理 API（Tenant Access Token + scope 校验）：
  - `POST /bot/chats` — 创建群聊（scope: `bot:chat:write`）
  - `POST /bot/chats/{chat_id}/members` — 邀请成员（scope: `bot:chat:write`）
  - `DELETE /bot/chats/{chat_id}/members` — 移除成员（scope: `bot:chat:write`）
  - `PUT /bot/chats/{chat_id}/announcement` — 设置公告（scope: `bot:announcement:write`）
- [ ] **23.4** scope 注册 — 新增 `bot:chat:write`、`bot:chat:read`、`bot:announcement:write`
- [ ] **23.5** Bot 管理频率限制（日创建群聊上限 50）

### Step 24: M3 集成测试

- [ ] **24.1** 后端测试 — 卡片消息发送 + 更新 + 按钮回调
- [ ] **24.2** 后端测试 — Reaction 事件触发与推送
- [ ] **24.3** 后端测试 — 定时任务创建/执行/暂停/恢复
- [ ] **24.4** 后端测试 — Bot 创建群聊/管理成员/设置公告
- [ ] **24.5** `backend_test` spec 文件 — 新增 M3 测试描述

---

## M4: 应用市场与生态

### Step 25: 应用版本与市场信息（M4 Phase A）

- [ ] **25.1** DB Migration — `m20260801_100010_open_app_versions` 创建 `open_app_versions` 表
- [ ] **25.2** DB Migration — `m20260801_100011_open_app_market_info` 创建 `open_app_market_info` 表
- [ ] **25.3** 创建 `backend/openapp/src/models/version.rs` — `OpenAppVersionModel`
- [ ] **25.4** 创建 `backend/openapp/src/models/market_info.rs` — `OpenAppMarketInfoModel`
- [ ] **25.5** 版本市场 API：
  - `POST /apps/{app_id}/versions` — 提交新版本（含 market_info）
  - `GET /apps/{app_id}/versions` — 版本列表
  - `POST /apps/{app_id}/market/icon` — 上传图标
  - `POST /apps/{app_id}/market/screenshots` — 上传截图
- [ ] **25.6** Vue SPA 应用市场发布页（在 AppDetail 中集成版本管理 UI）

### Step 26: 应用安装与授权（M4 Phase B）

- [ ] **26.1** DB Migration — `m20260801_100012_open_app_installations` 创建 `open_app_installations` 表
- [ ] **26.2** 创建 `backend/openapp/src/models/installation.rs` — `OpenAppInstallationModel`
- [ ] **26.3** 安装管理 API：
  - `GET /market/apps` — 市场应用列表（已上架应用，分页 + 分类筛选 + 搜索）
  - `GET /market/apps/{app_id}` — 应用市场详情
  - `POST /market/install` — 安装应用（创建 installation + 自动 Bot 入群 + 配置 Webhook）
  - `GET /market/installed` — 已安装应用列表
  - `POST /market/installed/{id}/enable` — 启用
  - `POST /market/installed/{id}/disable` — 停用
  - `DELETE /market/installed/{id}` — 卸载（Bot 退群 + 回收 Webhook + 清理 Token）
  - `PUT /market/installed/{id}/visibility` — 修改可见范围
- [ ] **26.4** Vue SPA 市场页面：
  - `MarketLayout.vue` — 市场布局（搜索栏 + 分类标签）
  - `MarketHome.vue` — 市场首页（Banner + 分类列表 + 卡片网格）
  - `AppDetail.vue` — 应用详情（展示信息 + 截图 + 权限 + 评分 + 安装按钮）
  - `AppInstall.vue` — 安装确认（可见范围选择 + 权限确认）
- [ ] **26.5** Vue SPA 已安装应用管理页（设置/管理 → 已安装应用列表 + 启用/停用/卸载操作）
- [ ] **26.6** 安装/卸载事件推送（`app.installed` / `app.uninstalled` → Bot Webhook）

### Step 27: 应用审核后台（M4 Phase C）

- [ ] **27.1** 审核 API：
  - `GET /admin/reviews?status=0` — 审核列表（待审核/已通过/已驳回）
  - `GET /admin/reviews/{version_id}` — 审核详情
  - `POST /admin/reviews/{version_id}/approve` — 通过（更新版本状态 + 上架市场）
  - `POST /admin/reviews/{version_id}/reject` — 驳回（填写原因）
  - `POST /admin/reviews/{app_id}/unpublish` — 下架
- [ ] **27.2** Vue SPA 审核后台页面：
  - `ReviewList.vue` — 审核列表（表格 + 状态筛选 + 分页）
  - `ReviewDetail.vue` — 审核详情（查看版本信息 + 权限 + 操作按钮）
- [ ] **27.3** 管理员权限守卫（仅 admin / super_admin 角色）

### Step 28: 应用评分与评价（M4 Phase D）

- [ ] **28.1** DB Migration — `m20260801_100013_open_app_reviews` 创建 `open_app_reviews` 表
- [ ] **28.2** 创建 `backend/openapp/src/models/review.rs` — `OpenAppReviewModel`
- [ ] **28.3** 评价 API：
  - `POST /market/apps/{app_id}/reviews` — 提交/修改评价
  - `GET /market/apps/{app_id}/reviews` — 评价列表（分页）
  - `POST /market/apps/{app_id}/reviews/{review_id}/reply` — 开发者回复
  - `GET /market/apps/{app_id}/ratings` — 评分聚合（平均分 + 分布）
- [ ] **28.4** Vue SPA 评价组件（嵌入 AppDetail 页面）：
  - 评分展示（星数 + 平均分 + 分布条形图）
  - 评价列表 + 开发者回复
  - 评价表单（仅已安装用户可评，每人一次）
  - 敏感词过滤

### Step 29: 开放平台 Dashboard（M4 Phase D）

- [ ] **29.1** DB Migration — `m20260801_100014_open_app_stats_event` 扩展 `open_app_stats` 表新增事件推送统计
- [ ] **29.2** Dashboard API：
  - `GET /dashboard/overview` — 总览数据（安装数/活跃数/调用量/Bot 消息量/推送成功率）
  - `GET /dashboard/trends?metric=api_calls&period=week` — 趋势数据
- [ ] **29.3** Vue SPA Dashboard 页面：
  - 统计数字卡片（安装数/活跃数/调用量/Bot 消息量）
  - 调用量趋势图（ECharts/Chart.js，支持日/周/月切换）
  - 事件推送成功率指标
  - 各应用 Top 5 调用排行

### Step 30: M4 集成测试

- [ ] **30.1** 后端测试 — 版本提交 + 审核流程（提交 → 通过 → 上架 → 下架）
- [ ] **30.2** 后端测试 — 应用安装/卸载全流程（含 Bot 自动入群/退群）
- [ ] **30.3** 后端测试 — 评价/回复/评分聚合
- [ ] **30.4** 后端测试 — Dashboard 数据聚合
- [ ] **30.5** `backend_test` spec 文件 — 新增 M4 测试描述

---

## 实施顺序总览

```
M1 (P0): Step 0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8
M2 (P0): Step 9 → 10 → 11 → 12 → 13 → 14 → 15 → 16 → 17
M3 (P1): Step 18 → 19 → 20 → 21 → 22 → 23 → 24
M4 (P1): Step 25 → 26 → 27 → 28 → 29 → 30
```

**里程碑依赖关系：**

```
M1 完成后 → M2 可并行 M3
M2 完成后 → M4
M3 不依赖 M2，可与 M2 并行
M4 依赖 M2（开发者工具）和 M3（Bot 高级能力）
```

**并行建议：**
- M1 Step 0-3 完成后，M2 Step 9-12（API 网关）即可开始（不依赖 M1 Step 4-5 的 Bot 部分）
- M3 Step 18-20（卡片 Proto + 渲染）可与 M2 并行
- M4 的 DB 迁移可提前进行，业务逻辑待 M2+M3 完成后接入
