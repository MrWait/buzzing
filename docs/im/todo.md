# IM 业务功能实施进度追踪

> 设计文档见 `docs/im/` 目录。每完成一步在 `[ ]` 前打 `[x]`。

---

## Milestone 1: 消息类型扩展与媒体能力

- [x] **M1-S0** Bug fixes: ChatQuit/ChatDismiss match arms, feed_update_read_pos
- [x] **M1-S1** Proto: MARKDOWN/FORWARD/SYSTEM types, MessageReference, Entity.files
- [x] **M1-S2** Backend image/file message send handlers, store module integration (thumbnail)
- [x] **M1-S3** SDK content build/parse/summary/render, forward_message

---

## Milestone 2: 群管理功能深化

### Step 0~8: 后端 + SDK（已完成）

- [x] **2-0** 基础设施 — update_cmv 修复 + CHAT_UPDATE 路由
- [x] **2-1** Proto 定义 — entity/chat/mute/invite/join_request protos + 12 commands
- [x] **2-2** DB Migration — chats 扩展 + group_mutes + join_requests + invite_links
- [x] **2-3** 后端群公告 — set/delete announcement (message upsert with id=chat_id)
- [x] **2-4** 后端禁言 — mute_member / global_mute + message_send 拦截
- [x] **2-5** 后端邀请链接 — create/join/revoke
- [x] **2-6** 后端加群验证 — create/approve/reject/list join_requests + join_mode guard
- [x] **2-7** 后端成员列表 — get_members 分页 + 关键词搜索
- [x] **2-8** SDK — chat/mute/invite/join_request modules + lib.rs registration

### Step 9~15: Flutter UI

- [x] **2-9.1** 导航入口 — ChatHeader 更多按钮 → 群资料
- [x] **2-9.2** GroupProfilePage — 群资料页（名称/头像/简介 + 各功能入口）
- [ ] **2-9.3** 群头像上传 — 复用 store /api/files/upload
- [ ] **2-10.1** 公告 banner — ChatHeader 下方 _AnnouncementBanner
- [ ] **2-10.2** 消息列表过滤 — 排除 id == chatId 的公告消息
- [x] **2-10.3** 公告编辑 — 群资料页 → 标题 + 内容 → setAnnouncement
- [x] **2-10.4** ImController 封装 — setAnnouncement / deleteAnnouncement
- [x] **2-11.1** 管理员管理 — 成员列表长按菜单设置/移除管理员
- [x] **2-11.2** 转让群主 — Owner 可见，成员列表长按 → 确认
- [x] **2-11.3** 权限控制 UI — 按角色显示/隐藏操作入口
- [x] **2-12.1** 全员禁言 — 群资料页 Switch（Owner/Admin）
- [x] **2-12.2** 个体禁言 — 成员列表长按 → 选择时长
- [ ] **2-12.3** 禁言状态展示 — 被禁言输入框提示
- [x] **2-13.1** 邀请入口 — 群资料页 → 邀请链接
- [ ] **2-13.2** 二维码生成 — qr_flutter 包
- [x] **2-13.3** 邀请链接管理 — 生成/撤销
- [ ] **2-13.4** 通过链接加群 — 解析 code → 自动加群
- [x] **2-14.1** 入群方式设置 — join_mode 选择
- [ ] **2-14.2** 申请加群 — 非成员 → 申请加入
- [x] **2-14.3** 审批管理 — 列表展示 pending 申请 → 通过/拒绝
- [x] **2-15.1** 成员列表页 — 分页 + 搜索 + 分组
- [x] **2-15.2** 成员操作 — 长按菜单（设置管理员/禁言/移出）

### Step 16: 测试

- [ ] **2-16.1** 后端测试 — 群资料/公告/禁言/邀请/加群验证/成员分页
- [ ] **2-16.2** SDK 测试 — 各新命令 FFI 调用
- [ ] **2-16.3** 手动验证 — 完整流程

---

## Milestone 6: Web 端 IM ✅ 已完成

> 设计文档 `docs/im/m6_web_im.md` — 共 10 steps 已全部完成

### Step 0: 基础设施 — 路由 / Layout / Proto 加载

