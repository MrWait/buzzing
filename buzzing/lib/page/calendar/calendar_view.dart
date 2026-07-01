import 'package:buzzing/models/const.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/page/calendar/events_view_bar.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/widget/button.dart';
import 'package:buzzing/widget/calendar_creator.dart';
import 'package:buzzing/widget/code_input_box.dart';
import 'package:buzzing/widget/debounce_button.dart';
import 'package:buzzing/widget/header_bar.dart';
import 'package:buzzing/widget/navigate_bar.dart';
import 'package:buzzing/widget/phone_input_box.dart';
import 'package:buzzing/widget/pwd_input_box.dart';
import 'package:buzzing/widget/schedule_creator.dart';
import 'package:buzzing/widget/touch_close_keyboard.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'calendar_logic.dart';
import 'events_planner_draggable_events_view.dart';
import 'events_planner_one_day_view.dart';
import "events_months_view.dart";
import 'events_view_bar.dart';
import "calendar_navigator.dart";

class CalendarPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctl = ref.watch(calendarLogicProvider);
    return Scaffold(
      backgroundColor: PageStyle.c_FFFFFF,
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
                  return ScheduleCreator(startTime: exactTime);
                });
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
          ),
          Expanded(child: CalendarList()),
        ]));
  }
}

class CalendarList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctl = ref.watch(calendarLogicProvider);
    return Container(
      width: 260,
      color: PageStyle.c_F1F7FF,
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
              return Container(
                child: Row(
                  children: [
                    Checkbox(
                      value: cal.enable,
                      onChanged: (val) {},
                    ),
                    Text(cal.name),
                  ],
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
