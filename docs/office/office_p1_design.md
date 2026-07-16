# 文档业务技术方案 — Phase 1

## 1. 架构概述

### 1.1 整体架构

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter 客户端                         │
│  ┌──────────┐  ┌─────────────────────────────────────┐   │
│  │ 文档列表  │  │  Riverpod Notifier                  │   │
│  │ + 空间树  │  │  (BizOffice -> SDK -> HTTP)         │   │
│  └──────────┘  └─────────────────────────────────────┘   │
└───────────────────────┬─────────────────────────────────┘
                        │ REST JSON (bypass protobuf)
                        ▼
┌─────────────────────────────────────────────────────────┐
│               Backend (Loco, port 5150)                   │
│                                                           │
│  ┌──────────────────┐  ┌──────────────────────────────┐  │
│  │  Office REST 路由 │  │  Yjs WebSocket               │  │
│  │  /api/office/*    │  │  /office/ws/:doc_id          │  │
│  │                   │  │                              │  │
│  │  - POST /docs     │  │  BroadcastGroup + Awareness  │  │
│  │  - GET /docs      │  │  yrs 0.18 + yrs-axum 0.8    │  │
│  │  - GET /docs/:id  │  │                              │  │
│  │  - PATCH /docs/:id│  └──────────┬───────────────────┘  │
│  │  - DELETE /docs/:id│            │                      │
│  │  - GET /spaces    │            │                      │
│  └────────┬──────────┘            │                      │
│           │                       │                      │
│           └───────────┬───────────┘                      │
│                       ▼                                  │
│            ┌──────────────────────┐                      │
│            │    PostgreSQL        │                      │
│            │  - documents         │                      │
│            │  - document_spaces   │                      │
│            │  - document_members  │                      │
│            └──────────────────────┘                      │
└─────────────────────────────────────────────────────────┘
                        ▲
                        │ JSON REST + y-websocket
                        ▼
┌─────────────────────────────────────────────────────────┐
│             Web 前端 (Vue3 SPA + ProseMirror)             │
│  ┌────────────────────────────────────────────────────┐  │
│  │  /office/*                 /admin/* (future)       │  │
│  │  ┌──────────────────┐  ┌──────────────────────┐   │  │
│  │  │  编辑器            │  │  管理后台             │   │  │
│  │  │  ProseMirror      │  │  (惰性加载)          │   │  │
│  │  │  y-prosemirror    │  └──────────────────────┘   │  │
│  │  │  y-websocket      │                             │  │
│  │  │  y-indexeddb      │                             │  │
│  │  └──────────────────┘                              │  │
│  └────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 1.2 关键设计决策

| 决策 | 选择 | 理由 |
|------|------|------|
| API 协议 | JSON REST (非 protobuf) | 浏览器直接调用，无需 protobuf WASM |
| 路由注册 | 注册到主 Loco 路由 `/api/office/*` | 复用 TLS、鉴权、端口 5150 |
| 鉴权 | 复用 JWT token（Header `Authorization: Bearer`） | 与现有系统一致 |
| 编辑器 | ProseMirror + y-prosemirror | Yjs 官方推荐，插件生态最成熟 |
| 前端框架 | Vue3 + Vite + TypeScript | 轻量、快速、生态好 |
| 离线缓存 | y-indexeddb | 浏览器端 IndexedDB 持久化 |
| Yjs 同步 | y-websocket (后端 yrs-axum) | 已有 yrs-axum BroadcastGroup 可用 |
| 持久化策略 | 定时保存 Yjs 二进制快照到 PG | Yjs update 增量合并定期写入 |
| 桌面 WebView | 同域名直接加载，无需额外适配 | 前端零改动 |

---

## 2. 数据库设计

### 2.1 documents

```sql
CREATE TABLE documents (
    id            BIGINT PRIMARY KEY,          -- Snowflake
    space_id      BIGINT NOT NULL,             -- 所属空间
    type          SMALLINT NOT NULL DEFAULT 1,  -- 1=doc, 2=sheet, 3=wiki_page
    title         VARCHAR(512) NOT NULL DEFAULT '',
    content       BYTEA,                        -- Yjs 二进制状态快照
    owner_id      BIGINT NOT NULL,
    version       BIGINT NOT NULL DEFAULT 0,    -- 乐观锁 (毫秒时间戳)
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at    TIMESTAMPTZ                     -- 软删除
);

CREATE INDEX idx_documents_space ON documents(space_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_documents_owner ON documents(owner_id) WHERE deleted_at IS NULL;
```

### 2.2 document_spaces

```sql
CREATE TABLE document_spaces (
    id            BIGINT PRIMARY KEY,          -- Snowflake
    name          VARCHAR(256) NOT NULL DEFAULT '',
    owner_id      BIGINT NOT NULL,
    type          SMALLINT NOT NULL DEFAULT 1,  -- 1=personal, 2=shared
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at    TIMESTAMPTZ
);

CREATE INDEX idx_spaces_owner ON document_spaces(owner_id) WHERE deleted_at IS NULL;
```

### 2.3 document_members

```sql
CREATE TABLE document_members (
    id            BIGINT PRIMARY KEY,
    document_id   BIGINT NOT NULL REFERENCES documents(id),
    user_id       BIGINT NOT NULL,
    role          SMALLINT NOT NULL DEFAULT 2,  -- 1=viewer, 2=editor, 3=owner
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(document_id, user_id)
);

CREATE INDEX idx_members_user ON document_members(user_id);
```

---

## 3. API 设计

### 3.1 REST 路由

所有路由均注册在 `/api/office` prefix 下。

#### 空间

| 方法 | 路径 | 功能 |
|------|------|------|
| GET | `/api/office/spaces` | 获取用户空间列表 |
| POST | `/api/office/spaces` | 创建空间 |
| PUT | `/api/office/spaces/:id` | 更新空间名称 |
| DELETE | `/api/office/spaces/:id` | 删除空间 |

#### 文档

| 方法 | 路径 | 功能 |
|------|------|------|
| GET | `/api/office/docs?space_id=xxx` | 获取文档列表 |
| POST | `/api/office/docs` | 创建文档 |
| GET | `/api/office/docs/:id` | 获取文档元数据 |
| PATCH | `/api/office/docs/:id` | 更新文档（重命名/移动） |
| DELETE | `/api/office/docs/:id` | 删除文档 |
| GET | `/api/office/docs/:id/edit-url` | 获取浏览器编辑 URL |

#### Yjs WebSocket

| 路径 | 功能 |
|------|------|
| `/office/ws/:doc_id` | Yjs 文档同步 |

### 3.2 请求/响应格式

**鉴权**：所有请求（除 WS 外）需携带 `Authorization: Bearer <token>` header。WebSocket 通过 URL query `?token=xxx` 传递。

**统一响应格式**：

```json
// 成功
{ "code": 0, "data": { ... } }

// 错误
{ "code": 40001, "message": "document not found" }
```

### 3.3 关键接口定义

#### POST /api/office/docs

```json
// Request
{
  "space_id": 123456,
  "title": "项目规划",
  "type": 1
}

// Response
{
  "code": 0,
  "data": {
    "id": 789012,
    "space_id": 123456,
    "type": 1,
    "title": "项目规划",
    "edit_url": "https://buzzing-im.com/office/editor/789012?token=xxx",
    "created_at": "2026-07-14T10:00:00Z"
  }
}
```

#### GET /api/office/docs/:id/edit-url

```json
// Response
{
  "code": 0,
  "data": {
    "edit_url": "https://buzzing-im.com/office/editor/789012?token=xxx",
    "title": "项目规划"
  }
}
```

`edit_url` 由服务端生成，包含加密的临时 token（或直接使用用户 JWT，通过 URL query 传递），供浏览器端认证。

---

## 4. 后端实现

### 4.1 模块结构

```
backend/office/
├── Cargo.toml
├── src/
│   ├── lib.rs                # ExternApp 实现 + 模块入口
│   ├── controllers/
│   │   ├── mod.rs
│   │   ├── docs.rs           # 文档 CRUD 路由处理函数
│   │   └── spaces.rs         # 空间路由处理函数
│   ├── models/
│   │   ├── mod.rs
│   │   ├── document.rs       # sea-orm Document entity
│   │   ├── document_space.rs # sea-orm DocumentSpace entity
│   │   └── document_member.rs# sea-orm DocumentMember entity
│   ├── ws.rs                 # Yjs WebSocket 处理器
│   └── yjs_store.rs          # Yjs 持久化 (定时存 PG)
```

### 4.2 ExternApp 实现

```rust
#[derive(Clone)]
pub struct AppOffice;

impl ExternApp for AppOffice {
    fn initializers(&self, _ctx: &AppContext) -> Vec<Box<dyn Initializer>> {
        Vec::new()
    }

    fn routes(&self, ctx: &AppContext) -> Vec<Routes> {
        vec![
            Routes::new()
                .prefix("/api/office")
                .add("/spaces", get(spaces::list))
                .add("/spaces", post(spaces::create))
                .add("/spaces/:id", put(spaces::update))
                .add("/spaces/:id", delete(spaces::delete))
                .add("/docs", get(docs::list))
                .add("/docs", post(docs::create))
                .add("/docs/:id", get(docs::get))
                .add("/docs/:id", patch(docs::update))
                .add("/docs/:id", delete(docs::delete))
                .add("/docs/:id/edit-url", get(docs::edit_url)),
        ]
    }

    fn serve(&self, ctx: &AppContext) {
        let cc = ctx.clone();
        tokio::spawn(async move {
            yjs_server::start(cc).await;
        });
    }

    fn handled_command(&self) -> Vec<i32> {
        vec![]  // office 不走 protobuf 命令
    }
}
```

### 4.3 鉴权中间件

复用 loco-rs 的 JWT 鉴权中间件。在 `/api/office` 路由组上应用 `middleware::require_authentication`。

对于 WebSocket 连接，通过 URL query `token` 参数获取并验证 JWT。

### 4.4 Yjs WebSocket 集成

```
/office/ws/:doc_id
```

核心流程：

```rust
// ws.rs
pub async fn start(ctx: AppContext) {
    let app = Router::new()
        .route("/office/ws/:doc_id", get(ws_handler))
        .with_state(ctx);

    // 注册到主 Loco 路由器
    // 通过 loco_rs 的 Route 注册机制或直接 merge router
}

async fn ws_handler(
    ws: WebSocketUpgrade,
    Path(doc_id): Path<String>,
    State(ctx): State<AppContext>,
    Query(params): Query<HashMap<String, String>>,
) -> impl IntoResponse {
    // 1. 验证 token
    let token = params.get("token").ok_or(...)?;
    let user = verify_token(&ctx, token).await?;

    // 2. 检查文档权限
    check_permission(&ctx, &doc_id, &user).await?;

    // 3. 获取或创建 Yjs Doc + BroadcastGroup
    let (doc, group) = get_or_init_document(&ctx, &doc_id).await;

    // 4. 升级 WebSocket 并加入 BroadcastGroup
    ws.on_upgrade(move |socket| {
        handle_yjs_connection(socket, group, doc, user)
    })
}
```

### 4.5 Yjs 持久化策略

```
触发时机:
  - 每 30 秒定时保存（有变更时）
  - 最后一个人断开连接时立即保存
  - 服务端优雅关闭前保存

保存方式:
  1. 对 Yjs Doc 调用 encode_state_as_update_v1() 获取增量
  2. 合并之前的 pending updates
  3. 达到阈值（50 个 update 或 5 分钟）后全量快照
  4. 写入 documents.content (BYTEA)

加载方式:
  1. 从 documents.content 读取二进制快照
  2. 调用 apply_update() 恢复 Yjs Doc 状态
```

---

## 5. Web 前端

Web 端是**独立完整的产品**，包含登录、主页、文档编辑器全套页面，不依赖 Flutter 客户端。

### 5.1 页面与路由

| 路由 | 页面 | 说明 |
|------|------|------|
| `/office/login` | LoginView | 账号密码登录，获取 JWT |
| `/office` | HomeView | 文档主页（空间树 + 文档列表） |
| `/office/editor/:docId` | EditorView | 文档编辑器（惰性加载） |
| `/office/*` | — | SPA fallback → index.html |

未登录用户自动重定向到 `/office/login`。

### 5.2 目录结构

采用单一 SPA 模式，按业务模块分组但不拆分项目。构建时通过 Vite 的 rollupOptions 按路由代码分割。

```
frontend/
├── package.json
├── vite.config.ts
├── tsconfig.json
├── index.html
├── src/
│   ├── main.ts              # Vue3 入口
│   ├── App.vue
│   ├── router/
│   │   ├── index.ts         # 路由定义 + 导航守卫
│   │   └── guards.ts        # auth 守卫
│   ├── layouts/
│   │   ├── AuthLayout.vue   # 登录/注册布局（无侧栏）
│   │   └── DefaultLayout.vue# 主应用布局（侧栏 + 顶栏）
│   ├── views/
│   │   ├── login/
│   │   │   └── LoginView.vue    # 登录页面
│   │   ├── home/
│   │   │   ├── HomeView.vue     # 文档主页
│   │   │   └── components/
│   │   │       ├── SpaceTree.vue    # 空间目录树
│   │   │       └── DocList.vue      # 文档列表
│   │   ├── editor/
│   │   │   ├── EditorView.vue   # 文档编辑器页面（惰性加载）
│   │   │   └── components/
│   │   │       ├── ProseEditor.vue   # ProseMirror 编辑器封装
│   │   │       ├── Toolbar.vue      # 格式化工具栏
│   │   │       └── Collaborators.vue# 协作者头像/光标
│   │   └── error/
│   │       └── NotFound.vue
│   ├── composables/
│   │   ├── useYjs.ts        # Yjs WebSocket 连接管理
│   │   ├── useDocument.ts   # 文档加载/保存
│   │   └── useSpaces.ts     # 空间管理
│   ├── stores/
│   │   ├── auth.ts          # Pinia auth store（token、用户信息）
│   │   └── document.ts      # Pinia document store（文档列表）
│   ├── services/
│   │   ├── api.ts           # axios 实例 + 拦截器
│   │   └── auth.ts          # 登录/登出 API
│   └── styles/
│       ├── global.css       # 全局样式
│       └── editor.css       # 编辑器样式
```

### 5.3 路由与鉴权

```typescript
// router/index.ts
const routes = [
  {
    path: '/office/login',
    component: AuthLayout,
    children: [
      { path: '', name: 'Login', component: LoginView },
    ],
  },
  {
    path: '/office',
    component: DefaultLayout,
    beforeEnter: authGuard,  // 需登录
    children: [
      { path: '', name: 'Home', component: HomeView },
      {
        path: 'editor/:docId',
        name: 'Editor',
        component: () => import('@/views/editor/EditorView.vue'), // 惰性加载
      },
    ],
  },
  { path: '/:pathMatch(.*)*', component: NotFound },
]
```

```typescript
// router/guards.ts
export function authGuard(to: RouteLocationNormalized): NavigationGuardReturn {
  const auth = useAuthStore()
  if (!auth.token) {
    return { name: 'Login', query: { redirect: to.fullPath } }
  }
}
```

### 5.4 登录与鉴权流程

```
1. 用户访问 /office/*，authGuard 检测无 token → 重定向到 /office/login
2. 用户输入账号密码 → POST /api/office/auth/login
3. 服务端验证 → 返回 { token, user }
4. 前端将 token 存入 localStorage + Pinia auth store
5. axios 拦截器自动携带 Authorization: Bearer <token>
6. token 过期 → 401 响应 → 拦截器自动跳转登录页

持久化: localStorage + Pinia (刷新后从 localStorage 恢复)
```

#### axios 拦截器

```typescript
// services/api.ts
const api = axios.create({ baseURL: import.meta.env.VITE_API_BASE })

api.interceptors.request.use((config) => {
  const auth = useAuthStore()
  if (auth.token) {
    config.headers.Authorization = `Bearer ${auth.token}`
  }
  return config
})

api.interceptors.response.use(
  (res) => res,
  (error) => {
    if (error.response?.status === 401) {
      const auth = useAuthStore()
      auth.clear()
      router.push({ name: 'Login' })
    }
    return Promise.reject(error)
  },
)
```

### 5.5 主页 (HomeView)

页面布局：

```
┌─────────────────────────────────────────┐
│  顶栏: Logo + 用户头像/退出              │
├───────────┬─────────────────────────────┤
│           │                             │
│  空间树   │  文档列表                    │
│           │                             │
│  📁 我的   │  📄 项目规划    10 min ago  │
│  📁 团队   │  📄 API 设计    1h ago      │
│  📁 个人   │  📄 周报        2h ago      │
│           │                             │
│  [+ 新建]  │  [+ 新建文档]               │
└───────────┴─────────────────────────────┘
```

#### Pinia Store

```typescript
// stores/auth.ts
export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('token') || '')
  const user = ref<UserInfo | null>(null)

  async function login(username: string, password: string) {
    const res = await authApi.login(username, password)
    token.value = res.token
    user.value = res.user
    localStorage.setItem('token', res.token)
  }

  function clear() {
    token.value = ''
    user.value = null
    localStorage.removeItem('token')
  }

  return { token, user, login, clear }
})

// stores/document.ts
export const useDocumentStore = defineStore('document', () => {
  const spaces = ref<SpaceInfo[]>([])
  const documents = ref<DocInfo[]>([])
  const currentSpaceId = ref<number>(0)

  async function loadSpaces() { /* GET /api/office/spaces */ }
  async function loadDocuments(spaceId: number) { /* GET /api/office/docs */ }
  async function createDocument(title: string, spaceId: number) { /* POST /api/office/docs */ }
  async function deleteDocument(id: number) { /* DELETE /api/office/docs/:id */ }
  // ...

  return { spaces, documents, currentSpaceId, loadSpaces, loadDocuments, createDocument, deleteDocument }
})
```

### 5.6 编辑器初始化流程

```
1. 用户打开 /office/editor/:docId（已登录，token 在 header 中）
2. useDocument 通过 API GET /api/office/docs/:id 获取文档元数据
3. useYjs 建立 WebSocket 连接 /office/ws/:docId?token=xxx
4. y-prosemirror 将 Yjs Text 绑定到 ProseMirror 编辑器
5. 用户编辑 → y-websocket 同步到其他协作者
6. y-indexeddb 在浏览器端缓存文档状态
```

### 5.7 后端认证 API

```json
// POST /api/office/auth/login
// Request
{ "username": "user@example.com", "password": "***" }

