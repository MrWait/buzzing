# Backend Test Framework — 设计方案

## 1. 目标

创建一个 JS 测试框架 `backend_test/`，通过 HTTP/WebSocket 直接对后端进行接口和业务功能测试。

---

## 2. 通信协议

所有客户端↔服务端通信使用 protobuf 编码的 `entity.Packet`，经 `cmd` 命令枚举分发。

**Packet 结构**（`proto/entity.proto`）：

```protobuf
message Packet {
    int64 rid = 1;
    int32 cmd = 2;
    int32 code = 3;
    bool http = 4;
    bytes payload = 5;
}
```

### 双通道支持

| 通道 | 地址 | 格式 | 用途 |
|------|------|------|------|
| HTTP | `POST /api/v1` | multipart/form-data, header `cmd`, header `rid`, header `code`(resp) | 业务请求 |
| HTTP (JSON) | `POST /api/accounts/login` | JSON `{ phone, password }` | 登录认证 |
| HTTP (JSON) | `GET /config/client` | JSON | 获取 Union 配置 |
| WebSocket | `ws://host:port` | Binary protobuf `Packet` | 长连接、推送 |

**HTTP 请求格式**：
- Content-Type: `multipart/form-data; boundary=...`
- Body: 单个 `data` 字段包含 protobuf payload 二进制
- Request headers: `rid` (请求ID), `cmd` (命令枚举值), `Authorization: Bearer <token>`
- Response headers: `rid`, `code` (0=成功)

**已知后端问题**：部分未实现接口返回 HTTP code=0 + JSON body `{"error":"Bad Request","description":"handle error"}`，而非 protobuf 响应。

---

## 3. 登录流程

完整的登录和身份选择流程：

```
Step 1: GET /config/client              → UnionConfig JSON
Step 2: client.applyUnionConfig(uc)     → 设置 HTTP/WS 地址
Step 3: POST {gateway}:{port}/api/accounts/login  { phone, password }
                                          → Account JSON
Step 4: 选择非个人用户身份 (tenant.id != 0)
Step 5: 使用选中身份的 token 进行后续请求
```

**Union 配置**：
- 请求：`GET /config/client`
- 响应：`{ "gateway": "https://...", "gateway_port": 5150, "ws": "ws://...", "ws_port": 8889, "api_gateway": "/api/v1", "api_login": "/api/accounts/login", ... }`
- 通过 `client.applyUnionConfig(uc)` 设置 `_httpBase` = `{gateway}:{gateway_port}`、`_wsUrl` = `{ws}:{ws_port}`
- `fullLogin()` 自动执行完整流程：fetchConfig → applyUnionConfig → login → selectNonPersonalIdentity

**登录 API 说明**：
- 响应：`Account` protobuf 结构的 JSON 序列化（snake_case 字段名）
- 需要 `json-bigint` 库解析（Snowflake ID 超过 JS Number 精度）

---

## 4. 目录结构

```
backend_test/
├── package.json              # npm 项目 (protobufjs, ws, json-bigint)
├── config/
│   └── default.js            # 默认配置（host/phone/password，仅用于下载 Union Config）
├── scripts/
│   └── gen-proto.sh          # proto 编译脚本（runtime 加载，无需预编译）
├── lib/
│   ├── index.js              # 统一导出
│   ├── proto.js              # protobuf runtime 加载 (protobufjs, keepCase)
│   ├── packet.js             # Packet 编解码 + rid 生成
│   ├── client.js             # BuzzingClient (HTTP + WebSocket)
│   ├── auth.js               # 登录流程
│   ├── config.js             # 配置读取
│   ├── json.js               # json-bigint 解析器
│   └── decode.js             # safeDecode / Long 兼容工具
├── test/
│   ├── helper.js             # 共享辅助方法 (init / createLoggedInClient)
│   ├── smoke/
│   │   └── ping.test.js      # 连通性 + 完整登录流程测试 (4 tests)
│   ├── user/
│   │   └── user.test.js      # 用户查询
│   ├── im/
│   │   ├── chat.test.js      # 群聊 CRUD
│   │   ├── message.test.js   # 消息发送/读取
│   │   └── feed.test.js      # Feed 列表/置顶/免打扰
│   ├── calendar/
│   │   └── calendar.test.js  # 日历/日程 CRUD
│   └── setting/
│       └── setting.test.js   # 设置读写
```

