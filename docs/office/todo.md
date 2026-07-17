# 文档模块实施进度

> 对应 `docs/office/office_roadmap.md` 中的里程碑。每项任务完成后将 `[ ]` 改为 `[x]`。
>
> **当前阶段：Phase A（MVP 基础可用）**

---

## Phase A — MVP

## M1 — 编辑器完善 ✅

### 设计参考
- 详细设计文档: `docs/office/office_pa_m1_design.md`
- 依赖: 无（M1 是基础里程碑）
- **交互形态**：纯浮动模式（FloatingToolbar + SlashMenu），不设固定顶部工具栏

### 1.0 基础设施

- [x] 创建 `frontend/src/views/office/composables/useEditorSchema.ts`
  - 定义完整 Schema（含 taskList/taskItem/codeBlock/table/underline/strike）
  - 装配所有 ProseMirror plugins（ySync, yCursor, yUndo, keymap, table）
  - 可单独测试 schema 定义
- [x] 修改 `ProseEditor.vue` 使用 `useEditorSchema` composable
  - 注入 `editorView` 供子组件使用
  - 暴露 `editorView` ref

### 1.1 浮动工具栏 (FloatingToolbar)

- [x] 实现 `FloatingToolbar.vue`（M1 主交互入口）：
  - 通过 Teleport 渲染，选区上方浮出
  - 按钮：粗体 / 斜体 / 下划线 / 删除线 / 行内代码
  - 标题：正文 / H1 / H2 / H3
  - 引用 / 链接 / 清除格式
  - 每个按钮响应 active 状态（根据选区高亮）
  - 分组间添加分隔线
- [x] 创建 `useToolbarState` composable（通过 Plugin 追踪选区状态 + 浮动位置）
- [x] 安装 `@lucide/vue` 图标库
- [x] 实现原子组件（供后续复用，M1 未挂载到编辑器）：
  - `ToolbarButton.vue`（props: active, disabled, tooltip; slot: icon）
  - `ToolbarDivider.vue`
  - `ToolbarDropdown.vue`
  - `Toolbar.vue`（容器）

> **注**：块级插入（列表/代码块/表格/图片/分割线/任务列表）通过 **SlashMenu** 而非工具栏触发。原设计中"顶部固定 Toolbar"改为浮动模式，Toolbar.vue 与原子组件保留作为通用基础组件。

### 1.2 文档标题 (TitleBar)

- [x] 创建 `TitleBar.vue`：
  - 编辑框展示文档标题
  - 占位符 "无标题"
  - 500ms debounce 后 `PATCH /api/office/docs/{id} { title }`
  - 无边框样式，hover 显示浅边框
- [x] 在 `EditorView.vue` 中集成 TitleBar（替换原来的 title fetch）

### 1.3 链接 (LinkDialog)

- [x] 创建 `LinkDialog.vue`：
  - 输入：URL + 显示文本
  - 选中文字时自动填入"显示文本"
  - 已有链接时预填 URL 和文本（编辑模式）
  - 确认后执行 `toggleLink(attrs)` 或 `updateLink(attrs)`
  - 移除链接按钮（仅编辑模式）
  - 弹窗样式：半透明遮罩 + 居中卡片
- [x] 工具栏链接按钮绑定 LinkDialog（从 Toolbar emit → EditorView 管理 dialog state）

### 1.4 图片上传 (ImageUpload)

- [x] 创建 `ImageUpload.vue`：
  - 触发：粘贴 (`Ctrl+V` 检测 `image/png` 等) / 拖拽 (`dragover` + `drop`) / 斜杠菜单
  - 上传：`POST /api/files/upload` (multipart/form-data)
  - 进度指示（旋转图标 + 百分比）
  - 上传完成后 dispatch `insertImage({ src: url })`
  - 错误处理（文件大小 10MB、格式 PNG/JPEG/WebP/GIF）
- [x] 粘贴图片支持（`editorView.dom.addEventListener('paste', ...)`）
- [x] 拖拽图片支持（`editorView.dom.addEventListener('drop', ...)`）
- [x] 斜杠菜单添加"图片"入口（`provide/inject: triggerImageUpload` → 触发 `ImageUpload.trigger()`）

