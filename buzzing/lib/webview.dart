import "dart:async";
import "dart:math";
import "dart:convert";

import 'package:buzzing/page/screenshot/screenshot_view.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/utils/platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
//import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
//import 'ffi/ffi_cpp.dart' if (dart.library.html) 'ffi_web.dart';
import 'package:buzzing/utils/env/config_wrapper.dart';
import 'package:buzzing/utils/env/env_config.dart';
import 'package:buzzing/page/screenshot/event_widget.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:desktop_lifecycle/desktop_lifecycle.dart';

/// 移动端 Webview 页面，替代桌面子窗口
class WebviewPage extends StatelessWidget {
  final String? url;
  final String? title;

  const WebviewPage({super.key, this.url, this.title});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title ?? 'Webview')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.web, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('Webview', style: tt.titleMedium),
            if (url != null) ...[
              const SizedBox(height: 8),
              Text(url!, style: tt.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class WebviewWindow extends StatelessWidget {
  WebviewWindow({
    Key? key,
    required this.windowController,
    required this.args,
    required this.channel,
  }) : super(key: key) {
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'close':
          break;
        case 'load':
          break;
        case 'newtab':
          break;
      }
    });
  }

  final WindowController windowController;
  final Map? args;
  final WindowMethodChannel channel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: ScreenshotOverlay(),
      ),
    );
  }
}
