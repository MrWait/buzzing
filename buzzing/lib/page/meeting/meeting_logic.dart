import 'package:buzzing/controller/app_controller.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'signaling/device_info.dart';
import 'signaling/session.dart';
import 'signaling/signaling.dart';

class ChatMessage {
  final String type;
  final String? from;
  final String? name;
  final String text;
  final int ts;

  ChatMessage({
    required this.type,
    this.from,
    this.name,
    required this.text,
    required this.ts,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    var data = json['data'] as Map<String, dynamic>? ?? {};
    return ChatMessage(
      type: json['type'] as String? ?? 'chat',
      from: data['from'] as String?,
      name: data['name'] as String?,
      text: data['text'] as String? ?? '',
      ts: data['ts'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class MeetingLogic extends ChangeNotifier {
  var inCalling = false;
  Signaling? signaling;
  String uid = '';
  List<dynamic> peers = [];
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> remoteRenderers = {};
  String layoutMode = 'grid';
  String? activeSpeaker;
  Session? session;
  bool waitAccept = false;
  final AppController app;
  final String token;
  final String userName;
  bool micEnabled = true;
  bool cameraEnabled = true;
  List<Map<String, String>> cameraList = [];
  List<Map<String, String>> micList = [];
  String? get selectedCameraDeviceId => signaling?.selectedVideoDeviceId;
  String? get selectedMicDeviceId => signaling?.selectedAudioDeviceId;
  final List<ChatMessage> chatMessages = [];
  int chatUnread = 0;
  bool chatOpen = false;

  MeetingLogic({required this.app, required this.token, this.userName = ''});

  void init() {
    initRenderers();
  }

  void initRenderers() async {
    await localRenderer.initialize();
  }

  void setLayoutMode(String mode) {
    if (layoutMode != mode) {
      layoutMode = mode;
      notifyListeners();
    }
  }

  void createMeeting({String? roomId, String? roomTitle}) {
    // 不 await：调用方无需等待窗口创建结果；createWindow 内部会处理复用或新建
    app.createWindow('VcWindow', true, true, {
      'token': token,
      'uid': uid,
      'user_name': userName,
      'locale': LocaleSettings.instance.currentLocale.languageCode,
      if (roomId != null) 'room_id': roomId,
      if (roomTitle != null) 'room_title': roomTitle,
    });
  }

  /// 打开视频会议窗口并加入指定房间
  /// 注意：此处不再调用入会 API，由 VcLogic.confirmJoin 在预加入页面调用
  void joinMeeting(String roomId, {String? roomTitle}) {
    app.createWindow('VcWindow', true, true, {
      'token': token,
      'uid': uid,
      'user_name': userName,
      'locale': LocaleSettings.instance.currentLocale.languageCode,
      'room_id': roomId,
      if (roomTitle != null) 'room_title': roomTitle,
    });
  }

  void toggleMic() {
    micEnabled = !micEnabled;
    if (signaling?.localStream != null) {
      for (var t in signaling!.localStream!.getAudioTracks()) {
        t.enabled = micEnabled;
      }
    }
    notifyListeners();
  }

  void toggleCamera() {
    cameraEnabled = !cameraEnabled;
    if (signaling?.localStream != null) {
      for (var t in signaling!.localStream!.getVideoTracks()) {
        t.enabled = cameraEnabled;
      }
    }
    notifyListeners();
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

  void muteMic() {
    signaling?.muteMic();
  }

  RTCVideoRenderer _getOrCreateRenderer(String peerId) {
    var renderer = remoteRenderers[peerId];
    if (renderer == null) {
      renderer = RTCVideoRenderer();
      renderer.initialize();
      remoteRenderers[peerId] = renderer;
    }
    return renderer;
  }

  void connect(BuildContext context) async {
    if (signaling == null) {
      signaling = Signaling(context, uid: uid, token: token);
    }
    signaling!.connect();

    signaling!.onSignalingStateChange = (SignalingState state) {
      L.d('[RTC] signaling state changed: $state');
    };

    signaling!.onCallStateChange = (Session newSession, CallState state) async {
      L.d('[RTC] call state change: ${newSession.sid}, $state');
      switch (state) {
        case CallState.CallStateNew:
          session = newSession;
          break;
        case CallState.CallStateRinging:
          final acc = await showAcceptDialog(context);
          if (acc) {
            signaling?.accept(session!.sid, 'video');
            inCalling = true;
            notifyListeners();
          } else {
            signaling?.reject(session!.sid);
          }
          break;
        case CallState.CallStateBye:
          if (waitAccept) {
            L.d('peer reject');
            waitAccept = false;
          }
          localRenderer.srcObject = null;
          for (var r in remoteRenderers.values) {
            r.srcObject = null;
          }
          inCalling = false;
          notifyListeners();
          session = null;
          break;
        case CallState.CallStateInvite:
          waitAccept = true;
          showInviteDialog(context);
          break;
        case CallState.CallStateConnected:
          if (waitAccept) {
            waitAccept = false;
          }
          inCalling = true;
          notifyListeners();
          break;
      }
    };

    var prevPeers = <String>{};
    signaling!.onPeerUpdate = (event) {
      L.d('[RTC] peer update: $event');
      uid = event['self'];
      var newPeers = (event['peers'] as List<dynamic>)
          .map((p) => p['id'] as String)
          .toSet();
      for (var pid in newPeers.difference(prevPeers)) {
        if (pid != uid) {
          var name = (event['peers'] as List<dynamic>)
              .firstWhere((p) => p['id'] == pid, orElse: () => ({'name': pid}))['name'] as String? ?? pid;
          _addSystemMessage('$name ${t.joinedMeeting}');
        }
      }
      for (var pid in prevPeers.difference(newPeers)) {
        if (pid != uid) {
          _addSystemMessage('${pid} ${t.leftMeeting}');
        }
      }
      prevPeers
        ..clear()
        ..addAll(newPeers);
      peers = event['peers'];
      notifyListeners();
    };
    signaling!.onLocalStream = (stream) {
      L.d('[RTC] local stream opened');
      localRenderer.srcObject = stream;
    };
    signaling!.onAddRemoteStream = (session, stream) {
      L.d('[RTC] add remote stream from ${session.pid}');
      var renderer = _getOrCreateRenderer(session.pid);
      renderer.srcObject = stream;
      notifyListeners();
    };
    signaling!.onRemoveRemoteStream = (session, stream) {
      L.d('[RTC] remove remote stream from ${session.pid}');
      var renderer = remoteRenderers.remove(session.pid);
      if (renderer != null) {
        renderer.srcObject = null;
        renderer.dispose();
      }
      notifyListeners();
    };
    signaling!.onReconnect = () {
      L.d('[RTC] signaling reconnected');
      if (session != null && inCalling) {
        signaling!.createOffer(session!, 'video', iceRestart: true);
      }
    };

    signaling!.onChatMessage = (data) {
      var msg = ChatMessage.fromJson(data);
      if (msg.from == uid) return;
      chatMessages.add(msg);
      if (!chatOpen) chatUnread++;
      notifyListeners();
    };

    refreshDevices();
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

  void _addSystemMessage(String text) {
    chatMessages.add(ChatMessage(
      type: 'system',
      text: text,
      ts: DateTime.now().millisecondsSinceEpoch,
    ));
    if (!chatOpen) chatUnread++;
    notifyListeners();
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

  invitePeer(BuildContext context, String peerId, bool useScreen) {
    if (signaling != null && peerId != uid) {
      signaling?.invite(peerId, 'video', useScreen);
    }
  }

  hangUp() {
    if (session != null) {
      signaling?.bye(session!.sid);
    }
  }

  Future<bool> showAcceptDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AcceptDialog(
        onAccept: () => Navigator.of(context).pop(true),
        onReject: () => Navigator.of(context).pop(false),
      ),
    ).then((v) => v ?? false);
  }

  Future<void> showInviteDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _InviteDialog(
        onCancel: () {
          Navigator.of(context).pop();
          hangUp();
        },
      ),
    );
  }

  @override
  void dispose() {
    for (var r in remoteRenderers.values) {
      r.dispose();
    }
    remoteRenderers.clear();
    localRenderer.dispose();
    signaling?.close();
    super.dispose();
  }
}

class _AcceptDialog extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _AcceptDialog({
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return AlertDialog(
      title: Text(
        '${t.incomingCall}...',
        style: tt.titleMedium,
      ),
      content: Text(t.acceptCall),
      actions: [
        TextButton(
          onPressed: onReject,
          child: Text(
            t.rejectCall,
            style: tt.bodyMedium?.copyWith(color: cs.error),
          ),
        ),
        TextButton(
          onPressed: onAccept,
          child: Text(
            t.acceptCall,
            style: tt.bodyMedium?.copyWith(color: cs.primary),
          ),
        ),
      ],
    );
  }
}

class _InviteDialog extends StatelessWidget {
  final VoidCallback onCancel;

  const _InviteDialog({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AlertDialog(
      title: Text(t.callConnecting, style: tt.titleMedium),
      content: Text(t.waitingAcceptVideoCall),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(t.cancel),
        ),
      ],
    );
  }
}
