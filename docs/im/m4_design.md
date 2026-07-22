# M4: 搜索与发现 — 设计方案

> 目标：建立全局搜索能力，让用户可以快速找到消息、联系人、文件和群。

---

## 1. 技术选型

**搜索引擎**: PostgreSQL `pg_trgm` 扩展（不引入独立搜索引擎，减少运维复杂度）。

**选择理由**:
- 当前消息只搜索 `summary` 字段（短文本），`pg_trgm` 已足够
- 无需额外部署 Elasticsearch / Meilisearch
- 与 office 模块的 `tsvector` 全文搜索互补（office 搜索长文档，消息搜索短文本）

**索引方案**:
```sql
-- 1. 消息搜索：pg_trgm GIN 索引，支持模糊匹配
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_summary_trgm
  ON messages USING GIN (summary gin_trgm_ops);

-- 2. 会话搜索：已有 name 上的 like 搜索，补充 trgm 索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_chats_name_trgm
  ON chats USING GIN (name gin_trgm_ops);

-- 3. 用户搜索：name / email 上的 trgm 索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_name_trgm
  ON users USING GIN (name gin_trgm_ops);
```

**高亮方案**: 搜索结果返回匹配片段（前/后截断 + 匹配部分标记），Flutter 端用 RichText 渲染。

---

## 2. 搜索范围与权限

| 搜索类型 | 数据源 | 权限约束 |
|---------|--------|---------|
| 消息搜索 | `messages` 表 | 只能搜用户所在群的群消息 + 参与过的 P2P 消息 |
| 会话搜索 | `chats` 表 | 只能搜用户加入的会话 |
| 用户搜索 | `users` 表 | 只能搜同一租户下的成员 |
| 文件搜索 | `files` 表 | 只能搜用户上传或有权限的文件 |
| 全局搜索 | 以上全部 | 各类型独立权限约束，合并返回 |

---

## 3. Proto 定义

### 3.1 现有（已定义但未实现）

```protobuf
// command.proto (已存在)
SEARCH_USER    = 1400;
SEARCH_MESSAGE = 1401;
SEARCH_CHAT    = 1402;
```

### 3.2 新增消息类型

#### search.proto（新建）

```protobuf
syntax = "proto3";
package search;
option go_package = "./proto";

// ── 通用搜索请求 ──

message SearchFilter {
  // 消息搜索过滤
  int64 chat_id = 1;       // 0 = 不限
  int64 from_id = 2;       // 0 = 不限
  int32 msg_type = 3;      // 0 = 不限（MessageType 枚举值）
  int64 time_start_ms = 4; // 0 = 不限
  int64 time_end_ms = 5;   // 0 = 不限
}

message SearchRequest {
  string keyword = 1;
  int32 page = 2;           // 从 1 开始
  int32 page_size = 3;      // 默认 20
  SearchFilter filter = 4;
}

// ── 消息搜索 ──

message MessageSearchResult {
  entity.Message message = 1;
  string highlight = 2;   // 高亮片段（关键词附近上下文）
}

message SearchMessagesResponse {
  repeated MessageSearchResult results = 1;
  int32 total = 2;
}

// ── 会话搜索 ──

message ChatSearchResult {
  entity.Chat chat = 1;
  string highlight = 2;
}

message SearchChatsResponse {
  repeated ChatSearchResult results = 1;
  int32 total = 2;
}

// ── 用户搜索 ──

message UserSearchResult {
  entity.User user = 1;
  string highlight = 2;
}

message SearchUsersResponse {
  repeated UserSearchResult results = 1;
  int32 total = 2;
}

// ── 文件搜索 ──

message FileSearchResult {
  string file_id = 1;
  string file_name = 2;
  string mime_type = 3;
  int64 size = 4;
  string url = 5;
  string highlight = 6;
  int64 created_at_ms = 7;
}

message SearchFilesResponse {
  repeated FileSearchResult results = 1;
  int32 total = 2;
}

// ── 全局搜索（合并搜索结果） ──

message GlobalSearchRequest {
  string keyword = 1;
  int32 page = 2;
  int32 page_size = 3;
  // 如果为空则搜全部
  repeated string types = 4; // "message", "chat", "user", "file"
}

message GlobalSearchResponse {
  repeated MessageSearchResult messages = 1;
  repeated ChatSearchResult chats = 2;
  repeated UserSearchResult users = 3;
  repeated FileSearchResult files = 4;
  int32 message_total = 5;
  int32 chat_total = 6;
  int32 user_total = 7;
  int32 file_total = 8;
}
```

### 3.3 command.proto 更新

```protobuf
// 已有（无需修改）
SEARCH_USER    = 1400;
SEARCH_MESSAGE = 1401;
SEARCH_CHAT    = 1402;

// 新增
SEARCH_FILES   = 1405;
GLOBAL_SEARCH  = 1406;
```

---

