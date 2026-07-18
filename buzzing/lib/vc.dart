import 'dart:convert';

import 'package:buzzing/page/vc/vc_view.dart';
import 'package:buzzing/utils/ext_window_controller.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';

void startVcWindow(
  WindowController windowController,
  Map<String, dynamic> arguments,
  String id,
) {
  // 子窗口日志通过 IPC 发送到主窗口，由主窗口写入 SDK
  defaultLogger.setLogFn((message, level, error, backtrace) {
    try {
      var channel = WindowMethodChannel('Main');
      channel.invokeMethod('sub_window_log', jsonEncode({
        'level': _levelFromValue(level),
        'msg': error != null ? '$message error=$error' : message,
        'tag': 'VcWin',
      }));
    } catch (_) {}
  });

  windowController.doCustomInitialize();
  runApp(
    VcWindow(
      windowController: windowController,
      args: arguments,
      id: id,
    ),
  );
}

String _levelFromValue(int value) {
  if (value <= 400) return 'D';
  if (value <= 500) return 'I';
  if (value <= 600) return 'W';
  return 'E';
}
