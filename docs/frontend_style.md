# 前端 UI 设计指南 (Vue3 SPA)

## 设计原则

1. **一致** — 所有页面共享同一套色彩、间距、字体、组件样式
2. **简洁** — 少即是多，每屏聚焦一个核心操作
3. **桌面优先** — 目前仅支持桌面端（宽屏），后续扩展响应式
4. **内容为王** — 编辑器/文档内容是核心，UI 不抢戏

---

## 1. 设计令牌 (Design Tokens)

所有视觉属性使用固定的令牌值，不允许硬编码。

### 1.1 颜色

#### 主色调

| 令牌 | 值 | 用途 |
|------|-----|------|
| `--color-primary` | `#1a1a2e` | 顶栏背景、主要按钮、卡片强调色 |
| `--color-primary-hover` | `#16213e` | 主要按钮 hover |
| `--color-primary-light` | `#e3f2fd` | 选中项背景、图标背景 |

#### 中性色

| 令牌 | 值 | 用途 |
|------|-----|------|
| `--color-bg` | `#ffffff` | 页面背景、卡片背景 |
| `--color-bg-secondary` | `#f5f5f5` | 认证页面背景、hover 态 |
| `--color-bg-tertiary` | `#fafafa` | 工具栏背景 |
| `--color-border` | `#e0e0e0` | 卡片/侧栏/分隔线边框 |
| `--color-border-strong` | `#ddd` | 输入框边框、引用线 |
| `--color-border-dashed` | `#ccc` | 新建按钮虚线 |

#### 文字色

| 令牌 | 值 | 用途 |
|------|-----|------|
| `--color-text` | `#333333` | 正文 |
| `--color-text-secondary` | `#666666` | 辅助文字、侧栏标题 |
| `--color-text-muted` | `#999999` | 时间戳、描述、空状态 |
| `--color-text-placeholder` | `#bbbbbb` | 编辑器占位符 |
| `--color-text-on-primary` | `#ffffff` | 深色背景上的文字 |

#### 功能色

| 令牌 | 值 | 用途 |
|------|-----|------|
| `--color-error` | `#e53935` | 错误提示 |
| `--color-link` | `#1565c0` | 链接文字 |
| `--color-cursor` | `#4080ff` | 协作者光标 |

#### 模块标志色（Hub 卡片）

| 模块 | 图标背景 | 图标色 |
|------|---------|-------|
| 办公文档 | `#e3f2fd` | `#1565c0` |
| 日历 | `#fff3e0` | `#e65100` |
| 任务 | `#e8f5e9` | `#2e7d32` |

### 1.2 字体

| 令牌 | 值 |
|------|-----|
| `--font-family` | `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif` |
| `--font-family-mono` | `'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace` |
| `--font-size-base` | `14px` |
| `--font-size-xs` | `12px` |
| `--font-size-sm` | `13px` |
| `--font-size-lg` | `15px` |
| `--font-size-xl` | `16px` |
| `--font-size-h1` | `1.8em` |
| `--font-size-h2` | `1.5em` |
| `--font-size-h3` | `1.25em` |
| `--line-height` | `1.5` |
| `--font-weight-normal` | `400` |
| `--font-weight-medium` | `500` |
| `--font-weight-semibold` | `600` |

### 1.3 间距

使用 4px 为基数的步进系统。

| 令牌 | 值 |
|------|-----|
| `--space-1` | `4px` |
| `--space-2` | `8px` |
| `--space-3` | `12px` |
| `--space-4` | `16px` |
| `--space-5` | `20px` |
| `--space-6` | `24px` |
| `--space-8` | `32px` |
| `--space-10` | `40px` |

常见组合：

```
卡片内边距:  16px (--space-4)
列表项内边距: 12px 16px (--space-3 --space-4)
页面内边距:  24px (--space-6)
组件间距:    12px 或 16px gap
```

### 1.4 圆角

