import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:buzzing/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_macos_permissions/flutter_macos_permissions.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;

import 'device_info.dart';
import 'session.dart';
import 'simple_ws.dart';

enum SignalingState { ConnectionOpen, ConnectionClosed, ConnectionError }

enum CallState {
  CallStateNew,
  CallStateRinging,
  CallStateInvite,
  CallStateConnected,
  CallStateBye,
}

enum VideoSource { Camera, Screen }

class SignalingConfig {
  final String host;
  final int port;
  Map<String, dynamic> iceServers;

  SignalingConfig({
    this.host = 'www.buzzing-im.com',
    this.port = 5150,
    Map<String, dynamic>? iceServers,
  }) : iceServers = iceServers ?? {
          'iceServers': [
            {'url': 'stun:stun.l.google.com:19302'},
          ],
        };
}

class Signaling {
  Signaling(this.context, {required String uid}) : uid = uid;

  final JsonEncoder encoder = JsonEncoder();
  final JsonDecoder decoder = JsonDecoder();
  late String uid;
  SimpleWebSocket? socket;
  BuildContext? context;

  var config = SignalingConfig();
  var turnCredential;
  final Map<String, Session> sessions = {};
  MediaStream? localStream;
  final List<MediaStream> remoteStreams = <MediaStream>[];
  final List<RTCRtpSender> senders = <RTCRtpSender>[];
  VideoSource videoSource = VideoSource.Camera;

  Function(SignalingState state)? onSignalingStateChange;
  Function(Session session, CallState state)? onCallStateChange;
  Function(MediaStream stream)? onLocalStream;
  Function(Session session, MediaStream stream)? onAddRemoteStream;
  Function(Session session, MediaStream stream)? onRemoveRemoteStream;
  Function(dynamic event)? onPeerUpdate;
  Function(Session session, RTCDataChannel dc, RTCDataChannelMessage data)?
      onDataChannelMessage;
  Function(Session session, RTCDataChannel dc)? onDataChannel;

  String get sdpSemantics => 'unified-plan';

  static const Map<String, dynamic> peerConfig = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  static const Map<String, dynamic> dcConstraints = {
    'mandatory': {'OfferToReceiveAudio': false, 'OfferToReceiveVideo': false},
    'optional': [],
  };

  close() async {
    L.d('RTC close');
    await cleanSessions();
    socket?.close();
  }

  void switchCamera() {
    L.d('RTC switch camera');
    if (localStream != null) {
      if (videoSource != VideoSource.Camera) {
        senders.forEach((sender) {});
        videoSource = VideoSource.Camera;
        onLocalStream?.call(localStream!);
      } else {
        Helper.switchCamera(localStream!.getVideoTracks()[0]);
      }
    }
  }

  void switchToScreenSharing(MediaStream stream) {
    L.d('RTC switch to screen sharing');
    if (localStream != null && videoSource != VideoSource.Screen) {
      senders.forEach((sender) {
        if (sender.track!.kind == 'video') {
          sender.replaceTrack(stream.getVideoTracks()[0]);
        }
      });
      onLocalStream?.call(stream);
      videoSource = VideoSource.Screen;
    }
  }

  void muteMic() {
    L.d('RTC mute mic');
    if (localStream != null) {
      final enabled = localStream!.getAudioTracks()[0].enabled;
      localStream!.getAudioTracks()[0].enabled = !enabled;
    }
  }

  void invite(String peerId, String media, bool useScreen) async {
    L.d('RTC invite, $peerId, $media, $useScreen');
    var sessionId = '$uid-$peerId';
    Session session = await createSession(
      null,
      peerId: peerId,
      sessionId: sessionId,
      media: media,
      screenSharing: useScreen,
    );
    sessions[sessionId] = session;
    if (media == 'data') {
      createDataChannel(session);
    }
    createOffer(session, media);
    onCallStateChange?.call(session, CallState.CallStateNew);
    onCallStateChange?.call(session, CallState.CallStateInvite);
  }

  void bye(String sessionId) {
    L.d('RTC send bye');
    send('bye', {'session_id': sessionId, 'from': uid});
    var sess = sessions[sessionId];
    if (sess != null) {
      closeSession(sess);
    }
  }

  void accept(String sessionId, String media) {
    L.d('RTC accept session, $sessionId, $media');
    var session = sessions[sessionId];
    if (session == null) return;
    createAnswer(session, media);
  }

  void reject(String sessionId) {
    L.d('RTC reject session, $sessionId');
    var session = sessions[sessionId];
    if (session == null) return;
    bye(session.sid);
  }

