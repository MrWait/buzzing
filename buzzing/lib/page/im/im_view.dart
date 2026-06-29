import 'dart:io';

import 'package:buzzing/page/chat/chat_view.dart';
import 'package:buzzing/page/feed/feed_view.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/widget/header_bar.dart';
import 'package:buzzing/widget/navigate_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
