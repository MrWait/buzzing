# M1 — 编辑器完善 · 详细设计

> 状态：**主体已完成 ✅**（详见 [todo.md](./todo.md)），保留本文档作为设计参考。
> 上级方案：[office_pa_design.md](./office_pa_design.md)。

## 1. 概述

M1 的目标是把编辑器从"基础可写"提升到"可编辑结构化文档"，达到主流富文本编辑器水准。所有实现均在前端（`frontend/src/views/office/`）完成，后端复用 `store` 模块的文件上传能力和已有的 `PATCH /api/office/docs/{id}` 更新接口。

### 交互形态选择

M1 编辑器采用 **纯浮动交互** 模式（Notion / Craft / 飞书文档同款）：

- **FloatingToolbar** — 选中文本时在选区上方浮出的格式工具条（marks + 标题 + 引用 + 链接 + 清除格式）
- **SlashMenu** — 在块起始输入 `/` 唤起，用于插入块级元素（列表、代码块、表格、分割线、图片等）
- **LinkDialog / ImageUpload** — 由 FloatingToolbar / SlashMenu / 快捷键触发的辅助弹层

**不设固定顶部工具栏**，让编辑区更沉浸；工具栏组件（`Toolbar.vue` + `ToolbarButton/Divider/Dropdown`）作为**可复用的原子组件保留**，供后续在需要固定栏的场景（如 comments、只读注解视图）复用。

### 范围

| 模块 | 变更 |
|------|------|
| 前端 | 扩展 Schema，新增 TitleBar / FloatingToolbar / SlashMenu / LinkDialog / ImageUpload |
| 后端 | 复用 `POST /api/files/upload` 与 `PATCH /api/office/docs/{id}` |
| 数据库 | 无变更 |

---

## 2. 组件架构

### 2.1 组件树

```
EditorView.vue
├── TitleBar.vue            [新增] 文档标题可编辑区域
├── ProseEditor.vue         [重写] 挂载 ProseMirror + Yjs
│   ├── FloatingToolbar.vue [新增] 选区上方浮动格式条（M1 主交互入口）
│   ├── SlashMenu.vue       [新增] 斜杠命令弹层（M1 块级插入入口）
│   ├── LinkDialog.vue      [新增] 链接编辑弹窗
│   └── ImageUpload.vue     [新增] 图片上传（隐藏 input + 进度）
└── Collaborators.vue       [保留] 协作者头像

保留但未挂载（原子组件，供后续复用）：
  Toolbar.vue / ToolbarButton.vue / ToolbarDivider.vue / ToolbarDropdown.vue
```

### 2.2 组件职责

| 组件 | 输入 (Props / Inject) | 输出 |
|------|----------------------|------|
| TitleBar | `docId` | debounce 500ms → PATCH `/api/office/docs/{id}` |
| FloatingToolbar | `editorView` inject | 选区变化时浮现，执行 ProseMirror 命令 |
| LinkDialog | `open`, `editorView` inject | 插入 / 编辑 / 移除 link mark |
| ImageUpload | `editorView` inject | 上传后 dispatch insertImage |
| SlashMenu | `editorView` / `schema` inject | 触发 setBlockType / wrapIn / insertNode 等命令 |
| ProseEditor | `yjs-type`, `yjs-provider` inject | provide `editorView`, `schema`；管理 LinkDialog 状态 |

### 2.3 composable 划分

| composable | 职责 |
|-----------|------|
| `useEditorSchema.ts` | 定义 Schema、装配所有 plugin、`mount` / `destroy` |
| `useToolbarState.ts` | 通过 ProseMirror plugin 追踪当前选区 marks / node / 浮动条位置，提供响应式 `activeMarks` / `activeNode` / `headingLevel` / `showFloating` / `floatingLeft` / `floatingTop` |
| `useSlashMenu.ts` | 斜杠菜单 plugin：监听 `/`、维护 filter、暴露 `visible/position/execute` |

---

## 3. ProseMirror Schema 设计

### 3.1 目标 Schema（M1 完成态）