  void onMessage(message) async {
    Map<String, dynamic> mapData = message;
    L.d('RTC receive message, $mapData');
    var data = mapData['data'];
    switch (mapData['type'] as String) {
      case 'peers':
        final List<dynamic> peers = data;
        if (onPeerUpdate != null) {
          onPeerUpdate?.call({'self': uid, 'peers': peers});
        }
        break;
      case 'offer':
        {
          var peerId = data['from'];
          var description = data['description'];
          var media = data['media'];
          var sessionId = data['session_id'];
          var session = sessions[sessionId];
          var newSession = await createSession(
            session,
            peerId: peerId,
            sessionId: sessionId,
            media: media,
            screenSharing: false,
          );
          sessions[sessionId] = newSession;
          L.d('prepare for new session: $newSession');
          await newSession.pc!.setRemoteDescription(
            RTCSessionDescription(description['sdp'], description['type']),
          );
          if (newSession.remoteCandidates.isNotEmpty) {
            for (var candidate in newSession.remoteCandidates) {
              await newSession.pc?.addCandidate(candidate);
            }
            newSession.remoteCandidates.clear();
          }
          onCallStateChange?.call(newSession, CallState.CallStateNew);
          onCallStateChange?.call(newSession, CallState.CallStateRinging);
        }
        break;
      case 'answer':
        {
          var description = data['description'];
          var sessionId = data['session_id'];
          var session = sessions[sessionId];
          await session?.pc?.setRemoteDescription(
            RTCSessionDescription(description['sdp'], description['type']),
          );
          onCallStateChange?.call(session!, CallState.CallStateConnected);
        }
        break;
      case 'candidate':
        {
          var peerId = data['from'];
          var candidateMap = data['candidate'];
          var sessionId = data['session_id'];
          var session = sessions[sessionId];
          var candidate = RTCIceCandidate(
            candidateMap['candidate'],
            candidateMap['sdpMid'],
            candidateMap['sdpMLineIndex'],
          );
          if (session != null) {
            if (session.pc != null) {
              await session.pc?.addCandidate(candidate);
            } else {
              session.remoteCandidates.add(candidate);
            }
          } else {
            sessions[sessionId] = Session(pid: peerId, sid: sessionId)
              ..remoteCandidates.add(candidate);
          }
        }
        break;
      case 'leave':
        clossSessionByPeerId(data as String);
        break;
      case 'bye':
        {
          var sessionId = data['session_id'];
          L.d('meeting bye: $sessionId');
          var session = sessions.remove(sessionId);
          if (session != null) {
            onCallStateChange?.call(session, CallState.CallStateBye);
            closeSession(session);
          }
        }
        break;
      case 'keepalive':
        L.d('meeting conn keepalive response');
        break;
    }
  }

  Future<void> connect() async {
    var url = 'https://${config.host}:${config.port}/ws';
    socket = SimpleWebSocket(url);
    L.d('connect to url: $url');

    if (turnCredential == null) {
      try {
        turnCredential = await getTurnCredential(config.host, config.port);
        config.iceServers = {
          'iceServers': [
            {
              'urls': turnCredential['uris'][0],
              'username': turnCredential['username'],
              'credential': turnCredential['password'],
            },
          ],
        };
      } catch (_) {}
    }

    socket?.onOpen = () {
      L.d('meeting connect on open');
      onSignalingStateChange?.call(SignalingState.ConnectionOpen);
      send('new', {
        'name': DeviceInfo.label,
        'id': uid,
        'user_agent': DeviceInfo.userAgent,
      });
    };
    socket?.onMessage = (message) {
      L.d('meeting received data: $message');
      onMessage(decoder.convert(message));
    };
    socket?.onClose = (int? code, String? reason) {
      L.d('meeting conn closed by server, [$code => $reason]');
      onSignalingStateChange?.call(SignalingState.ConnectionClosed);
    };
    await socket?.connect();
  }

