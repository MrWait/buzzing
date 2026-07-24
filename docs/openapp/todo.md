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

- [x] **3.1** `backend/openapp/src/models/app.rs` — `OpenAppModel`：
  - `create(db, owner_id, tenant_id, name, description, app_type)` → app + bot_user_id
  - `find_by_id(db, id)` / `find_by_app_id(db, app_id)`
  - `find_by_tenant(db, tenant_id, page, page_size)`
  - `update(db, app_id, fields)`
  - `soft_delete(db, app_id)`
  - `rotate_secret(db, app_id)` → new_secret
- [x] **3.2** `backend/openapp/src/models/bot.rs` — `OpenAppBotModel`：
  - `create_for_app(db, app_id, bot_user_id)`
  - `find_by_app(db, app_id)`
  - `update_webhook(db, app_id, webhook_url, event_types)`
  - `delete_by_app(db, app_id)`
- [x] **3.3** 创建 Bot 用户辅助函数 — `create_bot_user(db, app_id, tenant_id, name)`：
  - 写入 `users` 表，`type = USER_TYPE_BOT (3)`, `bot_app_id = app_id`
  - 生成 snowflake ID
  - 返回 `bot_user_id`
- [x] **3.4** `backend/openapp/src/handlers/app.rs` — 应用 CRUD：
  - `POST /apps` — 创建应用（自动创建 Bot 用户 + Bot 配置）
  - `GET /apps` — 列表（当前租户，分页）
  - `GET /apps/{app_id}` — 详情
  - `PUT /apps/{app_id}` — 修改
  - `DELETE /apps/{app_id}` — 删除（软删除 + 禁用 Bot 用户）
  - `POST /apps/{app_id}/rotate_secret` — 轮换密钥
  - `PUT /apps/{app_id}/bot` — 配置 Webhook + 订阅事件

### Step 4: Bot 消息收发

- [x] **4.1** 在 `common/src/service.rs` 中新增 `BizIm` trait
- [x] **4.2** 在 `backend/im/src/lib.rs` 中实现 `BizIm` trait
- [x] **4.3** 在 `backend/app/src/main.rs` 的 `BizHub` 中注册 `BizIm` 实现
- [x] **4.4** `backend/openapp/src/handlers/bot.rs` — Bot 消息 API

### Step 5: 事件订阅（Webhook）

- [x] **5.1** `backend/openapp/src/services/webhook.rs` — Webhook 推送服务
- [x] **5.2** 在 IM 模块中插入事件触发钩子（message.rs + chat.rs）
- [x] **5.3** 在 `common/src/service.rs` 中新增 `BizOpenApp` trait
- [x] **5.4** 在 `backend/openapp/src/lib.rs` 中实现 `BizOpenApp` trait
- [x] **5.5** 在 `backend/app/src/main.rs` 的 `BizHub` 中注册 `BizOpenApp` 实现

### Step 6: Rate Limiting & 安全加固

- [x] **6.1** 消息发送频率限制（moka per-app rate limiter）
- [x] **6.2** Token 签发频率限制
- [x] **6.3** app_secret 哈希存储（SHA-256）
- [x] **6.4** Tenant Access Token 缓存（JWT 无状态）

### Step 7: Flutter 开发者控制台

- [x] **7.1** 在 Flutter 开发者设置页中增加「开放平台」入口
- [x] **7.2** 应用列表页 — 展示当前租户的应用
- [x] **7.3** 创建应用页 — 表单（名称、描述、回调 URL）
- [x] **7.4** 应用详情页 — 基本信息（app_id/app_secret 可复制）、OAuth 重定向 URI 管理、Webhook CRUD、API 统计

### Step 8: 集成测试

- [ ] **8.1** 后端测试 — App CRUD 全流程
- [ ] **8.2** 后端测试 — 鉴权测试
- [ ] **8.3** 后端测试 — Bot 发送消息
- [ ] **8.4** 后端测试 — 事件订阅
- [ ] **8.5** `backend_test` spec 文件 — 新增 `openapp` 测试描述

---

## M2: 开发者工具与 API 开放

### Step 9: 错误码与 Scope 校验（M2 Phase A）

- [x] **9.1** Proto — `error.proto` 新增开放平台错误码
- [x] **9.2** OAuth 错误码
- [x] **9.3** `AppAuth` extractor 增加 `require_scope` 方法
- [x] **9.4** `openapps` 表新增 `redirect_uris` 字段迁移

### Step 10: BizXxx 跨模块接口扩展（M2 Phase A）

- [x] **10.1** `common/src/service.rs` — `BizIm` trait 新增（get_chat/list_members/list_messages）
- [x] **10.2** `common/src/service.rs` — `BizUser` trait 新增（list_depts/get_dept/list_members）
- [x] **10.3** `common/src/service.rs` — `BizCalendar` trait 新增（list_calendars/list_events/create_event）
- [x] **10.4** `backend/im/src/lib.rs` — 实现 `BizIm` 新增接口（部分）
- [x] **10.5** `backend/user/src/lib.rs` — 实现 `BizUser` 新增接口
- [x] **10.6** `backend/calendar/src/lib.rs` — 实现 `BizCalendar` 新增接口

