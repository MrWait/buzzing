# 前端架构文档 (Vue3 SPA)

## 技术栈

| 层 | 技术 | 版本 |
|----|------|------|
| 框架 | Vue | ^3.5.39 |
| 路由 | Vue Router | ^4.6.4 |
| 状态管理 | Pinia | ^3.0.4 |
| HTTP 客户端 | Axios | ^1.18.1 |
| 协同编辑 | Yjs + y-websocket + y-prosemirror | — |
| 富文本编辑器 | ProseMirror (8 个插件包) | — |
| 构建工具 | Vite | ^8.1.1 |
| 语言 | TypeScript | ~6.0.2 |
| 类型检查 | vue-tsc | ^3.3.5 |

无外部 UI 组件库，无 CSS 框架，无 i18n 库。

---

## 目录结构

```
frontend/
├── index.html                  # SPA 入口 HTML
├── vite.config.ts              # Vite 配置（proxy /@/alias）
├── tsconfig.json               # TS 配置
├── package.json                # 依赖 & 脚本
├── public/                     # 静态资源
└── src/
    ├── main.ts                 # 应用入口
    ├── App.vue                 # 根组件（RouterView）
    ├── styles/
    │   ├── global.css          # 全局 reset + 基础样式
    │   └── editor.css          # ProseMirror 编辑器样式
    ├── router/
    │   ├── index.ts            # 路由定义（7 条路由）
    │   └── guards.ts           # 导航守卫（authGuard / tenantGuard）
    ├── stores/
    │   ├── auth.ts             # 认证状态（login / selectIdentity）
    │   └── document.ts         # 文档模块 CRUD 状态
    ├── services/
    │   ├── api.ts              # Axios 实例 + 拦截器
    │   └── auth.ts             # 认证 API + 类型定义
    ├── layouts/
    │   ├── AuthLayout.vue      # 居中单列布局
    │   ├── HubLayout.vue       # 顶栏 + 内容（Hub/租户选择）
    │   ├── ModuleLayout.vue    # 顶栏 + 内容（模块页面）
    │   └── FullscreenLayout.vue# 全屏布局（预留）
    ├── views/
    │   ├── login/
    │   │   └── LoginView.vue   # 登录页
    │   ├── tenant/
    │   │   └── TenantSelectView.vue # 身份/租户选择
    │   ├── hub/
    │   │   └── HubView.vue     # 应用中心
    │   ├── office/
    │   │   ├── HomeView.vue    # 办公文档首页（侧栏+文档列表）
    │   │   ├── EditorView.vue  # 文档编辑器（Yjs 协同）
    │   │   └── components/
    │   │       ├── SpaceTree.vue     # 空间列表侧栏
    │   │       ├── DocList.vue       # 文档列表
    │   │       ├── Toolbar.vue       # 编辑器工具栏
    │   │       ├── ProseEditor.vue   # ProseMirror 编辑器
    │   │       └── Collaborators.vue # 协作者头像
    │   └── error/
    │       └── NotFound.vue    # 404 页面
    └── composables/
        ├── useYjs.ts           # Yjs Doc + WebsocketProvider 初始化
        ├── useDocument.ts      # 文档详情获取
        └── useSpaces.ts        # 空间列表加载
```

---

## 构建与配置

### Vite 配置 (`vite.config.ts`)

- `base: '/'` — SPA 部署在根路径
- `@` 别名映射到 `./src`
- 开发代理：`/api/*` → `http://localhost:5150`，`/office/ws` → `ws://localhost:5150`
- 仅 `@vitejs/plugin-vue` 插件

### 构建脚本

| 命令 | 说明 |
|------|------|
| `npm run dev` | 启动 Vite 开发服务器 |
| `npm run build` | `vue-tsc -b && vite build`（类型检查+构建） |
| `npm run preview` | 预览生产构建 |

---

## 应用启动流程

```
index.html  <div id="app">
       │
main.ts  createApp(App)
       │  .use(createPinia())
       │  .use(router)
       │  .mount('#app')
       │  + import('./styles/global.css')
       ▼
App.vue  <RouterView />
```

1. `main.ts` 创建 Vue 应用，注册 Pinia 和 Vue Router
2. `App.vue` 仅渲染 `<RouterView />`，无全局包裹
3. 全局样式 `global.css` 在 main.ts 中导入，覆盖所有组件
4. 路由匹配后将视图渲染到对应的 Layout 中

---

## 路由系统

### 路由表

