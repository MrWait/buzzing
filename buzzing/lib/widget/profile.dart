import 'package:buzzing/controller/im.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/widget/avatar.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fixnum/fixnum.dart';

Widget ProfilePopup(ImController im, BuildContext context, Int64 id,
    String url, Int64 ver) {
  var user = im.getUser(id);
  L.d("profile popup, get user: ${id}, ${user}");
  return CustomPopup(
    content: Container(
      height: 600,
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Avatar(
            url,
            Icon(Icons.account_circle_outlined, color: Colors.lightBlue),
          ),
          Row(children: [Text("Name: "), Text(user?.name ?? "")]),
          GestureDetector(
            onTap: () async {
              var chatId = await im.createP2PChat(id);
              if (chatId != null) {
                im.enterChat(chatId);
              }
              Navigator.of(context).pop();
            },
            behavior: HitTestBehavior.translucent,
            child: Text("Send Message"),
          ),
        ],
      ),
    ),
    child: CircleAvatar(
      backgroundImage: Image(
        image: CachedNetworkImageProvider(CommonUtils.fixResourceUrl(url)),
      ).image,
      radius: 20,
    ),
  );
}
