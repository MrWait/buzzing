import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

const _defaultCalColor = 0xFF2196F3;

Map<int, int> buildCalColorMap(List<Calendar> cl, int userId) {
  var m = <int, int>{};
  for (var c in cl) {
    m[c.id.toInt()] = c.color;
  }
  // 默认日历固定色
  m[userId] = _defaultCalColor;
  return m;
}

Event scheduleToCalendarEvent(Schedule s, Map<int, int> calColors, int userId) {
  final start = DateTime.fromMillisecondsSinceEpoch(s.startTime.toInt());
  final end = DateTime.fromMillisecondsSinceEpoch(s.endTime.toInt());
  final calId = s.calendarId.toInt();
  Color color;
  if (calId == userId) {
    color = const Color(_defaultCalColor);
  } else if (calColors.containsKey(calId)) {
    var cv = calColors[calId]!;
    color = cv != 0 ? Color(cv) : Colors.blue;
  } else {
    color = s.color != 0 ? Color(s.color) : Colors.blue;
  }
  return Event(
    startTime: start,
    endTime: end,
    isFullDay: s.fullDay,
    title: s.title,
    description: s.desc,
    color: color,
    textColor: Colors.white,
    data: s,
  );
}
