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

## 约束

- 测试间共享 `createdChatId`，需按顺序执行
- 群聊仅包含当前用户（member_ids 仅自己）
- 不涉及加人、踢人、退群、解散等操作