| 令牌 | 值 | 用途 |
|------|-----|------|
| `--radius-sm` | `4px` | 按钮、输入框 |
| `--radius-md` | `8px` | 卡片 |
| `--radius-lg` | `12px` | 大卡片 |
| `--radius-full` | `50%` | 头像 |

### 1.5 阴影

| 令牌 | 值 | 用途 |
|------|-----|------|
| `--shadow-card` | `0 2px 12px rgba(0,0,0,0.08)` | 普通卡片 |
| `--shadow-card-hover` | `0 4px 12px rgba(0,0,0,0.08)` | 卡片 hover |

### 1.6 过渡

| 令牌 | 值 |
|------|-----|
| `--transition-fast` | `0.15s ease` |
| `--transition-normal` | `0.2s ease` |

---

## 2. CSS 变量使用（推荐）

虽然当前项目未使用 CSS 变量，所有**新增页面和组件**应统一在 `src/styles/variables.css` 中声明上述令牌，并在组件中引用：

```css
/* ✅ 推荐 */
.sidebar-heading {
  color: var(--color-text-secondary);
  font-size: var(--font-size-xs);
  padding: 0 var(--space-4) var(--space-2);
}

/* ❌ 避免 */
.sidebar-heading {
  color: #666;
  font-size: 12px;
  padding: 0 16px 8px;
}
```

### 全局样式文件结构

```
src/styles/
├── variables.css     # CSS 自定义属性（所有设计令牌）
├── reset.css         # 全局 reset（已存在，可合并 global.css）
└── global.css        # 全局样式（保持最小）
```

在 `main.ts` 中引入：

```ts
import './styles/variables.css'
import './styles/global.css'
```

---

## 3. 布局系统

### 3.1 页面层级

```
App.vue
 └── RouterView
      ├── AuthLayout      (登录、注册等)
      ├── HubLayout       (Hub 主页)
      ├── ModuleLayout    (模块页面: /office, /calendar, ...)
      └── FullscreenLayout (全屏页面)
```

### 3.2 AuthLayout

- 居中单列布局
- 内容最大宽度 `360px`
- 背景色 `var(--color-bg-secondary)`
- 用于登录、注册、找回密码等

```
┌─────────────────────────────────────┐
│                                     │
│          ┌──────────────┐          │
│          │  表单/内容    │          │
│          │  max-width    │          │
│          │  360px        │          │
│          └──────────────┘          │
│                                     │
└─────────────────────────────────────┘
```

### 3.3 HubLayout

- 顶部 48px 深色导航栏 + 下方主区域
- 主区域居中，最大宽度 `640px`
- 用于功能选择页

```
┌─────────────────────────────────────┐
│  Logo                   用户名 退出  │ ← 48px topbar
├─────────────────────────────────────┤
│                                     │
│          ┌─────────────────┐        │
│          │  功能卡片网格    │        │
│          │  max-width: 640 │        │
│          └─────────────────┘        │
│                                     │
└─────────────────────────────────────┘
```

### 3.4 ModuleLayout

- 顶部 48px 深色导航栏（含模块名称 + 面包屑）
- 下方主区域：**侧栏 + 内容区** （两栏）

```
┌─────────────────────────────────────┐
│  Logo   模块名         用户名 退出   │ ← 48px topbar
├──────────┬──────────────────────────┤
│ 侧栏     │  内容区                   │
│ 220px    │  flex: 1                 │
│          │                          │
│ 列表/树  │  详情/编辑/列表           │
│          │                          │
└──────────┴──────────────────────────┘
```

### 3.5 FullscreenLayout

- 100vh 全屏
- 无导航栏
- 用于编辑器等沉浸式场景

### 3.6 布局约束

| 布局 | 最大宽度 | 侧栏宽度 | 响应式 |
|------|---------|---------|--------|
| AuthLayout | `360px` | — | 居中 |
| HubLayout | `640px` | — | 居中 |
| ModuleLayout | 100% | `220px` | 侧栏可折叠（待实现） |
| FullscreenLayout | 100% | — | — |

