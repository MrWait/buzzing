import 'package:buzzing/provider/app_state_provider.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/res/theme.dart';
import 'package:buzzing/utils/platform.dart';
import 'package:buzzing/widget/app_view.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buzzing/router/router.dart';
import 'package:window_manager/window_manager.dart';

class BuzzingApp extends ConsumerStatefulWidget {
  const BuzzingApp({Key? key, required this.channel}) : super(key: key);

  final WindowMethodChannel channel;

  @override
  ConsumerState<BuzzingApp> createState() => _BuzzingAppState();
}

class _BuzzingAppState extends ConsumerState<BuzzingApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    // 全局未读数变化 → 原生 app badge（FlutterAppBadger 调用保持注释，仅接线）
    ref.read(imProvider).onBadgeChanged = ref.read(appControllerProvider).showBadge;
    if (isDesktop) {
      windowManager.addListener(this);
      windowManager.setPreventClose(true);
    }
  }

  @override
  void dispose() {
    if (isDesktop) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void onWindowClose() async {
    if (!isDesktop) return;
    final app = ref.read(appControllerProvider);
    await app.destroyAllSubWindows();
    await windowManager.setPreventClose(false);
    await windowManager.close();
    super.onWindowClose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final appState = ref.watch(appStateProvider);
    final themeMode = switch (appState.theme) {
      1 => ThemeMode.light,
      2 => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    if (isDesktop) {
      widget.channel.setMethodCallHandler((call) async {
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

    return AppView(
      builder: ((locale, builder) => MaterialApp.router(
        debugShowCheckedModeBanner: true,
        routerConfig: router,
        builder: builder,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
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
