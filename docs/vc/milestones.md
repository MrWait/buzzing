# 视频会议（VC）里程碑计划

> 分 6 个里程碑，从当前 demo 逐步演进到生产级水平。
> 每个里程碑均交付可测试的增量价值，避免"大爆炸"式重构。

---

## 总览

```
M1 ─→ M2 ─→ M3 ─→ M4 ─→ M5 ─→ M6
2-3周   3-4周   4-6周   4-6周   6-8周   持续
基础     多人     会议     录制      SFU     企业
加固     Mesh    管理     转录      升级     功能
```

---

## 里程碑 M1：基础加固（2-3 周）

**目标**：修复当前 demo 中影响基本可用性的所有阻塞问题，使 1v1 通话达到可用水平。

### 需求覆盖

| 需求 ID | 说明 |
|---------|------|
| 2.3.7 | STUN/TURN 穿透 |
| 7.1.1 | 信令认证 |
| 7.1.2 | TURN 凭证认证 |
| 7.1.3 | 传输加密 |
| 2.3.1 | ICE restart |
| 2.3.2 | WebSocket 重连 |
| 3.1.1 | 屏幕共享（整屏+窗口） |
| 2.3.3 | 码率自适应 |
| 2.3.5 | 网络质量指示器 |
| 11.1 | VcWindow 完整化 |
| 11.2 | 主窗口↔子窗口同步 |
| 11.3 | 子窗口独立信令 |
| 11.4 | 子窗口控制栏 |

### 任务分解

#### 1.1 信令认证 + TURN 凭证修复

| 任务 | 文件 | 估算 |
|------|------|------|
| 后端 signaling.rs 增加 token 验证 | `backend/rtc/src/signaling.rs` | 2d |
| 后端 turn.rs 实现 HMAC 凭证验证 | `backend/rtc/src/turn.rs` | 1d |
| 后端 `/api/turn` 端点签发凭证 | `backend/rtc/src/lib.rs` | 1d |
| 客户端 Signaling 连接时传入 token | `signaling.dart` | 1d |
| 客户端 getTurnCredential 实现 | `signaling.dart` | 1d |
| 废除冗余 `/meeting` 端点 | `backend/rtc/src/lib.rs` | 0.5d |

#### 1.2 连接可靠性

| 任务 | 文件 | 估算 |
|------|------|------|
| ICE restart 网络切换触发 | `signaling.dart` | 2d |
| WebSocket 指数退避重连 | `signaling.dart` | 2d |
| Keepalive 超时检测 | `signaling.dart` | 1d |
| 重连后 peer list 恢复 | `meeting_logic.dart` | 1d |

#### 1.3 屏幕共享

| 任务 | 文件 | 估算 |
|------|------|------|
| `getDisplayMedia()` 桌面获取 | `signaling.dart` | 1d |
| track 替换逻辑补齐 | `signaling.dart` | 1d |
| source 选择对话框 | `meeting_logic.dart` | 1d |
| UI 交互按钮 | `meeting_controls.dart` | 0.5d |

#### 1.4 码率自适应

| 任务 | 文件 | 估算 |
|------|------|------|
| ICE 连接状态监听 | `signaling.dart` | 1d |
| RTCStatsReport 定时采集 | `signaling.dart` | 1d |
| 动态调整 maxBitrate | `signaling.dart` | 1d |
| 降级策略（1080p→720p→480p→audio） | `signaling.dart` | 1d |
| 网络质量图标 UI | `meeting_video_view.dart` | 1d |

#### 1.5 VcWindow 子窗口完整化

| 任务 | 文件 | 估算 |
|------|------|------|
| vc_view.dart 集成 MeetingVideoView | `vc_view.dart` | 2d |
| vc_logic.dart 完整信令逻辑 | `vc_logic.dart` | 2d |
| 子窗口独立 Signaling 连接 | `vc_logic.dart` | 1d |
| 子窗口 MeetingControls | `vc_view.dart` | 1d |
| 主窗口 createWindow 传参增强 | `app_controller.dart` | 1d |
| 生命周期事件通信（close/tick/end） | `app_controller.dart` | 1d |

