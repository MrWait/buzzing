# 文档业务技术方案 — Phase A

对应 PRD：[office_pa.md](./office_pa.md)。本方案覆盖 M1（编辑器）、M2（协作）、M3（管理）、M4（权限）四个里程碑的架构、数据模型、接口设计。

---

## 1. 架构概述

### 1.1 整体架构

```
┌────────────────────────────────────────────────────────────┐
│                    Flutter 客户端                            │
│  ┌──────────────────┐  ┌────────────────────────────────┐  │
│  │ 文档列表/空间树   │  │ Riverpod OfficeNotifier          │  │
│  │ 搜索/回收站入口   │  │ (BizOffice → SDK → HTTP)         │  │
│  └──────────────────┘  └────────────────────────────────┘  │
└─────────────────────────┬──────────────────────────────────┘
                          │ REST JSON
                          ▼
┌────────────────────────────────────────────────────────────┐
│               Backend (loco-rs, port 5150)                  │
│                                                              │
│  ┌───────────────────────┐  ┌────────────────────────────┐  │
│  │ Office REST 路由       │  │ Yjs WebSocket              │  │
│  │ /api/office/*          │  │ /office/ws/{doc_id}        │  │
│  │  - spaces CRUD         │  │                            │  │
│  │  - docs CRUD           │  │ BroadcastGroup + Awareness │  │
│  │  - docs/search         │  │ IndexedDB 断线补同步        │  │
│  │  - docs/trash          │  │                            │  │
│  │  - docs/{id}/members   │  └────────────┬───────────────┘  │
│  │  - docs/{id}/share     │               │                  │
│  └─────────┬─────────────┘               │                  │
│            │                              │                  │
│  ┌─────────┴──────────────────────────────┴──────────────┐  │
│  │              Permission Middleware                     │  │
│  │  role: viewer(0) / commenter(1) / editor(2) / owner(3) │  │
│  └────────────────────────┬───────────────────────────────┘  │
│                           ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                     PostgreSQL                          ││
│  │  documents / document_spaces / document_members         ││
│  │  document_stars / document_visits / document_shares     ││
│  │  files (store 模块)                                     ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
                           ▲
                           │ REST JSON + y-websocket
                           ▼
┌─────────────────────────────────────────────────────────────┐
│           Web 前端 (Vue3 + Pinia + ProseMirror)              │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  /office/login, /office (Home), /office/editor/:id       ││
│  │  /office/trash, /office/search                           ││
│  │  /share/{token}                                          ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### 1.2 关键设计决策

| 决策 | 选择 | 理由 |
|------|------|------|
| API 协议 | JSON REST（office 模块内不走 protobuf） | 浏览器直接调用，鉴权/文件操作走 axios |
| 路由挂载 | `/api/office/*` 注册到主 Loco AppHub | 复用 TLS、JWT 鉴权、单端口 5150 |
| 鉴权 | JWT (Header `Authorization: Bearer`)；WS 用 `?token=` | 与现有 user 模块共用 |
| 编辑器 | ProseMirror + y-prosemirror + Yjs | 官方推荐、插件生态成熟 |
| 前端 SPA | Vue3 + Vite + Pinia + Vue Router | 项目既定技术栈 |
| 离线缓存 | y-indexeddb（M2 引入） | 浏览器端持久化，断线补同步 |
| Yjs 同步 | y-websocket ↔ yrs-axum BroadcastGroup | 已有实现 |
| 持久化 | 30s 定时快照 + 最后一人断开时立即保存 | Yjs `encode_state_as_update_v1` 到 `documents.content` |
| 文件上传 | 复用 `store` 模块 `/api/files/upload` | 统一存储 (object_store + files 表) |
| 前端部署 | `rust-embed` 编译期嵌入 Rust 二进制 | 单二进制部署 |

---

## 2. 数据库设计

Phase A 建立在已有的 `documents / document_spaces / document_members` 基础上，M3/M4 增补如下字段与表。

### 2.1 documents（M3 增补）

```sql
ALTER TABLE documents
  ADD COLUMN parent_id BIGINT,            -- M3: 子页面 (自引用)
  ADD COLUMN trashed_at TIMESTAMPTZ,      -- M3: 软删除 (回收站)
  ADD COLUMN icon VARCHAR(64),            -- M3: 文档图标
  ADD COLUMN cover VARCHAR(512);          -- M3: 封面图 URL

CREATE INDEX idx_documents_parent  ON documents(parent_id)  WHERE deleted_at IS NULL;
CREATE INDEX idx_documents_trashed ON documents(trashed_at) WHERE trashed_at IS NOT NULL;

-- M3: 全文搜索索引
ALTER TABLE documents
  ADD COLUMN search_tsv tsvector
  GENERATED ALWAYS AS (
    setweight(to_tsvector('simple', coalesce(title, '')), 'A')
    -- content 部分建议单独维护 (BYTEA 不能直接进 tsvector)，见 4.4 节
  ) STORED;

CREATE INDEX idx_documents_search ON documents USING GIN(search_tsv);
```

### 2.2 document_spaces（M3 增补）

```sql
ALTER TABLE document_spaces
  ADD COLUMN icon VARCHAR(64),
  ADD COLUMN color VARCHAR(16),
  ADD COLUMN sort_order INT NOT NULL DEFAULT 0,
  ADD COLUMN archived_at TIMESTAMPTZ;
```

### 2.3 document_members（M4 完善）

```sql
-- 已存在，M4 阶段确认字段
-- role: 0=viewer, 1=commenter, 2=editor, 3=owner
CREATE UNIQUE INDEX ux_members_doc_user ON document_members(document_id, user_id);
```

### 2.4 document_stars（M3 新增）

```sql
CREATE TABLE document_stars (
    id           BIGINT PRIMARY KEY,
    user_id      BIGINT NOT NULL,
    document_id  BIGINT NOT NULL,
    group_name   VARCHAR(64),               -- 收藏夹分组
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, document_id)
);
CREATE INDEX idx_stars_user ON document_stars(user_id);
```

### 2.5 document_visits（M3 新增）

```sql
CREATE TABLE document_visits (
    id           BIGINT PRIMARY KEY,
    user_id      BIGINT NOT NULL,
    document_id  BIGINT NOT NULL,
    visited_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, document_id)   -- 冲突时更新 visited_at
);
CREATE INDEX idx_visits_user_time ON document_visits(user_id, visited_at DESC);
```

### 2.6 document_shares（M4 新增）

```sql
CREATE TABLE document_shares (
    id            BIGINT PRIMARY KEY,
    document_id   BIGINT NOT NULL,
    token         VARCHAR(64) NOT NULL UNIQUE,   -- 随机字符串
    creator_id    BIGINT NOT NULL,
    role          SMALLINT NOT NULL DEFAULT 0,   -- 分享链接授予的角色
    password_hash VARCHAR(128),                  -- 可选密码
    expires_at    TIMESTAMPTZ,                   -- 过期时间
    max_visits    INT,                           -- 最大访问次数
    visit_count   INT NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    revoked_at    TIMESTAMPTZ
);
CREATE INDEX idx_shares_doc ON document_shares(document_id);
```

---

## 3. API 设计

### 3.1 REST 路由汇总

所有路由挂载在 `/api/office` prefix 下，除公开的 `/share/*` 外均需 JWT 鉴权。

| Milestone | 方法 | 路径 | 功能 |
|-----------|------|------|------|
| 已有 | GET  | `/api/office/spaces` | 空间列表 |
| 已有 | POST | `/api/office/spaces` | 创建空间 |
| 已有 | PUT  | `/api/office/spaces/{id}` | 更新空间 |
| 已有 | DELETE | `/api/office/spaces/{id}` | 删除空间 |
| 已有 | GET  | `/api/office/docs?space_id=` | 文档列表 |
| 已有 | POST | `/api/office/docs` | 创建文档 |
| 已有 | GET  | `/api/office/docs/{id}` | 获取文档元数据 |
| 已有 | PATCH | `/api/office/docs/{id}` | 更新标题 / 移动 |
| 已有 | DELETE | `/api/office/docs/{id}` | 删除文档 |
| 已有 | GET  | `/api/office/docs/{id}/edit-url` | 编辑 URL |
| M3   | POST | `/api/office/docs/search` | 全文搜索 |
| M3   | GET  | `/api/office/docs/trash` | 回收站列表 |
| M3   | POST | `/api/office/docs/{id}/restore` | 恢复文档 |
| M3   | DELETE | `/api/office/docs/{id}/purge` | 永久删除 |
| M3   | POST | `/api/office/docs/{id}/duplicate` | 复制文档（含子页面） |
| M3   | POST | `/api/office/docs/{id}/move` | 移动到新空间/新父级 |
| M3   | GET  | `/api/office/docs/starred` | 星标文档 |
| M3   | POST | `/api/office/docs/{id}/star` | 加/取消星标 |
| M3   | GET  | `/api/office/docs/recent` | 最近访问 |
| M3   | POST | `/api/office/docs/{id}/visit` | 记录访问 |
| M3   | GET  | `/api/office/docs/tree?space_id=` | 子页面树 |
| M4   | GET  | `/api/office/docs/{id}/members` | 成员列表 |
| M4   | POST | `/api/office/docs/{id}/members` | 添加成员 |
| M4   | PATCH | `/api/office/docs/{id}/members/{user_id}` | 修改角色 |
| M4   | DELETE | `/api/office/docs/{id}/members/{user_id}` | 移除成员 |
| M4   | POST | `/api/office/docs/{id}/share` | 创建共享链接 |
| M4   | GET  | `/api/office/docs/{id}/shares` | 分享链接列表 |
| M4   | DELETE | `/api/office/docs/shares/{share_id}` | 撤销链接 |
| M4   | POST | `/share/{token}/verify` | 密码校验（公开） |
| M4   | GET  | `/share/{token}` | 解析 token → 返回文档只读视图（公开） |
| 已有 | GET  | `/office/ws/{doc_id}` | Yjs WebSocket |

### 3.2 关键接口示例

#### M3 全文搜索

```json
// POST /api/office/docs/search
{
  "q": "项目规划",
  "space_id": 123,      // 可选：限定空间
  "limit": 20
}

// Response
{
  "items": [
    {
      "id": "789",
      "title": "项目规划",
      "space_id": "123",
      "highlight": "<em>项目</em>规划中...",
      "matched_in": "title",   // title | content
      "updated_at": "..."
    }
  ]
}
```

#### M4 创建共享链接

```json
// POST /api/office/docs/{id}/share
{
  "role": 0,                              // viewer / commenter
  "password": "1234",                     // 可选
  "expires_at": "2026-08-01T00:00:00Z",   // 可选
  "max_visits": 100                       // 可选
}

// Response
{
  "id": "sh_xxx",
  "token": "abcdef12345",
  "url": "https://buzzing.com/share/abcdef12345",
  "role": 0,
  "expires_at": "..."
}
```

#### M4 通过共享链接访问

```
1. 用户访问 /share/{token}
2. 前端 GET /share/{token}
3. 后端:
   - 校验 token 有效性 (未撤销、未过期、未超次)
   - 若有密码，要求 POST /share/{token}/verify
   - 校验通过后返回临时 JWT (含 role + doc_id)
4. 前端携带此 JWT 打开 /office/editor/{doc_id}?readonly=1
5. WebSocket 连接使用同一 JWT，后端限制其为 read-only awareness
```

---

## 4. 后端实现

### 4.1 模块目录结构（Phase A 完成态）

```
backend/office/
├── Cargo.toml
├── src/
│   ├── lib.rs
│   ├── controllers/
│   │   ├── mod.rs
│   │   ├── auth.rs
│   │   ├── spaces.rs
│   │   ├── docs.rs         # M1/M2/M3 基础 CRUD
│   │   ├── search.rs       # M3
│   │   ├── trash.rs        # M3
│   │   ├── stars.rs        # M3
│   │   ├── visits.rs       # M3
│   │   ├── members.rs      # M4
│   │   └── shares.rs       # M4
│   ├── middleware/
│   │   └── permission.rs   # M4 权限校验
│   ├── models/
│   ├── ws.rs               # Yjs WS
│   └── yjs_store.rs        # Yjs 持久化
```

### 4.2 权限中间件（M4）

```rust
// middleware/permission.rs
pub enum Role { Viewer = 0, Commenter = 1, Editor = 2, Owner = 3 }

pub async fn require_role(
    ctx: &AppContext,
    user_id: i64,
    doc_id: i64,
    min_role: Role,
) -> Result<Role> {
    // 1. 若为 owner (documents.creator == user_id) → Owner
    // 2. 否则查 document_members
    // 3. 否则回退到 space 级权限（若空间有 members 表）
    // 4. 否则返回 403
}
```

所有涉及文档写操作的 controller 前置调用 `require_role`。M4 之前所有认证用户具备 `editor`。

### 4.3 Yjs 持久化策略（M2 增强）

```
触发时机：
  - 每 30 秒定时快照（有变更时）
  - 最后一个连接断开时立即持久化
  - 服务端优雅关闭前统一保存

保存方式：
  1. Yjs Doc.encode_state_as_update_v1() 获取当前快照
  2. 写入 documents.content (BYTEA) + 更新 version = now_ms
  3. M5 起会同时插入 document_versions 记录（快照 + 时间 + 作者）

加载方式：
  1. 从 documents.content 读取二进制
  2. 新 Yjs Doc apply_update() 恢复状态
  3. 挂到 BroadcastGroup

M2 附加：
  - 保存前 flush pending awareness（避免退出瞬间的光标丢失）
  - 保存成功后向所有连接推送 saved_at 时间戳供前端显示"已保存"
```

### 4.4 全文搜索方案（M3）

```
方案：PostgreSQL 全文检索
  - documents.title 直接 GIN 索引 (search_tsv 生成列)
  - documents.content 是 Yjs 二进制，不能直接 tsvector
    → 每次保存快照时，同步生成纯文本 plain_text 字段，单独索引
      documents.plain_text TEXT
      GIN idx_documents_plain_text_tsv (to_tsvector('simple', plain_text))
  - 提取纯文本：yrs XmlFragment.get_string() 或遍历 ProseMirror JSON
  - 中文分词：先用 'simple' 分词（按字），后续可引入 pg_jieba

查询：
  SELECT id, title, ts_headline('simple', plain_text, query) AS highlight
  FROM documents
  WHERE search_tsv @@ query OR to_tsvector('simple', plain_text) @@ query
  ORDER BY ts_rank(search_tsv, query) DESC
  LIMIT 20;
```

### 4.5 M2 保存状态推送

在 Yjs WebSocket 侧新增自定义消息：

```
Server → Client:
  { type: "saved", at: <ms> }         // 每次持久化成功后广播
  { type: "syncing" }                 // 收到 update 但未 flush

Client → Server:
  awareness update (y-websocket 内置)
```

前端 SyncStatus 组件订阅上述消息展示"已保存"/"保存中"。

---

## 5. 前端实现

### 5.1 目录结构（Phase A 完成态）

```
frontend/src/
├── router/                    # 已有
├── stores/
│   ├── auth.ts                # 已有
│   ├── document.ts            # 已有
│   └── search.ts              # M3
├── services/
│   ├── api.ts                 # 已有 (axios)
│   └── office/
│       ├── docs.ts            # M1
│       ├── search.ts          # M3
│       ├── members.ts         # M4
│       └── shares.ts          # M4
├── views/office/
│   ├── HomeView.vue           # 已有：主页
│   ├── EditorView.vue         # 已有：编辑器
│   ├── TrashView.vue          # M3
│   ├── SearchView.vue         # M3
│   ├── ShareView.vue          # M4 只读视图
│   ├── composables/
│   │   ├── useEditorSchema.ts # M1 ✅
│   │   ├── useToolbarState.ts # M1 ✅
│   │   ├── useSlashMenu.ts    # M1 ✅
│   │   ├── useYjs.ts          # M1 ✅ / M2 扩展 (saved_at)
│   │   ├── useSaveStatus.ts   # M2
│   │   └── usePermission.ts   # M4
│   └── components/
│       ├── TitleBar.vue       # M1 ✅
│       ├── Toolbar.vue        # M1 ✅
│       ├── FloatingToolbar.vue # M1 ✅
│       ├── ToolbarButton.vue  # M1 ✅
│       ├── ToolbarDivider.vue # M1 ✅
│       ├── ToolbarDropdown.vue# M1 ✅
│       ├── SlashMenu.vue      # M1 ✅
│       ├── LinkDialog.vue     # M1 ✅
│       ├── ImageUpload.vue    # M1 ✅
│       ├── ProseEditor.vue    # M1 ✅
│       ├── SpaceTree.vue      # 已有 / M3 拖拽排序
│       ├── DocList.vue        # 已有 / M3 面包屑 + 子页面树
│       ├── Collaborators.vue  # M1 已有 / M2 增强 (名字标签)
│       ├── SyncStatus.vue     # M2
│       ├── SearchBar.vue      # M3
│       ├── Breadcrumb.vue     # M3
│       ├── MoveDialog.vue     # M3
│       ├── MemberDialog.vue   # M4
│       └── ShareDialog.vue    # M4
└── styles/
    └── editor.css             # 已有 M1
```

### 5.2 路由扩展

```typescript
// router/index.ts
const routes = [
  { path: '/office/login', component: LoginView },
  {
    path: '/office',
    component: DefaultLayout,
    beforeEnter: authGuard,
    children: [
      { path: '', component: HomeView },
      { path: 'trash', component: TrashView },              // M3
      { path: 'search', component: SearchView },            // M3
      { path: 'editor/:docId', component: EditorView },
    ],
  },
  { path: '/share/:token', component: ShareView },          // M4 公开
]
```

### 5.3 关键前端流程

#### M2 保存状态

```
useSaveStatus(provider):
  - 监听 provider 的自定义 message (type: 'saved' / 'syncing')
  - 监听 provider.wsconnected / wsconnecting / wsopen
  - 输出 ref<'saved' | 'saving' | 'offline' | 'error'> + savedAt
  - IndexedDB (y-indexeddb) 提供本地缓存，网络中断时 UI 显示 "离线，本地已保存"
```

#### M3 全文搜索

```
Cmd+K → 打开搜索弹层 (SearchBar Teleport)
  → 输入关键词 (debounce 200ms)
  → POST /api/office/docs/search
  → 展示结果 (标题/空间/高亮片段)
  → 上下键选择 + Enter 跳转编辑器
```

#### M4 权限视图

```
EditorView 加载时:
  - 请求 GET /api/office/docs/{id}（响应含当前用户 role）
  - usePermission composable 全局提供 role
  - readonly = role === 'viewer'
  - readonly=true 时:
    * ProseEditor.editable = false
    * Toolbar 隐藏
    * WS 连接仍然建立以看到实时协作，但本地不 dispatch 编辑事务
```

### 5.4 ProseMirror Schema

Schema 定义见下文 §12.3「Schema 设计」。M2-M4 不改动 schema，仅通过 plugin 增强行为。

---

## 6. SDK 变更

### 6.1 BizOffice Trait（M3/M4 扩展）

```rust
#[async_trait]
pub trait BizOffice: Send + Sync {
    // M1 已有
    async fn create_document(&self, space_id: i64, title: &str) -> Result<DocInfo>;
    async fn list_documents(&self, space_id: i64) -> Result<Vec<DocInfo>>;
    async fn get_document(&self, doc_id: i64) -> Result<DocInfo>;
    async fn update_document(&self, doc_id: i64, title: &str) -> Result<()>;
    async fn delete_document(&self, doc_id: i64) -> Result<()>;
    async fn get_edit_url(&self, doc_id: i64) -> Result<String>;
    async fn list_spaces(&self) -> Result<Vec<SpaceInfo>>;
    async fn create_space(&self, name: &str) -> Result<SpaceInfo>;

    // M3 新增
    async fn search(&self, q: &str, space_id: Option<i64>) -> Result<Vec<SearchHit>>;
    async fn list_trash(&self) -> Result<Vec<DocInfo>>;
    async fn restore_document(&self, doc_id: i64) -> Result<()>;
    async fn list_starred(&self) -> Result<Vec<DocInfo>>;
    async fn toggle_star(&self, doc_id: i64) -> Result<bool>;
    async fn list_recent(&self, limit: u32) -> Result<Vec<DocInfo>>;
    async fn move_document(&self, doc_id: i64, space_id: i64, parent_id: Option<i64>) -> Result<()>;

    // M4 新增
    async fn list_members(&self, doc_id: i64) -> Result<Vec<MemberInfo>>;
    async fn add_member(&self, doc_id: i64, user_id: i64, role: i32) -> Result<()>;
    async fn update_member_role(&self, doc_id: i64, user_id: i64, role: i32) -> Result<()>;
    async fn remove_member(&self, doc_id: i64, user_id: i64) -> Result<()>;
    async fn create_share(&self, doc_id: i64, opts: ShareOptions) -> Result<ShareInfo>;
    async fn list_shares(&self, doc_id: i64) -> Result<Vec<ShareInfo>>;
    async fn revoke_share(&self, share_id: i64) -> Result<()>;
}
```

### 6.2 通信方式

SDK 通过 HTTP JSON 调用 `/api/office/*`，不走 protobuf 编码（与 Phase A 之前保持一致）。

---

## 7. Flutter 客户端

Phase A 阶段 Flutter 仍以**列表 + 跳转浏览器**为主：

- **M1** — 无需变更（编辑器纯 Web）
- **M2** — 列表页可选择性展示"最近编辑者"头像
- **M3** — 列表页支持搜索栏、回收站入口、星标筛选、子页面树、面包屑
- **M4** — 列表项显示权限徽章、分享入口打开系统浏览器

原生编辑器与移动端只读视图在 **M6（Phase B）** 落地，此处不做展开。

---

## 8. 实施顺序

### M1 — 已完成 ✅
按附录 §12.6「实施顺序」分 10 步实施：schema → 工具栏 → 标题 → 链接 → 图片 → 任务/代码块 → 表格 → 快捷键 → 斜杠菜单 → 样式。

### M2 — 协作增强

| # | 任务 | 预估 |
|---|------|------|
| 1 | Yjs WS 增加 `saved`/`syncing` 广播 | 0.5d |
| 2 | 前端 `useSaveStatus` + `SyncStatus.vue` | 1d |
| 3 | Collaborators.vue 光标名字标签 + 选区高亮 | 1d |
| 4 | 断线指数退避 + IndexedDB 本地缓存 | 1d |
| 5 | BroadcastGroup 上限配置化 | 0.5d |
| 6 | 手工回归 3 人协作场景 | 1d |
| **合计** | | **5d** |

### M3 — 文档管理

| # | 任务 | 预估 |
|---|------|------|
| 1 | DB 迁移：parent_id / trashed_at / stars / visits / plain_text | 1d |
| 2 | Yjs 快照生成 plain_text 副本 | 1d |
| 3 | 后端 search / trash / stars / visits / move / duplicate 端点 | 3d |
| 4 | 前端 SearchBar + SearchView + Cmd+K 快捷键 | 1.5d |
| 5 | TrashView + 恢复/永久删除 | 1d |
| 6 | 面包屑 + 子页面树（SpaceTree 改造） | 2d |
| 7 | 星标 / 最近访问入口 | 1d |
| 8 | 空间管理增强（图标/颜色/排序） | 1d |
| **合计** | | **11.5d** |

### M4 — 权限与分享

| # | 任务 | 预估 |
|---|------|------|
| 1 | 权限中间件 `require_role` | 1d |
| 2 | members CRUD 端点 | 1.5d |
| 3 | shares CRUD + 公开 `/share/{token}` 端点 | 2d |
| 4 | 前端 MemberDialog + ShareDialog | 2d |
| 5 | ShareView.vue（只读视图） | 1d |
| 6 | 权限徽章 + Toolbar 只读模式切换 | 1d |
| 7 | 用户搜索器接入（复用 contact） | 0.5d |
| **合计** | | **9d** |

---

## 9. 部署

前端 SPA 构建产物通过 `rust-embed` 编译期嵌入 Rust 二进制，axum 路由直接 serve。**单二进制部署**，前端与后端版本永远一致。

开发环境使用 `vite dev` + 后端 API 代理，不影响开发体验。详见 `frontend/vite.config.ts` 中的 proxy 配置。

---

## 10. 附录：M1 编辑器详细设计

> 本附录包含 M1（编辑器完善）阶段的详细设计，内容原独立为 `office_pa_m1_design.md`，现合并至此。
> 所有实现已在 Phase A 完成。

### 10.1 概述

M1 的目标是把编辑器从"基础可写"提升到"可编辑结构化文档"，达到主流富文本编辑器水准。所有实现均在前端（`frontend/src/views/office/`）完成，后端复用 `store` 模块的文件上传能力和已有的 `PATCH /api/office/docs/{id}` 更新接口。

#### 交互形态选择

M1 编辑器采用 **纯浮动交互** 模式（Notion / Craft / 飞书文档同款）：

- **FloatingToolbar** — 选中文本时在选区上方浮出的格式工具条（marks + 标题 + 引用 + 链接 + 清除格式）
- **SlashMenu** — 在块起始输入 `/` 唤起，用于插入块级元素（列表、代码块、表格、分割线、图片等）
- **LinkDialog / ImageUpload** — 由 FloatingToolbar / SlashMenu / 快捷键触发的辅助弹层

**不设固定顶部工具栏**，让编辑区更沉浸；工具栏组件（`Toolbar.vue` + `ToolbarButton/Divider/Dropdown`）作为**可复用的原子组件保留**，供后续在需要固定栏的场景（如 comments、只读注解视图）复用。

#### 范围

| 模块 | 变更 |
|------|------|
| 前端 | 扩展 Schema，新增 TitleBar / FloatingToolbar / SlashMenu / LinkDialog / ImageUpload |
| 后端 | 复用 `POST /api/files/upload` 与 `PATCH /api/office/docs/{id}` |
| 数据库 | 无变更 |

### 10.2 组件架构

#### 组件树

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

#### 组件职责

| 组件 | 输入 (Props / Inject) | 输出 |
|------|----------------------|------|
| TitleBar | `docId` | debounce 500ms → PATCH `/api/office/docs/{id}` |
| FloatingToolbar | `editorView` inject | 选区变化时浮现，执行 ProseMirror 命令 |
| LinkDialog | `open`, `editorView` inject | 插入 / 编辑 / 移除 link mark |
| ImageUpload | `editorView` inject | 上传后 dispatch insertImage |
| SlashMenu | `editorView` / `schema` inject | 触发 setBlockType / wrapIn / insertNode 等命令 |
| ProseEditor | `yjs-type`, `yjs-provider` inject | provide `editorView`, `schema`；管理 LinkDialog 状态 |

#### composable 划分

| composable | 职责 |
|-----------|------|
| `useEditorSchema.ts` | 定义 Schema、装配所有 plugin、`mount` / `destroy` |
| `useToolbarState.ts` | 通过 ProseMirror plugin 追踪当前选区 marks / node / 浮动条位置，提供响应式 `activeMarks` / `activeNode` / `headingLevel` / `showFloating` / `floatingLeft` / `floatingTop` |
| `useSlashMenu.ts` | 斜杠菜单 plugin：监听 `/`、维护 filter、暴露 `visible/position/execute` |

### 10.3 Schema 设计

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
    taskList:         { content: 'taskItem+', group: 'block' },
    taskItem:         { content: 'paragraph block*', attrs: { checked: false } },
    codeBlock:        { content: 'text*', marks: '', group: 'block',
                        attrs: { language: '' }, code: true },
    blockquote:       { content: 'block+', group: 'block' },
    horizontalRule:   { group: 'block' },
    image:            { inline: true, attrs: { src, alt, title }, group: 'inline' },
    hardBreak:        { inline: true, group: 'inline' },
    ...tableNodes({ tableGroup: 'block', cellContent: 'block+' }),
  },
  marks: {
    link:       { attrs: { href, title } },
    em:         {},
    strong:     {},
    code:       {},
    underline:  {},
    strike:     {},
  },
})
```

#### 节点/标记设计要点

- **taskList / taskItem**：渲染 `<ul data-type="taskList"><li data-type="taskItem" data-checked>`；CSS `::before` 画 checkbox；点击左侧 28px 区域切换 `checked`；输入 `[]`/`[x]` 自动转换；空 taskItem Enter 退化为段落
- **codeBlock**：`language` attr 保留，语法高亮推迟至 M9；快捷键 `Ctrl+Shift+C`
- **table**：`prosemirror-tables` 提供的 `tableNodes` / `tableEditing` / `columnResizing`；Tab 改为 `goToNextCell`；增删行列推迟至 M9
- **underline / strike**：渲染 `<u>` / `<s>`；快捷键 `Ctrl+U` / `Ctrl+Shift+S`

### 10.4 数据流

#### 浮动工具栏 & 选区

```
用户改变选区
  → ProseMirror plugin (useToolbarState) 触发 view.update
  → 计算 selection.empty / coordsAtPos(from) / coordsAtPos(to)
  → 更新响应式 showFloating / floatingLeft / floatingTop
  → FloatingToolbar 通过 Teleport 渲染到 body，绝对定位到选区上方
  → 用户点击按钮 → 执行 ProseMirror command → 派发到 Yjs → 同步其他协作者
  → activeMarks / activeNode 响应式更新，按钮 active 态跟随
```

#### 标题自动保存

```
用户输入 → TitleBar input event → title ref 更新
  → debounce 500ms → PATCH /api/office/docs/{id} { title }
  → 失败静默（下次进入编辑器会重新拉取）
```

#### 图片上传

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

#### 链接

```
触发方式：
  1. FloatingToolbar 的链接按钮 → emit link → ProseEditor 打开 LinkDialog
  2. Ctrl+K 快捷键 → EditorView 层拦截 → 打开 LinkDialog

LinkDialog 逻辑：
  打开时检测当前选区是否已有 link mark
    有 → 编辑模式（预填 href/text，显示"移除链接"按钮）
    无 → 新增模式（若选中文本，预填 text）
  确认 → dispatch removeMark + addMark
  移除 → dispatch removeMark
```

#### 斜杠命令

```
用户在块起始位置输入 '/'
  → useSlashMenu plugin handleTextInput 拦截，设置 active=true
  → SlashMenu 组件监听 plugin state 显示菜单，位置来自 coordsAtPos
  → 用户输入过滤词 (handleTextInput 累加 filter)
  → ↑↓ 选择，Enter 执行选中项的 command
  → Esc / Backspace(空 filter) 关闭
```

### 10.5 后端变更

M1 阶段**无后端代码变更**，仅复用：

| 接口 | 说明 |
|------|------|
| `GET /api/office/docs/{id}` | 文档元数据查询 |
| `PATCH /api/office/docs/{id}` | 更新标题 |
| `POST /api/files/upload` | 文件上传（store 模块） |
| `GET /api/files/{id}` | 文件下载 / inline 预览 |
| `GET /office/ws/{doc_id}` | Yjs 协作 WS |

### 10.6 实施顺序

M1 按以下顺序实施：

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

### 10.7 快捷键映射

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

### 10.8 样式规范

#### 浮动工具栏（M1 主交互）
- 通过 `<Teleport to="body">` 渲染，绝对定位在选区上方约 48px
- 圆角 8px + `box-shadow: 0 4px 16px rgba(0,0,0,0.15)`
- 按钮 28×28px，圆角 4px；分隔线 1px × 20px
- Active：背景 `#e3f2fd` / 文字 `#1565c0`；Hover：背景 `#f0f0f0`

#### 标题编辑
- 字号 24px / 字重 600；无边框，hover 显示浅色底边；占位符 "无标题"

#### 新增元素样式（`editor.css`）

| 元素 | 样式要点 |
|------|--------|
| 表格 | `border-collapse: collapse`；单元格边框 `#ccc`；header 背景 `#f5f5f5`；`column-resize-handle` 蓝色高亮 |
| 任务列表 | 列表无点，`::before` 画 18×18 checkbox；`data-checked=true` 时填充 `#1565c0` + 白色对号 + 文字半透明删除线 |
| 代码块 | 暗色 `#1e1e1e` / 文字 `#d4d4d4`；等宽字体；圆角 6px |
| 图片 | `max-width: 100%`；`cursor: pointer` |
| 链接 | `color: #1565c0`；下划线 |
| 斜杠菜单 | 圆角 8px；`box-shadow: 0 4px 12px rgba(0,0,0,0.15)`；每项 32px 高 |
| 协作者光标 | 左侧 2px 竖线；顶部小名字标签（浮动） |

### 10.9 文件变更清单

#### 新增（M1 主交互）

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

#### 新增（原子组件，M1 未挂载，供后续复用）

| 文件 | 说明 |
|------|------|
| `frontend/src/views/office/components/Toolbar.vue` | 通用工具栏容器 |
| `frontend/src/views/office/components/ToolbarButton.vue` | 原子按钮 |
| `frontend/src/views/office/components/ToolbarDivider.vue` | 分隔线 |
| `frontend/src/views/office/components/ToolbarDropdown.vue` | 下拉选择 |

#### 修改

| 文件 | 变更内容 |
|------|---------|
| `frontend/src/views/office/EditorView.vue` | 集成 TitleBar + provide yjs-type/provider；拦截 Ctrl+K 传递给 ProseEditor |
| `frontend/src/views/office/components/ProseEditor.vue` | 通过 `useEditorSchema` 挂载 + provide editorView/schema，接入 FloatingToolbar / SlashMenu / LinkDialog / ImageUpload |
| `frontend/src/styles/editor.css` | 增加表格 / 任务列表 / 代码块 / 暗色代码块 / 下划线 / 删除线 / 浮动条位置样式 |

### 10.10 遗留 / 后续处理

| 项 | 归属 |
|----|------|
| 代码块语言下拉 + 语法高亮 | M9（富组件） |
| 表格右键菜单（增删行列） | M9 |
| 标题编辑成功提示 / 冲突恢复 | M2（保存状态指示） |
| 图片点击查看原图 / 拖拽调整大小 | M9 |
| 中文输入法下 `/` 触发斜杠菜单的兼容 | 若有反馈再优化 |

### 10.11 验收清单

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

---

## 11. 相关文档

- Phase A PRD：[office_pa.md](./office_pa.md)
- 全局路线图：[office_roadmap.md](./office_roadmap.md)
- 文件上传设计：[file_upload_design.md](./file_upload_design.md)
