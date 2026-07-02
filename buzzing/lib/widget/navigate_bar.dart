import 'dart:io';

import 'package:buzzing/res/theme.dart';
import 'package:buzzing/routes/app_routes.dart';
import 'package:buzzing/widget/header_bar.dart';
import 'package:buzzing/widget/personal.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'button.dart';

class NaviBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bt = Theme.of(context).extension<BuzzingTheme>()!;
    final cs = Theme.of(context).colorScheme;
    final im = ref.watch(imProvider);
    var padding = 0.0;
    if (Platform.isMacOS) {
      padding = 32.0;
    }
    return GestureDetector(
        onPanStart: (details) {
          windowManager.startDragging();
        },
        child: Container(
            color: bt.navBarBg,
            width: 64.0,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                height: padding,
              ),
              ListenableBuilder(
                  listenable: im,
                  builder: (ctx, _) => PersonalPopup(
                    im: im,
                    id: im.userId,
                    url: im.avatar,
                    ver: im.getUserVer(im.userId),
                  )),
              Container(
                  height: 40,
                  child: Icon(
                    Icons.search_rounded,
                    color: cs.primary,
                  )),
              Container(height: 40, child: MainPopup(context)),
              NaviButton(context, () {
                final router = GoRouter.of(context);
                router.go(AppRoute.IM);
              }, Icons.message),
              NaviButton(context, () {
                final router = GoRouter.of(context);
                router.go(AppRoute.CALENDAR);
              }, Icons.calendar_month),
              NaviButton(context, () {
                final router = GoRouter.of(context);
                router.go(AppRoute.MEETING);
              }, Icons.video_call),
              NaviButton(context, () {
                final router = GoRouter.of(context);
                router.go(AppRoute.CONTACT);
              }, Icons.contact_page),
            ])));
  }
}