### 1.5 任务列表 (taskList)

- [x] 实现 `toggleTaskItem()` 命令（`taskItemClickHandler` plugin — 点击 checkbox 切换 `checked`）
- [x] 实现 `wrapInTaskList()` 命令（SlashMenu 中内联实现）
- [x] SlashMenu 添加"任务列表"入口
- [x] 添加 CSS 样式（checkbox 渲染、完成态透明度 + 删除线）
- [x] `prosemirror-inputrules` 输入规则：`[] ` / `[x] ` 自动转换

### 1.6 代码块 (codeBlock)

- [x] 实现 `setCodeBlock()` 命令（SlashMenu 中绑定 `setBlockType`）
- [x] SlashMenu 添加"代码块"入口 + 快捷键 `Ctrl+Shift+C`（keymap `Mod-Shift-c`）
- [ ] ~~语言选择下拉~~ → 推迟到 **M9**（富组件与体验）
- [x] 添加 CSS 样式（暗色背景 `#1e1e1e`、等宽字体、提升视觉）

### 1.7 表格 (table)

- [x] 集成 `prosemirror-tables` 插件（`tableEditing` + `columnResizing` key）
- [x] 实现 `insertTable()` 命令（3x3，SlashMenu 中内联实现）
- [x] SlashMenu 添加"表格"入口
- [ ] ~~`addRowBefore` / `addRowAfter` / `addColBefore` / `addColAfter` / `deleteRow` / `deleteCol` 命令 + 右键菜单~~ → 推迟到 **M9**
- [x] 添加 CSS 样式（边框、单元格 padding、header 背景色、column-resize-handle）

### 1.8 快捷键

- [x] 内置快捷键工作：`Ctrl+B`, `Ctrl+I`, `Ctrl+Z`, `Ctrl+Y`（ProseMirror built-in）
- [x] 实现自定义 keymap：`Ctrl+U` (underline), `Ctrl+Shift+S` (strike), `Ctrl+Shift+C` (code block)
- [x] `Ctrl+K` (link dialog) — 通过 `useEditorSchema` keymap `Mod-k` + `onLinkShortcut` 回调打开 LinkDialog
- [x] 实现 `Tab` 缩进列表项 / 跳转表格单元格（`sinkListItem` + `goToNextCell`）
- [x] 实现 `Shift+Tab` 反缩进 / 反跳转
- [x] 实现 `Enter` 在空 taskItem 上退化为段落

### 1.9 斜杠菜单 (SlashMenu)

- [x] 创建 `SlashMenu.vue`：
  - 监听 `/` 输入弹出菜单（block 起始位置）
  - 菜单项列表：段落、每级标题、引用、分割线、有序/无序/任务列表、代码块、表格
  - 键盘导航：上下箭头 + Enter
  - 按 Esc 或 Backspace（filter 为空时）隐藏
  - 菜单项带图标和描述
- [x] 注册 ProseMirror plugin 管理斜杠菜单状态（visible, position, filter）
- [x] 菜单弹出位置跟随光标（`coordsAtPos`）

### 1.10 样式完善

- [x] `editor.css` 新增/完善：
  - 表格样式（边框、header、单元格、column-resize-handle）
  - 任务列表样式（checkbox 渲染、完成态 + 删除线）
  - 代码块样式（暗色背景 `#1e1e1e`、等宽字体）
  - 图片样式（最大宽度、点击查看）
  - 下划线 / 删除线 / 行内代码 / 链接 / h4–h6 样式
- [x] 浮动工具栏样式（按钮、分隔线、分组、active/hover 态，box-shadow）

### 1.11 M1 遗留补齐 ✅

- [x] `Ctrl+K` 真正打开 LinkDialog：
  - `useEditorSchema` 增加 `onLinkShortcut` 回调，`Mod-k` keymap 触发
  - `ProseEditor.vue` 传入回调设置 `showLinkDialog = true`
  - 移除 `EditorView.vue` 里无意义的 preventDefault
