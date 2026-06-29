# Multi-Union 架构 PRD

## 1. 概述

### 1.1 背景

Buzzing 采用单体架构，但随着业务发展，需要支持多区域、多集群、多租户隔离部署。每个部署单元称为一个 **Union**（联邦），各自独立运行完整功能，之间通过网络通信交换数据。

### 1.2 目标

- 支持 Union 独立部署，拥有完整功能
- 客户端启动时选择目标 Union 进行连接
- Union 之间可以跨集群通信（如跨 Union 加好友、建群聊）
- ID 生成通过 12-bit Union ID 保证全局唯一

### 1.3 术语

| 术语 | 说明 |
|------|------|
| Union | 一个独立部署的服务集群，拥有完整后端服务 |
| Union ID | 每个 Union 的全局唯一标识，12-bit，范围 0-4095 |
| Master Union | 主联邦，可选角色，可承担跨 Union 路由/注册中心功能 |
| Client Config | 客户端配置，终端连接 Union 的入口信息 |
| Union Hub | Union 间通信的网关/路由层 |

---

## 2. 架构设计

### 2.1 整体架构

```
                        ┌──────────────────────────────┐
                        │         Union A               │
                        │  ┌────┐ ┌────┐ ┌────┐ ┌────┐ │
  Client A ──WS/HTTP──▶│  │GW  │ │IM  │ │User│ │... │ │
                        │  └────┘ └────┘ └────┘ └────┘ │
                        │  PostgreSQL         Redis     │
                        └──────────┬───────────────────┘
                                   │ Union Hub (gRPC/HTTP)
                        ┌──────────┴───────────────────┐
                        │         Union B               │
                        │  ┌────┐ ┌────┐ ┌────┐ ┌────┐ │
  Client B ──WS/HTTP──▶│  │GW  │ │IM  │ │User│ │... │ │
                        │  └────┘ └────┘ └────┘ └────┘ │
                        │  PostgreSQL         Redis     │
                        └──────────────────────────────┘
```

### 2.2 各 Union 独立完整性

每个 Union 都是完整的独立部署单元，包含全部后端模块：

| 模块 | 说明 |
|------|------|
| Gateway | API 网关 + WebSocket 信令 |
| User | 用户 & 部门 & 租户管理 |
| IM | 即时通讯（聊天、消息、Feed） |
| Calendar | 日历 & 日程 |
| Setting | 用户设置 |
| Store | 文件存储 |
| RTC | WebRTC 信令 + TURN |
| Office | 协作文档 |
| Todo | 任务管理 |

每个 Union 拥有独立的：
- PostgreSQL 实例（或数据库）
- Redis 实例
- ID 生成器（使用自己的 Union ID）
- 用户/账户/租户数据

### 2.3 Union Hub（跨 Union 通信层）

Union Hub 是跨 Union 数据交换的中枢，负责：

| 功能 | 说明 |
|------|------|
| 用户发现 | 查询用户所在 Union，返回该 Union 的接入地址 |
| 跨 Union 转发 | 将请求（如添加成员、发送消息）转发到目标 Union |
| 实体填充 | 跨 Union 查询用户信息、聊天信息等实体数据 |
| 健康检测 | 监控各 Union 在线状态 |

- Master Union 可承担 Hub 职责
- 非 Master Union 启动时向 Master 注册
- Hub 层建议独立部署，但也可部署在任一 Union 中
- 初期可通过 HTTP/gRPC 实现，后续可引入消息队列（Kafka/NATS）解耦

#### 2.3.1 Union 注册流程

```
非 Master Union 启动时:
  1. 读取自身配置 (union_id, union_host, gateway_port, ws_port 等)
  2. 向 Master Union 的 /hub/register 发送注册请求
  3. Master Union 验证 union_id 唯一性
  4. Master Union 在 Union Registry 中注册该 Union 的路由信息
  5. 返回注册确认

Master Union:
  - 维护 Union Registry（内存 + 持久化）
  - 提供 /hub/lookup 接口供跨 Union 查询
  - 定期检测各 Union 健康状态
```

#### 2.3.2 跨 Union 查询流程

