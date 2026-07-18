import 'package:buzzing/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../meeting/signaling/session.dart';
import '../meeting/signaling/signaling.dart';

class VcLogic extends ChangeNotifier {
  VcLogic({required this.token, String uid = ''}) : uid = uid;

  final String token;
  String uid;

  Signaling? signaling;
  var inCalling = false;
  Session? session;
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  Future<void> init() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  void connect() {
    signaling = Signaling(null, uid: uid, token: token);
    signaling!.connect();

    signaling!.onCallStateChange = (Session newSession, CallState state) {
      L.d('[VcLogic] call state change: ${newSession.sid}, $state');
      switch (state) {
        case CallState.CallStateNew:
          session = newSession;
          break;
        case CallState.CallStateRinging:
          signaling?.accept(session!.sid, 'video');
          inCalling = true;
          notifyListeners();
          break;
        case CallState.CallStateBye:
          localRenderer.srcObject = null;
          remoteRenderer.srcObject = null;
          inCalling = false;
          notifyListeners();
          session = null;
          break;
        case CallState.CallStateInvite:
          break;
        case CallState.CallStateConnected:
          inCalling = true;
          notifyListeners();
          break;
      }
    };

    signaling!.onLocalStream = (stream) {
      L.d('[VcLogic] local stream opened');
      localRenderer.srcObject = stream;
    };
    signaling!.onAddRemoteStream = (_, stream) {
      L.d('[VcLogic] add remote stream');
      remoteRenderer.srcObject = stream;
    };
    signaling!.onRemoveRemoteStream = (_, stream) {
      L.d('[VcLogic] remove remote stream');
      remoteRenderer.srcObject = null;
    };
    signaling!.onPeerUpdate = (event) {
      L.d('[VcLogic] peer update: $event');
      uid = event['self'];
    };
    signaling!.onReconnect = () {
      L.d('[VcLogic] signaling reconnected');
      if (session != null && inCalling) {
        signaling!.createOffer(session!, 'video', iceRestart: true);
      }
    };
  }

  void invite(String peerId) {
    signaling?.invite(peerId, 'video', false);
  }

  void hangUp() {
    if (session != null) {
      signaling?.bye(session!.sid);
    }
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
    signaling?.close();
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.dispose();
  }
}
