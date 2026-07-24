# Open Platform — 待办项清单

从 `todo.md` 中提取的所有待完成项。

---

## M1: 开放平台基础

### Step 0: Proto & DB 基础

- [ ] **0.7** 生成 sea-orm entity — `sea-orm-cli generate entity -o backend/base/src/models/_entities`（需要 DB 连接）

### Step 8: 集成测试

- [ ] **8.1** 后端测试 — App CRUD 全流程
- [ ] **8.2** 后端测试 — 鉴权测试
- [ ] **8.3** 后端测试 — Bot 发送消息
- [ ] **8.4** 后端测试 — 事件订阅
- [ ] **8.5** `backend_test` spec 文件 — 新增 `openapp` 测试描述

---

## M2: 开发者工具与 API 开放

### Step 11: 开放 API 网关 Handlers

- [ ] **11.5** 在 `middleware.rs` 中插入 API 调用统计中间件（model + handler ready，middleware 待接入）

### Step 14: OAuth 2.0 授权

- [ ] **14.7** 创建前端 OAuth 授权确认页（Vue SPA）
- [ ] **14.8** 在 Flutter 设置页中增加「已授权应用」列表 + 撤销功能

### Step 15: 出站 Webhook

- [ ] **15.4** 在 IM 模块消息发送流程中插入出站 Webhook 触发钩子
- [ ] **15.5** Outgoing Webhook 的前端配置 UI（在 AppBotConfig.vue 中新增 Tab）

### Step 16: API 调用统计

- [ ] **16.1** 在 `middleware.rs` 中实现 API 调用统计中间件（每请求异步更新 stat）

### Step 17: M2 集成测试

- [ ] **17.1** ~ **17.7** M2 集成测试（待后续补充）

---

## M3: Bot 高级能力

### Step 19: 卡片 Flutter 渲染

- [ ] **19.1** 创建 `buzzing/lib/widgets/message_card.dart` — 卡片渲染入口（判断 msg_type=17 时渲染）
- [ ] **19.2** 创建 `card_header.dart` — 标题栏组件（颜色竖条 + 标题文字）
- [ ] **19.3** 创建 `card_element.dart` — 元素分发器（按 tag 分发到各组件）
- [ ] **19.4** 创建 `card_text_element.dart` — 文本元素（支持 Markdown 渲染）
- [ ] **19.5** 创建 `card_button_element.dart` — 按钮元素（绑定点击事件，发送 CMD_CARD_ACTION）
- [ ] **19.6** 创建 `card_image_element.dart` — 图片元素（从 store 加载图片）
- [ ] **19.7** 创建 `card_divider_element.dart` — 分割线组件
- [ ] **19.8** 实现 `CMD_CARD_UPDATE` 处理 — 客户端收到后原地刷新卡片（不闪烁或重排）

### Step 20: SDK CardBuilder

- [ ] **20.1** 创建 `sdk/src/biz/card.rs` — `CardBuilder` 工具
- [ ] **20.2** 在 `sdk/src/lib.rs` 中导出 card 模块

### Step 21: Bot 互动回复

- [ ] **21.3** 事件推送 `im.message.receive` payload 中增加 `reactions` 字段
- [ ] **21.4** 新增事件类型 `im.message.reaction_added` / `im.message.reaction_removed`
- [ ] **21.6** IM 模块插入 Reaction 事件触发钩子

### Step 22: 定时/周期任务

- [ ] **22.7** Vue SPA 定时任务管理 UI

### Step 23: Bot 管理能力

- [ ] **23.2** `backend/im/src/lib.rs` — 实现 `BizIm` 管理类接口（部分）
- [ ] **23.5** Bot 管理频率限制（日创建群聊上限 50）

### Step 24: M3 集成测试

- [ ] **24.1** 后端测试 — 卡片消息发送 + 更新 + 按钮回调
- [ ] **24.2** 后端测试 — Reaction 事件触发与推送
- [ ] **24.3** 后端测试 — 定时任务创建/执行/暂停/恢复
- [ ] **24.4** 后端测试 — Bot 创建群聊/管理成员/设置公告
- [ ] **24.5** `backend_test` spec 文件 — 新增 M3 测试描述

---

## M4: 应用市场与生态

### Step 25: 应用版本与市场信息

- [ ] **25.6** Vue SPA 应用市场发布页

### Step 26: 应用安装与授权

- [ ] **26.4** Vue SPA 市场页面
- [ ] **26.5** Vue SPA 已安装应用管理页
- [ ] **26.6** 安装/卸载事件推送

### Step 27: 应用审核后台

- [ ] **27.2** Vue SPA 审核后台页面
- [ ] **27.3** 管理员权限守卫

### Step 28: 应用评分与评价

- [ ] **28.4** Vue SPA 评价组件

### Step 29: 开放平台 Dashboard

- [ ] **29.3** Vue SPA Dashboard 页面

### Step 30: M4 集成测试

- [ ] **30.1** 后端测试 — 版本提交 + 审核流程（提交 → 通过 → 上架 → 下架）
- [ ] **30.2** 后端测试 — 应用安装/卸载全流程（含 Bot 自动入群/退群）
- [ ] **30.3** 后端测试 — 评价/回复/评分聚合
- [ ] **30.4** 后端测试 — Dashboard 数据聚合
- [ ] **30.5** `backend_test` spec 文件 — 新增 M4 测试描述

---

## 汇总

| 里程碑 | 待办 Step | 待办项数 |
|--------|-----------|---------|
| M1 | 0, 8 | 6 |
| M2 | 11, 14, 15, 16, 17 | 7 |
| M3 | 19, 20, 21, 22, 23, 24 | 18 |
| M4 | 25, 26, 27, 28, 29, 30 | 12 |
| **合计** | | **43** |
