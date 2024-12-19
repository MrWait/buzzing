import 'dart:io';

import 'package:buzzing/controller/im.dart';
import 'package:buzzing/routes/app_navigator.dart';
import 'package:buzzing/widget/header_bar.dart';
import 'package:buzzing/widget/profile.dart';
import 'package:buzzing/widget/personal.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/res/styles.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import 'button.dart';

class NaviBar extends StatelessWidget {
  final im = Get.find<ImController>();
  @override
  Widget build(BuildContext context) {
    var padding = 0.0;
    if (Platform.isMacOS) {
      padding = 32.0;
    }
    return GestureDetector(
        onPanStart: (details) {
          windowManager.startDragging();
        },
        child: Container(
            color: Colors.black12,
            width: 64.0,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                height: padding,
              ),
              Obx(() => PersonalPopup(context, im.userId, im.avatar.value,
                  im.getUserVer(im.userId).value)),
              Container(
                  height: 40,
                  child: Icon(
                    Icons.search_rounded,
                    color: Colors.lightBlue,
                  )),
              Container(height: 40, child: MainPopup(context)),
              NaviButton(() => AppNavigator.startIm(null), Icons.message),
              NaviButton(
                  () => AppNavigator.startCalendar(), Icons.calendar_month),
              NaviButton(() => AppNavigator.startMeeting(), Icons.video_call),
              NaviButton(() => AppNavigator.startContact(), Icons.contact_page),
            ])));
  }
}
