import 'dart:async';

import 'package:buzzing/widget/app_view.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buzzing/router/router.dart';

class BuzzingApp extends ConsumerWidget {
  BuzzingApp({Key? key, required this.channel}) : super(key: key) {
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'meeting_end':
          break;
        case 'meeting_incomming':
          break;
        case 'webview_end':
          break;
      }
    });
  }
  final WindowMethodChannel channel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    Future.delayed(Duration(milliseconds: 0), () async {
      return;
    });
    return AppView(
      builder: ((locale, builder) => MaterialApp.router(
        debugShowCheckedModeBanner: true,
        routerConfig: router,
        builder: builder,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        locale: locale,
        supportedLocales: [const Locale('zh', 'CN'), const Locale('en', 'US')],
      )),
    );
  }
}
