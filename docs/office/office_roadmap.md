# 在线文档产品级需求 & 里程碑规划

## 产品定位

**Buzzing Office** 定位为**企业级协作文档平台**，对标飞书文档 / Notion / 腾讯文档 / Confluence。核心能力矩阵：

| 层 | 内容 |
|----|------|
| **编辑体验** | 富文本 + 结构化组件 + AI 辅助 |
| **内容组织** | 知识库 → 文档（支持子页面层级） |
| **协作矩阵** | Yjs 实时协作 + IM 联动 + 通知 + 评论 |
| **权限安全** | 分级权限 + 分享链接 + 水印 + DLP + 审计 |
| **多端** | Web SPA + Flutter 桌面 + 移动端只读 |
| **智能化** | AI 摘要 / 续写 / 翻译 / RAG 问答 |
| **规模化** | Yjs 集群 + 分块加载 + 监控 |
| **开放** | Webhook + 开放 API + 机器人 |

---

## 当前能力摘要

| 维度 | 现状 |
|------|------|
| 编辑器 | ProseMirror + y-prosemirror，M1 已完成基础 schema（heading/paragraph/list/image/link/mark/table/taskList/codeBlock）、工具栏、斜杠菜单、图片上传、快捷键 |
| 协作 | Yjs WebSocket + BroadcastGroup（单机，容量可配置 `BUZZING_YJS_MAX_CLIENTS`），协作光标 + awareness 在线列表，30s 定时持久化 + saved/syncing 自定义帧，IndexedDB 本地缓存离线可读 |
| API | REST JSON，Spaces + Docs 全套 CRUD + 搜索 + 回收站 + 星标 + 最近 + 面包屑树 + 成员 + 共享链接 |
| 文档列表同步 | ❌ 文档列表仅 REST 拉取，无 WebSocket 推送/轮询，多端不同步（保留至 M6 前后处理） |
| 客户端 | Web SPA 完整（编辑器 + 空间树 + 拖拽 + 搜索 + 回收站 + 星标 + 面包屑 + 成员/分享/只读视图），Flutter 仅列表+空间树，跳转浏览器打开编辑 |
| 权限 | Role enum（viewer/commenter/editor/owner），`document_members` + `document_shares`（token / 密码 / 过期 / 次数）已上线；只读态由客户端 `ProseEditor` + `TitleBar` 强制；WebSocket 建连做角色校验 |
| 测试 | 无（待 M12 系统性补齐） |
| IM 集成 | 无 |
| AI | 无 |
| 知识库 | 已完成 `wikis` 表 + 后端 CRUD，含首页文档自动创建与生命周期绑定；文档通过 `documents.wiki_id` 直接归属知识库，通过 `parent_id` 形成树形层级（去掉了中间 Space 层） |

---

## 三阶段总览

```
┌────────────────────────────────────────────────────────────┐
│  Phase A — MVP（基础可用）           M1 - M4               │
│  单文档编辑体验 + 文档管理 + 协作增强 + 权限分享           │
├────────────────────────────────────────────────────────────┤
│  Phase B — Team（团队协作）          M5 - M9               │
│  版本历史 + 多端 + 知识库 + IM 联动 + 富组件               │
├────────────────────────────────────────────────────────────┤
│  Phase C — Enterprise（企业级）      M10 - M14             │
│  企业安全 + AI + 规模化 + 开放平台 + 运营                  │
└────────────────────────────────────────────────────────────┘
```

