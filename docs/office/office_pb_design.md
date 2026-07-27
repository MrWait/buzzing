# 文档业务技术方案 — Phase B

对应 PRD 参考 [`office_roadmap.md`](./office_roadmap.md) Phase B（M5-M9）。本方案覆盖 **版本历史 / 多端支持 / 知识库层 / IM 集成 / 富组件与体验** 五个里程碑的架构、数据模型、接口设计。

---

## 0. 架构概述

### 0.1 增量架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Phase B 新增组件                                │
│                                                                      │
│  Backend:                                                             │
│    document_versions  ── 版本快照/对比/回滚                             │
│    wikis / wiki_members ── 知识库层级（文档直接通过 wiki_id 归属）                                  │
│    document_mentions ── @提及存储                                      │
│    document_reactions ── 表情反应                                      │
│    /api/office/versions/* ── 版本 CRUD                                 │
│    /api/office/wikis/* ── 知识库 CRUD                                  │
│    /api/office/mentions/search ── @提及用户/文档搜索                     │
│    /api/office/docs/{id}/preview ── IM 卡片元数据                       │
│                                                                      │
│  Frontend:                                                             │
│    VersionTimeline.vue ── 版本时间轴                                    │
│    VersionDiff.vue ── 版本对比视图                                     │
│    Outline.vue ── 右侧目录大纲                                         │
│    MentionEditor.vue ── @提及组件                                      │
│    CalloutNode / ToggleNode / ColumnsNode ── 结构化组件                  │
│    CodeBlockLang.vue ── 语言选择 + 语法高亮                             │
│    TableContextMenu.vue ── 表格右键                                     │
│                                                                      │
│  Flutter:                                                              │
│    webview_flutter ── 嵌入 SPA 编辑器                                  │
│    ReaderView ── 移动端只读渲染                                        │
└─────────────────────────────────────────────────────────────────────┘
```

### 0.2 Phase B 关键设计决策

| 决策 | 选择 | 理由 |
|------|------|------|
| 版本存储 | Yjs `encode_state_as_update_v1` 增量快照 | 与现有 Yjs 持久化一致，支持按需合并 |
| 版本对比 | 取两个快照的 Yjs update 解码后逐节点 diff | 无需额外存储 diff，快照即 diff 源 |
| Flutter 编辑 | `webview_flutter` 嵌入 SPA | 编辑器逻辑全部在 Web 端，Flutter 仅提供容器 + 原生工具栏叠加 |
| 知识库层级 | `wikis` 表 + `documents.wiki_id`，文档通过 `parent_id` 形成树 | 去掉了中间 Space 层，三层 → 两层，更简洁；利用已有的 `parent_id` 实现树形层级 |
| @提及实现 | ProseMirror `mention` node + 弹出搜索浮层 | 标准方案，协作友好（y-prosemirror 同步 node） |
| 公式渲染 | KaTeX（行内 `math_inline` + 块级 `math_display` node） | 轻量，无外部依赖加载慢问题 |
| 代码高亮 | highlight.js（运行时 + 按语言动态加载） | 生态好，支持 190+ 语言，包体积可控 |
| 结构化组件 | 每个组件一个 ProseMirror node | 解耦，可独立测试，Schema 隔离 |
| TOC 生成 | 编辑器 Plugin 扫描 heading 节点生成 | 无额外存储，实时跟随编辑 |

---

## M5 — 版本历史

### 5.1 数据库设计

```sql
CREATE TABLE document_versions (
    id BIGINT PRIMARY KEY,
    document_id BIGINT NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    version_number INTEGER NOT NULL,
    title VARCHAR NOT NULL DEFAULT '',
    description VARCHAR DEFAULT '',           -- 手动命名版本描述
    yjs_snapshot BYTEA NOT NULL,             -- Yjs encode_state_as_update_v1
    plain_text TEXT,                          -- 该版本的纯文本
    creator_id BIGINT NOT NULL,
    is_minor BOOLEAN NOT NULL DEFAULT FALSE,  -- true=自动快照, false=手动命名版本
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_doc_versions_doc ON document_versions(document_id, version_number DESC);
```

**快照策略**（在 `periodic_save_loop` 内实现）：
- 文档首次保存后创建 v1
- 每次手动命名保存创建显式版本（`is_minor=false`）
- 后台自动快照：最近 1 小时内每 5 分钟一次；1-24 小时每小时一次；超过 24 小时每天一次
- 自动快照上限 100 条，超出后合并最早的历史（`yjs_merge_updates`）

### 5.2 API 设计

| 方法 | 路径 | 说明 |
|------|------|------|
| `GET` | `/api/office/docs/{id}/versions?limit=50&offset=0` | 版本列表（按 version_number DESC） |
| `POST` | `/api/office/docs/{id}/versions` | 创建手动命名版本 `{ title, description }` |
| `GET` | `/api/office/docs/{id}/versions/{version_id}` | 获取单个版本快照 |
| `POST` | `/api/office/docs/{id}/versions/diff` | 对比两个版本 `{ v1_id, v2_id }` → diff 结果 |
| `POST` | `/api/office/docs/{id}/versions/{version_id}/restore` | 回滚到指定版本（追加新版本，不覆盖） |

### 5.3 Diff 算法

1. 加载两个版本的 `yjs_snapshot` 到独立 `yrs::Doc`
2. 遍历根 `XmlFragment` 的子节点
3. 对段落/标题 → 文本级 diff（`diff_match_patch` 或字符级对比）
4. 对结构化节点（表格/列表）→ 按行/单元格对比
5. 返回 `{ ops: [{ type: 'insert'|'delete'|'equal', text, pos }], stats: { additions, deletions } }`

### 5.4 前端设计

**组件树**：
```
EditorHeader
  └── VersionButton ──→ VersionTimeline (slide panel, 右侧滑出)
                          ├── VersionListItem (时间线条目，含自动/手动标记)
                          ├── VersionDiff (左右对比或行内差异)
                          │    ├── DiffLine (高亮增删行)
                          └── RestoreConfirmDialog (回滚确认)
```

**交互流程**：
1. 编辑器顶栏右侧新增"版本"按钮（时钟图标）
2. 点击滑出右侧面板 `VersionTimeline`
3. 每条版本显示：编号、时间、创建者、描述（手动命名版本）或"自动保存"标记
4. 选中一条 → 预览只读快照（可全屏查看）
5. 勾选两条对比 → `VersionDiff` 渲染差异
6. "回滚到此版本" → 确认 → 调用 restore API → 刷新编辑器

**实现要点**：
- `VersionTimeline` 使用 `position: fixed` 右滑面板（类似 Notion 版本历史）
- `VersionDiff` 用纯 CSS 渲染增删行（绿底/红底 + 行号）
- 回滚后通过 `provider` 重置 Yjs `Doc` 内容

---

## M6 — 多端支持

### 6.1 Flutter 桌面编辑

**方案**：`webview_flutter` 嵌入 Web SPA 编辑器

```
Flutter App
  ├── Native TitleBar + Toolbar overlay (可选)
  └── WebView
       └── SPA /office/editor/{docId}?token={jwt}
            ├── JS Bridge: postMessage(token, docId)
            ├── Flutter → Web: 打开链接, 插入图片, 切换只读
            └── Web → Flutter: 保存状态, 选区信息, 图片上传路径
```

**JS Bridge 接口**：

```dart
// Flutter → Web
webController.runJavaScript(`
  window.__buzzingBridge?.setToken('${jwt}');
  window.__buzzingBridge?.openDoc('${docId}');
  window.__buzzingBridge?.setReadonly(${isReadonly});
`);

// Web → Flutter (via JavaScriptChannel)
class BuzzingChannel {
  @JavascriptInterface
  void onSaveState(String state) {}   // 'saved' | 'syncing' | 'offline'
  @JavascriptInterface
  void onImagePick() {}               // 触发原生文件选择器
}
```

### 6.2 移动端只读浏览

**方案 A（推荐，轻量）**：后端预渲染 HTML → Flutter `flutter_widget_from_html` 或 `WebView` 只读打开

**方案 B**：ProseMirror JSON → Flutter 原生渲染（成本高，延后）

**流程**：
1. `GET /api/office/docs/{id}/render?format=html` → 返回 HTML（标题 + 正文纯文本 + 图片）
2. Flutter 内嵌 WebView 或使用富文本组件展示
3. 不支持协作/编辑，仅浏览

### 6.3 Web SPA 离线编辑增强（增量改善）

- Service Worker 注册（`vite-plugin-pwa`）
- 编辑器静态资源 SW cache
- IndexedDB 已有（y-indexeddb），补充 PWA manifest

### 6.4 实施顺序

1. 后端预渲染 HTML 接口
2. Flutter WebView 容器 + JS Bridge
3. 移动端只读浏览
4. Service Worker / PWA

---

## M7 — 知识库层

### 7.1 设计决策

**简化层级**：去掉中间 Space 层，将三层结构「知识库 → 空间 → 文档」简化为两层结构：

```
Organization (租户)
 └── Wiki (知识库)
      └── Document (文档，可含子页面，通过 parent_id 形成树)
```

**理由**：
- 三层结构让用户困惑（空间和知识库的边界模糊）
- 文档已有 `parent_id` 字段（M3.5 实现），天然支持树形层级，无需额外中间层
- 权限链路更短：`wiki_members` → `documents.wiki_id`
- 与飞书等主流产品的用户心智模型一致

### 7.2 数据模型

```sql
CREATE TABLE wikis (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT DEFAULT '',
    icon VARCHAR(50) DEFAULT '',
    cover VARCHAR(500) DEFAULT '',
    creator_id BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE wiki_members (
    wiki_id BIGINT NOT NULL REFERENCES wikis(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL,
    role SMALLINT NOT NULL DEFAULT 1,   -- 1=member, 2=admin, 3=owner
    joined_at BIGINT NOT NULL,
    PRIMARY KEY (wiki_id, user_id)
);

-- documents 表新增 wiki_id 字段
ALTER TABLE documents ADD COLUMN wiki_id BIGINT REFERENCES wikis(id);
-- document_spaces 保留表结构（兼容历史数据），UI 不再暴露空间概念
```

**权限继承链**：`wiki_members`（通过 `documents.wiki_id`）→ `documents`
- 文档查询权限时：creator 优先 → `document_members` → 回退到 `wiki_members`（按 `documents.wiki_id`）

**文档树结构**：利用现有 `documents.parent_id`（自引用 FK），无需新增字段：
```
Wiki 首页 (wiki_doc_type=1)
 ├── 子文档 A (parent_id = wiki首页id)
 │    ├── 孙文档 A1 (parent_id = A)
 │    └── 孙文档 A2 (parent_id = A)
 └── 子文档 B (parent_id = wiki首页id)
```

### 7.3 API 设计

| 方法 | 路径 | 说明 |
|------|------|------|
| `GET` | `/api/office/wikis` | 当前用户可访问的知识库列表 (含 role) |
| `POST` | `/api/office/wikis` | 创建知识库 `{ name, description, icon }` |
| `GET` | `/api/office/wikis/{id}` | 知识库详情 |
| `PATCH` | `/api/office/wikis/{id}` | 更新知识库信息 |
| `DELETE` | `/api/office/wikis/{id}` | 删除知识库（归档内部所有文档） |
| `GET` | `/api/office/wikis/{id}/members` | 成员列表 |
| `POST` | `/api/office/wikis/{id}/members` | 添加成员 `{ user_id, role }` |
| `DELETE` | `/api/office/wikis/{id}/members/{user_id}` | 移除成员 |
| `GET` | `/api/office/wikis/{id}/docs?parent_id=xxx` | 知识库文档树（按 parent_id 组织） |
| `GET` | `/api/office/wikis/{id}/recent` | 知识库最近更新 |
| `POST` | `/api/office/wikis/{id}/pins` | 置顶文档 |
| `DELETE` | `/api/office/wikis/{id}/pins/{doc_id}` | 取消置顶 |
| `POST` | `/api/office/wikis/{id}/docs` | 在知识库下创建文档 `{ title, parent_id? }` |

### 7.4 迁移方案

1. 创建 `wikis` / `wiki_members` 表
2. `documents` 表新增 `wiki_id` 字段（可为 null，兼容历史数据）
3. 后台脚本：遍历所有现有 space，为每个租户创建默认知识库；将 space 下的文档的 `wiki_id` 设为对应知识库 ID
4. `document_spaces` 保留表结构但不作为 UI 概念暴露
5. Web / Flutter 侧栏改造：知识库 → 文档树（去掉空间层）

### 7.5 前端设计

**侧栏改造**：
```
SidebarHeader (现有)
  ├── 搜索按钮 (移至 body 顶部)
  └── 标题 "在线文档"
QuickGroup (现有)
  ├── 星标 / 最近 / 回收站
WikiTreeNode (新增，替代原有的 SpaceTree)
  └── DocTreeNode (展开子文档)
```

**知识库首页**：
- `WikiHome.vue`：概览页（描述 + 最近更新 + 置顶 + 成员）
- wiki 切换器在侧栏顶部

**创建文档流程**：
- 新建文档时选择归属的知识库 + 父文档（可选）
- 文档树直接在知识库内通过 `parent_id` 组织

**@提及搜索**：
- `@doc` → `GET /api/office/mentions/docs?q=keyword&wiki_id=xxx`（不再传 space_id）

---

## M8 — IM 集成

### 8.1 文档链接预览

**后端接口**：

| 方法 | 路径 | 说明 |
|------|------|------|
| `GET` | `/api/office/docs/{id}/preview` | 返回文档元数据（标题、摘要、图标、更新时间、创建者） |

**响应格式**：

```json
{
  "id": "doc_id",
  "title": "文档标题",
  "icon": "📄",
  "excerpt": "纯文本前 200 字…",
  "updated_at": "2026-07-23T12:00:00Z",
  "creator": { "id": "user_id", "name": "张三", "avatar": "url" }
}
```

**IM 消息卡片**：
- 发送 IM 消息时检测 `https://host/office/editor/{docId}` 模式
- 调用 preview API 填充卡片
- 卡片渲染：icon + title + excerpt + 更新时间

### 8.2 @提及系统

**ProseMirror mention node**：

```typescript
// Schema
mention: {
  attrs: { id: string, type: 'user'|'doc'|'date', label: string },
  inline: true,
  group: 'inline',
  atom: true,
  toDOM: (node) => ['span', { class: 'mention mention--user' }, '@' + node.attrs.label]
}
```

**交互流程**：
1. 输入 `@` → `useMention` composable 检测触发
2. 弹出 `MentionPopup.vue` 搜索浮层
3. 搜索源：
   - `@user` → `GET /api/office/mentions/users?q=keyword`（搜索当前租户用户）
   - `@doc` → `GET /api/office/mentions/docs?q=keyword&space_id=xxx`
   - `@date` → 日期选择器（today/tomorrow/next Mon 等快捷选项）
4. 选择后插入 mention node（`{ id, type, label }`）
5. 后端存储 `document_mentions` 表（id, doc_id, mentioned_type, mentioned_id, created_at）
6. 保存时扫描文档提取 mentions → 写入 DB → 触发通知

### 8.3 分享到会话

- 编辑器顶栏"共享"按钮下拉新增"分享到会话"
- 弹出会话选择器（复用 IM 会话列表组件）
- 选择会话 → 发送消息卡片 + 可选留言
- 自动添加文档权限（如接收者无权限，加 commenter 角色）

### 8.4 通知联动

- `document_mentions` 表记录 @ 提及
- 文档保存时检测新增 mentions → 调用 `im/notification` 模块发送通知
- 通知类型：`mention`（@提及）/ `share`（分享到会话）/ `comment`（评论回复）

### 8.5 TaskItem ↔ Todo 联动

- `sdk/` 扩展 `BizOffice` trait：`on_task_checked(doc_id, task_item_id, checked)`
- `backend/todo/` 模块暴露 todo CRUD API
- 前端：taskItem checkbox 切换时检测是否有对应 todo（根据 taskItem 的 `todo_id` attr）
- 有 → 同步状态；无 → 创建 todo 并写入 `todo_id`

**数据库扩展**：`taskItem` node 增加 `todo_id` 属性（optional string）

---

## M9 — 富组件与体验

### 9.1 结构化组件

所有结构化组件作为 ProseMirror node 实现，统一放在 `frontend/src/views/office/nodes/` 目录。

#### Toggle（折叠段）

```typescript
// Schema
toggle: {
  content: 'block+',
  attrs: { open: { default: true } },
  toDOM: (node) => ['div', { class: 'toggle', 'data-open': node.attrs.open },
    ['div', { class: 'toggle-title', contenteditable: 'true' }],
    ['div', { class: 'toggle-body' }, 0]
  ]
}
```

- 标题行点击切换 `open` 属性
- 箭头图标使用 CSS `::before`

#### Callout（提示框）

```typescript
callout: {
  content: 'block+',
  attrs: { type: { default: 'info' } },  // info | warn | error | success
  toDOM: (node) => ['div', { class: `callout callout--${node.attrs.type}` }, 0]
}
```

- 4 种类型各带 icon + 背景色（CSS 控制）
- 通过 SlashMenu 插入，默认 info

#### Columns（分栏）

```typescript
columns: {
  content: 'column+',
  toDOM: () => ['div', { class: 'columns' }, 0]
},
column: {
  content: 'block+',
  attrs: { width: { default: 50 } },  // 百分比
  toDOM: (node) => ['div', { class: 'column', style: `flex: ${node.attrs.width}` }, 0]
}
```

- 2/3 栏通过 slash 菜单选择
- 宽高比通过拖拽调整（后续）

### 9.2 富媒体

#### 视频嵌入

```typescript
video: {
  attrs: { src, type: 'internal'|'youtube'|'bilibili', width?, height? },
  group: 'block',
  atom: true,
  toDOM: (node) => embed iframe 或 <video> tag
}
```

- 内部视频：复用 `store` 模块上传 → `<video controls>`
- 外链：youtube/bilibili 自动识别 → 嵌入 iframe

#### 音频嵌入

```typescript
audio: {
  attrs: { src },
  group: 'block',
  atom: true,
  toDOM: () => ['audio', { controls: true }]
}
```

#### 附件

```typescript
fileAttachment: {
  attrs: { file_id, name, size, mime_type },
  group: 'block',
  atom: true,
  toDOM: (node) => 文件卡片渲染
}
```

#### 外链预览（unfurl）

- SlashMenu 粘贴 URL → 后端 `GET /api/unfurl?url=xxx`
- 抓取 og:title / og:image / og:description
- 渲染为 link-preview 卡片 node

### 9.3 公式与图表

#### KaTeX

依赖：`katex` npm 包，CSS 独立加载

```typescript
// inline
math_inline: {
  group: 'inline',
  inline: true,
  atom: true,
  attrs: { tex: '' },
  toDOM: (node) => {
    const el = document.createElement('span')
    katex.render(node.attrs.tex, el, { throwOnError: false })
    return el
  }
}

// block
math_display: {
  group: 'block',
  atom: true,
  attrs: { tex: '' },
  toDOM: (node) => {
    const el = document.createElement('div')
    katex.render(node.attrs.tex, el, { displayMode: true, throwOnError: false })
    return el
  }
}
```

- SlashMenu 添加"公式"入口 → 弹出 KaTeX 编辑器（简易输入框 + 实时预览）
- 输入 `$$...$$` 自动转换（inputrule）

#### Mermaid

```typescript
mermaid: {
  group: 'block',
  atom: true,
  attrs: { diagram: '', type: 'flowchart' },
  toDOM: async (node) => {
    const { svg } = await mermaid.render('mermaid-id', node.attrs.diagram)
    return div with svg
  }
}
```

- 渲染使用 `mermaid` npm 包（`mermaid.render()`）
- 编辑模式显示源码（textarea）+ 预览按钮
- 只读模式直接渲染 SVG

### 9.4 代码块增强

- **语言选择器**：`<select>` 浮在代码块右上角，60+ 常用语言
- **语法高亮**：`highlight.js` 按语言动态加载
- **复制按钮**：代码块 hover 右上角显示复制图标
- **行号**：CSS `counter` + `::before` 每行编号

**数据结构**（已有 `codeBlock.language` attr，仅需补 UI）：

```typescript
// 新增语言列表自动完成
const LANGUAGES = ['javascript', 'typescript', 'python', 'rust', 'go', ...]
```

### 9.5 目录与导航（Outline）

**Outline 组件**（右侧固定面板）：
- 编辑器 Plugin 实时扫描 `heading` 节点
- 渲染为嵌套列表（h1→h6 缩进）
- 点击滚动到对应标题（`editorView.dispatch(scrollIntoView)`）
- 高亮当前可见标题（基于 IntersectionObserver）

**组件：`Outline.vue`**
```
┌─────────────┐
│  目录        │
│  ├ 标题 1    │ ← 高亮
│  │ ├ 标题 2  │
│  └ 标题 1    │
└─────────────┘
```

- 宽度 220px，`position: sticky; top: 0`
- 仅在编辑器页面右侧显示（`EditorView` 中条件渲染）

### 9.6 表格增强

| 功能 | 实现方式 |
|------|---------|
| 右键菜单 | `TableContextMenu.vue` — 监听 `contextmenu` 事件，检测是否在表格内 |
| 插入行/列 | `prosemirror-tables` 命令 `addRowBefore/After`, `addColBefore/After` |
| 删除行/列 | `deleteRow`, `deleteCol` 命令 |
| 单元格背景色 | 扩展 `table_cell` attrs `background: string` |
| 对齐方式 | 扩展 `table_cell` attrs `align: 'left'|'center'|'right'` |
| 排序/筛选 | 简化版：点击表头排序（纯前端，当前数据列排序） |

### 9.7 表情反应

```sql
CREATE TABLE document_reactions (
    id BIGINT PRIMARY KEY,
    document_id BIGINT NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL,
    emoji VARCHAR(50) NOT NULL,            -- unicode emoji 或 custom
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (document_id, user_id, emoji)
);
```

- 文档底部显示反应栏（👍 5, ❤️ 3, 😄 2）
- 点击切换自己是否已反应
- 择 Emoji 选择器添加更多反应

---

## 附录：实施顺序建议

```
Phase B 整体并行策略（按依赖排列）：

M5 (版本历史) ─── 无外部依赖，可先启动
                   │
M7 (知识库层) ─── 无外部依赖，可先启动
                   │
M9 (富组件) ───── 无外部依赖，可先启动（与 M5/M7 并行）
                   │
M8 (IM 集成) ──── 依赖 M7（权限继承）+ 后端 IM 模块
                   │
M6 (多端支持) ──── 依赖 M4（权限）+ 各里程碑稳定（最后启动）

推荐实施顺序：
  Track 1: M9 (富组件) → 贯穿前端改善
  Track 2: M7 (知识库) → M8 (IM 集成)
  Track 3: M5 (版本历史)
  Track 4: M6 (多端支持)
```

### 依赖关系

```
M5 ─── 无外部依赖，仅需 Yjs 存储层（已有）
M9 ─── 无外部依赖，仅需 ProseMirror Schema（M1 已有）
M7 ─── 依赖 M3（space/文档管理）+ M4（权限继承）
M8 ─── 依赖 M7（知识库作为组织单元）+ backend/im 模块
M6 ─── 依赖 Phase A 全部 + Flutter SDK 就绪
```