```
Union A 需要查询 Union B 的用户:
  1. Union A 通过用户 ID 提取 Union ID（高位 12 bit）
  2. 向 Master Union 的 /hub/lookup 查询 Union B 的连接地址
  3. （可选，Union B 地址也可缓存本地）
  4. Union A 直接向 Union B 发送查询请求
  5. Union B 返回结果，Union A 缓存结果
```

### 2.4 客户端连接

```
客户端启动流程:
  1. 用户输入 Union 地址（URL）
  2. 客户端向目标 Union 发送 GET /config/client
  3. 获取客户端配置（包含 gateway/ws/rtc 地址、功能开关等）
  4. 使用配置初始化 SDK 连接
  5. 注册/登录流程

客户端配置（/config/client 返回）:
  {
    "union": "https://union-a.buzzing-im.com",     // 当前 Union 地址
    "union_id": 1024,                                // 当前 Union ID
    "gateway": "https://union-a.buzzing-im.com",     // 网关地址
    "gateway_port": 5150,                            // 网关端口
    "ws": "ws://union-a.buzzing-im.com",             // WebSocket 地址
    "ws_port": 8889,                                 // WebSocket 端口
    "rtc": "wss://union-a.buzzing-im.com",           // RTC 地址
    "rtc_port": 8086,                                // RTC 端口
    "upload_*_path": "/storage/...",                 // 上传路径
    "api_gateway": "/api/v1",                        // API 网关前缀
    "api_*": "/api/...",                             // 各 API 路径
    "features": ["im", "calendar", "meeting"],       // 功能开关
    "union_hub": "https://master.buzzing-im.com"     // Master Union Hub 地址
  }
```

---

## 3. ID 生成

### 3.1 Snowflake 格式

```
[63 ───────── 52] [51 ──────────── 20] [19 ──────────── 0]
   12-bit Union ID    32-bit 时间戳         20-bit 序列号
```

### 3.2 字段说明

| 字段 | 位宽 | 最大值 | 说明 |
|------|------|--------|------|
| Union ID | 12 bit | 4095 | 全局唯一 Union 标识 |
| 时间戳 | 32 bit | ~136 年 | 秒级，从 2025-01-01 开始 |
| 序列号 | 20 bit | 1,048,575 | 单调递增，每秒重置 |

### 3.3 分配策略

| Union ID 范围 | 用途 |
|---------------|------|
| 0 | 保留/未分配 |
| 1-1023 | 预留给正式部署 |
| 1024-2047 | 开发/测试环境 |
| 2048-4095 | 预留扩展 |

- Union ID 必须全局唯一，建议由 Master Union 统一分配
- 配置文件中设置 `union_id` 字段
- 部署后不可修改（否则会导致 ID 冲突）
- 用户/机器人通过序列号最低位区分：`0`=人类，`1`=机器人

---

## 4. 数据模型

### 4.1 实体 ID 跨 Union 识别

所有核心实体（用户、聊天、消息、日程等）的 ID 均包含 Union ID，可通过 ID 提取来源 Union：

```rust
fn extract_union_id(id: i64) -> u16 {
    ((id >> 52) & 0xFFF) as u16
}
```

### 4.2 用户跨 Union 关联

跨 Union 用户采用 **ID 透传 + 本地缓存** 策略：

| 策略 | 说明 |
|------|------|
| 用户 ID | 用户在本 Union 注册，ID 包含本 Union ID |
| 跨 Union 引用 | 通过 `UserBrief { id, union_id, name, avatar }` 引用 |
| 本地缓存 | SDK 缓存跨 Union 用户基本信息，避免频繁跨集群查询 |
| 实体填充 | 拉取消息中的跨 Union 用户信息时，向目标 Union 请求 |

### 2.2 聊天跨 Union 设计

| 场景 | 实现 |
|------|------|
| P2P 聊天（同 Union） | 直接在本地 Union 处理 |
| P2P 聊天（跨 Union） | 两个用户所在 Union 各自维护一份 Chat 记录，通过 Hub 同步 |
| 群聊（跨 Union） | 群聊归属于创建者所在 Union，其他 Union 成员通过 Hub 接收推送 |

