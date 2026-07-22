# M4: 应用市场与生态 — 详细设计方案

> 设计目标：构建完整应用市场，支持应用发布、审核、安装、评分，提供租户级开放平台 Dashboard。
>
> 前提：M1（应用注册/Bot 基础）、M2（开发者工具/OAuth）、M3（Bot 高级能力）已完成。

---

## 一、应用发布流程

### 1.1 数据模型

**`open_app_versions` 表：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `bigint PK` | Snowflake ID |
| `app_id` | `bigint FK → open_apps.id` | 应用 ID |
| `version` | `varchar(32)` | 语义版本号，如 `1.0.0` |
| `release_notes` | `text` | 发布说明 |
| `status` | `smallint` | 0=待审核, 1=已通过, 2=已驳回, 3=已上架 |
| `review_comment` | `text` | 审核意见（驳回时填写） |
| `reviewed_by` | `bigint` | 审核人用户 ID |
| `reviewed_at` | `timestamptz` | 审核时间 |
| `created_at` | `timestamptz` | 创建时间 |

**`open_app_market_info` 表：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `app_id` | `bigint PK FK → open_apps.id` | 应用 ID |
| `app_category` | `varchar(32)` | 分类：`bot`, `integration`, `tool`, `calendar_plugin` |
| `icon_file_id` | `bigint` | store 文件 ID（图标） |
| `screenshots` | `bigint[]` | 截图文件 ID 列表 |
| `short_description` | `varchar(256)` | 短描述 |
| `detailed_description` | `text` | 详细描述 |
| `developer_name` | `varchar(128)` | 开发者名称 |
| `developer_email` | `varchar(256)` | 开发者联系邮箱 |
| `support_url` | `varchar(512)` | 技术支持链接 |
| `homepage_url` | `varchar(512)` | 应用主页 |
| `permissions` | `text[]` | 权限声明列表（人类可读） |
| `install_count` | `int DEFAULT 0` | 安装次数 |
| `rating_avg` | `float DEFAULT 0` | 平均评分 |
| `rating_count` | `int DEFAULT 0` | 评分人数 |
| `is_featured` | `boolean DEFAULT false` | 是否精选应用 |
| `created_at` | `timestamptz` | 创建时间 |
| `updated_at` | `timestamptz` | 更新时间 |

### 1.2 应用状态机

```
                  ┌──────────┐
                  │  草稿    │
                  └────┬─────┘
                       │ 提交审核
                       ▼
                  ┌──────────┐
           ┌─────│  待审核   │─────┐
           │     └──────────┘     │
           │         │            │
        ┌──┴──┐   ┌──┴──┐     ┌──┴──┐
        │通过 │   │驳回 │     │通过 │
        └──┬──┘   └──┬──┘     └──┬──┘
           ▼         ▼           ▼
     ┌─────────┐ ┌───────┐ ┌─────────┐
     │ 已上架  │ │ 已驳回 │ │ 已上架  │
     └────┬────┘ └───────┘ └─────────┘
          │ 下架
          ▼
     ┌─────────┐
     │ 已下架  │
     └─────────┘
```

### 1.3 开发者提交上架 API

**提交新版本（提交审核）：**

```
POST /openapi/v1/apps/{app_id}/versions
{
  "version": "1.0.0",
  "release_notes": "初始版本",
  "market_info": {
    "category": "bot",
    "short_description": "每日自动推送天气信息",
    "detailed_description": "天气 Bot 会在每天早上 9 点推送当天天气预报...",
    "developer_name": "张三",
    "developer_email": "zhangsan@example.com",
    "support_url": "https://example.com/support",
    "homepage_url": "https://example.com",
    "permissions": ["发送消息", "读取群信息"]
  }
}
```

响应：

```json
{
  "code": 0,
  "data": {
    "version_id": 12345,
    "version": "1.0.0",
    "status": 0,
    "created_at": 1712345678000
  }
}
```

**上传应用图标：**

```
POST /openapi/v1/apps/{app_id}/market/icon
Content-Type: multipart/form-data
file: <image>
```

**上传应用截图：**

