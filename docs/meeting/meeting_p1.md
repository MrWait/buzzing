# 视频会议功能生产化方案

## 当前现状评估

| 维度 | 状态 |
|------|------|
| 信令 | 自定义 JSON WebSocket，无认证，无会话恢复 |
| TURN | `RtcAuthHandler` 凭证表为空 → 认证永远失败 |
| 连接 | 仅 1-on-1 P2P，无 ICE restart，无重连 |
| 屏幕共享 | 空桩 |
| 多人群组 | 不支持（mesh/SFU 均无）|
| 安全 | 自签名证书，信令无 token 校验 |
| 可观测 | 仅 `L.d()` 日志 |
| UI | 基础 demo 级别 |
| 录音/录制 | 无 |
| 统计/质量 | 无 |

## 架构选择

- **多人通话**：Mesh P2P 作为过渡（≤4人），架构预留 SFU 接入点，后续平滑升级
- **会议录制**：Phase 3 再考虑

## 多窗口架构

### 设计原则

由于 Flutter PC 端原生多窗口未 ready，使用 `desktop_multi_window` 插件实现独立子窗口。
子窗口作为**独立 Flutter Engine 实例**运行，拥有完整的 `MeetingLogic` + `Signaling` + WebRTC 状态，
主窗口通过 `WindowMethodChannel` 传参控制。

### 架构图

```
┌──────────────────────────────────────────────────────────┐
│ 主窗口 (Main Flutter Engine)                              │
│                                                          │
│  MeetingPage                                             │
│  ├─ meeting_view.dart  ← 会议列表 + 在线用户              │
│  ├─ meeting_logic.dart ← 轻量状态：窗口管理、peer 发现    │
│  └─ signaling/ ← 信令连接（发现在线用户）                 │
│                                                          │
│  AppController                                           │
│  └─ createWindow("VcWindow", args)                       │
│       └─ args: { room_id, token, signal_host,            │
│                  turn_config, peer_id }                   │
│                          │                                │
│                    WindowMethodChannel                    │
│                          │                                │
│                          ▼                                │
│ 子窗口 (独立 Flutter Engine)                               │
│                                                          │
│  VcWindow                                                │
│  ├─ vc_view.dart     ← 全屏 WebRTC 视图                  │
│  ├─ vc_logic.dart    ← 独立 MeetingLogic                 │
│  │   ├─ Signaling (独立连接信令服务器)                    │
│  │   ├─ RTCPeerConnection (收发媒体)                     │
│  │   └─ RTCVideoRenderer * N                             │
│  ├─ MeetingVideoView  ← remote + local PiP              │
│  └─ MeetingControls   ← 控制栏                          │
│                                                          │
│  生命周期通信:                                            │
│  ┌──────────────────────────────────────┐                │
│  │ sub_window_close  →  主窗口清理注册   │                │
│  │ sub_window_tick   →  主窗口心跳检测   │                │
│  │ join/leave        →  主窗口同步状态   │                │
│  │ meeting_end       →  主窗口通知 UI    │                │
│  └──────────────────────────────────────┘                │
└──────────────────────────────────────────────────────────┘
```

### 主窗口 → 子窗口参数协议

```dart
// AppController.createWindow 传入
{
  "app": "VcWindow",
  "room_id": "uuid-string",
  "token": "user-jwt-token",
  "signal_host": "wss://meeting.buzzing-im.com/ws",
  "turn_config": {
    "urls": "turn:turn.buzzing-im.com:3478",
    "username": "timestamp:userid",
    "credential": "hmac-signed"
  },
  "peer_id": "optional-p2p-peer-id",
  "media": "video"  // video | screen
}
```

### 子窗口职责

- **独立连接**信令服务器（使用传入的 `token` 和 `signal_host`）
- **独立运行** `Signaling` 和 `RTCPeerConnection`，不依赖主窗口的 WebRTC 状态
- **渲染** remote 视频（全屏）+ local 视频（PiP 小窗）
- **展示**控制栏（切换摄像头、屏幕共享、挂断、静音）
- **发送**生命周期事件回主窗口

### 主窗口职责

- **发现**在线用户（通过自己的 Signaling 连接）
- **发起会议** → 调用 `createWindow("VcWindow", args)` 将会议参数传递给子窗口
- **监听**子窗口关闭/结束事件，清理本地状态
- **不做**任何 WebRTC 媒体处理（仅在子窗口中处理）

