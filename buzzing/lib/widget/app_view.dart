import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/provider/app_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import './focus_detector.dart';

class AppView extends ConsumerWidget {
  const AppView({Key? key, required this.builder});
  final Widget Function(Locale? locale,
      Widget Function(BuildContext context, Widget? child) builder) builder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    return FocusDetector(
      onForegroundGained: () =>
          ref.read(appStateProvider.notifier).setRunningBackground(false),
      onForegroundLost: () =>
          ref.read(appStateProvider.notifier).setRunningBackground(true),
      child: ScreenUtilInit(
        designSize: Size(Config.UI_W, Config.UI_H),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) => builder(appState.locale,
            EasyLoading.init(builder: (context, widget) {
          return widget!;
        })),
      ),
    );
  }
}
