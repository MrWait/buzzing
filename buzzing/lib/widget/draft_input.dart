import 'dart:io';

import 'package:buzzing/utils/screencapture_pc.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/widget/button.dart';
import 'package:buzzing/res/theme.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_macos_permissions/flutter_macos_permissions.dart';

class DraftInput extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bt = Theme.of(context).extension<BuzzingTheme>()!;
    final im = ref.watch(imProvider);
    return Container(
      color: bt.mentionBg,
      child: Column(
        children: [
          TextField(
            maxLines: 5,
            minLines: 1,
            onSubmitted: (v) {
              im.onSendMessage(v);
            },
            controller: im.imInputCtrl,
          ),
          Row(
            children: [
              Text("tool", textAlign: TextAlign.left),
              Button(
                enabled: true,
                text: "SC",
                textStyle: tt.bodyLarge?.copyWith(fontSize: 17),
                onTap: () async {
                  if (Platform.isMacOS) {
                    var granted =
                        await FlutterMacosPermissions.requestScreenRecording();
                  }
                  await captureScreen(null);
                },
              ),
              Spacer(),
              Button(
                enabled: true,
                text: "Send",
                textStyle: tt.bodyLarge?.copyWith(fontSize: 17),
                onTap: () {
                  im.onSendMessage("");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
