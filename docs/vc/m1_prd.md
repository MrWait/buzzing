# 视频会议 M1 — 基础加固 PRD

## 1. 概述

### 1.1 目标

修复当前 demo 中阻碍基本可用性的所有阻塞问题，使 1v1 通话达到可用的生产水平，并完成 Web 端基础入会能力。核心聚焦：**安全（信令认证/TURN）、可靠（重连/ICE restart）、功能完整（屏幕共享/码率自适应/子窗口/Web）**。

### 1.2 当前状态

| 模块 | 状态 |
|------|------|
| 信令 | 自定义 JSON WebSocket，**无认证**，任何 WS 连接者自动注册 |
| TURN | `RtcAuthHandler.cred_map` **始终为空** → 所有认证请求返回 `ErrFakeErr` |
| TURN 凭证 API | `GET /api/turn` 返回空 JSON `"{}"` |
| 连接可靠性 | 无 ICE restart，无 WS 重连，无 keepalive 超时检测 |
| 屏幕共享 | `switchToScreenSharing` 桩函数，`_selectScreenSource` 为空 |
| 码率自适应 | 无 stats 采集，无动态码率调整，无降级策略 |
| VcWindow 子窗口 | `vc_view.dart` 仅图标+文字占位，`vc_logic.dart` 无实际信令逻辑 |
| Flutter 1v1 通话 | 基础可用（局域网 P2P），但缺少认证、TURN、重连 |
| Web 端入会 | **不存在**，无 TypeScript Signaling，无可会议页面 |
| Proto 命令 | 无 meeting 相关命令枚举 |
| `/meeting` 端点 | 冗余的 UUID 分发型信令，与 `/ws` 并存 |

---

## 2. 功能需求

### 2.1 信令认证

#### 2.1.1 功能描述

客户端连接信令 WebSocket 时携带 JWT token，服务端校验 token 合法性，拒绝未认证连接。认证机制复用项目已有的用户 Token 体系。

#### 2.1.2 数据模型变更

**`PeerInfo` 新增字段（后端 signaling.rs）：**

```rust
struct PeerInfo {
    pub id: String,        // 原字段
    pub name: String,      // 原字段
    pub user_agent: String,// 原字段
    // 新增：
    pub user_id: i64,      // 从 token 解析的用户 ID
    pub tenant_id: i64,    // 从 token 解析的租户 ID
}
```

**`new` 消息协议变更：**

```json
// 旧协议
{"type": "new", "data": {"id": "random123", "name": "Device", "user_agent": "..."}}

// 新协议 — 客户端不再发送 id/name，服务端从 token 解析
{"type": "new", "data": {"token": "eyJhbGciOiJIUzI1NiJ9..."}}
```

#### 2.1.3 交互流程

```
客户端:
  Signaling.connect()
    → WebSocket 连接建立
    → 发送 {"type": "new", "data": {"token": jwt}}
    → 等待服务端响应

服务端 signaling.rs:
  收到 "new" 消息
    → 从 data.token 读取 JWT
    → 调用项目中已有的 Token 验证函数解码
    → token 有效:
        → 提取 user_id, tenant_id, name
        → 注册客户端到 peers map
        → 推送 peers 列表给所有在线用户
    → token 无效:
        → 返回 {"type": "error", "data": {"reason": "invalid token"}}
        → 关闭连接

客户端收到 peers 列表 → 进入正常信令流程
客户端收到 error → 显示"认证失败"并关闭连接
```

#### 2.1.4 边界情况

- token 过期 → 返回错误，客户端需重新登录获取新 token 后重试
- token 格式错误 → 直接关闭 WS 连接，不注册
- 无 `token` 字段 → 向后兼容? **不兼容**，M1 起强制要求 token
- 来宾模式（无 token）→ M1 **不支持**，M5 引入

#### 2.1.5 API 变更

| 变更 | 说明 |
|------|------|
| 后端 `signaling.rs` | `New` 消息处理增加 token 验证，拒绝未认证连接 |
| 后端 `PeerInfo` | 增加 `user_id`, `tenant_id` 字段 |
| Flutter `Signaling.connect()` | 连接时从 `loginUser` 获取 token 传入 |
| Flutter `Signaling.onSignalingStateChange` | 新增 `ConnectionError` 状态处理认证失败 |

### 2.2 TURN 凭证

#### 2.2.1 功能描述

实现 TURN 服务的 HMAC 凭证认证和凭证签发 API，使穿越 NAT 的设备可以正常建立 P2P 连接。

#### 2.2.2 数据模型

**TURN 凭证格式：**

```
username = "{timestamp}:{user_id}"
    timestamp: Unix 时间戳（秒），表示有效期起点
    user_id:   用户 ID

credential = base64(hmac_sha256(key, username))
    key: 服务端共享密钥（配置文件）
```

**TURN 凭证 API 响应格式：**

```json
{
  "uris": ["turn:turn.buzzing-im.com:3478"],
  "username": "1700000000:10086",
  "password": "base64-hmac-sha256-signature",
  "ttl": 3600
}
```

#### 2.2.3 交互流程

```
客户端:
  Signaling.connect()
    → 发送 GET /api/turn?token={jwt}
    → 服务端验证 token，提取 user_id
    → 生成 username = "{now+3600}:{user_id}"
    → 生成 credential = hmac_sha256(secret_key, username)
    → 返回 {"uris": [...], "username": ..., "password": ..., "ttl": 3600}
    → 客户端使用返回的凭证配置 iceServers
    → 后续 PeerConnection 使用 TURN 作为 relay 候选

TURN 服务端 (turn.rs):
  收到 TURN 分配请求
    → 提取 username, credential
    → 解析 username 中的 timestamp
    → timestamp 已过期 (>3600s) → 拒绝
    → 用共享密钥验证 credential
    → 验证通过 → 允许分配
```

#### 2.2.4 配置项

```toml
[rtc.turn]
secret_key = "your-hmac-secret-key"   # 与 credential 验证共享密钥
credential_ttl_sec = 3600              # 凭证有效期
```

#### 2.2.5 API 变更

| 变更 | 说明 |
|------|------|
| 后端 `turn.rs` | `RtcAuthHandler.auth_handle` 实现 HMAC 验证逻辑 |
| 后端 `lib.rs` | `/api/turn` 实现凭证签发，验证 token 参数 |
| 后端 `Cargo.toml` | 新增 `hmac`, `sha2`, `base64` 依赖 |
| Flutter `Signaling.getTurnCredential()` | 传入 token 参数，解析响应 |
| Flutter `Signaling.connect()` | 连接时调用 getTurnCredential 获取 iceServers |

### 2.3 连接可靠性

#### 2.3.1 功能描述

WebSocket 断线自动重连（指数退避），ICE restart 在网络切换时重建 P2P 连接，keepalive 超时检测及时发现断线。

#### 2.3.2 重连策略

