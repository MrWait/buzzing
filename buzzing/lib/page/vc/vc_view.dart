import 'dart:async';
import 'dart:convert';

import 'package:buzzing/utils/ext_window_controller.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:window_manager/window_manager.dart';

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
  @override
  void initState() {
    windowManager.addListener(this);
    _startTick();
    widget.channel.setMethodCallHandler(_onMethodCall);
    super.initState();
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
        appBar: AppBar(
          backgroundColor: cs.surface,
          elevation: 0,
          title: const Text('Buzzing Meeting'),
          centerTitle: true,
        ),
        body: Center(
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
                'Video Call',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
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
