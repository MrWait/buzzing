//import 'package:example/utils.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

class EventsMonthsView extends StatelessWidget {
  const EventsMonthsView({
    super.key,
    required this.controller,
    this.onMonthChange,
  });

  final EventsController controller;
  final void Function(DateTime monthFirstDay)? onMonthChange;

  @override
  Widget build(BuildContext context) {
    return EventsMonths(
      controller: controller,
      automaticAdjustScrollToStartOfMonth: true,
      onMonthChange: onMonthChange,
      daysParam: DaysParam(
        // custom builder : add drag and drop
        dayEventBuilder: (event, width, height) {
          return DraggableMonthEvent(
            child: getCustomEvent(context, width, height, event),
            onDragEnd: (DateTime day) {
              controller.updateCalendarData((data) => move(data, event, day));
            },
          );
        },
      ),
    );
  }

  SizedBox getCustomEvent(
    BuildContext context,
    double? width,
    double? height,
    Event event,
  ) {
    return SizedBox(
      width: width,
      height: height,
      child: DefaultMonthDayEvent(
        event: event,
        onTap: () => showSnack(context, "Tap : ${event.title}"),
      ),
    );
  }

  move(CalendarData data, Event event, DateTime newDay) {
    data.moveEvent(
      event,
      newDay.copyWith(
        hour: event.effectiveStartTime!.hour,
        minute: event.effectiveStartTime!.minute,
      ),
    );
  }
}

showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.surface),
      ),
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      duration: Duration(seconds: 1),
      showCloseIcon: true,
      closeIconColor: Theme.of(context).colorScheme.surface,
    ),
  );
}