#### 1.6 Web 端基础入会

| 任务 | 文件 | 估算 |
|------|------|------|
| TypeScript Signaling 类（信令连接+ICE 交换） | `frontend/src/services/signaling.ts` | 3d |
| meeting Pinia store | `frontend/src/stores/meeting.ts` | 2d |
| 会议页面路由 `/meeting/:roomId` | `frontend/src/router/index.ts` | 0.5d |
| MeetingRoomView 组件（video 标签渲染 + 控制栏） | `frontend/src/views/meeting/MeetingRoomView.vue` | 3d |
| 会前设备预览弹窗 | `frontend/src/views/meeting/components/DevicePreview.vue` | 1d |
| 参会者列表组件 | `frontend/src/views/meeting/components/ParticipantList.vue` | 1d |
| Vite 代理 `/meeting/ws` 到信令服务器 | `frontend/vite.config.ts` | 0.5d |
| 浏览器屏幕共享（getDisplayMedia） | `frontend/src/services/signaling.ts` | 1d |
| 来宾入会（输入昵称，无 token 模式） | `frontend/src/views/meeting/MeetingRoomView.vue` | 1d |
| 断线重连 + ICE restart（浏览器） | `frontend/src/services/signaling.ts` | 2d |

### 交付物

- [ ] 1v1 视频通话可成功穿越 NAT
- [ ] 网络切换时通话不中断（ICE restart + WS 重连）
- [ ] 屏幕共享可用（整屏+窗口）
- [ ] 弱网自动降级、信号质量显示
- [ ] 子窗口完整 WebRTC 视图 + 控制栏
- [ ] 所有连接使用登录 token 验证
- [ ] Web 端可通过 `/meeting/:roomId` 入会，与 Flutter 客户端互通

---

## 里程碑 M2：Mesh 多人通话（3-4 周）

**目标**：实现 ≤4 人 Mesh P2P 会议，包括房间模型、多 PeerConnection 管理、会中聊天。

### 需求覆盖

| 需求 ID | 说明 |
|---------|------|
| 6.2 | Mesh P2P（≤4 人） |
| 2.1.10 | 多路视频同时渲染 |
| 4.1.1 | 公开聊天 |
| 1.2.1 | 主持人角色 |
| 2.2 | 音频全面优化 |
| 10 | Proto 命令 1800~1812 |

### 任务分解

#### 2.1 房间模型（服务端）

| 任务 | 文件 | 估算 |
|------|------|------|
| 服务端 Room 数据结构 | `signaling.rs` | 1d |
| join/leave 房间消息处理 | `signaling.rs` | 2d |
| 广播 offer/answer/candidate 给房间内 | `signaling.rs` | 1d |
| 房间内 peer list 推送 | `signaling.rs` | 1d |

#### 2.2 多 PeerConnection 管理（客户端）

| 任务 | 文件 | 估算 |
|------|------|------|
| Signaling 改为 join(roomId) 模型 | `signaling.dart` | 2d |
| Map<peerId, Session> 多 session 管理 | `signaling.dart` | 2d |
| 新入会者触发已有成员建连 | `signaling.dart` | 2d |
| 离开/断连清理 | `signaling.dart` | 1d |

#### 2.3 多路视频渲染

| 任务 | 文件 | 估算 |
|------|------|------|
| 远程视频由 1 路扩展为 N 路 | `meeting_video_view.dart` | 2d |
| 宫格布局 | `meeting_video_view.dart` | 2d |
| 演讲者视图 | `meeting_video_view.dart` | 1d |
| 本地 PiP 小窗 | `meeting_video_view.dart` | 1d |

#### 2.4 会中聊天

| 任务 | 文件 | 估算 |
|------|------|------|
| RTCDataChannel 文本协议 | `signaling.dart` | 1d |
| 聊天 overlay UI | `meeting_video_view.dart` | 2d |
| 消息列表 + 发送框 | `meeting_video_view.dart` | 1d |

#### 2.5 音视频设备管理