### 子窗口生命周期

```
主窗口调用 createWindow()
  │
  ▼
子窗口启动 (startVcWindow)
  │
  ├─ 从 args 解析 room_id / token / signal_host
  ├─ 初始化 VcLogic (独立 MeetingLogic)
  ├─ 连接信令服务器 (Signaling.connect)
  ├─ 加入房间 (Signaling.join)
  │
  ├─ 通话中...
  │   ├─ 收发 offer/answer/candidate
  │   ├─ 用户操作 (mute/switchCamera/hangup)
  │   └─ 每秒心跳 tick → 主窗口
  │
  ├─ 用户挂断 / 对方挂断
  │   ├─ Signaling.bye
  │   └─ 发送 meeting_end → 主窗口
  │
  └─ 窗口关闭
      ├─ 发送 sub_window_close → 主窗口
      └─ 主窗口移除 SubWindow 注册
```

### 与主窗口 Meeting 页面的关系

| 场景 | 主窗口 | 子窗口 |
|------|--------|--------|
| 浏览在线用户 | MeetingPage 展示 peer list | — |
| 邀请某人通话 | createWindow 传 peer_id | 独立信令 `invite(peerId)` |
| 收到来电 | 弹 AcceptDialog | 窗口已打开时静默接收 |
| 通话中 | 可继续浏览其他页面 | 全屏视频通话 |
| 挂断 | 清理状态 | 关闭窗口 / 回到主窗口 |

## 分阶段实施计划

### Phase 1 — 基础加固（2-3周）

#### 1.1 信令认证

- 客户端连接 `/ws` 时携带用户 token（从现有 loginUser 获取）
- 后端 `signaling.rs` 在 `New` 消息中验证 token，提取 `user_id`，拒绝未认证连接
- 使用项目中已有的 JWT/Token 机制，保持一致

**涉及模块**：
- `backend/rtc/src/signaling.rs` — New 消息增加 token 校验
- `buzzing/lib/page/meeting/signaling/signaling.dart` — 连接时传入 token
- `buzzing/lib/page/meeting/meeting_logic.dart` — connect 时提供 loginUser token

#### 1.2 TURN 凭证

- `turn.rs` 实现 `auth_handle`：验证 `username:time` 格式的短期凭证
- 客户端从 `GET /api/turn?token={token}` 获取 HMAC 签名的 TURN 凭证（有效期 1 小时）
- 部署时可选择 coturn（生产推荐）替代自建 TURN

**涉及模块**：
- `backend/rtc/src/turn.rs` — 实现 HMAC 凭证验证
- `backend/rtc/src/lib.rs` — `/api/turn` 端点签发凭证
- `buzzing/lib/page/meeting/signaling/signaling.dart` — `getTurnCredential` 传入 token

#### 1.3 连接可靠性

- 客户端增加 ICE restart：`pc.createOffer({iceRestart: true})` 在网络切换时触发
- WebSocket 重连：指数退避（1s, 2s, 4s, 8s, max 30s），重连后恢复 peer list
- `Signaling` 增加 `keepalive` 超时检测（5s 无消息则重连）

**涉及模块**：
- `buzzing/lib/page/meeting/signaling/signaling.dart` — 重连逻辑 + ICE restart
- `buzzing/lib/page/meeting/meeting_logic.dart` — 重连后恢复状态

#### 1.4 屏幕共享

- 实现 `getDisplayMedia()` 获取桌面分享流
- 客户端 `Signaling.switchToScreenSharing` 完整的 track 替换逻辑
- UI 端增加 source 选择对话框（`DesktopCapturerSource`）

**涉及模块**：
- `buzzing/lib/page/meeting/signaling/signaling.dart` — 完善 `switchToScreenSharing`
- `buzzing/lib/page/meeting/meeting_logic.dart` — `selectScreenSourceDialog` 实现
- `buzzing/lib/page/meeting/widgets/meeting_controls.dart` — 屏幕共享按钮交互

#### 1.5 码率自适应

- 客户端监听 `pc.onIceConnectionState` 和 `RTCStatsReport`
- 根据 `googRtt`、`packetsLost` 动态调整视频编码器的 `maxBitrate`
- 降级策略：1080p → 720p → 480p → audio-only
- 使用 `RTCRtpSender.setParameters()` 实时调整