```
指数退避算法:
  第 1 次: 1 秒
  第 2 次: 2 秒
  第 3 次: 4 秒
  第 4 次: 8 秒
  第 5+ 次: 16 秒（上限）
  最大重连次数: 无限（持续尝试）
  
  连接成功后重置退避计数器
```

#### 2.3.3 ICE restart 触发条件

```
1. WebSocket 重连成功后
   → 检测到之前存在活跃的 RTCPeerConnection
   → 调用 pc.createOffer({iceRestart: true})
   → 通过新的 WS 连接发送新 offer

2. 网络状态变更（通过 navigator.connection 或系统回调检测）
   → 从 WiFi 切换到蜂窝 / 从有线到 WiFi
   → 触发 ICE restart

注意: ICE restart 仅重启 ICE 协商，不重建 PeerConnection
      DTLS 和 SRTP 状态保留，所以音视频不中断
```

#### 2.3.4 keepalive 机制

```
客户端每 3 秒发送 {"type": "keepalive", "data": {}}
服务端原样回显

客户端超时检测:
  5 秒未收到 keepalive 响应 → 判定连接断开
  触发重连流程
```

#### 2.3.5 API 变更

| 变更 | 说明 |
|------|------|
| Flutter `Signaling` | 新增 `_reconnectTimer`, `_reconnectAttempts` 状态 |
| Flutter `Signaling` | `onClose` 回调触发重连逻辑 |
| Flutter `Signaling` | `connect()` 提取为可重入方法 |
| Flutter `Signaling` | `createOffer` 添加 `iceRestart` 参数 |
| Flutter `Signaling` | 新增 `_keepaliveTimer`, `_keepaliveTimeout` |
| Flutter `Signaling` | 重连后自动恢复 session 和 PeerConnection |
| Flutter `MeetingLogic` | 新增 `onReconnect` 回调通知 UI 恢复 |
| Web `Signaling.ts` | 同 Flutter，实现指数退避重连 |
| Web `Signaling.ts` | 同 Flutter，实现 keepalive |

### 2.4 屏幕共享

#### 2.4.1 功能描述

支持在通话中共享整个屏幕或指定窗口。共享后远程参会者看到屏幕内容，本地继续显示摄像头预览供切换。

#### 2.4.2 交互流程

```
Flutter 端:
  用户点击控制栏「共享屏幕」按钮
    → 调用系统桌面捕获 API (getDisplayMedia)
    → 弹出窗口选择器（整个屏幕/窗口/浏览器标签）
    → 用户选择后:
        → 获取 MediaStream（屏幕流）
        → 用 replaceTrack 替换当前视频 track 的音视频轨
        → 通知远程端通过 ICE 重协商获得新流
    → 共享中:
        → 按钮变为「停止共享」状态
        → 控制栏显示正在共享的窗口名称
    → 用户再次点击「停止共享」
        → 恢复摄像头流
        → replaceTrack 替换回摄像头 track

Web 端:
  navigator.mediaDevices.getDisplayMedia()
    → 浏览器原生弹出选择器
    → 后续 replaceTrack 逻辑与 Flutter 相同
```

#### 2.4.3 边界情况

- 用户取消选择 → 不替换 track，按钮恢复
- 共享窗口被关闭 → 浏览器/系统自动停止流，`onTrackEnded` 回调触发切回摄像头
- 屏幕共享中挂断 → 在 `bye` 中清理 screen stream
- 分辨率选择 → 默认 1920x1080，用户可在选择器中切换

#### 2.4.4 API 变更

| 变更 | 说明 |
|------|------|
| Flutter `Signaling.switchToScreenSharing()` | 补齐 `getDisplayMedia` 调用 + track 替换 |
| Flutter `MeetingLogic` | 新增 `_selectScreenSource()` 实现 |
| Flutter `MeetingControls` | 屏幕共享按钮状态管理（共享中/未共享） |
| Flutter `DesktopCapturerSource` | 使用 `flutter_webrtc` 的 `getDisplayMedia` |
| Web `Signaling.ts` | 新增 `startScreenShare()` / `stopScreenShare()` |
| Web `MeetingRoomView.vue` | 屏幕共享按钮 + 状态指示 |

### 2.5 码率自适应

#### 2.5.1 功能描述

采集 ICE 连接状态和 RTCStats，根据网络质量动态调整视频编码码率，弱网时自动降级。

#### 2.5.2 降级策略

```
网络质量分级:
  优秀: RTT < 50ms, 丢包率 < 1%   → 1080p, maxBitrate=2500kbps
  良好: RTT < 150ms, 丢包率 < 3%  → 720p,  maxBitrate=1500kbps
  一般: RTT < 300ms, 丢包率 < 5%  → 480p,  maxBitrate=800kbps
  差:   RTT >= 300ms, 丢包率 >= 5% → audio-only（关闭视频）

  5秒内持续在更差等级 → 降级
  10秒内持续在更好等级 → 升级
```

#### 2.5.3 统计采集

```
每 5 秒采集一次 RTCStatsReport:

{
  "roundTripTime": 42,       // ms, ICE 往返时延
  "packetsLost": 3,          // 总丢包数
  "packetsReceived": 1500,   // 总收包数
  "jitter": 12,              // ms, 抖动
  "bitrate": 1800000,        // bps
  "frameRate": 30,           // fps
  "frameWidth": 1920,        // px
  "frameHeight": 1080        // px
}
```

#### 2.5.4 API 变更

| 变更 | 说明 |
|------|------|
| Flutter `Signaling` | `pc.onIceConnectionState` 实现状态监听 |
| Flutter `Signaling` | 新增 `_statsTimer` 定时采集 |
| Flutter `Signaling` | 新增 `_adjustBitrate()` 动态调整 `RTCRtpSender.setParameters()` |
| Flutter `MeetingVideoView` | 网络质量图标（绿/黄/红） |
| Flutter `MeetingLogic` | 新增 `networkQuality` 状态 |
| Web `Signaling.ts` | 同 Flutter，使用 `RTCRtpSender.setParameters()` |
| Web `MeetingRoomView.vue` | 网络质量指示器 UI |

### 2.6 VcWindow 子窗口完整化

#### 2.6.1 功能描述

当前子窗口仅显示占位图标。M1 使其成为功能完整的独立视频通话窗口，包含本地/远程视频渲染、控制栏、独立信令连接。

#### 2.6.2 架构设计

```
VcWindow (子窗口)
├── VcLogic (ChangeNotifier)
│   ├── Signaling (独立 WS 连接，复用 signaling.dart)
│   ├── localRenderer / remoteRenderer
│   └── 状态: inCalling, networkQuality, videoSource
├── MeetingVideoView
│   ├── remote 视频 (fullscreen)
│   └── local 视频 (PiP, 右下角)
└── MeetingControls
    ├── 静音按钮
    ├── 摄像头切换按钮
    ├── 屏幕共享按钮
    └── 挂断按钮
```

#### 2.6.3 参数协议

主窗口通过 `createWindow` 传入参数：

