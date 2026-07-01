import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/models/const.dart';
import 'package:buzzing/models/login_certificate.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/calendar.pb.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/routes/app_navigator.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/utils/net/apis.dart';
import 'package:buzzing/utils/data_persistence.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/widget/im_widget.dart';
import 'package:buzzing/widget/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fixnum/fixnum.dart';

import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'calendar_logic.dart';

class CalendarNavigator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctl = ref.watch(calendarLogicProvider);
    return Container(
      height: 280,
      width: 260,
      //padding: EdgeInsets.symmetric(horizontal: 10),
      color: PageStyle.c_F0F0F0,
      child: Column(children: [
        Row(
          children: [
            Text(ctl.currentMonth, style: PageStyle.ts_000000_13sp),
            Spacer(),
            TextButton(
              child: Text("<"),
              onPressed: () {},
            ),
            TextButton(
              child: Text(">"),
              onPressed: () {},
            ),
          ],
        ),
        Expanded(
            child: Container(
          child: CalendarCarousel<Event>(
            todayBorderColor: PageStyle.c_10CC64,
            onDayPressed: (date, events) {},
            daysHaveCircularBorder: true,
            showOnlyCurrentMonthDate: false,
            weekendTextStyle: TextStyle(color: Colors.red),
            thisMonthDayBorderColor: PageStyle.c_898989,
            weekFormat: false,
            //height: 420,
            showHeader: false,
            selectedDateTime: ctl.currentDate,
          ),
        )),
      ]),
    );
  }
}