---

## 4. 通用组件模式

> 以下组件尚无独立文件，新页面遇到时按此模式实现。

### 4.1 按钮

| 类型 | 样式 | 用途 |
|------|------|------|
| 主要按钮 (Primary) | 深色背景 `#1a1a2e`，白字，圆角 4px | 主要操作（登录、确认） |
| 文字按钮 (Text) | 无边框，主色或灰色文字 | 次要操作（取消、删除） |
| 虚线按钮 (Dashed) | 虚线边框 `1px dashed #ccc`，圆角 4px | 新建/添加（如"新建空间"） |

```html
<!-- 主要按钮 -->
<button class="btn-primary">确认</button>

<!-- 文字按钮 -->
<button class="btn-text">取消</button>

<!-- 虚线按钮 -->
<button class="btn-dashed">+ 新建文档</button>
```

```css
.btn-primary {
  background: var(--color-primary, #1a1a2e);
  color: #fff;
  border: none;
  border-radius: var(--radius-sm, 4px);
  padding: 8px 16px;
  cursor: pointer;
  font-size: var(--font-size-base, 14px);
}
.btn-primary:hover {
  background: var(--color-primary-hover, #16213e);
}

.btn-text {
  background: none;
  border: none;
  color: var(--color-text-secondary, #666);
  cursor: pointer;
  padding: 4px 8px;
  font-size: var(--font-size-base, 14px);
}
.btn-text:hover {
  color: var(--color-primary, #1a1a2e);
}

.btn-dashed {
  background: none;
  border: 1px dashed var(--color-border-dashed, #ccc);
  border-radius: var(--radius-sm, 4px);
  padding: 8px 16px;
  cursor: pointer;
  color: var(--color-text-secondary, #666);
  font-size: var(--font-size-base, 14px);
  transition: border-color var(--transition-normal, 0.2s);
}
.btn-dashed:hover {
  border-color: var(--color-primary, #1a1a2e);
  color: var(--color-primary, #1a1a2e);
}
```

### 4.2 输入框

```html
<input class="input" type="text" placeholder="请输入..." />
```

```css
.input {
  width: 100%;
  border: 1px solid var(--color-border-strong, #ddd);
  border-radius: var(--radius-sm, 4px);
  padding: 8px 12px;
  font-size: var(--font-size-base, 14px);
  outline: none;
  transition: border-color var(--transition-fast, 0.15s);
}
.input:focus {
  border-color: var(--color-primary, #1a1a2e);
}
```

### 4.3 卡片

```html
<div class="card">
  <!-- 内容 -->
</div>
```

```css
.card {
  background: var(--color-bg, #fff);
  border: 1px solid var(--color-border, #e0e0e0);
  border-radius: var(--radius-md, 8px);
  padding: var(--space-4, 16px);
  transition: box-shadow var(--transition-normal, 0.2s),
              border-color var(--transition-normal, 0.2s);
}
.card:hover {
  box-shadow: var(--shadow-card-hover, 0 4px 12px rgba(0,0,0,0.08));
}
```

### 4.4 列表行

```html
<div class="list-item" :class="{ active: isSelected }">
  <span class="list-item__name">项目名称</span>
  <span class="list-item__meta">辅助信息</span>
</div>
```

```css
.list-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 16px;
  cursor: pointer;
  border-radius: var(--radius-sm, 4px);
  transition: background var(--transition-fast, 0.15s);
}
.list-item:hover {
  background: var(--color-bg-secondary, #f5f5f5);
}
.list-item.active {
  background: var(--color-primary-light, #e3f2fd);
  color: var(--color-link, #1565c0);
}
.list-item__name {
  font-size: var(--font-size-base, 14px);
}
.list-item__meta {
  font-size: var(--font-size-xs, 12px);
  color: var(--color-text-muted, #999);
}
```

