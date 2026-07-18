# M2：Mesh 多人通话 — 详细设计方案

> 对应 `milestones.md` 中 M2 阶段（3-4 周），将多人通话从架构到实现细节逐一明确。

## 1. 架构总览

```
┌───────────────────────────────────────────────┐
│ 信令服务器 (backend/rtc/src/signaling.rs)      │
│                                                │
│  RoomManager ── Map<roomId, Room>              │
│    ├─ Room { id, peers, host }                 │
│    ├─ join(peerId, roomId) → broadcast peers   │
│    ├─ leave(peerId) → broadcast peers          │
│    └─ forward(msg, excludePeer)                │
│                                                │
│  PeerManager ── Map<peerId, Peer> (已有)         │
└───────────────────┬───────────────────────────┘
                    │ WS
┌───────────────────┴───────────────────────────┐
│ 客户端 (Flutter / Web)                         │
│                                                │
│  Signaling.join(roomId)                        │
│    → ws.send({type:"join", data:{room_id}})    │
│    → 服务端返回已有 peer list                    │
│    → 对每个 peer 创建 PeerConnection            │
│                                                │
│  Map<peerId, Session> 管理多路连接              │
│  RTCDataChannel 用于会中聊天                    │
└───────────────────────────────────────────────┘
```

## 2. 房间信令协议

### 2.1 新增消息类型（继续使用 JSON 协议）

```
join    → { type:"join",   data:{room_id, token?, password?} }
leave   → { type:"leave",  data:{room_id} }
room_info → { type:"room_info", data:{room_id, peers:[...], host}}
```

### 2.2 入会流程

```
Client A                Server              Client B
  │                       │                    │
  │──── join(room_a) ────→│                    │
  │                       │── store peer ──→   │
  │←── room_info(peers) ──│                    │
  │                       │                    │
  │── offer → B           │                    │
  │──── offer ────────────→│── forward ──────→ │
  │                       │                    │
  │                       │←── answer ─────── │
  │←── answer ────────────│                    │
  │                       │                    │
  │                       │←── candidate ──── │
  │←── candidate ─────────│                    │
```

信令服务器不解析 media 数据（offer/answer/candidate），仅按 room_id 转发给除发送者外的所有房间成员。

### 2.3 服务端 Room 数据结构

```rust
struct Room {
    id: String,
    host: String,              // 创建者 peer_id
    peers: HashMap<String, Peer>,
    created_at: Instant,
}

struct RoomManager {
    rooms: RwLock<HashMap<String, Room>>,
}
```

- 第一个 `join` 某 room_id 的用户自动成为 `host`
- 房间内 `peer list` 变化时广播 `room_info` 给所有成员
- 最后一个 `leave` 时删除 Room

### 2.4 服务端消息转发逻辑

```rust
// 收到消息 → 按 type 分类处理
match msg.type {
    "join"    → handle_join(...)
    "leave"   → handle_leave(...)
    "offer"   → forward_to_room(...)   // 发给除 sender 外的所有人
    "answer"  → forward_to_room(...)
    "candidate" → forward_to_room(...)
    "bye"     → forward_to_room(...)
    其他      → handle_new_peer(...)  // 保持 M1 的 new/peers 逻辑
}
```

## 3. 客户端多 PeerConnection 管理

### 3.1 数据结构

```dart
class Signaling {
  // 已有
  String uid;
  SimpleWebSocket? socket;

  // M2 新增
  String? roomId;
  Map<String, Session> sessions;  // peerId → Session (已有，但原为 sessionId 索引)
  List<String> remotePeerIds;     // 房间内除自己外的 peer 列表
}
```

### 3.2 连接生命周期

```
join(roomId)
  │
  ├─ ws.send("join", {room_id: roomId})
  │
  ├─ 收到 room_info
  │   ├─ uid = self
  │   ├─ remotePeerIds = peers - self
  │   └─ 对每个 remotePeer 调用 createPeerConnection(peerId)
  │
  ├─ 收到新成员加入 → createPeerConnection(newPeer)
  │
  ├─ 收到成员离开 → closeSession(peerId)
  │
  └─ leave() → ws.send("leave") → 清理所有连接
```

