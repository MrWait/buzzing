# M1: 消息类型扩展与媒体能力 — 设计文档

## 1. 概述

### 1.1 目标

在现有 IM 消息收发能力基础上，补齐图片、文件、富文本、转发、回复五种常用消息类型，建立媒体文件存储与管理基础设施。

### 1.2 范围

| 功能 | 说明 |
|------|------|
| 图片消息 | 上传、缩略图生成、预览、消息收发 |
| 文件消息 | 上传、下载、元数据管理、消息收发 |
| 富文本消息 | Quill Delta 格式，消息收发 |
| 消息转发 | 逐条转发 (single forward)、合并转发 (merged forward) |
| 消息回复 | 引用式回复 (quote reply)，支持嵌套链路 |

### 1.3 依赖修复

开始 M1 之前，先修复当前基线中的两个阻断 Bug：

| Bug | 文件 | 修复方式 |
|-----|------|----------|
| ChatQuit / ChatDismiss 注册但未路由 | `backend/im/src/lib.rs` | match 分支补全 |
| feed_update_read_pos 空实现 | `backend/im/src/feed.rs` | 实现 DB 更新 |

---

## 2. 架构设计

### 2.1 Message Content 结构化

当前 `entity.Message.content` 为不透明 `bytes`，消息展示逻辑仅靠 `tpy` 枚举区分。

**方案**: 保持 `tpy + bytes` 模式，每种消息类型有独立的 proto message，`tpy` 作为类型区分器。`content = <serialized per-type message>`。

```
┌────────────────────────────────────────────────────────────┐
│ entity.Message                                              │
│  tpy:     MessageType (类型枚举)                              │
│  content: bytes       = <序列化后的类型专属 proto>            │
│  summary: string      = "图片" / "文件: report.pdf"         │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  tpy 分类：                                                 │
│  ┌─────────────────────┬────────────┬────────────────────┐  │
│  │     场景            │ tpy        │ content 格式        │  │
│  ├─────────────────────┼────────────┼────────────────────┤  │
│  │ 用户 IM 消息         │ TEXT (1)   │ MessageText proto  │  │
│  │                     │ IMAGE (2)  │ MessageImage proto │  │
│  │                     │ FILE (3)   │ MessageFile proto  │  │
│  │                     │ RICH_TEXT_ │ MessageRichText    │  │
│  │                     │ QUILL (11) │ (Quill Delta JSON) │  │
│  │                     │ FORWARD    │ MessageForward     │  │
│  │                     │ — (reply)  │ Message.ref_*      │  │
│  ├─────────────────────┼────────────┼────────────────────┤  │
│  │ 自动化/机器人消息     │ MARKDOWN   │ MessageMarkdown    │  │
│  │                     │            │ (受限 Markdown)    │  │
│  ├─────────────────────┼────────────┼────────────────────┤  │
│  │ 结构化交互消息       │ CARD       │ MessageCard        │  │
│  │                     │            │ + Markdown 展示    │  │
│  └─────────────────────┴────────────┴────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

**设计原则**:
- `content` 字段保持 `bytes` 类型，**不改变 DB schema**
- `tpy` 枚举是唯一的类型区分器，proto 中没有 `oneof` 包装
- 服务端不解析 `content`（保持透明），SDK/客户端负责序列化/反序列化
- 读取消息时，根据 `tpy` 选择对应的 proto message 解析 `content`

### 2.2 富文本双轨设计

| | MessageRichText (tpy=11) | MessageMarkdown (tpy=13) |
|--|-------------------------|--------------------------|
| 用途 | **用户 IM 消息** — 编辑器 WYSIWYG 发送 | **自动化/机器人消息** — 系统、Bot、Webhook |
| 序列化 | Quill Delta JSON | Markdown 纯文本 |
| 编辑器 | flutter_quill / Quill.js (WYSIWYG) | 文本编辑 / Bot 直接拼字符串 |
| 渲染端 | Flutter 用 Document.fromJson | Flutter/Web 用 markdown 库 |
| 格式范围 | Quill 完整富文本能力 | **受限 Markdown** 子集（见下） |

**MessageMarkdown 受限 Markdown 子集**:

```
✅ 标题:     # H1 / ## H2 / ### H3
✅ 段落:     普通文本，空行分段
✅ 粗体:     **text**
✅ 斜体:     *text*
✅ 行内代码: `code`
✅ 代码块:   ```lang ... ```
✅ 有序列表: 1. item
✅ 无序列表: - item
✅ 链接:     [text](url)
✅ 图片:     ![alt](url)

