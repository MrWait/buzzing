import 'dart:io';

import 'package:buzzing/widget/picker.dart';
import 'package:buzzing/widget/profile.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/res/styles.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeaderBar extends ConsumerWidget {
  final double height = 44;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final im = ref.watch(imProvider);
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
                  child: ListenableBuilder(
                      listenable: im,
                      builder: (ctx, _) => ProfilePopup(im, context, im.userId,
                          im.avatar, im.getUserVer(im.userId))))),
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
          Navigator.of(context).pop();
          showDialog<bool>(
              context: context,
              builder: (context) {
                return ImChatCreater();
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