**涉及模块**：
- `buzzing/lib/page/meeting/signaling/signaling.dart` — stats 采集 + 码率调整
- `buzzing/lib/page/meeting/meeting_logic.dart` — 状态通知 UI

---

### Phase 2 — Mesh P2P 多人通话（3-4周）

#### 2.1 房间模型

- 服务端 `signaling.rs` 支持房间模型：

  ```rust
  Room {
      room_id: String,
      participants: HashMap<peer_id, WsConn>,
  }
  ```

- 客户端 `Signaling` 从 invite(peerId) 改为 join(roomId)
- 广播消息：offer、answer、candidate 自动转发给房间内所有其他参与者

**涉及模块**：
- `backend/rtc/src/signaling.rs` — 房间模型 + 广播逻辑
- `buzzing/lib/page/meeting/signaling/signaling.dart` — 多 PeerConnection 管理
- `buzzing/lib/page/meeting/meeting_logic.dart` — 多人状态管理

#### 2.2 N-1 PeerConnection 管理

- 加入房间后，与每个已存在的参与者建立 `RTCPeerConnection`
- 客户端维护 `Map<String, Session> sessions`，每个远程用户一个 session
- 新入会者通知房间内已有参与者，各自创建新的 PC

**涉及模块**：
- `buzzing/lib/page/meeting/signaling/signaling.dart` — 多 session 管理
- `buzzing/lib/page/meeting/signaling/session.dart` — 扩展 Session 模型

#### 2.3 音视频设备管理

- 枚举设备：`navigator.mediaDevices.enumerateDevices()`
- 设备切换：`getUserMedia` + `replaceTrack` 无需重建 PeerConnection
- 音频处理：`echoCancellation: true`、`noiseSuppression: true`、`autoGainControl: true`

**涉及模块**：
- `buzzing/lib/page/meeting/meeting_logic.dart` — 设备切换方法
- `buzzing/lib/page/meeting/widgets/meeting_controls.dart` — 设备选择 UI

#### 2.4 会议内聊天

- 通过 `RTCDataChannel` 传输文字消息
- 消息格式：JSON `{"type": "chat", "from": uid, "text": "..."}`
- UI 显示为消息列表，与会话页面风格一致

**涉及模块**：
- `buzzing/lib/page/meeting/signaling/signaling.dart` — DataChannel 消息处理
- `buzzing/lib/page/meeting/meeting_view.dart` — 聊天 overlay

---

### Phase 3 — SFU 升级 + 企业功能（4-6周）

#### 3.1 SFU 架构

- 引入 LiveKit Server 作为 SFU
- 客户端改用 `livekit_client` SDK（基于 flutter_webrtc 封装）
- 支持 50+ 人会议，服务端负责转发+转码
- 信令从 P2P 改为 client→LiveKit，TURN 需求降低

**注意**：此步骤涉及较大架构变更，需评估业务需求后再启动。

#### 3.2 会议生命周期管理

- 后端新增会议 API（复用或扩展 `backend/rtc`）：

  | 端点 | 方法 | 说明 |
  |------|------|------|
  | `/api/meeting/create` | POST | 创建会议，返回 `room_id` + token |
  | `/api/meeting/join` | POST | 验证 token，返回信令地址 |
  | `/api/meeting/end` | DELETE | 结束会议 |
  | `/api/meeting/list` | GET | 历史会议列表 |

- 会议数据写入 PostgreSQL（复用已有 `schedule` 表的 `room_id` 字段）
- SDK 层新增 `MeetingService`（参考 `app-calendar` 的实现模式）

**涉及模块**：
- `backend/rtc/src/lib.rs` — 新增 REST 端点
- `backend/rtc/Cargo.toml` — 依赖 sea-orm
- `buzzing/lib/controller/im.dart` 或新建 `meeting_controller.dart`
- `proto/` — 新增 `meeting.proto`

**多窗口交互**：
- `POST /api/meeting/create` 返回的 `room_id` + `token` 传入子窗口
- 子窗口使用这些参数独立连接信令服务器

#### 3.3 邀请机制

- 会议链接通过 IM 消息发送（复用 `ChatMessage` 机制）
- 新增消息类型 `MessageType.MEETING_INVITE`
- 消息内容包含 `room_id`、会议主题、开始时间
- 点击消息直接加入会议

**涉及模块**：
- `proto/message.proto` — 新增 invite 字段
- `buzzing/lib/widget/message.dart` — 新增 invite 消息渲染
- `buzzing/lib/page/meeting/meeting_logic.dart` — 通过 room_id 入会

