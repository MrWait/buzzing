# 数据库

## 概述

- 服务端：**PostgreSQL**（主存储）
- SDK 本地：**SQLite**（本地缓存）
- ORM：**SeaORM** 1.1（支持双数据库）
- 迁移：`backend/migration/`

## 表结构

### accounts — 账户

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | PK |
| phone | text | 手机号 |
| name | text | 名称 |
| password | text | 密码 (哈希) |
| avatar | text | 头像 URL |
| version | int | 乐观锁 |

### users — 用户 (每个租户一个用户)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | PK |
| pid | bigint | 关联 account ID |
| a_id | bigint | (可选) |
| api_key | text | API 密钥 |
| name | text | 显示名 |
| tenant_id | bigint | 所属租户 |
| type | int | 类型 (普通/机器人) |
| status | int | 状态 |
| avatar | text | 头像 |
| dept_id | bigint | 所属部门 |
| version | int | 乐观锁 |

### tenants — 租户 (组织)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | PK |
| name | text | 组织名 |
| root_dept_id | bigint | 根部门 ID |
| owner_id | bigint | 所有者 |
| managers | jsonb | 管理员列表 |
| version | int | 乐观锁 |

### depts — 部门

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | PK |
| parent_id | bigint | 父部门 |
| tenant_id | bigint | 所属租户 |
| name | text | 部门名 |
| member_ids | jsonb | 成员 ID 列表 |
| sub_ids | jsonb | 子部门 ID 列表 |
| version | int | 乐观锁 |

### chats — 聊天

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | PK |
| type | int | 类型 (P2P/群) |
| status | int | 状态 |
| name | text | 群名 |
| owner_id | bigint | 群主 |
| peer_a_id | bigint | P2P 用户 A |
| peer_b_id | bigint | P2P 用户 B |
| cmv | bigint | 当前 CMV ID |
| admin_ids | jsonb | 管理员列表 |
| last_message_* | - | 最后消息摘要 |
| version | int | 乐观锁 |

### cmvs — 聊天成员版本向量

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | PK |
| chat_id | bigint | 关联聊天 |
| cmv | bigint | 成员位向量 |
| count | int | 成员数 |
| create_at_ms | bigint | 创建时间 |

用于高效追踪成员存在和消息读取状态。

### messages — 消息

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | PK |
| type | int | 消息类型 |
| chat_id | bigint | 所属聊天 |
| from_id | bigint | 发送者 |
| pos | bigint | 位置序号 |
| badge | int | 徽标 |
| status | int | 状态 |
| client_id | text | 客户端去重 ID |
| at_user_ids | jsonb | @用户列表 |
| content | blob | Protobuf 编码消息体 |
| summary | text | 摘要 |
| cmv_id | bigint | 消息时的 CMV |
| read_states | jsonb | 已读状态 |
| reactions | jsonb | 表情回复 |
| version | int | 乐观锁 |

### feeds — 会话条目

| 字段 | 类型 | 说明 |
|------|------|------|
| entity_id | bigint | 实体 ID (复合 PK 之一) |
| entity_type | int | 实体类型 (复合 PK 之一) |
| user_id | bigint | 用户 ID (复合 PK 之一) |
| refer_id | bigint | 引用消息 ID |
| refer_pos | bigint | 引用消息位置 |
| read_pos | bigint | 已读位置 |
| status | int | 状态 |
| is_mute | bool | 免打扰 |
| is_top | bool | 置顶 |
| version | int | 乐观锁 |

复合主键：`(entity_id, entity_type, user_id)`

### pipelines — 离线消息管道

| 字段 | 类型 | 说明 |
|------|------|------|
| sid | bigint | 会话 ID (复合 PK) |
| user_id | bigint | 用户 ID (复合 PK) |
| command | int | 命令 |
| data | blob | 数据 |

复合主键：`(sid, user_id)`

### settings — 用户设置

| 字段 | 类型 | 说明 |
|------|------|------|
| user_id | bigint | PK |
| type | int | PK (设置类型) |
| data | blob | 设置内容 (Protobuf) |
| version | int | 乐观锁 |

复合主键：`(user_id, type)`

### calendars — 日历

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | PK |
| creator | bigint | 创建者 |
| tenant_id | bigint | 租户 |
| name | text | 日历名 |
| desc | text | 描述 |
| color | int | 颜色 |
| subscriber | jsonb | 订阅者列表 |
| version | int | 乐观锁 |

### schedules — 日程

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | PK |
| calendar_id | bigint | 所属日历 |
| type | int | 类型 |
| tenant | bigint | 租户 |
| owner | bigint | 所有者 |
| cycle_rule_id | bigint | 重复规则 ID |
| title | text | 标题 |
| start_time | bigint | 开始时间 |
| end_time | bigint | 结束时间 |
| member_ids | jsonb | 参与人 |
| version | int | 乐观锁 |

### cycleds — 重复日程规则

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint | PK |
| calendar_id | bigint | 日历 |
| start_at | bigint | 开始时间 |
| stop_at | bigint | 结束时间 |
| rule | blob | 重复规则 (Protobuf) |
| exceptions | text | 例外 |
| template | text | 模板 |
| version | int | 乐观锁 |

### user2_calendars — 用户-日历关联

| 字段 | 类型 | 说明 |
|------|------|------|
| user_id | bigint | PK |
| calendars | jsonb | 订阅的日历列表 |
| schedules | jsonb | 日程列表 |
| version | int | 乐观锁 |

### favorites — 收藏

| 字段 | 类型 | 说明 |
|------|------|------|
| (待补充) | | 收藏的消息或条目 |

## 关键设计

### CMV (Chat Member Version)
使用位向量 (VecBool) 高效追踪聊天成员变更：
- `cmvs` 表中记录每个版本的成员位向量
- `messages.cmv_id` 关联消息发送时的成员版本
- `messages.read_states` 记录哪些成员已读 (也是位向量)

### VecBool
自定义位向量实现 (`tool/vecbool/`)：
- 压缩存储布尔数组
- 用于成员存在性、已读状态等场景
- 比 JSON 数组更节省空间

### ID 生成
Snowflake 变体：`[12-bit 集群ID | 32-bit 秒级时间戳 | 20-bit 序列号]`
- 64 位整数，无符号
- LSB 奇偶可用于区分人类/机器人用户
