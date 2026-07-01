import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/models/idl/feed.pb.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/sdk.pb.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:buzzing/widget/feedcard.dart';
import 'package:buzzing/res/styles.dart';

import 'package:fixnum/fixnum.dart';

class ContactController extends ChangeNotifier {
  final SdkController sdk;
  final ImController im;
  ContactController({required this.sdk, required this.im});

  var mode = 0;

  List<User> listUsers = [];

  Tenant getTenant() {
    return im.loginUser.tenant;
  }

  Future<void> getDeptInfo() async {
    var list = await im.getDeptInfo(Int64(0));
    if (list != null) {
      listUsers.clear();
      listUsers.addAll(list.users.values);
      listUsers.sort((a, b) => a.name.compareTo(b.name));
      //LW("getDeptInfo ok: ${list}");
    }
    notifyListeners();
  }
}