```
POST /openapi/v1/apps/{app_id}/market/screenshots
Content-Type: multipart/form-data
files: [<image1>, <image2>, <image3>]
```

**查询应用版本列表：**

```
GET /openapi/v1/apps/{app_id}/versions
```

---

## 二、应用安装与授权

### 2.1 数据模型

**`open_app_installations` 表：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `bigint PK` | Snowflake ID |
| `app_id` | `bigint FK → open_apps.id` | 应用 ID |
| `tenant_id` | `bigint` | 安装租户 |
| `installer_id` | `bigint` | 安装者用户 ID |
| `scopes` | `text[]` | 实际授予的权限 |
| `status` | `smallint` | 0=已停用, 1=已启用, 2=已卸载 |
| `installed_at` | `timestamptz` | 安装时间 |
| `updated_at` | `timestamptz` | 更新时间 |
| `uninstalled_at` | `timestamptz` | 卸载时间 |

### 2.2 应用市场页面（Vue SPA）

在 `frontend/` 中新增市场页面：

```
frontend/src/
├── views/market/
│   ├── MarketLayout.vue         — 市场布局（搜索栏 + 分类标签）
│   ├── MarketHome.vue           — 市场首页（精选 Banner + 分类列表）
│   ├── AppDetail.vue            — 应用详情页
│   └── AppInstall.vue           — 安装确认页
```

**市场首页：**
- 顶部搜索栏（搜索应用名称/描述）
- 分类导航标签：全部 / Bot / 集成 / 工具 / 日历插件
- 卡片网格：应用图标 + 名称 + 短描述 + 评分 + 安装量
- 精选应用区域（Banner / 推荐）

**应用详情页：**
- 图标 + 名称 + 开发者
- 截图轮播
- 详细描述
- 权限列表（人类可读）
- 评分展示（平均分 + 星数分布 + 用户评价列表）
- 安装量统计
- 「安装」按钮

**安装确认页：**
- 应用信息摘要
- 可见范围选择：`全部成员` / `指定部门` / `指定成员`
- 权限确认列表
- 「确认安装」按钮

### 2.3 安装流程

```
[管理员]                    [Vue SPA]                    [Backend]              [Bot/App]
   |                           |                           |                      |
   |-- 浏览市场 → 点击安装 -->|                           |                      |
   |                           |-- 获取应用详情 --------->|                      |
   |                           |<-- 返回应用信息 + 权限 ---|                      |
   |-- 选择可见范围 ---------->|                           |                      |
   |-- 确认权限 ---------------|                           |                      |
   |                           |-- POST /openapi/v1/      |                      |
   |                           |    market/install        |                      |
   |                           |   { app_id, scope,       |                      |
   |                           |     visibility }         |                      |
   |                           |                           |-- 创建 installation  |
   |                           |                           |-- (Bot类型)自动入群  |
   |                           |                           |-- 配置 Webhook       |
   |                           |                           |-- 触发安装事件       |
   |                           |<-- 安装成功 -------------|                      |
   |<-- 跳转 "已安装应用" ----|                           |                      |
```

**安装 API：**

```
POST /openapi/v1/market/install
{
  "app_id": 12345,
  "scopes": ["im:message:write", "user:info:read"],
  "visibility": {
    "type": "all",           // "all" | "department" | "member"
    "department_ids": [],    // 当 type=department
    "member_ids": []         // 当 type=member
  }
}
```

**安装后自动执行（根据应用类型）：**

| 应用类型 | 安装后动作 |
|---------|-----------|
| Bot | 创建 Bot 用户在租户中、配置 webhook、自动选择群聊 |
| Integration | 仅为应用创建访问凭据 |
| Tool | 注册到应用列表 |
| Calendar Plugin | 注册日历事件回调 |

### 2.4 已安装应用管理

在 Vue SPA 设置/管理页新增「已安装应用」：

```
GET /openapi/v1/market/installed
```

返回当前租户已安装的应用列表，每项包含：

```json
{
  "installation_id": 12345,
  "app": {
    "id": 12345,
    "name": "天气 Bot",
    "icon_url": "...",
    "app_type": 1
  },
  "scopes": ["im:message:write"],
  "status": 1,
  "installed_at": 1712345678000
}
```