| # | 名称 | 阶段 | 工作量 | 依赖 | 状态 |
|---|------|------|--------|------|------|
| M1 | 编辑器完善 | A | 2-3 周 | — | ✅ 已完成 |
| M2 | 协作增强 | A | 1-2 周 | M1 | ✅ 已完成 |
| M3 | 文档管理 | A | 2-3 周 | M1 | ✅ 已完成 |
| M4 | 权限与分享 | A | 2 周 | M3 | ✅ 已完成（空间继承延后至 M7） |
| M5 | 版本历史 | B | 1-2 周 | M2 | 🔲 待开始 |
| M6 | 多端支持 | B | 3-4 周 | M4 | 🔲 待开始 |
| M7 | 知识库层 | B | 2-3 周 | M3, M4 | ✅ 已完成 |
| M8 | IM 集成 | B | 1-2 周 | M4, M7 | 🔲 待开始 |
| M9 | 富组件与体验 | B | 2-3 周 | M1 | 🔲 待开始 |
| M10 | 企业安全合规 | C | 2-3 周 | M4 | 🔲 待开始 |
| M11 | AI 智能化 | C | 3-4 周 | M9 | 🔲 待开始 |
| M12 | 规模化与稳定性 | C | 2-3 周 | 贯穿 | 🔲 待开始 |
| M13 | 开放平台 | C | 2-3 周 | M4, M10 | 🔲 待开始 |
| M14 | 运营与后台 | C | 2 周 | M10 | 🔲 待开始 |

---

# Phase A — MVP（基础可用）

## M1 — 编辑器完善 ✅

### 目标
达到主流富文本编辑器基础水准。

### 需求
- [x] 完整工具栏（粗/斜/下/删/行内代码/标题/引用/列表/任务/代码块/表格/链接/图片/清除格式）
- [x] Toolbar active 状态跟随选区同步
- [x] 任务列表 (taskList/taskItem) — checkbox 可点击切换
- [x] 代码块 (codeBlock) — 基础样式
- [x] 表格 (table) — 创建 + Tab 跳转
- [x] 下划线 / 删除线 mark
- [x] 文档标题可编辑（TitleBar）
- [x] 图片上传（点击 + 粘贴 + 拖拽）
- [x] 链接 dialog（插入/编辑/移除）
- [x] 快捷键（Ctrl+B/I/U，Ctrl+Shift+S/C，Ctrl+K，Tab）
- [x] 斜杠命令菜单 (/menu)
- [x] editor.css 样式统一

### 遗留（迁至 M9）
- 代码块语法高亮 + 语言下拉
- 表格右键菜单（增删行列）

### 交付产物
- `frontend/src/views/office/components/` 全部组件
- `frontend/src/views/office/composables/useEditorSchema.ts`

---

## M2 — 协作增强 ✅

### 目标
提升多人实时协作的体验和可靠性。

### 需求

#### 2.1 在线状态
- [x] 在线协作者列表（头像 + 名字 + 活跃状态）
- [x] 区分本地用户和远程用户
- [x] 光标带用户名标签，选区高亮

#### 2.2 同步反馈
- [x] 保存状态指示器（"已保存" / "保存中" / "未保存" / "离线"）
- [x] Yjs 连接状态提示（已连接 / 重连中 / 断开）
- [ ] 冲突提示（并发修改感知）— **Yjs CRDT 天然无冲突，此项转为观测指标，延后至 M12**

#### 2.3 断线重连
- [x] WebSocket 指数退避重连（`y-websocket` 内建）
- [x] 本地缓存未同步的编辑（IndexedDB `y-indexeddb`）
- [x] 网络恢复自动补同步

#### 2.4 协作边界
- [x] BroadcastGroup 扩容（可配置 `BUZZING_YJS_MAX_CLIENTS`，默认 128）
- [ ] 连接数超限友好提示 — 服务端仅返回错误，UI 未特化，延后

### 交付产物
- `Collaborators.vue` 重构、`SyncStatus.vue`
- 后端 `ws.rs` 可配置 max_clients + saved/syncing 自定义帧 (100/101)
- IndexedDB 本地缓存层（`useYjs.ts` + `y-indexeddb`）
- `.ProseMirror-yjs-cursor` CSS + `pickUserColor` 8 色板

---

## M3 — 文档管理 ✅

### 目标
完整的文档生命周期管理。

### 需求

#### 3.1 全文搜索
- [x] 后端：PostgreSQL 全文检索（`plain_text` + `search_tsv` GIN 索引 + `plainto_tsquery`）
- [x] 后端：`POST /api/office/docs/search`
- [x] 前端：全局搜索栏（Cmd+K 唤起） + 空间内搜索
- [x] 搜索结果高亮匹配文本（`ts_headline`）
- [ ] （P2）搜索附件内容 / 图片 OCR