## 4. 后端设计

### 4.1 模块划分

所有搜索 handler 集中在 `backend/im/src/search/` 目录下：
- `mod.rs` — 路由注册 + 公共工具
- `messages.rs` — 消息搜索 (`SEARCH_MESSAGE`)
- `chats.rs` — 会话搜索 (`SEARCH_CHAT`)
- `global.rs` — 全局搜索 (`GLOBAL_SEARCH`)
- `users.rs` — 用户搜索 (`SEARCH_USER`)

### 4.2 消息搜索逻辑 (`messages.rs`)

```rust
pub async fn search_messages(
    ctx: &AppContext, brief: &UserBrief, packet: &Packet, _ws: bool,
) -> Result<(i32, Vec<u8>)> {
    let req = pb_decode::<SearchRequest>(&packet.payload)?;
    let keyword = req.keyword.trim();
    if keyword.is_empty() { return Ok((0, SearchMessagesResponse::default().encode_to_vec())); }

    // 1. 获取用户有权限的 chat_id 列表（用户所在的群 + P2P 聊天）
    let chat_ids = MemberModel::find_by_user(ctx, brief.user_id).await?;

    // 2. 构建 pg_trgm 模糊搜索 SQL
    //    WHERE chat_id IN (chat_ids)
    //      AND summary % keyword
    //      AND (filter.chat_id == 0 OR chat_id = filter.chat_id)
    //      AND (filter.from_id == 0 OR from_id = filter.from_id)
    //      AND (filter.msg_type == 0 OR tpy = filter.msg_type)
    //      AND (filter.time_start_ms == 0 OR create_time_ms >= filter.time_start_ms)
    //      AND (filter.time_end_ms == 0 OR create_time_ms <= filter.time_end_ms)
    //    ORDER BY similarity(summary, keyword) DESC, create_time_ms DESC
    //    LIMIT page_size OFFSET (page-1)*page_size

    // 3. 生成高亮片段（关键词前后截断 30 字符）
    //    "xxx关键词xxx..." -> prefix<mark>keyword</mark>suffix

    // 4. 返回 SearchMessagesResponse
}
```

**权限约束**: 通过 `member` 表过滤，只返回用户所在的群组和 P2P 聊天中的消息。

### 4.3 会话搜索逻辑 (`chats.rs`)

```rust
// 搜索用户加入的会话
// WHERE (user_id = brief.user_id) 的 chat_id
//   AND name % keyword
// ORDER BY similarity(name, keyword) DESC
```

### 4.4 用户搜索逻辑 (`users.rs`)

```rust
// 搜索同一租户下的用户
// WHERE tenant_id = brief.tenant_id
//   AND (name % keyword OR email % keyword)
// ORDER BY similarity(name, keyword) DESC
```

### 4.5 全局搜索逻辑 (`global.rs`)

```rust
// 并行调用 messages / chats / users / files 搜索
// 各类型返回 top N 条
// 合并到 GlobalSearchResponse
```

### 4.6 路由注册

`backend/im/src/lib.rs`:
```rust
Command::SearchMessage => search::messages::search_messages(...),
Command::SearchChat => search::chats::search_chats(...),
Command::SearchUser => search::users::search_users(...),
Command::SearchFiles => search::files::search_files(...),
Command::GlobalSearch => search::global::global_search(...),
```

---

## 5. SDK 设计

在 `sdk/app-chat/src/` 中新增：
- `search.rs` — 所有搜索命令的封装

```rust
pub async fn search_messages(&self, param: &[u8]) -> Result<(i32, Vec<u8>)> {
    let req = search::SearchRequest::decode(param)?;
    let ack = common_request(Command::SearchMessages, req.encode_to_vec()).await?;
    Ok((0, ack.encode_to_vec()))
}
// 类似: search_chats, search_users, search_files, global_search
```

在 `sdk/app-chat/src/lib.rs` 注册命令路由。

---

## 6. Flutter 客户端设计

### 6.1 搜索页面（`/search` 路由）

```
┌─────────────────────────────┐
│ 🔍 搜索消息、联系人、群       │  <- 搜索栏（自动 focus + debounce 300ms）
├─────────────────────────────┤
│ [消息] [联系人] [群] [文件]  │  <- Tab 切换分类
├─────────────────────────────┤
│ 📌 搜索历史                  │  <- 无结果或空关键词时显示
│ │ 最近一次搜索记录           │
├─────────────────────────────┤
│ 搜索结果列表                 │
│ ├── 消息结果                 │
│ │   @用户名: xxx<mark>关键</mark>xxx  │  <- 高亮渲染
│ │   14:32                    │
│ ├── 联系人结果               │
│ │   [头像] 用户名            │
│ ├── 群结果                   │
│ │   [头像] 群名              │
│ └── 文件结果                 │
│     [图标] 文件名.ext        │
│     2.3 MB · 14:32           │
└─────────────────────────────┘
```

