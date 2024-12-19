# 协议与 API

## Protobuf 定义

所有数据结构和 API 契约定义在 `proto/` 目录，服务端、SDK、Flutter 三方统一编译。

### 核心文件

| 文件 | 说明 |
|------|------|
| `entity.proto` | 核心实体 (User, Chat, Message, Calendar 等) |
| `command.proto` | 全部 RPC 命令枚举 |
| `chat.proto` | 聊天 CRUD 请求 |
| `message.proto` | 消息发送/撤回/已读/表情 |
| `feed.proto` | Feed 列表管理 |
| `user.proto` | 用户注册/登录/Tokens |
| `calendar.proto` | 日历 & 日程 CRUD |
| `gateway.proto` | 网关转发 |
| `server.proto` | 服务端包拉取 |
| `sdk.proto` | SDK 初始化/调用/推送 |
| `error.proto` | 错误码 |
| `pipeline.proto` | 离线消息管道同步 |
| `dept.proto` | 部门 |

## 命令枚举 (`command.proto`)

| 范围 | 分类 | 示例 |
|------|------|------|
| 1000-1099 | SDK | Init, Login, Logout, GetVersion, NetRequest |
| 1050-1057 | Pipeline | PullPacket, PullEntity, PushSettings |
| 1100-1121 | Feed/Chat | CreateChat, AddChatters, Dismiss, SetTop, SetMute |
| 1200-1215 | Message | Send, Recall, Read, Reaction, GetByRange |
| 1300-1302 | User | GetByIds, Update, PushUserInfo |
| 1350 | Dept | GetById |
| 1400-1402 | Search | SearchUser, SearchMessage, SearchChat |
| 1500-1502 | Favorite | Add, Remove, GetList |
| 1600-1616 | Calendar | Calendar CRUD, Schedule CRUD, Subscribe, PullBusy |

## 数据流

### 请求流程 (客户端发送消息)

```
用户输入 → ImController.onSendMessage()
  → SdkController.invokeAsync(CMD_MESSAGE_SEND, proto_bytes)
  → flink_invoke() FFI
    → Rust SDK 处理本地缓存
    → app-network WebSocket 发送
      → 服务端 Gateway 接收
        → AppHub.handle_packet()
          → IM module.chat_send()
            → 保存消息到 PostgreSQL
            → 更新 Feed 位置
            → 推送收件人
              → BizGateway.send_packet_to_user()
                → WebSocket / Pipeline
```

### 推送流程 (接收端)

```
服务端 WebSocket → AppNetwork 接收
  → 反序列化 Packet
  → app-network 回调
    → flink_reg_push_handler sink
      → Dart SdkController.handlePush()
        → ImController.onPushMessages()
          → mergeEntity() → GetBuilder UI 更新
```

### 离线推送

```
用户离线时：
  消息存入 pipelines 表 (sid + user_id 复合主键)
  用户重连后：
    客户端发送 CMD_PULL_PACKET
    服务端拉取所有离线包推送
    客户端确认接收后删除
```

## 网关包结构

### 请求包
```
Packet {
  cmd:  uint32     // 命令枚举
  rid:  uint64     // 请求序列号
  seq:  uint64     // 可选，可靠消息序列号
  data: bytes      // Protobuf 编码的请求体
}
```

### 响应包
```
Packet {
  cmd:  uint32     // 命令枚举
  rid:  uint64     // 对应请求序列号
  code: int32      // 业务状态码 (0=成功)
  data: bytes      // Protobuf 编码的响应体
}
```

### 推送包
```
Packet {
  cmd:  uint32     // 推送命令枚举
  data: bytes      // 推送数据
}
```

## HTTP API

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/v1/` | 统一网关 (multipart/form-data) |
| POST | `/api/v1/user/get-by-ids` | 批量获取用户 |
| POST | `/api/v1/account/sign-in` | 账户登录 |
| POST | `/api/v1/account/sign-up` | 账户注册 |
| POST | `/api/v1/tenant/get` | 获取租户信息 |
| POST | `/api/v1/tenant/get-by-account` | 按账户获取租户列表 |
| POST | `/api/v1/dept/get` | 获取部门 |
| POST | `/api/v1/dept/get-by-tenant` | 获取租户部门树 |
| POST | `/storage/upload` | 文件上传 |
| GET | `/storage/{namespace}/{file_id}` | 文件下载 |
