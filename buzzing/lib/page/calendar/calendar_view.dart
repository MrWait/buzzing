import 'package:buzzing/models/const.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/page/calendar/events_view_bar.dart';
import 'package:buzzing/res/strings.dart';
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
import 'package:buzzing/utils/loogger_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//import 'package:flutter_calendar_carousel/classes/event.dart';
//import 'package:flutter_calendar_carousel/classes/event_list.dart';
//import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
//    show CalendarCarousel;

//import 'package:table_calendar/table_calendar.dart';
//import 'package:infinite_calendar_view/infinite_calendar_view.dart';

import 'calendar_logic.dart';
import 'events_planner_draggable_events_view.dart';
import 'events_planner_one_day_view.dart';
import "events_months_view.dart";
import 'events_view_bar.dart';
import "calendar_navigator.dart";

class CalendarPage extends StatelessWidget {
  final ctl = Get.find<CalendarLogic>();
  @override
  Widget build(BuildContext context) {
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
                  child: Obx(() => Scaffold(
                        appBar: EventPlanerHeader(
                          dateText: "Calendar",
                          onChangeCalendarView: (mode) {
                            ctl.calendarMode.value = mode;
                          },
                          jumpToday: () {

                          },
                        ),
                        //child: CalendarDetail(),
                        body: eventView(ctl.calendarMode.value),
                      ))),
            ],
          ))
        ]))
      ]),
    );
  }

  Widget eventView(CalendarView mode) {
    switch (mode) {
      case CalendarView.day7:
        return EventsPlannerDraggableEventsView(
          controller: ctl.eventController,
          daysShowed: 7,
          isDarkMode: false,
          dayOnSlotTap: onDaySlotTap,
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

  void onDaySlotTap(int index, DateTime exactTime, DateTime roundTime) {
    L.d("day slot tap, $index, $exactTime, $roundTime");
    showDialog<bool>(
        context: Get.context!,
        builder: (context) {
          return ScheduleCreator(startTime: exactTime);
        });
    //var events = <Event>[];
    //events.add(Event(startTime: DateTime(2025, 9, 16), isFullDay: true));
    //eventController.calendarData.addEvents(events);
    //eventController.updateCalendarData((data) {});
  }
}

class CalendarDeck extends StatelessWidget {
  final ctl = Get.find<CalendarLogic>();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 260,
        //color: PageStyle.c_71BCFF,
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

class CalendarList extends StatelessWidget {
  var ctl = Get.find<CalendarLogic>();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      //height: 300,
      color: PageStyle.c_F1F7FF,
      child: GetBuilder<CalendarLogic>(
          id: ConstKey.KeyCalendarList,
          builder: (c) => ListView.builder(
              itemCount: c.calendarList.length,
              itemBuilder: (context, index) {
                var cal = c.calendarList[index];
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
                      mode: ctl.myCalendarListMode.value,
                      title: "My Calendar",
                      onToggle: (mode) {
                        ctl.myCalendarListMode.value = mode;
                        ctl.updateCalendarList();
                      },
                    );
                  case 3:
                    return CalendarListGroup(
                      mode: ctl.subscribeCalendarListMode.value,
                      title: "Subscribed Calendar",
                      onToggle: (mode) {
                        ctl.subscribeCalendarListMode.value = mode;
                        ctl.updateCalendarList();
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
                    ));
                }
              })),
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

/*
class CalendarDetail extends StatelessWidget {
  final ctl = Get.find<CalendarLogic>();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: PageStyle.c_A2A3A5,
      child: Column(
        children: [
          Container(
            child: Text("CalendarDetail"),
            color: PageStyle.c_2576FC,
            alignment: Alignment.topLeft,
          ),
          TableCalendar(
            firstDay: ctl.firstDay,
            lastDay: ctl.lastDay,
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.week,
          ),
        ],
      ),
    );
  }
}
*/