#### 3.2 回收站
- [x] 软删除：`documents.trashed_at`
- [x] 回收站页面：列出已删除，显示剩余恢复时间（30d）
- [x] 恢复 / 永久删除 + 1h 定时清理任务

#### 3.3 移动 / 复制
- [x] "移动到…" / "复制到…" 右键菜单
- [x] 复制文档需深拷贝 Yjs state
- [ ] 批量选择 + 批量操作 — 延后

#### 3.4 收藏与最近
- [x] 星标 / 收藏（`document_stars` 表）
- [x] 收藏夹分组（`group_name`）
- [x] 最近访问（`document_visits` 表 / `visited_at`）
- [x] 主页入口："最近文档" / "星标"

#### 3.5 子页面（Notion 式层级）
- [x] 文档可作为父级，包含子页面
- [x] 数据库：`documents.parent_id` 字段
- [x] 侧栏树形展开子页面 + 拖拽调整层级
- [x] 面包屑导航

#### 3.6 空间管理
- [x] 空间重命名 / 图标（emoji picker）/ 颜色
- [x] 空间排序（`sort_order`，拖拽 UI 已就绪）
- [x] 空间归档 / 归档列表
- [x] 默认空间锁定（`sp_type=0` 禁止删除/归档，用户注册时创建）

#### 3.7 文档列表实时同步（post-MVP）
> 当前文档列表仅 REST 拉取，多端操作不会实时反映。后续可实现服务端 WebSocket 推送文档变更事件（增/删/改/移动），或先以定时轮询（30s）过渡。
- [ ] 方案调研：WebSocket 推送 vs 短轮询 vs SSE
- [ ] 服务端文档变更事件定义及推送
- [ ] 客户端事件接收及列表增量更新

### 交付产物
- 迁移 `m20260720_100001_office_m3.rs`（documents 加 parent_id/trashed_at/icon/cover/plain_text/search_tsv；spaces 加 icon/color/sort_order/archived_at；新增 document_stars/document_visits）
- 后端 controllers：`search` / `trash` / `stars` / `docs::move_doc` / `duplicate` / `visit` / `recent` / `tree`
- 后端 `AppOffice::serve` 1h trash cleanup 任务
- 前端 services + `useDocumentStore` 重构
- 前端组件：`SearchBar` / `TrashView` / `SpaceTree` + `DocTreeNode`（递归/拖拽/右键）/ `Breadcrumb` / `IconPicker` / `ContextMenu` / `StarredView` / `RecentView`
- `HomeView` 与 `EditorView` 集成面包屑 + visit 上报

---

## M4 — 权限与分享 ✅

### 目标
文档级权限控制 + 外部分享。

### 需求

#### 4.1 成员管理 API
- [x] `document_members` CRUD：
  - `GET /api/office/docs/{id}/members`
  - `POST /api/office/docs/{id}/members`（upsert）
  - `DELETE /api/office/docs/{id}/members/{user_id}`
  - `PATCH /api/office/docs/{id}/members/{user_id}` (改角色)
- [x] 角色：viewer(0) / commenter(1) / editor(2) / owner(3)
- [x] 权限中间件 `office::permission::{Role, resolve_role, require_role}`；`docs::get/update/delete/move_doc/duplicate` + `trash::restore/purge` 全部接入
- [x] WebSocket 建连做角色校验（普通 JWT + `share:{share_id}:{doc_id}` 临时 JWT 两类）
- [x] 额外 `GET /api/office/docs/{id}/permission` 端点供前端读取角色

#### 4.2 共享链接
- [x] `POST /api/office/docs/{id}/share`：生成 token（32 字符 base62）
- [x] 支持过期时间、访问密码（`bcrypt::DEFAULT_COST`）、访问次数限制
- [x] `GET /api/share/{token}` / `POST /api/share/{token}/verify`：Token 校验 + 签发临时 JWT（`pid=share:{share_id}:{doc_id}`）
- [x] 分享 dialog（复制链接、权限、过期、密码、次数、撤销）
- [x] 只读链接视图 `/share/:token`（`ShareView` + `ShareReader`，禁用 IndexedDB 避免污染本地缓存）

