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

见 [M1 详细设计](./office_pa_m1_design.md#3-prosemirror-schema-设计)。M2-M4 不改动 schema，仅通过 plugin 增强行为。

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
按 `office_pa_m1_design.md` 分 10 步实施：schema → 工具栏 → 标题 → 链接 → 图片 → 任务/代码块 → 表格 → 快捷键 → 斜杠菜单 → 样式。

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

## 10. 相关文档

- Phase A PRD：[office_pa.md](./office_pa.md)
- M1 详细设计：[office_pa_m1_design.md](./office_pa_m1_design.md)
- 全局路线图：[office_roadmap.md](./office_roadmap.md)
- 文件上传设计：[file_upload_design.md](./file_upload_design.md)