### 6.2 组件拆分

| 组件 | 说明 |
|------|------|
| `SearchPage` | 搜索主页，管理搜索状态和 Tab 切换 |
| `SearchInput` | 搜索输入栏（debounce 300ms，i18n 提示） |
| `SearchHistory` | 最近搜索记录（本地存储） |
| `SearchTabBar` | [消息/联系人/群/文件] 分类 Tab |
| `MessageSearchResult` | 单条消息搜索结果（高亮渲染） |
| `ChatSearchResult` | 单个群的搜索结果 |
| `UserSearchResult` | 单个用户的搜索结果 |
| `FileSearchResult` | 单个文件的搜索结果 |
| `MessageSearchFilter` | 过滤面板（发送人/类型/时间） |

### 6.3 消息内搜索

点击聊天头部的搜索图标 → 打开当前会话的搜索浮层：
```
┌─────────────────────────────┐
│ 在本会话中搜索...            │  <- 搜索栏
│ [↑][↓] 2 个结果             │  <- 上/下翻页 + 结果计数
├─────────────────────────────┤
│ ← 消息列表定位到第一条匹配消息│
│ ← 匹配消息高亮               │
└─────────────────────────────┘
```

### 6.4 ImController 扩展

```dart
// 全局搜索
Future<GlobalSearchResponse> globalSearch(String keyword, {List<String>? types});

// 分类搜索
Future<SearchMessagesResponse> searchMessages(String keyword, {SearchFilter? filter, int page, int pageSize});
Future<SearchChatsResponse> searchChats(String keyword, {int page, int pageSize});
Future<SearchUsersResponse> searchUsers(String keyword, {int page, int pageSize});
Future<SearchFilesResponse> searchFiles(String keyword, {int page, int pageSize});

// 消息内搜索（当前会话）
Future<List<Message>> searchInChat(Int64 chatId, String keyword);

// 搜索历史管理
List<String> searchHistory;
void addSearchHistory(String keyword);
void clearSearchHistory();
```

### 6.5 高亮渲染

```dart
/// 将 "xxx<mark>keyword</mark>xxx..." 解析为 RichText
Widget _buildHighlightText(String raw, TextStyle baseStyle, ColorScheme cs) {
  final pattern = RegExp(r'<mark>(.*?)</mark>');
  final spans = <InlineSpan>[];
  int lastEnd = 0;
  for (final match in pattern.allMatches(raw)) {
    if (match.start > lastEnd) {
      spans.add(TextSpan(text: raw.substring(lastEnd, match.start), style: baseStyle));
    }
    spans.add(TextSpan(
      text: match.group(1),
      style: baseStyle.copyWith(
        color: cs.primary,
        fontWeight: FontWeight.w600,
        backgroundColor: cs.primary.withValues(alpha: 0.15),
      ),
    ));
    lastEnd = match.end;
  }
  if (lastEnd < raw.length) {
    spans.add(TextSpan(text: raw.substring(lastEnd), style: baseStyle));
  }
  return RichText(text: TextSpan(children: spans));
}
```

---

## 7. 分步实施计划

| 步骤 | 内容 | 工作量 |
|------|------|--------|
| Step 0 | Proto 定义 | 1d |
| Step 1 | DB 迁移（pg_trgm 扩展 + 索引） | 0.5d |
| Step 2 | 后端消息搜索 | 2d |
| Step 3 | 后端会话搜索 | 1d |
| Step 4 | 后端用户搜索 | 0.5d |
| Step 5 | 后端文件搜索 + 全局搜索 | 1.5d |
| Step 6 | SDK 封装 | 1d |
| Step 7 | Flutter 搜索页 + 全局搜索入口 | 3d |
| Step 8 | Flutter 消息内搜索 | 1.5d |
| **合计** | | **~12d** |

---

## 8. 边界情况与注意事项

1. **空关键词**: 所有搜索接口返回空结果（不走 DB）
2. **关键词过短**: `pg_trgm` 要求关键词 >= 3 字符（可配 `pg_trgm.word_similarity_threshold`）
3. **搜索历史**: 客户端本地存储最近 20 条搜索记录
4. **权限隔离**: 用户只能搜到自己有权限的数据
5. **性能**: 大租户下用户数 > 10w 时，用户搜索需要限制 `page_size` 上限
6. **高亮注入防御**: 服务端返回的 `highlight` 字段使用 `<mark>` 标记，Flutter 端必须进行 HTML 转义后再解析（防止 XSS-like 问题——虽然 Flutter 不是 HTML 渲染，但 `</mark>` 错乱会导致 UI 异常）
7. **文件搜索**: 搜索 `files` 表的 `file_name`，不走 object_store，只搜元数据表
8. **搜索与聊天列表融合**: 搜索页的「消息」结果点击后跳转到对应聊天并定位到消息位置
