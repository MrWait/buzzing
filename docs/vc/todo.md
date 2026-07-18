# VC M1 实施跟踪

> 对应 `m1_prd.md` 第 6 节实施步骤，按步骤拆分为可勾选的任务项。
> 状态图例：⬜ 未开始 🔄 进行中 ✅ 已完成 ❌ 阻塞

---

## M1-1 后端基础

### 1.1 信令认证

**文件**: `backend/rtc/src/signaling.rs` + `lib.rs` + `signaling.dart` + `meeting_logic.dart` | **工时**: 1.5d | **负责人**: | **状态**: ✅

- [x] 1.1.1 `PeerInfo` 增加 `user_id: i64`、`tenant_id: i64` 字段
- [x] 1.1.2 `New` 消息解析 token，调用项目现有 JWT 验证函数
- [x] 1.1.3 token 有效时提取 user_id/tenant_id 填充到 PeerInfo
- [x] 1.1.4 token 无效时返回 error 消息并关闭 WS 连接
- [x] 1.1.5 Flutter 端 Signaling 传入 token（SignalingConfig + MeetingLogic + provider）
- [x] 1.1.6 服务端 JWT 初始化（`signaling::init_jwt()`）

### 1.2 TURN 凭证

**文件**: `backend/rtc/src/turn.rs` + `lib.rs` | **工时**: 1.5d | **负责人**: | **状态**: ✅

- [x] 1.2.5 删除冗余 `/meeting` 端点（旧 ws_handler + handle_socket 已移除）
- [x] 1.2.1 `Cargo.toml` 添加 hmac, sha2, base64 依赖
- [x] 1.2.2 改用 `LongTermAuthHandler` HMAC 验证（timestamp 过期检查 + 签名校验）
- [x] 1.2.3 TURN secret_key 配置读取（`settings.turn_secret`）
- [x] 1.2.4 `/api/turn?token={jwt}` 凭证签发端点（validate_token → generate_credential → 返回 JSON）
- [ ] 1.2.6 集成测试：curl 凭证 API + TURN 端口可达

---

## M1-2 连接可靠性

### 2.1 WS 重连 + Keepalive

**文件**: `signaling.dart` + `meeting_logic.dart` | **工时**: 1.5d | **负责人**: | **状态**: ✅

- [x] 2.1.1 新增 `_reconnectAttempts` / `_reconnectTimer` 状态
- [x] 2.1.2 实现 `_reconnect()`：指数退避（1→2→4→8→16s），成功后重置
- [x] 2.1.3 `onClose` 回调触发重连（`_intentionalClose` 区分主动/被动关闭）
- [x] 2.1.4 重连成功后自动 re-send `new` 消息
- [x] 2.1.5 `_keepaliveTimer` 每 3s 发送 keepalive
- [x] 2.1.6 `_keepaliveTimeout`：5s 无响应 → 判定断开 → 触发重连
- [x] 2.1.7 `connect()` 改为可重入（清旧 socket、复用 turnCredential）
- [x] 2.1.8 `MeetingLogic` 新增 `onReconnect` 回调

### 2.2 ICE Restart

**文件**: `signaling.dart` + `meeting_logic.dart` | **工时**: 1.5d | **负责人**: | **状态**: ✅

- [x] 2.2.1 `createOffer` 添加 `iceRestart` 参数
- [x] 2.2.2 重连后检测活跃 session，触发 `pc.createOffer({iceRestart: true})` + 发送新 offer
- [ ] 2.2.3 平台网络状态变更时触发 ICE restart（后续 M4）
- [ ] 2.2.4 验证 DTLS 会话复用，音视频不中断（手动测试）

---

## M1-3 屏幕共享 + 码率自适应

### 3.1 屏幕共享

**文件**: Flutter `signaling.dart` + `meeting_logic.dart` | **工时**: 2d | **负责人**: | **状态**: ✅

- [x] 3.1.1 `startScreenSharing()` 调用 `getDisplayMedia()` + `replaceTrack`；`stopScreenSharing()` 切回摄像头
- [x] 3.1.2 `_createCameraStream()` 加入音频约束（echoCancellation/noiseSuppression/autoGainControl）
- [x] 3.1.3 `MeetingLogic.startScreenSharing()` / `stopScreenSharing()`
- [ ] 3.1.4 `MeetingControls` 按钮状态（共享中/未共享）切换（UI 待做）
- [ ] 3.1.5 Web `signaling.ts` 实现 `startScreenShare()` / `stopScreenShare()`
- [ ] 3.1.6 Web `ControlBar.vue` 屏幕共享按钮

### 3.2 码率自适应

**文件**: Flutter `signaling.dart` | **工时**: 2d | **负责人**: | **状态**: ✅

- [x] 3.2.1 `pc.onIceConnectionState` 监听 → `_onIceConnectionState()`
- [x] 3.2.2 `_setupSimulcastEncodings()` 设置三层（q/h/f）编码参数
- [x] 3.2.3 `_onIceConnectionState` BWE：Connected/Completed 启用编码，Disconnected/Failed 禁用
- [ ] 3.2.4 `_statsTimer` 每 5s 采集 RTCStatsReport + 动态降级/升级（后续实现）
- [ ] 3.2.5 `MeetingVideoView` 网络质量图标
- [ ] 3.2.6 `MeetingLogic` 暴露 `networkQuality` 状态
- [ ] 3.2.7 Web `signaling.ts` 码率自适应实现
- [ ] 3.2.8 Web `MeetingRoomView.vue` 网络质量指示器

---

## M1-4 VcWindow 子窗口

### 4.1 子窗口信令逻辑