### 4.5 分隔线

```html
<div class="divider"></div>
```

```css
.divider {
  height: 1px;
  background: var(--color-border, #e0e0e0);
  margin: 0;
}
```

### 4.6 空状态

```html
<div class="empty-state">
  <p class="empty-state__text">暂无文档</p>
</div>
```

```css
.empty-state {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 32px;
}
.empty-state__text {
  font-size: var(--font-size-base, 14px);
  color: var(--color-text-muted, #999);
}
```

### 4.7 加载中

```html
<div class="loading">
  <span class="loading__spinner"></span>
</div>
```

```css
.loading {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 32px;
}
```

暂时使用 CSS spin 动画。后续按需引入 spinner 组件。

### 4.8 页面头部标题

```html
<div class="page-header">
  <h2 class="page-header__title">空间名称</h2>
  <button class="btn-primary">新建</button>
</div>
```

```css
.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px;
}
.page-header__title {
  font-size: var(--font-size-base, 14px);
  font-weight: var(--font-weight-semibold, 600);
}
```

### 4.9 Dialog / 模态框

```html
<div class="dialog-overlay" @click.self="close">
  <div class="dialog">
    <h3 class="dialog__title">标题</h3>
    <div class="dialog__body">内容</div>
    <div class="dialog__footer">
      <button class="btn-text" @click="close">取消</button>
      <button class="btn-primary" @click="confirm">确认</button>
    </div>
  </div>
</div>
```

```css
.dialog-overlay {
  position: fixed; inset: 0;
  background: rgba(0,0,0,0.3);
  display: flex; align-items: center; justify-content: center;
  z-index: 1000;
}
.dialog {
  background: #fff;
  border-radius: var(--radius-md, 8px);
  padding: 24px;
  min-width: 360px;
  max-width: 480px;
}
.dialog__title {
  font-size: 15px;
  font-weight: var(--font-weight-semibold, 600);
  margin-bottom: 16px;
}
.dialog__body {
  margin-bottom: 24px;
}
.dialog__footer {
  display: flex; justify-content: flex-end; gap: 12px;
}
```

---

## 5. 侧栏模式

### 5.1 侧栏约定

| 属性 | 值 |
|------|-----|
| 宽度 | `220px` |
| 背景色 | `var(--color-bg, #fff)` |
| 右边框 | `1px solid var(--color-border, #e0e0e0)` |
| 内边距 | 顶级 `16px`，列表项 `8px 16px` |

### 5.2 侧栏内容结构

```
┌──────────────────┐
│ 面板标题          │  ← padding: 16px 16px 8px
├──────────────────┤
│ 搜索框 (可选)     │
├──────────────────┤
│ 导航项 1          │
│ 导航项 2          │
│ 导航项 3 (高亮)   │
│ ...               │
├──────────────────┤
│ 新建按钮          │  ← dashed button
└──────────────────┘
```

### 5.3 侧栏导航项

```css
.sidebar-item {
  display: flex;
  align-items: center;
  padding: 8px 16px;
  cursor: pointer;
  border-radius: var(--radius-sm, 4px);
  font-size: var(--font-size-base, 14px);
  color: var(--color-text, #333);
  transition: background var(--transition-fast);
}
.sidebar-item:hover {
  background: var(--color-bg-secondary, #f5f5f5);
}
.sidebar-item.active {
  background: var(--color-primary-light, #e3f2fd);
  color: var(--color-link, #1565c0);
}
```

---

## 6. 顶栏模板

### 6.1 HubLayout / ModuleLayout 共用结构

```html
<header class="topbar">
  <span class="topbar__logo" @click="goHub">Buzzing</span>
  <span v-if="moduleName" class="topbar__module">{{ moduleName }}</span>
  <div class="topbar__spacer"></div>
  <span class="topbar__user">{{ userName }}</span>
  <button class="topbar__logout">退出</button>
</header>
```

