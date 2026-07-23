# 架构概览

## 整体架构

```
[Flutter Desktop Client]  <--FFI-->  [Rust SDK (本地)]  <--WS/HTTP-->  [Rust Backend (Loco-RS)]
       ^                                                                         |
       |                                                                         v
  (flutter_rust_bridge)                                                   [PostgreSQL]
```

三层架构：
1. **服务端** (Rust/Loco-RS) — 提供 REST + WebSocket 接口，连接 PostgreSQL
2. **SDK** (Rust) — 嵌入在 Flutter 进程中的客户端库，管理本地状态和网络连接
3. **客户端** (Flutter) — 桌面端 UI，通过 FFI 调用 Rust SDK

## 技术栈

| 层 | 技术 | 说明 |
|----|------|------|
| 后端框架 | **loco-rs** 0.16 | 基于 axum 0.8 的 Rails-like 框架 |
| HTTP 服务器 | **axum-server** 0.7 | 支持 TLS (rustls) |
| ORM | **sea-orm** 1.1 | 支持 PostgreSQL + SQLite |
| 数据库 | **PostgreSQL** | 主存储（含 loco queue） |
| 缓存 | **moka** | 进程内内存缓存 |
| 序列化 | **prost** 0.13 | Protobuf 编解码 |
| WebSocket | **tokio-tungstenite** | 全双工长连接 |
| CRDT | **yrs** + **yrs-axum** | 协作文档编辑 |
| SDK 运行时 | **tokio** | 异步运行时 |
| SDK HTTP | **reqwest** 0.12 | 支持 multipart |
| SDK 本地 DB | **SQLite** (base-db) | 本地缓存 |
| 客户端框架 | **Flutter** ^3.9.2 | 桌面端为主 |
| 状态管理 | **Riverpod** | Notifier + ref.watch |
| FFI 桥接 | **flutter_rust_bridge** 2.11 | Dart ↔ Rust |
| 网络 (Dart) | **Dio** 5.5 | HTTP 拦截器 |
| WebRTC | **flutter_webrtc** 1.2 | 音视频通话 |

## 设计模式

1. **命令模式** — 所有客户端↔服务端通信使用统一的 protobuf 编码包 + 命令枚举分发
2. **插件架构** — 后端各模块实现 `ExternApp` trait，通过 `AppHub` 统一注册分发
3. **实体填充** — 返回实体时自动附加关联实体（如 Feed 附带 Chat/Message/User）
4. **CMV 版本向量** — 使用紧凑位向量追踪聊天成员和消息读取状态
5. **双通道网络** — SDK 优先走 WebSocket 长连接，超时后自动降级到 HTTP
6. **Snowflake ID** — 自定义 64 位 ID 生成器：`[12-bit 集群 | 32-bit 时间戳 | 20-bit 序列]`

## 协议流

```
用户操作 → Riverpod Notifier → SdkController.invokeAsync()
  → FFI (invoke) → Rust SDK 本地处理
  → app-network WebSocket/HTTP → 服务端 Gateway
  → AppHub 命令分发 → 模块 Handler → DB 操作
  → 响应回传 + 通过 BizGateway 推送其他用户
  → 接收端 WebSocket Push → FFI 回调 → ref.watch UI 更新
```