  Future<MediaStream> createStream(
    String media,
    bool userScreen, {
    BuildContext? context,
  }) async {
    await FlutterMacosPermissions.requestCamera();
    var devices = await rtc.navigator.mediaDevices.enumerateDevices();
    for (var d in devices) {
      L.d('RTC device: ${d.label}, ${d.deviceId}, ${d.kind}');
    }
    final Map<String, dynamic> mediaContraints = {
      'video': {
        'mandatory': {
          'minWidth': '640',
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      },
    };
    var stream = await rtc.navigator.mediaDevices.getUserMedia(mediaContraints);
    onLocalStream?.call(stream);
    return stream;
  }

  Future<Session> createSession(
    Session? session, {
    required String peerId,
    required String sessionId,
    required String media,
    required bool screenSharing,
  }) async {
    var newSession = session ?? Session(sid: sessionId, pid: peerId);
    if (media != 'data') {
      localStream = await createStream(media, screenSharing, context: context);
    }
    L.d('create session, ice server: ${config.iceServers}');
    RTCPeerConnection pc = await createPeerConnection({
      ...config.iceServers,
      ...{'sdpSemantics': sdpSemantics},
    }, peerConfig);
    if (media != 'data') {
      switch (sdpSemantics) {
        case 'plan-b':
          pc.onAddStream = (MediaStream stream) {
            onAddRemoteStream?.call(newSession, stream);
            remoteStreams.add(stream);
          };
          await pc.addStream(localStream!);
          break;
        case 'unified-plan':
          pc.onTrack = (event) {
            if (event.track.kind == 'video') {
              onAddRemoteStream?.call(newSession, event.streams[0]);
            }
          };
          localStream!.getTracks().forEach((track) async {
            senders.add(await pc.addTrack(track, localStream!));
          });
          break;
      }
    }

    pc.onIceCandidate = (candidate) async {
      await Future.delayed(
        const Duration(seconds: 1),
        () => send('candidate', {
          'to': peerId,
          'from': uid,
          'candidate': {
            'sdpMLineIndex': candidate.sdpMLineIndex,
            'sdpMid': candidate.sdpMid,
            'candidate': candidate.candidate,
          },
          'session_id': sessionId,
        }),
      );
    };

    pc.onIceConnectionState = (state) {};
    pc.onRemoveStream = (stream) {
      onRemoveRemoteStream?.call(newSession, stream);
      remoteStreams.removeWhere((it) => it.id == stream.id);
    };

    pc.onDataChannel = (channel) {
      addDataChannel(newSession, channel);
    };

    newSession.pc = pc;
    return newSession;
  }

  void addDataChannel(Session session, RTCDataChannel channel) {
    channel.onDataChannelState = (e) {};
    channel.onMessage = (RTCDataChannelMessage data) {
      onDataChannelMessage?.call(session, channel, data);
    };
    session.dc = channel;
    onDataChannel?.call(session, channel);
  }

  Future<void> createDataChannel(
    Session session, {
    label = 'fileTransfer',
  }) async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit()
      ..maxRetransmits = 30;
    RTCDataChannel channel = await session.pc!.createDataChannel(
      label,
      dataChannelDict,
    );
    addDataChannel(session, channel);
  }

  Future<void> createOffer(Session session, String media) async {
    try {
      RTCSessionDescription s = await session.pc!.createOffer(
        media == 'data' ? dcConstraints : {},
      );
      await session.pc!.setLocalDescription(fixSdp(s));
      send('offer', {
        'to': session.pid,
        'from': uid,
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': session.sid,
        'media': media,
      });
    } catch (e) {
      L.d('create offer error: $e');
    }
  }

  RTCSessionDescription fixSdp(RTCSessionDescription s) {
    s.sdp = s.sdp!.replaceAll(
      'profile-level-id=640c1f',
      'profile-level-id=42e032',
    );
    return s;
  }

  Future<void> createAnswer(Session session, String media) async {
    try {
      RTCSessionDescription s = await session.pc!.createAnswer(
        media == 'data' ? dcConstraints : {},
      );
      await session.pc!.setLocalDescription(fixSdp(s));
      send('answer', {
        'to': session.pid,
        'from': uid,
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': session.sid,
      });
    } catch (e) {
      L.d('create answer error: $e');
    }
  }

  send(event, data) {
    var request = <String, dynamic>{};
    request['type'] = event;
    request['data'] = data;
    socket?.send(encoder.convert(request));
  }

  Future<void> cleanSessions() async {
    if (localStream != null) {
      for (var element in localStream!.getTracks()) {
        await element.stop();
      }
      await localStream!.dispose();
      localStream = null;
    }
    for (var sess in sessions.values) {
      await sess.pc?.close();
      await sess.dc?.close();
    }
    sessions.clear();
  }

  void clossSessionByPeerId(String peerId) {
    Session? session;
    sessions.removeWhere((String key, Session sess) {
      var ids = key.split('_');
      session = sess;
      return peerId == ids[0] || peerId == ids[1];
    });
    if (session != null) {
      closeSession(session);
      onCallStateChange?.call(session!, CallState.CallStateBye);
    }
  }

  void closeSession(Session? session) async {
    if (session == null) return;
    for (var element in (localStream?.getTracks() ?? [])) {
      await element.stop();
    }
    await localStream?.dispose();
    localStream = null;

    await session.pc?.close();
    await session.dc?.close();
    senders.clear();
    videoSource = VideoSource.Camera;
  }
}

Future<Map> getTurnCredential(String host, int port) async {
  HttpClient client = HttpClient(context: SecurityContext());
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) {
    L.d('getTurnCredential: Allow self-signed certificate => $host:$port.');
    return true;
  };
  var url = 'https://$host:$port/api/turn?service=turn&username=flutter-webrtc';
  var request = await client.getUrl(Uri.parse(url));
  var response = await request.close();
  var responseBody = await response.transform(Utf8Decoder()).join();
  L.d('getTurnCredential:response => $responseBody.');
  return JsonDecoder().convert(responseBody);
}