#### 跨 Union 群聊消息流

```
1. Union A 用户发送群消息
2. Union A 的 IM 模块处理消息存储
3. Union A 检查群成员所在 Union
4. 对于 Union B 的成员:
   a. 通过 Hub 查询 Union B 地址
   b. 向 Union B 的推送接口发送消息通知
5. Union B 收到后推送给在线成员，不在线的存离线管道
6. Union B 成员收到消息
```

### 4.3 各模块跨 Union 数据策略

| 模块 | 数据策略 |
|------|----------|
| 用户 | 每个 Union 独立管理本地用户；跨 Union 用户通过 Union Hub 查询 |
| 聊天 | 群聊归属创建 Union；P2P 跨 Union 需双向同步 |
| 消息 | 消息归属发送者所在的 Union |
| Feed | 每个用户只维护自己所在 Union 的 Feed |
| 日历 | 日历归属创建者所在 Union，跨 Union 成员通过 Hub 查看 |
| 文件 | 文件存储在当前 Union 的存储服务中，跨 Union 引用需转发 |

---

## 5. SDK 层适配

### 5.1 初始化流程

```
1. Flutter 层传入目标 Union 地址
2. SDK 发送 GET {union_url}/config/client 获取配置
3. SDK 解析 UnionClientConfig
4. SDK 使用配置初始化网络层（HTTP/WS/RTC 地址）
5. SDK 使用配置中的特性开关初始化各业务模块
6. 进入登录流程
```

### 5.2 UnionClientConfig 结构

```rust
pub struct UnionClientConfig {
    pub union: String,              // 当前 Union 地址
    pub union_id: i32,             // 当前 Union ID
    pub gateway: String,           // 网关地址
    pub gateway_port: i32,         // 网关端口
    pub ws: String,                // WebSocket 地址
    pub ws_port: i32,              // WebSocket 端口
    pub rtc: String,               // RTC 地址
    pub rtc_port: i32,             // RTC 端口
    pub upload_file_path: String,  // 文件上传路径
    pub upload_icon_path: String,  // 图标上传路径
    pub upload_avatar_path: String,// 头像上传路径
    pub api_gateway: String,       // API 网关前缀
    pub api_register: String,      // 注册接口路径
    pub api_login: String,         // 登录接口路径
    pub features: Vec<String>,     // 支持的功能列表
    pub union_hub: String,         // Master Union Hub 地址
}
```

### 5.3 网络层适配

| 连接 | 配置源 | 说明 |
|------|--------|------|
| HTTP | gateway + gateway_port + api_gateway | REST API 基础 URL |
| WebSocket | ws + ws_port | 长连接地址 |
| RTC | rtc + rtc_port | WebRTC 信令地址 |
| Union Hub | union_hub | 跨 Union 查询 |

---

## 6. Flutter 层适配

### 6.1 启动选择 Union

- **启动页**（Splash）增加 Union 选择/配置界面
- 支持输入 URL 或从预设列表选择
- 配置持久化到本地存储，下次启动自动使用

```
Splash 页面流程:
  1. 检查本地是否有已保存的 Union 配置
  2. 有: 直接连接
  3. 无/连接失败: 展示 Union 选择界面
  4. 用户输入/选择 Union 地址
  5. 获取 /config/client 配置
  6. 保存配置到本地
  7. 初始化 SDK → 进入登录
```

### 6.2 Union 选择器 UI

- 编辑框输入 Union URL
- 预设 Union 列表（可由 Master Union 下发）
- "扫描二维码加入 Union"（未来支持）
- 展示 Union 名称、地区、延迟等基本信息

---

## 7. 部署与运维

### 7.1 配置文件（development.yaml）

```yaml
settings:
  gen_id: true
  union_id: 1024                   # 本 Union 的唯一 ID
  client_config: "config/1024.json" # 客户端配置文件路径
  union_master: true               # 是否作为 Master Union
  union_hub: "http://localhost:8892" # Master Union Hub 地址
  union_register: "http://localhost:8892/api/hub/register" # 注册接口
```

### 7.2 客户端配置文件（config/1024.json）

