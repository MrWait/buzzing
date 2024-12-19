import 'package:buzzing/models/const.dart';
import 'package:buzzing/widget/draft_input.dart';
import 'package:buzzing/widget/message.dart';
import 'package:buzzing/controller/im.dart';
import 'package:buzzing/controller/event.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/utils/loogger_util.dart';
import 'package:buzzing/widget/message_input.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/res/styles.dart';
import 'package:get/get.dart';
import 'package:fixnum/fixnum.dart';

class ChatPage extends StatelessWidget {
  final im = Get.find<ImController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: PageStyle.c_F0F6FF,
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: Obx(() {
        var chatId = im.chatId.value;
        var chat = im.getChat(chatId);
        if (chatId == 0) {
          return Column(mainAxisSize: MainAxisSize.max, children: []);
        } else {
          var name = "";
          if (chat != null) {
            name = chat.name;
          }
          if (name.length > 40) {
            name = name.substring(0, 40) + "...";
          }
          name = name + "(" + chatId.toString() + ")";

          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                color: PageStyle.c_F0F6FF,
                height: 44.0,
                child: Row(
                  children: [
                    Icon(Icons.group),
                    Text(name, textAlign: TextAlign.center),
                    Spacer(),
                  ],
                ),
              ),
              Expanded(child: MessageView()),
              // DraftInput(),
              MessageInput(),
            ],
          );
        }
      }),
    );
  }
}

class MessageView extends StatelessWidget {
  final im = Get.find<ImController>();

  @override
  Widget build(BuildContext ctx) {
    return GetBuilder<ImController>(
      id: ConstKey.KeyChatMessage,
      builder: (c) {
        L.d("rebuild message view, count: ${im.messagePosList.length}");
        return Container(
          color: PageStyle.c_FDFEFF,
          child: SelectionArea(
            child: ListView.separated(
              controller: im.msgCtrl,
              itemCount: im.messagePosList.length,
              itemBuilder: (context, index) {
                var msg = im.messagePosList[index];

                return Model.messageBox(msg.id, msg.fromId, im.entity);
              },
              separatorBuilder: (context, index) => Divider(height: 5.0),
            ),
          ),
        );
      },
    );
  }
}