```css
.topbar {
  display: flex;
  align-items: center;
  height: 48px;
  padding: 0 16px;
  background: var(--color-primary, #1a1a2e);
  color: var(--color-text-on-primary, #fff);
  gap: 12px;
  flex-shrink: 0;
}
.topbar__logo {
  font-weight: var(--font-weight-semibold);
  font-size: var(--font-size-xl);
  cursor: pointer;
}
.topbar__module {
  font-size: var(--font-size-sm);
  color: rgba(255,255,255,0.6);
}
.topbar__spacer {
  flex: 1;
}
.topbar__user {
  font-size: var(--font-size-base);
}
.topbar__logout {
  border: 1px solid rgba(255,255,255,0.3);
  border-radius: var(--radius-sm);
  background: none;
  color: inherit;
  padding: 4px 12px;
  cursor: pointer;
  font-size: var(--font-size-base);
}
```

---

## 7. 编辑器相关样式

编辑器相关样式保持独立，放在 `src/styles/editor.css` 中。

不需要改动现有 ProseMirror 样式。新增编辑器组件（工具栏按钮、斜杠菜单等）遵循以下规则：

- 工具栏按钮：`32px` 尺寸，`4px` 圆角，hover 时 `#f0f0f0` 背景
- 工具栏分隔线：`1px solid #e0e0e0`，高度 `20px`
- 斜杠菜单弹出层：`border-radius: 8px`，`box-shadow: 0 4px 12px rgba(0,0,0,0.12)`

---

## 8. 写作规范

### 8.1 文案

- 使用 `src/i18n/` 下的多语言系统，不要硬编码中文或英文
- 按钮文字：2-4 字（"新建"、"删除"、"取消"、"确认"）
- 提示文字：简短明确，句末不句号

### 8.2 类名命名

使用 BEM 风格：

```css
/* Block */
.sidebar { ... }
/* Block__Element */
.sidebar__item { ... }
/* Block--Modifier */
.sidebar__item--active { ... }
```

或使用语义化 class：

```css
.page-header { ... }
.page-header__title { ... }
.doc-list { ... }
.doc-list__item { ... }
```

### 8.3 CSS 顺序约定

按以下顺序声明属性：

```
1. 定位 (position, top, z-index)
2. 盒模型 (display, flex, width, height, padding, margin, border)
3. 背景 (background)
4. 文字 (color, font-*, text-*, line-height)
5. 其他 (border-radius, box-shadow, transition, cursor)
```

---

## 9. 响应式断点（规划）

当前仅支持桌面端。适合添加的断点（后续里程碑实现）：

| 断点 | 宽度 | 行为 |
|------|------|------|
| `--bp-lg` | `≥1200px` | 宽屏，侧栏保持 220px |
| `--bp-md` | `≥768px` | 平板，侧栏可折叠 |
| `--bp-sm` | `<768px` | 手机，单列布局 |

---

## 10. 检查清单（新增页面/组件）

- [ ] 使用 `variables.css` 中的 CSS 变量，无硬编码颜色/间距
- [ ] 遵循卡片的 `border-radius: 8px` / `box-shadow` 约定
- [ ] 使用系统字体栈，无自定义字体引入
- [ ] 顶栏使用深色 `#1a1a2e`
- [ ] 侧栏宽度 `220px`，右侧 `1px solid #e0e0e0` 分隔线
- [ ] 分页/列表空状态使用 `#999` 文字
- [ ] 按钮使用预设样式（Primary / Text / Dashed）
- [ ] Dialog 使用半透明遮罩 + 白色居中卡片
- [ ] 文案使用 i18n，不硬编码
- [ ] 类名使用 BEM 风格或语义化命名
- [ ] 无 Tailwind / UnoCSS 类名
- [ ] 无外部组件库引入
