# user — 用户查询

## 测试目标

验证用户信息查询接口（USER_GET_BY_IDS）的基本功能。

## 测试用例

### 1. should get user by IDs

- **命令**: `USER_GET_BY_IDS` (1300)
- **请求**: `GetUserByIdsRequest { ids: [当前用户ID] }`
- **预期**: 返回 `GetUserByIdsResponse`，`users` 数组非空
- **验证点**: 返回的用户 ID 与请求 ID 一致
- **依赖**: `fullLogin()` 获取有效 token 和 userId

## 约束

- 仅测试单用户查询场景
- 依赖 `fullLogin()` 完成的身份选择
