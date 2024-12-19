import 'dart:io';

import 'package:buzzing/controller/im.dart';
import 'package:buzzing/widget/avatar.dart';
import 'package:buzzing/widget/picker.dart';
import 'package:buzzing/widget/profile.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/utils/loogger_util.dart';
import 'package:path/path.dart';
import 'package:window_manager/window_manager.dart';
import 'package:get/get.dart';
import 'button.dart';

class HeaderBar extends StatelessWidget {
  final double height = 44;
  final im = Get.find<ImController>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanStart: (details) {
          windowManager.startDragging();
        },
        child: Row(children: [
          Expanded(
              child: Container(
                  alignment: Alignment.centerLeft,
                  height: height,
                  color: PageStyle.c_F0F0F0,
                  child: Obx(() => ProfilePopup(context, im.userId,
                      im.avatar.value, im.getUserVer(im.userId).value)))),
          Container(
            width: height,
            child: Icon(Icons.query_builder, color: Colors.lightBlue),
          ),
          Container(
              color: PageStyle.c_F0F0F0,
              height: height,
              width: 120,
              child: Column(children: [
                Text("Header", textAlign: TextAlign.center),
              ])),
          Container(
            width: height,
            child: MainPopup(context),
            /*
        child: NaviButton(
            () => {
                },
            Icons.add),
            */
          ),
          Expanded(
              child: Container(
                  height: height,
                  color: PageStyle.c_F0F0F0,
                  child: Row(children: [
                    Spacer(),
                    GestureDetector(
                      child: Icon(Icons.minimize, color: Colors.lightBlue),
                      onTap: () {
                        windowManager.minimize();
                      },
                    ),
                    GestureDetector(
                        child: Icon(Icons.maximize, color: Colors.lightBlue),
                        onTap: () {
                          windowManager.maximize();
                        }),
                    GestureDetector(
                      child: Icon(Icons.close, color: Colors.lightBlue),
                      onTap: () {
                        windowManager.close();
                      },
                    ),
                  ]))),
        ]));
  }
}

class HeaderBarWindows extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return GestureDetector(
        onPanStart: (details) {
          windowManager.startDragging();
        },
        child: Row(
          children: [
            Expanded(
                child: Container(
                    height: 26,
                    color: PageStyle.c_F0F0F0,
                    child: Row(children: [
                      Spacer(),
                      Icon(Icons.minimize, color: Colors.lightBlue),
                      Icon(Icons.maximize, color: Colors.lightBlue),
                      Icon(Icons.close, color: Colors.lightBlue),
                    ]))),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}

Widget MainPopup(BuildContext context) {
  return CustomPopup(
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(
        onTap: () {
          Get.back();
          showDialog<bool>(
              context: context,
              builder: (context) {
                return ImChatCreater();
                /*
                return AlertDialog(
                    title: Text("Alert"),
                    content: Text("Content"),
                    actions: <Widget>[
                      TextButton(
                          child: Text("OK"), onPressed: () => Get.back()),
                    ]);
                    */
              });
        },
        behavior: HitTestBehavior.translucent,
        child: Text("Create Chat"),
      )
    ]),
    child: const Icon(
      Icons.add,
      color: Colors.lightBlue,
    ),
  );
}