#### 3.4 日历集成

- 创建日历时 `Schedule.type = 1 (meeting)` + 自动创建会议
- `Schedule.room_id` 关联会议房间
- 日程开始时自动弹出入会入口

**涉及模块**：
- `proto/entity.proto` — 已定义 `type=1` 和 `room_id`
- `buzzing/lib/page/calendar/` — 日程详情显示入会按钮
- SDK `app-calendar` — 创建日程时联动创建会议

#### 3.5 通话统计与质量监控

- 客户端每 5s 采集 `RTCStatsReport`：

  ```json
  {
    "roundTripTime": 42,
    "packetsLost": 3,
    "jitter": 12,
    "bitrate": 1800000,
    "frameRate": 30
  }
  ```

- 上报到服务端监控端点 `/api/meeting/stats`
- 服务端预警：丢包率 > 5% 或 RTT > 300ms 时报警
- 客户端 UI 展示信号质量图标（绿/黄/红）

**涉及模块**：
- `buzzing/lib/page/meeting/signaling/signaling.dart` — stats 定时采集
- `backend/rtc/src/lib.rs` — stats 接收端点
- `buzzing/lib/page/meeting/widgets/` — 信号质量指示器

#### 3.6 VcWindow 子窗口完整化

- 当前 `vc_view.dart` 是占位，需集成完整的 WebRTC 视图
- 子窗口拥有**独立的** `VcLogic`（继承/复用 `MeetingLogic` 的信令逻辑）
- 子窗口与主窗口通过 `WindowMethodChannel` 同步状态

**子窗口内部组件**：
```
VcWindow
├── VcLogic (extends ChangeNotifier)
│   ├── Signaling (独立信令连接)
│   ├── localRenderer / remoteRenderer
│   └── 状态: inCalling, peers, session
├── MeetingVideoView (remote 全屏 + local PiP)
└── MeetingControls (控制栏)
```

**主窗口改动**：
- `MeetingLogic.createMeeting()` → 生成 room_id + 参数 → `createWindow("VcWindow", args)`
- `MeetingLogic.invitePeer()` → 改为先 `createWindow`，子窗口启动后独立 `invite`
- `app_controller.dart` 的 `sub_window_close` handler → 清理 meeting 状态

**涉及模块**：
- `buzzing/lib/page/vc/vc_view.dart` — 集成 MeetingVideoView + MeetingControls
- `buzzing/lib/page/vc/vc_logic.dart` — 完整实现（复用 signaling/ 模块）
- `buzzing/lib/vc.dart` — 从 args 解析参数，注入 VcLogic
- `buzzing/lib/controller/app_controller.dart` — 传参增强
- `buzzing/lib/page/meeting/meeting_logic.dart` — createWindow 传参

---

### Phase 4 — 安全与运维（持续）

#### 4.1 生产证书

- 替换自签名证书为 Let's Encrypt（certbot 自动续期）
- 或使用负载均衡器（Nginx/Caddy）终止 TLS

#### 4.2 速率限制

- 信令每秒最多处理 50 条/连接
- 单用户最多同时参与 3 个会议
- 会议时长限制（默认 24h 自动结束）

#### 4.3 信令协议 Protobuf 化（可选）

- 当前 JSON 信令简单但不可扩展
- 定义 `rtc.proto`：

  ```protobuf
  message SignalMessage {
    SignalType type = 1;
    bytes payload = 2;
    string room_id = 3;
    string from_id = 4;
  }
  ```

- 建议：**保持 JSON 信令**，仅对会议控制命令使用 proto，避免 WebRTC 信令的 JSON 原生优势丢失

#### 4.4 日志与监控

- 信令服务健康检查：`GET /health`
- Prometheus 指标：活跃会议数、参与者数、TURN 流量
- 告警：信令断开率 > 1%、TURN 带宽超限

---

## 建议优先级路线图

```
现在 ───→ Phase 1 ───→ Phase 2 ───→ Phase 3 ───→ Phase 4
          2-3 周       3-4 周       4-6 周        持续
```

### Phase 1 最低可行价值

```
□ 信令认证             ← 最重要的安全门槛
□ TURN 凭证             ← 否则 NAT 穿透必然失败
□ ICE restart + 重连    ← 否则断网即断话
□ 屏幕共享               ← 高频需求
□ 码率自适应             ← 否则弱网体验极差
```
