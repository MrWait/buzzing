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

### 1.1 sender unread cleared after sending latest message

- **命令**: `FEED_GET_LIST` (1112)
- **请求**: `PullFeedListRequest { cursor=0, count=20 }`
- **背景**: 发送者发出本会话最新消息时，服务端把其已读游标推进到本条消息（`read_badge = msg.badge_count`），使该会话未读归零（未读 = `refer_badge - read_badge`，见 docs/data_sync §6）。多端场景：任一设备发送，本账号该会话即视为已读。
- **预期**: 找到 `id == chatId` 的 Feed，且 `read_badge >= refer_badge`、`read_pos >= refer_pos`
- **依赖**: 用例 1 发送消息

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

### 5.2 merge & compress PUSH_ENTITY_CHANGE(1057) packets on pipeline pull

- **命令**: `PIPELINE_PULL_PACKET` (1050)
- **背景**: 服务端对 1057 包做合并压缩（见 docs/data_sync）：策略1 同一实体 `(type,id)` 多次变更仅保留 version 最大值（连同 operate）；策略2 窗口内多个 1057 行收敛为一个 `PushEntityChanged` 包（超 2048 条拆包）。单次至少 load 500 行做全局合并，返回包数可超请求 count（超额返回）。`has_more` 按「取到整页行数」判定，合并包 rid 取被合并行最大 sid 保证游标推进。
- **步骤**: 新发一条消息 → `MESSAGE_READ` 已读（READSTATE=17 变更）→ 连续两次 `REACTION_SET`（REACTION=24 变更，同一实体多次变更）→ `PIPELINE_PULL_PACKET { sid=0, count=100 }` 循环拉全量
- **预期**: 返回 `PullPipelineResponse`
  - 至少有一个 1057 包（压缩生效）
  - 该消息 READSTATE 与 REACTION 变更各只出现一次（reaction 触发两次被合并为一条）
  - reaction operate=UPDATE(2)，且 reaction version > readstate version（保留最大值）
- **依赖**: 用例 5 群聊环境
- **注意**: 拉取不再删除 pipeline 行（多设备共享，清理仅由服务端 TTL worker 执行），历史行会一直累积；用例按具体消息 id 断言，不受历史行影响

### 5.3 recall message and see tombstone via pipeline

- **命令**: `MESSAGE_RECALL` (1205)
- **请求**: `RecallMessageRequest { id: sentMessageId }`
- **背景**: 撤回属实体变更（operate=Delete），之后经 pipeline 懒拉应见 tombstone
- **预期**: 撤回返回成功；`PIPELINE_PULL_ENTITY` 拉到该消息 `status=RECALL(6)`
- **依赖**: 用例 1 发送消息

### 5.4 delete message and see tombstone via pipeline

- **命令**: `MESSAGE_DELETE` (1206)
- **请求**: `DeleteMessageRequest { message_id, mode=1 }`（mode=1 全局删除）
- **背景**: 删除属实体变更（operate=Delete），之后经 pipeline 懒拉应见 tombstone
- **预期**: 删除返回成功；`PIPELINE_PULL_ENTITY` 拉到该消息 `status=DELETED(5)`
- **依赖**: 用例 5.3 撤回后删除

### 5.5 pipeline pull fresh (sid=0)

- **命令**: `PIPELINE_PULL_PACKET` (1050)
- **请求**: `PullPipelineRequest { sid=0, count=100 }`
- **背景**: 全新安装客户端 cursor=0，无需回放历史（见 docs/data_sync §pipeline TTL / 全新安装）
- **预期**: `PullPipelineResponse { packets=[], has_more=false, expired=false }`，`sid` 为当前最大 sid（可为 0）
- **依赖**: 群聊环境

### 5.6 pipeline pull does not delete rows (multi-device shared)

- **命令**: `PIPELINE_PULL_PACKET` (1050)
- **背景**: 拉取不再消费即删（delete_le_sid 已移除），数据仅由服务端 TTL worker 清理
- **步骤**: 从 `sid=0` 重复拉取两次
- **预期**: 两次 `sid` 与 `packets` 完全一致（数据未被消费删除）
- **依赖**: 用例 5.2 累积的历史行

### 5.7 pipeline pull expired 字段（正常拉取）

- **命令**: `PIPELINE_PULL_PACKET` (1050)
- **背景**: TTL 清理触发的水位线/expired 路径无法仅通过 HTTP 触发（需服务端 DB 侧种子水位线或等待 30 天 TTL），本用例仅验证字段存在且正常路径 expired=false
- **预期**: 正常拉取 `expired=false`，`min_sid` 存在（未清理过为 0）
- **依赖**: 群聊环境

## 约束

- 测试间共享 `chatId` 和 `sentMessageId`，需按顺序执行
- 仅测试纯文本消息（`tpy=TEXT`）
- 不涉及图片、文件等附件消息
- 不涉及消息撤回、删除
