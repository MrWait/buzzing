# M2 实施进度追踪

> 设计文档见 `docs/im/m2_design.md`。每完成一步在 `[ ]` 前打 `[x]`。

---

## Step 0: 基础设施 — 修复 update_cmv + CHAT_UPDATE 路由

- [x] **0.1** 修复 `ChatModel::update_cmv` — 将 `owner_id` / `admin_ids` 参数写入 `chats` 表
- [x] **0.2** 后端 `chat_update` handler — `backend/im/src/chat.rs`
- [x] **0.3** 注册路由 — `backend/im/src/lib.rs` (handled_command + match)
- [x] **0.4** SDK FFI — `sdk/app-chat/src/lib.rs` (ffi_commands + dispatch)
- [x] **0.5** SDK handler — `sdk/app-chat/src/chat.rs`
- [x] **0.6** Proto `UpdateChatRequest` 替换为新结构 + `UpdateChatResponse` 加 `entities`

---

## Step 1: Proto 定义

- [x] **1.1** `entity.proto` — Chat 扩展 (description/join_mode/global_mute_until), MessageType.ANNOUNCEMENT=16, AnnouncementContent
- [x] **1.2** 新增 `mute.proto`
- [x] **1.3** 新增 `invite.proto`
- [x] **1.4** 新增 `join_request.proto`
- [x] **1.5** `chat.proto` — UpdateChatRequest 替换 + SetAnnouncement/DeleteAnnouncement + GetMembers
- [x] **1.6** `command.proto` — 新增 12 个命令 (1122-1133)

---

## Step 2: DB Migration

- [x] **2.1** `m20260720_100005_chats_m2` — chats 表扩展 description/join_mode/global_mute_until
- [x] **2.2** `m20260720_100006_group_mutes` — group_mutes 表
- [x] **2.3** `m20260720_100007_join_requests` — join_requests 表
- [x] **2.4** `m20260720_100008_invite_links` — invite_links 表
- [x] **2.5** 生成 sea-orm entity + SDK DB schema 更新

---

## Step 3: 后端群公告（消息 id = chat_id）

- [x] **3.1** `chat_set_announcement` — INSERT or UPDATE messages 表
- [x] **3.2** `chat_delete_announcement` — DELETE from messages
- [x] **3.3** 注册路由 (CHAT_SET_ANNOUNCEMENT / CHAT_DELETE_ANNOUNCEMENT)

---

## Step 4: 后端禁言

- [x] **4.1** GroupMute Model — upsert/delete (raw SQL in mute.rs)
- [x] **4.2** Mute 模块 — `mute.rs`: mute_member, global_mute
- [x] **4.3** 消息发送拦截 — `message_send` 禁言检查 (Owner/Admin 豁免)
- [x] **4.4** 注册路由 (CHAT_MUTE_MEMBER / CHAT_GLOBAL_MUTE)

---

## Step 5: 后端邀请链接

- [x] **5.1** InviteLink Model — create/verify/revoke (raw SQL)
- [x] **5.2** Invite 模块 — `invite.rs`: create/join/revoke
- [x] **5.3** 注册路由 (CHAT_INVITE_LINK_CREATE / JOIN / REVOKE)

---

## Step 6: 后端加群验证

- [x] **6.1** JoinRequest Model — create/approve/reject/list (raw SQL)
- [x] **6.2** JoinRequest 模块 — `join_request.rs`: create/approve/reject/list
- [x] **6.3** 邀请加人权限检查 — `chat_add_chatters` 按 join_mode 限制
- [x] **6.4** 注册路由 (CHAT_JOIN_REQUEST_CREATE / APPROVE / REJECT / LIST)

---

## Step 7: 后端成员列表分页

- [x] **7.1** `get_members` handler — 从 cmv.ids() 分页 + 搜索
- [x] **7.2** Proto GetMembersRequest / GetMembersResponse / MemberItem (pre-defined)
- [x] **7.3** 注册路由 (CHAT_GET_MEMBERS)

---

## Step 8: SDK

- [x] **8.1** `sdk/app-chat/src/chat.rs` — chat_set_announcement / chat_delete_announcement / chat_get_members
- [x] **8.2** 新增 `sdk/app-chat/src/mute.rs` — mute_member / global_mute
- [x] **8.3** 新增 `sdk/app-chat/src/invite.rs` — invite_link_create / invite_link_join / invite_link_revoke
- [x] **8.4** 新增 `sdk/app-chat/src/join_request.rs` — join_request_create / approve / reject / list
- [x] **8.5** SDK `lib.rs` — 注册所有新命令 (ffi_commands + on_ffi_command)

---

## Step 9: Flutter 群资料编辑页

- [x] **9.1** 导航入口 — ChatHeader 更多按钮 → "群资料"
- [x] **9.2** `GroupProfilePage` — 展示/编辑名称/头像/简介
- [ ] **9.3** 群头像上传 — 复用 store `/api/files/upload`

---

## Step 10: Flutter 群公告

- [ ] **10.1** 公告 banner — `ChatHeader` 下方 `_AnnouncementBanner`，取 `entity.messages[chatId]`
- [ ] **10.2** 消息列表过滤 — 排除 `id == chatId` 的消息
- [x] **10.3** 公告编辑 — 群资料页 → 标题 + 富文本编辑器 → `setAnnouncement`
- [x] **10.4** ImController 封装 — `setAnnouncement()` / `deleteAnnouncement()`

---

## Step 11: Flutter 角色与权限管理

- [x] **11.1** 管理员管理 — 群资料页 → 设置/移除管理员（成员列表长按菜单）
- [x] **11.2** 转让群主 — Owner 可见 → 成员列表长按 → 确认
- [x] **11.3** 权限控制 UI — 按角色显示/隐藏操作入口

---

## Step 12: Flutter 禁言设置

- [x] **12.1** 全员禁言 — 群资料页 → 开关（Owner/Admin）
- [x] **12.2** 个体禁言 — 成员列表 → 长按 → 禁言（Owner/Admin）
- [ ] **12.3** 禁言状态展示 — 被禁言输入框提示

---

## Step 13: Flutter 邀请与二维码

- [x] **13.1** 邀请入口 — 群资料页 → "邀请链接"
- [ ] **13.2** 二维码生成 — `qr_flutter` 包
- [x] **13.3** 邀请链接管理 — 生成/撤销链接
- [ ] **13.4** 通过链接加群 — 解析 code → 自动加群

---

## Step 14: Flutter 加群验证

- [x] **14.1** 入群方式设置 — 群资料页 → join_mode 选择
- [ ] **14.2** 申请加群 — 非成员 → "申请加入"
- [x] **14.3** 审批管理 — 列表展示 pending 申请 → 通过/拒绝

---

## Step 15: Flutter 成员列表增强

- [x] **15.1** 成员列表页 — 分页 + 搜索 + 分组 (群主/管理员/成员)
- [x] **15.2** 成员操作 — 长按 → 设置管理员/禁言/移出群聊

---

## Step 16: 测试

- [ ] **16.1** 后端测试 — 群资料/公告/禁言/邀请/加群验证/成员分页
- [ ] **16.2** SDK 测试 — 各新命令 FFI 调用
- [ ] **16.3** 手动验证 — 完整流程
