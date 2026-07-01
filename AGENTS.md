# Buzzing — 项目概况

## 项目简介

Buzzing 是一个企业级协作平台（类飞书/钉钉/Slack），包含完整的服务端、SDK、客户端代码。

## 技术栈

| 层 | 技术 | 说明 |
|----|------|------|
| 后端 | Rust, loco-rs 0.16 (axum 0.8), sea-orm 1.1 | PostgreSQL + Redis |
| SDK | Rust, tokio, reqwest, tokio-tungstenite | 嵌入 Flutter 进程 |
| 客户端 | Flutter 3.9, GetX, flutter_rust_bridge 2.11 | 桌面端 (Windows/macOS/Linux) |
| 协议 | Protobuf (prost 0.13) | 全平台统一编译 |

## 架构

```
[Flutter Desktop Client]  <--FFI-->  [Rust SDK]  <--WS/HTTP-->  [Rust Backend (loco-rs)]
                                                                       |
                                                                  [PostgreSQL] [Redis]
```

## 模块分布

| 目录 | 说明 |
|------|------|
| `backend/` | Rust 后端 (loco-rs 单体)，按功能拆分子模块 |
| `sdk/` | Rust SDK，通过 FFI 嵌入 Flutter |
| `buzzing/` | Flutter 客户端 |
| `proto/` | 共享 Protobuf 定义 |
| `docs/` | 项目文档 |

### 后端模块

| 模块 | 路径 | 说明 |
|------|------|------|
| gateway | `backend/gateway/` | API 网关 + WebSocket 信令 |
| im | `backend/im/` | 即时通讯 (聊天/消息/Feed) |
| user | `backend/user/` | 用户 & 部门 & 租户 |
| calendar | `backend/calendar/` | 日历 & 日程 |
| setting | `backend/setting/` | 用户设置 |
| store | `backend/store/` | 文件存储 |
| rtc | `backend/rtc/` | WebRTC 信令 + TURN |
| todo | `backend/todo/` | 任务管理 |
| office | `backend/office/` | 协作文档 (Yjs CRDT) |
| common | `backend/common/` | 共享工具 (ID生成/缓存/配置) |

## 开发规范

- 所有客户端↔服务端通信使用 **Protobuf 编码包 + 命令枚举** 分发
- proto 定义文件存储在 proto/ 目录中。使用 proto v3 版本，无 optional、required
- 后端模块实现 `ExternApp` trait，注册到 `AppHub` 统一分发
- SDK 实现 `AppTrait` / `BizXxx` trait，通过 `invoke` FFI 入口调用
- ID 生成：Snowflake 变体 `[12-bit 集群 | 32-bit 秒级时间戳 | 20-bit 序列]`
- Flutter 状态管理：GetX (Controller + GetBuilder + Reactive)
- 客户端、SDK、服务端均使用 proto 通信，存储在项目目录 proto/ 中
- 客户端实现业务中展示、用户交互的部分，SDK 负责实现业务逻辑（网络接口、服务端交互、数据同步、数据存储、日志、埋点等非 UI 功能）。
- SDK 原则上仅使用 rust 技术栈，如果某个功能无法使用 rust 实现，或者 rust 实现效果比较差，先进行询问。
- 在实现用户请求的功能时，如果功能较为复杂，先给出方案，由用户审核。

## 文档导航

| 文档 | 内容 |
|------|------|
| `docs/architecture.md` | 整体架构、技术栈、分层设计 |
| `docs/server.md` | 后端模块划分、路由、命令分发 |
| `docs/sdk.md` | SDK trait 层、FFI 桥接、双通道网络 |
| `docs/client.md` | Flutter 页面结构、状态管理、路由 |
| `docs/protocol.md` | Protobuf 协议、命令枚举、数据流 |
| `docs/database.md` | 数据库表结构、CMV 位向量 |
| `docs/calendar-layout-algorithm.md` | 日历重叠日程排列算法 |
| `docs/calendar/calendar_p1.md` | 日历业务功能 PRD (Phase 1) |

## 编译命令
常用命令都在 justfile 中，大部分命令都可以通过 just 运行。如果新增命令或脚本，建议添加到 justfile。
