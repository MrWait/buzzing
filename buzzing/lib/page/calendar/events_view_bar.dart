import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/utils/platform.dart';
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
  Size get preferredSize => Size.fromHeight(isMobile ? 36 : 60);

  @override
  Widget build(BuildContext context) {
    if (isMobile) return _buildMobile(context);
    return _buildDesktop(context);
  }

  Widget _buildDesktop(BuildContext context) {
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

  Widget _buildMobile(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: onPrevious,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: onNext,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36),
          ),
        ],
      ),
    );
  }
}
