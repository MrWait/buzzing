import 'dart:io';

import 'package:buzzing/utils/screencapture_pc.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/widget/button.dart';
import 'package:buzzing/controller/im.dart';
import 'package:buzzing/res/styles.dart';
import 'package:get/get.dart';
import 'package:flutter_macos_permissions/flutter_macos_permissions.dart';

class DraftInput extends StatelessWidget {
  final im = Get.find<ImController>();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: PageStyle.c_F0F6FF,
      //height: 120.0,
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
                textStyle: PageStyle.ts_171A1D_17,
                onTap: () async {
                  // start screen capture
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
                textStyle: PageStyle.ts_171A1D_17,
                onTap: () {
                  im.onSendMessage("");
                },
              ),
              //  Text("Send", textAlign: TextAlign.left),
            ],
          ),
          //          Expanded(child: Container()),
        ],
      ),
    );
  }
}