操作：
- **启用/停用**：`POST /openapi/v1/market/installed/{id}/enable` / `disable`
- **卸载**：`DELETE /openapi/v1/market/installed/{id}`
  - 卸载后 Bot 退出所有群聊、回收 Webhook 配置、清理 Token
- **管理可见范围**：`PUT /openapi/v1/market/installed/{id}/visibility`

### 2.5 安装事件推送

应用安装/卸载时，向 Bot Webhook 推送事件：

| 事件类型 | 说明 |
|---------|------|
| `app.installed` | 应用被安装到租户 |
| `app.uninstalled` | 应用被从租户卸载 |

```json
{
  "event_id": "evt_xxxxx",
  "app_id": "app_xxxxx",
  "type": "app.installed",
  "timestamp": 1712345678000,
  "payload": {
    "tenant_id": 100,
    "installer_id": 54321,
    "scopes": ["im:message:write"]
  }
}
```

---

## 三、应用审核后台

### 3.1 页面结构（Vue SPA）

```
frontend/src/views/admin/
├── reviews/
│   ├── ReviewList.vue          — 审核列表
│   └── ReviewDetail.vue        — 审核详情
```

入口：管理后台导航中新增「应用审核」菜单。

### 3.2 审核列表

```
GET /openapi/v1/admin/reviews?status=0&page=1&page_size=20
```

| 参数 | 说明 |
|------|------|
| `status` | 0=待审核, 1=已通过, 2=已驳回 |
| `page`, `page_size` | 分页 |

列表展示：应用名称、版本号、开发者、提交时间、当前状态。

### 3.3 审核详情

```
GET /openapi/v1/admin/reviews/{version_id}
```

返回信息：
- 应用基本信息（名称/描述/类型）
- 版本信息（版本号/发布说明）
- 市场信息（分类/图标/截图/描述）
- 权限声明列表
- Bot 配置（如需）

### 3.4 审核操作

**通过：**
```
POST /openapi/v1/admin/reviews/{version_id}/approve
```

**驳回：**
```
POST /openapi/v1/admin/reviews/{version_id}/reject
{
  "reason": "应用描述不完整，请补充详细说明"
}
```

审核操作流程：
1. 更新版本状态
2. 若通过且该版本为首次上架 → 设置 `open_app_market_info` 为已上架
3. 记录审核人 + 审核时间
4. 向开发者推送审核结果通知（站内信）

**下架应用：**
```
POST /openapi/v1/admin/reviews/{app_id}/unpublish
{
  "reason": "违反平台规定"
}
```

### 3.5 管理员权限

审核后台仅 `user_role = admin` 或 `super_admin` 的用户可访问。

---

## 四、应用评分与评价

### 4.1 数据模型

`open_app_reviews` 表：

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `bigint PK` | Snowflake ID |
| `app_id` | `bigint FK → open_apps.id` | 应用 ID |
| `user_id` | `bigint FK → users.id` | 评价用户 |
| `tenant_id` | `bigint` | 租户 ID |
| `rating` | `smallint` | 评分 1-5 |
| `content` | `text` | 评价内容 |
| `reply_content` | `text` | 开发者回复 |
| `reply_at` | `timestamptz` | 回复时间 |
| `created_at` | `timestamptz` | 创建时间 |
| `updated_at` | `timestamptz` | 更新时间 |

`UNIQUE (app_id, user_id, tenant_id)` — 每个用户仅可评价一次。

### 4.2 API

**提交评价：**
```
POST /openapi/v1/market/apps/{app_id}/reviews
{
  "rating": 5,
  "content": "非常好用的 Bot！"
}
```

**查询评价列表：**
```
GET /openapi/v1/market/apps/{app_id}/reviews?page=1&page_size=20
```

**开发者回复评价：**
```
POST /openapi/v1/market/apps/{app_id}/reviews/{review_id}/reply
{
  "content": "感谢您的支持！"
}
```

**评分聚合信息：**
```
GET /openapi/v1/market/apps/{app_id}/ratings
```

