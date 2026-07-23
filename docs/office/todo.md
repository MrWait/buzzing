# 文档模块实施进度

> 对应 `docs/office/office_roadmap.md` 中的里程碑。每项任务完成后将 `[ ]` 改为 `[x]`。
>
> **当前阶段：Phase B — Team（团队协作）**

---

## Phase B — Team

> 详细设计文档: `docs/office/office_pb_design.md`
>
> Phase A 未完成项已移至 `docs/office/pending.md`

---

## M5 — 版本历史

### 设计参考
- 设计文档: `docs/office/office_pb_design.md` §5
- 依赖: M1-M4（Yjs 持久化已有）

### 5.1 数据库迁移

- [x] 新建 `document_versions` 表（id, document_id, version_number, title, description, yjs_snapshot, plain_text, creator_id, is_minor, created_at）
- [x] 添加索引 `(document_id, version_number DESC)`
- [x] 迁移文件 `m20260728_100001_office_m5.rs`

### 5.2 后端 — 版本 CRUD

- [x] `controllers/versions.rs`：
  - `GET /api/office/docs/{id}/versions` — 版本列表（分页 DESC）
  - `POST /api/office/docs/{id}/versions` — 创建手动命名版本
  - `GET /api/office/docs/{id}/versions/{version_id}` — 获取单个版本快照
  - `POST /api/office/docs/{id}/versions/diff` — 对比两个版本 `{ v1_id, v2_id }`
  - `POST /api/office/docs/{id}/versions/{version_id}/restore` — 回滚（追加新版本）
- [x] `models/document_versions.rs` SeaORM 实体
- [x] 权限校验：所有版本操作需 Editor+ 角色

### 5.3 后端 — 快照策略

- [ ] `periodic_save_loop` 中集成版本快照逻辑 — **暂缓，等待 M5 主流程稳定后实现**
- [ ] 快照降级策略：最近 1h → 5min，1-24h → 1h，24h+ → 1d
- [ ] 自动快照上限 100 条，超出后合并最早的历史
- [ ] 手动命名版本（`is_minor=false`）不计入自动上限

### 5.4 后端 — Diff 实现（5.1/5.2 中已内置，基于 plain_text 行级 diff）

- [x] 加载两个版本 Yjs update 到独立 `yrs::Doc`
- [x] 逐节点比较根 Fragment 子节点
- [x] 段落/标题 → 文本级 diff（行级）
- [x] 返回 `{ ops: [{ type: 'insert'|'delete'|'equal', text, pos }], stats: { additions, deletions } }`

### 5.5 前端 — 版本历史面板

- [x] `services/office/versions.ts` 封装 API
- [x] `VersionTimeline.vue`：浮动面板，时间线条目，版本对比选择
- [x] `VersionDiff.vue`：模态窗口，行内差异渲染（绿底/红底 + 行号）
- [x] `RestoreConfirmDialog.vue`：回滚确认弹窗
- [x] 编辑器顶栏右侧"版本历史"按钮
- [x] 回滚后通过 `@restored` 事件刷新面板

### 5.6 M5 验收

- [ ] 自动快照按策略定时生成
- [ ] 手动命名版本创建成功，可查看历史
- [ ] 两版本 diff 展示正确（文本增删）
- [ ] 回滚后编辑器内容正确，可继续编辑

---

## M6 — 多端支持

### 设计参考
- 设计文档: `docs/office/office_pb_design.md` §6

### 6.1 后端 — 文档渲染接口

- [x] `GET /api/office/docs/{id}/render?format=html|fragment` — 后端预渲染 HTML
- [x] HTML 包含：标题、文档内容（Yjs XML→HTML 转换）、创建/更新时间
- [x] 权限校验：Viewer+（含临时 JWT 的分享用户）
- [x] Yjs XML→HTML 转换：支持 paragraph/heading/bold/italic/strike/link/list/codeblock/blockquote/image/hr/br

### 6.2 Flutter — WebView 容器（暂不实现）

> 已登记至 `pending.md`

### 6.3 Flutter — 移动端只读浏览（暂不实现）

> 已登记至 `pending.md`

### 6.4 Web — PWA/离线增强

- [x] `vite-plugin-pwa` 配置 Service Worker（autoUpdate + NetworkFirst API 缓存）
- [x] 编辑器静态资源 SW precache（46 entries, 846 KiB）
- [x] PWA manifest（桌面图标 SVG、主题色 #1565c0、standalone）

