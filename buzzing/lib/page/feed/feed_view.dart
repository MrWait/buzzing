import 'package:buzzing/models/const.dart';
import 'package:buzzing/widget/sticker.dart';
import 'package:buzzing/controller/im.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/models/model.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/res/styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 260,
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              width: 260,
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

class FeedListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final im = ref.watch(imProvider);
    return ListenableBuilder(
        listenable: im,
        builder: (ctx, _) => ListView.separated(
              itemCount: im.feedList.length,
              itemBuilder: (context, index) {
                return Model.feed(im.feedList[index].feed.id, im.entity, () {
                  im.enterChat(im.feedList[index].feed.id);
                });
              },
              separatorBuilder: (context, index) => Divider(height: 0.0),
            ),
          );
  }
}