| 任务 | 文件 | 估算 |
|------|------|------|
| 枚举设备 + 切换 | `meeting_logic.dart` | 1d |
| replaceTrack 实现 | `signaling.dart` | 1d |
| 音频约束（AEC/NS/AGC） | `signaling.dart` | 0.5d |

#### 2.6 Proto + 命令定义

| 任务 | 文件 | 估算 |
|------|------|------|
| 新增 `meeting.proto` 消息定义 | `proto/meeting.proto` | 1d |
| 新增命令枚举 1800~1812 | `proto/command.proto` | 0.5d |
| 后端 AppRtc 注册命令处理 | `backend/rtc/src/lib.rs` | 1d |

#### 2.7 Web 端多人会议

| 任务 | 文件 | 估算 |
|------|------|------|
| Web Signaling 多 session 管理 | `frontend/src/services/signaling.ts` | 2d |
| Web 端多路 `<video>` 渲染（宫格/演讲者布局） | `frontend/src/views/meeting/MeetingRoomView.vue` | 2d |
| Web 端 RTCDataChannel 聊天 | `frontend/src/services/signaling.ts` + 组件 | 2d |
| Web 端音频约束 + 设备切换 | `frontend/src/services/signaling.ts` | 1d |

### 交付物

- [ ] ≤4 人 Mesh 会议可用
- [ ] 多路视频宫格/演讲者布局
- [ ] 会中文字聊天
- [ ] 主持人角色（创建者自动为主持人）
- [ ] 设备切换（摄像头、麦克风）
- [ ] Proto 命令定义完毕，信令部分保持 JSON
- [ ] Web 端支持多人会议，布局与 Flutter 端一致

---

## 里程碑 M3：会议生命周期管理 + 日历集成（4-6 周）

**目标**：建立完整的会议管理后端（创建/加入/结束/列表），与日程系统联动，实现 SDK 层支持。

### 需求覆盖

| 需求 ID | 说明 |
|---------|------|
| 1.1.1~1.1.3 | 即时/预定会议、会议链接 |
| 1.1.5 | 会议密码 |
| 1.2.1~1.2.6 | 会中控制 |
| 1.3.1 | 历史会议记录 |
| 9.1.1~9.1.4 | 日历集成 |
| 9.2.1~9.2.2 | IM 集成 |

### 任务分解

#### 3.1 会议管理后端 API

| 任务 | 文件 | 估算 |
|------|------|------|
| MEETING_CREATE 处理 | `backend/rtc/src/lib.rs` | 2d |
| MEETING_JOIN（含密码验证） | `backend/rtc/src/lib.rs` | 2d |
| MEETING_LEAVE | `backend/rtc/src/lib.rs` | 1d |
| MEETING_END | `backend/rtc/src/lib.rs` | 1d |
| MEETING_GET_INFO / GET_LIST | `backend/rtc/src/lib.rs` | 2d |
| MEETING_KICK / SET_ROLE | `backend/rtc/src/lib.rs` | 2d |
| 会议数据持久化（PostgreSQL） | `backend/rtc/src/models.rs` | 3d |

#### 3.2 SDK 会议模块

| 任务 | 文件 | 估算 |
|------|------|------|
| 新建 `sdk/app-meeting/` crate | `sdk/` | 2d |
| BizMeeting trait 定义 | `sdk/app-meeting/src/lib.rs` | 1d |
| MeetingService 实现 | `sdk/app-meeting/src/service.rs` | 3d |
| 注册到 UnionClient | `sdk/service/src/lib.rs` | 1d |

#### 3.3 日历集成

| 任务 | 文件 | 估算 |
|------|------|------|
| 创建日程自动创建会议 | `buzzing/lib/page/meeting/` | 2d |
| 日程详情会议入口 | `buzzing/lib/page/calendar/` | 1d |
| 日程开始时弹出会议提醒 | `buzzing/lib/page/calendar/` | 1d |

#### 3.4 IM 集成