```json
{
  "average": 4.5,
  "total": 128,
  "distribution": {
    "5": 80,
    "4": 30,
    "3": 10,
    "2": 5,
    "1": 3
  }
}
```

### 4.3 前端组件

在应用详情页中新增评价区域：
- 评分展示（星数 + 平均分 + 分布条形图）
- 评价列表（用户头像 + 用户名 + 评分 + 内容 + 时间 + 开发者回复）
- 评价表单（星数选择 + 文本框）
- 登录用户才能评价（未登录提示）
- 每个用户仅可评价一次（已评价显示已评分数）

---

## 五、开放平台 Dashboard

### 5.1 数据聚合

Dashboard 数据来源：
- `open_app_stats` 表（M2 建立的 API 调用统计）
- `open_app_installations` 表（安装统计）
- `open_app_reviews` 表（评分统计）
- Bot 消息量（通过消息记录查询）

### 5.2 API

```
GET /openapi/v1/dashboard/overview
```

返回：

```json
{
  "installed_apps": 15,
  "active_apps": 12,
  "api_calls_today": 12345,
  "api_errors_today": 23,
  "bot_messages_today": 567,
  "event_push_success_rate": 0.998
}
```

趋势数据：

```
GET /openapi/v1/dashboard/trends?period=week&metric=api_calls
```

```json
{
  "labels": ["2024-04-01", "2024-04-02", "2024-04-03"],
  "values": [1200, 1350, 1100]
}
```

支持的 metric：
- `api_calls` — API 调用量
- `api_errors` — 错误量
- `bot_messages` — Bot 消息量
- `event_push_success` — 事件推送成功率
- `avg_latency` — 平均延时

### 5.3 前端页面

Dashboard 作为开放平台入口页，展示：
- 统计数字卡片（安装数/活跃数/调用量/Bot 消息量）
- 调用量趋势折线图（可切换日/周/月）
- 事件推送成功率指标
- 各应用 Top 5 调用排行

### 5.4 消息推送成功率跟踪

在 `openapp_stats` 中新增字段（或独立表）跟踪 Webhook 事件推送：

```sql
ALTER TABLE open_app_stats ADD COLUMN event_push_count INT DEFAULT 0;
ALTER TABLE open_app_stats ADD COLUMN event_push_failed INT DEFAULT 0;
```

每次事件推送成功/失败时异步更新。

---

## 六、后端模块扩展

### 6.1 模块文件树扩展

```
backend/openapp/src/
├── lib.rs                            (M1 + M2 + M3 + M4 routes)
├── middleware.rs
├── error.rs
├── handlers/
│   ├── mod.rs
│   ├── auth.rs, app.rs, bot.rs       (M1)
│   ├── open_api.rs, oauth.rs         (M2)
│   ├── card.rs                       (M3)
│   └── market.rs                     (M4 新增)
│       ├── submit_version
│       ├── upload_icon, upload_screenshots
│       ├── install, uninstall
│       ├── list_installed
│       └── enable_app, disable_app
├── handlers/
│   └── admin.rs                      (M4 新增)
│       ├── list_reviews
│       ├── review_detail
│       ├── approve_version
│       ├── reject_version
│       └── unpublish_app
├── handlers/
│   └── dashboard.rs                  (M4 新增)
│       ├── overview
│       └── trends
├── models/
│   ├── mod.rs
│   ├── app.rs, bot.rs                (M1)
│   ├── authorization.rs, user_token.rs, api_stat.rs, outgoing_webhook.rs (M2)
│   ├── scheduled_task.rs             (M3)
│   ├── version.rs                    (M4 新增)
│   ├── market_info.rs                (M4 新增)
│   ├── installation.rs               (M4 新增)
│   └── review.rs                     (M4 新增)
└── services/
    ├── mod.rs
    ├── auth.rs, webhook.rs           (M1)
    ├── oauth.rs                      (M2)
    ├── scheduler.rs                  (M3)
    └── market.rs                     (M4 新增)
        ├── submit_for_review
        ├── process_installation
        ├── process_uninstallation
        └── calculate_rating
```

### 6.2 新增路由

