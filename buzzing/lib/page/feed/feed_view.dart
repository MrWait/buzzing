import 'package:buzzing/models/const.dart';
import 'package:buzzing/widget/feedcard.dart';
import 'package:buzzing/widget/sticker.dart';
import 'package:buzzing/page/im/im_logic.dart';
import 'package:buzzing/controller/im.dart';
import 'package:buzzing/controller/event.dart';
import 'package:buzzing/utils/loogger_util.dart';
import 'package:buzzing/models/model.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/res/styles.dart';
import 'package:get/get.dart';

class FeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 260,
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              width: 260,
//              height: 200,
              color: PageStyle.c_F0F0F0,
              child: Wrap(children: genSticker())),
          Expanded(
              child: Container(
            width: 260,
            color: PageStyle.c_D8D8D8,
            child: FeedListView(),
          ))
        ]));
  }
}

class FeedListView extends StatelessWidget {
  final im = Get.find<ImController>();

  @override
  Widget build(BuildContext ctx) {
    return GetBuilder<ImController>(
        id: ConstKey.KeyFeedList,
        builder: (c) => ListView.separated(
              itemCount: im.feedList.length,
              itemBuilder: (context, index) {
                return Model.feed(im.feedList[index].feed.id, im.entity, () {
                  im.enterChat(im.feedList[index].feed.id);
                });
              },
              separatorBuilder: (context, index) => Divider(height: 0.0),
            ));
  }
}
