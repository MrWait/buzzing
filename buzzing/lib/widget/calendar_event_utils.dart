import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

Event scheduleToCalendarEvent(Schedule s) {
  final start = DateTime.fromMillisecondsSinceEpoch(s.startTime.toInt());
  final end = DateTime.fromMillisecondsSinceEpoch(s.endTime.toInt());
  final color = s.hasCalendarId()
      ? Color(s.color)
      : Colors.blue;
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