**文件**: `vc_logic.dart` | **工时**: 1.5d | **负责人**: | **状态**: ✅

- [x] 4.1.1 `VcLogic`（ChangeNotifier）声明 Signaling/renderer/状态字段
- [x] 4.1.2 `init()` 渲染器初始化 + `connect()` 创建 Signaling(token, uid)
- [x] 4.1.3 `connect()` → `Signaling.connect()` + 设置 onPeerUpdate/onCallStateChange/onLocalStream/onAddRemoteStream
- [x] 4.1.4 invite/hangUp/muteMic/switchCamera/startScreenSharing/stopScreenSharing
- [x] 4.1.5 `onCallStateChange`：Ringing→accept, Connected→inCalling, Bye→挂断

### 4.2 子窗口 UI + 主窗口传参

**文件**: `vc_view.dart` + `meeting_logic.dart` | **工时**: 2.5d | **负责人**: | **状态**: ✅

- [x] 4.2.1 `vc_view.dart` 集成 RTCVideoView + MeetingControls
- [x] 4.2.2 remote 全屏 + local PiP（右下角 200x150）布局
- [x] 4.2.3 MeetingControls 挂载（切换摄像头/屏幕共享/挂断/静音）
- [x] 4.2.4 `vc_view.dart` 从 args 解析 token/uid
- [x] 4.2.5 `meeting_logic.dart` createMeeting 传入 token/uid 到子窗口
- [x] 4.2.6 子窗口 dispose → sub_window_close → 主窗口清理（已有架构）

---

## M1-5 Web 端基础入会

### 5.1 Signaling.ts + 路由 + 页面骨架

**文件**: `frontend/` | **工时**: 2.5d | **负责人**: | **状态**: ✅

- [x] 5.1.1 `services/meeting/signaling.ts` — 完整 TS Signaling 类（connect/disconnect/invite/accept/reject/bye/keepalive/reconnect/send/onMessage）
- [x] 5.1.2 Web 端 ICE restart（`iceRestart()` 方法）
- [x] 5.1.3 Web 端码率自适应（`oniceconnectionstatechange` 切换 track enabled）
- [x] 5.1.4 `stores/meeting.ts` — Pinia store（inCalling/uid/peers/networkQuality）
- [x] 5.1.5 路由注册：`/meeting/:roomId` → FullscreenLayout → MeetingRoomView
- [x] 5.1.6 `layouts/FullscreenLayout.vue` 启用（已有）
- [ ] 5.1.7 `views/meeting/MeetingRoomView.vue` 骨架（onMounted → 获取 token → 创建 Signaling → 弹出 DevicePreview）
- [ ] 5.1.8 `vite.config.ts` 添加 `/meeting/ws` proxy

### 5.2 组件 + 来宾入会

**文件**: `frontend/src/views/meeting/` | **工时**: 2.5d | **负责人**: | **状态**: ⬜

- [ ] 5.2.1 `DevicePreview.vue`：枚举设备 → 用户选择 → `getUserMedia`
- [ ] 5.2.2 `ControlBar.vue`：静音/摄像头/屏幕共享/挂断
- [ ] 5.2.3 `ParticipantList.vue`：peers 列表
- [ ] 5.2.4 `MeetingRoomView.vue` 完整集成（RemoteVideo + LocalVideo PiP + ControlBar + ParticipantList）
- [ ] 5.2.5 来宾入会：无 token → 弹出名称输入框 → `connectAsGuest(name)`
- [ ] 5.2.6 断线重连 + keepalive（signaling.ts）

---

## M1-6 联调 + 测试

### 6.1 端到端验证

**工时**: 2d | **负责人**: | **状态**: ⬜

- [ ] 6.1 Vite proxy `/meeting/ws` 确认生效
- [ ] 6.2 Flutter 1v1 端到端：双设备 → 信令 → 视频通话 3min → 挂断
- [ ] 6.3 Web ↔ Flutter 互通：浏览器入会 → Flutter 双向音视频
- [ ] 6.4 屏幕共享端到端：Flutter 共享 → Web 端渲染
- [ ] 6.5 认证拒绝：非法 token → 拒绝连接（`backend_test`）
- [ ] 6.6 WS 重连：kill WS 进程 → 自动重连 < 16s（`backend_test`）
- [ ] 6.7 VcWindow：创建 → 渲染 → 控制 → 挂断 → 关闭（`buzzing/sdk_test`）
- [ ] 6.8 回归测试：login/chat/calendar/office 不受影响（`just test`）

---

## 汇总

| 阶段 | 总工时 | 完成度 |
|------|--------|--------|
| M1-1 后端基础 | 3d | ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜ |
| M1-2 连接可靠性 | 3d | ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜ |
| M1-3 屏幕共享+码率 | 4d | ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜ |
| M1-4 VcWindow | 4d | ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜ |
| M1-5 Web 端 | 5d | ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜ |
| M1-6 联调测试 | 2d | ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜ |
| **合计** | **21d** | |

### Done Definition

- [ ] 信令连接必须携带有效 token，非法 token 100% 拒绝
- [ ] TURN 凭证签发 API 可用，TURN 转发成功率 > 90%
- [ ] WS 断线后自动重连，ICE restart 不中断通话
- [ ] 屏幕共享可用（全屏+窗口），远端正常渲染
- [ ] 码率根据网络状况自动调整，降级不频繁（> 10s 间隔）
- [ ] VcWindow 子窗口完整操作：创建/渲染/控制/挂断/关闭
- [ ] Web 端可创建和加入会议，与 Flutter 客户端互通
- [ ] 自动化测试覆盖认证/重连/子窗口核心场景
- [ ] 无 P0/P1 级别的稳定性问题
