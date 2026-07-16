import 'dart:convert';

import 'package:buzzing/ffi/rust/frb_generated.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/utils/data_persistence.dart';
import 'package:buzzing/utils/net/http_util.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sp_util/sp_util.dart';
import 'package:window_manager/window_manager.dart';

class Config {
  static const PAGE_SIZE = 20;
  static const API_TOKEN = "4d65e2a5626103f92a71867d7b49fea0";
  static const TOKEN_KEY = "token";
  static const USER_NAME_KEY = "user-name";
  static const PW_KEY = "user-pw";
  static const USER_BASIC_CODE = "user-basic-code";
  static const USER_INFO = "user-info";
  static const LANGUAGE_SELECT = "language-select";
  static const LANGUAGE_SELECT_NAME = "language-select-name";
  static const REFRESH_LANGUAGE = "refreshLanguageApp";
  static const THEME_COLOR = "theme-color";
  static const LOCALE = "locale";
  static const UI_W = 375.0;
  static const UI_H = 812.0;

  static bool? DEBUG = true;
  static late String cachePath;
  static Union union = Union();
  static String currentUnion = "";

  static Future init(Function() runApp) async {
    WidgetsFlutterBinding.ensureInitialized();
    cachePath = (await getApplicationDocumentsDirectory()).path;
    await SpUtil.getInstance();
    HttpUtil.init();

    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    runApp();
  }

  static String apiUrl() {
    return union.apiUrl();
  }
}
