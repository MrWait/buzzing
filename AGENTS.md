# Buzzing — 项目概况

## 项目简介

Buzzing 是一个企业级协作平台（类飞书/钉钉/Slack），包含完整的服务端、SDK、客户端代码。

## 技术栈

| 层 | 技术 | 说明 |
|----|------|------|
| 后端 | Rust, loco-rs 0.16 (axum 0.8), sea-orm 1.1 | PostgreSQL + Redis |
| SDK | Rust, tokio, reqwest, tokio-tungstenite | 嵌入 Flutter 进程 |
| 客户端 | Flutter 3.9, Riverpod, flutter_rust_bridge 2.11 | 桌面端 (Windows/macOS/Linux) |
| 前端 SPA | Vue 3.5, Pinia 3, Vue Router 4, Axios, Vite 8 | 管理后台/Web 版 |
| 协议 | Protobuf (prost 0.13) | 全平台统一编译 |

## 架构

```
[Flutter Desktop Client]  <--FFI-->  [Rust SDK]  <--WS/HTTP-->  [Rust Backend (loco-rs)]
                                                                       |
[Vue3 SPA (Web)]        <-------------WS/HTTP-------------------> [PostgreSQL] [Redis]
```

## 模块分布

| 目录 | 说明 |
|------|------|
| `backend/` | Rust 后端 (loco-rs 单体)，按功能拆分子模块 |
| `sdk/` | Rust SDK，通过 FFI 嵌入 Flutter |
| `buzzing/` | Flutter 客户端 |
| `frontend/` | Vue3 SPA 前端 (管理后台/Web版) |
| `proto/` | 共享 Protobuf 定义 |
| `docs/` | 项目文档 |
| `buzzing/sdk_test/` | 基于 dart 的自动化测试框架 |
| `utils` | 使用 js 的数据初始化工具 |
| `backend_test` | 使用 js 的服务端业务测试套件 |

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
- Flutter 状态管理：Riverpod (Notifier + ref.watch)
- 客户端、SDK、服务端均使用 proto 通信，存储在项目目录 proto/ 中
- 客户端实现业务中展示、用户交互的部分，SDK 负责实现业务逻辑（网络接口、服务端交互、数据同步、数据存储、日志、埋点等非 UI 功能）。
- SDK 原则上仅使用 rust 技术栈，如果某个功能无法使用 rust 实现，或者 rust 实现效果比较差，先进行询问。
- 在实现用户请求的功能时，如果功能较为复杂，先给出方案，由用户审核。
- 客户端代码中，style 必须使用 theme.dart 中的定义，不允许硬编码样式。如果 theme.dart 中无适合类型，可自行增加。
- 添加自动化测试用例（包括 buzzing/sdk_test, backend_test），需添加 spec 文件，用于描述用例。且测试用例和 spec 要同步修改。
- backend、SDK 在构建时，自动编译 proto 文件，无需单独生成。
- 服务端可以从 http 请求 token、ws 连接 token 中解析用户的信息。
- 客户端增加文本，使用多语言系统，不要硬编码。
- 前端 SPA 使用 `frontend/` 目录，技术栈 Vue 3.5 + Pinia 3 + Vue Router 4 + Axios + Vite 8。
- 前端 SPA 路由定义在 `frontend/src/router/index.ts`，导航守卫在 `frontend/src/router/guards.ts`。
- 前端 SPA 使用 Pinia store 管理状态，位于 `frontend/src/stores/`。
- 前端 SPA API 请求通过 `frontend/src/services/api.ts`（Axios 实例），自动注入 Bearer token，401 响应触发退出登录。
- 前端 SPA 无需本地化（i18n），文案使用中文硬编码。
- 前端 SPA 样式写在各 SFC 的 `<style scoped>` 中；ProseMirror 编辑器样式在 `frontend/src/styles/editor.css`。
- 前端 SPA 使用 `@/` 别名映射到 `frontend/src/`。
- 前端开发命令：`npm run dev`（开发服务器）、`npm run build`（类型检查+构建）。

## 文档导航

| 文档 | 描述 |
|------|------|
| [架构概览](docs/architecture.md) | 整体架构、技术栈、分层设计 |
| [服务端](docs/server.md) | 后端模块划分、路由、数据库、关键设计 |
| [SDK](docs/sdk.md) | Rust SDK 模块划分、FFI 桥接、网络层 |
| [客户端](docs/client.md) | Flutter 客户端页面、状态管理、路由 |
| [客户端主题设计系统](docs/client_style.md) | 颜色/字体/ThemeExtension 设计方案 |
| [协议与 API](docs/protocol.md) | Protobuf 协议、命令枚举、数据流 |
| [数据库](docs/database.md) | 数据库表结构、关系说明 |
| [日历业务](docs/calendar/calendar_p1.md) | 日历业务功能 PRD (Phase 1) |
| [日历排列](docs/calendar-layout-algorithm.md) | 日历重叠日程排列算法 |
| [服务端测试](docs/backend_test.md) | 服务端测试套件 |
| [前端架构](docs/frontend_arch.md) | Vue3 SPA 架构、路由、Layout、状态管理、协同编辑 |
| [前端设计指南](docs/frontend_style.md) | 设计令牌、组件模式、布局系统、写作规范 |


## 编译命令
常用命令都在 justfile 中，大部分命令都可以通过 just 运行。如果新增命令或脚本，建议添加到 justfile。
