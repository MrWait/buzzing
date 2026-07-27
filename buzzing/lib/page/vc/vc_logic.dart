import 'package:buzzing/page/meeting/meeting_logic.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../meeting/signaling/device_info.dart';
import '../meeting/signaling/session.dart';
import '../meeting/signaling/signaling.dart';

/// VC 子窗口生命周期阶段
enum VcPhase {
  /// 预加入：仅启动本地摄像头/麦克风预览，未连接 signaling
  prejoin,
  /// 已加入会议：signaling 已连接，进入房间
  inMeeting,
  /// 已挂断/离开
  ended,
}

typedef JoinMeetingApi = Future<bool> Function(String roomId, String? password);

class VcLogic extends ChangeNotifier {
  VcLogic({
    required this.token,
    String uid = '',
    this.userName = '',
    String? roomId,
    String? roomTitle,
    this.joinApi,
  }) : uid = uid, _roomId = roomId, _roomTitle = roomTitle;

  final String token;
  String uid;
  final String userName;
  /// 待加入的房间号（预加入阶段就有；进入会议后会赋值）
  String? _roomId;
  String? get roomId => _roomId;
  /// 房间标题，仅用于预加入页面展示；reactivate 时可更新
  String? _roomTitle;
  String? get roomTitle => _roomTitle;
  /// 调用 homeCtl.joinMeeting 的回调；为 null 时表示不需要调用 API（如创建会议后直接加入）
  final JoinMeetingApi? joinApi;

  /// 全局 joinApi 注册：主窗口 MeetingHomeLogic 启动时注册，
  /// 子窗口 VcLogic 在 confirmJoin 时优先用实例 joinApi，否则回退到此全局回调。
  /// 解决 desktop_multi_window 只能传 JSON 参数、无法直接传闭包的问题。
  static JoinMeetingApi? globalJoinApi;

  Signaling? signaling;
  var inCalling = false;
  Session? session;
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> remoteRenderers = {};
  String layoutMode = 'grid';
  String? activeSpeaker;
  final List<ChatMessage> chatMessages = [];
  int chatUnread = 0;
  bool chatOpen = false;
  List<Map<String, String>> cameraList = [];
  List<Map<String, String>> micList = [];
  String? get selectedMicDeviceId => signaling?.selectedAudioDeviceId;
  String? get selectedCameraDeviceId => signaling?.selectedVideoDeviceId;

  /// 预加入阶段：麦克风/摄像头开关状态（默认开启）
  bool micEnabled = true;
  bool cameraEnabled = true;

  VcPhase _phase = VcPhase.prejoin;
  VcPhase get phase => _phase;

  /// 窗口当前是否处于隐藏状态（由 VcView 在 onWindowClose 中设置）
  bool isHidden = false;

  /// 最小化：保留 WebRTC 连接，仅隐藏 UI（移动端使用）
  void minimize() {
    isHidden = true;
    notifyListeners();
  }

  /// 恢复：从最小化状态恢复（移动端使用）
  void restore() {
    isHidden = false;
    notifyListeners();
  }

  Future<void> init() async {
    L.d('[VcLogic] init: token=${token.length}chars, uid=$uid, roomId=$_roomId');
    await localRenderer.initialize();
    L.d('[VcLogic] localRenderer initialized');
    // 创建 signaling 实例但暂不连接，预加入阶段只用本地流和设备枚举能力
    signaling = Signaling(null, uid: uid, token: token);
    L.d('[VcLogic] Signaling instance created, config host=${signaling?.config.host}:${signaling?.config.port}');
    _registerSignalingCallbacks();
    await _startPreview();
    L.d('[VcLogic] init done, phase=$_phase');
  }

  /// 预加入阶段：申请权限、获取本地流、枚举设备
  Future<void> _startPreview() async {
    L.d('[VcLogic] _startPreview: getting local stream...');
    try {
      await signaling!.ensureLocalStream();
      var hasStream = signaling?.localStream != null;
      var hasVideo = signaling?.localStream?.getVideoTracks().isNotEmpty ?? false;
      var hasAudio = signaling?.localStream?.getAudioTracks().isNotEmpty ?? false;
      L.d('[VcLogic] local stream ready: hasStream=$hasStream, video=$hasVideo, audio=$hasAudio');
      await refreshDevices();
      L.d('[VcLogic] devices: camera=${cameraList.length}, mic=${micList.length}');
    } catch (e) {
      L.e('[VcLogic] preview start failed: $e');
    }
  }

