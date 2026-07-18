import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/calendar.pb.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/page/calendar/events_view_bar.dart';
import 'package:buzzing/page/meeting/meeting_home_logic.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/res/theme.dart';
import 'package:buzzing/widget/calendar_creator.dart';
import 'package:buzzing/widget/color_picker.dart';
import 'package:buzzing/widget/header_bar.dart';
import 'package:buzzing/widget/navigate_bar.dart';
import 'package:buzzing/widget/schedule_creator.dart';
import 'package:buzzing/widget/schedule_detail_page.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:go_router/go_router.dart';

import 'calendar_logic.dart';
import 'events_planner_draggable_events_view.dart';
import 'events_planner_one_day_view.dart';
import "events_months_view.dart";
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
        final isMeeting = reminder.type == 1 && reminder.hasRoomId() && reminder.roomId.toInt() > 0;
        if (isMeeting) {
          final meetingHome = ref.read(meetingHomeLogicProvider);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(
                content: Text(reminder.title.isNotEmpty
                    ? "${t.scheduleReminder}: ${reminder.title}"
                    : t.scheduleReminder),
                action: SnackBarAction(
                  label: t.joinMeeting,
                  onPressed: () async {
                    var ok = await meetingHome.joinMeeting(
                      reminder.roomId.toInt().toString(),
                    );
                    if (ok && context.mounted) {
                      context.go('/meeting');
                    }
                  },
                ),
                duration: const Duration(seconds: 10),
              ));
        } else {
          final sched = Schedule.create()
            ..id = reminder.scheduleId
            ..title = reminder.title
            ..startTime = reminder.startTime
            ..endTime = reminder.endTime
            ..location = reminder.location;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(
                content: Text(reminder.title.isNotEmpty
                    ? "${t.scheduleReminder}: ${reminder.title}"
                    : t.scheduleReminder),
                action: SnackBarAction(
                  label: t.view,
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
                        floatingActionButton: FloatingActionButton(
                          mini: true,
                          onPressed: () {
                            showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return const ScheduleCreator(startTime: null);
                                });
                          },
                          child: const Icon(Icons.add),
                        ),
                        appBar: EventPlanerHeader(
                          dateText: "",
                          onChangeCalendarView: (mode) {
                            ctl.calendarMode = mode;
                            ctl.notifyListeners();
                          },
                          jumpToday: () => ctl.goToToday(),
                          onPrevious: () => ctl.previousMonth(),
                          onNext: () => ctl.nextMonth(),
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
          eventsPlannerKey: ctl.eventsPlannerKey,
          controller: ctl.eventController,
          daysShowed: 7,
          isDarkMode: false,
          dayOnSlotDoubleTap: (int index, DateTime exactTime, DateTime roundTime) {
            L.d("day slot double tap, $index, $exactTime, $roundTime");
            showDialog<bool>(
                context: context,
                builder: (context) {
                  return ScheduleCreator(startTime: roundTime);
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
            ctl.updateViewRange(
              offset,
              offset.add(const Duration(days: 7)),
            );
          },
        );
      case CalendarView.month:
        return EventsMonthsView(
          controller: ctl.eventController,
          onMonthChange: (monthFirstDay) {
            ctl.updateViewRange(
              monthFirstDay,
              DateTime(monthFirstDay.year, monthFirstDay.month + 1),
            );
          },
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
    final cs = Theme.of(context).colorScheme;
    final ctl = ref.watch(calendarLogicProvider);
    return ListenableBuilder(
      listenable: ctl,
      builder: (context, _) {
        return Container(
            width: 260,
            child: Column(children: [
              CalendarNavigator(),
              TextField(
                maxLines: 1,
                controller: ctl.calendarSearchInput,
                decoration: InputDecoration(
                  hintText: t.searchCalendarHint,
                  prefixIcon: Icon(Icons.search, size: 18),
                ),
                onChanged: (val) => ctl.onSearchInput(val),
              ),
              Expanded(
                child: Stack(
                  children: [
                    CalendarList(),
                    if (ctl.isSearchActive)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: Material(
                          elevation: 4,
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(4),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: ctl.searchResults.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(t.noResults,
                                        style: TextStyle(color: cs.onSurfaceVariant)),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: ctl.searchResults.length,
                                    itemBuilder: (ctx, i) {
                                      var cal = ctl.searchResults[i];
                                      var subscribed = ctl.subscribedCalendarIds.contains(cal.id);
                                      return ListTile(
                                        dense: true,
                                        leading: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: cal.color != 0 ? Color(cal.color) : cs.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        title: Text(cal.name, overflow: TextOverflow.ellipsis),
                                        trailing: Icon(
                                          subscribed ? Icons.star : Icons.star_border,
                                          color: subscribed ? Colors.amber : cs.onSurfaceVariant,
                                          size: 20,
                                        ),
                                        onTap: () async {
                                          await ctl.subscribeCalendar(cal.id, !subscribed);
                                          ctl.clearSearch();
                                          ctl.calendarSearchInput.clear();
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ]));
      },
    );
  }
}

class CalendarList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final bt = Theme.of(context).extension<BuzzingTheme>()!;
    final ctl = ref.watch(calendarLogicProvider);
    return ListenableBuilder(
      listenable: ctl,
      builder: (context, _) {
        return Container(
          width: 260,
          color: bt.mentionBg,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog<bool>(
                        context: context,
                        builder: (context) => CalendarCreator());
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(t.newCalendar),
                  ),
                ),
                _Section(
                    title: t.myCalendar,
                  expanded: ctl.myCalendarListMode,
                  onToggle: (v) {
                    ctl.myCalendarListMode = v;
                    ctl.updateCalendarList();
                  },
                  children: ctl.myCalendars
                      .map((cal) => _CalendarRow(cal: cal, ctl: ctl, cs: cs))
                      .toList(),
                ),
                _Section(
                    title: t.subscribedCalendar,
                  expanded: ctl.subscribeCalendarListMode,
                  onToggle: (v) {
                    ctl.subscribeCalendarListMode = v;
                    ctl.updateCalendarList();
                  },
                  children: ctl.subCalendars
                      .map((cal) => _SubscribedCalendarRow(cal: cal, ctl: ctl, cs: cs))
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final bool expanded;
  final ValueChanged<bool> onToggle;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onToggle(!expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(expanded ? "⌵ $title" : "> $title"),
          ),
        ),
        if (expanded) ...children,
      ],
    );
  }
}

class _CalendarRow extends StatelessWidget {
  final Calendar cal;
  final CalendarLogic ctl;
  final ColorScheme cs;

  const _CalendarRow({required this.cal, required this.ctl, required this.cs});

  @override
  Widget build(BuildContext context) {
    var isDefault = cal.id == ctl.sdk.userId;
    Color calColor;
    if (isDefault) {
      calColor = const Color(0xFF2196F3);
    } else {
      calColor = cal.color != 0 ? Color(cal.color) : cs.primary;
    }
    return Container(
      child: Row(
        children: [
          Checkbox(
            value: cal.enable,
            activeColor: calColor,
            checkColor: Colors.white,
            onChanged: (val) async {
              await ctl.toggleCalendarEnable(cal);
            },
          ),
          SizedBox(width: 8),
          Expanded(child: Text(cal.name, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _SubscribedCalendarRow extends StatelessWidget {
  final Calendar cal;
  final CalendarLogic ctl;
  final ColorScheme cs;

  const _SubscribedCalendarRow({required this.cal, required this.ctl, required this.cs});

  @override
  Widget build(BuildContext context) {
    Color calColor = cal.color != 0 ? Color(cal.color) : cs.primary;
    return Container(
      child: Row(
        children: [
          Checkbox(
            value: cal.enable,
            activeColor: calColor,
            checkColor: Colors.white,
            onChanged: (val) async {
              await ctl.toggleCalendarEnable(cal);
            },
          ),
          SizedBox(width: 8),
          Expanded(child: Text(cal.name, overflow: TextOverflow.ellipsis)),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => ctl.subscribeCalendar(cal.id, false),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: t.subscribe,
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_horiz, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onSelected: (int action) async {
              switch (action) {
                case 0:
                  await ctl.toggleCalendarEnable(cal);
                  break;
                case 1:
                  showDialog<bool>(
                      context: context,
                      builder: (context2) => ColorPickerDialog(
                            currentColor: cal.color,
                            onSelected: (newColor) async {
                              await ctl.changeCalendarColor(cal.id, newColor);
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
                  break;
                case 4:
                  var req = CalendarUpdateRequest.create();
                  req.calendar = cal;
                  req.calendar.public = !cal.public;
                  await ctl.sdk.invokeAsync(Command.CALENDAR_UPDATE, req.writeToBuffer());
                  await ctl.refreshCalendarList();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 0, child: Text(cal.enable ? t.disable : t.enable)),
              PopupMenuItem(value: 1, child: Text(t.changeColor)),
              PopupMenuItem(value: 2, child: Text(t.edit)),
              PopupMenuItem(value: 3, child: Text(t.delete)),
              PopupMenuItem(value: 4, child: Text(t.togglePublic)),
            ],
          ),
        ],
      ),
    );
  }
}


