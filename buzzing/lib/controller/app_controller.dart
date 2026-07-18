import 'dart:convert';
import 'dart:io';

import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/utils/upgrade_manager.dart';
import 'package:buzzing/utils/logger_util.dart';
//import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:uuid/v4.dart';

class SubWindow {
  final WindowController controller;
  int lastTick = DateTime.now().millisecondsSinceEpoch;
  final String id;
  /// 窗口是否处于隐藏状态（常驻模式：onWindowClose 改为 hide）
  /// true 表示窗口已隐藏但 engine 保留，可复用
  bool isHidden = false;

  SubWindow({required this.controller, required this.id});

  /// 窗口是否存活：未隐藏且 tick 在 10 秒内（hidden 时 tick 5 秒一次，阈值放宽）
  bool isAlive() {
    if (isHidden) return true; // 隐藏窗口视为存活，等待复用
    var now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastTick) < 10000;
  }
}

//class AppController extends GetxController with UpgradeManager {
class AppController {
  var isRunningBackground = false;
  var backgroundSubject = PublishSubject<bool>();
  var flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();
  var isAppBadgeSupported = false;
  var theme = 0;
  var windows = Map<String, SubWindow>();
  final mainChannel = WindowMethodChannel("Main");

  final initializationSettingsAndroid = AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  final initializationSettingsWindows = WindowsInitializationSettings(
    appName: "buzzing",
    appUserModelId: "buzzing_user",
    guid: UuidV4().generate(),
  );

  final initializationSettingsDarwin = DarwinInitializationSettings();

  final notDisturbMap = <String, bool>{};
  final clientConfigMap = <String, dynamic>{};

  void runningBackground(bool run) {
    L.d('App running background: $run');
    isRunningBackground = run;
    backgroundSubject.sink.add(run);
    if (!run) {
      _cancelAllNotifications();
    }
  }

