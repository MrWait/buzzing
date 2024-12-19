import 'package:example/data.dart';
import 'package:example/extension.dart';
import 'package:example/utils.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsPlannerMultiColumnSchedulerView extends StatefulWidget {
  const EventsPlannerMultiColumnSchedulerView({
    super.key,
    required this.isDarkMode,
  });

  final bool isDarkMode;

  @override
  State<EventsPlannerMultiColumnSchedulerView> createState() =>
      _EventsPlannerMultiColumnSchedulerViewState();
}

class _EventsPlannerMultiColumnSchedulerViewState
    extends State<EventsPlannerMultiColumnSchedulerView> {
  GlobalKey<EventsPlannerState> oneDayViewKey = GlobalKey<EventsPlannerState>();
  late double heightPerMinute;
  late double initialVerticalScrollOffset;
  late DateTime selectedDay;
  var controller = EventsController()
    ..updateCalendarData((calendarData) {
      calendarData.addEvents(multiColumnEvents);
    });

  @override
  void initState() {
    super.initState();
    selectedDay = controller.focusedDay;
    heightPerMinute = 1.0;
    initialVerticalScrollOffset = heightPerMinute * 7 * 60;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 20),
        tableCalendar(),
        Divider(),
        Expanded(
          child: EventsPlanner(
            key: oneDayViewKey,
            controller: controller,
            daysShowed: 1,
            heightPerMinute: heightPerMinute,
            initialVerticalScrollOffset: initialVerticalScrollOffset,
            daySeparationWidth: 10,

            // header
            daysHeaderParam: DaysHeaderParam(
              daysHeaderVisibility: false,
              daysHeaderHeight: 70,
              daysHeaderColor: Theme.of(context).colorScheme.surface,
            ),

            // custom column bar decoration
            fullDayParam: FullDayParam(
              fullDayEventsBarDecoration: customColumsBarDecoration(context),
            ),

            // personalize columns
            columnsParam: ColumnsParam(
              columns: 7,
              maxColumns: 3,
              columnsWidthRatio: List.generate(7, (i) => 1 / 3),
              columnHeaderBuilder: (day, isToday, columIndex, columnWidth) {
                return Avatar(columnWidth: columnWidth, columIndex: columIndex);
              },
            ),

            // personalize offTimes per column
            offTimesParam: customColumnOffTimes(context),
            onDayChange: (newDay) => setState(() => selectedDay = newDay),

            // event cell
            dayParam: DayParam(
              dayEventBuilder: (event, height, width, heightPerMinute) =>
                  EventWidget(controller, event, height, width),
              onSlotTap: (columnIndex, exactDateTime, roundDateTime) =>
                  showSnack(context, "Slot Tap column = ${columnIndex}"),
              todayColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration customColumsBarDecoration(BuildContext context) {
    return BoxDecoration(
      border: Border(
        top: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        bottom: BorderSide(color: Colors.black12),
      ),
    );
  }

  OffTimesParam customColumnOffTimes(BuildContext context) {
    return OffTimesParam(
      offTimesAllDaysPainter:
          (column, day, isToday, heightPerMinute, ranges, color) {
        var offTimesDefaultColor = widget.isDarkMode
            ? Theme.of(context).colorScheme.surface.lighten(0.03)
            : const Color(0xFFF4F4F4);
        return OffSetAllDaysPainter(
          isToday,
          paintToday: true,
          heightPerMinute,
          column == 0 ? ranges : getHalfTimeRange(),
          offTimesDefaultColor,
        );
      },
    );
  }

  TableCalendar tableCalendar() {
    return TableCalendar(
      firstDay: selectedDay.subtract(Duration(days: 365)),
      lastDay: selectedDay.add(Duration(days: 365)),
      focusedDay: selectedDay,
      calendarFormat: CalendarFormat.week,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          this.selectedDay = selectedDay;
        });
        controller.updateFocusedDay(selectedDay);
        oneDayViewKey.currentState?.jumpToDate(selectedDay);
      },
      headerVisible: false,
      weekNumbersVisible: true,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        markerSize: 7,
        todayDecoration: BoxDecoration(
          color: Colors.blueGrey,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  List<OffTimeRange> getHalfTimeRange() => [
        OffTimeRange(
          TimeOfDay(hour: 0, minute: 0),
          TimeOfDay(hour: 9, minute: 0),
        ),
        OffTimeRange(
          TimeOfDay(hour: 13, minute: 0),
          TimeOfDay(hour: 24, minute: 0),
        ),
      ];
}

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.columnWidth,
    required this.columIndex,
  });

  final double columnWidth;
  final int columIndex;

  @override
  Widget build(BuildContext context) {
    var name = switch (columIndex) {
      0 => 'Suzy',
      1 => 'Jose',
      2 => 'Michelle',
      3 => 'John',
      4 => 'Blaise',
      5 => 'Jane',
      6 => 'Alfred',
      int() => '',
    };
    var imageUrl = switch (columIndex) {
      0 => 'https://randomuser.me/api/portraits/thumb/women/88.jpg',
      1 => 'https://randomuser.me/api/portraits/thumb/men/11.jpg',
      2 => 'https://randomuser.me/api/portraits/thumb/women/85.jpg',
      3 => 'https://randomuser.me/api/portraits/thumb/men/88.jpg',
      4 => 'https://randomuser.me/api/portraits/thumb/men/12.jpg',
      5 => 'https://randomuser.me/api/portraits/thumb/women/18.jpg',
      6 => 'https://randomuser.me/api/portraits/thumb/men/90.jpg',
      int() => '',
    };

    return Container(
      width: columnWidth,
      child: Column(
        children: [
          ClipOval(
            child: Image.network(
              imageUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          Text(name, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class EventWidget extends StatelessWidget {
  const EventWidget(
    this.controller,
    this.event,
    this.height,
    this.width,
  );

  final EventsController controller;
  final Event event;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return DraggableEventWidget(
      event: event,
      height: height,
      width: width,
      onDragEnd: (columnIndex, exactStart, exactEnd, roundStart, roundEnd) {
        controller.updateCalendarData(
          (data) => data.updateEvent(
            oldEvent: event,
            newEvent: event.copyWith(
              columnIndex: columnIndex,
              startTime: roundStart,
              endTime: roundEnd,
            ),
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            height: height,
            width: width,
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Container(
                  width: 5,
                  color: event.color,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            getSlotHourText(event.startTime, event.endTime!),
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            event.title ?? "",
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 2,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            event.description ?? "",
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getSlotHourText(DateTime start, DateTime end) {
    return start.hour.toString().padLeft(2, '0') +
        ":" +
        start.hour.toString().padLeft(2, '0') +
        " - " +
        end.hour.toString().padLeft(2, '0') +
        ":" +
        end.hour.toString().padLeft(2, '0');
  }
}
