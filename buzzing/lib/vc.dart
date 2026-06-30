import "dart:async";
import 'dart:io';
import "dart:math";
import "dart:convert";

import 'package:buzzing/utils/loogger_util.dart';
import 'package:buzzing/page/screenshot/screenshot_view.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/page/error_page.dart';
import 'package:buzzing/utils/ext_window_controller.dart';
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
import 'package:window_manager/window_manager.dart';
import 'package:flutter/services.dart';

class VcWindow extends StatefulWidget {
  final WindowController windowController;
  final Map? args;
  final WindowMethodChannel channel;
  final String id;

  VcWindow({
    Key? key,
    required this.windowController,
    required this.args,
    required this.channel,
    required this.id,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return VcWindowState(
      windowController: windowController,
      args: args,
      channel: channel,
      id: id,
    );
  }
}

class VcWindowState extends State<VcWindow> with WindowListener {
  // class VcWindowState extends State<VcWindow> {
  final WindowController windowController;
  final Map? args;
  final WindowMethodChannel channel;
  final String id;

  VcWindowState({
    required this.windowController,
    required this.args,
    required this.channel,
    required this.id,
  });

  @override
  void initState() {
    windowManager.addListener(this);
    //windowManager.setPreventClose(true);
    Future.delayed(Duration.zero, () async {
      while (true) {
        var channel = WindowMethodChannel("Main");
        await channel.invokeMethod("sub_window_tick", jsonEncode({"id": id}));
        await Future.delayed(Duration(milliseconds: 1000));
      }
    });

    channel.setMethodCallHandler((call) async {
      LD("sub window call handler: ${call}");
      switch (call.method) {
        case 'close':
          break;
        case 'show':
          break;
        case 'join':
          break;
        case 'leave':
          break;
      }
    });
    super.initState();
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    LD("sub window dispose");
    windowManager.removeListener(this);
    await windowController.close();
    var channel = WindowMethodChannel("Main");
    await channel.invokeMethod("sub_window_close", jsonEncode({"id": id}));

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Text("123"),
      ),
    );
  }

  @override
  void onWindowClose() {
    LD("sub window close");
    var channel = WindowMethodChannel("Main");
    Future.delayed(Duration.zero, () async {
      await channel.invokeMethod("sub_window_close", jsonEncode({"id": id}));
    });

    windowManager.removeListener(this);
    windowManager.close();
    //windowManager.destroy();

    super.onWindowClose();
  }
}

void startVcWindow(
  WindowController windowController,
  Map<String, dynamic> arguments,
  String id,
) {
  final channel = WindowMethodChannel('VcWindow');
  /*
  windowController.setWindowMethodHandler((call) async {
    LD("handle sub window call: ${call}");
    switch (call.method) {
      case "window_close":
        LD("sub window closed");
        var channel = WindowMethodChannel("Main");
        await channel.invokeMethod("sub_window_close", {"id": id});
        break;
      default:
    }
  });
  */
  windowController.doCustomInitialize();
  runApp(
    VcWindow(
      windowController: windowController,
      args: arguments,
      channel: channel,
      id: id,
    ),
  );
  LD("run end");
}