#### 4.3 权限继承
- [x] `documents.inherit_from_space bool` 默认 true 字段已随 M4 迁移落地
- [ ] 空间级成员表（`space_members`）— **暂缓：随 M7 知识库层一起补齐**
- [ ] `require_role` 回退到空间成员时读取空间角色 — 依赖上一条
- [ ] 知识库（M7）→ 空间 → 文档 三级继承 — 依赖 M7

#### 4.4 UI 集成
- [ ] 文档列表显示权限角色徽章 — 待补
- [x] 只读模式禁用编辑：`useEditorSchema.editable` + `ProseEditor` + `TitleBar` 全部支持；只读态顶栏显示"只读"标记
- [x] 编辑器顶栏"成员""共享"入口按钮，仅 editor+ 可见
- [ ] 用户搜索器（复用 contact 组件）— 当前使用 user_id 输入，待接入组织通讯录后升级

### 交付产物
- 迁移 `m20260720_100002_office_m4.rs`（documents.inherit_from_space + document_shares 表 + `ux_document_shares_token` 唯一索引）
- 后端：`office::permission` + `controllers::members` + `controllers::shares` + `docs::permission`
- 后端：`ws.rs` 兼容普通 / 分享临时 JWT
- 前端：`services/office/members.ts` + `shares.ts`（公开分享走独立 axios 实例，避免 401 误登出）
- 前端：`composables/usePermission.ts`、`components/MemberDialog.vue` + `ShareDialog.vue` + `ShareReader.vue`、`views/office/ShareView.vue`
- 前端：`useYjs(docId, { token, enableIndexedDb })` 支持共享 token；`useEditorSchema` + `ProseEditor` 支持 editable
- 路由：`/share/:token` 公开路由（不走 tenantGuard）

---

# Phase B — Team（团队协作）

## M5 — 版本历史

### 目标
文档版本管理与追溯。

### 需求

#### 5.1 版本快照
- [ ] 增量快照策略：保留最近 N 版本 + 每小时一版本
- [ ] 数据库：`document_versions` 表
- [ ] `GET /api/office/docs/{id}/versions`
- [ ] 手动创建命名版本（如 "发布 v1.0"）

#### 5.2 版本对比
- [ ] 时间轴 UI
- [ ] 选中两版本 diff（文本级差异高亮）
- [ ] 利用 Yjs `encode_state_as_update` 做 diff

#### 5.3 版本回滚
- [ ] 恢复至历史版本（创建新版本追加，不覆盖）
- [ ] 回滚确认 + 通知在线协作者

### 交付产物
- `document_versions` 表 + CRUD
- 前端版本时间轴 + Diff 视图

---

## M6 — 多端支持

### 目标
Flutter 桌面 / 移动端可用。

### 需求

#### 6.1 Flutter 桌面编辑
- [ ] **方案 A（推荐）**：`webview_flutter` 嵌入 SPA 编辑器
- [ ] JS Bridge 传递 auth token + docId
- [ ] Flutter 原生工具栏覆盖层（可选）

#### 6.2 移动端只读浏览（前置）
- [ ] Flutter 移动端文档列表 + 只读渲染（不含编辑）
- [ ] 加载后端预渲染 HTML 或 ProseMirror JSON

#### 6.3 离线编辑
- [ ] Service Worker + IndexedDB 缓存
- [ ] 本地 Yjs 状态离线保存
- [ ] 网络恢复自动同步

### 交付产物
- `buzzing/lib/page/office/editor_view.dart`
- `buzzing/lib/page/office/reader_view.dart`（移动端）

---

## M7 — 知识库层

### 目标
从「空间 → 文档」扁平结构升级为**知识库层级**，简化中间层，文档直接归属于知识库并通过 `parent_id` 形成树形结构。

### 需求

