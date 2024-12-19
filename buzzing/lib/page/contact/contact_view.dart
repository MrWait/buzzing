import 'package:buzzing/models/const.dart';
import 'package:buzzing/res/strings.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/controller/im.dart';
import 'package:buzzing/widget/header_bar.dart';
import 'package:buzzing/widget/navigate_bar.dart';
import 'package:buzzing/widget/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'contact_logic.dart';

class ContactPage extends StatelessWidget {
  final contactController = Get.find<ContactController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PageStyle.c_FFFFFF,
      body: Row(children: [
        NaviBar(),
        Expanded(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(child: HeaderBarWindows()),
          Expanded(
            child: Row(children: [
              ContactList(),
              Expanded(
                  child: Obx(() => ContactDetail(
                      contactController.mode.value, contactController))),
            ]),
          )
        ])),
      ]),
    );
  }
}

class ContactList extends StatelessWidget {
  final contactController = Get.find<ContactController>();
  @override
  Widget build(BuildContext context) {
    var tenant = contactController.getTenant();
    return Container(
        width: 260,
        color: PageStyle.c_F0F0F0,
        child: Column(
          children: [
            Container(
                alignment: Alignment.topLeft,
                color: PageStyle.c_F0F0F0,
                child: Text(
                  StrRes.contacts,
                  style: PageStyle.ts_000000_14sp,
                )),
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                "${tenant.name}",
                style: PageStyle.ts_000000_13sp,
              ),
            ),
            GestureDetector(
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    StrRes.internalContacts,
                    style: PageStyle.ts_000000_13sp,
                  ),
                ),
                onTap: () async {
                  contactController.mode.value = 1;
                  await contactController.getDeptInfo();
                }),
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                StrRes.externalContacts,
                style: PageStyle.ts_000000_13sp,
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                StrRes.starContacts,
                style: PageStyle.ts_000000_13sp,
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                StrRes.newFriendApplication,
                style: PageStyle.ts_000000_13sp,
              ),
            ),
          ],
        ));
  }
}

class ContactDetail extends StatelessWidget {
  final int mode;
  final ContactController ctl;
  final im = Get.find<ImController>();
  ContactDetail(this.mode, this.ctl);

  @override
  Widget build(BuildContext context) {
    switch (this.mode) {
      case 1:
        return GetBuilder<ContactController>(
            id: ConstKey.KeyContactDetail,
            builder: (c) => ListView.separated(
                itemCount: ctl.listUsers.length,
                itemBuilder: (context, index) {
                  var u = ctl.listUsers[index];
                  return Container(
                    height: 44,
                    child: Row(
                      children: [
                        ProfilePopup(
                            context, u.id, u.avatar, im.getUserVer(u.id).value),
                        Text(u.name),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(height: 0.0)));
      default:
        return Container(child: Text("Contact Detail"));
    }
  }
}