| 路径 | 名称 | Layout | 守卫 | 视图 |
|------|------|--------|------|------|
| `/login` | Login | AuthLayout | 已登录→跳 Hub | LoginView |
| `/select-tenant` | TenantSelect | HubLayout | 无 | TenantSelectView |
| `/hub` | Hub | HubLayout | tenantGuard | HubView |
| `/` | — | HubLayout | tenantGuard | 重定向到 Hub |
| `/office` | OfficeHome | ModuleLayout | tenantGuard | HomeView |
| `/office/editor/:docId` | OfficeEditor | ModuleLayout | tenantGuard | EditorView |
| `/:pathMatch(.*)*` | NotFound | 无 | 无 | NotFound |

所有路由使用懒加载（`() => import(...)`）。

### 导航守卫 (`guards.ts`)

```
                    ┌──────────────┐
                    │  访问受保护  │
                    │  路由 (/hub, │
                    │  /office)    │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │  token 存在? │──否──→ /login?redirect=...
                    └──────┬───────┘
                           │ 是
                    ┌──────▼───────┐
                    │   user 存在? │──否──→ /select-tenant
                    └──────┬───────┘
                           │ 是
                    ┌──────▼───────┐
                    │   放行       │
                    └──────────────┘
```

关键点：
- `authGuard` 已定义但**未使用**，当前仅 `tenantGuard` 在路由中注册
- `token` 和 `user` 是不同阶段设置的——`token` 在 `selectIdentity()` 中设置，不是 `login()`
- `user` 从 localStorage 恢复，支持页面刷新后保持登录状态

---

## 布局系统

### AuthLayout

```
┌──────────────────────────────────────┐
│          vh:100%                      │
│    display:flex;align-items:center;   │
│    justify-content:center             │
│    background: #f5f5f5                │
│                                      │
│        ┌────────────────────┐        │
│        │    <RouterView />  │        │
│        │    登录表单        │        │
│        └────────────────────┘        │
└──────────────────────────────────────┘
```

### HubLayout

```
┌──────────────────────────────────────┐
│  topbar: #1a1a2e, 48px, 白字         │
│  [Buzzing]              [用户] [退出] │
├──────────────────────────────────────┤
│  <RouterView />                      │
│  flex:1; overflow:auto               │
│                                      │
└──────────────────────────────────────┘
```

用于 `/hub`、`/`（重定向）、`/select-tenant`。

### ModuleLayout

```
┌──────────────────────────────────────┐
│  topbar: #1a1a2e, 48px, 白字         │
│  [Buzzing] [模块名]     [用户] [退出] │
├──────────────────────────────────────┤
│  <RouterView />                      │
│  flex:1; overflow:auto               │
└──────────────────────────────────────┘
```

与 HubLayout 几乎相同，增加了模块名显示和 logo 回 Hub 功能。

### FullscreenLayout

```
┌──────────────────────────────────────┐
│ height: 100vh                        │
│ <RouterView /> (全屏内容)             │
└──────────────────────────────────────┘
```

当前未使用，为编辑器全屏模式预留。

---

## 认证流程

```
LoginView                      TenantSelectView              受保护路由
┌──────────┐                  ┌───────────────┐              ┌────────┐
│ 输入手机  │                  │ 显示所有身份   │              │        │
│ 密码      │                  │               │              │        │
│           │                  │ 个人身份       │              │ /hub   │
│ login()  ─┼─→ POST /api/    │ 租户A-身份1   │              │ /office│
│           │   accounts/     │ 租户B-身份2   │              │        │
│           │   login         │               │              │        │
│           │                  │ selectIdentity│              │        │
│           │  返回 LoginResult│ ──→ 设置      │              │        │
│           │  含 users[]     │  token/user   │              │        │
│ 设置      │                  │  持久化到     │              │        │
│ loginUsers│                  │  localStorage │              │        │
│           │                  └──────┬────────┘              │        │
│ 1个用户   │                         │                       │        │
│ ─→ 直接   │                         │                       │        │
│ 选身份    │                         │                       │        │
└──────────┘                         └───────────────────────┘        │
```

关键设计：
- **两步登录**：先 `login()` 获取用户的多个身份（跨租户），再 `selectIdentity()` 选择使用哪个身份
- `login()` 不设 `token`，`selectIdentity(lu)` 才设 `token`、`user`、`currentTenant`
- 个人用户无 tenant（`tenant_id=0`），`currentTenant` 为 null

---

## 状态管理 (Pinia Stores)

### auth 状态 (`stores/auth.ts`)

