# 文档 & 知识库权限模型

## 角色定义

### 文档角色

| 角色 | 值 | 说明 |
|------|-----|------|
| `Viewer` | 0 | 只读 |
| `Commenter` | 1 | 可评论 |
| `Editor` | 2 | 可编辑 |
| `Owner` | 3 | 所有者（仅创建者） |

### 知识库角色

| 角色 | 值 | 说明 |
|------|-----|------|
| `Viewer` | 0 | 只读 |
| `Editor` | 2 | 可编辑 |
| `Admin` | 3 | 管理员（可管理成员/设置） |
| `Owner` | 4 | 所有者（仅创建者） |

## 文档权限解析 (`resolve_role`)

按序判断，命中最优路径后返回：

1. **创建者** → `Owner`
2. **`document_members` 表** → 直接角色（个人文档/知识库文档均可通过此表添加协作者）
3. **个人文档**（`wiki_id IS NULL`）非创建者且不在 `document_members` 中 → 无权限
4. **知识库继承**：通过 `documents.wiki_id` → `wikis` → `wiki_members` / 可见性

### 知识库→文档角色映射

| 知识库角色 | 映射为文档角色 |
|------------|---------------|
| `Owner` (4) | `Owner` (3) |
| `Admin` (3) | `Editor` (2) |
| `Editor` (2) | `Editor` (2) |
| `Viewer` (1) | `Viewer` (0) |

## 知识库权限解析 (`resolve_wiki_role`)

1. **创建者** → `Owner`
2. **`wiki_members` 表** → 对应角色
3. **`visibility == 1`（组织内全员可见）** → `Viewer`
4. 否则 → 无权限

## 知识库可见性

| 可见性 | 值 | 说明 |
|--------|-----|------|
| `仅成员可见` | 0 | 仅创建者 + wiki_members 可见 |
| `组织内全员可见` | 1 | 同租户所有用户至少获得 Viewer |

## 共享链接 (`document_shares`)

共享链接绕过文档权限解析，直接通过 `share:{share_id}:{doc_id}` 格式的 JWT 令牌鉴权：

- 令牌中编码了 `role`（创建共享时指定）
- WS 连接时对比令牌中的 `doc_id` 与请求路径中的 `doc_id`，一致则放行
- 可选密码保护、过期时间、最大访问次数

## 前端只读判断 (`EditorContent`)

```
isReadonly = role < ROLE_EDITOR || isPreview
```

- `role` 来源于 `docsApi.get()` 返回的权限解析结果
- `isPreview` 是用户手动切换的预览模式

## 关键数据表

### `documents`

```rust
pub struct Model {
    pub id: i64,                     // Snowflake
    pub tenant_id: i64,
    pub creator: i64,                // 文档创建者（所有者）
    pub wiki_id: Option<i64>,        // 所属知识库，NULL 表示为个人文档
    pub parent_id: Option<i64>,      // 父文档 ID，个人文档顶级 parent_id = user_id
    // ...
}
```

### `wikis`

```rust
pub struct Model {
    pub id: i64,
    pub tenant_id: i64,
    pub creator_id: i64,
    pub visibility: i32,             // 0=仅成员, 1=组织内全员
    pub allow_external_share: bool,
    pub reader_permission: i32,      // 读者可获得的最低文档权限
    // ...
}
```

### `document_members`

```rust
pub struct Model {
    pub doc_id: i64,
    pub user_id: i64,
    pub role: i32,                   // 文档角色值
    pub joined_at: i64,
}
```

### `wiki_members`

```rust
pub struct Model {
    pub wiki_id: i64,
    pub user_id: i64,
    pub role: i16,                   // 知识库角色值
    pub joined_at: i64,
}
```

### `document_shares`

```rust
pub struct Model {
    pub id: i64,
    pub document_id: i64,
    pub token: String,              // 唯一令牌
    pub creator_id: i64,
    pub role: i16,                  // 共享允许的角色 (Viewer/Commenter)
    pub password_hash: Option<String>,
    pub expires_at: Option<DateTimeWithTimeZone>,
    pub max_visits: Option<i32>,
    pub visit_count: i32,
    pub revoked_at: Option<DateTimeWithTimeZone>,
}
```