| 任务 | 文件 | 估算 |
|------|------|------|
| MEETING_INVITE 消息类型 | `proto/message.proto` | 1d |
| 邀请消息发送 | `buzzing/lib/page/meeting/` | 1d |
| 收到邀请点击入会 | `buzzing/lib/page/meeting/` | 1d |
| IM 群聊发起会议 | `buzzing/lib/page/meeting/` | 1d |

#### 3.5 客户端会议 UI 增强

| 任务 | 文件 | 估算 |
|------|------|------|
| 预定会议表单 | `meeting_view.dart` | 2d |
| 历史会议列表 | `meeting_view.dart` | 2d |
| 入会弹窗（输入会议号/密码） | `meeting_view.dart` | 1d |
| 会中参会者列表 + 菜单 | `meeting_video_view.dart` | 2d |
| 主持人控制面板 | `meeting_video_view.dart` | 2d |

#### 3.6 Web 端会议 UI

| 任务 | 文件 | 估算 |
|------|------|------|
| HubView 添加会议入口卡片 | `frontend/src/views/hub/HubView.vue` | 1d |
| MeetingHomeView（预定/即时会议入口+历史列表） | `frontend/src/views/meeting/MeetingHomeView.vue` | 3d |
| 预定会议表单 | `frontend/src/views/meeting/components/ScheduleMeeting.vue` | 2d |
| 主持人控制面板（Web 端） | `frontend/src/views/meeting/MeetingRoomView.vue` | 2d |
| ModuleLayout 添加 meeting 路由 | `frontend/src/router/index.ts` | 0.5d |

### 交付物

- [ ] 后端完整会议 CRUD API（proto 命令）
- [ ] SDK 层 meeting 模块（BizMeeting trait）
- [ ] 会议关联日历日程、到点提醒
- [ ] IM 发起/邀请/点击入会
- [ ] 预定会议、历史列表、参会者管理
- [ ] Web 端完整会议管理 UI（创建/预定/历史/入会）

---

## 里程碑 M4：录制与实时字幕（4-6 周）

**目标**：实现服务端录制和实时字幕功能，录制文件支持在线播放和管理。

### 需求覆盖

| 需求 ID | 说明 |
|---------|------|
| 5.1.1~5.1.5 | 录制（服务端/本地、管理） |
| 5.2.1~5.2.4 | 实时字幕与转录 |
| 8.1~8.2 | 统计仪表盘/监控 |

### 任务分解

#### 4.1 服务端录制

| 任务 | 估算 |
|------|------|
| 录制架构设计（SFU 侧录制 vs 客户端上行录制） | 3d |
| 录制启动/停止命令 | 2d |
| 录制文件分段写入 S3 | 3d |
| 录制完成通知推送 | 1d |
| 录制管理（列表/播放/下载/删除） | 3d |

#### 4.2 客户端录制指示器

| 任务 | 估算 |
|------|------|
| 录制状态指示器 UI | 1d |
| 暂停/继续录制交互 | 1d |

#### 4.3 实时字幕（ASR）

| 任务 | 估算 |
|------|------|
| ASR 服务选型（阿里云/腾讯云/Azure 语音） | 2d |
| 音频流转发到 ASR 服务 | 3d |
| 字幕下发到所有参会者 | 2d |
| 字幕 UI 展示 | 2d |
| 发言人标识 | 1d |

#### 4.4 会后转录

| 任务 | 估算 |
|------|------|
| 全文转录存储 | 2d |
| 转录文件查看/搜索 | 2d |
| 导出（SRT/TXT） | 1d |

#### 4.5 Web 端录制回放

| 任务 | 文件 | 估算 |
|------|------|------|
| 录制文件列表页 | `frontend/src/views/meeting/RecordingsView.vue` | 2d |
| 录制在线播放（`<video>` + 进度条） | `frontend/src/views/meeting/components/RecordingPlayer.vue` | 2d |
| 转录文稿查看（时间戳链接触发跳转） | `frontend/src/views/meeting/components/TranscriptView.vue` | 2d |
| 录制文件下载 | `frontend/src/views/meeting/components/RecordingPlayer.vue` | 0.5d |

#### 4.6 监控仪表盘（前端 SPA）

