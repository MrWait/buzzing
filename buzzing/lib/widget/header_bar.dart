import 'dart:io';

import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/utils/platform.dart';
import 'package:buzzing/widget/picker.dart';
import 'package:buzzing/widget/profile.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeaderBar extends ConsumerWidget {
  final double height = 44;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final im = ref.watch(imProvider);
    return GestureDetector(
        onPanStart: (details) {
          if (isDesktop) windowManager.startDragging();
        },
        child: Row(children: [
          Expanded(
              child: Container(
                  alignment: Alignment.centerLeft,
                  height: height,
                  color: cs.surfaceVariant,
                  child: ListenableBuilder(
                      listenable: im,
                      builder: (ctx, _) => AvatarUserPopup(
                            im: im,
                            id: im.userId,
                            url: im.avatar,
                            ver: im.getUserVer(im.userId),
                            child: CircleAvatar(
                              backgroundImage: im.avatar.isEmpty
                                  ? null
                                  : NetworkImage(CommonUtils.fixResourceUrl(im.avatar)),
                              radius: 20,
                            ),
                          )))),
          Container(
            width: height,
            child: Icon(Icons.query_builder, color: cs.primary),
          ),
          Container(
              color: cs.surfaceVariant,
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
                  color: cs.surfaceVariant,
                  child: Row(children: [
                    Spacer(),
                    GestureDetector(
                      child: Icon(Icons.minimize, color: cs.primary),
                      onTap: () {
                        if (isDesktop) windowManager.minimize();
                      },
                    ),
                    GestureDetector(
                        child: Icon(Icons.maximize, color: cs.primary),
                        onTap: () {
                          if (isDesktop) windowManager.maximize();
                        }),
                    GestureDetector(
                      child: Icon(Icons.close, color: cs.primary),
                      onTap: () {
                        if (isDesktop) windowManager.close();
                      },
                    ),
                  ]))),
        ]));
  }
}

class HeaderBarWindows extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!isDesktop) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
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
                    color: cs.surfaceVariant,
                    child: Row(children: [
                      Spacer(),
                      Icon(Icons.minimize, color: cs.primary),
                      Icon(Icons.maximize, color: cs.primary),
                      Icon(Icons.close, color: cs.primary),
                    ]))),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

Widget MainPopup(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return CustomPopup(
    backgroundColor: cs.surface,
    arrowColor: cs.surface,
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
        child: Text(t.createGroup),
      )
    ]),
    child: Icon(
      Icons.add,
      color: cs.primary,
    ),
  );
}
