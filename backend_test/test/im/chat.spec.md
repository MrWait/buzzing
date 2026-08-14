# im/chat — 群聊 CRUD

## 测试目标

验证群聊的创建、查询、更新功能。草稿功能为 SDK 专属，不在此测试范围。

## 测试用例

### 1. should create a group chat

- **命令**: `CHAT_CREATE` (1101)
- **请求**: `CreateChatRequest { chat: { chat_type=CHAT_GROUP, name, member_ids } }`
- **预期**: 返回 `CreateChatResponse`，`chat_id` 非零
- **验证点**: chat_id 为有效的 Snowflake ID
- **副作用**: 创建群聊会同时生成 Feed

### 2. should get chat by IDs

- **命令**: `CHAT_GET_BY_IDS` (1109)
- **请求**: `GetChatByIdsRequest { ids: [已创建的 chat_id] }`
- **预期**: 返回 `GetChatByIdsResponse`，`entities.chats` 包含目标群聊
- **验证点**: 通过 `Object.values(chats)` 遍历，按 `chat.id` 匹配
- **依赖**: 用例 1 创建群聊
- **注意**: `map<int64>` 的 key 是二进制字符串，不能直接用字符串索引

### 3. should update chat name

- **命令**: `CHAT_UPDATE` (1106)
- **请求**: `UpdateChatRequest { chat: { id, name } }`
- **预期**: 返回成功（code=0）
- **依赖**: 用例 1 创建群聊

### 4. should dismiss the group chat

- **命令**: `CHAT_DISMISS` (1110)
- **请求**: `DismissChatRequest { chat_id }`
- **预期**: 返回 `DismissChatResponse`，code=0
- **验证点**: 解散后 `FEED_GET_LIST` 返回的 feed 列表中不再包含该会话
  （feed 状态置为 DismissPending，被列表过滤，即会话从会话列表中消失）
- **依赖**: 用例 1 创建群聊（创建者为群主）
- **注意**: 该用例需在 describe 末尾执行（解散后群聊不可再被复用）

### 5. should reject sending messages to a dismissed chat

- **命令**: `MESSAGE_SEND` (1200)
- **请求**: `SendMessageRequest { client_id: 0, message: { chat_id=已解散群, tpy=TEXT, content } }`
- **预期**: 发送被拒绝（`code != 0/200`，服务端返回 `ErrorNoPermision`=1005）
- **验证点**: 解散后 `chats.status` 落库为 `DELETED`，`message_send` / `update_last_message`
  对非 `NORMAL` 状态群聊拒绝写消息，避免解散群聊继续收发消息
- **依赖**: 用例 4 已解散群聊
- **注意**: 该用例同样需在 describe 末尾执行（解散后群聊不可再被复用）

### 6. should reject sending messages to a chat where user is not a member

- **命令**: `CHAT_CREATE` (1101) → `CHAT_DELETE_CHATTERS` (1107) → `MESSAGE_SEND` (1200)
- **流程**: 创建仅含当前用户的群聊 → 群主移除自己（`RemoveChatChatterRequest { chat_id, ids: [自己] }`）
  → 再尝试发送消息
- **预期**: 消息发送被拒绝（`code != 0/200`，服务端返回 `ErrorNoPermision`=1005）
- **验证点**: `message_send` / `update_last_message` 校验发送者在 cmv 成员列表内
  （`cmv.contains_key(brief.id)`），非成员（退群/被移除）不可再发消息
- **注意**: 该用例同样需在 describe 末尾执行（移除后无法复用该群）

## 约束

- 测试间共享 `createdChatId`，需按顺序执行
- 群聊仅包含当前用户（member_ids 仅自己）
- 不涉及加人、踢人、退群等操作（解散为群主专属，见用例 4）
