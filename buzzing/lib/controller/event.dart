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

enum GlobalEvent {
  Logined(1),
  MessageUpdate(2),
  FeedlistUpdate(3);

  final int num;

  const GlobalEvent(this.num);
}

class EventController extends GetxController {
  var eventHandler = Map<int, Map<String, Function>>();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    LW("event controller close");
    super.onClose();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    LW("event controller init");
    super.onInit();
  }

  void regEventHandler(int event, String tag, Function f) {
    var m = eventHandler[event];
    if (m == null) {
      eventHandler[event] = Map<String, Function>();
      m = eventHandler[event];
    }
    m?[tag] = f;
  }

  void removeEventHandler(int event, String tag) {
    var m = eventHandler[event];
    if (m != null) {
      m.remove(tag);
    }
  }

  void emitEvent(int event) {
    var m = eventHandler[event];
    m?.forEach((tag, f) {
      f();
    });
  }
}
