import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:async';

import 'package:buzzing/controller/app_controller.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/utils/net/apis.dart';
import 'package:buzzing/utils/net/http_util.dart';
import 'package:buzzing/models/login_certificate.dart';
import 'package:buzzing/utils/data_persistence.dart';
import 'package:buzzing/utils/loogger_util.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/utils/random_string.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/widget/im_widget.dart';
import 'package:buzzing/widget/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:flutter_macos_permissions/flutter_macos_permissions.dart';


class MeetingLogic extends ChangeNotifier {
  var inCalling = false;
  Signaling? signaling;
  String uid = randomNumeric(6);
  List<dynamic> peers = [];
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  Session? session;
  DesktopCapturerSource? selectedSource;
  bool waitAccept = false;
  final AppController app;
  MeetingLogic({required this.app});

  void init() {
    initRenderers();
  }

  void createMeeting() {
    app.createWindow("VcWindow", true, true, {});
  }

  void joinMeeting() {}

  void initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  void switchCamera() {
    signaling?.switchCamera();
  }

  void connect(BuildContext context) async {
    signaling ??= Signaling(context, uid: uid)..connect();
    signaling?.onSignalingStateChange = (SignalingState state) {
      L.d("[RTC] signaling state changed: $state");
      switch (state) {
        case SignalingState.ConnectionClosed:
          signaling = null;
          break;
        case SignalingState.ConnectionError:
        case SignalingState.ConnectionOpen:
          break;
      }
    };

    signaling?.onCallStateChange = (Session newSession, CallState state) async {
      L.d("[RTC] call state change: ${newSession}, $state");
      switch (state) {
        case CallState.CallStateNew:
          session = newSession;
          break;
        case CallState.CallStateRinging:
          bool? acc = await showAcceptDialog(context);
          if (acc!) {
            accept();
            inCalling = true;
            notifyListeners();
          } else {
            reject();
          }
          break;
        case CallState.CallStateBye:
          if (waitAccept) {
            L.d("peer reject");
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

    signaling?.onPeerUpdate = ((event) {
      L.d("[RTC] peer update: $event");
      uid = event['self'];
      peers = event['peers'];
    });
    signaling?.onLocalStream = ((stream) {
      L.d("[RTC] local stream opened");
      localRenderer.srcObject = stream;
    });
    signaling?.onAddRemoteStream = ((_, stream) {
      L.d("[RTC] add remote stream");
      remoteRenderer.srcObject = stream;
    });
    signaling?.onRemoveRemoteStream = ((_, stream) {
      L.d("[RTC] remove remote stream");
      remoteRenderer.srcObject = null;
    });
  }

  Future<bool?> showAcceptDialog(BuildContext context) {
    return showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("title"),
          content: Text("accept?"),
          actions: <Widget>[
            MaterialButton(
              child: Text("Reject", style: PageStyle.ts_F44038_13sp),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            MaterialButton(
              child: Text("Accept", style: PageStyle.ts_898989_13sp),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> showInviteDialog(BuildContext context) {
    return showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("title"),
          content: Text("waiting"),
          actions: <Widget>[
            TextButton(
              child: Text("cancel"),
              onPressed: () {
                Navigator.of(context).pop(false);
                hangUp();
              },
            ),
          ],
        );
      },
    );
  }

  invitePeer(BuildContext context, String peerId, bool useScreen) async {
    if (signaling != null && peerId != uid) {
      signaling?.invite(peerId, "video", useScreen);
    }
  }

  accept() {
    if (session != null) {
      signaling?.accept(session!.sid, "video");
    }
  }

  reject() {
    if (session != null) {
      signaling?.reject(session!.sid);
    }
  }

  hangUp() {
    if (session != null) {
      signaling?.bye(session!.sid);
    }
  }

  Future<void> selectScreenSourceDialog(BuildContext context) async {}

  muteMic() {}

  buildRow(context, peer) {}
}

enum SignalingState { ConnectionOpen, ConnectionClosed, ConnectionError }

enum CallState {
  CallStateNew,
  CallStateRinging,
  CallStateInvite,
  CallStateConnected,
  CallStateBye,
}

enum VideoSource { Camera, Screen }

class Session {
  Session({required this.sid, required this.pid});

  String pid;
  String sid;
  RTCPeerConnection? pc;
  RTCDataChannel? dc;
  List<RTCIceCandidate> remoteCandidates = [];
}

class Signaling {
  Signaling(this.context, {required String uid}) : uid = uid;

  JsonEncoder encoder = JsonEncoder();
  JsonDecoder decoder = JsonDecoder();
  late String uid;
  SimpleWebSocket? socket;
  BuildContext? context;
  String host = "www.buzzing-im.com";
  var port = 5150;
  var turnCredential;
  Map<String, Session> sessions = {};
  MediaStream? localStream;
  List<MediaStream> remoteStreams = <MediaStream>[];
  List<RTCRtpSender> senders = <RTCRtpSender>[];
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

  Map<String, dynamic> iceServers = {
    "iceServers": [
      {"url": "stun:stun.l.google.com:19302"},
    ],
  };
  final Map<String, dynamic> config = {
    "mandatory": {},
    "optional": [
      {"DtlsSrtpKeyAgreement": true},
    ],
  };
  final Map<String, dynamic> dcConstraints = {
    "mandatory": {"OfferToReceiveAudio": false, "OfferToReceiveVideo": false},
    "optional": [],
  };

  close() async {
    L.d("RTC close");
    await cleanSessions();
    socket?.close();
  }

  void switchCamera() {
    L.d("RTC switch carema");
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
    L.d("RTC switch ot screen sharing");
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
    L.d("RTC mute mic");
    if (localStream != null) {
      bool enabled = localStream!.getAudioTracks()[0].enabled;
      localStream!.getAudioTracks()[0].enabled = !enabled;
    }
  }

  void invite(String peerId, String media, bool useScreen) async {
    L.d("RTC invite, $peerId, $media, $useScreen");
    var sessionId = uid + '-' + peerId;
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
    L.d("RTC send bye");
    send('bye', {'session_id': sessionId, 'from': uid});
    var sess = sessions[sessionId];
    if (sess != null) {
      closeSession(sess);
    }
  }

  void accept(String sessionId, String media) {
    L.d("RTC accept session, $sessionId, $media");
    var session = sessions[sessionId];
    if (session == null) {
      return;
    }
    createAnswer(session, media);
  }

  void reject(String sessionId) {
    L.d("RTC reject session, $sessionId");
    var session = sessions[sessionId];
    if (session == null) {
      return;
    }
    bye(session.sid);
  }

  void onMessage(message) async {
    Map<String, dynamic> mapData = message;
    L.d("RTC receive message, $mapData");
    var data = mapData['data'];
    L.d("message type: ${mapData['type']}");
    switch (mapData['type'] as String) {
      case 'peers':
        {
          List<dynamic> peers = data;
          if (onPeerUpdate != null) {
            Map<String, dynamic> event = Map<String, dynamic>();
            event['self'] = uid;
            event['peers'] = peers;
            onPeerUpdate?.call(event);
          }
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
          L.d("prepare for new session: $newSession");
          await newSession.pc!.setRemoteDescription(
            RTCSessionDescription(description['sdp'], description['type']),
          );

          if (newSession.remoteCandidates.length > 0) {
            newSession.remoteCandidates.forEach((candidate) async {
              await newSession.pc?.addCandidate(candidate);
            });
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
          session?.pc?.setRemoteDescription(
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
          RTCIceCandidate candidate = RTCIceCandidate(
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
        {
          var peerId = data as String;
          clossSessionByPeerId(peerId);
        }
        break;
      case 'bye':
        {
          var sessionId = data['session_id'];
          L.d("meeting bye: $sessionId");
          var session = sessions.remove(sessionId);
          if (session != null) {
            onCallStateChange?.call(session, CallState.CallStateBye);
            closeSession(session);
          }
        }
        break;
      case 'keepalive':
        {
          L.d("meeting conn keepalive response");
        }
        break;
      default:
        break;
    }
  }

  Future<void> connect() async {
    var url = 'https://$host:$port/ws';
    socket = SimpleWebSocket(url);
    L.d("connect to url: $url");

    if (turnCredential == null) {
      try {
        turnCredential = await getTurnCredential(host, port);
        iceServers = {
          'iceServers': [
            {
              'urls': turnCredential['uris'][0],
              'username': turnCredential['username'],
              'credential': turnCredential['password'],
            },
          ],
        };
      } catch (e) {}
    }

    socket?.onOpen = () {
      L.d("meeting connect on open");
      onSignalingStateChange?.call(SignalingState.ConnectionOpen);
      send('new', {
        'name': DeviceInfo.label,
        'id': uid,
        'user_agent': DeviceInfo.userAgent,
      });
    };
    socket?.onMessage = (message) {
      L.d("meeting received data: " + message);
      onMessage(decoder.convert(message));
    };
    socket?.onClose = (int? code, String? reason) {
      L.d("meeting conn closed by server, [$code => $reason]");
      onSignalingStateChange?.call(SignalingState.ConnectionClosed);
    };
    await socket?.connect();
  }

  Future<MediaStream> createStream(
    String media,
    bool userScreen, {
    BuildContext? context,
  }) async {
    var granted = await FlutterMacosPermissions.requestCamera();
    L.d("camera permission: $granted");
    var devices = await rtc.navigator.mediaDevices.enumerateDevices();
    for (var d in devices) {
      L.d("RTC device: ${d.label}, ${d.deviceId}, ${d.kind}");
    }
    final Map<String, dynamic> mediaContraints = {
      "video": {
        'mandatory': {
          'minWidth':
              '640', // Provide your own width, height and frame rate here
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      },
    };
    late MediaStream stream;
    /*
      if(userScreen) {
        if(WebRTC.platformIsDesktop) {
          final source = await showDialog<DesktopCapturerSource>(context: context!, builder: (context) => SceenSelectDialog(),);
          stream = await rtc.navigator.mediaDevices.getDisplayMedia(<String, dynamic> {
            'video' : source == null ? true : {'deviceId': {'exact': source.id}, 'mandatory': {'frameRate': 30.0}}
          });
        }else {
          stream = await rtc.navigator.mediaDevices.getUserMedia(mediaContraints);
        }

      } else {
        stream = await rtc.navigator.mediaDevices.getUserMedia(mediaContraints);
      }
      */

    stream = await rtc.navigator.mediaDevices.getUserMedia(mediaContraints);
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
    L.d("create session, ice server: $iceServers");
    RTCPeerConnection pc = await createPeerConnection({
      ...iceServers,
      ...{'sdpSemantics': sdpSemantics},
    }, config);
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
      if (candidate == null) {
        L.d("create session, on ice candidate: complete!");
        return;
      }
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
      remoteStreams.removeWhere((it) {
        return (it.id == stream.id);
      });
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
      L.d("create offer error: $e");
    }
  }

  RTCSessionDescription fixSdp(RTCSessionDescription s) {
    var sdp = s.sdp;
    s.sdp = sdp!.replaceAll(
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
      L.d("create answer error: $e");
    }
  }

  send(event, data) {
    var request = Map();
    request['type'] = event;
    request['data'] = data;
    socket?.send(encoder.convert(request));
  }

  Future<void> cleanSessions() async {
    if (localStream != null) {
      localStream!.getTracks().forEach((element) async {
        await element.stop();
      });
      await localStream!.dispose();
      localStream = null;
    }
    sessions.forEach((key, sess) async {
      await sess.pc?.close();
      await sess.dc?.close();
    });
    sessions.clear();
  }

  void clossSessionByPeerId(String peerId) {
    var session;
    sessions.removeWhere((String key, Session sess) {
      var ids = key.split('_');
      session = sess;
      return peerId == ids[0] || peerId == ids[1];
    });
    if (session != null) {
      closeSession(session);
      onCallStateChange?.call(session, CallState.CallStateBye);
    }
  }

  void closeSession(Session session) async {
    localStream?.getTracks().forEach((element) async {
      await element.stop();
    });
    await localStream?.dispose();
    localStream = null;

    await session.pc?.close();
    await session.dc?.close();
    senders.clear();
    videoSource = VideoSource.Camera;
  }
}

class DeviceInfo {
  static String get label {
    return 'Flutter ' +
        Platform.operatingSystem +
        '(' +
        Platform.localHostname +
        ')';
  }

  static String get userAgent {
    return 'fluter-webrtc/' + Platform.operatingSystem + '-plugin 0.0.1';
  }
}

class SimpleWebSocket {
  String _url;
  var _socket;
  Function()? onOpen;
  Function(dynamic msg)? onMessage;
  Function(int? code, String? reaso)? onClose;
  SimpleWebSocket(this._url);

  connect() async {
    try {
      //_socket = await WebSocket.connect(_url);
      _socket = await _connectForSelfSignedCert(_url);
      onOpen?.call();
      _socket.listen(
        (data) {
          onMessage?.call(data);
        },
        onDone: () {
          onClose?.call(_socket.closeCode, _socket.closeReason);
        },
      );
    } catch (e) {
      onClose?.call(500, e.toString());
    }
  }

  send(data) {
    if (_socket != null) {
      _socket.add(data);
      print('send: $data');
    }
  }

  close() {
    if (_socket != null) _socket.close();
  }

  Future<WebSocket> _connectForSelfSignedCert(url) async {
    try {
      Random r = new Random();
      String key = base64.encode(List<int>.generate(8, (_) => r.nextInt(255)));
      HttpClient client = HttpClient(context: SecurityContext());
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
            print(
              'SimpleWebSocket: Allow self-signed certificate => $host:$port. ',
            );
            return true;
          };

      HttpClientRequest request = await client.getUrl(
        Uri.parse(url),
      ); // form the correct url here
      request.headers.add('Connection', 'Upgrade');
      request.headers.add('Upgrade', 'websocket');
      request.headers.add(
        'Sec-WebSocket-Version',
        '13',
      ); // insert the correct version here
      request.headers.add('Sec-WebSocket-Key', key.toLowerCase());

      HttpClientResponse response = await request.close();
      // ignore: close_sinks
      Socket socket = await response.detachSocket();
      var webSocket = WebSocket.fromUpgradedSocket(
        socket,
        protocol: 'signaling',
        serverSide: false,
      );

      return webSocket;
    } catch (e) {
      throw e;
    }
  }
}

Future<Map> getTurnCredential(String host, int port) async {
  HttpClient client = HttpClient(context: SecurityContext());
  client
      .badCertificateCallback = (X509Certificate cert, String host, int port) {
    print('getTurnCredential: Allow self-signed certificate => $host:$port. ');
    return true;
  };
  var url = 'https://$host:$port/api/turn?service=turn&username=flutter-webrtc';
  var request = await client.getUrl(Uri.parse(url));
  var response = await request.close();
  var responseBody = await response.transform(Utf8Decoder()).join();
  print('getTurnCredential:response => $responseBody.');
  Map data = JsonDecoder().convert(responseBody);
  return data;
}