---

## 5. 核心 API

### lib/auth.js

| 函数 | 说明 |
|------|------|
| `fetchConfig()` | GET `/config/client` → UnionConfig JSON |
| `loginByPhone(client, phone, password, loginUrl?)` | POST JSON 登录 → `{ token, user, account, loginUser }` |
| `selectNonPersonalIdentity(account)` | 从 Account.users 选出第一个 `tenant.id != 0` 的用户 |
| `fullLogin(client, phone, password)` | 四步合一：fetchConfig → applyUnionConfig → login → selectNonPersonalIdentity |

### lib/packet.js

| 函数 | 说明 |
|------|------|
| `nextRid()` | 生成递增请求 ID（string，因 protobufjs int64 不支持 BigInt） |
| `encodePacket(cmd, payload, http?)` | 编码 `entity.Packet` protobuf |
| `decodePacket(bytes)` | 解码 `entity.Packet` protobuf |

### lib/client.js (BuzzingClient)

| 方法/属性 | 说明 |
|-----------|------|
| `httpRequest(cmd, payloadBytes)` | POST `/api/v1` multipart → `{ rid, code, data }` |
| `connectWs()` | 建立 WebSocket 连接（header 传 token），30s ping 心跳 |
| `wsRequest(cmd, payloadBytes, timeout?)` | 通过 WS 发起请求，rid 匹配响应 |
| `onPush(handler)` | 注册推送回调 `(cmd, payload, rid)` |
| `closeWs()` | 关闭 WS 连接 |
| `setAuth(token, account, user)` | 设置认证信息 |
| `applyUnionConfig(uc)` | 从 Union 配置提取 HTTP/WS 地址 |
| `token` / `userId` / `tenantId` / `wsConnected` | 属性 |

### lib/decode.js

| 函数 | 说明 |
|------|------|
| `safeDecode(proto, typeName, data)` | 尝试解码为指定类型，失败时回退到 `CommonError` |
| `str(val)` | int64/Long 对象转字符串 |
| `isZero(val)` | 检查 int64 值是否为 0（兼容 Long 对象） |
| `isNonZero(val)` | 检查 int64 值是否非空非零 |

### test/helper.js

| 函数 | 说明 |
|------|------|
| `init()` | 初始化 protobuf |
| `createLoggedInClient()` | 创建已登录的 BuzzingClient（使用非个人用户 + fullLogin） |

---

## 6. 编写测试

使用 Node.js 内置 `node:test`（v18+）。

```javascript
import { describe, it, before } from 'node:test';
import assert from 'node:assert/strict';
import { initProto, getProto, BuzzingClient, fullLogin, getConfig, safeDecode, str } from '../../lib/index.js';

before(async () => { await initProto(); });

describe('chat module', () => {
  it('should create a chat', async () => {
    const config = getConfig();
    const client = new BuzzingClient();
    const login = await fullLogin(client, config.phone, config.password);

    const cmdEnum = getProto().lookupEnum('command.Command');
    const CreateChatRequest = getProto().lookupType('chat.CreateChatRequest');
    const Chat = getProto().lookupType('entity.Chat');

    const reqBytes = CreateChatRequest.encode(
      CreateChatRequest.create({
        chat: Chat.create({ chat_type: 2, name: 'test group', member_ids: [str(client.userId)] })
      })
    ).finish();

    const res = await client.httpRequest(cmdEnum.values.CHAT_CREATE, reqBytes);
    assert.ok(res.code === 0 || res.code === 200);

    const dec = safeDecode(getProto(), 'chat.CreateChatResponse', res.data);
    assert.ok(dec.ok);
    assert.ok(dec.result.chat_id);
  });
});
```

### 测试注意事项

