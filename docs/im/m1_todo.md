# M1 实施清单

> 基于 `docs/im/m1_message_media.md` 设计，按依赖顺序排列。
> 每完成一步在 `[ ]` 前打 `[x]`。

---

## Step 0: 现有 Bug 修复

- [x] **0.1** ChatQuit / ChatDismiss 路由修复 — `backend/im/src/lib.rs`
  - match 补全 `Command::ChatQuit` → `chat::chat_quit`
  - match 补全 `Command::ChatDismiss` → `chat::chat_dismiss`
- [x] **0.2** feed_update_read_pos 实现 — `backend/im/src/feed.rs`
  - `feed_update_read_pos` 调用 `FeedModel::update_read_pos`
  - `update_read_pos` 在 `feeds.rs` 中实现，更新 `read_pos` + `read_badge` + `update_ms`

---

## Step 1: Proto 定义

- [x] **1.1** 填充 `entity.proto` 中的 `MessageText`
  - `string text = 1`
  - `repeated Mention mentions = 2`（新增 Mention message: user_id, name, offset, length）
- [x] **1.2** 填充 `entity.proto` 中的 `MessageImage`
  - `string url, string thumbnail_url, int32 width, int32 height, string alt_text`
- [x] **1.3** 填充 `entity.proto` 中的 `MessageFile`
  - `string name, int64 size, string mime_type, string url`
- [x] **1.4** 新增 `MessageRichText`
  - `string delta`（纯文本摘要由 Message.summary 承载，不重复存储）
- [x] **1.5** 新增 `MessageMarkdown`
  - `string text`（受限 Markdown 子集）+ `string fallback`（纯文本降级）
- [x] **1.6** 新增 `MessageForward` + `ForwardItem`
  - `MessageForward`: type, chat_id, chat_name, message_count, title, repeated ForwardItem items
  - `ForwardItem`: user_id, user_name, tpy, summary, message_id
- [x] **1.7** `Message` 新增 `ref_*` 字段（引用回复不再是独立消息类型）
  - `int64 ref_message_id, int64 ref_chat_id, bytes ref_content, string ref_summary, int32 ref_tpy, string ref_sender_name`
  - 废除 `MessageReply` proto，移除 `REPLY` tpy 枚举
- [x] **1.8** 新增 `MessageSystem`
  - `int32 action, string text, int64 operator_id, repeated int64 target_ids`
- [-] **1.9** ~~新增 `MessageBody` oneof 容器~~
  - 已决策：不引入 oneof，保持 `tpy + bytes` 模式
- [x] **1.10** 消息 content 中直接使用 URL，不经过 file_id
  - `MessageImage.url` / `MessageFile.url` 即为直接可访问的 URL
  - `FileInfo` 已定义，`files` map 已加入 `Entity`
  - `file.proto` 暂不定义（服务端 Store 模块用 HTTP API，不需要 proto）

---

## Step 2: 文件表 Migration + Model

> ✅ 已完成 — `backend/store/` 模块合并。

- [x] **2.1** 新建 migration `m20250720_000001_files.rs`（id, user_id, file_name, file_size, mime_type, ext, storage_key, md5, category, created_at, deleted_at）
- [x] **2.2** 生成 sea-orm entity (`base/src/models/_entities/files.rs`)
- [x] **2.3** 封装 `FileModel`（get_by_id, get_by_doc_id, get_by_md5, create, soft_delete）

---

## Step 3: Store 模块扩展

> ✅ 已完成 — 路由 `/api/files/*`，基于 `object_store` crate。

- [x] **3.1** 上传 `POST /api/files/upload`（multipart → object_store + files 表记录）
- [x] **3.2** 下载 `GET /api/files/{id}`（文件流，自动设置 Content-Type，图片/PDF inline）
- [x] **3.3** 详情 `GET /api/files/{id}/info`（返回文件元数据 JSON）
- [x] **3.4** 删除 `DELETE /api/files/{id}`（软删除，deleted_at 标记）

---

## Step 4: 图片缩略图

- [x] **4.1** 引入 `image` crate（已存在于 workspace）
- [x] **4.2** 上传后 inline 生成 256x256 缩略图（JPEG），存储为 `{storage_key}_thumb.jpg`
- [x] **4.3** 缩略图下载：`GET /api/files/{id}?size=thumb`，记录 `thumbnail_key` 到 files 表
  - files 表新增 `width`, `height`, `thumbnail_key` 列（migration: `m20260720_100003_files_thumbnail`）
  - `FileResponse` 新增 `thumbnail_url`, `width`, `height`
  - `text_image_to_store` 同时更新

---

## Step 5: 后端 Forward 支持

- [x] **5.1** `message_forward` handler (`backend/im/src/message.rs`)
  - 解析 ForwardRequest
  - 逐条转发：复制每条消息（保留原 tpy/content/summary）
  - 合并转发：创建一条 type=FORWARD 消息，content = MessageForward 序列化
  - 解析来源会话名、发送者名（通过 BizUser 查询）
  - 自动推送到目标会话成员
- [-] **5.2** `message_reply` handler
  - 引用回复不占独立 tpy，不新增 handler；回复内容走自身消息类型，`ref_*` 字段由 SDK 填充，服务端透传
- [x] **5.3** 注册 `Command::MessageForward` (1216) 到 `handled_command()` + match

---

## Step 6: SDK Content 序列化