### Step 11: 开放 API 网关 Handlers（M2 Phase A）

- [x] **11.1** 创建 `backend/openapp/src/handlers/open_api.rs` — IM 开放 API
- [x] **11.2** `open_api.rs` — User 开放 API
- [x] **11.3** `open_api.rs` — Calendar 开放 API
- [x] **11.4** `open_api.rs` — Files 开放 API
- [x] **11.5** 在 `middleware.rs` 中插入 API 调用统计中间件（model + handler ready，middleware 待接入）

### Step 12: 数据库迁移 — M2（M2 Phase A）

- [x] **12.1** DB Migration — `m20260728_100001_open_app_stats` 创建 `open_app_stats` 表
- [x] **12.2** DB Migration — `m20260728_100002_open_apps_redirect_uris` `open_apps` 表新增 `redirect_uris`

### Step 13: Vue SPA 开发者后台 — 应用管理（M2 Phase B）

- [x] **13.1** 创建 `frontend/src/services/openapp.ts` — 开放平台 API 调用封装
- [x] **13.2** 创建 `frontend/src/stores/openapp.ts` — Pinia store（应用列表、当前应用）
- [x] **13.3** 路由注册 — 在 `router/index.ts` 中新增 `/open/*` 路由
- [x] **13.4** 创建 `frontend/src/views/openapp/AppList.vue` — 应用列表页（卡片网格 + 创建按钮）
- [x] **13.5** 创建 `frontend/src/views/openapp/AppCreate.vue` — 创建应用页（表单）
- [x] **13.6** 创建 `frontend/src/views/openapp/AppDetail.vue` — 详情页（5 个 Tab：基本信息编辑 + OAuth + Webhook CRUD + 统计 + 版本提交审核）
- [x] **13.7** 创建 `frontend/src/views/openapp/AppBotConfig.vue` — Bot 配置页（Webhook URL + Token + 自动回复开关）
- [x] **13.8** 创建 `frontend/src/views/openapp/ApiStats.vue` — API 统计面板（4 个概览指标卡片 + 近 7 天趋势表格）

### Step 14: OAuth 2.0 授权（M2 Phase C）

- [x] **14.1** DB Migration — `m20260728_100003_open_app_authorizations` 创建 `open_app_authorizations` 表
- [x] **14.2** DB Migration — `m20260728_100004_open_app_user_tokens` 创建 `open_app_user_tokens` 表
- [x] **14.3** 创建 `backend/openapp/src/models/authorization.rs` — `AuthorizationModel`
- [x] **14.4** 创建 `backend/openapp/src/models/user_token.rs` — `UserTokenModel`
- [x] **14.5** 创建 `backend/openapp/src/services/oauth.rs` — OAuth 核心逻辑
- [x] **14.6** 创建 `backend/openapp/src/handlers/oauth.rs` — OAuth 端点
- [ ] **14.7** 创建前端 OAuth 授权确认页（Vue SPA）
- [ ] **14.8** 在 Flutter 设置页中增加「已授权应用」列表 + 撤销功能

### Step 15: 出站 Webhook（M2 Phase D）

- [x] **15.1** DB Migration — `m20260728_100005_open_app_outgoing_webhooks` 表
- [x] **15.2** 创建 `backend/openapp/src/models/outgoing_webhook.rs` — CRUD model
- [x] **15.3** `backend/openapp/src/handlers/app.rs` 增补出站 Webhook 管理 API
- [ ] **15.4** 在 IM 模块消息发送流程中插入出站 Webhook 触发钩子
- [ ] **15.5** Outgoing Webhook 的前端配置 UI（在 AppBotConfig.vue 中新增 Tab）

### Step 16: API 调用统计（M2 Phase D）

- [ ] **16.1** 在 `middleware.rs` 中实现 API 调用统计中间件（每请求异步更新 stat）
- [x] **16.2** 创建 `backend/openapp/src/models/api_stat.rs` — `ApiStatModel`
- [x] **16.3** `open_api.rs` 增补统计查询端点

### Step 17: M2 集成测试

- [ ] **17.1** ~ **17.7** M2 集成测试（待后续补充）

---

## M3: Bot 高级能力

### Step 18: 交互式卡片 Proto 与 API（M3 Phase A）

- [x] **18.1** Proto — 新增 `proto/card.proto`
- [x] **18.2** Proto — `entity.proto` `MessageType` 新增 `INTERACTIVE_CARD = 17`
- [x] **18.3** Proto — `openapp.proto` 新增 `CardActionCallback` 消息
- [x] **18.4** Proto — `command.proto` 新增命令码 `CMD_CARD_ACTION=2001`, `CMD_CARD_UPDATE=2002`, `CMD_CARD_TEMPLATE=2003`
- [x] **18.5** 在 `openapp` 中注册命令码处理（`handled_command`）
- [x] **18.6** `backend/openapp/src/handlers/card.rs` — 卡片 API

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