// Response
{
  "code": 0,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": { "id": 123, "name": "张三", "avatar": "" }
  }
}
```

复用现有 user 模块的认证接口。若用户系统已经存在 `/api/user/login`，Web 前端直接调用该接口即可，无需单独实现。

### 5.8 部署

前端 SPA 构建产物通过 `rust-embed` 编译期嵌入 Rust 二进制，axum 路由直接 serve。**单二进制部署，无需 Nginx / CDN 等外部依赖**。

```
frontend/ (源码)
    │  pnpm build
    ▼
frontend/dist/ (构建产物)
    │
    │  cargo build (rust-embed 编译期嵌入)
    ▼
backend/target/release/app (单一二进制，含前端 + 后端)
```

**实现方式：**

在 `backend/office/Cargo.toml` 中：

```toml
[dependencies]
rust-embed = { workspace = true }
```

在路由中注册静态文件处理：

```rust
use rust_embed::Embed;

#[derive(Embed)]
#[folder = "../../frontend/dist"]
#[prefix = "/office"]
struct OfficeAssets;

// routes() 中注册
.route("/office/{*path}", get(office_assets_handler))
```

```rust
async fn office_assets_handler(
    path: Option<axum::extract::Path<String>>,
) -> Result<Response, StatusCode> {
    let path = path.map(|p| p.0).unwrap_or_default();
    let path = if path.is_empty() || path == "/" {
        "index.html"
    } else {
        &path
    };

    match OfficeAssets::get(path) {
        Some(content) => {
            let mime = mime_guess::from_path(path).first_or_unknown();
            Ok(Response::builder()
                .header("Content-Type", mime.as_ref())
                .body(Body::from(content.data.to_vec()))
                .unwrap())
        }
        None => {
            // SPA fallback: 所有未匹配路径返回 index.html
            OfficeAssets::get("index.html")
                .map(|content| {
                    Response::builder()
                        .header("Content-Type", "text/html")
                        .body(Body::from(content.data.to_vec()))
                        .unwrap()
                })
                .ok_or(StatusCode::NOT_FOUND)
        }
    }
}
```

**优点：** 版本一致（前端永远与后端二进制匹配）、部署简单（scp 一个二进制即可）、无需额外基础设施。

**缺点：** 前端变更需重新编译整个二进制（可在 CI 中自动化）。

对于开发环境，可继续使用 `vite dev` + 后端 API 代理，不影响开发体验。

### 5.9 ProseMirror 插件

| 插件 | 功能 |
|------|------|
| y-prosemirror | Yjs ↔ ProseMirror 双向绑定 |
| y-websocket | 与服务端 Yjs 同步 |
| y-indexeddb | 浏览器端离线持久化 |
| prosemirror-schema-basic | 基础格式（加粗、斜体、标题） |
| prosemirror-schema-list | 有序/无序列表 |
| prosemirror-history | 撤销/重做（与 Yjs 兼容） |
| prosemirror-collab | 协作光标/选中（通过 y-prosemirror） |
| prosemirror-tables | 表格支持 |

### 5.10 关键依赖

```json
{
  "dependencies": {
    "vue": "^3.4",
    "vue-router": "^4.3",
    "prosemirror-state": "^1.4",
    "prosemirror-view": "^1.33",
    "prosemirror-model": "^1.19",
    "prosemirror-schema-basic": "^1.2",
    "prosemirror-schema-list": "^1.3",
    "prosemirror-tables": "^1.3",
    "prosemirror-history": "^1.3",
    "prosemirror-example-setup": "^1.2",
    "y-prosemirror": "^1.2",
    "y-websocket": "^2.0",
    "y-indexeddb": "^1.0",
    "yjs": "^13.6",
    "axios": "^1.7"
  }
}
```

---

## 6. SDK 变更

### 6.1 BizOffice Trait

```rust
#[async_trait]
pub trait BizOffice: Send + Sync {
    /// 创建文档
    async fn create_document(&self, ctx: &AppContext, space_id: i64, title: &str) -> Result<DocInfo>;

