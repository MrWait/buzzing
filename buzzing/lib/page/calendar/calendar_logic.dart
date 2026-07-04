import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/calendar.pb.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:buzzing/widget/calendar_event_utils.dart';
import 'package:flutter/material.dart';

import 'package:fixnum/fixnum.dart';

import 'package:intl/intl.dart' show DateFormat;
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

class CalendarLogic extends ChangeNotifier {
  final SdkController sdk;
  CalendarLogic({required this.sdk});
  var currentDate = DateTime(2025, 9, 2);
  var currentMonth = DateFormat.yMMM().format(DateTime(2025, 9, 2));
  var calendarSearchInput = TextEditingController();
  final firstDay = DateTime(2000, 1, 1);
  final lastDay = DateTime(2030, 12, 30);
  var eventController = EventsController();
  var darkMode = false;
  var calendarMode = CalendarView.day7;

  var myCalendarListMode = true;
  var subscribeCalendarListMode = true;
  var calendarList = <Calendar>[];
  var originCalendarList = <Calendar>[];

  void init() {
    Future.delayed(Duration.zero, () async {
      await refreshCalendarList();
    });

    sdk.regPushCallback(Command.CALENDAR_PUSH_LIST.value, onPushCalendarList);
    sdk.regPushCallback(Command.PUSH_SCHEDULE_REMINDER.value, onScheduleRemind);
    sdk.regPushCallback(Command.PUSH_SCHEDULE_DELETE.value, onScheduleDelete);
  }

  void onPushCalendarList(List<int> data) {
    var push = CalendarPushListRequest.fromBuffer(data);
    L.d("receive push calendar list: $push");
    originCalendarList = push.calendars;
    updateCalendarList();
  }

  ScheduleRemindPush? latestReminder;

  void onScheduleRemind(List<int> data) {
    var push = ScheduleRemindPush.fromBuffer(data);
    L.d("schedule reminder: ${push.title}");
    latestReminder = push;
    notifyListeners();
  }

  void clearReminder() {
    latestReminder = null;
  }

  void onScheduleDelete(List<int> data) {
    var push = ScheduleDeletePush.fromBuffer(data);
    L.d("schedule deleted push: ids=${push.ids}, cycleRuleId=${push.cycleRuleId}");
    eventController.updateCalendarData((cd) {
      var toRemove = <Event>[];
      cd.dayEvents.forEach((day, events) {
        for (var e in events) {
          if (e.data is Schedule && push.ids.contains((e.data as Schedule).id)) {
            toRemove.add(e);
          }
        }
      });
      for (var e in toRemove) {
        cd.removeEvent(e);
      }
    });
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
    if (myCalendarListMode) {
      calendarList.addAll(myCalendars);
    }
    calendarList.add(Calendar(id: Int64(3)));
    if (subscribeCalendarListMode) {
      calendarList.addAll(subCalendars);
    }
  }

  // === Calendar CRUD ===

  Future<void> createCalendar(String name, String desc, int color, bool isPublic) async {
    var req = CalendarCreateRequest.create();
    req.calendar = Calendar.create();
    req.calendar.name = name;
    req.calendar.desc = desc;
    req.calendar.color = color;
    req.calendar.public = isPublic;
    req.calendar.ensureSubscribers();
    req.calendar.subscribers.subscribers[sdk.userId] =
        Calendar_Subscriber(id: sdk.userId, role: CalendarRole.RoleOwner.value);
    var result = await sdk.invokeAsync(Command.CALENDAR_CREATE, req.writeToBuffer());
    if (result.data != null) {
      await refreshCalendarList();
    }
  }

