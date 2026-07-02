# smoke/ping — 连通性 + 登录流程

## 测试目标

验证后端基础连通性和核心登录流程是否正常。

## 测试用例

### 1. should fetch union client config

- **请求**: `GET /config/client`
- **预期**: 返回 JSON，`gateway`、`ws`、`gateway_port` 等字段非空
- **依赖**: 后端运行中

### 2. should login and select non-personal tenant user

- **请求**: `POST /api/accounts/login { phone, password }`
- **预期**: 返回 Account JSON，`users` 数组非空；从 users 中选出 `tenant.id != 0` 的身份
- **依赖**: 测试账号存在，且至少有一个租户身份

### 3. should call HTTP protobuf gateway as non-personal user

- **流程**: `fullLogin()` → `USER_GET_BY_IDS` 查询自己
- **预期**: HTTP 返回 `code=0`，protobuf 响应包含当前用户
- **验证点**: 返回的用户 ID 与登录身份一致
- **依赖**: 用例 2 的登录流程

### 4. should connect WebSocket and send a request

- **流程**: `fullLogin()` → `connectWs()` (通过 upgrade header 传 token) → `wsRequest(USER_GET_BY_IDS)`
- **预期**: WS 连接成功，请求响应匹配 rid，返回用户信息
- **验证点**: WS 响应 code=0，用户 ID 匹配
- **清理**: `closeWs()`

## 约束

- 所有测试依赖外部后端服务（`config.host`）
- 后端不可用时通过 `backendUp` 开关跳过
- WS 使用明文 `ws://` 而非 `wss://`