- [x] **6-0.1** `services/im/proto.ts` — 集中加载 proto 文件
- [x] **6-0.2** `services/im/api.ts` — 封装 protoRequest() + IM API 函数（feed/chat/message/user）
- [x] **6-0.3** `services/im/ws.ts` — WebSocket 客户端（连接/重连/心跳/推送分发/请求响应匹配）
- [x] **6-0.4** `stores/im.ts` — Pinia store（connection/feeds/chats/messages/users/typing/PUSH 分发）
- [x] **6-0.5** `views/im/ImHome.vue` — 三栏布局容器 + FeedPanel（会话列表）
- [x] **6-0.6** 注册 IM 路由 `/im`, `/im/feed`, `/im/chat/:chatId` + TopRightBar IM 入口

### Step 1: 会话列表 (Feed) ✅ 已完成

- [x] **6-1.1** `FeedPanel.vue` — 左侧面板容器（搜索栏 + 列表）
- [x] **6-1.2** `FeedItem.vue` — 会话条目（集成在 FeedPanel 中）
- [x] **6-1.3** `FeedList.vue` — 列表 + 首次加载 + 分页（集成在 FeedPanel 中）
- [x] **6-1.4** PUSH_FEED_LIST 推送处理 → 更新 store feeds
- [x] **6-1.5** 点击 FeedItem → 进入会话（切换 chatId）

### Step 2: 消息基础 — 消息列表 + 发送文本 ✅ 已完成

- [x] **6-2.1** `ChatPanel.vue` — 聊天面板容器
- [x] **6-2.2** `ChatHeader.vue` — 会话头部（返回/名称/群资料导航）
- [x] **6-2.3** `MessageList.vue` — 消息列表（scroll 加载历史 + 自动滚底）
- [x] **6-2.4** `TextMessage.vue` — 文本气泡
- [x] **6-2.5** `MessageInput.vue` — 文本输入框 + 发送按钮
- [x] **6-2.6** `sendMessage()` API + PUSH_MESSAGES 处理

### Step 3: 回复 ✅ 已完成

- [x] **6-3.1** `ReplyPreview.vue` — 引用消息预览 + 取消
- [x] **6-3.2** refMessageId 发送支持（store/api 链路）

### Step 4: 图片/文件消息 ✅ 已完成

- [x] **6-4.1** 文件选择 + Axios 上传 + 进度
- [x] **6-4.2** `ImageMessage.vue` — 图片展示（缩略图 → 原图）
- [x] **6-4.3** `FileMessage.vue` — 文件展示（图标/名称/大小/下载）
- [x] **6-4.4** 上传完成 → sendMessage (tpy=IMAGE/FILE)

### Step 5: 消息交互 — Reaction + 操作菜单 ✅ 已完成

- [x] **6-5.1** `ReactionBar.vue` — Reaction 展示 + 点击切换
- [x] **6-5.2** `MessageMenu.vue` — 右键菜单（回复/复制/转发/撤回/删除）
- [x] **6-5.3** `ForwardPicker.vue` — 转发选择器
- [x] **6-5.4** `ForwardMessage.vue` — 转发消息渲染

### Step 6: Typing + Presence ✅ 已完成

- [x] **6-6.1** `TypingIndicator.vue` — "正在输入..." 展示
- [x] **6-6.2** 输入状态推送 PUSH_TYPING → store 处理
- [x] **6-6.3** 在线状态展示 PUSH_PRESENCE → store 处理

### Step 7: 消息 Thread ✅ 已完成

- [x] **6-7.1** `ThreadPanel.vue` — 右侧 Thread 面板
- [x] **6-7.2** 父消息展示 + 回复列表
- [x] **6-7.3** 发送 Thread 回复

### Step 8: 群资料页（只读）✅ 已完成

- [x] **6-8.1** `GroupProfile.vue` — 群信息/创建者/管理员
- [x] **6-8.2** 从聊天头部导航到群资料
- [x] **6-8.3** 路由 `/im/chat/:chatId/profile`

### Step 9: 打磨 ✅ 已完成

- [x] **6-9.1** 消息发送中/失败/重试状态（optimistic local message + sendStatus + retry）
- [x] **6-9.2** 移动端适配（单栏切换，<768px 自动切换面板）
- [x] **6-9.3** @提及弹出成员搜索（MentionPicker 组件 + 键盘导航）
- [x] **6-9.4** 富文本消息（tpy=11 Quill Delta → HTML）— 延迟到后续
- [x] **6-9.5** 已读状态展示（self 消息显示「已读」标记）

---

## Milestone 3: 消息互动与体验增强 ✅ 已完成

## Milestone 4: 搜索与发现 ✅ 已完成

## Milestone 5: 高级消息功能 ✅ 已完成

## Milestone 7+: 待规划
