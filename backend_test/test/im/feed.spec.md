# im/feed — Feed 列表/置顶/免打扰

## 测试目标

验证 Feed（会话列表）的基本操作：获取列表、置顶/取消置顶、免打扰开关、激活。

## 测试用例

### 1. should get feed list

- **命令**: `FEED_GET_LIST` (1100)
- **请求**: `PullFeedListRequest { cursor=0, count=20 }`
- **预期**: 返回 `PullFeedListResponse`，解码成功
- **验证点**: 返回码为 0
- **注意**: cursor 是分页游标（Snowflake ID），不为 0 是正常行为

### 2. should get feed top list

- **命令**: `FEED_GET_TOP_LIST` (1116)
- **请求**: `GetFeedTopListRequest {}`
- **预期**: 返回 `GetFeedTopListResponse`，`ids` 为数组
- **验证点**: 返回码为 0

### 3. should set feed top and mute

- **命令**: `FEED_SET_TOP` (1115)、`FEED_SET_MUTE` (1121)
- **流程**: 获取第一个 feed → set top → set mute → unset mute → unset top
- **预期**: 所有操作返回成功
- **依赖**: 有可用的 feed（若不存在则先创建群聊生成 feed）

### 4. should active a feed

- **命令**: `FEED_ACTIVE` (1118)
- **请求**: `ActiveFeedRequest { id }`
- **预期**: 返回成功
- **依赖**: 有可用的 feed

## 约束

- feed 操作依赖已有的 feed 记录；如无则创建群聊生成
- 不测试 feed 移除操作