```dart
// AppController.createWindow("VcWindow", true, true, args)
{
  "app": "VcWindow",
  "host": "meeting.buzzing-im.com",
  "port": 5150,
  "token": "user-jwt-token",           // 信令认证用
  "turn_credential": {                  // TURN 凭证（预获取）
    "uris": ["turn:turn.buzzing-im.com:3478"],
    "username": "1700000000:10086",
    "password": "base64-hmac-signature"
  },
  "room_id": "uuid-string",            // 会议房间 ID
  "peer_id": "target-peer-id",         // 1v1 对方 ID
  "media": "video"                     // video | screen
}
```

#### 2.6.4 生命周期通信

```
主窗口 → 子窗口 (MethodChannel):
  close:  主窗口要求子窗口关闭
  show:   主窗口要求子窗口显示
  join:   主窗口通知子窗口加入某会议
  leave:  主窗口通知子窗口离开会议

子窗口 → 主窗口 (MethodChannel):
  sub_window_close:  子窗口已关闭
  sub_window_tick:   心跳（每秒）
  meeting_end:       会议已结束（对方挂断/网络断开）
```

#### 2.6.5 交互流程

```
主窗口 MeetingPage:
  用户点击「创建会议」
    → 生成 room_id (UUID)
    → 获取 TURN 凭证
    → 调用 AppController.createWindow("VcWindow", args)
      args 包含 host, token, turn_credential, room_id, media
    → 子窗口启动

子窗口 VcWindow:
  initState()
    → 从 args 解析参数
    → 初始化 VcLogic
    → VcLogic.init():
        → 初始化渲染器 (local.initialize, remote.initialize)
        → 创建 Signaling(uid, token, turnCredential)
        → Signaling.connect(host, port)
        → 连接成功后:
            → 注册到房间: {"type": "join", "data": {"room_id": ...}}
            → 等待 peers 列表
            → 如果有对端，自动 invite

  用户操作:
    → 点击挂断 → Signaling.bye(sessionId) → 关闭窗口
    → 点击静音 → Signaling.muteMic()
    → 点击切摄像头 → Signaling.switchCamera()
    → 点击屏幕共享 → Signaling.switchToScreenSharing(getDisplayMedia())

  dispose()
    → 清理 Signaling (断开 WS, 关闭 PeerConnection)
    → 发送 sub_window_close 到主窗口
```

#### 2.6.6 API 变更

| 变更 | 说明 |
|------|------|
| `buzzing/lib/page/vc/vc_view.dart` | 集成 `MeetingVideoView` + `MeetingControls` |
| `buzzing/lib/page/vc/vc_logic.dart` | 完整实现（复用 `signaling/` 模块） |
| `buzzing/lib/vc.dart` | 从 `args` 解析参数，注入 `VcLogic` |
| `buzzing/lib/controller/app_controller.dart` | `createWindow` 传参增加 host/token/room_id 等 |
| `buzzing/lib/page/meeting/meeting_logic.dart` | `createMeeting()` 补齐参数生成逻辑 |
| `buzzing/lib/page/meeting/meeting_view.dart` | 优化 create 按钮交互 |

### 2.7 Web 端基础入会

#### 2.7.1 功能描述

支持在浏览器中通过 URL `/meeting/:roomId` 加入视频会议。实现 Web 端 Signaling 类、会议页面 UI、基础接通流程。**M1 目标**：Web 端可与 Flutter 客户端 1v1 互通。

#### 2.7.2 架构

```
frontend/
├── src/
│   ├── router/index.ts
│   │   └── 新增路由: /meeting/:roomId → FullscreenLayout → MeetingRoomView
│   │              /meeting             → ModuleLayout → MeetingHomeView (占位)
│   ├── stores/meeting.ts              ← Pinia store
│   ├── services/signaling.ts          ← TypeScript Signaling 类
│   ├── views/meeting/
│   │   ├── MeetingRoomView.vue        ← 会议主页面
│   │   └── components/
│   │       ├── LocalVideo.vue          ← 本地视频（PiP）
│   │       ├── RemoteVideo.vue         ← 远程视频（全屏）
│   │       ├── ControlBar.vue          ← 控制栏
│   │       ├── ParticipantList.vue     ← 参会者列表
│   │       └── DevicePreview.vue       ← 会前设备预览弹窗
│   └── MeetingRoomView.vue
├── vite.config.ts
│   └── 新增 proxy: '/meeting/ws' → ws://localhost:5150
```

#### 2.7.3 Signaling.ts 设计

```typescript
// frontend/src/services/signaling.ts

interface SignalingConfig {
  host: string;
  port: number;
  token: string;
  iceServers: RTCIceServer[];
}

class Signaling {
  private ws: WebSocket | null = null;
  private pc: RTCPeerConnection | null = null;
  private localStream: MediaStream | null = null;
  private remoteStream: MediaStream | null = null;
  private config: SignalingConfig;
  private uid: string;
  private reconnectAttempts: number = 0;
  private keepaliveTimer: number | null = null;

  // 回调
  onLocalStream: ((stream: MediaStream) => void) | null = null;
  onRemoteStream: ((stream: MediaStream) => void) | null = null;
  onConnectionState: ((state: string) => void) | null = null;
  onPeerUpdate: ((peers: any[]) => void) | null = null;
  onCallState: ((state: string) => void) | null = null;

  constructor(config: SignalingConfig);

  async connect(): Promise<void>;
  disconnect(): void;
  async invite(peerId: string, media: string): Promise<void>;
  async accept(sessionId: string, media: string): Promise<void>;
  reject(sessionId: string): void;
  bye(sessionId: string): void;
  muteMic(): void;
  switchCamera(): void;
  async startScreenShare(): Promise<void>;
  stopScreenShare(): void;

  // 内部方法
  private onMessage(data: any): void;
  private createPeerConnection(): RTCPeerConnection;
  private async createOffer(media: string): Promise<void>;
  private async createAnswer(media: string): Promise<void>;
  private send(type: string, data: any): void;
  private reconnect(): void;
  private startKeepalive(): void;
  private collectStats(): void;
}
```

Web 端 `Signaling` 与 Flutter 端 `Signaling` 使用完全相同的 JSON 信令协议，确保互通。

#### 2.7.4 路由与页面

**路由定义（router/index.ts）：**

```typescript
{
  path: '/meeting',
  component: () => import('@/layouts/ModuleLayout.vue'),
  beforeEnter: tenantGuard,
  children: [
    { path: '', name: 'MeetingHome', component: () => import('@/views/meeting/MeetingHomeView.vue') },
  ],
},
{
  path: '/meeting/:roomId',
  component: () => import('@/layouts/FullscreenLayout.vue'),
  beforeEnter: tenantGuard,
  children: [
    { path: '', name: 'MeetingRoom', component: () => import('@/views/meeting/MeetingRoomView.vue') },
  ],
},
```

**MeetingRoomView.vue 布局：**

