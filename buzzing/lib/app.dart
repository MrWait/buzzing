import 'dart:async';

import 'package:buzzing/controller/app_controller.dart';
import 'package:buzzing/controller/event.dart';
import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/controller/im.dart';
import 'package:buzzing/res/strings.dart';
import 'package:buzzing/routes/app_pages.dart';
import 'package:buzzing/widget/app_view.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:buzzing/utils/loogger_util.dart';

class BuzzingApp extends StatelessWidget {
  BuzzingApp({Key? key, required this.channel}) : super(key: key) {
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        // meeting
        case 'meeting_end':
          break;
        case 'meeting_incomming':
          break;
        // webview
        case 'webview_end':
          break;
      }
    });
  }
  final WindowMethodChannel channel;

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 0), () async {
      return;
      /*
      await FlutterLogs.initLogs(
        logLevelsEnabled: [
          LogLevel.ERROR,
          LogLevel.INFO,
          LogLevel.WARNING,
          LogLevel.SEVERE,
        ],
        timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
        directoryStructure: DirectoryStructure.FOR_DATE,
        logTypesEnabled: ["device", "network", "errors"],
        logFileExtension: LogFileExtension.LOG,
        logsWriteDirectoryName: "Logs",
        logsExportDirectoryName: "Logs/Export",
        debugFileOperations: true,
        isDebuggable: true,
      );
      */
    });
    return AppView(
      builder: ((locale, builder) => GetMaterialApp(
        debugShowCheckedModeBanner: true,
        enableLog: true,
        builder: builder,
        logWriterCallback: printLog,
        translations: TranslationService(),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        fallbackLocale: TranslationService.fallbackLocale,
        locale: locale,
        localeResolutionCallback: (locale, list) {
          Get.locale ??= locale;
        },
        supportedLocales: [const Locale('zh', 'CN'), const Locale('en', 'US')],
        getPages: AppPages.routes,
        initialBinding: InitBinding(),
        initialRoute: AppRoute.SPLASH,
        theme: ThemeData(pageTransitionsTheme: NoTransitions()),
      )),
    );
  }
}

class InitBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(EventController());
    Get.put(SdkController());
    Get.put(ImController());
    Get.put(AppController());
  }
}

class NoTransitions extends PageTransitionsTheme {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (GetPlatform.isDesktop) {
      return child;
    }
    return super.buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}