  Future<void> updateCalendar(
      Int64 calendarId, String name, String desc, int color, bool isPublic, bool enable) async {
    var req = CalendarUpdateRequest.create();
    req.calendar = Calendar.create();
    req.calendar.id = calendarId;
    req.calendar.name = name;
    req.calendar.desc = desc;
    req.calendar.color = color;
    req.calendar.public = isPublic;
    req.calendar.enable = enable;
    req.calendar.ensureSubscribers();
    var result = await sdk.invokeAsync(Command.CALENDAR_UPDATE, req.writeToBuffer());
    if (result.data != null) {
      await refreshCalendarList();
    }
  }

  Future<void> deleteCalendar(Int64 calendarId) async {
    var req = CalendarDeleteRequest.create();
    req.id = calendarId;
    await sdk.invokeAsync(Command.CALENDAR_DELETE, req.writeToBuffer());
    await refreshCalendarList();
  }

  Future<void> toggleCalendarEnable(Calendar cal) async {
    cal.enable = !cal.enable;
    await updateCalendar(cal.id, cal.name, cal.desc, cal.color,
        cal.public, cal.enable);
  }

  Future<void> subscribeCalendar(Int64 calendarId) async {
    var req = CalendarSubscribeRequest.create();
    req.id = calendarId;
    await sdk.invokeAsync(Command.CALENDAR_SUBSCRIBE, req.writeToBuffer());
    await refreshCalendarList();
  }

  Future<void> changeCalendarColor(Int64 calendarId, int color) async {
    var cal = originCalendarList.firstWhere((c) => c.id == calendarId);
    await updateCalendar(cal.id, cal.name, cal.desc, color,
        cal.public, cal.enable);
  }

  Future<List<Calendar>> searchCalendar(String key) async {
    var req = CalendarSearchRequest.create();
    req.key = key;
    var result = await sdk.invokeAsync(Command.CALENDAR_SEARCH, req.writeToBuffer());
    if (result.data != null) {
      var resp = CalendarSearchResponse.fromBuffer(result.data!);
      return resp.calendars;
    }
    return [];
  }

  // === Schedule CRUD ===

  Future<void> fetchSchedules(DateTime start, DateTime end) async {
    var enabledIds = <Int64>[];
    for (var cal in originCalendarList) {
      if (cal.enable) {
        enabledIds.add(cal.id);
      }
    }
    if (enabledIds.isEmpty) return;
    var req = SchedulePullByCalendarIdsRequest.create();
    req.calendarIds.addAll(enabledIds);
    req.startTime = Int64(start.millisecondsSinceEpoch);
    req.endTime = Int64(end.millisecondsSinceEpoch);
    var result = await sdk.invokeAsync(
        Command.SCHEDULE_PULL_BY_CALENDAR_IDS, req.writeToBuffer());
    if (result.data != null) {
      var resp = SchedulePullByCalendarIdsResponse.fromBuffer(result.data!);
      L.d("fetched ${resp.schedules.length} schedules");
      eventController.updateCalendarData((data) {
        data.clearAll();
        data.addEvents(resp.schedules.map(scheduleToCalendarEvent).toList());
      });
    }
  }

  Future<void> createSchedule(Calendar calendar, ScheduleCreateRequest req) async {
    var result = await sdk.invokeAsync(Command.SCHEDULE_CREATE, req.writeToBuffer());
    if (result.data != null) {
      await fetchSchedules(currentDate, currentDate.add(Duration(days: 30)));
    }
  }

  Future<void> updateSchedule(ScheduleUpdateRequest req) async {
    await sdk.invokeAsync(Command.SCHEDULE_UPDATE, req.writeToBuffer());
    await fetchSchedules(currentDate, currentDate.add(Duration(days: 30)));
  }

  Future<void> removeSchedule(Int64 id, Int64 cycleId, int modifyScope) async {
    var req = ScheduleRemoveRequest.create();
    req.id = id;
    req.cycleId = cycleId;
    req.modifyScope = modifyScope;
    await sdk.invokeAsync(Command.SCHEDULE_REMOVE, req.writeToBuffer());
    await fetchSchedules(currentDate, currentDate.add(Duration(days: 30)));
  }
}
