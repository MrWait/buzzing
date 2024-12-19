# Rust SDK

## 概述

SDK 是嵌入在 Flutter 进程中运行的 Rust 库，负责本地缓存、网络通信、状态管理。通过 `flutter_rust_bridge` 暴露给 Dart 层。

## 目录结构

```
sdk/
├── flink/           # SDK 入口 + FFI 桥接
├── service/         # Trait 层定义
├── app-account/     # 用户/账户实现
├── app-chat/        # 聊天/消息/Feed 实现
├── app-calendar/    # 日历实现
├── app-common/      # 配置、任务管理、本地 DB
├── app-ffi/         # FFI 事件注册
├── app-network/     # 网络层 (WS + HTTP)
├── app-todo/        # 任务实现
├── base-db/         # SQLite 连接封装
├── base-log/        # 日志初始化
├── base-runtime/    # Tokio 运行时管理
├── base-util/       # 工具函数
├── proto/           # Protobuf 生成代码
└── flink-cli/       # CLI 调试工具
```

## Trait 层 (`service/src/`)

| Trait | 方法 | 说明 |
|-------|------|------|
| `AppTrait` | init, uninit, login, logout, on_ffi_command, on_net_command, on_event | 生命周期 + 命令分发 |
| `BizAccount` | get_user, fill_entity | 用户信息 + 实体填充 |
| `BizChat` | 聊天相关操作 | 本地聊天缓存 |
| `BizNetwork` | request, longlink_state, on_event | HTTP + WebSocket 管理 |
| `BizCommon` | get_config, save_config, task | 配置 + 后台任务 |
| `BizFfi` | reg_pull_handler, reg_push_handler | FFI 推送注册 |
| `BizCalendar` | 日历操作 | 本地日历缓存 |
| `BizTodo` | 任务操作 | 本地任务缓存 |

## FFI 桥接 (`flink/`)

Dart 通过 `flutter_rust_bridge` 调用以下函数：

| 函数 | 说明 |
|------|------|
| `flink_init(param)` | 初始化 SDK |
| `flink_invoke(param)` | 发送命令 (fire-and-forget) |
| `flink_reg_push_handler(sink)` | 注册推送流 |
| `flink_reg_invoke_handler(sink)` | 注册调用结果流 |

Dart 侧使用 `Channel` 模式：通过 seq 编号匹配异步请求-响应。

## 网络层 (`app-network/`)

### 双通道请求
1. 优先通过 WebSocket 长连接发送请求
2. 如果 500ms 内未收到响应，同时触发 HTTP 回退请求
3. 先收到的有效响应作为最终结果

### WebSocket (`connection.rs`)
- 基于 `tokio-tungstenite`
- 自动重连 (最多 6 次，指数退避)
- 30 秒心跳
- 包格式：Protobuf 编码二进制

### HTTP (`http.rs`)
- 基于 `reqwest`
- 支持 multipart 文件上传
- 携带设备信息、认证 token 头
- 支持 Cookie 持久化

## 本地缓存

- 基于 SQLite (各 app 模块独立 database)
- `app-chat` 管理 Chat/Message/Feed/Favorite 本地表
- `app-account` 管理 User 本地表
- 消息草稿支持 (未发送消息本地暂存)
