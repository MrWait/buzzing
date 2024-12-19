import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/controller/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import './focus_detector.dart';

class AppView extends StatelessWidget {
  const AppView({Key? key, required this.builder});
  final Widget Function(Locale? locale,
      Widget Function(BuildContext context, Widget? child) builder) builder;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GetBuilder<AppController>(
        init: AppController(),
        builder: (controller) => FocusDetector(
              onForegroundGained: () => controller.runningBackground(false),
              onForegroundLost: () => controller.runningBackground(true),
              child: ScreenUtilInit(
                designSize: Size(Config.UI_W, Config.UI_H),
                minTextAdapt: true,
                splitScreenMode: true,
                builder: (_, child) => builder(controller.getLocale(),
                    EasyLoading.init(builder: (context, widget) {
                  return widget!;
                })),
              ),
            ));
  }
}