```ts
new Schema({
  nodes: {
    doc:              { content: 'block+' },
    paragraph:        { content: 'inline*', group: 'block' },
    text:             { group: 'inline' },
    heading:          { attrs: { level: 1 }, content: 'inline*', group: 'block' },
    bulletList:       { content: 'listItem+', group: 'block' },
    orderedList:      { content: 'listItem+', group: 'block', attrs: { order: 1 } },
    listItem:         { content: 'paragraph block*' },
    taskList:         { content: 'taskItem+', group: 'block' },              // 新增
    taskItem:         { content: 'paragraph block*', attrs: { checked: false } },// 新增
    codeBlock:        { content: 'text*', marks: '', group: 'block',          // 新增
                        attrs: { language: '' }, code: true },
    blockquote:       { content: 'block+', group: 'block' },
    horizontalRule:   { group: 'block' },
    image:            { inline: true, attrs: { src, alt, title }, group: 'inline' },
    hardBreak:        { inline: true, group: 'inline' },
    ...tableNodes({ tableGroup: 'block', cellContent: 'block+' }),            // prosemirror-tables
  },
  marks: {
    link:       { attrs: { href, title } },
    em:         {},
    strong:     {},
    code:       {},
    underline:  {},   // 新增
    strike:     {},   // 新增
  },
})
```

### 3.2 节点/标记设计要点

#### taskList / taskItem
- 渲染 `<ul data-type="taskList"><li data-type="taskItem" data-checked>` ；CSS 用 `::before` 画 checkbox
- 点击 checkbox 区域（左侧 28px）→ 通过 `taskItemClickHandler` plugin 切换 `checked`
- 输入 `[] ` / `[x] ` 自动转换（`inputRules`）
- 空 taskItem 按 Enter → 退化为 paragraph
- Tab / Shift-Tab → `sinkListItem` / `liftListItem`

#### codeBlock
- 语言属性 `language` 保留，M1 不接入语法高亮（推迟至 M9）
- 快捷键 `Ctrl+Shift+C` → `setBlockType(codeBlock)`

#### table
- 依赖 `prosemirror-tables` 提供的 `tableNodes` / `tableEditing` / `columnResizing`
- Tab 在表格中改为 `goToNextCell`
- 增删行列命令在 M9 阶段补齐（右键菜单）

#### underline / strike marks
- 渲染 `<u>` / `<s>`
- 快捷键 `Ctrl+U` / `Ctrl+Shift+S`

---

## 4. 数据流

### 4.1 浮动工具栏 & 选区

```
用户改变选区
  → ProseMirror plugin (useToolbarState) 触发 view.update
  → 计算 selection.empty / coordsAtPos(from) / coordsAtPos(to)
  → 更新响应式 showFloating / floatingLeft / floatingTop
  → FloatingToolbar 通过 Teleport 渲染到 body，绝对定位到选区上方
  → 用户点击按钮 → 执行 ProseMirror command → 派发到 Yjs → 同步其他协作者
  → activeMarks / activeNode 响应式更新，按钮 active 态跟随
```

### 4.2 标题自动保存

```
用户输入 → TitleBar input event → title ref 更新
  → debounce 500ms → PATCH /api/office/docs/{id} { title }
  → 失败静默（下次进入编辑器会重新拉取）
```

### 4.3 图片上传

```
触发方式（三种）：
  1. 粘贴：editor.dom paste event → 检测 image/* → 调用 uploadFile
  2. 拖拽：editor.dom drop event  → 检测 image/* → 调用 uploadFile
  3. 斜杠菜单：/ → "图片" → 触发 ImageUpload.trigger() 打开系统 file picker

上传流程：
  校验类型 (png/jpeg/webp/gif) 和大小 (< 10MB)
  → FormData.append('file', file)
  → POST /api/files/upload  (复用 store 模块)
  → 返回 { id, url, mime_type, ... }
  → editorView.dispatch(tr.replaceSelectionWith(image.create({ src: url })))
  → ySyncPlugin 自动把 image node 同步给协作者
```

### 4.4 链接

```
触发方式：
  1. FloatingToolbar 的链接按钮 → emit link → ProseEditor 打开 LinkDialog
  2. Ctrl+K 快捷键 → EditorView 层拦截 → 打开 LinkDialog
  3. 斜杠菜单：/ → 链接（可选）

LinkDialog 逻辑：
  打开时检测当前选区是否已有 link mark
    有 → 编辑模式（预填 href/text，显示"移除链接"按钮）
    无 → 新增模式（若选中文本，预填 text）
  确认 → dispatch removeMark + addMark
  移除 → dispatch removeMark
```