#### 7.1 知识库模型
```
Organization (租户)
 └── Wiki (知识库) ← 新增
      └── Document (文档，可含子页面，通过 parent_id 形成树)
```
- [ ] 数据库：`wikis` 表（id, tenant_id, name, description, cover, icon, creator_id）
- [ ] 数据库：`wiki_members` 表（角色继承到知识库内文档）
- [ ] `documents` 表增加 `wiki_id` 字段，文档直接归属知识库（无需经过空间层）
- [ ] 利用现有 `parent_id` 实现文档树形层级
- [ ] `document_spaces` 保留表结构（兼容历史数据），但不再作为 UI 概念

#### 7.2 知识库首页
- [ ] 概览页（描述 + 最近更新 + 置顶文档 + 成员）
- [ ] 侧栏树形导航（wiki → doc(含子文档)）
- [ ] 成员列表 + 加入申请

#### 7.3 CRUD API
- [ ] `GET/POST/PATCH/DELETE /api/office/wikis`
- [ ] `POST /api/office/wikis/{id}/members`
- [ ] `GET /api/office/wikis/{id}/pins`（置顶文档）
- [ ] `GET /api/office/wikis/{id}/recent`
- [ ] `GET /api/office/wikis/{id}/docs?parent_id=xxx` — 知识库中文档树（按 parent_id 组织）

#### 7.4 迁移
- [ ] `documents` 表新增 `wiki_id` 字段，历史文档保留 `space_id`（向后兼容），新文档通过 wiki_id 归属
- [ ] 后台脚本：为每个租户创建默认知识库，将现有 space 下的文档归入
- [ ] Web 侧栏改造：知识库 → 文档树（去掉空间层）
- [ ] Flutter 侧栏同步改造

### 交付产物
- `wikis` + `wiki_members` 表
- `documents.wiki_id` 字段
- 后端知识库 API + 文档树接口
- 前端知识库首页 + 侧栏改造（去空间层）

---

## M8 — IM 集成

### 目标
文档与 IM 打通，形成协作矩阵。

### 需求

#### 8.1 消息卡片
- [ ] IM 中的文档链接自动预览（标题 + 摘要 + 图标 + 更新时间）
- [ ] 卡片点击直接打开文档
- [ ] SDK/后端：文档 URL → 元数据接口

#### 8.2 分享到会话
- [ ] 文档右上角"分享到会话"按钮
- [ ] 选择会话 → 发送卡片 + 自动加权限（可配置）

#### 8.3 通知联动
- [ ] @提及用户 → IM 通知 + 站内消息
- [ ] 评论/回复 → 通知作者
- [ ] 文档分享 → 通知被分享者

#### 8.4 taskItem ↔ Todo
- [ ] 文档中的任务列表项可"抽取"为个人 todo
- [ ] 状态双向同步（勾选 = 完成）
- [ ] 依赖 `backend/todo/` 模块

#### 8.5 @提及
- [ ] 输入 `@` 弹出用户/文档选择器
- [ ] 支持 @user / @doc / @date
- [ ] 提及信息作为 mark 存储在 ProseMirror

### 交付产物
- 后端：文档元数据接口 + 通知触发
- SDK：消息卡片渲染 / 事件订阅
- 前端：@mention 组件 + 分享菜单
- 表：`document_mentions`

---

## M9 — 富组件与体验

### 目标
从基础富文本升级为结构化文档，达到 Notion 水准。

### 需求

#### 9.1 结构化组件
- [ ] 折叠段 (toggle)
- [ ] 提示框 (callout，含 info/warn/error/success 4 种)
- [ ] 分栏 (columns，2/3 栏)
- [ ] 面板 (panel)

#### 9.2 富媒体
- [ ] 视频嵌入（内部上传 + 外链 YouTube/Bilibili）
- [ ] 音频嵌入
- [ ] 附件（非图片文件，含预览）
- [ ] 外链预览卡片（unfurl，抓取 og:image / title）

#### 9.3 公式与图表
- [ ] KaTeX 数学公式（行内 + 块级）
- [ ] Mermaid 流程图 / 时序图
- [ ] （P3）绘图板 (excalidraw)

#### 9.4 代码块增强
- [ ] 语言选择下拉（M1 遗留）
- [ ] 语法高亮（highlight.js 或 shiki）
- [ ] 一键复制按钮
- [ ] 行号显示

