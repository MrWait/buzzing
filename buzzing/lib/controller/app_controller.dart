import 'dart:convert';
import 'dart:io';

import 'package:buzzing/res/strings.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/utils/data_persistence.dart';
import 'package:buzzing/utils/upgrade_manager.dart';
import 'package:buzzing/utils/loogger_util.dart';
//import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:uuid/v4.dart';

class SubWindow {
  final WindowController controller;
  int lastTick = DateTime.now().millisecondsSinceEpoch;
  final String id;

  SubWindow({required this.controller, required this.id});

  bool isAlive() {
    var now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastTick) < 1000;
  }
}

//class AppController extends GetxController with UpgradeManager {
class AppController extends GetxController {
  var isRunningBackground = false;
  var backgroundSubject = PublishSubject<bool>();
  var flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();
  var isAppBadgeSupported = false;
  var theme = 0.obs;
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
  final clientConfigMap = <String, dynamic>{}.obs;

  void runningBackground(bool run) {
    LD('App running background: $run');
    isRunningBackground = run;
    backgroundSubject.sink.add(run);
    if (!run) {
      _cancelAllNotifications();
    }
  }

  @override
  void onInit() async {
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // TODO
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      windows: initializationSettingsWindows,
    );
    await flutterLocalNotificationPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) {},
    );
    if (!GetPlatform.isWindows) {
      //isAppBadgeSupported = await FlutterAppBadger.isAppBadgeSupported();
    }

    mainChannel.setMethodCallHandler((call) async {
      print("handle sub window event: ${call}");
      var argument = call.arguments as String;
      var arg = jsonDecode(argument) as Map<String, dynamic>;
      print("arg: ${arg}");
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
        case "sub_window_tick":
          {
            var sub_id = arg['id'] as String;
            for (var win in windows.values) {
              if (win.id == sub_id) {
                win.lastTick = DateTime.now().millisecondsSinceEpoch;
              }
            }
          }
          break;
        default:
      }
    });

    super.onInit();
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
    if (window != null) {
      if (!window.isAlive()) {
        windows.remove(tag);
      } else {
        return window.controller;
      }
    }

    arguments['app'] = tag;
    var arg = jsonEncode(arguments);
    print("new window arg: ${arg}");

    final controller = await WindowController.create(
      WindowConfiguration(hiddenAtLaunch: false, arguments: arg),
    );
    if (show) {
      controller.show();
    }

    windows[tag] = SubWindow(controller: controller, id: controller.windowId);
    return controller;
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
          1,
          /*packageInfo!.appName*/ "buzzing",
          StrRes.serviceNotificationBody,
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

  @override
  void onClose() {
    backgroundSubject.close();
    //closeSubject();
    super.onClose();
  }

  void changeTheme(int newTheme) {
    this.theme.value = newTheme;
  }

  Locale? getLocale() {
    var local = Get.locale;
    var index = DataPersistence.getLanguage() ?? 0;
    switch (index) {
      case 1:
        local = Locale('zh', 'CN');
        break;
      case 2:
        local = Locale('en', 'US');
        break;
    }
    return local;
  }

  @override
  void onReady() {
    _queryClientConfig();
    //autoCheckVersionUpgrade();
    super.onReady();
  }

  Future<bool> _noDisturb() async {
    return true;
  }

  void _queryClientConfig() async {}
}
