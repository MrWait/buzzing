import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/provider/sdk_provider.dart';
import 'package:buzzing/page/calendar/calendar_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/calendar.pb.dart';
import 'package:intl/intl.dart';
import 'package:fixnum/fixnum.dart';
import 'package:buzzing/utils/screen_ext.dart';

class ScheduleCreator extends ConsumerStatefulWidget {
  final DateTime? startTime;
  final Calendar? selectedCalendar;
  final Schedule? editSchedule;

  const ScheduleCreator({this.startTime, this.selectedCalendar, this.editSchedule});

  @override
  _ScheduleCreatorState createState() => _ScheduleCreatorState();
}

class _ScheduleCreatorState extends ConsumerState<ScheduleCreator> {
  late SdkController sdk;
  late CalendarLogic calendarLogic;
  late List<Calendar> calendars;

  var titleCtrl = TextEditingController();
  var descCtrl = TextEditingController();
  var locationCtrl = TextEditingController();

  Int64? selectedCalendarId;
  var isAllDay = false;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  int startSlot = 0;
  int endSlot = 1;

  var recurrenceType = "None";
  var recurrenceIntervalCtrl = TextEditingController(text: "1");
  var recurrenceEndType = "Never";
  var recurrenceCountCtrl = TextEditingController(text: "10");
  var recurrenceEndDate = DateTime.now().add(const Duration(days: 365));
  var weekDays = <int>[];
  var reminderMinutes = <int>[];

  bool get isEditing => widget.editSchedule != null;

  static const timeSlots = ['00:00','00:30','01:00','01:30','02:00','02:30','03:00','03:30','04:00','04:30','05:00','05:30','06:00','06:30','07:00','07:30','08:00','08:30','09:00','09:30','10:00','10:30','11:00','11:30','12:00','12:30','13:00','13:30','14:00','14:30','15:00','15:30','16:00','16:30','17:00','17:30','18:00','18:30','19:00','19:30','20:00','20:30','21:00','21:30','22:00','22:30','23:00','23:30'];

  @override
  void initState() {
    super.initState();
    sdk = ref.read(sdkProvider);
    calendarLogic = ref.read(calendarLogicProvider);
    calendars = calendarLogic.originCalendarList.where((c) => c.enable).toList();

    if (widget.editSchedule != null) {
      final s = widget.editSchedule!;
      titleCtrl.text = s.title;
      descCtrl.text = s.desc;
      locationCtrl.text = s.location;
      selectedCalendarId = s.calendarId;
      isAllDay = s.fullDay;
      startDate = DateTime.fromMillisecondsSinceEpoch(s.startTime.toInt());
      endDate = DateTime.fromMillisecondsSinceEpoch(s.endTime.toInt());
      startSlot = startDate.hour * 2 + (startDate.minute >= 30 ? 1 : 0);
      endSlot = endDate.hour * 2 + (endDate.minute >= 30 ? 1 : 0);
      reminderMinutes.addAll(s.notifyTime);
      if (s.hasCycle()) {
        final cycle = s.cycle;
        switch (cycle.rule.cycleType) {
          case 1: recurrenceType = "Daily"; break;
          case 2: recurrenceType = "Weekly"; break;
          case 3: recurrenceType = "Monthly"; break;
          case 5: recurrenceType = "Yearly"; break;
        }
        recurrenceIntervalCtrl.text = cycle.rule.seq.toString();
        weekDays.addAll(cycle.rule.weekSeqs);
        if (cycle.stopAt.toInt() > 0) {
          recurrenceEndType = "On date";
          recurrenceEndDate = DateTime.fromMillisecondsSinceEpoch(cycle.stopAt.toInt());
        }
      }
    } else {
      final t = widget.startTime ?? DateTime.now();
      startDate = t;
      endDate = t;
      startSlot = t.hour * 2 + (t.minute >= 30 ? 1 : 0);
      endSlot = startSlot + 1;
      if (endSlot >= timeSlots.length) {
        endSlot = timeSlots.length - 1;
        endDate = endDate.add(const Duration(days: 1));
      }
      if (calendars.isNotEmpty) {
        selectedCalendarId = widget.selectedCalendar?.id ?? calendars.first.id;
      }
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    locationCtrl.dispose();
    recurrenceIntervalCtrl.dispose();
    recurrenceCountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? "Edit Schedule" : "Create Schedule"),
      content: Container(
        width: 0.5.sw,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Calendar picker
            DropdownButtonFormField<Int64>(
              value: selectedCalendarId,
              decoration: const InputDecoration(labelText: "Calendar", isDense: true),
              items: calendars.map((c) => DropdownMenuItem(
                value: c.id,
                child: Row(children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: Color(c.color), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(c.name, style: const TextStyle(fontSize: 13)),
                ]),
              )).toList(),
              onChanged: (v) => setState(() => selectedCalendarId = v),
            ),
            const SizedBox(height: 8),

            // Title
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title", isDense: true)),
            const SizedBox(height: 8),

            // All-day toggle
            Row(children: [
              const Text("All day", style: TextStyle(fontSize: 13)),
              Switch(value: isAllDay, onChanged: (v) => setState(() => isAllDay = v), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            ]),

            // Date/time pickers
            Row(children: [
              Expanded(child: _dateField("Start date", startDate, (d) => setState(() => startDate = d))),
              if (!isAllDay) Expanded(child: _slotDropdown("Start", startSlot, (v) => setState(() => startSlot = v!))),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(child: _dateField("End date", endDate, (d) => setState(() => endDate = d))),
              if (!isAllDay) Expanded(child: _slotDropdown("End", endSlot, (v) => setState(() => endSlot = v!))),
            ]),
            const SizedBox(height: 8),

            // Description
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description", isDense: true), maxLines: 2),
            const SizedBox(height: 8),

            // Location
            TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: "Location", isDense: true)),
            const SizedBox(height: 12),

