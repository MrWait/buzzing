# Open Platform — Milestone Plan

> 目标：为 Buzzing 构建完整的企业级开放平台，支持 Bot、应用接入、事件订阅、开发者工具与应用市场。

---

## M1: 开放平台基础（8 周）

### 1.1 数据模型与 DB
- `open_apps` 表 — 应用（id, name, description, app_type, app_secret, owner_id, tenant_id, permissions, status, created_at）
- `open_app_bots` 表 — Bot 配置（app_id, webhook_url, webhook_token, event_subscriptions, status）
- `open_app_tokens` 表 — 已签发的 access_token（app_id, token, scopes, expire_at）
- 租户隔离：所有开放平台数据按 tenant_id 分区

### 1.2 App 注册与鉴权
- `POST /openapi/apps/register` — 创建应用（生成 app_id + app_secret）
- `POST /openapi/auth/tenant_access_token` — 获取 tenant_access_token（app_id + app_secret → JWT）
- `GET /openapi/apps/{id}` — 查询应用信息
- `PUT /openapi/apps/{id}` — 修改应用
- `DELETE /openapi/apps/{id}` — 删除应用
- app_secret 支持定期轮换（Rotate）

### 1.3 Bot 基础能力
- Bot 作为特殊用户存在 — `UserType.BOT`，可加入群聊、收发消息
- `POST /openapi/bot/send_message` — Bot 主动发送消息（文本/图片/文件/Markdown）
- `POST /openapi/bot/edit_message` — Bot 编辑已发送消息
- Bot 接收消息回调 → 推送到开发者配置的 webhook
- Bot 消息频率限制（Rate Limit）：租户级别、Bot 级别

### 1.4 事件订阅（Event Subscription）
- Webhook 回调机制：开发者配置 callback URL，Buzzing POST 事件 payload
- 事件签名验证：HMAC-SHA256（app_secret 派生的 signing_key）
- 事件重试：按指数退避最多重试 3 次
- 核心事件类型：
  - `im.message.receive` — Bot 收到消息
  - `im.group.added_bot` — Bot 被加入群聊
  - `im.group.removed_bot` — Bot 被移出群聊
  - `im.group.member_added` / `member_removed`
- 事件去重：事件 ID（event_id）全局唯一，开发者幂等处理

### 1.5 后端模块
- 新增 `backend/openapp/` 模块，实现 `ExternApp` trait 注册到 `AppHub`
- 路由：`/openapi/*` 前缀，统一鉴权中间件
- 鉴权中间件：验证 tenant_access_token，提取 app_id + tenant_id

---

## M2: 开发者工具与 API 开放（8 周）

### 2.1 API 开放网关
- 基于现有 gateway 模块开放标准化 REST API
- `/openapi/im/*` — IM 相关 API（获取群信息、成员列表、发送消息等）
- `/openapi/user/*` — 用户/部门 API（获取用户信息、组织架构等）
- `/openapi/calendar/*` — 日历 API
- `/openapi/files/*` — 文件 API（上传/下载）
- API 权限分级：read / write / admin，在 app 注册时声明

### 2.2 开发者后台（Vue SPA）
- 在 `frontend/` 中新增开发者控制台页面
- 应用列表页：展示已创建的应用、状态、操作
- 应用详情页：基本信息编辑、app_secret 查看/轮换
- Bot 配置页：Webhook URL 配置、事件订阅开关
- 权限申请页：选择 API 作用域
- 调用统计：API 调用次数、错误率、延时

### 2.3 OAuth 2.0 授权
- 标准 OAuth 2.0 Authorization Code 流程
- `/openapi/oauth/authorize` — 用户授权页面
- `/openapi/oauth/token` — 换取 user_access_token
- `/openapi/oauth/refresh` — 刷新 token
- 支持 scope 声明（`im:message:read`, `im:message:write`, `user:info:read` 等）
- 授权记录管理：用户可在设置页查看/撤销已授权的应用

### 2.4 Webhook 出站
- 支持配置出站 Webhook（Outgoing Webhook）：群聊中通过关键词触发
- 群聊中输入 `/command` 触发 → POST 到配置 URL → 返回结果展示

### 2.5 SDK 与文档
- 提供 REST API 文档（OpenAPI/Swagger）
- 提供 Webhook 事件 payload 文档
- Bot 快速开始教程

---

## M3: Bot 高级能力（6 周）

### 3.1 交互式消息卡片
- Proto 定义：`InteractiveCard` 消息类型（`MessageType.INTERACTIVE_CARD = 17`）
- 卡片消息格式（JSON 定义，存储在 `content` 中）：
  ```json
  {
    "header": {"title": "...", "color": "blue"},
    "elements": [
      {"tag": "text", "content": "..."},
      {"tag": "button", "text": "确认", "value": "confirm", "style": "primary"},
      {"tag": "button", "text": "取消", "value": "cancel", "style": "default"}
    ]
  }
  ```
- 卡片支持：文本、按钮（主/次/危险）、图片、分割线、Markdown
- 按钮点击回调 → POST 到 Bot Webhook（含 action_value + message_id + user_id）
- Bot 回复更新卡片（`card_update` API，仅替换内容而非整条消息）

### 3.2 Bot 互动回复
- Bot 支持回复消息时的关联线程（回复链）
- Bot 支持 @ 提及感知
- Bot 消息支持表情回应（Reaction）事件通知