```rust
fn routes(&self, ctx: &AppContext) -> Vec<Routes> {
    vec![
        Routes::new().prefix("/openapi/v1")
            // M1 + M2 + M3 routes...
            
            // M4.1 — 应用版本管理
            .add("/apps/{app_id}/versions", post(handlers::market::submit_version))
            .add("/apps/{app_id}/versions", get(handlers::market::list_versions))
            .add("/apps/{app_id}/market/icon", post(handlers::market::upload_icon))
            .add("/apps/{app_id}/market/screenshots", post(handlers::market::upload_screenshots))
            
            // M4.2 — 应用市场
            .add("/market/apps", get(handlers::market::list_market_apps))
            .add("/market/apps/{app_id}", get(handlers::market::get_market_app_detail))
            .add("/market/install", post(handlers::market::install))
            .add("/market/installed", get(handlers::market::list_installed))
            .add("/market/installed/{id}/enable", post(handlers::market::enable_installation))
            .add("/market/installed/{id}/disable", post(handlers::market::disable_installation))
            .add("/market/installed/{id}", delete(handlers::market::uninstall))
            
            // M4.3 — 审核后台
            .add("/admin/reviews", get(handlers::admin::list_reviews))
            .add("/admin/reviews/{version_id}", get(handlers::admin::review_detail))
            .add("/admin/reviews/{version_id}/approve", post(handlers::admin::approve))
            .add("/admin/reviews/{version_id}/reject", post(handlers::admin::reject))
            .add("/admin/reviews/{app_id}/unpublish", post(handlers::admin::unpublish))
            
            // M4.4 — 评价
            .add("/market/apps/{app_id}/reviews", post(handlers::market::create_review))
            .add("/market/apps/{app_id}/reviews", get(handlers::market::list_reviews))
            .add("/market/apps/{app_id}/reviews/{review_id}/reply", post(handlers::market::reply_review))
            .add("/market/apps/{app_id}/ratings", get(handlers::market::get_ratings))
            
            // M4.5 — Dashboard
            .add("/dashboard/overview", get(handlers::dashboard::overview))
            .add("/dashboard/trends", get(handlers::dashboard::trends)),
    ]
}
```

### 6.3 Cargo.toml 新增依赖

M4 无新增外部依赖，复用已有 crate。

---

## 七、数据库迁移清单

| 序号 | 迁移名称 | 说明 |
|------|---------|------|
| `m20260801_100010_open_app_versions` | 应用版本表 |
| `m20260801_100011_open_app_market_info` | 应用市场信息表 |
| `m20260801_100012_open_app_installations` | 应用安装记录表 |
| `m20260801_100013_open_app_reviews` | 应用评价表 |
| `m20260801_100014_open_app_stats_event` | 事件推送统计字段扩展 |

---

## 八、安全性设计

### 8.1 审核安全
- 开发者不能审核自己的应用
- 已上架应用修改后需重新提交审核（版本升级）
- 审核驳回的应用不可直接上架，需重新提交

### 8.2 安装安全
- 应用安装需要管理员或拥有 `openapp:manage` 权限的用户
- 安装时需明确展示权限列表，用户确认后方可安装
- 安装后 Bot 加入群聊需用户指定目标群聊

### 8.3 评价安全
- 仅租户内已安装应用的成员可评价
- 每个用户仅可评价一次（可修改评价不可删除）
- 评价内容需敏感词过滤

---

## 九、实施顺序建议

```
Phase A: 应用发布（Step 1-3）
  Step 1: DB migration（版本表 + 市场信息表）
  Step 2: 版本提交 + 上传图标/截图 API
  Step 3: Vue SPA 市场发布页

Phase B: 应用安装（Step 4-6）
  Step 4: DB migration（安装记录表）
  Step 5: 安装/卸载 API + 自动 Bot 入群
  Step 6: Vue SPA 市场浏览 + 安装页 + 已安装管理

Phase C: 审核后台（Step 7-8）
  Step 7: 审核 API（列表/详情/通过/驳回）
  Step 8: Vue SPA 审核后台页面

Phase D: 评价 + Dashboard（Step 9-11）
  Step 9: DB migration（评价表）
  Step 10: 评价/回复 API
  Step 11: Dashboard API + Vue SPA 页面
```
