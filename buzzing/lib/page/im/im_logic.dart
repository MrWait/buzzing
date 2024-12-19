import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/models/idl/feed.pb.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/sdk.pb.dart';
import 'package:buzzing/utils/loogger_util.dart';
import 'package:buzzing/widget/feedcard.dart';
import 'package:buzzing/res/styles.dart';
import 'package:get/get.dart';
import 'package:fixnum/fixnum.dart';

class ImLogic extends GetxController {
  final sdk = Get.find<SdkController>();
  // text editing controllors

  // obs
  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    LD("im logic close");
    super.onClose();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }
}
