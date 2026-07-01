import 'package:buzzing/ffi/rust/api/flutter.dart';
import 'package:buzzing/page/splash/splash_logic.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/res/images.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/res/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buzzing/utils/screen_ext.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final logic = ref.watch(splashLogicProvider);
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() {
        final router = GoRouter.of(context);
        logic.init(router);
      });
    }
    return Material(
      child: Stack(
        children: [
          Positioned(
            top: 603.h,
            width: 375.w,
            child: Center(
              child: Image.asset(ImageRes.ic_app, width: 52.w, height: 53.h),
            ),
          ),
          Positioned(
            top: 673.h,
            width: 375.w,
            child: Center(
              child: Text(t.welcomeUse, style: tt.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }
}
