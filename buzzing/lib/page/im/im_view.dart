import 'dart:io';

import 'package:buzzing/page/chat/chat_view.dart';
import 'package:buzzing/page/feed/feed_view.dart';
import 'package:buzzing/page/im/im_logic.dart';
import 'package:buzzing/page/feed/feed_logic.dart';
import 'package:buzzing/page/chat/chat_logic.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/widget/header_bar.dart';
import 'package:buzzing/widget/navigate_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImPage extends StatelessWidget {
  final imLogic = Get.find<ImLogic>();
  final feedLogic = Get.find<FeedLogic>();
  final chatLogic = Get.find<ChatLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PageStyle.c_DCEBFE,
      body: Row(children: [
        NaviBar(),
        Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(child: HeaderBarWindows()),
            Expanded(
              child: Row(
                children: [
                  FeedPage(),
                  Expanded(
                    child: ChatPage(),
                  ),
                ],
              ),
            ),
          ]),
        )
      ]),
    );
  }
}
