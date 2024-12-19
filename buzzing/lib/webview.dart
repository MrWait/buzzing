import "dart:async";
import "dart:math";
import "dart:convert";

import 'package:buzzing/page/screenshot/screenshot_view.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/page/error_page.dart';
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