  void setLayoutMode(String mode) {
    if (layoutMode != mode) {
      layoutMode = mode;
      notifyListeners();
    }
  }

  Future<RTCVideoRenderer> _getOrCreateRenderer(String peerId) async {
    var renderer = remoteRenderers[peerId];
    if (renderer == null) {
      renderer = RTCVideoRenderer();
      await renderer.initialize();
      remoteRenderers[peerId] = renderer;
    }
    return renderer;
  }

  Future<void> connect() async {
    L.d('[VcLogic] connect: starting WebSocket connection...');
    try {
      await signaling!.connect();
      L.d('[VcLogic] connect: WebSocket connected, isConnected=${signaling?.isConnected}');
    } catch (e) {
      L.e('[VcLogic] connect: WebSocket connection failed: $e');
      rethrow;
    }
    refreshDevices();
  }

  void _registerSignalingCallbacks() {
    L.d('[VcLogic] registering signaling callbacks');

    signaling!.onSignalingStateChange = (state) {
      L.d('[VcLogic] signaling state: $state');
    };

    signaling!.onCallStateChange = (Session newSession, CallState state) {
      L.d('[VcLogic] call state change: pid=${newSession.pid} sid=${newSession.sid} state=$state');
      switch (state) {
        case CallState.CallStateNew:
          session = newSession;
          break;
        case CallState.CallStateRinging:
          L.d('[VcLogic] ringing, accepting...');
          signaling?.accept(session!.sid, 'video');
          inCalling = true;
          notifyListeners();
          break;
        case CallState.CallStateBye:
          L.d('[VcLogic] call ended (bye)');
          localRenderer.srcObject = null;
          for (var r in remoteRenderers.values) {
            r.srcObject = null;
          }
          inCalling = false;
          notifyListeners();
          session = null;
          break;
        case CallState.CallStateInvite:
          L.d('[VcLogic] call invite (ignored in room mode)');
          break;
        case CallState.CallStateConnected:
          L.d('[VcLogic] call connected');
          inCalling = true;
          notifyListeners();
          break;
      }
    };

    signaling!.onLocalStream = (stream) {
      L.d('[VcLogic] local stream opened, tracks=${stream.getVideoTracks().length}v ${stream.getAudioTracks().length}a');
      localRenderer.srcObject = stream;
      // room 模式下不会触发 CallStateConnected，本地流就绪即代表已接入会议
      if (!inCalling && _phase == VcPhase.inMeeting) {
        L.d('[VcLogic] marking inCalling=true (room mode)');
        inCalling = true;
        notifyListeners();
      }
    };
    signaling!.onAddRemoteStream = (session, stream) async {
      L.d('[VcLogic] add remote stream: pid=${session.pid}, sid=${session.sid}, tracks=${stream.getVideoTracks().length}v ${stream.getAudioTracks().length}a');
      var renderer = await _getOrCreateRenderer(session.pid);
      renderer.srcObject = stream;
      notifyListeners();
    };
    signaling!.onRemoveRemoteStream = (session, stream) {
      L.d('[VcLogic] remove remote stream: pid=${session.pid}');
      var renderer = remoteRenderers.remove(session.pid);
      if (renderer != null) {
        renderer.srcObject = null;
        renderer.dispose();
      }
      notifyListeners();
    };
    signaling!.onPeerUpdate = (event) {
      var selfId = event['self'];
      var peers = event['peers'] as List? ?? [];
      L.d('[VcLogic] peer update: self=$selfId, peers=${peers.length}');
      uid = selfId;
    };
    signaling!.onRoomInfo = (info) {
      L.d('[VcLogic] room info: $info');
    };
    signaling!.onReconnect = () {
      L.d('[VcLogic] signaling reconnected');
      if (session != null && inCalling) {
        L.d('[VcLogic] restarting ICE after reconnect');
        signaling!.createOffer(session!, 'video', iceRestart: true);
      }
    };

    signaling!.onChatMessage = (data) {
      L.d('[VcLogic] chat message from ${data["from"]}');
      var msg = ChatMessage.fromJson(data);
      if (msg.from == uid) return;
      chatMessages.add(msg);
      if (!chatOpen) chatUnread++;
      notifyListeners();
    };
  }