### 6.5 M6 验收

- [ ] PWA 安装后离线打开已缓存文档

---

## M7 — 知识库层

### 设计参考
- 设计文档: `docs/office/office_pb_design.md` §7

### 7.1 数据库迁移

- [x] 新建 `wikis` 表（id, tenant_id, name, description, icon, cover, creator_id）
- [x] 新建 `wiki_members` 表（wiki_id, user_id, role, joined_at）
- [x] 新建 `wiki_pins` 表（id, wiki_id, doc_id, pinned_by, created_at）
- [x] `document_spaces` 增加字段：`wiki_id` + `wiki_space_type`
- [x] 迁移文件 `m20260729_100001_office_m7.rs`

### 7.2 后端 — wiki CRUD

- [x] `controllers/wikis.rs`：
  - `GET /api/office/wikis` — 当前用户可访问的知识库列表
  - `POST /api/office/wikis` — 创建知识库
  - `GET /api/office/wikis/{id}` — 知识库详情（含 member_count + space_count）
  - `PATCH /api/office/wikis/{id}` — 更新
  - `DELETE /api/office/wikis/{id}` — 删除
- [x] `models/wikis.rs` + `models/wiki_members.rs` + `models/wiki_pins.rs` SeaORM 实体 / Model
- [x] 权限：wiki 成员管理（admin/owner 可管理成员，Viewer/Editor/Admin/Owner 四级）

### 7.3 后端 — 知识库扩展

- [x] `GET /api/office/wikis/{id}/members` — 成员列表
- [x] `POST /api/office/wikis/{id}/members` — 添加成员
- [x] `DELETE /api/office/wikis/{id}/members/{user_id}` — 移除成员
- [x] `GET /api/office/wikis/{id}/spaces` — 知识库空间列表
- [x] `GET /api/office/wikis/{id}/recent` — 最近更新文档（前 20）
- [x] `POST /api/office/wikis/{id}/pins` — 置顶文档
- [x] `DELETE /api/office/wikis/{id}/pins/{doc_id}` — 取消置顶

### 7.4 后端 — 权限继承

- [x] `permission.rs` 新增 `WikiRole` enum + `resolve_wiki_role` + `require_wiki_role`
- [x] `require_role` 回退链：creator → document_members → wiki_members（通过 `space.wiki_id`）
- [x] 默认 space 自动继承 wiki 角色（`inherit_from_space` 为 true 时）

### 7.5 前端 — 侧栏改造

- [x] Wiki 切换器（侧栏顶部 `<select>` 下拉选择知识库）
- [x] 选中知识库后过滤空间列表
- [x] `useWikiStore` Pinia store（wikis 列表 + currentWikiId）

### 7.6 前端 — 知识库首页

- [x] `WikiHome.vue`：概览页（名称/描述/成员数 + 置顶文档 + 最近更新）
- [x] `HomeView` 改造：默认显示 WikiHome（有 wiki 时）/ DocList（无 wiki 时）
- [x] `document` store 新增 `filter` + `setFilter`

### 7.7 M7 验收

- [ ] 新建知识库，可在其下创建 space + doc（需部署验证）
- [ ] 知识库成员角色正确继承到文档（inherit_from_space）
- [ ] 侧栏 wiki 下拉切换正确过滤空间

---

## M8 — IM 集成

### 设计参考
- 设计文档: `docs/office/office_pb_design.md` §8

### 8.1 后端 — 文档预览接口

- [x] `GET /api/office/docs/{id}/preview` — 文档元数据（title, icon, excerpt 前 200 字, updated_at, creator）
- [x] 权限校验：Viewer+
- [x] IM 链接检测预览由 IM 模块调用该接口

### 8.2 后端 — @提及

- [x] 新建 `document_mentions` 表（id, doc_id, mentioned_type, mentioned_id, mentioned_by, created_at）
- [x] `GET /api/office/mentions/users?q=keyword` — 搜索当前租户用户（ILIKE name, 限 20 条）
- [x] `GET /api/office/mentions/docs?q=keyword&space_id=xxx` — 搜索文档（ILIKE title）
- [x] 保存文档时 `yjs_store::save_document` 扫描提及 → upsert `document_mentions`
- [x] 迁移文件 `m20260730_100001_office_m8.rs`

### 8.3 ProseMirror — mention node