### 3.3 Session 结构（调整）

```dart
class Session {
  String pid;            // peer id（原为 "from" 角色）
  String sid;            // session id = `${uid}-${pid}`
  RTCPeerConnection? pc;
  List<RTCIceCandidateInit> remoteCandidates;
  RTCDataChannel? dc;    // 会中聊天
  String media;          // "video" | "data"
}
```

注意：M1 中 Session 的 key 是 `sessionId = "$uid-$peerId"`，M2 沿用此模式。每个远端 peer 对应一个 Session。

### 3.4 invite 语义变更

M1 中 `invite` 是定向呼叫（点对点邀请）。M2 中移入房间模型：
- 用户先 `join(roomId)` 进入会议房间
- 房间内成员自动建连
- 无需显式 `invite` 操作

兼容 M1 的 1v1 场景：`join("$uid-$peerId")` 使用两位 ID 拼接作为 roomId。

## 4. 多路视频渲染

### 4.1 数据结构

```dart
class MeetingLogic {
  // M1 已有
  RTCVideoRenderer localRenderer;
  RTCVideoRenderer remoteRenderer;   // 单路

  // M2 改为
  Map<String, RTCVideoRenderer> remoteRenderers;  // peerId → renderer
  String layoutMode;  // "grid" | "speaker"
  String? activeSpeaker;  // 当前发言者 peerId
}
```

### 4.2 宫格布局（Grid Layout）

- 1 人：自己的全屏预览
- 2 人：1大（远端）+ 1小（本地 PiP）= M1 当前设计
- 3-4 人：2×2 宫格
- 4 人以上：3×3 宫格（M2 限 4 人，但布局预留）

```
┌──────────┬──────────┐
│  远端1    │  远端2    │
│          │          │
├──────────┼──────────┤
│  远端3    │  本地     │
│          │ (PiP)    │
└──────────┴──────────┘
```

### 4.3 演讲者视图（Speaker View）

- 主区域：当前发言者（音频音量最大的参与者）全屏
- 右侧/底部：其他参与者缩略图列表

```
┌─────────────────┬──────┐
│                  │远端2  │
│    远端1(发言)    │      │
│                  ├──────┤
│                  │远端3  │
│                  │      │
│                  ├──────┤
│  本地 PiP        │远端4  │
└─────────────────┴──────┘
```

### 4.4 本地 PiP

保持 M1 设计，通话中始终显示在右下角。

## 5. 会中聊天（RTCDataChannel）

### 5.1 通道建立

每个 PeerConnection 建立成功后，创建一条 `RTCDataChannel`，label = `chat`。

```dart
// createSession 中
if (media != 'data') {
  RTCDataChannel channel = await pc.createDataChannel('chat', ...);
  setupChatChannel(session, channel);
}

// 接收端
pc.onDataChannel = (channel) {
  if (channel.label == 'chat') {
    setupChatChannel(session, channel);
  }
};
```

### 5.2 聊天消息协议（JSON over DataChannel）

```json
// 发送
{ "type": "chat", "data": { "from": "uid", "name": "张三", "text": "你好", "ts": 1712345678 } }

// 系统通知
{ "type": "system", "data": { "text": "张三 加入了会议", "ts": 1712345678 } }
```

### 5.3 消息类型

| type | 说明 |
|------|------|
| `chat` | 普通文本消息 |
| `system` | 系统通知（入会/离会/录制开始等） |

## 6. 音频/视频设备管理

### 6.1 设备枚举与切换

```dart
Future<List<MediaDeviceInfo>> enumerateDevices() async {
  return await navigator.mediaDevices.enumerateDevices();
}

Future<void> switchCamera(String deviceId) async {
  // 重新 getUserMedia → replaceTrack
  var newStream = await navigator.mediaDevices.getUserMedia({video: {deviceId}});
  var videoTrack = newStream.getVideoTracks()[0];
  await sender.replaceTrack(videoTrack);
}
```

### 6.2 replaceTrack 统一封装

在 `Signaling` 中新增：

```dart
Future<void> replaceVideoTrack(MediaStreamTrack track) async {
  for (final sender in senders) {
    if (sender.track?.kind == 'video') {
      await sender.replaceTrack(track);
    }
  }
}
```