```
State:
  token: string                ← localStorage('token')
  user: UserInfo | null        ← localStorage('user')
  loginUsers: LoginUser[]      ← 运行时
  accountName: string          ← 运行时
  currentTenant: TenantInfo    ← computed from localStorage('currentTenant')

Actions:
  login(phone, password)       → POST /api/accounts/login → 填充 loginUsers
  selectIdentity(lu)           → 设置 token/user → 持久化
  clear()                      → 清除所有
```

### document 状态 (`stores/document.ts`)

```
State:
  spaces: SpaceInfo[]
  documents: DocInfo[]
  currentSpaceId: string

Actions:
  loadSpaces()                 → GET /office/spaces
  loadDocuments(spaceId)       → GET /office/docs?space_id=...
  createDocument(title, sid)   → POST /office/docs
  deleteDocument(id)           → DELETE /office/docs/:id
  createSpace(name)            → POST /office/spaces
```

类型定义内联在 store 文件中：

```ts
interface SpaceInfo { id: string; name: string; sp_type: number; created_at: string; updated_at: string }
interface DocInfo { id: string; space_id: string; title: string; doc_type: number; version: number; created_at: string; updated_at: string }
```

---

## API 层

### Axios 实例 (`services/api.ts`)

```ts
const api = axios.create({
  baseURL: '/api',
  timeout: 15000,
  headers: { 'Content-Type': 'application/json' },
})
```

**请求拦截器** — 在每个请求中注入 `Authorization: Bearer <token>`：

```ts
api.interceptors.request.use((config) => {
  const auth = useAuthStore()
  if (auth.token) {
    config.headers.Authorization = `Bearer ${auth.token}`
  }
  return config
})
```

**响应拦截器** — 401 时清除认证状态并跳转登录：

```ts
api.interceptors.response.use(
  (r) => r,
  (error: AxiosError) => {
    if (error.response?.status === 401) {
      useAuthStore().clear()
      router.push({ name: 'Login' })
    }
    return Promise.reject(error)
  }
)
```

### 认证 API (`services/auth.ts`)

| 函数 | 方法 | 路径 |
|------|------|------|
| `login(params)` | POST | `/api/accounts/login` |

其他 CRUD 操作直接在 store/组件中调用 `api.get/post/delete`。

---

## 组件架构

### 组件树

```
RouterView
├── AuthLayout
│   └── LoginView             表单: 手机号 + 密码
│
├── HubLayout
│   ├── TenantSelectView      身份卡片列表（多租户选择）
│   └── HubView               应用中心卡片网格
│
├── ModuleLayout
│   ├── HomeView
│   │   ├── SpaceTree         空间侧栏列表 (220px)
│   │   └── DocList           文档列表 (flex: 1)
│   │
│   └── EditorView
│       ├── Toolbar           标题 + 保存按钮
│       ├── ProseEditor       ProseMirror 编辑器实例
│       └── Collaborators     协作者浮动头像
│
└── (无 Layout)
    └── NotFound              404 页面
```

### Office 模块组件详情

| 组件 | 职责 | 数据来源 | 状态 |
|------|------|---------|------|
| SpaceTree | 空间列表，点击加载文档 | `documentStore.spaces` | 选中的 space 高亮 |
| DocList | 文档列表，创建/删除/打开 | `documentStore.documents` | 加载态、空态 |
| Toolbar | 文档标题 + save 事件 | props + emit | — |
| ProseEditor | ProseMirror 实例 + Yjs 绑定 | inject (yjs-type, yjs-provider) | — |
| Collaborators | 远程协作者头像 | Awareness (Yjs) | 固定定位右上角 |

---

## 实时协同编辑 (Yjs)

### 架构

```
EditorView
  │
  ├── useYjs(docId) composable
  │     │
  │     ├── new Y.Doc()
  │     │
  │     ├── new WebsocketProvider(
  │     │     ws://host/office/ws/<docId>,
  │     │     doc
  │     │   )
  │     │
  │     └── provide('yjs-type', doc.getXmlFragment('prosemirror'))
  │         provide('yjs-provider', provider)
  │
  ├── Toolbar
  │     └── emit('save')  →  stub (服务端自动保存)
  │
  ├── ProseEditor
  │     └── inject → ySyncPlugin / yCursorPlugin / yUndoPlugin
  │
  └── Collaborators
        └── inject → provider.awareness
              awareness.getStates() → 远程用户列表
```

### 数据流

```
用户输入 → ProseMirror → ySyncPlugin → Y.Doc (shared)
                                              │
                                    WebsocketProvider
                                              │
                                         WebSocket
                                              │
                                    ┌─────────┴─────────┐
                                    │  Backend (loco-rs)│
                                    │  /office/ws/:id   │
                                    │  Yjs broadcast +  │
                                    │  定期持久化到 DB   │
                                    └───────────────────┘
```