- [x] Schema 定义 `mention` inline node（attrs: id, mention_type, label, atom: true）
- [x] `useMention.ts` composable（检测 `@`/`#` 输入，弹出搜索浮层，↑↓ 导航，Enter 插入）
- [x] `MentionPopup.vue`：浮动面板，搜索结果显示（用户/文档），当前高亮项
- [x] mention node CSS 样式（蓝色背景圆角标签 `.mention`，文档紫色 `.mention--doc`）
- [x] 集成到 `ProseEditor`（`extraPlugins` + `MentionPopup` 组件）

### 8.4 前端 — 分享到会话（暂不实现）

> 需要 IM 模块的会话选择器组件，等待 IM 模块就绪后实现。

### 8.5 通知联动（暂不实现）

> 需要 IM notification 模块就绪后实现。

### 8.6 TaskItem ↔ Todo 联动（暂不实现）

> 需要 todo 模块 + SDK 扩展，延后。

### 8.7 M8 验收

- [ ] IM 中粘贴文档链接自动展示预览卡片
- [ ] @提及弹出搜索浮层，选择后插入 mention node
- [ ] 分享到会话成功后发送消息卡片
- [ ] @提及的用户收到 IM 通知
- [ ] 文档任务列表项可同步为个人 todo

---

## M9 — 富组件与体验

### 设计参考
- 设计文档: `docs/office/office_pb_design.md` §9

### 9.1 结构化组件（已完成）

- [x] **Toggle**：ProseMirror node schema + node view（▶/▼ 箭头点击折叠展开，`collapsed` 属性）
- [x] **Callout**：schema + node view（info/warn/error/success 4 种，带 icon + 左边框颜色）
- [x] **Columns**：`columns` + `column` 双 node 类型，flex 自适应 2 栏布局
- [x] SlashMenu 添加 toggle / callout / columns 入口（`/` 菜单触发插入）
- [x] 新增 `nodes/` 组件目录（`nodes/toggle.ts`, `nodes/callout.ts`, `nodes/columns.ts`, `nodes/index.ts`）
- [x] `useEditorSchema` 支持 `extraNodes` + `nodeViews` 选项注入
- [x] editor.css 新增 toggle / callout / columns 样式

### 9.2 富媒体嵌入（暂不实现）

> 需要 store 模块文件上传接口完善和第三方嵌入解析，延后。

### 9.3 公式与图表（暂不实现）

> 需要 KaTeX / Mermaid npm 安装 + node view 实现，延后。

### 9.4 代码块增强（已完成）

- [x] **语言选择器**：代码块顶部 `<select>`，24 种常用语言（纯文本/JS/TS/Python/Rust/Go 等）
- [x] **语法高亮**：安装 `highlight.js`，代码块 node view 自动按语言高亮
- [x] **复制按钮**：代码块右上角 SVG 图标，点击复制 + 反馈（✓ 提示）
- [x] 代码块 node view 重写（`codeBlock`），代替原有 `toDOM`
- [x] editor.css 新增 dark 主题高亮配色

### 9.5 目录与导航（已完成）

- [x] `Outline.vue`：右侧固定面板（200px），仅在有 heading 时显示
- [x] `useOutline.ts` composable：遍历 doc 提取 heading 列表
- [x] 嵌套缩进渲染（h1→h6 不同 padding-left）
- [x] 点击跳转到对应标题（`scrollTo` + 设置光标）
- [x] `ProseEditor.vue` 集成 outline，flex-row 布局

### 9.6 表格增强（暂不实现）

### 9.7 表情反应（暂不实现）

### 9.8 M9 验收

- [x] Toggle/Callout/Columns 插入显示正确，可嵌套编辑
- [x] 代码块语言选择 + 高亮 + 复制
- [x] 右侧大纲实时跟随编辑
- [ ] 表格右键增删行列（M9.6 未实现）
- [ ] 文档底部表情反应实时更新（M9.7 未实现）

---

## Phase B 交叉事项

- [ ] 更新 `docs/office/todo.md` 进度（每个 milestone 完成后）
- [ ] 向后端办公室邮件列表发送 Phase B 变更通知
- [ ] 补充 Phase B API 的自动化测试（`backend_test/test/office/`）

---

## Phase C — 待启动

> 具体任务待 Phase B 完成后拆解，详见 `office_roadmap.md` 中 M10-M14 描述。