## 7. Proto + 命令定义

### 7.1 `proto/meeting.proto`（新建）

```protobuf
syntax = "proto3";
package meeting;

message MeetingInfo {
  string room_id = 1;
  int64 host_id = 2;
  repeated int64 member_ids = 3;
  string title = 4;
  int64 created_at = 5;
  string password = 6;       // 可选
  MeetingStatus status = 7;
}

enum MeetingStatus {
  MEETING_ACTIVE = 0;
  MEETING_ENDED = 1;
}

message JoinMeetingRequest {
  string room_id = 1;
  string password = 2;          // 可选
}

message JoinMeetingResponse {
  MeetingInfo info = 1;
}

message LeaveMeetingRequest {
  string room_id = 1;
}

message EndMeetingRequest {
  string room_id = 1;
}

message GetMeetingInfoRequest {
  string room_id = 1;
}

message GetMeetingListResponse {
  repeated MeetingInfo meetings = 1;
}
```

### 7.2 命令枚举 `proto/command.proto` 追加

```protobuf
// Meeting commands 1800-1812
MEETING_CREATE = 1800;
MEETING_JOIN = 1801;
MEETING_LEAVE = 1802;
MEETING_END = 1803;
MEETING_GET_INFO = 1804;
MEETING_GET_LIST = 1805;
MEETING_KICK = 1806;
MEETING_SET_ROLE = 1807;
MEETING_INVITE = 1808;
```

### 7.3 说明

- Proto 命令 1800~1812 对应 M3 的会议管理后端 API
- M2 阶段**信令仍保持 JSON 协议**，房间 join/leave 走 WebSocket JSON 消息
- Proto 命令仅在需要与后端 CRUD 交互时使用（M3 正式引入）
- 但 M2 提前定义命令和消息结构，确保前后端 proto 编译一致

## 8. Web 端适配

### 8.1 多 Session 管理

`frontend/src/services/meeting/signaling.ts` 中 `sessions` 已是 `Map<string, Session>` 结构，M2 扩展为 `Map<peerId, Session>` 即可。

### 8.2 多路 `<video>` 渲染

```
receives: Map<peerId, MediaStream>

〈template〉
  <div v-for="(stream, peerId) in receives" :key="peerId">
    <video :srcObject="stream" autoplay />
  </div>
```

宫格布局使用 CSS Grid：
```css
.grid-layout {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 4px;
}
```

### 8.3 聊天 UI

使用一个 overlay 面板，通过按钮切换显示/隐藏。

## 9. 文件变更清单

| 文件 | 变更类型 | 说明 |
|------|----------|------|
| `backend/rtc/src/signaling.rs` | 修改 | 新增 Room/RoomManager，join/leave 消息处理，房间内转发 |
| `signaling.dart` | 修改 | 新增 join(roomId)、leave()、多 Session 管理适配 |
| `signaling.ts` | 修改 | 同上，Web 端 |
| `meeting_logic.dart` | 修改 | 多路 renderer、宫格/演讲者布局切换 |
| `meeting_video_view.dart` | 修改 | 多路视频渲染、布局切换 |
| `MeetingRoomView.vue` | 修改 | 多路 `<video>` 渲染、聊天 overlay |
| `meeting_controls.dart` | 修改 | 新增设备切换按钮、聊天开关 |
| `meeting_view.dart` | 修改 | 新增举手/聊天入口 |
| `proto/meeting.proto` | 新增 | 会议相关消息定义 |
| `proto/command.proto` | 修改 | 追加 1800~1808 命令枚举 |

## 10. 边界情况

| 场景 | 处理方式 |
|------|----------|
| 重复 roomId | 房间已存在则直接加入 |
| 房间满员 | M2 限 4 人，超限返回 "room_full" 错误 |
| 创建者离开 | 移交 host 给剩余成员中最早加入者 |
| 网络断开后重连 | 重连后自动 re-join 房间、恢复连接 |
| 并发入会 | 锁保护 Room.peers 插入操作 |
| Web 端同房间 2 个 Tab | 每个 Tab 独立 peerId，视为不同参与者 |
