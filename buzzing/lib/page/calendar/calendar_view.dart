import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/calendar.pb.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/page/calendar/events_view_bar.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/res/theme.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/routes/app_routes.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/utils/platform.dart';
import 'package:buzzing/widget/calendar_creator.dart';
import 'package:buzzing/widget/color_picker.dart';
import 'package:buzzing/widget/header_bar.dart';
import 'package:buzzing/widget/mobile_drawer.dart';
import 'package:buzzing/widget/navigate_bar.dart';
import 'package:buzzing/widget/schedule_creator.dart';
import 'package:buzzing/widget/schedule_detail_page.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_calendar_carousel/classes/event.dart' as carousel_event;
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;

import 'calendar_logic.dart';
import 'events_planner_draggable_events_view.dart';
import 'events_planner_one_day_view.dart';
import "events_months_view.dart";
import "calendar_navigator.dart";

class CalendarPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isMobile) {
      return const _CalendarMobile();
    }
    return const _CalendarDesktop();
  }
}

/// Desktop: original 3-column layout (NaviBar + CalendarDeck + event view)
class _CalendarDesktop extends ConsumerWidget {
  const _CalendarDesktop();

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

/// Mobile: full-screen calendar with title bar + endDrawer settings
class _CalendarMobile extends ConsumerWidget {
  const _CalendarMobile();

  void _showMiniCalendar(BuildContext context, CalendarLogic ctl) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setInnerState) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Spacer(),
                        Text(ctl.currentMonth,
                            style: Theme.of(context).textTheme.titleMedium),
                        IconButton(
                          icon: const Icon(Icons.chevron_left, size: 20),
                          onPressed: () => ctl.previousMonth(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, size: 20),
                          onPressed: () => ctl.nextMonth(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 280,
                    child: CalendarCarousel<carousel_event.Event>(
                      todayBorderColor: Theme.of(context).extension<BuzzingTheme>()!.success,
                      onDayPressed: (date, events) {
                        ctl.goToDate(date);
                        Navigator.of(ctx).pop();
                      },
                      daysHaveCircularBorder: true,
                      showOnlyCurrentMonthDate: false,
                      weekendTextStyle: const TextStyle(color: Colors.red),
                      thisMonthDayBorderColor: cs.onSurfaceVariant,
                      weekFormat: false,
                      showHeader: false,
                      selectedDateTime: ctl.currentDate,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ctl = ref.watch(calendarLogicProvider);
    final im = ref.watch(imProvider);
    final user = im.loginUser.user;
    final avatarUrl = CommonUtils.fixResourceUrl(user.avatar);
    final userName = user.name.isNotEmpty ? user.name : "?";

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

    final dateText = DateFormat.yMMMd().format(ctl.currentDate);
    final leftDrawer = buildMobileDrawer(context, ref);
    final rightDrawer = _CalendarDrawer(ctl: ctl, cs: cs, tt: tt, context: context);

    return Scaffold(
      drawer: leftDrawer,
      endDrawer: rightDrawer,
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
      body: Builder(
        builder: (ctx) => SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: cs.outlineVariant, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Scaffold.of(ctx).openDrawer(),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundImage: avatarUrl.isNotEmpty
                            ? CachedNetworkImageProvider(avatarUrl)
                            : null,
                        child: avatarUrl.isEmpty
                            ? Text(userName[0], style: tt.bodySmall)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showMiniCalendar(context, ctl),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(dateText, style: tt.titleSmall),
                          Icon(Icons.arrow_drop_down, size: 20, color: cs.onSurfaceVariant),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.gps_fixed, size: 18),
                      onPressed: () => ctl.goToToday(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: IconButton.styleFrom(
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search, size: 20),
                      onPressed: () => context.push(AppRoute.SEARCH),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: IconButton.styleFrom(
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.calendar_month_outlined, size: 20),
                      onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: IconButton.styleFrom(
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: ctl,
                  builder: (ctx, _) => eventView(ctx, ctl, ctl.calendarMode),
                ),
              ),
            ],
          ),
        ),
      ),
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

/// Calendar settings drawer (EndDrawer on mobile)
class _CalendarDrawer extends StatelessWidget {
  final CalendarLogic ctl;
  final ColorScheme cs;
  final TextTheme tt;
  final BuildContext context;

  const _CalendarDrawer({
    required this.ctl,
    required this.cs,
    required this.tt,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // View switcher
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ViewSwitcherButton(
                    icon: Icons.calendar_view_day,
                    label: t.day,
                    selected: ctl.calendarMode == CalendarView.day,
                    onTap: () {
                      ctl.calendarMode = CalendarView.day;
                      ctl.notifyListeners();
                      Navigator.of(context).pop();
                    },
                  ),
                  _ViewSwitcherButton(
                    icon: Icons.calendar_view_week,
                    label: t.week,
                    selected: ctl.calendarMode == CalendarView.day7,
                    onTap: () {
                      ctl.calendarMode = CalendarView.day7;
                      ctl.notifyListeners();
                      Navigator.of(context).pop();
                    },
                  ),
                  _ViewSwitcherButton(
                    icon: Icons.calendar_month,
                    label: t.month,
                    selected: ctl.calendarMode == CalendarView.month,
                    onTap: () {
                      ctl.calendarMode = CalendarView.month;
                      ctl.notifyListeners();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Add calendar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(t.newCalendar),
                  onPressed: () => _showAddCalendarSheet(context),
                ),
              ),
            ),
            const Divider(height: 1),
            // Calendar list
            Expanded(
              child: CalendarList(),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('设置'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCalendarSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.rss_feed_outlined),
              title: const Text('订阅日历'),
              onTap: () {
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: Text(t.newCalendar),
              onTap: () {
                Navigator.of(ctx).pop();
                showDialog<bool>(
                  context: context,
                  builder: (_) => CalendarCreator(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(t.cancel),
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewSwitcherButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ViewSwitcherButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected ? cs.primary : cs.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}

/// Left sidebar (desktop only)
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

/// Calendar list with "我管理的" and "我订阅的" sections
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
          color: bt.mentionBg,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
