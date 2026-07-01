import 'package:buzzing/controller/im.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/widget/avatar.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fixnum/fixnum.dart';
import 'package:go_router/go_router.dart';

Widget PersonalPopup(ImController im, BuildContext context, Int64 id,
    String url, Int64 ver) {
  var user = im.getUser(id);
  var tenant = im.getTenant();
  L.w("hero popup, get user: ${id}, ${user}");

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
              child: Text(t.myInfo),
            ),
            onTap: () {},
          ),
          GestureDetector(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(t.myQrcode),
            ),
            onTap: () {},
          ),
          GestureDetector(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(t.mySetting),
            ),
            onTap: () {},
          ),
          GestureDetector(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(t.logout),
            ),
            onTap: () {
              im.logout(GoRouter.of(context));
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
