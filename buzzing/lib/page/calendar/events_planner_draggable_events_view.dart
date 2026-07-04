import 'package:buzzing/res/theme.dart';
import 'package:buzzing/utils/extension.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:intl/intl.dart';

class EventsPlannerDraggableEventsView extends StatelessWidget {
  const EventsPlannerDraggableEventsView({
    super.key,
    required this.onDayChange,
    required this.controller,
    required this.daysShowed,
    required this.isDarkMode,
    required this.dayOnSlotTap,
    this.onEventTap,
    this.initialDate,
  });

  final EventsController controller;
  final int daysShowed;
  final bool isDarkMode;
  final Function(int, DateTime, DateTime) dayOnSlotTap;
  final Function(Event)? onEventTap;
  final Function(DateTime) onDayChange;
  final DateTime? initialDate;

  @override
  Widget build(BuildContext context) {
    var heightPerMinute = 1.0;
    var initialVerticalScrollOffset = heightPerMinute * 7 * 60;

    return EventsPlanner(
      controller: controller,
      daysShowed: daysShowed,
      maxPreviousDays: 10,
      maxNextDays: 10,
      initialDate: initialDate,
      heightPerMinute: heightPerMinute,
      initialVerticalScrollOffset: initialVerticalScrollOffset,
      dayParam: DayParam(
        onSlotTap: dayOnSlotTap,
        dayEventBuilder: (event, height, width, heightPerMinute) {
          return draggableEvent(event, height, width);
        },
      ),
      daysHeaderParam: DaysHeaderParam(
        daysHeaderVisibility: daysShowed != 1,
        dayHeaderTextBuilder: (day) => DateFormat("E d").format(day),
        daysHeaderColor: Color(0xFFA2C9F8),
        topLeftCellBuilder: (day) => Center(
          child: Text(
            DateFormat("MMM").format(day),
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      fullDayParam: FullDayParam(
        fullDayEventsBarHeight: 50,
      ),
      onDayChange: onDayChange,
    );
  }

  DefaultDayHeader getDayHeader(
      DateTime day, bool isToday, BuildContext context) {
    return DefaultDayHeader(
      dayText: DateFormat("E d").format(day),
      isToday: isToday,
      foregroundColor:
          //isDarkMode ? Theme.of(context).colorScheme.primary : null,
          Theme.of(context).colorScheme.primary,
    );
  }

  DraggableEventWidget draggableEvent(
    Event event,
    double height,
    double width,
  ) {
    return DraggableEventWidget(
      event: event,
      height: height,
      width: width,
      onDragEnd: (columnIndex, exactStart, exactEnd, roundStart, roundEnd) {
        controller.updateCalendarData(
          (calendarData) => calendarData.moveEvent(event, roundStart),
        );
      },
      child: DefaultDayEvent(
        height: height,
        width: width,
        title: event.title,
        description: event.description,
        color: isDarkMode ? event.color.onPastel : event.color,
        textColor: isDarkMode ? event.textColor.pastel : event.textColor,
        onTap: () {
          if (onEventTap != null) {
            onEventTap!(event);
          } else {
            L.d("tap ${event.uniqueId}");
          }
        },
      ),
    );
  }
}