  void onInit() async {
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // TODO
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      windows: initializationSettingsWindows,
    );
    await flutterLocalNotificationPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) {},
    );
    if (!Platform.isWindows) {
      //isAppBadgeSupported = await FlutterAppBadger.isAppBadgeSupported();
    }

    mainChannel.setMethodCallHandler((call) async {
      var argument = call.arguments as String;
      var arg = jsonDecode(argument) as Map<String, dynamic>;
      if (call.method != "sub_window_tick" && call.method != "sub_window_log") {
        L.d("handle sub window event: ${call}, arg: ${arg}");
      }
      switch (call.method) {
        case "sub_window_close":
          {
            var sub_id = arg['id'] as String;
            var sub_tag = null;
            for (var tag in windows.keys) {
              var id = windows[tag]?.id;
              if (id != null) {
                if (sub_id == id) {
                  sub_tag = tag;
                  break;
                }
              }
            }
            if (sub_tag != null) {
              windows.remove(sub_tag);
            }
          }

          break;
        case "sub_window_hide":
          {
            // 常驻模式：子窗口隐藏而非关闭，保留 windows[tag] 以便复用
            var sub_id = arg['id'] as String;
            for (var win in windows.values) {
              if (win.id == sub_id) {
                win.isHidden = true;
                L.d("sub window hidden: ${win.id}, keep for reuse");
              }
            }
          }
          break;
          case "sub_window_tick":
            {
              var sub_id = arg['id'] as String;
              for (var win in windows.values) {
                if (win.id == sub_id) {
                  win.lastTick = DateTime.now().millisecondsSinceEpoch;
                  // 收到 tick 说明窗口已可见（reactivate 后），清除 hidden 标记
                  win.isHidden = false;
                }
              }
            }
            break;
          case "sub_window_log":
            {
              var level = arg['level'] as String? ?? 'D';
              var msg = arg['msg'] as String? ?? '';
              var tag = arg['tag'] as String? ?? 'SubWin';
              switch (level) {
                case 'E': L.e('[$tag] $msg'); break;
                case 'W': L.w('[$tag] $msg'); break;
                case 'I': L.i('[$tag] $msg'); break;
                default:  L.d('[$tag] $msg'); break;
              }
            }
            break;
          default:
      }
    });

  }

  Future<WindowController?> createWindow(
    String tag,
    bool unique,
    bool show,
    Map<String, dynamic> arguments,
  ) async {
    if (!Platform.isMacOS && !Platform.isWindows) {
      return null;
    }
    var window = windows[tag];
    L.d('createWindow: tag=$tag, existing=${window != null}, isAlive=${window?.isAlive()}, isHidden=${window?.isHidden}');
    if (window != null) {
      if (!window.isAlive()) {
        // 子窗口已失联（tick 超时），从注册表中移除
        L.d('createWindow: window $tag not alive, removing');
        windows.remove(tag);
        window = null;
      } else {
        // 复用：显示窗口 + 通过 controller.invokeMethod 通知子窗口 reactivate
        // 注意：必须用 controller.invokeMethod（基于 windowId 的 unidirectional channel），
        // 不能用 WindowMethodChannel(tag)（bidirectional 模式，主窗口未注册会失败）
        arguments['app'] = tag;
        L.d("reuse window: $tag, args: ${arguments}");
        try {
          await window.controller.show();
          await window.controller.invokeMethod('reactivate', jsonEncode(arguments));
          L.d('reuse window $tag done');
        } catch (e) {
          L.e("reuse window failed: $e, will create new one");
          windows.remove(tag);
          window = null;
        }
        if (window != null) {
          return window.controller;
        }
      }
    }

    arguments['app'] = tag;
    var arg = jsonEncode(arguments);
    L.d("new window arg: ${arg}");

    final controller = await WindowController.create(
      WindowConfiguration(hiddenAtLaunch: false, arguments: arg),
    );
    if (show) {
      controller.show();
    }

    windows[tag] = SubWindow(controller: controller, id: controller.windowId);
    return controller;
  }

  /// 应用退出时调用：通知所有常驻子窗口强制销毁（释放 engine + 资源）
  Future<void> destroyAllSubWindows() async {
    L.d('destroy all sub windows: count=${windows.length}');
    for (var tag in windows.keys.toList()) {
      var win = windows[tag];
      if (win == null) continue;
      try {
        // 用 controller.invokeMethod 直接调子窗口（基于 windowId 的 unidirectional channel）
        await win.controller.invokeMethod('destroy', '{}');
      } catch (e) {
        L.e('destroy sub window $tag failed: $e');
      }
    }
    windows.clear();
  }

  void _requestPermission() {
    flutterLocalNotificationPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    flutterLocalNotificationPlugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<bool> showNotification(dynamic data) async {
    var id = 0;
    var showind = false;
    return true;
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationPlugin.cancelAll();
  }

  Future<void> _startForegroundService() async {
    //await getAppInfo();
    const androidPlatformChannelSpecifiecs = AndroidNotificationDetails(
      'pro',
      'Buzzing background',
      channelDescription: 'Ensure app receive msg',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    await flutterLocalNotificationPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.startForegroundService(
          id: 1,
          title: /*packageInfo!.appName*/ "buzzing",
          body: t.serviceNotificationBody,
          notificationDetails: androidPlatformChannelSpecifiecs,
          payload: '',
        );
  }

  Future<void> _stopForegroundService() async {
    await flutterLocalNotificationPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.stopForegroundService();
  }

  void showBadge(count) {
    if (isAppBadgeSupported) {
      if (count == 0) {
        removeBadge();
      } else {
        // FlutterAppBadger.updateBadgeCount(count);
      }
    }
  }

  void removeBadge() {
    // FlutterAppBadger.removeBadge();
  }

  void onClose() {
    backgroundSubject.close();
  }

  void changeTheme(int newTheme) {
    this.theme = newTheme;
  }

  void onReady() {
    _queryClientConfig();
  }

  Future<bool> _noDisturb() async {
    return true;
  }

  void _queryClientConfig() async {}
}