### 3.3 定时/周期任务
-  Bot 注册定时任务 — cron 表达式
- 系统按时触发 Bot 回调 → Bot 推送消息
- 示例："每日早报 Bot"每天早上 9:00 推送群消息

### 3.4 Bot 管理能力
- Bot 创建群聊
- Bot 邀请/移除成员
- Bot 设置群公告
- Bot 操作需声明权限并在用户安装时确认

---

## M4: 应用市场与生态（6 周）

### 4.1 应用发布流程
- 应用版本管理：version, release_notes, package
- 应用审核流程：提交 → 平台审核 → 通过/驳回 → 上架
- 应用分类：Bot / 集成 / 工具 / 日历插件
- 应用图标 + 描述 + 截图

### 4.2 应用安装与授权
- 应用市场页面：浏览、搜索、分类筛选
- 应用详情页：介绍、评分、权限列表、安装量
- 一键安装流程：选择可见范围 → 确认权限 → 安装完成
- 安装后自动 Bot 入群、配置 Webhook
- 管理员可管理已安装应用（启用/停用/卸载）

### 4.3 应用审核后台
- 审核列表：待审核 / 已通过 / 已驳回
- 审核详情：查看版本信息、权限声明、测试
- 审核操作：通过 / 驳回（填写原因）

### 4.4 应用评分与评价
- 用户可评分（1-5 星）+ 文字评价
- 评分聚合展示
- 开发者可回复评价

### 4.5 开放平台 Dashboard
- 租户级开放平台总览：
  - 已安装应用数 / 活跃应用数
  - API 调用量趋势
  - Bot 消息量趋势
  - 事件推送成功率

---

## M5: 企业级增强（4 周）

### 5.1 审计日志
- 记录所有开放平台的 API 调用、事件推送、权限变更
- 日志持久化存储，支持按时间 / 应用 / 用户检索
- 管理后台可查看审计日志

### 5.2 安全增强
- IP 白名单：限制特定 IP 才能调用 API
- API 调用频率控制（Rate Limiter by token/app/user）
- 敏感操作二次确认（如删除应用、轮换 secret）

### 5.3 多语言与国际化
- 应用信息支持多语言（zh/en）
- Bot 消息按用户语言推送

### 5.4 合规与数据导出
- 应用数据使用声明
- 用户可导出应用相关数据
- 应用停用/卸载后的数据清理

---

## 技术设计要点

### 鉴权流程
```
[Third-Party App]            [Buzzing OpenAPI]
       |                           |
       |-- POST /auth/tenant_access_token --> (app_id + app_secret)
       |                           |-- 验证 app_id/app_secret
       |                           |-- 生成 JWT（含 tenant_id, app_id, scopes, exp）
       |<-- { token, expire } -----|
       |                           |
       |-- GET /openapi/im/xxx --> (Authorization: Bearer <token>)
       |                           |-- 验证 JWT
       |                           |-- 鉴权 scope
       |                           |-- 执行业务逻辑
       |<-- { data } --------------|
```

### 模块结构
```
backend/openapp/
├── Cargo.toml
├── src/
│   ├── lib.rs              — ExternApp 注册 + 路由挂载
│   ├── models/
│   │   ├── mod.rs
│   │   ├── app.rs           — open_apps CRUD
│   │   ├── bot.rs           — bot 配置
│   │   └── token.rs         — token 管理
│   ├── handlers/
│   │   ├── mod.rs
│   │   ├── auth.rs          — token 签发
│   │   ├── app_crud.rs      — app 增删改查
│   │   ├── bot.rs           — bot 消息发送/编辑
│   │   └── event.rs         — 事件推送
│   ├── middleware.rs         — 鉴权中间件
│   └── services/
│       ├── mod.rs
│       └── webhook.rs       — webhook 推送 + 重试 + 签名
```

### Bot 用户模型
- `users` 表新增字段 `bot_app_id`（Nullable，指向 open_apps.id）
- `UserType` 新增 `USER_TYPE_BOT = 3`
- Bot 用户无密码、无登录能力，仅通过 API 交互
- Bot 消息走现有消息通道，`from_id` 为 Bot 用户 ID

### 事件推送格式
```json
{
  "event_id": "evt_xxxxx",
  "app_id": "app_xxxxx",
  "tenant_id": 12345,
  "type": "im.message.receive",
  "timestamp": 1712345678000,
  "payload": {
    "message_id": 67890,
    "chat_id": 12345,
    "sender_id": 54321,
    "content": "...",
    "message_type": 1
  }
}
```

### Proto 扩展（M3 交互式卡片）
```
proto/entity.proto:
- MessageType.INTERACTIVE_CARD = 17

proto/card.proto (新增):
- message CardHeader { string title, string color }
- message CardElement { oneof { CardText text, CardButton button, CardImage image, CardDivider divider } }
- message CardText { string content, bool markdown }
- message CardButton { string text, string value, string style }
- message CardImage { string image_key, string alt }
- message CardDivider {}
- message InteractiveCard { CardHeader header, repeated CardElement elements }
```

---

## 优先级建议

| 里程碑 | 优先级 | 说明 |
|--------|--------|------|
| M1     | P0     | 开放平台基础：基础能力，使第三方可以构建 Bot 和调用 API |
| M2     | P0     | 开发者工具：让开发者可自助管理和调试 |
| M3     | P1     | Bot 高级能力：交互式卡片是 Bot 体验的关键差异点 |
| M4     | P1     | 应用市场：生态价值，但需基础能力稳定后再上 |
| M5     | P2     | 企业级增强：安全合规，大型客户需求 |