```
┌──────────────────────────────────────────────┐
│  全屏区域                                      │
│  ┌─────────────────────────────────────┐      │
│  │                                     │      │
│  │  RemoteVideo (fullscreen)           │      │
│  │                                     │      │
│  │  ┌──────────┐                       │      │
│  │  │ LocalVid │  (PiP, 右下角)         │      │
│  │  └──────────┘                       │      │
│  └─────────────────────────────────────┘      │
│                                               │
│  ┌─────────────────────────────────────────┐  │
│  │ ControlBar (浮层)                        │  │
│  │ [静音] [摄像头] [屏幕共享] [参会者] [挂断]  │  │
│  └─────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
```

#### 2.7.5 Pinia Store 设计

```typescript
// frontend/src/stores/meeting.ts

interface MeetingState {
  roomId: string;
  uid: string;
  inCalling: boolean;
  peers: any[];
  networkQuality: 'good' | 'fair' | 'poor';
  isMuted: boolean;
  isVideoOff: boolean;
  isScreenSharing: boolean;
}

export const useMeetingStore = defineStore('meeting', {
  state: (): MeetingState => ({
    roomId: '',
    uid: '',
    inCalling: false,
    peers: [],
    networkQuality: 'good',
    isMuted: false,
    isVideoOff: false,
    isScreenSharing: false,
  }),
  actions: {
    setRoomId(id: string) { ... },
    setPeers(peers: any[]) { ... },
    setCalling(calling: boolean) { ... },
    reset() { ... },
  },
});
```

#### 2.7.6 Vite 配置变更

```typescript
// frontend/vite.config.ts
server: {
  proxy: {
    '/api': { target: 'http://localhost:5150', changeOrigin: true },
    '/meeting/ws': { target: 'ws://localhost:5150', ws: true },
  },
},
```

#### 2.7.7 交互流程

```
用户访问 /meeting/abc123
  → FullscreenLayout 渲染 MeetingRoomView
  → MeetingRoomView onMounted:
      → 从 useAuthStore 获取 token
      → 从 useMeetingStore 初始化 roomId
      → 创建 Signaling({ host, port, token })
      → 弹出 DevicePreview 弹窗（选择摄像头/麦克风）
      → 用户确认后：
          → Signaling.connect()
          → 发送 {"type": "new", "data": {"token": jwt}}
          → 发送 {"type": "join", "data": {"room_id": "abc123"}}
          → 服务端分配 peer list
          → 如果有其他用户，自动 invite/接受
      → 通话中：ControlBar 控制
      → 用户点击挂断 / 标签页关闭：
          → Signaling.bye()
          → 清理 MediaStream, PeerConnection
          → 跳转到 MeetingHome 或关闭标签页
```

#### 2.7.8 来宾入会（无登录）

支持无需登录的来宾模式：

```typescript
// 无 token 时进入来宾模式
if (!authStore.token) {
  // 弹出名称输入框
  const name = await showNameDialog();
  signaling.connectAsGuest(name);
}

// signaling.connectAsGuest 发送:
{"type": "new", "data": {"name": "访客小明", "id": "guest-uuid", "user_agent": "..."}}
// 服务端为来宾分配临时 ID，但不关联真实 user_id
```

来宾模式的限制：
- 不可创建会议，仅可通过链接加入已有会议
- 不可主持、录制
- 聊天中显示"访客"标签

#### 2.7.9 API 变更

| 变更 | 说明 |
|------|------|
| `frontend/src/services/signaling.ts` | **新建** — TypeScript Signaling 类 |
| `frontend/src/stores/meeting.ts` | **新建** — Pinia meeting store |
| `frontend/src/router/index.ts` | 新增 `/meeting/:roomId` 路由 |
| `frontend/src/layouts/FullscreenLayout.vue` | 启用（已有骨架代码） |
| `frontend/src/views/meeting/MeetingRoomView.vue` | **新建** — 会议主页面 |
| `frontend/src/views/meeting/components/DevicePreview.vue` | **新建** — 设备预览弹窗 |
| `frontend/src/views/meeting/components/ControlBar.vue` | **新建** — 控制栏 |
| `frontend/src/views/meeting/components/ParticipantList.vue` | **新建** — 参会者列表 |
| `frontend/src/views/meeting/MeetingHomeView.vue` | **新建** — 会议首页（占位） |
| `frontend/vite.config.ts` | 新增 `/meeting/ws` 代理 |
| `frontend/src/services/api.ts` | 新增 meeting 相关 API 调用 |

---

## 3. 技术实现计划

### 3.1 阶段划分

| 阶段 | 内容 | 工时估算 |
|------|------|----------|
| M1-1 | 信令认证 + TURN 凭证修复 | 3 天 |
| M1-2 | 连接可靠性（ICE restart + WS 重连 + keepalive） | 3 天 |
| M1-3 | 屏幕共享 + 码率自适应 | 4 天 |
| M1-4 | VcWindow 子窗口完整化 | 4 天 |
| M1-5 | Web 端基础入会 | 5 天 |
| M1-6 | 端到端联调 + 自动化测试 | 2 天 |

### 3.2 Proto 变更清单

| 文件 | 变更 |
|------|------|
| `proto/command.proto` | 新增 `MEETING_CREATE=1800`, `MEETING_JOIN=1801` 等枚举（可选，M1 信令仍使用 JSON） |
| `proto/meeting.proto` | **新建** — 定义 Meeting, MeetingParticipant 等消息（可选，M1 先不强制使用） |

**注意**：M1 信令保持 JSON WebSocket 协议，不强制使用 Proto 编码。Proto 命令定义在 M2 开始使用。

### 3.3 后端变更清单

| 文件 | 变更 |
|------|------|
| `backend/rtc/src/signaling.rs` | `New` 消息增加 token 验证；`PeerInfo` 增加 `user_id`/`tenant_id` |
| `backend/rtc/src/turn.rs` | `RtcAuthHandler.auth_handle` 实现 HMAC 验证 |
| `backend/rtc/src/lib.rs` | `/api/turn` 凭证签发端点；废除冗余 `/meeting` 端点 |
| `backend/rtc/Cargo.toml` | 新增 `hmac`, `sha2`, `base64` 依赖 |
| `backend/common/` | 若需要 token 解码函数，暴露公共方法 |

### 3.4 Flutter 变更清单

| 文件 | 变更 |
|------|------|
| `signaling.dart` | `connect()` 传入 token；`getTurnCredential()` 传 token；重连逻辑；keepalive；ICE restart；码率自适应 |
| `signaling.dart` | `switchToScreenSharing()` 补齐；`createStream()` 加入 AEC/NS/AGC 约束 |
| `meeting_logic.dart` | 从 `loginUser` 获取 uid/token；`createMeeting()` 补齐参数；`joinMeeting()` 补齐 |
| `meeting_view.dart` | 优化创建/加入交互 |
| `meeting_video_view.dart` | 网络质量指示器 |
| `meeting_controls.dart` | 屏幕共享按钮交互 |
| `vc_view.dart` | 集成 MeetingVideoView + MeetingControls |
| `vc_logic.dart` | 完整实现（复用 signaling/ 模块） |
| `vc.dart` | 从 args 解析参数注入 |
| `app_controller.dart` | createWindow 传参增强（host/token/room_id） |

