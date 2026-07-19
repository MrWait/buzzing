# M1 实施清单

> 基于 `docs/im/m1_message_media.md` 设计，按依赖顺序排列。
> 每完成一步在 `[ ]` 前打 `[x]`。

---

## Step 0: 现有 Bug 修复

- [ ] **0.1** ChatQuit / ChatDismiss 路由修复 — `backend/im/src/lib.rs`
  - match 补全 `Command::ChatQuit` → `chat::chat_quit`
  - match 补全 `Command::ChatDismiss` → `chat::chat_dismiss`
- [ ] **0.2** feed_update_read_pos 实现 — `backend/im/src/feed.rs`
  - `feed_update_read_pos` 调用 `FeedModel::feed_set_read_pos`
  - `feed_set_read_pos` 在 `feeds.rs` 中实现，更新 `read_pos` + `read_badge` + `version`

---

## Step 1: Proto 定义

- [ ] **1.1** 填充 `entity.proto` 中的 `MessageText`
  - `string text = 1`
  - `repeated Mention mentions = 2`（新增 Mention message: user_id, name, offset, length）
- [ ] **1.2** 填充 `entity.proto` 中的 `MessageImage`
  - `string file_id, string thumbnail_url, string original_url, int32 width, int32 height, string alt_text`
- [ ] **1.3** 填充 `entity.proto` 中的 `MessageFile`
  - `string file_id, string name, int64 size, string mime_type, string url`
- [ ] **1.4** 新增 `MessageRichText`
  - `string delta`（纯文本摘要由 Message.summary 承载，不重复存储）
- [ ] **1.5** 新增 `MessageMarkdown`
  - `string text`（受限 Markdown 子集）+ `string fallback`（纯文本降级）
- [ ] **1.6** 新增 `MessageForward` + `ForwardItem`
  - `MessageForward`: type, chat_id, chat_name, message_count, title, repeated ForwardItem items
  - `ForwardItem`: user_id, user_name, tpy, summary, message_id
- [ ] **1.7** 新增 `MessageReply`
  - `int64 ref_message_id, int64 ref_chat_id, string ref_sender_name, bytes ref_content, string ref_summary, int32 ref_tpy`
- [ ] **1.8** 新增 `MessageSystem`
  - `int32 action, string text, int64 operator_id, repeated int64 target_ids`
- [-] **1.9** ~~新增 `MessageBody` oneof 容器~~
  - 已决策：不引入 oneof，保持 `tpy + bytes` 模式
- [ ] **1.10** 消息 content 中直接使用 URL，不经过 file_id
  - `MessageImage.url` / `MessageFile.url` 即为直接可访问的 URL
  - `FileInfo` 和 `file.proto` 暂不定义（服务端内部用，不做成 proto）

---

## Step 2: 文件表 Migration + Model

> ⏸️ PENDING — 已由其他分支实现，合并后同步。

- [-] **2.1** 新建 migration `m20250720_000001_files.rs`
- [-] **2.2** 生成 sea-orm entity
- [-] **2.3** 封装 `FileModel`

---

## Step 3: Store 模块扩展

> ⏸️ PENDING — 已由其他分支实现，合并后同步。

- [-] **3.1** `BizStore` trait 扩展
- [-] **3.2** `DefaultBizStore` 实现上传
- [-] **3.3** 新增路由 `POST /storage/im/upload`
- [-] **3.4** 新增路由 `GET /storage/im/info/{file_id}`

---

## Step 4: 图片缩略图

> ⏸️ PENDING — 已由其他分支实现，合并后同步。

- [-] **4.1** 引入 Rust 图片处理库
- [-] **4.2** `generate_thumbnail`
- [-] **4.3** 上传后异步生成缩略图

---

## Step 5: 后端 Forward / Reply 支持

- [ ] **5.1** `message_forward` handler (`backend/im/src/message.rs`)
  - 解析 ForwardRequest
  - 逐条转发：为每条消息复制创建新消息 type=TEXT，summary 带来源标记
  - 合并转发：创建一条 type=FORWARD 消息，content = MessageForward 序列化
- [ ] **5.2** `message_reply` handler
  - 校验 ref_message_id 存在
  - SDK 已构建好 MessageReply，服务端仅透传（与普通 send 相同）
- [ ] **5.3** 注册新命令到 `handled_command()` + match
  - `Command::MessageForward` (1216)
  - `Command::MessageReply` (1217)

---

## Step 6: SDK Content 序列化

- [ ] **6.1** 新增 `sdk/app-chat/src/content.rs`
  - `fn build_content(tpy: i32, msg: impl prost::Message) -> Vec<u8>`
  - `fn parse_content(msg: &entity::Message) -> Option<ContentBody>` (按 tpy 分发解析)
  - `fn render_summary(summary: &str, at_user_cache: &HashMap<i64, String>) -> String`
    - 解析 `^[t][meta][content]` 标记
    - `^[@][user_ids][fallback]` → 用 at_user_cache 查当前用户名拼接
    - 不识别的标记 → 直接显示 content
    - 无标记 → 原样返回
- [ ] **6.2** `message_create_draft` 集成 `build_content`
  - 客户端传入 structured body，SDK 序列化为 content
- [ ] **6.3** `message_send` 集成 `generate_summary`
  - 发送前自动填充 `msg.summary`