  /// 预加入页面点击"加入会议"按钮：调用 API + 连接 signaling + 进入房间
  Future<bool> confirmJoin() async {
    L.d('[VcLogic] confirmJoin: phase=$_phase, roomId=$_roomId');
    if (_phase != VcPhase.prejoin) return false;
    final rid = roomId;
    if (rid == null) {
      L.e('[VcLogic] confirmJoin: roomId is null');
      return false;
    }
    // 调用入会 API：优先用实例 joinApi，否则回退到 globalJoinApi
    final api = joinApi ?? VcLogic.globalJoinApi;
    L.d('[VcLogic] confirmJoin: hasJoinApi=${api != null}');
    if (api != null) {
      try {
        L.d('[VcLogic] confirmJoin: calling joinApi for room $rid...');
        final ok = await api(rid, null);
        L.d('[VcLogic] confirmJoin: joinApi returned $ok');
        if (!ok) {
          L.e('[VcLogic] join API returned false');
          return false;
        }
      } catch (e) {
        L.e('[VcLogic] join API error: $e');
        return false;
      }
    }
    _phase = VcPhase.inMeeting;
    // 预加入阶段本地流已就绪，不会再次触发 onLocalStream 回调，
    // 因此此处主动标记 inCalling，避免卡在 _ConnectingView
    var hasLocalStream = signaling?.localStream != null;
    if (hasLocalStream) {
      L.d('[VcLogic] confirmJoin: local stream already ready, setting inCalling=true');
      inCalling = true;
    } else {
      L.d('[VcLogic] confirmJoin: no local stream yet, will wait for onLocalStream');
    }
    notifyListeners();
    // 应用预加入页面的麦克风/摄像头开关状态到实际 track
    applyDeviceStates();
    L.d('[VcLogic] confirmJoin: connecting signaling...');
    await connect();
    L.d('[VcLogic] confirmJoin: joining room $rid');
    joinRoom(rid);
    L.d('[VcLogic] confirmJoin: done');
    return true;
  }

  /// 取消加入，隐藏窗口（不销毁 engine）
  void cancelJoin() {
    // 直接走 leaveAndHide 流程：释放本地流 + 重置 phase 为 prejoin
    leaveAndHide();
  }

  /// 隐藏窗口时调用：释放重资源（signaling/PC/本地流），重置状态为 prejoin
  /// 保留 VcLogic 实例 + localRenderer + UI widget tree，实现 engine 复用
  Future<void> leaveAndHide() async {
    L.d('[VcLogic] leaveAndHide: phase=$_phase, roomId=$_roomId, remoteRenderers=${remoteRenderers.length}');
    // 1. leave 房间 + 关闭 signaling：释放 localStream、PC、socket
    try {
      if (_roomId != null) {
        L.d('[VcLogic] leaveAndHide: sending leave...');
        signaling?.leave();
      }
      L.d('[VcLogic] leaveAndHide: closing signaling...');
      await signaling?.close();
      L.d('[VcLogic] leaveAndHide: signaling closed');
    } catch (e) {
      L.e('[VcLogic] leaveAndHide signaling close error: $e');
    }
    // 2. 释放远端 renderer（释放原生视频渲染内存）
    var rendererCount = remoteRenderers.length;
    for (var r in remoteRenderers.values) {
      r.srcObject = null;
      r.dispose();
    }
    remoteRenderers.clear();
    // 3. 释放本地 renderer（仅清空引用，不 dispose — flutter_webrtc 不支持 dispose 后重新 initialize）
    localRenderer.srcObject = null;
    // 4. 重置状态
    _phase = VcPhase.prejoin;
    inCalling = false;
    session = null;
    _roomId = null;
    chatMessages.clear();
    chatUnread = 0;
    chatOpen = false;
    isHidden = true;
    L.d('[VcLogic] leaveAndHide: reset done, freed $rendererCount remote renderers');
    notifyListeners();
  }

  /// 窗口再次显示时调用：重新获取本地流 + 设备枚举，进入预加入页面
  /// 由 VcView 在收到主窗口的 'reactivate' IPC 消息时触发
  Future<void> reactivate({String? roomId, String? roomTitle}) async {
    L.d('[VcLogic] reactivate: roomId=$roomId, roomTitle=$roomTitle, oldSignaling=${signaling != null}');
    if (roomId != null) {
      _roomId = roomId;
    }
    if (roomTitle != null) {
      _roomTitle = roomTitle;
    }
    isHidden = false;
    // 为了状态最干净，直接重建一个 signaling 实例
    try {
      await signaling?.close();
    } catch (_) {}
    signaling = Signaling(null, uid: uid, token: token);
    L.d('[VcLogic] reactivate: new signaling created');
    _registerSignalingCallbacks();
    await _startPreview();
    L.d('[VcLogic] reactivate: done');
    notifyListeners();
  }