### 3.5 Web 前端变更清单

| 文件 | 变更 |
|------|------|
| `frontend/src/services/signaling.ts` | **新建** — TypeScript Signaling 类 |
| `frontend/src/stores/meeting.ts` | **新建** — Pinia meeting store |
| `frontend/src/router/index.ts` | 新增 `/meeting/:roomId`, `/meeting` 路由 |
| `frontend/src/views/meeting/MeetingRoomView.vue` | **新建** |
| `frontend/src/views/meeting/MeetingHomeView.vue` | **新建** |
| `frontend/src/views/meeting/components/DevicePreview.vue` | **新建** |
| `frontend/src/views/meeting/components/ControlBar.vue` | **新建** |
| `frontend/src/views/meeting/components/ParticipantList.vue` | **新建** |
| `frontend/vite.config.ts` | 新增 `/meeting/ws` 代理 |
| `frontend/src/styles/meeting.css` | **新建** — 会议页面样式 |

### 3.6 配置项

```toml
# backend/config/
[rtc.signal]
port = 5150
tls_cert = "configs/certs/cert.pem"
tls_key = "configs/certs/key.pem"

[rtc.turn]
port = 19302
public_ip = "127.0.0.1"
realm = "flutter-webrtc"
secret_key = "your-hmac-secret-key-here"
credential_ttl_sec = 3600

[rtc.keepalive]
interval_sec = 3
timeout_sec = 5

[rtc.reconnect]
initial_delay_sec = 1
max_delay_sec = 16

[rtc.stats]
collect_interval_sec = 5
```

---

## 4. 非功能需求

### 4.1 性能

| 指标 | 目标 |
|------|------|
| 信令连接建立 | < 500ms（含 token 验证） |
| ICE 连接建立 | < 3s（同一内网），< 8s（跨 NAT） |
| WebSocket 重连 | < 1s（直接重连），< 16s（最大退避） |
| 码率调整响应 | < 5s（检测到网络变化后） |
| 视频编码码率范围 | 200kbps ~ 2500kbps |
| 统计采集开销 | < 50ms/次 |

### 4.2 安全

| 项目 | 要求 |
|------|------|
| 信令连接 | 必须携带有效 JWT token，拒绝未认证连接 |
| TURN 凭证 | HMAC 签名，1h 有效期，防止盗用 |
| 传输层 | TLS 1.3（WSS/HTTPS） |
| 媒体流 | DTLS-SRTP 加密（WebRTC 内置） |
| 来宾限制 | 来宾不可创建会议、不可录制、不可主持 |

### 4.3 兼容性

- Flutter 屏幕共享：Windows + macOS 桌面端（Linux 暂不支持）
- Web 端屏幕共享：Chrome 89+, Edge 89+, Firefox 75+, Safari 16+（getDisplayMedia 支持）
- Web 端 WebRTC：Chrome 70+, Firefox 60+, Safari 14+, Edge 79+
- Web 端需处理 Safari 不支持 `RTCRtpSender.setParameters()` 的降级

### 4.4 可靠性

- WS 重连无限次尝试，保持重连状态不丢失
- ICE restart 不中断已有音视频流（DTLS 会话复用）
- 子窗口崩溃后主窗口可检测并清理（tick 超时 2s 判定死亡）

---

## 5. 附录

### 5.1 信令协议参考

#### 客户端 → 服务端

| 类型 | 方向 | 说明 |
|------|------|------|
| `new` | C→S | 注册（携带 token），替换旧版的 id/name/user_agent |
| `join` | C→S | 加入房间（M2 启用，M1 暂用 P2P invite） |
| `bye` | C→S | 结束会话 |
| `offer` | C→S | SDP offer，转发给对端 |
| `answer` | C→S | SDP answer，转发给对端 |
| `candidate` | C→S | ICE candidate，转发给对端 |
| `keepalive` | C→S | 保活心跳 |

#### 服务端 → 客户端

| 类型 | 方向 | 说明 |
|------|------|------|
| `peers` | S→C | 在线用户列表广播 |
| `leave` | S→C | 有用户离开 |
| `bye` | S→C | 转发 bye |
| `offer/answer/candidate` | S→C | 转发信令 |
| `error` | S→C | 错误（如 token 无效） |
| `keepalive` | S→C | 心跳回显 |

### 5.2 HMAC 凭证生成参考

```rust
// 后端: TURN 凭证签发
use hmac::{Hmac, Mac};
use sha2::Sha256;
use base64::Engine;

type HmacSha256 = Hmac<Sha256>;

fn generate_turn_credential(
    secret: &str,
    user_id: i64,
    ttl: u32,
) -> (String, String) {
    let timestamp = chrono::Utc::now().timestamp() + ttl as i64;
    let username = format!("{}:{}", timestamp, user_id);
    
    let mut mac = HmacSha256::new_from_slice(secret.as_bytes())
        .expect("HMAC key");
    mac.update(username.as_bytes());
    let result = mac.finalize();
    let credential = base64::engine::general_purpose::STANDARD
        .encode(result.into_bytes());
    
    (username, credential)
}
```

### 5.3 Web 端 ICE restart 参考

```typescript
// frontend/src/services/signaling.ts — ICE restart
async function restartIce(): Promise<void> {
  if (!this.pc) return;
  const offer = await this.pc.createOffer({ iceRestart: true });
  await this.pc.setLocalDescription(offer);
  this.send('offer', {
    to: this.peerId,
    from: this.uid,
    description: { sdp: offer.sdp, type: offer.type },
    session_id: this.sessionId,
    media: 'video',
  });
}
```

### 5.4 测试策略

| 测试项 | 方法 | 覆盖 |
|--------|------|------|
| 信令认证 | 无 token 连接 → 应被拒绝；伪造 token → 应被拒绝 | `backend_test` |
| TURN 联通 | 跨 NAT 设备 P2P 连接建立成功率 > 90% | 手动测试 |
| ICE restart | 网络切换后音视频不中断 > 30s | 手动测试 |
| WS 重连 | kill WS 连接后自动恢复 < 16s | `backend_test` |
| 屏幕共享 | 共享窗口/全屏后远端正确渲染 | 手动测试 |
| 码率自适应 | 模拟丢包(rtt)后码率正确下降 | 手动测试 |
| VcWindow | 子窗口打开/视频渲染/挂断/关闭 | `buzzing/sdk_test` |
| Web ↔ Flutter 互通 | Web 端与 Flutter 端建立 1v1 通话 | 手动测试 |

---

## 6. 实施步骤

### 6.1 执行顺序与依赖关系

