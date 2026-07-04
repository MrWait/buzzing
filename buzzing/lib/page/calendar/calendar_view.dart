import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/calendar.pb.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/page/calendar/events_view_bar.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/res/theme.dart';
import 'package:buzzing/widget/calendar_creator.dart';
import 'package:buzzing/widget/color_picker.dart';
import 'package:buzzing/widget/header_bar.dart';
import 'package:buzzing/widget/navigate_bar.dart';
import 'package:buzzing/widget/schedule_creator.dart';
import 'package:buzzing/widget/schedule_detail_page.dart';
import 'package:buzzing/widget/search_dialog.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

import 'calendar_logic.dart';
import 'events_planner_draggable_events_view.dart';
import 'events_planner_one_day_view.dart';
import "events_months_view.dart";
import 'events_view_bar.dart';
import "calendar_navigator.dart";

class CalendarPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ctl = ref.watch(calendarLogicProvider);

    ref.listen<CalendarLogic>(calendarLogicProvider, (prev, next) {
      final reminder = next.latestReminder;
      if (reminder != null) {
        next.clearReminder();
        final sched = Schedule.create()
          ..id = reminder.scheduleId
          ..title = reminder.title
          ..startTime = reminder.startTime
          ..endTime = reminder.endTime
          ..location = reminder.location;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
              content: Text(reminder.title.isNotEmpty
                  ? "Reminder: ${reminder.title}"
                  : "Schedule reminder"),
              action: SnackBarAction(
                label: "View",
                onPressed: () {
                  showDialog<bool>(
                    context: context,
                    builder: (_) => ScheduleDetailPage(schedule: sched),
                  );
                },
              ),
              duration: const Duration(seconds: 5),
            ));
      }
    });

    return Scaffold(
      backgroundColor: cs.surface,
      body: Row(children: [
        NaviBar(),
        Expanded(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(child: HeaderBarWindows()),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CalendarDeck(),
              Expanded(
                  child: ListenableBuilder(
                      listenable: ctl,
                      builder: (ctx, _) => Scaffold(
                        appBar: EventPlanerHeader(
                          dateText: "Calendar",
                          onChangeCalendarView: (mode) {
                            ctl.calendarMode = mode;
                            ctl.notifyListeners();
                          },
                          jumpToday: () {

                          },
                        ),
                        body: eventView(context, ctl, ctl.calendarMode),
                      ))),
            ],
          ))
        ]))
      ]),
    );
  }

  Widget eventView(BuildContext context, CalendarLogic ctl, CalendarView mode) {
    switch (mode) {
      case CalendarView.day7:
        return EventsPlannerDraggableEventsView(
          controller: ctl.eventController,
          daysShowed: 7,
          isDarkMode: false,
          dayOnSlotTap: (int index, DateTime exactTime, DateTime roundTime) {
            L.d("day slot tap, $index, $exactTime, $roundTime");
            showDialog<bool>(
                context: context,
                builder: (context) {
                  return const ScheduleCreator(startTime: null);
                });
          },
          onEventTap: (Event event) {
            final s = event.data;
            if (s is Schedule) {
              showDialog<bool>(
                  context: context,
                  builder: (_) => ScheduleDetailPage(schedule: s));
            }
          },
          onDayChange: (DateTime offset) {
            L.d("calendar day changed: ${offset}");
          },
        );
      case CalendarView.month:
        return EventsMonthsView(
          controller: ctl.eventController,
        );
      default:
        return EventsPlannerOneDayView(
          controller: ctl.eventController,
          isDarkMode: false,
        );
    }
  }
}

class CalendarDeck extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctl = ref.watch(calendarLogicProvider);
    return Container(
        width: 260,
        child: Column(children: [
          CalendarNavigator(),
          TextField(
            maxLines: 1,
            controller: ctl.calendarSearchInput,
            decoration: InputDecoration(
              hintText: "Search calendars...",
              prefixIcon: Icon(Icons.search, size: 18),
            ),
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                showDialog<bool>(
                  context: context,
                  builder: (ctx) => CalendarSearchDialog(),
                );
              }
            },
          ),
          Expanded(child: CalendarList()),
        ]));
  }
}

