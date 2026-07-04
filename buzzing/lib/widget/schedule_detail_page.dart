import 'package:buzzing/page/calendar/calendar_logic.dart';
import 'package:buzzing/widget/modify_scope_dialog.dart';
import 'package:buzzing/widget/schedule_creator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:intl/intl.dart';
import 'package:buzzing/utils/logger_util.dart' show L;

class ScheduleDetailPage extends ConsumerWidget {
  final Schedule schedule;

  const ScheduleDetailPage({super.key, required this.schedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctl = ref.read(calendarLogicProvider);
    final s = schedule;
    final hasCycle = s.hasCycle() || s.cycleRuleId.toInt() > 0;
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
    final startDT = DateTime.fromMillisecondsSinceEpoch(s.startTime.toInt());
    final endDT = DateTime.fromMillisecondsSinceEpoch(s.endTime.toInt());

    return AlertDialog(
      title: Text(s.title.isNotEmpty ? s.title : "(No title)"),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _infoRow(Icons.access_time, s.fullDay ? "All day" : "${dateFmt.format(startDT)} - ${dateFmt.format(endDT)}"),
        if (s.desc.isNotEmpty) _infoRow(Icons.description, s.desc),
        if (s.location.isNotEmpty) _infoRow(Icons.location_on, s.location),
        if (hasCycle) _infoRow(Icons.repeat, _recurrenceLabel(s)),
        if (s.notifyTime.isNotEmpty) _infoRow(Icons.notifications, s.notifyTime.map((m) {
          if (m == 0) return "At time";
          if (m < 60) return "${m} min";
          if (m < 1440) return "${m ~/ 60} hr";
          return "${m ~/ 1440} day";
        }).join(", ")),
      ]),
      actions: [
        TextButton(
          child: const Text("Close"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(s.cycleRuleId.toInt() > 0 ? "Edit" : "Edit"),
          onPressed: () async {
            if (hasCycle) {
              final scope = await showDialog<int>(context: context, builder: (_) => const ModifyScopeDialog());
              if (scope == null) return;
              L.d("edit scope: $scope");
            }
            if (!context.mounted) return;
            await showDialog<bool>(
              context: context,
              builder: (_) => ScheduleCreator(editSchedule: s),
            );
          },
        ),
        TextButton(
          child: Text("Delete", style: TextStyle(color: Colors.red)),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Delete schedule"),
                content: Text(hasCycle ? "Are you sure you want to delete this schedule?" : 'Delete "${s.title}"?'),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Cancel")),
                  TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                ],
              ),
            );
            if (confirmed != true) return;
            var scope = 1;
            if (hasCycle) {
              final result = await showDialog<int>(context: context, builder: (_) => const ModifyScopeDialog(isDelete: true));
              if (result == null) return;
              scope = result;
            }
            if (context.mounted) {
              await ctl.removeSchedule(s.id, s.cycleRuleId, scope);
              L.d("schedule deleted");
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ]),
    );
  }

  String _recurrenceLabel(Schedule s) {
    if (!s.hasCycle()) return "";
    final rule = s.cycle.rule;
    final typeStr = {
      1: "Daily", 2: "Weekly", 3: "Monthly", 5: "Yearly"
    }[rule.cycleType] ?? "Repeating";
    return "Every $typeStr";
  }
}