```
M1-1 ────────────────────────────────────────┐
  ├── 1.1: signaling.rs token 校验            │
  └── 1.2: turn.rs HMAC + /api/turn 凭证签发   │
                                              ├── 所有客户端依赖 TURN 和认证
M1-2 ────────────────────────────────────────┤
  ├── 2.1: Flutter 重连 + keepalive           │
  └── 2.2: Flutter ICE restart                 │
                                              │
M1-3 ────────────────────────────────────────┤
  ├── 3.1: Flutter 屏幕共享实现               │
  └── 3.2: Flutter 码率自适应 + stats 采集     │
                                              │
M1-4 ────────────────────────────────────────┤
  ├── 4.1: vc_logic 完整信令逻辑               │
  ├── 4.2: vc_view 集成 MeetingVideoView       │
  ├── 4.3: MeetingControls 集成               │
  └── 4.4: app_controller 传参增强             │  ← 依赖 M1-1（token/TURN）
                                              │
M1-5 ────────────────────────────────────────┤
  ├── 5.1: signaling.ts（TS 版）              │  ← 依赖 M1-1（信令协议统一）
  ├── 5.2: store + 路由 + 页面                │
  ├── 5.3: DevicePreview + ControlBar          │
  └── 5.4: 来宾入会                           │
                                              │
M1-6 ────────────────────────────────────────┘
  ├── 6.1: Vite proxy 配置生效 + 端到端联调
  ├── 6.2: 自动化测试（backend_test + buzzing/sdk_test）
  └── 6.3: 回归测试（Flutter 1v1、Web ↔ Flutter 互通）
```

**核心依赖规则：**
- M1-1（后端认证+TURN）是所有客户端工作的前置依赖
- M1-2（连接可靠性）与 M1-1 无代码依赖，可并行开发
- M1-3（屏幕共享+码率）依赖 M1-1 的信令环境
- M1-4（VcWindow）依赖 M1-1 + M1-2 + M1-3 的全部能力
- M1-5（Web 端）信令协议在 M1-1 确定后即可独立开发

### 6.2 详细步骤

#### 步骤 M1-1.1：信令认证（后端）

| 序号 | 操作 | 文件 | 验收标准 |
|------|------|------|----------|
| 1.1.1 | 在 `signaling.rs` 的 `PeerInfo` 中增加 `user_id: i64` 和 `tenant_id: i64` 字段 | `backend/rtc/src/signaling.rs` | 编译通过 |
| 1.1.2 | 在 `New` 消息处理中解析 token：从 `data.token` 读取 JWT，调用项目现有 token 验证函数解码 | `backend/rtc/src/signaling.rs` | token 有效时返回 peers 列表，无效时返回 error+断开连接 |
| 1.1.3 | 提取 `user_id`/`tenant_id` 填充到 `PeerInfo` | `backend/rtc/src/signaling.rs` | 注册后 peers 广播中包含正确的 user_id |
| 1.1.4 | 验证不通过时：返回 `{"type":"error","data":{"reason":"invalid token"}}` 并关闭 WS | `backend/rtc/src/signaling.rs` | 客户端收到 error 类型消息 |
| 1.1.5 | 单元测试：无 token 连接、伪造 token、过期 token 三种场景 | `backend/rtc/src/signaling.rs` | 测试覆盖三种拒绝场景 |
| 1.1.6 | 集成测试：后端启动后用 wscat 手动验证连接 | 命令行 | `wscat -c wss://host/ws` 发送 new 消息应被拒绝 |

**预计工时**：1.5 天

#### 步骤 M1-1.2：TURN 凭证签发 + 验证（后端）

| 序号 | 操作 | 文件 | 验收标准 |
|------|------|------|----------|
| 1.2.1 | 在 `Cargo.toml` 中添加 `hmac`, `sha2`, `base64` 依赖 | `backend/rtc/Cargo.toml` | `cargo build` 通过 |
| 1.2.2 | 在 `turn.rs` 中实现 `RtcAuthHandler.auth_handle`：解析 `username` 中的 timestamp，检查是否过期，用共享密钥验证 HMAC | `backend/rtc/src/turn.rs` | 合法凭证返回 Ok(pw)，非法返回 `ErrFakeErr` |
| 1.2.3 | 读取 secret_key 配置（如不支持配置则先用硬编码常量 `SHARE_KEY`） | `backend/rtc/src/turn.rs` | TURN 启动时读取配置 |
| 1.2.4 | 在 `lib.rs` 中实现 `/api/turn?token={jwt}`：验证 token → 取 user_id → 生成 username+credential → 返回 JSON | `backend/rtc/src/lib.rs` | `curl /api/turn?token=xxx` 返回含 uris/username/password/ttl 的 JSON |
| 1.2.5 | 删除冗余的旧 `/meeting` 端点（`ws_handler` + `handle_socket`） | `backend/rtc/src/lib.rs` | 路由只剩 `/ws` 和 `/api/turn` |
| 1.2.6 | 集成测试：curl TURN 凭证 API 验证格式正确，TURN 服务可用 | 命令行 | TURN 端口 19302 可响应分配请求 |

**预计工时**：1.5 天

#### 步骤 M1-2.1：WebSocket 重连 + keepalive（Flutter）

| 序号 | 操作 | 文件 | 验收标准 |
|------|------|------|----------|
| 2.1.1 | `Signaling` 类新增 `_reconnectAttempts` 和 `_reconnectTimer` 状态 | `signaling.dart` | |
| 2.1.2 | 实现 `_reconnect()` 方法：指数退避（1s→2s→4s→8s→16s 上限），连接成功后重置计数器 | `signaling.dart` | 断线后 16s 内恢复连接 |
| 2.1.3 | 在 `onClose` 回调中触发重连流程 | `signaling.dart` | WS 关闭后自动启动重连 |
| 2.1.4 | 重连成功后自动 re-send `new` 消息重新注册 | `signaling.dart` | 重连后服务端 peers 列表恢复 |
| 2.1.5 | 新增 `_keepaliveTimer`：每 3 秒发送 `keepalive` 消息 | `signaling.dart` | keepalive 消息周期发送 |
| 2.1.6 | 新增 `_keepaliveTimeout`：5 秒未收到回显则判定断开，触发重连 | `signaling.dart` | 无响应 5s 后自动重连 |
| 2.1.7 | 提取 `connect()` 为可重入方法，重连时复用已有 config | `signaling.dart` | 多次调用 connect 不冲突 |
| 2.1.8 | `MeetingLogic` 增加 `onReconnect` 回调，通知 UI 恢复状态 | `meeting_logic.dart` | UI 显示"重新连接成功"提示 |

**预计工时**：1.5 天

#### 步骤 M1-2.2：ICE restart（Flutter）

| 序号 | 操作 | 文件 | 验收标准 |
|------|------|------|----------|
| 2.2.1 | 修改 `createOffer` 添加可选 `iceRestart` 参数 | `signaling.dart` | `createOffer({iceRestart: true})` 生成带 ICE restart 的 offer |
| 2.2.2 | 重连成功后检测是否存在活跃的 session，如存在则调用 `pc.createOffer({iceRestart: true})` 并发送新 offer | `signaling.dart` | 重连后 ICE 连接恢复，音视频不中断 |
| 2.2.3 | 通过平台 API 监听网络状态变更（WiFi↔蜂窝等），触发 ICE restart | `meeting_logic.dart` | 网络切换后 ICE 自动重新协商 |
| 2.2.4 | 验证 ICE restart 后 DTLS 会话复用，音视频流不中断 | 手动测试 | 断网再恢复后通话持续 > 30s |

