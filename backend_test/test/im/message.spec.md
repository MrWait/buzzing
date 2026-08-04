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

### 4.1 lazy pull read entity via pipeline entity change channel

- **命令**: `PIPELINE_PULL_ENTITY` (1051)
- **请求**: `PullEntityRequest { ids: [{id: sentMessageId, type=15 (MESSAGE)}] }`
- **背景**: 已读为独立实体（ReadState，id=message_id，随 `Entity.readstates` 下发），走 pipeline 实体变更通道；SDK 收到 `PUSH_ENTITY_CHANGE` 后按需懒拉（见 docs/data_sync §5）
- **预期**: 返回 `PullEntityResponse`，`entity.messages` 含目标消息且 `entity.readstates[sentMessageId]` 已填充（`read_count >= 1`）
- **依赖**: 用例 4 已读

### 4.2 get read members (full list)

- **命令**: `MESSAGE_GET_READ_MEMBERS` (1218)
- **请求**: `GetReadMembersRequest { chat_id, message_id }`
- **背景**: 已读详情全量返回成员（读/未读状态）；已读状态最多承载 ~2000 人群，超大群仅展示 at 成员（后续单独处理）
- **预期**: 返回 `GetReadMembersResponse.members`，>=1 名成员且已读成员 `isRead=true` 数 >=1
- **依赖**: 用例 4 已读

### 5. should set reaction on message
- **命令**: `REACTION_SET` (1214)
- **请求**: `SetMessageReactitonRequest { message_id, reaction=1, set=true }`
- **预期**: 返回成功（code=0）
- **依赖**: 用例 1 发送消息

### 5.1 lazy pull reaction via pipeline entity change channel

- **命令**: `PIPELINE_PULL_ENTITY` (1051)
- **请求**: `PullEntityRequest { ids: [{id: sentMessageId, type=15}] }`
- **背景**: reaction 为独立实体（Reactions，id=message_id，随 `Entity.reactions` 下发），走 pipeline 实体变更通道
- **预期**: 返回 `entity.messages` 含目标消息且 `entity.reactions[sentMessageId].reactions[1].total>=1`
- **依赖**: 用例 5

### 5.2 recall message and see tombstone via pipeline

- **命令**: `MESSAGE_RECALL` (1205)
- **请求**: `RecallMessageRequest { id: sentMessageId }`
- **背景**: 撤回属实体变更（operate=Delete），之后经 pipeline 懒拉应见 tombstone
- **预期**: 撤回返回成功；`PIPELINE_PULL_ENTITY` 拉到该消息 `status=RECALL(6)`
- **依赖**: 用例 1 发送消息

### 5.3 delete message and see tombstone via pipeline

- **命令**: `MESSAGE_DELETE` (1206)
- **请求**: `DeleteMessageRequest { message_id, mode=1 }`（mode=1 全局删除）
- **背景**: 删除属实体变更（operate=Delete），之后经 pipeline 懒拉应见 tombstone
- **预期**: 删除返回成功；`PIPELINE_PULL_ENTITY` 拉到该消息 `status=DELETED(5)`
- **依赖**: 用例 5.2 撤回后删除

## 约束

- 测试间共享 `chatId` 和 `sentMessageId`，需按顺序执行
- 仅测试纯文本消息（`tpy=TEXT`）
- 不涉及图片、文件等附件消息
- 不涉及消息撤回、删除
