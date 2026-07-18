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
  final String token;
  Map<String, dynamic> iceServers;

  SignalingConfig({
    this.host = 'www.buzzing-im.com',
    this.port = 5150,
    required this.token,
    Map<String, dynamic>? iceServers,
  }) : iceServers = iceServers ?? {
          'iceServers': [
            {'url': 'stun:stun.l.google.com:19302'},
          ],
        };
}

class Signaling {
  Signaling(this.context, {required String uid, required String token})
      : uid = uid,
        config = SignalingConfig(token: token);

  final JsonEncoder encoder = JsonEncoder();
  final JsonDecoder decoder = JsonDecoder();
  late String uid;
  SimpleWebSocket? socket;
  BuildContext? context;

  late SignalingConfig config;
  var turnCredential;
  final Map<String, Session> sessions = {};
  MediaStream? localStream;
  final List<MediaStream> remoteStreams = <MediaStream>[];
  final List<RTCRtpSender> senders = <RTCRtpSender>[];
  VideoSource videoSource = VideoSource.Camera;

  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _keepaliveTimer;
  Timer? _keepaliveTimeout;
  bool _intentionalClose = false;
  bool _connected = false;

  Function(SignalingState state)? onSignalingStateChange;
  Function(Session session, CallState state)? onCallStateChange;
  Function(MediaStream stream)? onLocalStream;
  Function(Session session, MediaStream stream)? onAddRemoteStream;
  Function(Session session, MediaStream stream)? onRemoveRemoteStream;
  Function(dynamic event)? onPeerUpdate;
  Function(Session session, RTCDataChannel dc, RTCDataChannelMessage data)?
      onDataChannelMessage;
  Function(Session session, RTCDataChannel dc)? onDataChannel;
  Function()? onReconnect;

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
    _intentionalClose = true;
    _stopReconnect();
    _stopKeepalive();
    await cleanSessions();
    socket?.close();
    socket = null;
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

  Future<void> startScreenSharing() async {
    if (videoSource == VideoSource.Screen) return;
    L.d('RTC start screen sharing');
    try {
      final stream = await rtc.navigator.mediaDevices.getDisplayMedia({
        'video': {
          'mandatory': {'minWidth': '1280', 'minHeight': '720'},
        },
        'audio': false,
      });
      if (localStream != null && stream.getVideoTracks().isNotEmpty) {
        for (final sender in senders) {
          if (sender.track?.kind == 'video') {
            await sender.replaceTrack(stream.getVideoTracks()[0]);
          }
        }
        stream.getVideoTracks()[0].onEnded = () {
          L.d('screen sharing stopped by system');
          stopScreenSharing();
        };
        videoSource = VideoSource.Screen;
        onLocalStream?.call(stream);
      }
    } catch (e) {
      L.d('start screen sharing error: $e');
    }
  }

  Future<void> stopScreenSharing() async {
    if (videoSource != VideoSource.Screen) return;
    L.d('RTC stop screen sharing');
    if (localStream != null) {
      final cameraStream = await _createCameraStream();
      for (final sender in senders) {
        if (sender.track?.kind == 'video' && cameraStream.getVideoTracks().isNotEmpty) {
          await sender.replaceTrack(cameraStream.getVideoTracks()[0]);
        }
      }
      videoSource = VideoSource.Camera;
      onLocalStream?.call(cameraStream);
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
        _keepaliveTimeout?.cancel();
        break;
    }
  }

  Future<void> connect() async {
    _intentionalClose = false;
    _reconnectAttempts = 0;
    _stopReconnect();

    var url = 'https://${config.host}:${config.port}/ws';
    socket?.close();
    socket = SimpleWebSocket(url);
    L.d('connect to url: $url');

    if (turnCredential == null) {
      try {
        turnCredential = await getTurnCredential(config.host, config.port, token: config.token);
        if (turnCredential['urls'] != null) {
          config.iceServers = {
            'iceServers': [
              {
                'urls': turnCredential['urls'][0],
                'username': turnCredential['username'],
                'credential': turnCredential['credential'],
              },
            ],
          };
        }
      } catch (_) {}
    }

    socket?.onOpen = () {
      L.d('meeting connect on open');
      _connected = true;
      _reconnectAttempts = 0;
      onSignalingStateChange?.call(SignalingState.ConnectionOpen);
      send('new', {
        'token': config.token,
        'name': DeviceInfo.label,
        'user_agent': DeviceInfo.userAgent,
      });
      _startKeepalive();
    };
    socket?.onMessage = (message) {
      L.d('meeting received data: $message');
      onMessage(decoder.convert(message));
    };
    socket?.onClose = (int? code, String? reason) {
      L.d('meeting conn closed by server, [$code => $reason]');
      _connected = false;
      _stopKeepalive();
      onSignalingStateChange?.call(SignalingState.ConnectionClosed);
      if (!_intentionalClose) {
        _reconnect();
      }
    };
    await socket?.connect();
  }

