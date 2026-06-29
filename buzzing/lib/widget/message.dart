import 'dart:convert';
import 'dart:math';

import 'package:buzzing/widget/profile.dart';
import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/res/styles.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

class MessageWidget extends ConsumerWidget {
  late final String icon;
  late final String name;
  late final String desc;
  late final String time;
  late final String text;
  late final String avatar;
  late final Int64 userId;
  late final GlobalKey? key;
  late bool simple;
  MessageWidget({
    icon = "",
    name = "",
    desc = "",
    time = "",
    avatar = "",
    key,
    simple = false,
    required text,
    required userId,
  }) : icon = icon,
       desc = desc,
       name = name,
       time = time,
       simple = simple,
       avatar = avatar,
       userId = userId,
       text = text,
       key = key;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final im = ref.watch(imProvider);
    return renderMsg(context, im);
  }

  Widget renderMsg(context, ImController im) {
    if (simple) {
      return Container(
        //color: PageStyle.c_71BCFF,
        padding: EdgeInsets.all(2),
        child: Row(
          children: [
            Container(
              color: PageStyle.c_EB84CA,
              width: 40,
              //                height: 40,
            ),
            //Spacer(),
            Expanded(
              child: Container(
                alignment: Alignment.topLeft,
                color: PageStyle.c_E8F2FF,
                padding: EdgeInsets.all(2),
                child: Text(text, textAlign: TextAlign.left),
              ),
            ),
          ],
        ),
      );
    } else {
      return IntrinsicHeight(
        child: Container(
          //color: PageStyle.c_71BCFF,
          padding: EdgeInsets.all(2),
          child: Row(
            children: [
              // icon
              Container(
                width: 40,
                child: Column(
                  children: [
                    Container(
                      //color: PageStyle.c_EB84CA,
                      alignment: Alignment.topCenter,
                      //                      width: 40,
                      height: 40,
                      child: ListenableBuilder(
                        listenable: im,
                        builder: (ctx, _) => ProfilePopup(
                          im,
                          context,
                          userId,
                          avatar,
                          im.getUserVer(userId),
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: [
                      // detail
                      Row(
                        children: [
                          Text(
                            name,
                            textAlign: TextAlign.left,
                            //textScaleFactor: 1.5,
                          ),
                          Text(desc, textAlign: TextAlign.left),
                          Text(time, textAlign: TextAlign.left),
                          Spacer(),
                        ],
                      ),
                      // msg
                      Container(
                        alignment: Alignment.topLeft,
                        color: PageStyle.c_E8F2FF,
                        padding: EdgeInsets.all(2),
                        child: Text(text, textAlign: TextAlign.left),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

String genText(int len) {
  const src = '+-*=?AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
  Random random = Random();
  return String.fromCharCodes(
    Iterable.generate(len, (_) => src.codeUnitAt(random.nextInt(src.length))),
  );
}

List<Widget> genMessages() {
  return <Widget>[
    MessageWidget(simple: true, text: genText(2000), userId: 0),
    Container(height: 2),
    MessageWidget(
      simple: false,
      icon: "I1",
      name: "N1",
      desc: "D1",
      text: genText(20),
      userId: 0,
    ),
    Container(height: 2),
    MessageWidget(
      simple: false,
      icon: "I1",
      name: "N1",
      desc: "D1",
      text: genText(200),
      userId: 0,
    ),
    Container(height: 2),
    MessageWidget(
      simple: false,
      icon: "I1",
      name: "N1",
      desc: "D1",
      text: genText(5),
      userId: 0,
    ),
    Container(height: 2),
    MessageWidget(simple: true, text: genText(140), userId: 0),
    Container(height: 2),
    MessageWidget(simple: true, text: genText(140), userId: 0),
    Container(height: 2),
    MessageWidget(simple: true, text: genText(140), userId: 0),
    Container(height: 2),
    MessageWidget(simple: true, text: genText(140), userId: 0),
    Container(height: 2),
    MessageWidget(simple: true, text: genText(140), userId: 0),
    Container(height: 2),
    MessageWidget(simple: true, text: genText(140), userId: 0),
    Container(height: 2),
    MessageWidget(
      simple: false,
      icon: "I1",
      name: "N1",
      desc: "D1",
      text: genText(1400),
      userId: 0,
    ),
  ];
}

class MessageBox extends ConsumerWidget {
  final User user;
  final Message msg;
  var controller = QuillController.basic();

  MessageBox({required msg, required user}) : user = user, msg = msg;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final im = ref.watch(imProvider);
    Widget render;
    switch (msg.tpy) {
      // MessageType.TEXT.value:
      case 1:
        var m = MessageText.fromBuffer(msg.content);
        render = Text(m.text, textAlign: TextAlign.left);
        break;
      // MessageType.RICH_TEXT_QUILL.value
      case 11:
        var m = MessageText.fromBuffer(msg.content);
        try {
          controller.document = Document.fromJson(jsonDecode(m.text));
          controller.readOnly = true;
          render = QuillEditor.basic(
            controller: controller,
            config: QuillEditorConfig(
              showCursor: false,
              minHeight: 100,
              maxHeight: 300,
              embedBuilders: FlutterQuillEmbeds.editorBuilders(),
            ),
          );
        } catch (e) {
          render = Text(msg.summary, textAlign: TextAlign.left);
        }
        break;
      default:
        render = Text(msg.summary, textAlign: TextAlign.left);
        break;
    }
    return IntrinsicHeight(
      child: Container(
        //color: PageStyle.c_71BCFF,
        padding: EdgeInsets.all(2),
        child: Row(
          children: [
            // icon
            Container(
              width: 40,
              child: Column(
                children: [
                  Container(
                    //color: PageStyle.c_EB84CA,
                    alignment: Alignment.topCenter,
                    //                      width: 40,
                    height: 40,
                    child: ListenableBuilder(
                      listenable: im,
                      builder: (ctx, _) => ProfilePopup(
                        im,
                        context,
                        user.id,
                        user.avatar,
                        im.getUserVer(user.id),
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.topLeft,
                child: Column(
                  children: [
                    // detail
                    Row(
                      children: [
                        Text(
                          user.name,
                          textAlign: TextAlign.left,
                          //textScaleFactor: 1.5,
                        ),
                        Text(
                          "(" +
                              msg.pos.toString() +
                              ", " +
                              msg.id.toString() +
                              ")",
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          msg.updateTimeMs.toString(),
                          textAlign: TextAlign.left,
                        ),
                        Spacer(),
                      ],
                    ),
                    // msg
                    Container(
                      alignment: Alignment.topLeft,
                      color: PageStyle.c_E8F2FF,
                      padding: EdgeInsets.all(2),
                      child: render,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