- [x] SlashMenu 添加"图片"入口：
  - `ProseEditor.vue` 通过 `provide('triggerImageUpload', ...)` 暴露触发器
  - `SlashMenu.vue` inject 后追加"图片"菜单项，执行时触发系统 file picker

### M1 验收清单

- [x] 浮动工具栏切换格式正常（active 态跟随选区同步）
- [x] 标题编辑保存生效
- [x] 图片上传（粘贴 / 拖拽 / 斜杠菜单）成功并插入编辑器
- [x] 链接插入/编辑/移除正常（浮动工具栏 + LinkDialog）
- [x] 任务列表创建、checkbox 切换、Enter 行为正常
- [x] 代码块创建正常（斜杠菜单 + `Ctrl+Shift+C`）
- [x] 表格创建、Tab 跳转正常（斜杠菜单）
- [x] 快捷键 `Ctrl+B/I/U`、`Ctrl+K`、`Ctrl+Shift+S/C`、Tab/Shift+Tab、Enter 正常
- [x] 斜杠 `/` 弹出菜单，可切换任意节点类型（含图片）
- [x] 编辑器样式统一
- [ ] 协作同步正常（→ M2 联调验证）
- [ ] 后端 API 无性能退化（→ M12 自动化测试）

---

## M2 — 协作增强

### 设计参考
- PRD: `docs/office/office_pa.md` §2.1 M2
- 技术方案: `docs/office/office_pa_design.md` §4.5 / §5.3 / §8-M2
- 依赖: M1

### 2.1 后端 — Yjs 保存状态推送

- [x] `backend/office/src/ws.rs`：Yjs 持久化成功后向房间广播自定义消息 `MSG_CUSTOM_SAVED(100)`，payload = 毫秒时间戳
- [x] 收到 client update 且从 clean→dirty 过渡时广播 `MSG_CUSTOM_SYNCING(101)`（debounce，避免高频输入淹没）
- [x] 保存前 flush pending awareness — 由 `yrs-axum` `BroadcastGroup` 内建覆盖，无需额外代码
- [x] `BroadcastGroup` 上限从 32 改为读取环境变量 `BUZZING_YJS_MAX_CLIENTS`（默认 128）

### 2.2 前端 — 保存状态指示

- [x] `composables/useYjs.ts` 扩展：
  - 通过 `provider.messageHandlers[100/101]` 消费自定义消息
  - 订阅 `provider.on('status' | 'sync')`，本地 update 立即置 `syncing`
  - 输出 `saveState: 'saved' | 'syncing' | 'offline'` + `lastSavedAt` + `connected` + `editingUsers`
- [x] 创建 `components/SyncStatus.vue`：
  - 顶栏右侧展示"已保存 · 相对时间 / 正在同步… / 离线，本地已保存"
  - 三态各自使用绿/蓝/黄配色 + 呼吸圆点
- [x] `EditorView.vue` 集成 SyncStatus + Collaborators 到顶栏右侧

### 2.3 前端 — 协作光标增强

- [x] `Collaborators.vue` 重构：接受 `users` prop，展示头像列表，悬停显示名字标签
- [x] 光标 DOM 名字标签：`y-prosemirror` 默认 `cursorBuilder` 已内置，通过 `.ProseMirror-yjs-cursor > div` CSS 定制
- [x] 选区高亮：`.ProseMirror-yjs-selection` 使用 defaultSelectionBuilder 的 `bg + 70 alpha`
- [x] 颜色调色板：`useYjs.ts` 中 `pickUserColor(uid)` 从 8 色 tailwind 400 色板按 uid 稳定映射

### 2.4 前端 — 断线重连与离线缓存

- [x] 安装 `y-indexeddb` + `lib0`（pnpm add）
- [x] `useYjs.ts` 集成 `IndexeddbPersistence(\`buzzing-office-${docId}\`, ydoc)`，暴露 `localLoaded`
- [x] `y-websocket` 使用默认指数退避重连
- [x] 网络中断时 `saveState = 'offline'`，SyncStatus 显示"离线，本地已保存"
- [x] 恢复后 Yjs 自动补同步；`provider.on('sync')` 触发状态回到 `saved`

