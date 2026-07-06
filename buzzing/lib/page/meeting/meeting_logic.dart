import 'dart:math';

import 'package:buzzing/controller/app_controller.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:buzzing/utils/random_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'signaling/session.dart';
import 'signaling/signaling.dart';

class MeetingLogic extends ChangeNotifier {
  var inCalling = false;
  Signaling? signaling;
  String uid = randomNumeric(6);
  List<dynamic> peers = [];
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  Session? session;
  bool waitAccept = false;
  final AppController app;

  MeetingLogic({required this.app});

  void init() {
    initRenderers();
  }

  void initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  void createMeeting() {
    app.createWindow('VcWindow', true, true, {});
  }

  void joinMeeting() {}

  void switchCamera() {
    signaling?.switchCamera();
  }

  void muteMic() {
    signaling?.muteMic();
  }

  void connect(BuildContext context) async {
    signaling ??= Signaling(context, uid: uid)..connect();
    signaling?.onSignalingStateChange = (SignalingState state) {
      L.d('[RTC] signaling state changed: $state');
      if (state == SignalingState.ConnectionClosed) {
        signaling = null;
      }
    };

    signaling?.onCallStateChange = (Session newSession, CallState state) async {
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
          remoteRenderer.srcObject = null;
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

    signaling?.onPeerUpdate = (event) {
      L.d('[RTC] peer update: $event');
      uid = event['self'];
      peers = event['peers'];
      notifyListeners();
    };
    signaling?.onLocalStream = (stream) {
      L.d('[RTC] local stream opened');
      localRenderer.srcObject = stream;
    };
    signaling?.onAddRemoteStream = (_, stream) {
      L.d('[RTC] add remote stream');
      remoteRenderer.srcObject = stream;
    };
    signaling?.onRemoveRemoteStream = (_, stream) {
      L.d('[RTC] remove remote stream');
      remoteRenderer.srcObject = null;
    };
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