#### 9.5 目录与导航
- [ ] 自动生成 TOC（右侧大纲）
- [ ] 面包屑（依赖 M3 子页面）
- [ ] 章节锚点 + 链接跳转

#### 9.6 表格增强
- [ ] 右键菜单：增删行列
- [ ] 单元格背景色 / 对齐方式
- [ ] 排序 / 筛选（简化版）

#### 9.7 表情反应
- [ ] 文档级点赞 / 表情反应
- [ ] 数据库：`document_reactions`

### 交付产物
- 新 ProseMirror node schema
- `highlight.js` / `mermaid` / `katex` 依赖
- 右侧 TOC 组件

---

# Phase C — Enterprise（企业级）

## M10 — 企业安全合规

### 目标
满足企业级安全审计与数据保护要求。

### 需求

#### 10.1 密级与标签
- [ ] 文档密级：公开 / 内部 / 机密 / 绝密
- [ ] 密级影响导出 / 复制 / 打印
- [ ] 数据库：`documents.security_level`

#### 10.2 水印
- [ ] 用户名 + 时间叠加水印
- [ ] 可配置：文字 / 图片 / 密度 / 透明度
- [ ] 打印水印

#### 10.3 访问日志
- [ ] 记录：谁在什么时间访问了哪个文档、停留时长
- [ ] 数据库：`document_visits_log`
- [ ] 管理端查询

#### 10.4 操作限制
- [ ] 禁止复制 / 禁止导出 / 禁止打印（按密级或按用户）
- [ ] 内容防截图（前端伪防护）

#### 10.5 DLP 敏感词
- [ ] 编辑时敏感词检测（关键词库 / 正则）
- [ ] 命中后提示 / 阻止保存 / 上报

#### 10.6 审计日志
- [ ] 记录：创建 / 编辑 / 分享 / 删除 / 权限变更 / 导出
- [ ] 数据库：`audit_logs`
- [ ] 管理端审计查询 + 导出 CSV

#### 10.7 数据保留
- [ ] 自动归档策略（N 天未访问自动归档）
- [ ] 归档文档只读
- [ ] 保留期满自动删除

### 交付产物
- 表：`document_visits_log` / `audit_logs`
- 水印中间件
- DLP 敏感词服务
- 管理端审计页面

---

## M11 — AI 智能化

### 目标
接入 AI 能力，成为智能化协作平台差异化亮点。

### 需求

#### 11.1 AI 助手侧栏
- [ ] 编辑器右侧 AI 面板（Cmd+J 唤起）
- [ ] 消息式交互（历史 + 新问）

#### 11.2 内容生成
- [ ] AI 摘要（选中文本 → 摘要）
- [ ] AI 续写
- [ ] AI 润色（正式 / 口语 / 简洁 / 详细）
- [ ] AI 翻译（多语言）
- [ ] AI 大纲生成
- [ ] AI 表格生成（"生成一个 XX 表格"）

#### 11.3 RAG 问答
- [ ] 知识库向量化（依赖 M7）
- [ ] 基于知识库的智能问答
- [ ] 引用来源（跳转原文）

#### 11.4 会议纪要
- [ ] 音频转文字（依赖 VC 模块）
- [ ] 结构化输出：议题 / 决策 / 行动项
- [ ] 自动关联 todo（依赖 M8）

#### 11.5 智能配图
- [ ] 根据段落内容 AI 生图（可选）

### 交付产物
- 后端：AI 网关（对接 OpenAI/Claude/国产模型）
- 向量库集成（pgvector / Qdrant）
- 前端：AI 侧栏组件

---

## M12 — 规模化与稳定性

### 目标
支撑万级并发编辑、千万级文档规模。

### 需求

#### 12.1 Yjs 集群化
- [ ] 当前 BroadcastGroup 单机 → Redis pub/sub 或 y-redis
- [ ] 房间跨节点广播
- [ ] 房间迁移与故障转移

#### 12.2 增量快照
- [ ] 定时快照 + 压缩历史 update
- [ ] Snapshot + Log 分离存储
- [ ] 快照压缩定时任务