### 2.5 M2 验收

- [ ] 3 人同时打开同一文档，光标带名字标签正确显示（待手动联调）
- [ ] 一人断网 30 秒后恢复，编辑内容完整同步给其他人（待手动联调）
- [ ] 顶栏保存状态在编辑 → 保存 → 空闲三个阶段过渡自然（待手动联调）
- [x] BroadcastGroup 上限可通过环境变量 `BUZZING_YJS_MAX_CLIENTS` 调整

---

## M3 — 文档管理

### 设计参考
- PRD: `docs/office/office_pa.md` §2.1 M3
- 技术方案: `docs/office/office_pa_design.md` §2.1-2.5 / §3 / §4.4 / §5.3
- 依赖: M1

### 3.1 数据库迁移

- [x] `documents` 表加字段：
  - `parent_id BIGINT` / `trashed_at TIMESTAMPTZ` / `icon VARCHAR` / `cover VARCHAR` / `plain_text TEXT` / `search_tsv tsvector`（GIN）
- [x] `document_spaces` 加字段：`icon` / `color` / `sort_order` / `archived_at`
- [x] 新增 `document_stars` 表 + `ux_document_stars_user_doc` 唯一索引
- [x] 新增 `document_visits` 表 + 唯一索引 + `(user_id, visited_at desc)` 复合索引
- [x] 迁移文件 `m20260720_100001_office_m3.rs`

### 3.2 后端 — 全文搜索

- [x] Yjs 快照保存时同步提取 `plain_text`（`XmlFragmentRef::get_string` + strip_xml_tags）
- [x] `controllers/search.rs`：`POST /api/office/docs/search`，使用 `plainto_tsquery('simple', $q)` + `ts_headline` 高亮，支持 `space_id` / `limit` / 租户级过滤

### 3.3 后端 — 回收站与生命周期

- [x] `controllers/trash.rs` 三接口：`GET /docs/trash` / `POST /docs/{id}/restore` / `DELETE /docs/{id}/purge`
- [x] 现有 `DELETE /docs/{id}` 改为软删除（`documents.trashed_at`）
- [x] `AppOffice::serve` 启动 1 小时轮询任务，清理 `trashed_at` 超过 30 天的文档

### 3.4 后端 — 移动 / 复制 / 星标 / 最近

- [x] `POST /docs/{id}/move` — 更新 `space_id` / `parent_id`（`parent_id="0"` 表示提到根级）
- [x] `POST /docs/{id}/duplicate` — 递归复制 Yjs state + 元数据 + 子页面（`include_children`）
- [x] `POST /docs/{id}/star` / `DELETE /docs/{id}/star`（幂等）
- [x] `GET /docs/starred`
- [x] `POST /docs/{id}/visit`（upsert `document_visits`）
- [x] `GET /docs/recent?limit=20`

### 3.5 后端 — 子页面树

- [x] `GET /docs/tree?space_id=xxx`：单次查询 + 内存组装，输出 `TreeNode { id, parent_id, title, icon, children }`

### 3.6 前端 — 全局搜索

- [x] `components/SearchBar.vue`：`Cmd/Ctrl+K` 全局唤起，debounce 200ms，↑↓ 导航 Enter 打开
- [x] 高亮片段渲染（`v-html`，`<em>` 黄底蓝字），显示 title/content 标签
- [x] `services/office/docs.ts` 封装 `search()` API

### 3.7 前端 — 回收站

- [x] `views/office/TrashView.vue`：列表 + 剩余天数 + 恢复/永久删除按钮
- [x] `router/index.ts` 添加 `/office/trash` 路由 (`OfficeTrash`)
- [x] `HomeView` 侧栏加入"回收站"入口

### 3.8 前端 — 子页面树 + 面包屑