            // Recurrence
            const Divider(height: 1),
            const SizedBox(height: 4),
            _buildRecurrence(),
            const SizedBox(height: 8),

            // Reminder
            const Divider(height: 1),
            const SizedBox(height: 4),
            _buildReminders(),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
        TextButton(onPressed: _onSubmit, child: Text(isEditing ? "Save" : "Create")),
      ],
    );
  }

  Widget _dateField(String label, DateTime date, ValueChanged<DateTime> onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label, style: const TextStyle(fontSize: 12)),
      subtitle: Text(DateFormat.yMd().format(date), style: const TextStyle(fontSize: 13)),
      trailing: const Icon(Icons.calendar_today, size: 16),
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2030),
        );
        if (d != null) onChanged(d);
      },
    );
  }

  Widget _slotDropdown(String label, int value, ValueChanged<int?> onChanged) {
    return DropdownButtonFormField<int>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
      items: List.generate(timeSlots.length, (i) => DropdownMenuItem(value: i, child: Text(timeSlots[i], style: const TextStyle(fontSize: 13)))),
      onChanged: onChanged,
    );
  }

  Widget _buildRecurrence() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text("Repeat: ", style: TextStyle(fontSize: 13)),
        DropdownButton<String>(
          value: recurrenceType,
          style: const TextStyle(fontSize: 13),
          items: ["None", "Daily", "Weekly", "Monthly", "Yearly"].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
          onChanged: (v) => setState(() => recurrenceType = v!),
        ),
        if (recurrenceType != "None") ...[
          const Text(" every ", style: TextStyle(fontSize: 13)),
          SizedBox(width: 40, child: TextField(controller: recurrenceIntervalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(isDense: true, hintText: "1"))),
          Text(" ${_recurrenceUnit(recurrenceType)}", style: const TextStyle(fontSize: 13)),
        ],
      ]),
      if (recurrenceType != "None") ...[
        const SizedBox(height: 4),
        Row(children: [
          const Text("End: ", style: TextStyle(fontSize: 13)),
          DropdownButton<String>(
            value: recurrenceEndType,
            style: const TextStyle(fontSize: 13),
            items: ["Never", "After", "On date"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => recurrenceEndType = v!),
          ),
          if (recurrenceEndType == "After") ...[
            SizedBox(width: 40, child: TextField(controller: recurrenceCountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(isDense: true, hintText: "10"))),
            const Text(" times", style: TextStyle(fontSize: 13)),
          ],
          if (recurrenceEndType == "On date")
            TextButton(
              child: Text(DateFormat.yMd().format(recurrenceEndDate)),
              onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: recurrenceEndDate, firstDate: DateTime.now(), lastDate: DateTime(2030, 12, 31));
                if (d != null) setState(() => recurrenceEndDate = d);
              },
            ),
        ]),
        if (recurrenceType == "Weekly") ...[
          const SizedBox(height: 4),
          Wrap(spacing: 4, children: ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"].asMap().entries.map((e) => FilterChip(
            label: Text(e.value, style: const TextStyle(fontSize: 11)),
            selected: weekDays.contains(e.key),
            onSelected: (sel) => setState(() { if (sel) weekDays.add(e.key); else weekDays.remove(e.key); }),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          )).toList()),
        ],
      ],
    ]);
  }

  Widget _buildReminders() {
    const options = [
      ("At time", 0), ("5 min", 5), ("10 min", 10), ("30 min", 30),
      ("1 hr", 60), ("2 hr", 120), ("1 day", 1440),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Reminders: ", style: TextStyle(fontSize: 13)),
      const SizedBox(height: 4),
      Wrap(spacing: 4, children: options.map((o) {
        final sel = reminderMinutes.contains(o.$2);
        return FilterChip(
          label: Text(o.$1, style: const TextStyle(fontSize: 11)),
          selected: sel,
          onSelected: (v) => setState(() { if (v) reminderMinutes.add(o.$2); else reminderMinutes.remove(o.$2); }),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        );
      }).toList()),
    ]);
  }

  void _onSubmit() async {
    final schedule = Schedule.create();
    schedule.title = titleCtrl.text;
    schedule.desc = descCtrl.text;
    schedule.location = locationCtrl.text;
    schedule.fullDay = isAllDay;
    if (selectedCalendarId != null) schedule.calendarId = selectedCalendarId!;

    final startDT = DateTime(startDate.year, startDate.month, startDate.day, isAllDay ? 0 : startSlot ~/ 2, isAllDay ? 0 : (startSlot % 2) * 30);
    final endDT = DateTime(endDate.year, endDate.month, endDate.day, isAllDay ? 23 : endSlot ~/ 2, isAllDay ? 59 : (endSlot % 2) * 30);
    schedule.startTime = Int64(startDT.millisecondsSinceEpoch);
    schedule.endTime = Int64(endDT.millisecondsSinceEpoch);

    schedule.memberIds.add(sdk.userId);
    schedule.notifyTime.addAll(reminderMinutes);

    if (recurrenceType != "None") {
      schedule.cycle = ScheduleCycleRule.create();
      schedule.cycle.startAt = schedule.startTime;
      schedule.cycle.rule = CycleRule.create();
      schedule.cycle.rule.cycleType = {"Daily": 1, "Weekly": 2, "Monthly": 3, "Yearly": 5}[recurrenceType] ?? 0;
      schedule.cycle.rule.seq = int.tryParse(recurrenceIntervalCtrl.text) ?? 1;
      if (recurrenceType == "Weekly") schedule.cycle.rule.weekSeqs.addAll(weekDays);
      if (recurrenceEndType == "After") {
        final count = int.tryParse(recurrenceCountCtrl.text) ?? 10;
        schedule.cycle.stopAt = Int64(schedule.startTime.toInt() + count * schedule.cycle.rule.seq * 86400000);
      } else if (recurrenceEndType == "On date") {
        schedule.cycle.stopAt = Int64(recurrenceEndDate.millisecondsSinceEpoch);
      }
    }

    if (isEditing) {
      final req = ScheduleUpdateRequest.create();
      req.schedule = schedule;
      req.schedule.id = widget.editSchedule!.id;
      req.modifyScope = 0;
      await calendarLogic.updateSchedule(req);
    } else {
      await calendarLogic.createSchedule(Calendar(), ScheduleCreateRequest(schedule: schedule));
    }
    if (mounted) Navigator.of(context).pop();
  }

  String _recurrenceUnit(String type) {
    switch (type) {
      case "Daily": return "day(s)";
      case "Weekly": return "week(s)";
      case "Monthly": return "month(s)";
      case "Yearly": return "year(s)";
      default: return "";
    }
  }
}