#### 12.3 大文档性能
- [ ] 基准测试：10 万字加载 / 编辑 / 保存
- [ ] Yjs state 分块传输（>1MB 分片）
- [ ] 虚拟滚动（超长文档只渲染可视区）
- [ ] 内存泄漏检测

#### 12.4 自动化测试
- [ ] 后端 (`backend_test/`)：Spaces / Docs / Members / Share / Search CRUD
- [ ] 前端 e2e：编辑器渲染、工具栏、协作、AI
- [ ] SDK (`buzzing/sdk_test/`)：BizOffice
- [ ] 每项测试有 spec 文件

#### 12.5 监控告警
- [ ] Yjs 房间内存 / CPU 指标（Prometheus）
- [ ] WebSocket 连接数 / 保存队列积压
- [ ] 慢查询日志
- [ ] 告警规则（保存失败率 / P99 延迟）

### 交付产物
- Yjs 集群改造
- 测试用例 + spec
- 监控 dashboard + 告警规则

---

## M13 — 开放平台

### 目标
第三方开发者可集成 Buzzing Office，形成生态。

### 需求

#### 13.1 开放 API
- [ ] 完整 REST API 文档（OpenAPI 3.0）
- [ ] API Token 管理（应用维度）
- [ ] 限流 / 配额

#### 13.2 Webhook
- [ ] 事件：文档创建 / 编辑 / 评论 / 分享 / 删除
- [ ] Webhook 签名 (HMAC)
- [ ] 重试策略 + 死信队列
- [ ] 管理端配置

#### 13.3 OAuth 应用
- [ ] 第三方应用注册
- [ ] 授权流程（OAuth 2.0）
- [ ] Scope 管理

#### 13.4 机器人
- [ ] 机器人身份（bot user）
- [ ] 通过 API 发送评论 / 编辑 / 分享
- [ ] 事件订阅（配合 Webhook）

#### 13.5 SDK
- [ ] JS SDK
- [ ] Python SDK（P3）

### 交付产物
- `apps` / `webhooks` / `oauth_tokens` 表
- 开放 API 文档站
- 3 个示例应用

---

## M14 — 运营与后台

### 目标
提供管理员 / 运营视角的能力。

### 需求

#### 14.1 文档模板
- [ ] 模板库：会议记录 / 周报 / OKR / 项目计划 / 产品需求
- [ ] 组织自定义模板
- [ ] 新建文档时选择模板
- [ ] `templates` 表

#### 14.2 评论与批注
- [ ] 选中文本 → 添加评论
- [ ] 评论列表侧边栏
- [ ] 回复 / 解决 / 重开
- [ ] 批注模式（对比编辑模式）
- [ ] 依赖 M8 @mention 通知

#### 14.3 导入 / 导出
- [ ] 导出：Markdown / PDF / DOCX（pandoc / WASM）
- [ ] 导入：Markdown / DOCX → Yjs
- [ ] 保留结构化信息（标题 / 列表 / 表格 / 图片）

#### 14.4 管理后台
- [ ] 组织文档总览（存储用量 / 活跃度 / 分享数）
- [ ] 用户维度统计（编辑量 / 分享量）
- [ ] 文档维度统计（访问量 / 编辑者数）
- [ ] 存储配额管理

#### 14.5 订阅
- [ ] 订阅文档 / 空间 / 知识库变更
- [ ] 邮件 / IM 通知
- [ ] `subscriptions` 表

### 交付产物
- `templates` / `comments` / `subscriptions` 表
- 评论组件 + 通知集成
- 导入导出服务
- 管理后台页面

---

## 优先级矩阵