- [x] `SpaceTree.vue` 改造：递归展开，支持拖拽（空间间调整 sort_order；文档跨空间/换父级）
- [x] `DocTreeNode.vue` 递归组件（支持右键菜单、图标、拖拽 into）
- [x] `Breadcrumb.vue`：EditorView 顶部展示 `空间 / 父页面 / … / 当前文档`，点击跳转
- [x] `EditorView` 加载文档时递归上溯 `parent_id` 构建面包屑
- [x] `DocList.vue` 只展示根级文档，子页面在 SpaceTree 展开查看

### 3.9 前端 — 星标与最近

- [x] `views/office/views/StarredView.vue` + `RecentView.vue`
- [x] `HomeView` 侧栏"快速访问"分组（星标 / 最近 / 回收站）
- [x] 文档列表右键 & SpaceTree 右键均可 toggle 星标
- [x] `EditorView.onMounted` 调用 `POST /docs/{id}/visit`

### 3.10 前端 — 空间管理增强

- [x] 空间右键菜单：重命名 / 设置图标 / 新建文档 / 归档 / 删除
- [x] 空间列表拖拽调整 `sort_order`
- [x] `IconPicker.vue` emoji 图标选择器（4 分类，40+ 常用 emoji）

### 3.11 SDK — BizOffice 扩展

- [x] （本轮跳过，Flutter 客户端后续接入时再补齐；见 roadmap）

### 3.12 M3 验收

- [ ] 万级文档规模下搜索 P50 < 300ms （待联调）
- [ ] 删除文档进回收站，30 天后自动 purge（后端定时任务已挂）
- [ ] 子页面可拖拽调整层级，面包屑正确显示
- [ ] 星标 / 最近文档分组入口在主页可用
- [ ] Cmd+K 全局搜索跨空间跳转正常

---

## M4 — 权限与分享

### 设计参考
- PRD: `docs/office/office_pa.md` §2.1 M4
- 技术方案: `docs/office/office_pa_design.md` §2.3 / §3 / §4.2 / §8-M4
- 依赖: M1, M3（部分复用文档管理入口）

### 4.1 数据库迁移

- [x] `document_members` 确认字段与索引（已有表）：
  - `role`：0=viewer / 1=commenter / 2=editor / 3=owner
  - PK 已是 `(doc_id, user_id)`（原设计的唯一索引已由主键保证）
- [x] 新增 `document_shares` 表（含 token / password_hash / expires_at / max_visits / visit_count / revoked_at）

### 4.2 后端 — 权限中间件

- [x] `backend/office/src/permission.rs`：
  - `Role` enum
  - `async fn require_role(ctx, user_id, doc_id, min_role) -> Result<Role>`
  - 查询顺序：`documents.creator == user_id` → `document_members` → （空间继承 TODO）→ 403
- [x] 现有 `docs::get / update / delete / move_doc / duplicate` + `trash::restore / purge` 加入权限校验
- [x] Yjs WebSocket 建连时校验（Viewer 及以上可连；只读由客户端 `ProseEditor readonly` 强制）
- [x] 新增 `GET /api/office/docs/{id}/permission` 前端读取角色

### 4.3 后端 — 成员管理

- [x] `controllers/members.rs`：
  - `GET /api/office/docs/{id}/members`
  - `POST /api/office/docs/{id}/members { user_id, role }`（upsert）
  - `PATCH /api/office/docs/{id}/members/{user_id} { role }`
  - `DELETE /api/office/docs/{id}/members/{user_id}`
- [x] 修改成员时校验：仅 owner 可管理成员（list 需 viewer+）

### 4.4 后端 — 共享链接

- [x] `controllers/shares.rs`：
  - `POST /api/office/docs/{id}/share { role, password?, expires_at?, max_visits? }` → 生成 token
  - `GET /api/office/docs/{id}/shares` — 列出该文档的所有链接
  - `DELETE /api/office/docs/shares/{share_id}` — 撤销
  - `POST /api/share/{token}/verify { password }` — 校验密码（公开）
  - `GET /api/share/{token}` — 解析 token（公开）：
    - 校验有效性 → 生成临时 JWT（`pid=share:{share_id}:{doc_id}`，含 role + doc_id + share_id）
    - 增加 `visit_count`
    - 返回文档元数据 + 临时 JWT
