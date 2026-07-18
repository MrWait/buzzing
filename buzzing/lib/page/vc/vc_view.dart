import 'dart:async';
import 'dart:convert';

import 'package:buzzing/page/meeting/widgets/meeting_controls.dart';
import 'package:buzzing/utils/ext_window_controller.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:window_manager/window_manager.dart';

import '../meeting/signaling/signaling.dart';
import 'vc_logic.dart';

class VcWindow extends StatefulWidget {
  final WindowController windowController;
  final Map? args;
  final WindowMethodChannel channel;
  final String id;

  const VcWindow({
    required this.windowController,
    required this.args,
    required this.channel,
    required this.id,
  });

  @override
  State<VcWindow> createState() => _VcWindowState();
}

class _VcWindowState extends State<VcWindow> with WindowListener {
  late VcLogic _logic;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _startTick();
    widget.channel.setMethodCallHandler(_onMethodCall);

    final token = widget.args?['token'] as String? ?? '';
    final uid = widget.args?['uid'] as String? ?? '';
    _logic = VcLogic(token: token, uid: uid);
    _logic.init();
    _logic.connect();
  }

  void _startTick() {
    Future.delayed(Duration.zero, () async {
      while (true) {
        var channel = WindowMethodChannel('Main');
        await channel.invokeMethod(
          'sub_window_tick',
          jsonEncode({'id': widget.id}),
        );
        await Future.delayed(const Duration(seconds: 1));
      }
    });
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    L.d('sub window call handler: ${call.method}');
    switch (call.method) {
      case 'close':
      case 'show':
      case 'join':
      case 'leave':
        break;
    }
  }

  @override
  void dispose() {
    L.d('sub window dispose');
    windowManager.removeListener(this);
    _logic.dispose();
    widget.windowController.close();
    var channel = WindowMethodChannel('Main');
    channel.invokeMethod(
      'sub_window_close',
      jsonEncode({'id': widget.id}),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: cs.surfaceContainerLow,
        body: ListenableBuilder(
          listenable: _logic,
          builder: (context, _) {
            if (!_logic.inCalling) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.videocam,
                      size: 64,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Connecting...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          color: cs.surfaceContainerLow,
                          child: RTCVideoView(_logic.remoteRenderer),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: 20,
                        child: Container(
                          width: 200,
                          height: 150,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: RTCVideoView(
                              _logic.localRenderer,
                              mirror: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                MeetingControls(
                  onSwitchCamera: _logic.switchCamera,
                  onScreenShare: () {
                    if (_logic.signaling?.videoSource == VideoSource.Screen) {
                      _logic.stopScreenSharing();
                    } else {
                      _logic.startScreenSharing();
                    }
                  },
                  onHangUp: _logic.hangUp,
                  onMuteMic: _logic.muteMic,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void onWindowClose() {
    L.d('sub window close');
    var channel = WindowMethodChannel('Main');
    Future.delayed(Duration.zero, () async {
      await channel.invokeMethod(
        'sub_window_close',
        jsonEncode({'id': widget.id}),
      );
    });
    windowManager.removeListener(this);
    windowManager.close();
    super.onWindowClose();
  }
}