| 功能 | 用户价值 | 实现成本 | 优先级 | Milestone |
|------|---------|---------|--------|-----------|
| 编辑器工具栏 | ★★★★★ | 低 | P0 | M1 ✅ |
| 图片上传 | ★★★★★ | 中 | P0 | M1 ✅ |
| 表格 / 代码块 | ★★★★ | 中 | P0 | M1 ✅ / M9 |
| 协作光标 / 状态 | ★★★★ | 中 | P0 | M2 |
| 搜索 | ★★★★ | 中 | P1 | M3 |
| 回收站 | ★★★★ | 低 | P1 | M3 |
| 子页面 / 面包屑 | ★★★★ | 中 | P1 | M3 |
| 权限 / 分享 | ★★★★★ | 中 | P1 | M4 |
| 版本历史 | ★★★ | 高 | P2 | M5 |
| Flutter 编辑 | ★★★★ | 中-高 | P2 | M6 |
| 知识库层级 | ★★★★★ | 中 | P1 | M7 |
| IM 消息卡片 | ★★★★ | 低 | P1 | M8 |
| @提及 | ★★★★ | 中 | P1 | M8 |
| Todo 联动 | ★★★ | 中 | P2 | M8 |
| 富组件（toggle/callout） | ★★★★ | 中 | P2 | M9 |
| 公式 / 图表 | ★★★ | 中 | P2 | M9 |
| TOC 大纲 | ★★★★ | 低 | P1 | M9 |
| 水印 / 密级 | ★★★★ | 中 | P1 | M10 |
| 审计日志 | ★★★ | 低 | P2 | M10 |
| DLP | ★★ | 中 | P3 | M10 |
| AI 摘要 / 续写 | ★★★★★ | 高 | P1 | M11 |
| AI 翻译 / 润色 | ★★★★ | 中 | P2 | M11 |
| RAG 问答 | ★★★★ | 高 | P2 | M11 |
| Yjs 集群 | ★★★ | 高 | P2 | M12 |
| 自动化测试 | ★★★ | 中 | P1 | M12 |
| Webhook / 开放 API | ★★★ | 中 | P3 | M13 |
| 文档模板 | ★★★ | 中 | P2 | M14 |
| 评论批注 | ★★★★ | 高 | P2 | M14 |
| 导出导入 | ★★★ | 中 | P2 | M14 |

---

## 依赖关系图

```
                                    ┌─── M11 (AI)
                                    │
       M1 ──> M2 ──> M5              ├─── M12 (规模化)
        │              │             │
        └──> M3 ──> M7 ┼─> M8 ──────> M13 (开放平台)
        │      │       │              │
        │      └─────> M4 ──> M6      ├─── M14 (运营)
        │              │              │
        └──> M9 ────────┴──> M10 ─────┘
```

**关键依赖**：
- **M1 是基础**，所有后续依赖编辑器能力的增强
- **M4（权限）是很多能力的前置**：M6 多端、M8 IM 集成、M10 企业安全、M13 开放平台
- **M7（知识库）是 M8 IM 集成、M11 AI RAG、M14 订阅 的前置**
- **M12（规模化）贯穿全程**，建议每完成 P0/P1 里程碑就做一轮性能与测试补齐
- **M9（富组件）** 与 M11（AI）解耦，可并行开发

---

## 开发节奏建议

| 阶段 | 时间 | 目标 |
|------|------|------|
| Q1（已完成） | ~ | ✅ Phase A（M1-M4）全部落地，缺 M4 空间继承（随 M7 一起） |
| Q2（当前） | 6-8 周 | 推进 M5-M9：版本 + 多端 + 知识库 + IM 集成 + 富组件 |
| Q3 | 6-8 周 | 完成 M10-M12：企业安全 + AI + 规模化 |
| Q4 | 4-6 周 | 完成 M13-M14：开放平台 + 运营 + 打磨 |

---

## 更新记录

- 2026-07-20：重构 roadmap，加入 M7 知识库层、M8 IM 集成、M9 富组件、M10 企业安全、M11 AI、M12 规模化、M13 开放平台、M14 运营
- 2026-07-21：Phase A 收尾 —
  - M2 协作增强：完成 awareness 光标 / SyncStatus / IndexedDB 离线缓存 / BroadcastGroup 可配置容量（冲突提示等观测项延后至 M12）
  - M3 文档管理：全文搜索 / 回收站 / 移动复制 / 星标 / 最近 / 子页面 / 空间元数据 全部落地；默认空间锁定
  - M4 权限与分享：Role 模型 / 成员 CRUD / 共享链接（token+密码+过期+次数）/ 公开只读视图 全部落地；空间继承相关随 M7 一起补
