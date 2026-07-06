import 'package:buzzing/page/vc/vc_view.dart';
import 'package:buzzing/utils/ext_window_controller.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';

void startVcWindow(
  WindowController windowController,
  Map<String, dynamic> arguments,
  String id,
) {
  final channel = WindowMethodChannel('VcWindow');
  windowController.doCustomInitialize();
  runApp(
    VcWindow(
      windowController: windowController,
      args: arguments,
      channel: channel,
      id: id,
    ),
  );
}