❌ HTML 标签 (<div>, <span>, ...)
❌ 表格 (| --- | --- |)
❌ 任务列表 (- [ ] / - [x])
❌ 脚注
❌ 引用块 (> )
❌ 分割线 (---)
❌ 内联 HTML
```

**约束理由**：
- 自动化工具消息不需要桌面排版级的富文本能力
- 受限子集保证 Flutter/Web 两端渲染一致性
- 杜绝 HTML 注入（自动化工具 generate 的 markdown 可能含 XSS payload）

### 2.3 Summary 轻量化标记格式

`summary` 是字符串字段，服务端透传。部分场景需要接收端具备动态渲染能力（如 @提及中用户改名后摘要老化）。为此定义 `summary` 的轻量化标记格式，使接收端能以 **声明周期成本** 实现动态渲染和前向兼容。

```
纯文本摘要                                          → 常规显示
^[t][meta][content]                                → 标记摘要，接收端按 t 解析
```

**格式规则**:
- `^` 标记起始，紧跟 `[t][meta][content]`
- `t` — 标记类型标识（单字母或简短编码）
- `meta` — 结构化引用数据，接收端从中解析动态数据
- `content` — 默认展示文本（低版本/不识别的类型直接显示此项）
- `^` 字面量需转义为 `^^`

**预定义标记类型**:

| t | 名称 | meta 格式 | content 示例 | 说明 |
|---|------|-----------|-------------|------|
| `@` | @提及 | `user_id,user_id,...` | `"张三, 李四"` | 接收端用 user_id 查当前用户名渲染 |
| `@a` | @所有人 | _(空)_ | `"所有人"` |  |
| `img` | 图片 | `file_id` | `"[图片]"` |  |
| `file` | 文件 | `file_id,name` | `"[文件] report.pdf"` |  |
| `fwd` | 转发 | `chat_id,count` | `"[聊天记录]"` |  |

**处理流程**:
1. 发送端 SDK 填充 summary 时，对含动态引用的消息生成标记格式
2. 接收端 SDK/客户端渲染 summary 时，检测是否以 `^[` 开头
3. 是：解析 t，识别则按规则从 meta 渲染；不识别则直接显示 content
4. 否：按纯文本直接显示

**纯文本摘要直接保留原样**（最常见的 TEXT 消息 summary = 文本前 100 字，不含标记），零额外成本。

### 2.3 文件存储

服务端引入 `files` 表记录文件元数据（后台管理用）。消息 content 中**直接存储文件 URL**，不经过 file_id 间接寻址。

**客户端负责上传，SDK 不感知传输过程**：

```
Flutter                          Server
  │                                │
  │── Dio POST /api/files/upload ──▶│
  │   [onSendProgress: ████░░░]   │── save to object_store
  │   [CancelToken]                │── insert files 表
  │◀── { id, url, file_name, ... }│
  │                                │
  │── SDK FFI: send_message(      │
  │    tpy=IMAGE,                 │
  │    content={ url, ... })      │
  │                                │
  │── SDK FFI: send_message(      │
  │    tpy=IMAGE,                 │
  │    content={ url, thumb })    │
```

文件上传流程:

1. Flutter 用户选择文件（image_picker / file_picker）
2. Flutter 用 **Dio** 发起 HTTP multipart POST 到 `/api/files/upload`
   - `onSendProgress` → 展示上传进度条
   - `CancelToken` → 支持用户取消
   - 自动注入 Bearer token（JWT 鉴权）
3. 服务端保存文件到 `object_store`（storage key: `{category}/{yyyy}/{mm}/{fid}.{ext}`）
4. 服务端在 `files` 表写入元数据
5. 返回 JSON `FileResponse { id, url, file_name, file_size, mime_type, ext, category }`
   - `url` 为 `/api/files/{id}`，下载时自动处理 Content-Type（图片 inline，其余 attachment）
6. Flutter 构造对应 proto（`MessageImage` / `MessageFile`），传给 SDK FFI 发送
7. SDK 将 proto 序列化到 `content`，走标准 `MESSAGE_SEND` 流程

**文件下载与缓存**:

1. 收到消息后，Flutter 根据 `content` 中的 URL 渲染/下载
2. 图片：`cached_network_image` 管理缩略图/原图缓存
3. 文件：Dio stream 下载 → `path_provider` 本地存储 → 展示下载进度

**SDK 不参与**：文件传输的进度、取消、重试、缓存，全部由 Flutter 侧实现。

### 2.4 文件表设计

```sql
CREATE TABLE files (
    id            VARCHAR(32) PRIMARY KEY,  -- snowflake id as string
    created_at    TIMESTAMPTZ NOT NULL,
    updated_at    TIMESTAMPTZ NOT NULL,
    name          TEXT NOT NULL,             -- original filename
    size          BIGINT NOT NULL,           -- file size in bytes
    mime_type     VARCHAR(128) NOT NULL,
    md5           VARCHAR(64),               -- content hash for dedup
    width         INT,                       -- image width (if image)
    height        INT,                       -- image height (if image)
    thumbnail_url TEXT,                      -- thumbnail URL (if image)
    url           TEXT NOT NULL,             -- file access URL
    uploader_id   BIGINT NOT NULL,
    status        SMALLINT NOT NULL DEFAULT 1, -- 1=active, 2=expired
    extra         BYTEA
);
```

### 2.5 转发模型

#### 2.5.1 分类与定位

| | 逐条转发 (Single) | 合并转发 (Merged) |
|--|------------------|-------------------|
| 类型 | type=0 | type=1 |
| 产出 | N 条独立消息 | 1 条卡片消息 |
| 摘要 | 每条 msg.summary 独立 | 卡片预览：来源 + 条数 + 前几条摘要 |
| 展开 | 不适用 | 弹出历史记录页 |

#### 2.5.2 MessageForward proto

```protobuf
message MessageForward {
  int32 type             = 1;  // 0=single, 1=merged
  int64 chat_id          = 2;  // 来源会话 ID
  string chat_name       = 3;  // 来源会话名称（缓存）
  int32 message_count    = 4;  // 总消息数
  string title           = 5;  // 卡片标题（可选）
  repeated ForwardItem items = 6;  // 预览条目
}

message ForwardItem {
  int64  user_id    = 1;  // 原始发送者 ID
  string user_name  = 2;  // 发送者名称（缓存）
  int32  tpy        = 3;  // 原始消息类型
  string summary    = 4;  // 原始消息的 summary（含标记格式）
  int64  message_id = 5;  // 原始消息 ID（用于点开拉取完整内容）
}
```

**设计要点**：
- `items` 承载预览用的摘要信息（sender + summary），确保 **未展开时无需任何网络请求**
- 原始消息的完整 content 不嵌入 forwarded proto，通过 `message_id` + `chat_id` 按需拉取
- `summary` 沿用标记格式，转发卡片中也能正确渲染 @提及

#### 2.5.3 嵌套转发

转发消息中可能包含另一条转发消息（即 `ForwardItem.tpy == FORWARD`）。

**渲染规则**：

```
Feed 列表: "张三 转发了聊天记录"
          ↕ 展开
消息列表: ┌──────────────────────────────┐
          │ 📎 聊天记录 · 来自「项目群」   │
          │ 张三: 这个方案你看下...       │
          │ 李四: 好的                    │
          │ 王五: 📎 聊天记录 · 来自「设计群」│  ← 嵌套
          │           × 5条消息           │
          │ 赵六: +1                     │
          └──────────────────────────────┘
                   ↕ 点击嵌套卡片
          ┌──────────────────────────────┐
          │ 📎 聊天记录 · 来自「设计群」   │
          │ 小明: 新设计稿在这里           │
          │ ...                          │
          └──────────────────────────────┘
```

**嵌套限制**:
- 最大嵌套深度：**2 层**（外层转发 → 嵌套转发，不再进一步展开）
- 嵌套的 `ForwardItem` 中 `summary` 显示为 `"📎 [聊天记录] {chat_name} · ×{count}条"`
- 各层独立的 `chat_id` + `message_id` 确保拉取路径正确

#### 2.5.4 数据填充流程

**发送端**（构建 ForwardMessage）：

```
用户选择 N 条消息 → "合并转发" → 目标会话
                                  │
                    SDK 遍历选中消息：
                    ├─ 从本地 DB 读每条消息的 {tpy, summary, sender}
                    ├─ 若消息已达转发上限(100条)，截断
                    ├─ 若某条 tpy=FORWARD（嵌套）：
                    │   ├─ 解析 ForwardItem 的 user_name + summary
                    │   └─ 保留原始 message_id + chat_id 链
                    └─ 构造 MessageForward { items, chat_name, ... }
                       → serialize → content → MESSAGE_SEND
```

**接收端**（渲染 ForwardMessage）：

```
收到 tpy=FORWARD 消息
  │
  ├─ 解析 content → MessageForward
  │
  ├─ Feed 摘要显示："{user_name} 转发了聊天记录"
  │
  ├─ 卡片预览（未展开）：
  │   ├─ 标题："📎 聊天记录 · 来自「{chat_name}」"
  │   ├─ 前 4 条 ForwardItem 摘要
  │   └─ 如有嵌套 ForwardItem → 显示为内联卡片
  │
  └─ 点击展开：
      ├─ 本地有缓存 → 直接渲染
      ├─ 本地无缓存 → 调 MESSAGE_GET_BY_POS 从源 chat 拉取
      ├─ 已撤回消息 → 显示 "[消息已被撤回]"
      └─ 嵌套 ForwardItem → 再次点击可继续展开（限 2 层）
```

#### 2.5.5 撤回与删除的处理

- 转发生效时**不检查**原始消息是否已被撤回（当时认为有效即可）
- 接收端展开时检查：拉取消息后 status=RECALL 则显示灰色 "[消息已被撤回]"
- 原始消息被删除不影响转发内容（预览摘要已缓存）

#### 2.5.6 边界规则

| 场景 | 行为 |
|------|------|
| 选中消息 > 100 条 | 截断，提示仅转发前 100 条 |
| 选中消息全部为图片/文件 | items 中 summary 存 "[图片]"/"[文件]"，展开后完整渲染 |
| 嵌套转发超过 2 层 | 第 2 层嵌套 Flat，不再可展开 |
| 原始会话已解散 | items 中 chat_name 带 "(已解散)"，不可展开 |
| 用户转发后改名 | items.user_name 为转发时快照，不追溯更新 |

### 2.6 回复模型

**引用回复 (Quote Reply)** 不是独立消息类型，引用参考数据作为 `Message` 自身的元字段存在：

```
mesasge Message {
  // ... 原有字段
  int64  ref_message_id   = 31;  // 被引用消息 ID
  int64  ref_chat_id      = 32;  // 被引用会话 ID
  bytes  ref_content      = 33;  // 被引用消息的 content bytes 缓存
  string ref_summary      = 34;  // 被引用消息的摘要缓存
  int32  ref_tpy          = 35;  // 被引用消息的类型，决定如何反序列化 ref_content
  string ref_sender_name  = 36;  // 发送者名称缓存
}
```

- 任何消息类型（TEXT / IMAGE / FILE / RICH_TEXT_QUILL / FORWARD）均可携带 `ref_*` 字段成为回复
- `ref_content` 保证离线可展示（直接缓存原始 bytes，无需额外序列化）
- 客户端展示时，先渲染引用条（解析 `ref_content` → 展示摘要），再渲染回复内容
- 不存在 `MessageReply` proto，也不存在 `REPLY` tpy 枚举值

---

## 3. Proto 变更

### 3.1 entity.proto 新增/修改

```protobuf
// === 消息体类型 — 每种类型独立 proto，通过 Message.tpy 区分 ===

// --- 已有，扩充 @提及支持 ---
message Mention {
  int64 user_id = 1;
  string name   = 2;
  int32 offset  = 3;  // 在 text 中的起始位置
  int32 length  = 4;  // 提及文本长度
}

message MessageText {
  string text             = 1;
  repeated Mention mentions = 2;  // @提及结构化数据
}

// --- 新增：图片 ---
message MessageImage {
  string url           = 1;  // 图片 URL（未来可切换 CDN URL）
  string thumbnail_url = 2;  // 缩略图 URL
  int32 width          = 3;
  int32 height         = 4;
  string alt_text      = 5;  // 替代文本
}

// --- 新增：文件 ---
message MessageFile {
  string name      = 1;  // 文件名
  int64 size       = 2;  // 文件大小（字节）
  string mime_type = 3;  // MIME 类型
  string url       = 4;  // 下载 URL
}

// --- 富文本 (IM 用户编辑发送) ---
message MessageRichText {
  string delta = 1;  // Quill Delta JSON
}

// --- 新增：Markdown (自动化/机器人消息，受限子集) ---
message MessageMarkdown {
  string text     = 1;  // Markdown source（受限子集）
  string fallback = 2;  // 纯文本降级（可选，默认取 text 纯文本部分）
}

// --- 转发 ---
message MessageForward {
  int32 type             = 1;  // 0=single, 1=merged
  int64 chat_id          = 2;  // 来源会话 ID
  string chat_name       = 3;  // 来源会话名称（缓存）
  int32 message_count    = 4;  // 总消息数（预览用）
  string title           = 5;  // 卡片标题（可选）
  repeated ForwardItem items = 6;  // 预览条目摘要
}

message ForwardItem {
  int64  user_id    = 1;  // 原始发送者 ID
  string user_name  = 2;  // 发送者名称（转发时快照）
  int32  tpy        = 3;  // 原始消息类型
  string summary    = 4;  // 原始消息 summary（含标记格式）
  int64  message_id = 5;  // 原始消息 ID（展开时拉取完整内容用）
}

// 回复参考数据内嵌在 Message 消息体上，不是独立消息类型
// 见 2.6 节

// --- 新增：系统消息（群变更通知等）---
message MessageSystem {
  int32 action        = 1;  // 系统消息动作枚举
  string text         = 2;  // 本地化展示文本
  int64 operator_id   = 3;  // 操作人 ID
  repeated int64 target_ids = 4;  // 操作目标用户 ID 列表
}

// === File — 文件元数据 ===
message FileInfo {
  string id            = 1;
  string name          = 2;
  int64 size           = 3;
  string mime_type     = 4;
  string url           = 5;
  int64 uploader_id    = 6;
  int64 created_at_ms  = 7;
  string thumbnail_url = 8;
  int32 width          = 9;
  int32 height         = 10;
  string md5           = 11;
}

// entity.Entity 新增 files 映射
// map<string, FileInfo> files = 6;
```

#### MessageForward 的新命令枚举

Forward 复用 `MESSAGE_SEND` 命令（通过 `content` 中不同的 proto 区分），不需要新增命令枚举。客户端/SDK 构造好对应类型的 `content` 后，走标准的 `MESSAGE_SEND` 流程。

### 3.2 消息体序列化规则

每种消息类型的 content 序列化方式：

| tpy | 类型 | content 内容 | 当前状态 |
|-----|------|-------------|----------|
| 1 (TEXT) | `MessageText` proto | 文本内容 + @提及 | ✅ 已有，扩充 mentions |
| 2 (IMAGE) | `MessageImage` proto | 图片元数据 | 新增 |
| 3 (FILE) | `MessageFile` proto | 文件元数据 | 新增 |
| 11 (RICH_TEXT_QUILL) | `MessageRichText` proto | Quill Delta JSON | 当前存为 MessageText，改为独立的 MessageRichText |
| 13 (MARKDOWN) | `MessageMarkdown` proto | 受限 Markdown 子集 | 新增，自动化/机器人消息 |
| 14 (FORWARD) | `MessageForward` proto | items 摘要列表 + chat_id（展开时拉取） | 新增 |
| 15 (SYSTEM) | `MessageSystem` proto | 系统消息 | 新增 |
| — (reply) | Message.ref_* 字段 | 引用参考数据直接挂 Message 上，不占 tpy | 新增，非独立消息类型 |

### 3.3 新增文件上传 Proto

```protobuf
// file.proto (新增)
syntax = "proto3";
package file;
option go_package = "./proto";
import "entity.proto";

message UploadFileRequest {
  bytes data        = 1;  // 文件数据
  string name       = 2;  // 原文件名
  int64 size        = 3;
  string mime_type  = 4;
  string md5        = 5;  // 可选，用于服务端去重
}

message UploadFileResponse {
  string file_id    = 1;
  entity.FileInfo info = 2;  // 完整元数据
}

message GetFileInfoRequest {
  string file_id = 1;
}

message GetFileInfoResponse {
  entity.FileInfo info = 1;
}
```

### 3.4 命令枚举新增

Forward 复用 `MESSAGE_SEND` 命令（通过 `content` 中 `MessageForward` proto 区分），不需要新增命令枚举。

---

## 4. 后端变更

### 4.1 Bug 修复

| 位置 | 改动 |
|------|------|
| `backend/im/src/lib.rs:94-98` | match 补全 `Command::ChatQuit` 和 `Command::ChatDismiss` 分支 |
| `backend/im/src/feed.rs:89-96` | `feed_update_read_pos` 调用 `FeedModel::feed_set_read_pos` 写入 DB |

### 4.2 File Service（`backend/store/`）

> ⏸️ 文件上传能力已在其他分支实现，此处的 Store 模块扩展、files 表、缩略图等均待对应分支合并后同步。

| 模块 | 新增 | 说明 |
|------|------|------|
| `BizStore` trait | `upload_file()` / `get_file_info()` | 文件上传与元数据查询 |
| `AppStore` | 实现 upload_file | 写入磁盘 + files 表 |
| 路由 | `POST /storage/im/upload` | 内部 API，网关鉴权后调用 |
| 缩略图 | `generate_thumbnail()` | 图片上传后异步生成 256x256 缩略图 |

### 4.3 IM 模块

**现有命令无需修改**，MESSAGE_SEND 已支持任意 `bytes` content。

需新增：

| 功能 | 文件 | 说明 |
|------|------|------|
| `FORWARD_MESSAGE` handler | `message.rs` | 解析 ForwardRequest，创建被转发消息的副本或引用 |

**转发消息策略**: 
- 逐条转发：为每条被转发消息创建新的 Message，type = TEXT，content 包含原始消息的摘要 + 来源说明。`summary` 设为 "[转发] 发送者: 内容摘要"。
- 合并转发：创建一条 type = FORWARD 的消息，content 序列化为 MessageForward，包含所有消息 ID 列表。

### 4.4 文件表 Migration

```rust
// m20250720_000001_files.rs
col(pk_auto(FileId)),        // string PK
col(string(Name)),
col(big_integer(Size)),
col(string(MimeType)),
col(string_null(Md5)),
col(integer_null(Width)),
col(integer_null(Height)),
col(string_null(ThumbnailUrl)),
col(string(Url)),
col(big_integer(UploaderId)),
col(tiny_integer(Status)),
col(blob(Extra)),
```

---

## 5. SDK 变更

### 5.1 Content 序列化

```rust
// sdk/app-chat/src/content.rs (新增)
use proto::idl::entity;

/// 根据消息类型构建 content bytes
fn build_content(tpy: i32, msg: impl prost::Message) -> Vec<u8> {
    msg.encode_to_vec()
}

/// 从消息中解析出对应类型的消息体
fn parse_content(msg: &entity::Message) -> Option<ContentBody> {
    match msg.tpy {
        1  => entity::MessageText::decode(msg.content.as_slice()).ok().map(ContentBody::Text),
        2  => entity::MessageImage::decode(msg.content.as_slice()).ok().map(ContentBody::Image),
        3  => entity::MessageFile::decode(msg.content.as_slice()).ok().map(ContentBody::File),
        11 => entity::MessageRichText::decode(msg.content.as_slice()).ok().map(ContentBody::RichText),
        13 => entity::MessageMarkdown::decode(msg.content.as_slice()).ok().map(ContentBody::Markdown),
        _  => None,
    }
}

enum ContentBody {
    Text(entity::MessageText),
    Image(entity::MessageImage),
    File(entity::MessageFile),
    RichText(entity::MessageRichText),
    Markdown(entity::MessageMarkdown),
}

/// 根据类型和内容自动生成摘要
fn generate_summary(tpy: i32, content: &[u8]) -> String {
    match tpy {
        1 => {
            MessageText::decode(content).map(|t| truncate(&t.text, 100)).unwrap_or_default()
        }
        2 => "[图片]".to_string(),
        3 => {
            MessageFile::decode(content).map(|f| format!("[文件] {}", f.name)).unwrap_or_default()
        }
        11 => "[富文本]".to_string(),
        13 => {
            MessageMarkdown::decode(content)
                .and_then(|m| {
                    if !m.fallback.is_empty() {
                        Some(m.fallback)
                    } else {
                        Some(strip_markdown(&m.text))
                    }
                })
                .unwrap_or("[消息]".to_string())
        }
        _ => String::new(),
    }
}
```

### 5.2 文件上传

> 文件上传由 Flutter 直接发起 HTTP 请求，SDK 不感知传输过程。

Flutter 上传获得 URL 后，构造对应 proto 传给 SDK FFI。SDK 仅需标准 `send_message` 接口：

```dart
// Flutter 端
final response = await dio.post(
  '/api/files/upload',
  data: FormData.fromMap({ 'file': MultipartFile.fromBytes(bytes, filename: name) }),
  onSendProgress: (sent, total) => updateProgress(sent / total),
);
final data = response.data; // FileResponse { id, url, file_name, file_size, mime_type, ext, category }

// url 即为 /api/files/{id}，直接用于消息 content
final imageMsg = MessageImage(url: data['url'], thumbnailUrl: ...);
sdk.sendMessage(chatId: chatId, tpy: MessageType.IMAGE, content: imageMsg.writeToBuffer());
```

### 5.3 Forward / Reply 发送

Forward 和 Reply 复用 `MESSAGE_SEND`，客户端/SDK 在发送前构造好对应 proto 的 content：

```rust
// 转发：构造 MessageForward → 序列化到 content → 调 message_send
fn build_forward_content(ids: Vec<i64>, chat_id: i64, merge: bool) -> Vec<u8> {
    entity::MessageForward {
        message_ids: ids,
        chat_id,
        r#type: if merge { 1 } else { 0 },
        ..Default::default()
    }.encode_to_vec()
}

// 回复：引用参考数据直接填充到 Message 的 ref_* 字段，回复内容沿用自身 tpy
fn build_reply_message(ref_msg: &entity::Message, content: Vec<u8>) -> entity::Message {
    entity::Message {
        ref_message_id: ref_msg.id,
        ref_chat_id: ref_msg.chat_id,
        ref_sender_name: /* 从缓存取 sender name */,
        ref_content: ref_msg.content.clone(),
        ref_summary: ref_msg.summary.clone(),
        ref_tpy: ref_msg.tpy,
        content,
        ..Default::default()
    }
}
```

---

## 6. 客户端变更

### 6.1 消息渲染

Flutter 客户端当前 `widget/message.dart` 按 `tpy` 分发渲染，需补充：

| MessageType | Widget | 说明 |
|-------------|--------|------|
| TEXT | TextMessage | 已有，改用结构化 body 解析 |
| IMAGE | ImageMessage | 图片展示 + 点击预览 + 缩略图 |
| FILE | FileMessage | 文件卡片 + 下载按钮 + 进度 |
| RICH_TEXT_QUILL | RichTextMessage | Quill Delta 渲染 |
| CARD | CardMessage | 卡片容器（供转发等使用） |
| - | ForwardMessage | 逐条/合并转发卡片 |
| — (any with ref_*) | ReplyDecorator | 在消息上方渲染引用条 |

### 6.2 消息输入

| 组件 | 说明 |
|------|------|
| ImagePicker | 选图 → 上传 → 插入消息 |
| FilePicker | 选文件 → 上传 → 插入消息 |
| RichTextToolbar | 富文本编辑工具栏 |
| ForwardPicker | 选消息 → 选目标会话 → 发送 |
| ReplyPreview | 引用回复预览条 |

---

## 7. 数据流

### 7.1 图片消息发送

```
Flutter                          SDK                          Server
  │                               │                             │
  │── select image                │                             │
  │── Dio POST /storage/im/upload ────────────────────────────▶│
  │   [onSendProgress: ████░░░]   │                             │── save file + metadata
  │   [CancelToken]               │                             │── generate thumbnail
  │◀── { url, thumbnail_url } ───│                             │
  │                               │                             │
  │── SDK FFI: send_message(    │                             │
  │    tpy=IMAGE,               │                             │
  │    content={url,thumb,...}) ▶── api::message_send ────────▶│
  │                               │                             │── store message (opaque)
  │◀── push message ─────────────│◀── PushMessages ────────────│
  │                               │                             │
  │── read tpy=2 → MessageImage  │                             │
  │── render thumbnail_url       │                             │
  │── on tap → load original_url │                             │
```

### 7.2 引用回复发送

引用参考数据不占独立 tpy，直接作为 Message 元字段，回复内容走自身消息类型。

```
Client                          SDK
  │                              │
  │── long press → Reply ──────▶│
  │                              │── 从本地 DB 获取被引用消息的 content/summary/tpy/sender
  │── show reply preview ──────▶│
  │                              │
  │── type text → send ────────▶│── 构建 Message，填充 ref_* 字段
  │                              │   { tpy=TEXT, content={text:"回复内容"},
  │                              │     ref_message_id, ref_content, ref_summary, ref_tpy, ... }
  │                              │── MESSAGE_SEND
```

---

## 8. 消息搜索架构

搜索功能在 M4 中完整实现，但架构设计需与 M1 的内容格式决策对齐，提前说明。

### 8.1 搜索范围与分级

| 级别 | 搜索内容 | 实现方式 | 阶段 |
|------|---------|---------|------|
| L1 | 消息摘要文本 + @提及 | PostgreSQL `summary` + `at_user_ids` | M1 即可支持 |
| L2 | 会话搜索 | 本地 feed 列表 Filter | M1 即可支持 |
| L3 | 全文检索 + 文件名 + 富文本内容 | 专用搜索引擎 (Meilisearch/ES) | M4 |

### 8.2 动态内容搜索

**@提及搜索** 是 IM 搜索中最典型的动态场景。当前 messages 表已有 `at_user_ids` 列（`bigint[]`），可直接支持：

```sql
-- 查找 @了我 的消息
SELECT * FROM messages
WHERE at_user_ids @> ARRAY[$current_user_id]
  AND chat_id IN (SELECT entity_id FROM feeds WHERE user_id = $current_user_id)
ORDER BY created_at DESC
LIMIT 20;
```

**文本搜索** 基于 `summary` 字段（DB 中为 `TEXT`）：

```sql
-- 查找包含关键词的消息
SELECT * FROM messages
WHERE summary ILIKE '%keyword%'
  AND chat_id IN (SELECT entity_id FROM feeds WHERE user_id = $current_user_id)
ORDER BY created_at DESC
LIMIT 20;
```

### 8.3 与内容格式的关系

| 消息类型 | 搜索依赖 | 说明 |
|---------|---------|------|
| TEXT (1) | `summary`（摘要前 100 字） | 直接搜，精度足够 |
| IMAGE (2) | `summary` 固定为 `"[图片]"` | 按发送者/时间筛选 |
| FILE (3) | `summary` 固定为 `"[文件] {name}"` | 文件名由发送端 SDK 填充 summary |
| RICH_TEXT_QUILL (11) | `summary`（发送端提取的纯文本） | 可在 SDK 中扩展为索引 Delta JSON 中的文本 |
| MARKDOWN (13) | `summary`（提取纯文本）或 `fallback` | 同 |
| FORWARD (14) | `summary` 固定为 `"转发了聊天记录"` | 按发送者/时间筛选 |

**限制**：L1 搜索只覆盖 `summary`，不搜索 `content`。这意味着：
- 文件名（file message）只有前 100 字被索引 → 长文件名截断
- 富文本正文不索引 → 只搜索摘要

L3 阶段引入专用搜索引擎后，`content` 由搜索引擎解析索引，不再受此限制。

### 8.4 Proto

```protobuf
message SearchMessageRequest {
  string keyword    = 1;  // 搜索关键词
  int64 chat_id     = 2;  // 可选：限定会话
  int64 from_id     = 3;  // 可选：限定发送者
  int32 tpy         = 4;  // 可选：限定消息类型
  int64 before_id   = 5;  // 游标：从此 ID 之前的消息开始翻页
  int32 count       = 6;  // 分页大小
}

message SearchMessageResponse {
  int64 cursor      = 1;  // 下一页游标
  bool has_more     = 2;
  entity.Entity entity = 3;
}
```

### 8.5 与 Summary 标记格式的配合

summary 中 `^[@][user_ids][fallback]` 标记对搜索**无影响**——搜索时 `summary` 字段是完整字符串，`ILIKE '%张三%'` 直接命中 `fallback` 部分。如果用户改名后搜新名字，L1 搜不到（需 L3 搜索引擎解析 `at_user_ids` 查当前用户名后索引），这对 M1 是可接受的限制。

---

## 9. 未涉及的范围

以下功能与 M1 相关但后置到后续 Milestone：

| 功能 | 目标 Milestone | 原因 |
|------|---------------|------|
| 语音消息 | M6 | 需要 ASR 集成 |
| 视频消息 | M6 | 需要转码服务 |
| 位置消息 | M6 | 需要地图服务 |
| 消息搜索 | M4 | 需要搜索引擎 |
| CDN 加速 | M8 | 非 MVP 必需 |
| S3 云存储 | M8 | 非 MVP 必需 |
| 消息 Pin | M3 | 属于互动功能 |

---

## 9. 关键决策记录

| 决策 | 选项 | 选择 | 理由 |
|------|------|------|------|
| Content 容器 | oneof MessageBody / tpy+bytes | **tpy+bytes** | 保持现有模式，不引入额外 oneof 层；tpy 已足够区分类型 |
| 消息体序列化 | JSON / Proto | **Proto** | 与现有序列化一致，零额外解析开销 |
| 文件上传实现方 | SDK (reqwest) / Flutter (Dio) | **Flutter (Dio)** | 上传需要进度/取消/重试，Dio 原生支持；SDK 只负责传输完成后的业务逻辑 |
| 文件下载缓存 | SDK / Flutter | **Flutter** | `cached_network_image` + `path_provider`，图片渲染需要本地路径 |
| 文件去重 | server / client | **Server MD5** | 减少重复上传流量 |
| 缩略图生成位置 | client / server | **Server** | 统一质量，客户端无计算开销 |
| 转发实现 | 引用 / 复制 | **引用 (存 message_ids)** | 节省存储，撤回时效 |
| 回复引用缓存 | 同步拉取 / 嵌入 | **嵌入 (ref_content + ref_summary)** | 保证离线可用；直接存原始 bytes，无需额外序列化 |
| MessageRichText 是否存 plain_text | 存 / 不存 | **不存** | Message.summary 字段已承载纯文本摘要，无需冗余 |
| 富文本双轨 | 统一格式 / 分开 | **分开** | RICH_TEXT_QUILL (用户 WYSIWYG) + MARKDOWN (自动化/受限子集)，场景不同 |
| Markdown 特性集 | 完整 / 受限 | **受限** | 屏蔽 HTML/表格/任务列表，渲染一致且防 XSS |
| Summary 动态渲染 | 服务端渲染 / 客户端标记解析 | **客户端标记解析** | 服务端不感知 content/summary；标记格式 `^[t][meta][content]` 驱动接收端动态渲染，不识别时降级显示 content |

---

## 10. 工作量估计

| 模块 | 估算 (人天) | 主要风险 |
|------|------------|----------|
| Proto 定义 | 1 | — |
| Bug 修复 | 0.5 | — |
| files 表 Migration + Model | 1 | — |
| Store 模块文件上传 | 2 | 缩略图库选择 |
| IM 模块 Forward/Reply | 2 | — |
| SDK Content 序列化 | 2 | 与客户端对接 |
| SDK 文件上传 | 1.5 | — |
| 客户端消息渲染 | 3 | 图片预览交互 |
| 客户端消息输入 | 2 | — |
| **合计** | **15** | — |