- [x] Token 使用 32 字符随机字符串（base62 alphabet）
- [x] 密码使用 `bcrypt::DEFAULT_COST`

### 4.5 后端 — 权限继承

- [ ] 空间级成员表（若尚未建立需迁移 `space_members`）— **暂缓：待 M5 空间协作时补齐**
- [ ] `require_role` 回退到空间成员时读取空间角色 — 待空间成员表就绪
- [x] `documents.inherit_from_space bool`（默认 true）字段已在 M4 迁移中就绪

### 4.6 前端 — 成员管理 Dialog

- [x] `components/MemberDialog.vue`：
  - 展示当前成员列表（头像/名字/角色下拉）
  - 添加成员：输入 user_id + 角色下拉（后续替换成员搜索器）
  - 修改角色 / 移除成员
  - 空间继承来源标记 — **待 4.5 补齐**
- [x] `services/office/members.ts`

### 4.7 前端 — 共享 Dialog

- [x] `components/ShareDialog.vue`：
  - 复制链接按钮
  - 权限下拉（viewer / commenter）
  - 过期时间：`datetime-local` 自定义（快捷预设可后续补）
  - 访问密码输入
  - 已有链接列表 + 撤销
- [x] `services/office/shares.ts`

### 4.8 前端 — 只读视图 (ShareView)

- [x] `views/office/ShareView.vue` + `components/ShareReader.vue`：
  - 独立路由 `/share/:token`（公开，不走 tenantGuard）
  - 首次加载调用 `GET /api/share/:token` 获取临时 JWT + 文档元数据
  - 若需密码，先弹出密码框调用 `POST /api/share/:token/verify`
  - 内嵌 ProseEditor 以只读模式加载（EditorView 保持授权访问路径不变）
- [x] `composables/usePermission.ts`：查询并暴露 role / canEdit / readOnly
- [x] `useEditorSchema` + `ProseEditor` 支持 `editable` 开关；ShareReader 使用共享 JWT 且禁用 IndexedDB
- [ ] Toolbar / FloatingToolbar / SlashMenu 在 viewer 模式下隐藏或禁用 — **未细化，只读时编辑事务已被 ProseMirror 拒绝**

### 4.9 前端 — 权限视觉标记

- [ ] 文档列表项右侧角色徽章（"所有者" / "编辑" / "评论" / "查看"）— **待补**
- [x] EditorView 顶栏显示只读标记（当无 Editor 权限时）
- [x] 分享 / 成员入口按钮放在编辑器顶栏（仅 editor+ 可见）

### 4.10 SDK — BizOffice 扩展

- [ ] 补充 M4 相关 trait 方法（见 `office_pa_design.md` §6.1）— **暂跳过，与 M2/M3 同策**
- [ ] HTTP 客户端实现 — 同上

### 4.11 M4 验收

- [x] 4 种角色（viewer/commenter/editor/owner）权限校验完整（空间继承除外）
- [x] 共享链接支持过期 / 密码 / 次数限制，任一条件不满足返回 404
- [x] 未登录用户可通过公开分享链接以只读模式打开文档
- [x] 只读模式下 ProseMirror 不接受编辑事务；顶栏隐藏成员/分享按钮
- [ ] 空间成员权限自动继承到文档（可关闭）— **随 4.5 一起延后**

---

## Phase A 交叉事项

- [ ] `backend_test/test/office/` 添加自动化测试脚本（M1-M4 每个 milestone 的核心接口）
  - `office.spec.md` 描述测试用例
  - `office.test.js` 覆盖 CRUD / 搜索 / 权限 / 分享
- [ ] `buzzing/sdk_test/` 添加 BizOffice 测试

---

## Phase B / C — 待启动

> 具体任务待 Phase A 完成后再拆解，详见 `office_roadmap.md` 中 M5-M14 描述。