**预计工时**：1.5 天

#### 步骤 M1-3.1：屏幕共享（Flutter + Web）

| 序号 | 操作 | 文件 | 验收标准 |
|------|------|------|----------|
| 3.1.1 | 在 `Signaling` 中补齐 `switchToScreenSharing(stream)`：使用 `getDisplayMedia()` 获取屏幕流，`replaceTrack` 替换当前视频 track | `signaling.dart` | 屏幕流成功替换摄像头流 |
| 3.1.2 | `createStream` 加入音频约束：`echoCancellation: true`、`noiseSuppression: true`、`autoGainControl: true` | `signaling.dart` | 音频质量提升 |
| 3.1.3 | `MeetingLogic` 实现 `_selectScreenSource()`：调用 `getDisplayMedia` 并传递结果到 signaling | `meeting_logic.dart` | 弹出系统窗口选择器 |
| 3.1.4 | `MeetingControls` 屏幕共享按钮增加状态（共享中/未共享），停止共享时恢复摄像头流 | `meeting_controls.dart` | 按钮图标和文字随状态切换 |
| 3.1.5 | Web `Signaling.ts` 实现 `startScreenShare()`：`navigator.mediaDevices.getDisplayMedia()` + `replaceTrack` | `signaling.ts` | 浏览器弹出窗口选择器 |
| 3.1.6 | Web `ControlBar.vue` 屏幕共享按钮 | `ControlBar.vue` | 按钮交互正确 |

**预计工时**：2 天

#### 步骤 M1-3.2：码率自适应（Flutter + Web）

| 序号 | 操作 | 文件 | 验收标准 |
|------|------|------|----------|
| 3.2.1 | 在 `Signaling` 中实现 `pc.onIceConnectionState` 监听 | `signaling.dart` | ICE 状态变化时打印日志 |
| 3.2.2 | 新增 `_statsTimer`：每 5s 调用 `pc.getStats()` 获取 `RTCStatsReport`，提取 RTT/packetsLost/jitter/bitrate | `signaling.dart` | 控制台输出 stats 数据 |
| 3.2.3 | 实现 `_adjustBitrate()`：根据 stats 判断网络等级，调用 `RTCRtpSender.setParameters()` 调整 `maxBitrate` | `signaling.dart` | 码率随网络状况变化 |
| 3.2.4 | 实现降级策略：5 秒持续差→降一级，10 秒持续好→升一级 | `signaling.dart` | 降级/升级不频繁抖动 |
| 3.2.5 | `MeetingVideoView` 增加网络质量图标（圆点绿/黄/红） | `meeting_video_view.dart` | UI 显示当前质量等级 |
| 3.2.6 | `MeetingLogic` 新增 `networkQuality` 状态暴露给 UI | `meeting_logic.dart` | |
| 3.2.7 | Web `Signaling.ts` 同 3.2.1~3.2.4 实现 | `signaling.ts` | Web 端码率自适应生效 |
| 3.2.8 | Web `MeetingRoomView.vue` 显示网络质量指示器 | `MeetingRoomView.vue` | |

**预计工时**：2 天

#### 步骤 M1-4.1：VcWindow 子窗口信令逻辑

| 序号 | 操作 | 文件 | 验收标准 |
|------|------|------|----------|
| 4.1.1 | `VcLogic` 继承 `ChangeNotifier`，新增 `Signaling`, `localRenderer`, `remoteRenderer`, `inCalling`, `networkQuality` 等状态 | `vc_logic.dart` | |
| 4.1.2 | `VcLogic.init()` 完成渲染器初始化 + 创建 `Signaling` 实例（从传入的 token/turnCredential 配置） | `vc_logic.dart` | 渲染器 init 成功 |
| 4.1.3 | `VcLogic.connect()` 调用 `Signaling.connect(host, port)`，连接成功后发送 `join` 消息 | `vc_logic.dart` | 信令连接成功 |
| 4.1.4 | 实现 `invite()`, `hangUp()`, `muteMic()`, `switchCamera()`, `switchToScreenSharing()` 方法映射到 Signaling | `vc_logic.dart` | 所有控制方法工作正常 |
| 4.1.5 | 处理 `onCallStateChange` 回调：CallStateConnected→`inCalling=true`, CallStateBye→挂断处理 | `vc_logic.dart` | 呼叫状态正确切换 |

**预计工时**：1.5 天

#### 步骤 M1-4.2：VcWindow 子窗口 UI + 主窗口传参

| 序号 | 操作 | 文件 | 验收标准 |
|------|------|------|----------|
| 4.2.1 | `vc_view.dart` 引入 `MeetingVideoView` 和 `MeetingControls`，替换占位 UI | `vc_view.dart` | 子窗口显示视频视图 |
| 4.2.2 | 子窗口 `MeetingVideoView` 布局：remote 全屏 + local PiP（右下角 200x150） | `vc_view.dart` | 视频渲染正确 |
| 4.2.3 | `MeetingControls` 挂载：静音/摄像头/屏幕共享/挂断按钮 | `vc_view.dart` | 按钮交互正常 |
| 4.2.4 | `vc.dart` 从 `args` 解析 `host/token/turn_credential/room_id/peer_id/media`，创建 `VcLogic` 并注入 | `vc.dart` | 参数正确传递到 VcLogic |
| 4.2.5 | `app_controller.dart` 的 `createWindow("VcWindow", args)` 参数增强，调用前先获取 TURN 凭证 | `app_controller.dart` | args 包含完整参数 |
| 4.2.6 | `meeting_logic.dart` 的 `createMeeting()` 补齐：生成 UUID room_id，获取 TURN credential，调用 createWindow | `meeting_logic.dart` | 点击「创建会议」成功打开子窗口 |
| 4.2.7 | 生命周期通信：子窗口 `dispose` 时发 `sub_window_close`，主窗口处理清理注册 | `vc_view.dart` + `app_controller.dart` | 子窗口关闭后主窗口正确清理 |

**预计工时**：2.5 天

#### 步骤 M1-5.1：Web 端 Signaling.ts + MeetingRoomView