class CalendarList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final bt = Theme.of(context).extension<BuzzingTheme>()!;
    final ctl = ref.watch(calendarLogicProvider);
    return Container(
      width: 260,
      color: bt.mentionBg,
      child: ListView.builder(
        itemCount: ctl.calendarList.length,
        itemBuilder: (context, index) {
          var cal = ctl.calendarList[index];
          var id = cal.id.toInt();
          switch (id) {
            case 1:
              return GestureDetector(
                child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text("+ New Calendar")),
                onTap: () {
                  showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return CalendarCreator();
                      });
                });
            case 2:
              return CalendarListGroup(
                mode: ctl.myCalendarListMode,
                title: "My Calendar",
                onToggle: (mode) {
                  ctl.myCalendarListMode = mode;
                  ctl.updateCalendarList();
                  ctl.notifyListeners();
                },
              );
            case 3:
              return CalendarListGroup(
                mode: ctl.subscribeCalendarListMode,
                title: "Subscribed Calendar",
                onToggle: (mode) {
                  ctl.subscribeCalendarListMode = mode;
                  ctl.updateCalendarList();
                  ctl.notifyListeners();
                },
              );
            default:
              var colorVal = cal.color;
              var dotColor = colorVal != 0
                  ? Color(colorVal)
                  : cs.primary;
              return PopupMenuButton(
                onSelected: (int action) async {
                  switch (action) {
                    case 0:
                      await ctl.toggleCalendarEnable(cal);
                      ctl.notifyListeners();
                      break;
                    case 1:
                      showDialog<bool>(
                          context: context,
                          builder: (context2) => ColorPickerDialog(
                            currentColor: cal.color,
                            onSelected: (newColor) async {
                              await ctl.changeCalendarColor(cal.id, newColor);
                              ctl.notifyListeners();
                            },
                          ));
                      break;
                    case 2:
                      showDialog<bool>(
                          context: context,
                          builder: (context2) => CalendarCreator(
                            editCalendar: cal,
                          ));
                      break;
                    case 3:
                      await ctl.deleteCalendar(cal.id);
                      ctl.notifyListeners();
                      break;
                    case 4:
                      var req = CalendarUpdateRequest.create();
                      req.calendar = cal;
                      req.calendar.public = !cal.public;
                      await ctl.sdk.invokeAsync(Command.CALENDAR_UPDATE, req.writeToBuffer());
                      await ctl.refreshCalendarList();
                      ctl.notifyListeners();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 0,
                      child: Text(cal.enable ? "Disable" : "Enable")),
                  PopupMenuItem(value: 1, child: Text("Change Color")),
                  PopupMenuItem(value: 2, child: Text("Edit")),
                  PopupMenuItem(value: 3, child: Text("Delete")),
                  PopupMenuItem(value: 4, child: Text("Toggle Public")),
                ],
                child: Container(
                  child: Row(
                    children: [
                      Checkbox(
                        value: cal.enable,
                        onChanged: (val) async {
                          await ctl.toggleCalendarEnable(cal);
                          ctl.notifyListeners();
                        },
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(cal.name,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}

class CalendarListGroup extends StatelessWidget {
  final bool mode;
  final String title;
  Function onToggle;

  CalendarListGroup({required mode, required title, required onToggle})
      : mode = mode,
        title = title,
        onToggle = onToggle;

  @override
  Widget build(BuildContext context) {
    var txt = "⌵ " + title;
    if (!mode) {
      txt = "> " + title;
    }
    return GestureDetector(
      child: Container(alignment: Alignment.topLeft, child: Text(txt)),
      onTap: () {
        this.onToggle(!mode);
      },
    );
  }
}
