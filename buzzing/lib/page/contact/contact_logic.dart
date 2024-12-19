import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:buzzing/models/const.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/models/idl/feed.pb.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/sdk.pb.dart';
import 'package:buzzing/utils/loogger_util.dart';
import 'package:buzzing/widget/feedcard.dart';
import 'package:buzzing/res/styles.dart';
import 'package:get/get.dart';
import 'package:fixnum/fixnum.dart';

class ContactController extends GetxController {
  final sdk = Get.find<SdkController>();
  final im = Get.find<ImController>();
  // text editing controllors

  var mode = 0.obs;

  List<User> listUsers = [];

  Tenant getTenant() {
    return im.loginUser.tenant;
  }

  Future<void> getDeptInfo() async {
    var list = await im.getDeptInfo(Int64(0));
    if (list != null) {
      listUsers.clear();
      listUsers.addAll(list.users.values);
      listUsers.sortBy((u) {
        return u.name;
      });
    }
    update([ConstKey.KeyContactDetail]);
  }

  // obs
  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    LD("contact logic close");
    super.onClose();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }
}