- [x] **6.1** 新增 `sdk/app-chat/src/content.rs`
  - `build_content(tpy, msg)` — proto 序列化封装
  - `parse_content(msg)` — 按 tpy 分发反序列化为 `ContentBody` 枚举
  - `generate_summary(tpy, content, sender_name)` — 按消息类型自动生成摘要
  - `render_summary(summary, at_user_cache)` — 解析 `^[t][meta][content]` 标记
- [x] **6.2** Flutter 端调用 `build_content` 后通过 FFI 传入，SDK 不额外处理
- [x] **6.3** `message_send` 自动填充 `msg.summary`（发送端摘要生成）
- [x] **6.4** `handle_push_messages` 暂不解析 content（透传至 Flutter 由 FFI push 处理）

---

## Step 7: SDK Upload Task 支持 + Flutter 文件上传

> 文件上传由 Flutter 客户端（Dio）执行，SDK 不参与传输过程和进度回调。
> Flutter 通过 SDK 的 setting store（`SETTING_SET` / `SETTING_GET`）持久化上传任务元数据。

- [x] **7.1** Proto 清理与扩展
  - 移除 `MESSAGE_UPDATE_DRAFT` (1217) / `MESSAGE_GET_PENDING_TASKS` (1218) — 不参与 SDK 流程
  - 移除 `message.proto` 中的 `UpdateDraftRequest` / `GetPendingUploadTasksRequest` / `PendingUploadTask`
  - 新增 `SETTING_SET` (1058) / `SETTING_GET` (1059) 命令
  - 新增 `setting.proto` `LocalSettingSetRequest/Response` / `LocalSettingGetRequest/Response`
- [x] **7.2** SDK AppCommon FFI: `SETTING_SET` / `SETTING_GET`
  - `ffi_commands()` 注册两个命令
  - `on_ffi_command()` 分派到 `config_set` / `config_get`
- [x] **7.3** Flutter 上传流程集成
  - 选图/选文件 → `MESSAGE_CREATE_DRAFT` 创建本地草稿 → `SETTING_SET` 持久化上传任务
  - `Dio` upload → `MESSAGE_SEND` 携带真实 URL 发送 → `SETTING_SET` 清理任务

---

## Step 8: SDK Forward / Reply + 后端 ref_* 持久化

- [x] **8.1** `message_forward` SDK FFI handler
  - `sdk/app-chat/src/api.rs`: 新增 `forward_message()` API 调用
  - `sdk/app-chat/src/message.rs`: 新增 `message_forward()` handler
  - `sdk/app-chat/src/lib.rs`: 注册 `MESSAGE_FORWARD` 到 `ffi_commands()` + `on_ffi_command()`
- [x] **8.2** 后端 `ref_message_id` / `ref_data` 持久化
  - 新增 migration `m20260720_100004_messages_ref`（`ref_message_id` bigint, `ref_data` bytea）
  - 更新 `MessageModel::From/Into` 以持久化/恢复引用回复字段
  - SDK `message_send` 透传 `ref_*` 字段（`Message` proto 已包含）
- [x] **8.3** Flutter `ImController.forwardMessage()`
  - 支持 single forward（forward_type=0）和 merged forward（forward_type=1）

---

## Step 9: 客户端渲染

- [x] **9.1** `_ImageContent` widget (`lib/widget/message.dart`)
  - `CachedNetworkImage` 缩略图展示，加载/错误状态
  - 点击全屏预览（`InteractiveViewer` + `showDialog`）
- [x] **9.2** `_FileContent` widget
  - 文件卡片（图标 + 文件名 + 格式化大小）
- [x] **9.3** `_MarkdownContent` widget
  - 简单 markdown 渲染（# ## ### 标题、- * 列表）
- [x] **9.4** `_ForwardContent` widget
  - 合并转发：来源名 + 条数 + 前 4 条预览 + 折叠
- [x] **9.5** `_SystemContent` widget
  - 居中系统消息（无气泡，浅色背景标签）
- [x] **9.6** `_ReplyDecorator` widget（装饰器）
  - 引用条展示（左侧蓝色边框 + 发送者名 + 摘要，最大 2 行）

---

## Step 10: 客户端消息输入

- [x] **10.1** 图片选择 + 上传流程
  - `image_picker` → draft → `SETTING_SET` 持久化任务 → `Dio` upload → `MESSAGE_SEND` → 清理
- [x] **10.2** 文件选择 + 上传流程
  - `file_picker` → draft → `SETTING_SET` 持久化任务 → `Dio` upload → `MESSAGE_SEND` → 清理
- [x] **10.3** 工具栏按钮
  - 图片选择、文件选择、表情、@、视频会议、发送
- [x] **10.4** 消息右键菜单 + Hover 浮动菜单（PC 桌面）
  - `onSecondaryTap` 右键弹出 `showMenu`（转发/回复/收藏/删除）
  - `MouseRegion` Hover 时浮动显示 4 个操作按钮（带 Tooltip）
  - 移动端保持原有布局，不显示 Hover 菜单
- [x] **10.5** 转发选择器 UI
  - 右键/Hover → 转发 → 弹出 `ForwardPickerDialog`
  - 转发方式选择（逐条/合并）、已选消息预览、目标会话搜索列表
  - 确认后调用 `ImController.forwardMessage()`
- [x] **10.6** 引用回复预览条
  - `ImController.replyTarget` + `setReplyTarget()` / `clearReply()`
  - 编辑器上方蓝色竖线预览条（回复对象名 + 内容）+ 关闭按钮
  - `onSendMessage` 自动填充 `refMessageId` + `refData`，发送后 `clearReply()`

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
