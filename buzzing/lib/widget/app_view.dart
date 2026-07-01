import 'package:buzzing/provider/app_state_provider.dart';
import 'package:buzzing/utils/screen_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          ScreenUtil.init(constraints: constraints);
          return builder(appState.locale, _buildAppBuilder);
        },
      ),
    );
  }

  Widget Function(BuildContext, Widget?) get _buildAppBuilder {
    return (BuildContext context, Widget? child) {
      return EasyLoading.init(builder: (ctx, w) => w!)(context, child);
    };
  }
}