| 任务 | 文件 | 估算 |
|------|------|------|
| 活跃会议列表 | `frontend/src/views/admin/MeetingMonitor.vue` | 2d |
| 质量数据展示 | `frontend/src/views/admin/MeetingMonitor.vue` | 2d |
| 使用量统计 | `frontend/src/views/admin/MeetingStats.vue` | 2d |

### 交付物

- [ ] 服务端录制可用（启动/停止/存储）
- [ ] 录制文件管理（播放/下载）
- [ ] 中文实时字幕 + 发言人标识
- [ ] 会后全文转录 + 导出
- [ ] Web 端录制在线播放 + 转录查看
- [ ] 前端 SPA 会议监控面板

---

## 里程碑 M5：SFU 架构升级（6-8 周）

**目标**：从 Mesh P2P 升级为 SFU 架构，支持 50+ 人大型会议，实现 Simulcast。

### 需求覆盖

| 需求 ID | 说明 |
|---------|------|
| 6.3 | SFU 架构（≤50 人） |
| 6.4 | Simulcast |
| 2.1.8 | 多层编码 |
| 1.1.7 | 来宾入会 |
| 1.2.7 | 等候室 |

### 任务分解

#### 5.1 SFU 选型与集成

| 任务 | 估算 |
|------|------|
| 方案评估（LiveKit / mediasoup / ion-sfu / 自研） | 3d |
| 选定 SFU 部署（Kubernetes / Docker） | 3d |
| 客户端换用 SFU SDK（如 livekit_client） | 5d |
| 信令改为 client↔SFU 模式 | 3d |

#### 5.2 Simulcast 支持

| 任务 | 估算 |
|------|------|
| 服务端 Simulcast 配置 | 3d |
| 客户端多质量层发布 | 2d |
| 接收端订阅策略（自动选择质量层） | 2d |

#### 5.3 大型会议功能

| 任务 | 估算 |
|------|------|
| 等候室逻辑 | 2d |
| 来宾入会（无登录） | 2d |
| 参会者权限系统 | 2d |
| 大会议模式（仅主持/嘉宾发言） | 3d |

#### 5.4 互动功能

| 任务 | 估算 |
|------|------|
| 表情反应 | 2d |
| 举手 + 顺序列表 | 2d |
| 投票创建/发起/结果 | 3d |
| 分组讨论（Breakout Rooms） | 5d |

#### 5.5 Web 端 SFU 适配

| 任务 | 文件 | 估算 |
|------|------|------|
| Web 端切换 SFU 模式（LiveKit JS SDK / mediasoup-client） | `frontend/src/services/signaling.ts` | 3d |
| Simulcast 质量层选择（Web 端） | `frontend/src/services/signaling.ts` | 1d |
| Web 端等候室 UI | `frontend/src/views/meeting/MeetingRoomView.vue` | 1d |
| Web 端表情/举手动画 | `frontend/src/views/meeting/MeetingRoomView.vue` | 2d |
| 移动端浏览器 SFU 通话适配 | `frontend/src/views/meeting/MeetingRoomView.vue` | 2d |

### 交付物

- [ ] SFU 部署上线，≤50 人会议
- [ ] Simulcast 按需订阅
- [ ] 等候室、来宾入会
- [ ] 表情反应、举手、投票、分组讨论
- [ ] Web 端 SFU 适配，含移动端浏览器

---

## 里程碑 M6：企业级功能（持续）

**目标**：完善安全合规、管理后台、AI 功能、开放生态，达到企业生产标准。

### 需求覆盖

| 需求 ID | 说明 |
|---------|------|
| 7.x | 安全与合规 |
| 8.x | 管理后台 |
| 5.3.x | AI 功能 |
| 9.3.x | 开放 API |

### 任务分解

#### 6.1 安全合规

| 任务 | 估算 |
|------|------|
| 审计日志（入会/离会/操作） | 3d |
| 端到端加密（E2EE）方案 | 5d |
| IP 白名单 | 2d |
| 管理员强制结束会议 | 1d |
| 会议水印 | 2d |

#### 6.2 管理后台

