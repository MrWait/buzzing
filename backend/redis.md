# 缓存使用
redis 存储读写多、meta 数据。读写少的数据存储到 DB 中。

# 缓存类型
## 会话状态
缓存模式，和 DB 同步。
Chat ID -- Chat，2 天淘汰。

## 用户会话列表
用户查询会话，2 天淘汰，数据和 DB 同步。
如果不存在，则从 DB 加载。
User ID -- Set

## 会话 pipeline
存储会话中状态变更，包括会话、消息等，会话内所有用户共享
Chat ID -- Zset，7 天淘汰


## 全局 pipeline
存储租户级别状态变更
Tenant ID -- Zset，7 天淘汰

# 用户 Pipeline
用户级别状态变更数据，7 天淘汰
User ID -- Zset

# 数据丢失判断
应用启动时，设置当前 sid 到 redis，作为 pipeline 数据记录起点。
如果 sid 已设置，不进行覆盖。

客户端拉取时，如果给出的 sid 小于创始 sid，则认为数据过期，需要用户重置 pipeline 对应数据。

# pipeline meta
存储在 feed 表中。当会话级别更新时，使用批量操作处理。