### 4.5 斜杠命令

```
用户在块起始位置输入 '/'
  → useSlashMenu plugin handleTextInput 拦截，设置 active=true
  → SlashMenu 组件监听 plugin state 显示菜单，位置来自 coordsAtPos
  → 用户输入过滤词 (handleTextInput 累加 filter)
  → ↑↓ 选择，Enter 执行选中项的 command
  → Esc / Backspace(空 filter) 关闭
```

---

## 5. 后端变更

M1 阶段**无后端代码变更**，仅复用：

| 接口 | 说明 |
|------|------|
| `GET /api/office/docs/{id}` | 文档元数据查询 |
| `PATCH /api/office/docs/{id}` | 更新标题 |
| `POST /api/files/upload` | 文件上传（store 模块） |
| `GET /api/files/{id}` | 文件下载 / inline 预览 |
| `GET /office/ws/{doc_id}` | Yjs 协作 WS |

---

## 6. 依赖

| 包 | 用途 |
|----|------|
| `prosemirror-tables` | 表格节点 + 命令 |
| `prosemirror-inputrules` | 任务列表 `[] ` 输入规则 |
| `@lucide/vue` | 工具栏图标 |
| `highlight.js` | 代码块语法高亮（M9 引入，M1 未启用） |

---

## 7. 文件变更清单

### 新增（M1 主交互）

| 文件 | 说明 |
|------|------|
| `frontend/src/views/office/components/TitleBar.vue` | 标题编辑 |
| `frontend/src/views/office/components/FloatingToolbar.vue` | 选区浮动格式条（M1 主入口） |
| `frontend/src/views/office/components/LinkDialog.vue` | 链接弹窗 |
| `frontend/src/views/office/components/ImageUpload.vue` | 图片上传 |
| `frontend/src/views/office/components/SlashMenu.vue` | 斜杠菜单（块级插入） |
| `frontend/src/views/office/composables/useEditorSchema.ts` | Schema + plugins |
| `frontend/src/views/office/composables/useToolbarState.ts` | 工具栏状态 plugin |
| `frontend/src/views/office/composables/useSlashMenu.ts` | 斜杠菜单 plugin |

### 新增（原子组件，M1 未挂载，供后续复用）

| 文件 | 说明 |
|------|------|
| `frontend/src/views/office/components/Toolbar.vue` | 通用工具栏容器 |
| `frontend/src/views/office/components/ToolbarButton.vue` | 原子按钮 |
| `frontend/src/views/office/components/ToolbarDivider.vue` | 分隔线 |
| `frontend/src/views/office/components/ToolbarDropdown.vue` | 下拉选择 |

### 修改

| 文件 | 变更内容 |
|------|---------|
| `frontend/src/views/office/EditorView.vue` | 集成 TitleBar + provide yjs-type/provider；拦截 Ctrl+K 传递给 ProseEditor |
| `frontend/src/views/office/components/ProseEditor.vue` | 通过 `useEditorSchema` 挂载 + provide editorView/schema，接入 FloatingToolbar / SlashMenu / LinkDialog / ImageUpload |
| `frontend/src/styles/editor.css` | 增加表格 / 任务列表 / 代码块 / 暗色代码块 / 下划线 / 删除线 / 浮动条位置样式 |

---

## 8. 快捷键映射

| 快捷键 | 功能 | 实现 |
|--------|------|------|
| `Ctrl+B` | 加粗 | ProseMirror built-in |
| `Ctrl+I` | 斜体 | ProseMirror built-in |
| `Ctrl+U` | 下划线 | 自定义 keymap → `toggleMark(underline)` |
| `Ctrl+Shift+S` | 删除线 | 自定义 keymap → `toggleMark(strike)` |
| `Ctrl+K` | 插入链接 | EditorView 键盘捕获 → 打开 LinkDialog |
| `Ctrl+Shift+C` | 代码块 | 自定义 keymap → `setBlockType(codeBlock)` |
| `Ctrl+Z / Ctrl+Y` | 撤销 / 重做 | y-prosemirror `yUndoPlugin` |
| `Tab` | 缩进列表项 / 跳转表格单元格 | 自定义 keymap（`sinkListItem` + `goToNextCell`） |
| `Shift+Tab` | 反缩进 / 反跳转 | 自定义 keymap |
| `Enter` | 空 taskItem 退化为段落 | 自定义 keymap |
| `/` | 斜杠菜单 | `useSlashMenu` plugin |