| 任务 | 文件 | 估算 |
|------|------|------|
| 用户会议统计 | `frontend/` | 3d |
| 质量告警规则配置 | `frontend/` | 2d |
| 自定义品牌配置 | `frontend/` | 2d |
| 录制文件保留策略 | `frontend/` | 2d |

#### 6.3 AI 功能

| 任务 | 估算 |
|------|------|
| AI 摘要生成 | 5d |
| AI 待办提取 | 3d |
| 迟来者摘要 | 2d |
| 快捷记录分享到 IM | 1d |

#### 6.4 开放 API + 生态

| 任务 | 估算 |
|------|------|
| RESTful 会议 CRUD API | 3d |
| Webhook 事件推送 | 2d |
| API 文档（OpenAPI） | 2d |

### 交付物

- [ ] 审计日志、E2EE、水印等企业安全功能
- [ ] 管理后台（统计/告警/品牌/策略）
- [ ] AI 会议纪要（摘要/待办/迟来者摘要）
- [ ] 开放 API + Webhook

---

## 研发建议

### 架构演进路线

```
M1-M2: Mesh P2P     ──→  M5: SFU
                         ↑
                   短期过渡，架构预留 SFU 接入点
```

- **当前**：纯 P2P，无服务端媒体
- **M1-M2**：Mesh P2P（≤4人），信令服务器仅做转发
- **M5**：SFU，服务端转发媒体，支持 50+ 人

保持信令与媒体分离的设计，SFU 升级时客户端信令逻辑可复用。

### Web 端架构

```
┌─────────────────────────────────────────────────┐
│ Browser (Vue SPA)                                │
│                                                   │
│  MeetingRoomView.vue                              │
│  ├─ Signaling.ts ←── WS ──→ backend/rtc /ws      │
│  ├─ RTCPeerConnection ←── P2P/SFU ──→ media      │
│  ├─ <video> remote (×N)                           │
│  ├─ <video> local (PiP)                           │
│  └─ Controls (mute/camera/screen/hangup)          │
│                                                   │
│  MeetingHomeView.vue                              │
│  ├─ 创建/预定会议 → /api (Axios → gateway)        │
│  └─ 历史会议列表                                  │
└─────────────────────────────────────────────────┘
```

Web 端与 Flutter 客户端共享同一信令服务器和协议，通过 `Browser Tab` 替代 `desktop_multi_window`。
Vite 开发环境需在 `vite.config.ts` 中代理 WS 连接：

```ts
server: {
  proxy: {
    '/api': { target: 'http://localhost:5150', changeOrigin: true },
    '/meeting/ws': { target: 'ws://localhost:5150', ws: true },
  },
}
```

### 命名建议

为与现有 "meeting" 命名统一，建议 Proto/代码中使用 `Meeting` 前缀。
后端模块保持 `backend/rtc/` 不变，SDK 新增 `sdk/app-meeting/`。

### 测试策略

| 里程碑 | 测试重点 |
|--------|----------|
| M1 | TURN 联通性、ICE restart、重连、Web ↔ Flutter 互通 |
| M2 | 多路连接建立与断开、消息收发、Web 多人会议 |
| M3 | 会议 CRUD、日程联动、IM 集成、Web 管理页面 |
| M4 | 录制文件完整性、ASR 准确率、Web 端播放 |
| M5 | 50 人并发、Simulcast 质量、移动端浏览器适配 |
| M6 | 安全渗透测试、审计日志完整性 |

### 风险点

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| SFU 选型错误导致架构重做 | 高 | M5 前充分 PoC 评估 |
| WebRTC 在 Flutter Desktop 兼容性 | 中 | 关注 flutter_webrtc 版本更新 |
| 录制文件存储成本 | 中 | 限制录制时长 + 自动清理策略 |
| ASR 服务成本 | 中 | 可配置第三方 API Key，按量计费 |
| 浏览器 WebRTC API 差异（Safari vs Chrome） | 中 | 建立跨浏览器测试矩阵，使用 adapter.js |
| WebSocket 代理跨域/端口冲突 | 低 | Vite proxy 配置统一管理 |
