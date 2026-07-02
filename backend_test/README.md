# Backend Test Framework

JS 测试框架，通过 HTTP/WebSocket 直接测试后端接口。

## 快速开始

```bash
cd backend_test
npm install
npm test
```

## 默认配置

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `BUZZING_HOST` | 服务端地址 | `https://www.buzzing-im.com:5150` |
| `BUZZING_WS_HOST` | WebSocket 地址 | `wss://www.buzzing-im.com:8889` |
| `BUZZING_PHONE` | 测试手机号 | `10011110003` |
| `BUZZING_PASSWORD` | 测试密码 | `123456` |

## 登录流程

测试框架默认使用非个人用户租户身份进行测试：

1. `GET /config/client` — 获取 Union 连接配置
2. `POST /api/accounts/login` — 手机号+密码登录，获取 Account（含所有身份）
3. 从 `account.users` 中选出第一个 `tenant.id != 0` 的非个人用户

详见 `docs/backend_test.md`。

## 运行测试

```bash
# 全部测试
npm test

# 仅 smoke 测试
npm run test:smoke
```

## 项目结构

```
backend_test/
├── config/default.js     # 默认配置
├── lib/
│   ├── proto.js          # protobuf runtime 加载
│   ├── packet.js         # Packet 编解码 + rid 生成
│   ├── client.js         # BuzzingClient (HTTP)
│   ├── auth.js           # 登录流程 (fetchConfig / loginByPhone / selectNonPersonalIdentity / fullLogin)
│   └── index.js          # 统一导出
└── test/
    ├── helper.js         # createLoggedInClient
    └── smoke/
        └── ping.test.js  # 连通性 + 完整登录流程
```

## 编写测试

```javascript
import { describe, it, before } from 'node:test';
import { initProto } from '../../lib/proto.js';
import { BuzzingClient, fullLogin, getConfig } from '../../lib/index.js';

before(async () => { await initProto(); });

describe('my module', () => {
  it('should do something', async () => {
    const client = new BuzzingClient();
    const login = await fullLogin(client, getConfig().phone, getConfig().password);
    // login.user / login.tenant / login.token 已设置为非个人用户
  });
});
```

## 通信方式

- **登录**: `POST /api/accounts/login` (JSON)
- **Union 配置**: `GET /config/client` (JSON)
- **业务请求**: `POST /api/v1/` (multipart/form-data, protobuf `Packet`)
- **WebSocket**: Binary protobuf `Packet` (近期支持)
