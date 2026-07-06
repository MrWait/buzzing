import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/res/theme.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;

class CalendarNavigator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bt = Theme.of(context).extension<BuzzingTheme>()!;
    final ctl = ref.watch(calendarLogicProvider);
    return Container(
      height: 280,
      width: 260,
      color: cs.surfaceVariant,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(t.calendar, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          ),
        ),
        Row(
          children: [
            const Spacer(),
            Text(ctl.currentMonth, style: tt.bodyMedium?.copyWith(fontSize: 13)),
            TextButton(
              child: Text("<"),
              onPressed: () => ctl.previousMonth(),
            ),
            TextButton(
              child: Text(">"),
              onPressed: () => ctl.nextMonth(),
            ),
          ],
        ),
        Expanded(
            child: Container(
          child: CalendarCarousel<Event>(
            todayBorderColor: bt.success,
            onDayPressed: (date, events) => ctl.goToDate(date),
            daysHaveCircularBorder: true,
            showOnlyCurrentMonthDate: false,
            weekendTextStyle: TextStyle(color: Colors.red),
            thisMonthDayBorderColor: cs.onSurfaceVariant,
            weekFormat: false,
            showHeader: false,
            selectedDateTime: ctl.currentDate,
          ),
        )),
      ]),
    );
  }
}
