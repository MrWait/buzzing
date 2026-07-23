# 服务端 (Backend)

## 目录结构

```
backend/
├── app/           # 主入口，组装所有模块到 AppHub + BizHub
├── base/          # Loco-rs Hooks 实现 (启动、路由、worker)
├── common/        # 共享工具：ID 生成、缓存、配置、头像生成
├── gateway/       # API 网关 + WebSocket 信令
├── im/            # 即时通讯 (聊天、消息、Feed)
├── user/          # 用户 & 部门
├── calendar/      # 日历 & 日程
├── setting/       # 用户设置
├── store/         # 文件存储 (上传/下载)
├── rtc/           # WebRTC 信令 + TURN
├── todo/          # 任务管理
├── office/        # 协作文档 (Yjs/Yrs CRDT)
├── migration/     # SeaORM 数据库迁移
└── proto/         # Protobuf 编译
```

## 关键 Trait

| Trait | 作用 | 实现者 |
|-------|------|--------|
| `ExternApp` | 模块生命周期：路由、WS 命令处理、实体填充 | 所有功能模块 |
| `BizGateway` | 向用户推送消息 (WS/离线管道) | AppGateway |
| `BizStore` | 生成文字头像图片 | DefaultBizStore |
| `BizUser` | 按 ID 获取用户 | AppUser |
| `BizCalendar` | 创建默认日历 | AppCalendar |
| `BizSetting` | 获取/修改用户设置 | AppSetting |

## 路由

| 路径 | 说明 |
|------|------|
| `POST /api/v1/` | 统一网关入口 (multipart protobuf) |
| `POST /api/v1/user/*` | 用户 REST |
| `POST /api/v1/account/*` | 账户 REST |
| `POST /api/v1/tenant/*` | 租户 REST |
| `POST /api/v1/dept/*` | 部门 REST |
| `POST /storage/*` | 文件上传/下载 |

## WebSocket 协议

- 升级时携带 `x-buzzing-token`, `x-buzzing-appversion`, `x-buzzing-deviceid` 头
- 二进制消息：Protobuf 编码的 `entity.Packet`
- 心跳：30 秒 Ping/Pong
- 服务端推送：新消息、Feed 更新、实体变更

## 命令分发流程

```
客户端请求 Packet { cmd, rid, payload }
  → Gateway (WS/HTTP)
  → AppHub::handle_packet()
    → DashMap<i32, Arc<dyn ExternApp>> 查找
    → 模块 handler 反序列化 payload
    → 业务逻辑 → DB 操作
    → (code, data) 响应
    → BizGateway::send_packet_to_user() 推送其他用户
      → WebSocket 直接推送
      → 离线：Pipeline 表 (Postgres)
```

## 核心实现

### Gateway (`gateway/src/lib.rs`)
- 接收所有客户端请求，分离路径和 body
- `handle_packet()` — 通用包处理入口
- `handle_client_packet()` — WebSocket 包处理
- `send_packet_to_user()` — 推送到在线用户 (WS) 或离线管道

### IM (`im/src/`)
- `chat.rs` — 聊天 CRUD，Chat + User 缓存 (moka)，CMV 管理
- `message.rs` — 消息发送/撤回/已读/表情回复，消息缓存
- `feed.rs` — Feed 列表管理 (置顶、免打扰、最新消息定位)
- `setting.rs` — 收藏夹、置顶列表

### Common (`common/src/`)
- `service.rs` — AppHub/BizHub 定义
- `model.rs` — UserBrief, PresetColor
- `cache.rs` — CommonCache + CacheLoader (moka 内存缓存)
- `config.rs` — 配置读取
- `text_image.rs` — 文字转图片头像 (ab_glyph 字体渲染)

## 运行和部署
主要命令可以通过根目录 justfile 运行。

- 服务端命令需要在 backend/base 目录中，loco-rs 框架要求
- base/config 中存储服务端配置
- 主要使用 loco 作为工具，且需要在 backend/base 目录下运行
- db migrate: cargo loco db migrate
- db reset: cargo loco db reset
- start: cargo loco start
