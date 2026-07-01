import 'package:buzzing/models/const.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/widget/header_bar.dart';
import 'package:buzzing/widget/navigate_bar.dart';
import 'package:buzzing/widget/profile.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'contact_logic.dart';

class ContactPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactController = ref.watch(contactLogicProvider);
    return Scaffold(
      backgroundColor: PageStyle.c_FFFFFF,
      body: Row(
        children: [
          NaviBar(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(child: HeaderBarWindows()),
                Expanded(
                  child: Row(
                    children: [
                      ContactList(),
                      Expanded(
                        child: ListenableBuilder(
                          listenable: contactController,
                          builder: (ctx, _) => ContactDetail(
                            contactController.mode,
                            contactController,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContactList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactController = ref.watch(contactLogicProvider);
    var tenant = contactController.getTenant();
    return Container(
      width: 260,
      color: PageStyle.c_F0F0F0,
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            color: PageStyle.c_F0F0F0,
            child: Text(t.contacts, style: PageStyle.ts_000000_14sp),
          ),
          Container(
            alignment: Alignment.topLeft,
            child: Text("${tenant.name}", style: PageStyle.ts_000000_13sp),
          ),
          GestureDetector(
            child: Container(
              alignment: Alignment.topLeft,
              child: Text(t.internalContacts, style: PageStyle.ts_000000_13sp),
            ),
            onTap: () async {
              L.w("start getDeptInfo");
              contactController.mode = 1;
              contactController.notifyListeners();
              await contactController.getDeptInfo();
            },
          ),
          Container(
            alignment: Alignment.topLeft,
            child: Text(t.externalContacts, style: PageStyle.ts_000000_13sp),
          ),
          Container(
            alignment: Alignment.topLeft,
            child: Text(t.starContacts, style: PageStyle.ts_000000_13sp),
          ),
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              t.newFriendApplication,
              style: PageStyle.ts_000000_13sp,
            ),
          ),
        ],
      ),
    );
  }
}

class ContactDetail extends ConsumerWidget {
  final int mode;
  final ContactController ctl;
  ContactDetail(this.mode, this.ctl);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final im = ref.watch(imProvider);
    switch (this.mode) {
      case 1:
        return ListView.separated(
          itemCount: ctl.listUsers.length,
          itemBuilder: (context, index) {
            var u = ctl.listUsers[index];
            return Container(
              height: 44,
              child: Row(
                children: [
                  ProfilePopup(im, context, u.id, u.avatar, im.getUserVer(u.id)),
                  Text(u.name),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => Divider(height: 0.0),
        );
      default:
        return Container(child: Text("Contact Detail"));
    }
  }
}