  void _reconnect() {
    if (_intentionalClose) return;
    _stopReconnect();
    final delay = _reconnectDelay();
    _reconnectAttempts++;
    L.d('reconnect attempt $_reconnectAttempts in ${delay}ms');
    _reconnectTimer = Timer(Duration(milliseconds: delay), () {
      onSignalingStateChange?.call(SignalingState.ConnectionError);
      connect();
    });
  }

  int _reconnectDelay() {
    const maxDelay = 16000;
    int delay = 1000;
    for (int i = 1; i < _reconnectAttempts; i++) {
      delay *= 2;
    }
    return delay > maxDelay ? maxDelay : delay;
  }

  void _stopReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _startKeepalive() {
    _stopKeepalive();
    _keepaliveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_connected) return;
      send('keepalive', {});
      _keepaliveTimeout?.cancel();
      _keepaliveTimeout = Timer(const Duration(seconds: 5), () {
        L.d('keepalive timeout, triggering reconnect');
        _connected = false;
        socket?.close();
      });
    });
  }

  void _stopKeepalive() {
    _keepaliveTimer?.cancel();
    _keepaliveTimer = null;
    _keepaliveTimeout?.cancel();
    _keepaliveTimeout = null;
  }

  void _setupSimulcastEncodings(RTCRtpSender sender) async {
    try {
      final params = sender.parameters;
      params.encodings = [
        RTCRtpEncoding(
          rid: 'q',
          active: true,
          scaleResolutionDownBy: 4.0,
          maxBitrate: 100000,
        ),
        RTCRtpEncoding(
          rid: 'h',
          active: true,
          scaleResolutionDownBy: 2.0,
          maxBitrate: 500000,
        ),
        RTCRtpEncoding(
          rid: 'f',
          active: true,
          scaleResolutionDownBy: 1.0,
          maxBitrate: 1500000,
        ),
      ];
      await sender.setParameters(params);
      L.d('simulcast encodings set up');
    } catch (e) {
      L.d('simulcast setup error (non-fatal): $e');
    }
  }

  void _onIceConnectionState(RTCIceConnectionState state, Session session) async {
    L.d('ICE connection state: $state');
    if (!senders.any((s) => s.track?.kind == 'video')) return;
    try {
      final videoSender = senders.firstWhere((s) => s.track?.kind == 'video');
      final params = videoSender.parameters;
      final encodings = params.encodings;
      if (encodings == null || encodings.isEmpty) return;
      switch (state) {
        case RTCIceConnectionState.RTCIceConnectionStateConnected:
        case RTCIceConnectionState.RTCIceConnectionStateCompleted:
          for (final e in encodings) {
            e.active = true;
          }
          break;
        case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
        case RTCIceConnectionState.RTCIceConnectionStateFailed:
          for (final e in encodings) {
            e.active = false;
          }
          break;
        default:
          break;
      }
      await videoSender.setParameters(params);
    } catch (e) {
      L.d('BWE update error: $e');
    }
  }

  Future<MediaStream> createStream(
    String media,
    bool userScreen, {
    BuildContext? context,
  }) async {
    if (userScreen) {
      final stream = await rtc.navigator.mediaDevices.getDisplayMedia({
        'video': {
          'mandatory': {'minWidth': '1280', 'minHeight': '720'},
        },
        'audio': false,
      });
      onLocalStream?.call(stream);
      return stream;
    }
    return _createCameraStream();
  }

  Future<MediaStream> _createCameraStream() async {
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
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
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
            final sender = await pc.addTrack(track, localStream!);
            senders.add(sender);
            if (track.kind == 'video') {
              _setupSimulcastEncodings(sender);
            }
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

    pc.onIceConnectionState = (state) {
      _onIceConnectionState(state, newSession);
    };
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

  Future<void> createOffer(Session session, String media,
      {bool iceRestart = false}) async {
    try {
      final constraints = Map<String, dynamic>.from(
          media == 'data' ? dcConstraints : {});
      if (iceRestart) {
        constraints['iceRestart'] = true;
      }
      RTCSessionDescription s = await session.pc!.createOffer(constraints);
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

Future<Map> getTurnCredential(String host, int port, {String? token}) async {
  HttpClient client = HttpClient(context: SecurityContext());
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) {
    L.d('getTurnCredential: Allow self-signed certificate => $host:$port.');
    return true;
  };
  var queryParams = 'token=$token';
  var url = 'https://$host:$port/api/turn?$queryParams';
  var request = await client.getUrl(Uri.parse(url));
  var response = await request.close();
  var responseBody = await response.transform(Utf8Decoder()).join();
  L.d('getTurnCredential:response => $responseBody.');
  return JsonDecoder().convert(responseBody);
}