1. **int64/Long 兼容**：protobufjs 对 int64 字段返回 `Long` 对象，不能直接用 `===` 或 `assert.equal` 比较。使用 `str(val)` 或 `String(val)` 转字符串后再比较。
2. **JSON 错误响应**：部分未实现接口返回 JSON 而非 protobuf。使用 `safeDecode()` 会自动检测并解码为 `CommonError`。
3. **Snowflake ID 精度**：用户/消息 ID 可能超过 `Number.MAX_SAFE_INTEGER`，需用 `json-bigint` 以字符串形式解析 JSON。
4. **SSL**：开发环境使用自签名证书，需设置 `NODE_TLS_REJECT_UNAUTHORIZED=0`。
5. **WS 地址**：后端 WS 服务使用明文 WebSocket（`ws://`），不是 `wss://`。

---

## 7. 与 SDK app-network 的对照

| SDK (Rust) | backend_test (JS) | 说明 |
|------------|--------------------|------|
| `connection.rs::ws_task()` | `lib/client.js::connectWs()` | WS 连接管理 |
| `lib.rs::request()` | `client.httpRequest()` | HTTP 请求 |
| `http.rs::init_user_client()` | `client.setAuth()` | 设置认证 token |
| `buzzing/src/app.rs` login | `lib/auth.js::fullLogin()` | 完整登录流程 |
| `AppTrait::request()` | `client.wsRequest()` | WS 请求/响应匹配 |
| `proto::idl::*` | `lib/proto.js` (runtime) | protobuf 绑定 |

---

## 8. 默认配置

| 变量 | 默认值 |
|------|--------|
| 服务端地址（仅用于下载 Union Config） | `https://www.buzzing-im.com:5150` |
| 测试手机号 | `10011110003` |
| 测试密码 | `123456` |
| AppVersion | `0.1.0` |
| DeviceId | `backend-test-device` |

---

## 9. 分步实施计划

### Phase 1: 基础设施 (已完成)

- [x] 目录结构 + package.json (protobufjs, ws, json-bigint)
- [x] protobuf runtime 加载 (protobufjs parse)
- [x] Packet 编解码 + rid 生成
- [x] BuzzingClient HTTP 通道 (multipart/form-data)
- [x] 登录流程 (fetchConfig + loginByPhone + selectNonPersonalIdentity + fullLogin)
- [x] smoke 测试（连通性 + HTTP/WS 网关 + 非个人用户身份选择）
- [x] json-bigint 集成（Snowflake ID 精度）
- [x] safeDecode 错误处理 + Long 兼容工具

### Phase 2: WebSocket 支持 (已完成)

- [x] `lib/client.js` WS 通道: `connectWs()`, `wsRequest()`, 30s ping 心跳, rid 匹配
- [x] WS 认证通过 upgrade headers (`x-buzzing-token`, etc.)
- [x] `test/smoke/ping.test.js` 含 WS 测试
- [x] 推送接收回调: `onPush(handler)`
- [x] WS 连接断开自动清理等待队列

### Phase 3: 业务模块测试 (21/27 通过)

- [x] **user** — 用户查询 (1/1)
- [x] **im/chat** — 创建群聊、按 ID 查询、更新群信息 (3/3)
- [x] **im/message** — 发送消息、范围查询、ID 查询、已读、Reaction (5/5)
- [x] **im/feed** — 列表、置顶/免打扰、活跃 (4/4)
- [ ] **calendar** — 日历/日程 CRUD (7/10) — 更新日历/日程返回空、SchedulePull 返回 JSON 错误
- [ ] **setting** — 设置读写 (1/4) — 查询接口返回 JSON 错误

> **说明**：未通过的 6 个测试均为服务端接口未完整实现（返回 JSON `{"error":"Bad Request"}` 或空响应）。草稿功能为 SDK 专属，不在服务端测试范围内。待服务端完善后可直接生效。

### Phase 4: 测试基础设施完善

- [x] 独立测试租户 — `utils/init_test.json`，手机号 `1011111****`
- [ ] 多用户测试（同时登录多个用户模拟交互）
- [ ] 错误场景测试
- [ ] CI 集成（`just backend_test`）
- [ ] 测试报告生成