| 序号 | 操作 | 文件 | 验收标准 |
|------|------|------|----------|
| 5.1.1 | 在 `frontend/src/services/` 下新建 `signaling.ts`，实现完整的 TS Signaling 类（connect/disconnect/invite/accept/reject/bye/keepalive/reconnect/send/onMessage） | `signaling.ts` | 与 Flutter Signaling 协议一致，可互通 |
| 5.1.2 | 实现 Web 端 ICE restart（`createOffer({iceRestart: true})`） | `signaling.ts` | 网络切换后 ICE 重协商 |
| 5.1.3 | 实现 Web 端码率自适应（`RTCRtpSender.setParameters()` 调整 maxBitrate） | `signaling.ts` | 码率动态调整 |
| 5.1.4 | 在 `frontend/src/stores/` 下新建 `meeting.ts`（Pinia store） | `meeting.ts` | store 状态正确 |
| 5.1.5 | 路由注册：`/meeting/:roomId` → `FullscreenLayout` + `MeetingRoomView` | `router/index.ts` | 访问路由可正确渲染 |
| 5.1.6 | `FullscreenLayout.vue` 启用（去除 TODO/条件判断，设为 100vh 全屏） | `FullscreenLayout.vue` | 全屏显示无顶部条 |
| 5.1.7 | `MeetingRoomView.vue` 骨架：建立 onMounted 生命周期，获取 token，创建 Signaling，弹出 DevicePreview | `MeetingRoomView.vue` | 进入页面弹出设备选择 |
| 5.1.8 | 添加 `/meeting/ws` 到 Vite proxy | `vite.config.ts` | WS 连接正常 proxied |

**预计工时**：2.5 天

#### 步骤 M1-5.2：Web 端组件 + 来宾入会

| 序号 | 操作 | 文件 | 验收标准 |
|------|------|------|----------|
| 5.2.1 | `DevicePreview.vue`：列举 `navigator.mediaDevices.enumerateDevices()`，用户选择摄像头/麦克风，点击确认后调用 `getUserMedia` | `DevicePreview.vue` | 设备选择生效 |
| 5.2.2 | `ControlBar.vue`：静音/摄像头/屏幕共享/挂断按钮，绑定 Signaling 方法 | `ControlBar.vue` | 所有按钮工作 |
| 5.2.3 | `ParticipantList.vue`：显示当前 peers 列表（名称 + 视频状态图标） | `ParticipantList.vue` | 列表与 store 同步 |
| 5.2.4 | `MeetingRoomView.vue` 完整集成：RemoteVideo（`<video>` autoplay）+ LocalVideo（PiP 右下角）+ ControlBar + ParticipantList | `MeetingRoomView.vue` | 完整会议 UI |
| 5.2.5 | 来宾入会：无 token 时弹出名称输入框，调用 `connectAsGuest(name)` | `MeetingRoomView.vue` | 来宾可输入名称入会 |
| 5.2.6 | 断线重连 + keepalive（Signaling.ts 中实现） | `signaling.ts` | 断线后自动重连 |

**预计工时**：2.5 天

#### 步骤 M1-6：联调 + 测试

| 序号 | 操作 | 文件 | 验收标准 |
|------|------|------|----------|
| 6.1 | Vite proxy 配置 `/meeting/ws` → `ws://localhost:5150` 确认生效 | `vite.config.ts` | 浏览器 WS 连接成功 |
| 6.2 | Flutter 1v1 端到端测试：双设备登录 → 建立信令 → 视频通话 → 挂断 | 手动 | 通话3分钟无断流 |
| 6.3 | Web ↔ Flutter 互通测试：浏览器访问 `/meeting/:roomId` → Flutter 呼入 → 音视频双向正常 | 手动 | 画面+声音双向正常 |
| 6.4 | 屏幕共享端到端测试：Flutter 端共享屏幕 → Web 端看到屏幕内容 | 手动 | 屏幕内容正确渲染 |
| 6.5 | 认证拒绝测试：非法 token 连接 WS → 应被拒绝 | `backend_test` | 测试通过 |
| 6.6 | WS 重连测试：kill WS 进程 → 客户端自动重连 < 16s | `backend_test` | 测试通过 |
| 6.7 | VcWindow 测试：创建会议 → 子窗口打开 → 控制栏操作 → 挂断 → 窗口关闭 | `buzzing/sdk_test` | 测试用例通过 |
| 6.8 | 回归测试：现有项目功能不受影响（login/chat/calendar/office） | `just test` | 全部通过 |

**预计工时**：2 天

---

## 7. 跟踪

### 7.1 进度跟踪表

| 步骤 | 内容 | 负责人 | 预估工时 | 状态 | 开始日 | 完成日 | 备注 |
|------|------|--------|----------|------|--------|--------|------|
| 1.1.1~1.1.4 | signaling.rs token 校验 | | 1.5d | ⬜ | | | |
| 1.2.1~1.2.5 | turn.rs HMAC + /api/turn 签发 | | 1.5d | ⬜ | | | |
| 2.1.1~2.1.8 | Flutter WS 重连 + keepalive | | 1.5d | ⬜ | | | |
| 2.2.1~2.2.4 | Flutter ICE restart | | 1.5d | ⬜ | | | |
| 3.1.1~3.1.6 | 屏幕共享（Flutter + Web） | | 2d | ⬜ | | | |
| 3.2.1~3.2.8 | 码率自适应（Flutter + Web） | | 2d | ⬜ | | | |
| 4.1.1~4.1.5 | VcLogic 信令逻辑 | | 1.5d | ⬜ | | | |
| 4.2.1~4.2.7 | VcWindow UI + 主窗口传参 | | 2.5d | ⬜ | | | |
| 5.1.1~5.1.8 | Web Signaling.ts + 路由 + 页面骨架 | | 2.5d | ⬜ | | | |
| 5.2.1~5.2.6 | Web 组件 + 来宾入会 | | 2.5d | ⬜ | | | |
| 6.1~6.8 | 联调 + 测试 | | 2d | ⬜ | | | |

### 7.2 状态图例

| 符号 | 含义 |
|------|------|
| ⬜ | 未开始 |
| 🔄 | 进行中 |
| ✅ | 已完成 |
| ❌ | 阻塞/有问题 |

### 7.3 每周同步检查项

- [ ] 信令认证是否已上线？是否存在 token 泄露风险？
- [ ] TURN 凭证是否已生效？跨 NAT 通话成功率？
- [ ] 重连机制是否稳定？有无异常重连循环？
- [ ] 屏幕共享是否存在性能问题（帧率、CPU）？
- [ ] 码率自适应是否过度敏感导致频繁升降？
- [ ] VcWindow 子窗口是否有内存泄漏（渲染器未释放）？
- [ ] Web 端与 Flutter 端信令协议是否完全一致？
- [ ] 测试覆盖率是否达到预期？

### 7.4 退出标准（M1 Done Definition）

- [ ] 信令连接必须携带有效 token，非法 token 100% 拒绝
- [ ] TURN 凭证签发 API 可用，TURN 转发成功率 > 90%
- [ ] WS 断线后自动重连，ICE restart 不中断通话
- [ ] 屏幕共享可用（全屏+窗口），远端正常渲染
- [ ] 码率根据网络状况自动调整，降级不频繁（> 10s 间隔）
- [ ] VcWindow 子窗口完整操作：创建/渲染/控制/挂断/关闭
- [ ] Web 端可创建和加入会议，与 Flutter 客户端互通
- [ ] 自动化测试覆盖认证/重连/子窗口核心场景
- [ ] 无 P0/P1 级别的稳定性问题