    /// 获取文档列表
    async fn list_documents(&self, ctx: &AppContext, space_id: i64) -> Result<Vec<DocInfo>>;

    /// 获取文档详情
    async fn get_document(&self, ctx: &AppContext, doc_id: i64) -> Result<DocInfo>;

    /// 更新文档
    async fn update_document(&self, ctx: &AppContext, doc_id: i64, title: &str) -> Result<()>;

    /// 删除文档
    async fn delete_document(&self, ctx: &AppContext, doc_id: i64) -> Result<()>;

    /// 获取编辑 URL
    async fn get_edit_url(&self, ctx: &AppContext, doc_id: i64) -> Result<String>;

    /// 获取空间列表
    async fn list_spaces(&self, ctx: &AppContext) -> Result<Vec<SpaceInfo>>;

    /// 创建空间
    async fn create_space(&self, ctx: &AppContext, name: &str) -> Result<SpaceInfo>;
}
```

### 6.2 通信方式

SDK 中的 `BizOffice` 实现通过 HTTP JSON 调用 `/api/office/*` 路由，不走 protobuf 编码。

```rust
// SDK 内部实现
impl BizOffice for OfficeClient {
    async fn create_document(&self, ctx: &AppContext, space_id: i64, title: &str) -> Result<DocInfo> {
        let resp = self.http_post(ctx, "/api/office/docs", json!({
            "space_id": space_id,
            "title": title
        })).await?;
        Ok(serde_json::from_value(resp.data)?)
    }
    // ...
}
```

---

## 7. Flutter 客户端

### 7.1 页面结构

```
lib/
├── pages/
│   └── office/
│       ├── office_page.dart          # 文档主页面（空间树 + 文档列表）
│       ├── widgets/
│       │   ├── space_tree.dart       # 空间树侧边栏
│       │   ├── doc_list_item.dart    # 文档列表项
│       │   └── create_doc_dialog.dart# 新建文档对话框
│       └── providers/
│           └── office_provider.dart# Riverpod Notifier
```

### 7.2 OfficeNotifier (Riverpod)

```dart
final officeProvider = NotifierProvider<OfficeNotifier, OfficeState>(
  OfficeNotifier.new,
);

class OfficeState {
  final List<SpaceInfo> spaces;
  final List<DocInfo> documents;
  final int currentSpaceId;
  final bool loading;

  const OfficeState({...});
}

class OfficeNotifier extends Notifier<OfficeState> {
  @override
  OfficeState build() => OfficeState(...);

  Future<void> loadSpaces() async {
    state = state.copyWith(loading: true);
    final client = ref.read(sdkProvider);
    final list = await client.listSpaces();
    state = state.copyWith(spaces: list, loading: false);
  }

  Future<void> loadDocuments(int spaceId) async {
    final client = ref.read(sdkProvider);
    final list = await client.listDocuments(spaceId);
    state = state.copyWith(documents: list);
  }

  Future<void> openDocument(int docId) async {
    final client = ref.read(sdkProvider);
    final url = await client.getEditUrl(docId);
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
```

### 7.3 多语言

在 `lib/l10n/` 中新增 office 相关文案 key：

```dart
// app_zh.dart
'office_title': '文档',
'office_new_doc': '新建文档',
'office_delete_doc': '删除文档',
'office_rename': '重命名',
'office_create_space': '新建空间',
```

---

## 8. 数据流示例

### 8.1 创建并编辑文档

```
Flutter                     Backend                     Browser
   │                          │                          │
   │── POST /api/office/docs ──│                          │
   │   {space_id, title}       │                          │
   │                          │─ INSERT documents         │
   │◄── {id, edit_url} ──────│                          │
   │                          │                          │
   │── launchUrl(edit_url) ──────────────────────────────│
   │                          │                          │
   │                          │◄── GET /office/editor/:id│
   │                          │    ?token=xxx             │
   │                          │── 返回 editor HTML ──────│
   │                          │                          │
   │                          │◄── WS /office/ws/:id     │
   │                          │    ?token=xxx             │
   │                          │── Yjs sync ──────────────│
   │                          │                          │
   │                          │   [协作编辑中...]         │
   │                          │   [每 30s 持久化快照]    │
   │                          │                          │
```

---

## 9. 实施计划

### 9.1 任务分解

| 序号 | 任务 | 预估工时 |
|------|------|---------|
| 1 | 数据库迁移：documents / document_spaces / document_members | 1d |
| 2 | 后端 sea-orm 实体 + 基础 CRUD service | 2d |
| 3 | Spaces REST 路由 + controller | 1d |
| 4 | Docs REST 路由 + controller | 1d |
| 5 | 后端 auth/login API（或复用现有 user 接口） | 0.5d |
| 6 | 鉴权中间件集成（JWT 验证） | 0.5d |
| 7 | Yjs WebSocket handler + BroadcastGroup 集成 | 2d |
| 8 | Yjs 持久化逻辑（定时快照 + 加载） | 2d |
| 9 | rust-embed 静态文件集成 + 路由注册 | 0.5d |
| 10 | SDK BizOffice trait + HTTP JSON 实现 | 1d |
| 11 | Flutter 文档列表页面 + Riverpod Notifier | 2d |
| 12 | Flutter 空间树组件 | 1d |
| 13 | Vue3 项目初始化 + Vite + TypeScript + 目录结构 | 0.5d |
| 14 | Pinia 状态管理 + axios 拦截器 + 路由框架 | 0.5d |
| 15 | 登录页面 LoginView + 鉴权流程 | 1d |
| 16 | 主页 HomeView（空间树 + 文档列表） | 2d |
| 17 | ProseMirror 编辑器集成 + y-prosemirror | 2d |
| 18 | 协作光标/选中 UI | 1d |
| 19 | Web 端联调 + 测试 | 1d |
| 20 | Flutter ↔ Web 端到端联调 | 1d |
| **合计** | | **~23d** |

### 9.2 依赖关系

```
DB Migration ──> sea-orm Models ──> REST Controllers
                                        │
                                        ├──> SDK BizOffice ──> Flutter UI
                                        │
                                        └──> Vue3 Editor (独立开发)
                                              │
Yjs WS Handler ──> Yjs Persistence ──────────┘
```

Vue3 编辑器开发与后端 REST/Yjs 开发可以并行进行。