  /// 主窗口通过 IPC 调用，更新预加入阶段的房间信息
  void updateRoom({String? roomId, String? roomTitle}) {
    if (roomId != null) _roomId = roomId;
    if (roomTitle != null) _roomTitle = roomTitle;
    notifyListeners();
  }

  /// 预加入页面切换麦克风开关
  void toggleMic() {
    micEnabled = !micEnabled;
    final stream = signaling?.localStream;
    if (stream != null) {
      for (var t in stream.getAudioTracks()) {
        t.enabled = micEnabled;
      }
    }
    notifyListeners();
  }

  /// 预加入页面切换摄像头开关
  void toggleCamera() {
    cameraEnabled = !cameraEnabled;
    final stream = signaling?.localStream;
    if (stream != null) {
      for (var t in stream.getVideoTracks()) {
        t.enabled = cameraEnabled;
      }
    }
    notifyListeners();
  }

  /// 入会时同步预加入页面的开关状态到 signaling（避免被 signaling 内部状态覆盖）
  void applyDeviceStates() {
    final stream = signaling?.localStream;
    if (stream != null) {
      for (var t in stream.getAudioTracks()) {
        t.enabled = micEnabled;
      }
      for (var t in stream.getVideoTracks()) {
        t.enabled = cameraEnabled;
      }
    }
  }

  Future<void> refreshDevices() async {
    var map = await signaling!.enumerateDevices();
    cameraList = map.keys
        .where((k) => k.startsWith('videoinput:'))
        .map((k) => {'deviceId': k.split(':')[1], 'label': map[k] ?? ''})
        .toList();
    micList = map.keys
        .where((k) => k.startsWith('audioinput:'))
        .map((k) => {'deviceId': k.split(':')[1], 'label': map[k] ?? ''})
        .toList();
    notifyListeners();
  }

  Future<void> switchCameraDevice(String deviceId) async {
    await signaling?.switchCameraDevice(deviceId);
    await refreshDevices();
  }

  Future<void> switchMicrophoneDevice(String deviceId) async {
    await signaling?.switchMicrophoneDevice(deviceId);
    await refreshDevices();
  }

  void sendChatMessage(String text) {
    if (text.trim().isEmpty) return;
    signaling?.sendChatMessage(text, name: userName.isNotEmpty ? userName : null);
    chatMessages.add(ChatMessage(
      type: 'chat',
      from: uid,
      name: userName.isNotEmpty ? userName : DeviceInfo.label,
      text: text.trim(),
      ts: DateTime.now().millisecondsSinceEpoch,
    ));
    notifyListeners();
  }

  void toggleChat() {
    chatOpen = !chatOpen;
    if (chatOpen) chatUnread = 0;
    notifyListeners();
  }

  void joinRoom(String roomId) {
    L.d('[VcLogic] joinRoom: roomId=$roomId, localStream=${signaling?.localStream != null}, connected=${signaling?.isConnected}');
    _roomId = roomId;
    signaling?.join(roomId);
  }

  void leaveRoom() {
    signaling?.leave();
    _roomId = null;
  }

  void invite(String peerId) {
    signaling?.invite(peerId, 'video', false);
  }

  void hangUp() {
    if (roomId != null) {
      leaveRoom();
    } else if (session != null) {
      signaling?.bye(session!.sid);
    }
  }

  bool _disposed = false;

  /// 异步释放 WebRTC 资源：必须等待 PC/Stream/Socket 全部关闭，
  /// 否则子窗口关闭后 flutter_webrtc 引擎仍在后台持有摄像头/麦克风
  Future<void> disposeAsync() async {
    if (_disposed) return;
    _disposed = true;
    await signaling?.close();
    try {
      localRenderer.srcObject = null;
      localRenderer.dispose();
    } catch (_) {}
    for (var r in remoteRenderers.values) {
      try {
        r.srcObject = null;
        r.dispose();
      } catch (_) {}
    }
    remoteRenderers.clear();
    super.dispose();
  }

  void muteMic() {
    signaling?.muteMic();
  }

  void switchCamera() {
    signaling?.switchCamera();
  }

  void startScreenSharing() {
    signaling?.startScreenSharing();
  }

  void stopScreenSharing() {
    signaling?.stopScreenSharing();
  }

  @override
  void dispose() {
    // 兜底：若 disposeAsync 已执行过则跳过；否则同步快速释放
    if (_disposed) return;
    _disposed = true;
    signaling?.close();
    localRenderer.dispose();
    for (var r in remoteRenderers.values) {
      r.dispose();
    }
    remoteRenderers.clear();
    super.dispose();
  }
}
