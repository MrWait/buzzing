# im/message — 消息发送/读取

## 测试目标

验证文本消息的发送、查询、已读和反应功能。消息直接发送（client_id=0），不经过草稿流程。

## 测试用例

### 1. should send a text message

- **命令**: `MESSAGE_SEND` (1203)
- **请求**: `SendMessageRequest { client_id=0, message: { chat_id, tpy=TEXT, content=MessageText } }`
- **预期**: 返回 `SendMessageResponse`，`id` 非零
- **验证点**: 返回的消息 ID 为有效 Snowflake ID
- **依赖**: 前置创建群聊（在 `before` 中完成）

### 2. should get messages by range

- **命令**: `MESSAGE_GET_BY_RANGE` (1213)
- **请求**: `GetMessageByRangeRequest { chat_id, pos=0, count=10, direct=BOTH }`
- **预期**: 返回 `GetMessageByRangeResponse`，`entity.messages` 包含刚发送的消息
- **验证点**: 通过 `Object.values(messages)` 遍历，按 `msg.id` 匹配
- **依赖**: 用例 1 发送消息
- **注意**: `map<int64>` 的 key 是二进制字符串，不能直接用字符串索引

### 3. should get message by IDs

- **命令**: `MESSAGE_GET_BY_IDS` (1208)
- **请求**: `GetMessageByIdsRequest { ids: [sentMessageId] }`
- **预期**: 返回 `GetMessageByIdsResponse`，`entity.messages` 包含目标消息
- **验证点**: 通过 `Object.values(messages)` 查找，消息 `chat_id` 匹配
- **依赖**: 用例 1 发送消息

### 4. should read messages

- **命令**: `MESSAGE_READ` (1209)
- **请求**: `MessageReadRequest { chat_id, max_pos=0, message_ids }`
- **预期**: 返回成功（code=0）
- **依赖**: 用例 1 发送消息

### 5. should set reaction on message

- **命令**: `REACTION_SET` (1214)
- **请求**: `SetMessageReactitonRequest { message_id, reaction=1, set=true }`
- **预期**: 返回成功（code=0）
- **依赖**: 用例 1 发送消息

## 约束

- 测试间共享 `chatId` 和 `sentMessageId`，需按顺序执行
- 仅测试纯文本消息（`tpy=TEXT`）
- 不涉及图片、文件等附件消息
- 不涉及消息撤回、删除