- [x] **21.1** Bot 消息支持 `reply_to` 参数
- [x] **21.2** Bot 消息支持 `mention_all` 参数（序列化层支持）
- [ ] **21.3** 事件推送 `im.message.receive` payload 中增加 `reactions` 字段
- [ ] **21.4** 新增事件类型 `im.message.reaction_added` / `im.message.reaction_removed`
- [x] **21.5** Bot Reaction API（add/remove reactions）
- [ ] **21.6** IM 模块插入 Reaction 事件触发钩子

### Step 22: 定时/周期任务（M3 Phase C）

- [x] **22.1** DB Migration — `m20260728_100006_open_app_scheduled_tasks` 表
- [x] **22.2** 创建 `backend/openapp/src/models/scheduled_task.rs`
- [x] **22.3** Cargo.toml — 添加 `tokio-cron-scheduler = "0.11"` 依赖
- [x] **22.4** 创建 `backend/openapp/src/services/scheduler.rs` — `TaskScheduler`
- [x] **22.5** 在 `AppOpenApp::serve()` 中启动 `TaskScheduler`
- [x] **22.6** Bot 定时任务管理 API（CRUD + pause/resume）
- [ ] **22.7** Vue SPA 定时任务管理 UI

### Step 23: Bot 管理能力（M3 Phase D）

- [x] **23.1** `common/src/service.rs` — `BizIm` trait 新增管理类接口
- [ ] **23.2** `backend/im/src/lib.rs` — 实现 `BizIm` 管理类接口（部分）
- [x] **23.3** Bot 管理 API（create_chat/add/remove_members/set_announcement）
- [x] **23.4** scope 注册 — `bot:chat:write`, `bot:chat:read`, `bot:announcement:write`
- [ ] **23.5** Bot 管理频率限制（日创建群聊上限 50）

### Step 24: M3 集成测试

- [ ] **24.1** ~ **24.5** M3 集成测试（待后续补充）

### Step 24: M3 集成测试

- [ ] **24.1** 后端测试 — 卡片消息发送 + 更新 + 按钮回调
- [ ] **24.2** 后端测试 — Reaction 事件触发与推送
- [ ] **24.3** 后端测试 — 定时任务创建/执行/暂停/恢复
- [ ] **24.4** 后端测试 — Bot 创建群聊/管理成员/设置公告
- [ ] **24.5** `backend_test` spec 文件 — 新增 M3 测试描述

---

## M4: 应用市场与生态

### Step 25: 应用版本与市场信息（M4 Phase A）

- [x] **25.1** DB Migration — `m20260728_100007_open_app_versions` 表
- [x] **25.2** DB Migration — `m20260728_100008_open_app_market_info` 表
- [x] **25.3** 创建 `backend/openapp/src/models/version.rs` — `VersionModel`
- [x] **25.4** 创建 `backend/openapp/src/models/market_info.rs` — `MarketInfoModel`
- [x] **25.5** 版本市场 API（submit/list_versions + market_info upsert）
- [ ] **25.6** Vue SPA 应用市场发布页

### Step 26: 应用安装与授权（M4 Phase B）

- [x] **26.1** DB Migration — `m20260728_100009_open_app_installations` 表
- [x] **26.2** 创建 `backend/openapp/src/models/installation.rs` — `InstallationModel`
- [x] **26.3** 安装管理 API（list/install/enable/disable/uninstall）
- [ ] **26.4** Vue SPA 市场页面
- [ ] **26.5** Vue SPA 已安装应用管理页
- [ ] **26.6** 安装/卸载事件推送

### Step 27: 应用审核后台（M4 Phase C）

- [x] **27.1** 审核 API（list/detail/approve/reject/unpublish）
- [ ] **27.2** Vue SPA 审核后台页面
- [ ] **27.3** 管理员权限守卫

### Step 28: 应用评分与评价（M4 Phase D）

- [x] **28.1** DB Migration — `m20260728_100010_open_app_reviews` 表
- [x] **28.2** 创建 `backend/openapp/src/models/review.rs` — `ReviewModel`
- [x] **28.3** 评价 API（create/list/reply/ratings）
- [ ] **28.4** Vue SPA 评价组件

### Step 29: 开放平台 Dashboard（M4 Phase D）

- [x] **29.1** DB Migration — `open_app_stats` 表已包含 event_push_count/failed 字段
- [x] **29.2** Dashboard API（overview/trends）
- [ ] **29.3** Vue SPA Dashboard 页面

### Step 30: M4 集成测试

- [ ] **30.1** ~ **30.5** M4 集成测试（待后续补充）

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
