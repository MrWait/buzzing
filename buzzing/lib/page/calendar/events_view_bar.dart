import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/model.dart';
import 'package:flutter/material.dart';

class EventPlanerHeader extends StatelessWidget implements PreferredSizeWidget {
  final String dateText;
  final Function(CalendarView calendarMode)? onChangeCalendarView;
  final VoidCallback? jumpToday;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  EventPlanerHeader({
    required this.dateText,
    this.onChangeCalendarView,
    this.jumpToday,
    this.onPrevious,
    this.onNext,
  });

  @override
  Size get preferredSize => Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).colorScheme.primary;
    return AppBar(
      title: Row(
        children: [
          TextButton(
            child: Text(t.today),
            onPressed: jumpToday,
          ),
          TextButton(
            child: Text("<"),
            onPressed: onPrevious,
          ),
          TextButton(
            child: Text(">"),
            onPressed: onNext,
          ),
          Text(
            this.dateText,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
      scrolledUnderElevation: 0.0,
      toolbarOpacity: 1,
      elevation: 0,
      centerTitle: false,
      actions: [
        TextButton(
          child: Text(t.day),
          onPressed: () {
            if (onChangeCalendarView != null) {
              onChangeCalendarView!(CalendarView.day);
            }
          },
        ),
        TextButton(
          child: Text(t.week),
          onPressed: () {
            if (onChangeCalendarView != null) {
              onChangeCalendarView!(CalendarView.day7);
            }
          },
        ),
        TextButton(
          child: Text(t.month),
          onPressed: () {
            if (onChangeCalendarView != null) {
              onChangeCalendarView!(CalendarView.month);
            }
          },
        ),
      ],
    );
  }
}