- [ ] **6.4** `handle_push_messages` 集成 `parse_content`
  - 解析 content → MessageBody，填充到 push 数据中

---

## Step 7: Flutter 文件上传

> 文件上传由 Flutter 客户端实现，SDK 不参与传输过程。

- [ ] **7.1** Flutter 文件上传服务 (`lib/services/file_upload.dart`)
  - Dio multipart POST 到 `/storage/im/upload`
  - `onSendProgress` → 更新进度条
  - `CancelToken` → 支持取消
  - 大文件断点续传（Range header）
  - 自动注入 Bearer token
  - 返回 `{ url, thumbnail_url, width, height, name, size, mime_type }`
- [ ] **7.2** Flutter 文件下载与缓存
  - 图片：`cached_network_image` 管理缩略图/原图缓存
  - 文件：Dio stream 下载 + `path_provider` 本地存储 + 进度回调
- [ ] **7.3** 图片发送流程集成
  - 选图 → 上传（显示进度）→ 拿 URL → 构造 MessageImage → SDK FFI send_message

---

## Step 8: SDK Forward / Reply

- [ ] **8.1** `message_forward` 实现
  - 逐条转发：遍历源消息，逐条调用 message_send
  - 合并转发：
    - 遍历源消息，构建 ForwardItem 列表（tpy + summary + message_id + sender 快照）
    - 嵌套检测：若某条 tpy=FORWARD，保留原始 ForwardItem 数据
    - 构造 MessageForward proto → build_content → message_send
- [ ] **8.2** `message_reply` 实现
  - 拉取被引用消息的 content + summary + tpy + sender_name
  - 构造 MessageReply{ref_message_id, ref_content, ref_summary, ref_tpy, ref_sender_name} → build_content → message_send

---

## Step 9: 客户端渲染

- [ ] **9.1** ImageMessage widget
  - 缩略图展示 (thumbnail_url)，点击全屏预览 (original_url)
  - 加载状态、点击下载
- [ ] **9.2** FileMessage widget
  - 文件卡片（图标 + 文件名 + 大小）
  - 下载按钮，下载进度条
- [ ] **9.3** RichTextMessage widget
  - Quill Delta JSON 渲染（flutter_quill 或自定义渲染器）
- [ ] **9.4** ForwardMessage widget
  - 逐条转发：显示来源会话名 + 摘要
  - 合并转发：卡片式 "聊天记录"，显示条数 + 点击展开
- [ ] **9.5** ReplyMessage widget
  - 引用条展示（被引用消息内容摘要，点击跳转）
  - 下方显示回复内容

---

## Step 10: 客户端消息输入

- [ ] **10.1** 图片选择 + 上传流程
  - image_picker → Step 7.1 上传 → file_id → SDK FFI send
- [ ] **10.2** 文件选择 + 上传流程
  - file_picker → Step 7.1 上传 → file_id → SDK FFI send
- [ ] **10.3** 富文本编辑工具栏
  - 切换到 Quill 编辑器模式（flutter_quill）
- [ ] **10.4** 消息长按菜单
  - 转发、回复、收藏、删除
- [ ] **10.5** 转发选择器 UI
  - 选择消息 → 选择目标会话 → 确认转发
- [ ] **10.6** 引用回复预览条
  - 长按 → 回复 → 顶部显示引用预览 → 输入内容 → 发送

---

## Step 11: 测试

- [ ] **11.1** 服务端测试 (`backend_test/`)
  - 测试发送图片/文件/富文本消息
  - 测试转发消息
  - 测试引用回复
  - (文件上传接口测试 ⏸️ PENDING)
- [ ] **11.2** SDK 测试 (`buzzing/sdk_test/`)
  - 测试 content 序列化/反序列化
  - 测试 summary 生成
- [ ] **11.3** 手动验证
  - P2P 发送图片并查看 (⏸️ 图片上传依赖 pending 分支)
  - 群聊发送文件并下载 (⏸️ 文件上传依赖 pending 分支)
  - 富文本编辑发送
  - 逐条转发 / 合并转发
  - 引用回复

---

## 依赖图

```
Step 0 (Bug Fix)
    │
    ▼
Step 1 (Proto) ─────────────────▶ Step 6 (SDK Content) ──▶ Step 8 (SDK Forward/Reply)
    │                                │
    ▼                                │
Step 2 (File Migration) ────────────┤
    │                                │
    ▼                                │
Step 3 (Store Module) ──▶ Step 4 ───┤
    │                   (Thumbnail)  │
    ▼                                │
Step 5 (Backend Forward/Reply)       │
    │                                │
    ▼                                ▼
Step 7 (Flutter File Upload) ──▶ Step 10 (Client Input)
    │                                │
    ▼                                ▼
    └──────── Step 9 (Client Render) ┘
                    │
                    ▼
               Step 11 (Test)
```

---

## 分支策略

```bash
# 从 main 创建功能分支
git checkout -b feat/m1-message-media

# 每个 Step 独立 commit，PR 时 squash merge
git commit -m "feat(im): step 0 fix chat quit/dismiss routing"
git commit -m "feat(proto): step 1 structured message body types"
git commit -m "feat(store): step 2-4 file upload and thumbnail"
# ...
```
