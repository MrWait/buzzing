import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/models/const.dart';
import 'package:buzzing/models/login_certificate.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/calendar.pb.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/routes/app_navigator.dart';
import 'package:buzzing/res/strings.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/utils/net/apis.dart';
import 'package:buzzing/utils/data_persistence.dart';
import 'package:buzzing/utils/loogger_util.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/widget/im_widget.dart';
import 'package:buzzing/widget/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fixnum/fixnum.dart';

import 'package:intl/intl.dart' show DateFormat;
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

class CalendarLogic extends GetxController {
  final sdk = Get.find<SdkController>();
  var currentDate = DateTime(2025, 9, 2);
  var currentMonth = DateFormat.yMMM().format(DateTime(2025, 9, 2));
  var calendarSearchInput = TextEditingController();
  final firstDay = DateTime(2000, 1, 1);
  final lastDay = DateTime(2030, 12, 30);
  var eventController = EventsController();
  var darkMode = false.obs;
  var calendarMode = CalendarView.day7.obs;

  var myCalendarListMode = true.obs;
  var subscribeCalendarListMode = true.obs;
  var calendarList = <Calendar>[];
  // id > 1: new, 2: my, 3: sub
  var originCalendarList = <Calendar>[];

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, () async {
      await refreshCalendarList();
    });

    sdk.regPushCallback(Command.CALENDAR_PUSH_LIST.value, onPushCalendarList);
  }

  void onPushCalendarList(List<int> data) {
    var push = CalendarPushListRequest.fromBuffer(data);
    L.d("receive push calendar list: $push");
    originCalendarList = push.calendars;
    updateCalendarList();
  }

  Future<void> refreshCalendarList() async {
    var req = CalendarGetListRequest.create();
    var result = await sdk.invokeAsync(
      Command.CALENDAR_GET_LIST,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = CalendarGetListResponse.fromBuffer(result.data!);
      originCalendarList = resp.calendars;
      L.d("get calendar list: ${resp.calendars}");
      updateCalendarList();
    } else {
      L.d("get calendar list error: ${result}");
    }
  }

  void updateCalendarList() {
    var userId = sdk.userId;
    calendarList.clear();
    calendarList.add(Calendar(id: Int64(1)));
    calendarList.add(Calendar(id: Int64(2)));
    var myCalendars = <Calendar>[];
    var subCalendars = <Calendar>[];
    for (var calendar in originCalendarList) {
      var me = calendar.subscribers.subscribers[userId];
      if (calendar.isDefault) {
        myCalendars.add(calendar);
        continue;
      }

      if (me == null) {
        continue;
      }

      if (me.role == CalendarRole.RoleOwner.value) {
        myCalendars.add(calendar);
        continue;
      }
      subCalendars.add(calendar);
    }
    if (myCalendarListMode.value) {
      calendarList.addAll(myCalendars);
    }
    calendarList.add(Calendar(id: Int64(3)));
    if (subscribeCalendarListMode.value) {
      calendarList.addAll(subCalendars);
    }

    update([ConstKey.KeyCalendarList]);
  }

  void resetCreateInfo() {}
}