```json
{
  "union": "https://union-a.example.com",
  "union_id": 1024,
  "gateway": "https://union-a.example.com",
  "gateway_port": 5150,
  "ws": "wss://union-a.example.com",
  "ws_port": 8889,
  "rtc": "wss://union-a.example.com",
  "rtc_port": 8086,
  "upload_file_path": "/storage/file/upload",
  "upload_icon_path": "/storage/icon/upload",
  "upload_avatar_path": "/storage/avatar/upload",
  "api_gateway": "/api/v1",
  "api_register": "/api/accounts/register",
  "api_login": "/api/accounts/login",
  "features": ["im", "calendar", "meeting"],
  "union_hub": "https://master.buzzing-im.com"
}
```

### 7.3 初始化流程

```
服务端启动:
  1. 读取配置 (union_id, union_master, union_hub, client_config 等)
  2. 设置全局 UNION_ID 供 ID 生成器使用
  3. 读取 client_config 文件内容，缓存到内存
  4. 注册路由: GET /config/client → 返回客户端配置
  5. 如果不是 Master Union:
     a. 向 Master Union 发送注册请求
     b. 上报本 Union 的地址和服务信息
  6. 启动各业务模块
```

### 7.4 接入新 Union

```
1. 申请全局唯一 Union ID（联系 Master Union 维护者）
2. 准备独立部署的 PostgreSQL + Redis
3. 配置 development.yaml 中的 union_id、client_config、union_hub 等
4. 准备客户端配置文件（JSON），根据实际域名/端口修改
5. 部署后端服务
6. 验证客户端连接和跨 Union 通信
```

### 7.5 Union 间延迟优化

| 策略 | 说明 |
|------|------|
| 本地缓存 | 跨 Union 用户基本信息缓存到本地 Union，减少实时查询 |
| 批量拉取 | 实体填充时批量请求，减少网络往返 |
| CDN | 文件存储使用对象存储 + CDN，跨 Union 访问不经过应用层 |
| 就近接入 | 客户端自动选择延迟最低的 Union |

---

## 8. 安全与隔离

### 8.1 数据隔离

- 各 Union 的数据库物理/逻辑隔离
- Union 间不直接暴露数据库
- 跨 Union 数据访问必须通过 Hub API

### 8.2 认证

| 场景 | 认证方式 |
|------|----------|
| 客户端 → Union | Token（JWT），由 Union 签发 |
| Union → Union Hub | API Key 或 mTLS |
| Union 间直连 | 基于 Union ID + 签名 |

### 8.3 Union ID 验证

- 服务端收到请求时验证 Token 中的 Union ID 与请求来源一致
- ID 生成器拒绝 Union ID 为 0 的请求
- 部署后 Union ID 不可变更

---

## 9. 里程碑

| 阶段 | 内容 |
|------|------|
| P0 | Union 独立部署 + 客户端配置读取 + ID 生成器 Union ID 支持（已完成） |
| P1 | Union Hub 注册发现 + 跨 Union 用户查询 |
| P2 | 跨 Union 群聊 + 跨 Union 消息推送 |
| P3 | 跨 Union 日历共享 + 跨 Union 文件访问 |
| P4 | 运维工具（Union 健康监控、延迟统计、动态扩容） |

---

## 10. 现有实现对照

| 组件 | 当前状态 | 位置 |
|------|----------|------|
| ID 生成器（12-bit Union ID） | 已实现 | `backend/common/src/lib.rs` |
| union_id 配置读取 | 已实现 | `backend/setting/src/lib.rs` |
| /config/client 端点 | 已实现 | `backend/setting/src/lib.rs` |
| 客户端配置 JSON 文件 | 已实现 | `backend/base/config/1024.json` |
| UnionClientConfig SDK 结构 | 已实现 | `sdk/service/src/lib.rs` |
| 跨 Union 用户查询 | 待实现 | - |
| Union 间注册发现 | 待实现 | setting/src/lib.rs 中已留 `union_register`/`union_update` 桩 |
| 跨 Union 群聊 | 待实现 | - |
| Flutter Union 选择器 | 待实现 | - |