### ProseMirror 插件

| 插件 | 来源 | 说明 |
|------|------|------|
| ySyncPlugin | y-prosemirror | Yjs ↔ ProseMirror 双向同步 |
| yCursorPlugin | y-prosemirror | 协作者光标渲染 |
| yUndoPlugin | y-prosemirror | 协同撤销栈 |
| keymap (Ctrl+Z/Y) | prosemirror-keymap | 撤销/重做快捷键 |
| exampleSetup | prosemirror-example-setup | 基础 schema（不含 history/menu） |

---

## 样式架构

### 文件结构

```
src/styles/
├── global.css    # 全局 reset + 基础样式（main.ts 中导入）
└── editor.css    # ProseMirror 编辑器样式（ProseEditor.vue 中导入）
```

### global.css 内容

- `box-sizing: border-box` 全局重置
- `body`: 系统字体栈，14px，`#333`，白色背景
- `a`: 无下划线，继承颜色
- `button`/`input`: 继承字体
- `#app`: `height: 100%`

### 样式约定

- 所有样式写在 SFC `<style scoped>` 中（除 ProseMirror 深度选择器用 `:deep()`）
- 编辑器相关样式在 `editor.css`（非 scoped，因为 ProseMirror DOM 在 Teleport 或插件创建的元素中）
- **无 CSS 变量**（已在设计指南中建议添加 `variables.css`）
- **无 BEM 命名约定**（已在设计指南中建议）
- **无硬编码颜色约定**（已在设计指南中建议使用 CSS 变量）

---

## 数据流总图

```
┌─────────┐       HTTP/JSON       ┌──────────────┐
│ Pinia    │◄────────────────────►│  Axios (api)  │
│ Stores   │   CRUD (spaces/docs) │  baseURL:/api │
│          │                      │  + Bearer     │
│ auth     │                      │  + 401 handler│
│ document │                      └──────┬─────────┘
└─────────┘                              │
      │                              proxy(/api)
      │                                  │
      │                          ┌───────▼────────┐
      │                          │  Backend        │
      │                          │  loco-rs :5150  │
      │                          └───────┬─────────┘
      │                                  │
      │      ┌────────────┐              │
      │      │ Yjs        │◄────WS───────┘
      │      │ Websocket  │  /office/ws/:id
      │      │ Provider   │
      │      └─────┬──────┘
      │            │
      │      ┌─────▼──────┐
      │      │ Y.Doc      │
      │      │ XmlFragment│
      │      │ Awareness  │
      │      └─────┬──────┘
      │            │
      │      ┌─────▼──────┐
      │      │ ProseMirror │
      │      │ EditorView  │
      │      └────────────┘
      │
      ▼
   Components (SpaceTree, DocList, etc.)
```

---

## 模块状态

| 模块 | 视图 | 状态 |
|------|------|------|
| 办公文档 | HomeView / EditorView | ✅ 已完成（含 Yjs 协同） |
| 日历 | — | ⏳ 占位 |
| 任务 | — | ⏳ 占位 |

`HubView` 中日历和任务卡片已有 UI 但点击无反应（`TODO`）。

---

## 关键依赖图（文件间引用）

```
main.ts
  ├── App.vue
  ├── router/index.ts
  │     ├── guards.ts (useAuthStore)
  │     ├── AuthLayout.vue
  │     ├── HubLayout.vue (useAuthStore)
  │     ├── ModuleLayout.vue (useAuthStore)
  │     └── FullscreenLayout.vue
  ├── stores/auth.ts
  │     └── services/auth.ts (api + types)
  └── stores/document.ts
        └── services/api.ts (axios + useAuthStore)

views/office/EditorView.vue
  ├── composables/useYjs.ts
  ├── components/Toolbar.vue
  ├── components/ProseEditor.vue (styles/editor.css)
  └── components/Collaborators.vue

views/office/HomeView.vue
  ├── stores/document.ts
  ├── components/SpaceTree.vue
  └── components/DocList.vue
    ```

---

## 待改进项

1. **CSS 变量** — 尚无 `variables.css`，颜色/间距硬编码
2. **i18n** — 所有文案硬编码中文，无多语言支持
3. **类型文件** — 无集中 `types/` 目录，类型定义零散在各文件中
4. **公共组件** — 无 `src/components/` 目录，按钮/输入框/卡片无复用组件
5. **`authGuard` 未使用** — 已定义但不注册，所有保护依赖 `tenantGuard`
6. **全屏布局未使用** — `FullscreenLayout` 已创建但无路由使用
7. **日志/埋点** — 无前端日志或埋点系统