---

## 9. 样式规范

### 9.1 浮动工具栏（M1 主交互）
- 通过 `<Teleport to="body">` 渲染，绝对定位在选区上方约 48px
- 圆角 8px + `box-shadow: 0 4px 16px rgba(0,0,0,0.15)`
- 按钮 28×28px，圆角 4px
- 分隔线 1px × 20px
- Active：背景 `#e3f2fd` / 文字 `#1565c0`
- Hover：背景 `#f0f0f0`
- `useToolbarState.estFloatPos` 计算位置，避开左右边缘（padding 12px）

### 9.2 标题编辑
- 字号 24px / 字重 600
- 无边框，hover 显示浅色底边
- 占位符 "无标题"

### 9.3 新增元素样式（`editor.css`）

| 元素 | 样式要点 |
|------|--------|
| 表格 | `border-collapse: collapse`；单元格边框 `#ccc`；header 背景 `#f5f5f5`；`column-resize-handle` 蓝色高亮 |
| 任务列表 | 列表无点，`::before` 画 18×18 checkbox；`data-checked=true` 时填充 `#1565c0` + 白色对号 + 文字半透明删除线 |
| 代码块 | 暗色 `#1e1e1e` / 文字 `#d4d4d4`；等宽字体；圆角 6px |
| 图片 | `max-width: 100%`；`cursor: pointer` |
| 链接 | `color: #1565c0`；下划线 |
| 斜杠菜单 | 圆角 8px；`box-shadow: 0 4px 12px rgba(0,0,0,0.15)`；每项 32px 高 |
| 协作者光标 | 左侧 2px 竖线；顶部小名字标签（浮动） |

---

## 10. 实施顺序（回顾）

M1 已按以下顺序完成实施：

1. Schema 抽取 → `useEditorSchema.ts`
2. 原子组件 `ToolbarButton / Divider / Dropdown`（作为通用基础，M1 未挂载）
3. TitleBar 独立组件 + PATCH 集成
4. LinkDialog + Ctrl+K 快捷键（EditorView 层拦截，转发给 ProseEditor 打开 dialog）
5. ImageUpload + 粘贴 / 拖拽 handler
6. 任务列表 + 代码块（Schema + Command + CSS）
7. Table 集成（tableNodes + tableEditing + columnResizing）
8. 快捷键 keymap（下划线 / 删除线 / 代码块 / Tab / Enter）
9. SlashMenu + useSlashMenu plugin
10. FloatingToolbar 作为 M1 主交互入口（marks + 标题 + 引用 + 链接 + 清除格式）
11. `editor.css` 样式统一

---

## 11. 遗留 / 后续处理

| 项 | 归属 |
|----|------|
| 代码块语言下拉 + 语法高亮 | M9（富组件） |
| 表格右键菜单（增删行列） | M9 |
| 标题编辑成功提示 / 冲突恢复 | M2（保存状态指示） |
| 图片点击查看原图 / 拖拽调整大小 | M9 |
| 中文输入法下 `/` 触发斜杠菜单的兼容 | 若有反馈再优化 |

---

## 12. 验收清单

M1 完成的核对项（详见 [todo.md](./todo.md)）：

- [x] 所有工具栏按钮切换格式正常（active 态跟随选区同步）
- [x] 标题编辑保存生效
- [x] 图片上传成功并插入编辑器
- [x] 链接插入 / 编辑 / 移除正常
- [x] 任务列表创建、checkbox 切换、Enter 行为正常
- [x] 代码块创建正常
- [x] 表格创建、Tab 跳转正常
- [x] 所有快捷键按设计工作
- [x] 斜杠 `/` 弹出菜单，可切换任意节点类型
- [x] 编辑器样式统一
- [ ] 协作同步正常（待 M2 联调验证）
- [ ] 后端 API 无性能退化（待 M12 自动化测试）
