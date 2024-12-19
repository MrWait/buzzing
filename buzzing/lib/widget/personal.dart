import 'package:buzzing/controller/im.dart';
import 'package:buzzing/res/strings.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/widget/avatar.dart';
import 'package:buzzing/widget/picker.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/utils/loogger_util.dart';
import 'package:window_manager/window_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:fixnum/fixnum.dart';
import 'button.dart';

Widget PersonalPopup(BuildContext context, Int64 id, String url, Int64 ver) {
  var im = Get.find<ImController>();
  var user = im.getUser(id);
  var tenant = im.getTenant();
  L.d("hero popup, get user: ${id}, ${user}");

  var tenantName = "Personal";
  if (tenant != null) {
    tenantName = tenant.name;
  }
  return CustomPopup(
    content: Container(
      height: 600,
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                height: 64,
                child: Avatar(
                  url,
                  Icon(Icons.account_circle_outlined, color: Colors.lightBlue),
                ),
              ),
              Column(children: [Text(user?.name ?? ""), Text(tenantName)]),
            ],
          ),
          GestureDetector(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(StrRes.myInfo),
            ),
            onTap: () {},
          ),
          GestureDetector(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(StrRes.myQrcode),
            ),
            onTap: () {},
          ),
          GestureDetector(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(StrRes.mySetting),
            ),
            onTap: () {},
          ),
          GestureDetector(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(StrRes.logout),
            ),
            onTap: () {
              im.logout();
            },
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
