import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/idl/meeting.pb.dart';
import 'package:buzzing/page/meeting/meeting_api.dart';
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

  var recurrenceType = 0;
  var recurrenceIntervalCtrl = TextEditingController(text: "1");
  var recurrenceEndType = 0;
  var recurrenceCountCtrl = TextEditingController(text: "10");
  var recurrenceEndDate = DateTime.now().add(const Duration(days: 365));
  var weekDays = <int>[];
  var reminderMinutes = <int>[];
  var createMeeting = false;

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
        recurrenceType = cycle.rule.cycleType;
        recurrenceIntervalCtrl.text = cycle.rule.seq.toString();
        weekDays.addAll(cycle.rule.weekSeqs);
        if (cycle.stopAt.toInt() > 0) {
          recurrenceEndType = 3;
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
      title: Text(isEditing ? t.editSchedule : t.createSchedule),
      content: Container(
        width: 0.5.sw,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Calendar picker
            DropdownButtonFormField<Int64>(
              value: selectedCalendarId,
              decoration: InputDecoration(labelText: t.scheduleCalendar, isDense: true),
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
            TextField(controller: titleCtrl, decoration: InputDecoration(labelText: t.scheduleTitle, isDense: true)),
            const SizedBox(height: 8),

            // All-day toggle
            Row(children: [
              Text(t.allDay, style: const TextStyle(fontSize: 13)),
              Switch(value: isAllDay, onChanged: (v) => setState(() => isAllDay = v), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            ]),

            // Date/time pickers
            Row(children: [
              Expanded(child: _dateField(t.startDate, startDate, (d) => setState(() => startDate = d))),
              if (!isAllDay) Expanded(child: _slotDropdown(t.startTime, startSlot, (v) => setState(() => startSlot = v!))),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(child: _dateField(t.endDate, endDate, (d) => setState(() => endDate = d))),
              if (!isAllDay) Expanded(child: _slotDropdown(t.endTime, endSlot, (v) => setState(() => endSlot = v!))),
            ]),
            const SizedBox(height: 8),

            // Description
            TextField(controller: descCtrl, decoration: InputDecoration(labelText: t.description, isDense: true), maxLines: 2),
            const SizedBox(height: 8),

            // Location
            TextField(controller: locationCtrl, decoration: InputDecoration(labelText: t.location, isDense: true)),
            const SizedBox(height: 12),

            // Meeting toggle
            Row(children: [
              Text('视频会议', style: const TextStyle(fontSize: 13)),
              const Spacer(),
              Switch(value: createMeeting, onChanged: (v) => setState(() => createMeeting = v), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            ]),
            const SizedBox(height: 8),

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
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(t.cancel)),
        TextButton(onPressed: _onSubmit, child: Text(isEditing ? t.save : t.createSchedule)),
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

  static const _recurrenceLabels = ["None", "Daily", "Weekly", "Monthly", "Yearly"];
  static const _recurrenceValues = [0, 1, 2, 3, 5];
  static const _endLabels = ["Never", "After", "On date"];
  static const _endValues = [0, 1, 3];

  Widget _buildRecurrence() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(t.repeat, style: const TextStyle(fontSize: 13)),
        DropdownButton<int>(
          value: recurrenceType,
          style: const TextStyle(fontSize: 13),
          items: List.generate(_recurrenceValues.length, (i) => DropdownMenuItem(
            value: _recurrenceValues[i],
            child: Text(_recurrenceText(_recurrenceLabels[i])),
          )),
          onChanged: (v) => setState(() => recurrenceType = v!),
        ),
        if (recurrenceType != 0) ...[
          Text(t.every, style: const TextStyle(fontSize: 13)),
          SizedBox(width: 40, child: TextField(controller: recurrenceIntervalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(isDense: true, hintText: "1"))),
          Text(" ${_recurrenceUnit(recurrenceType)}", style: const TextStyle(fontSize: 13)),
        ],
      ]),
      if (recurrenceType != 0) ...[
        const SizedBox(height: 4),
        Row(children: [
          Text(t.endLabel, style: const TextStyle(fontSize: 13)),
          DropdownButton<int>(
            value: recurrenceEndType,
            style: const TextStyle(fontSize: 13),
            items: List.generate(_endValues.length, (i) => DropdownMenuItem(
              value: _endValues[i],
              child: Text(_endText(_endLabels[i])),
            )),
            onChanged: (v) => setState(() => recurrenceEndType = v!),
          ),
          if (recurrenceEndType == 1) ...[
            SizedBox(width: 40, child: TextField(controller: recurrenceCountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(isDense: true, hintText: "10"))),
            Text(t.times, style: const TextStyle(fontSize: 13)),
          ],
          if (recurrenceEndType == 3)
            TextButton(
              child: Text(DateFormat.yMd().format(recurrenceEndDate)),
              onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: recurrenceEndDate, firstDate: DateTime.now(), lastDate: DateTime(2030, 12, 31));
                if (d != null) setState(() => recurrenceEndDate = d);
              },
            ),
        ]),
        if (recurrenceType == 2) ...[
          const SizedBox(height: 4),
          Wrap(spacing: 4, children: [t.weekdayMon, t.weekdayTue, t.weekdayWed, t.weekdayThu, t.weekdayFri, t.weekdaySat, t.weekdaySun].asMap().entries.map((e) => FilterChip(
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

  String _recurrenceText(String label) {
    switch (label) {
      case "None": return t.never;
      case "Daily": return t.daily;
      case "Weekly": return t.weekly;
      case "Monthly": return t.monthly;
      case "Yearly": return t.yearly;
      default: return label;
    }
  }

  String _endText(String label) {
    switch (label) {
      case "Never": return t.never;
      case "After": return t.after;
      case "On date": return t.onDate;
      default: return label;
    }
  }

  Widget _buildReminders() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t.reminders, style: const TextStyle(fontSize: 13)),
      const SizedBox(height: 4),
      Wrap(spacing: 4, children: [
        _reminderChip(t.atTime, 0),
        _reminderChip("5${t.minUnit}", 5),
        _reminderChip("10${t.minUnit}", 10),
        _reminderChip("30${t.minUnit}", 30),
        _reminderChip("1${t.hrUnit}", 60),
        _reminderChip("2${t.hrUnit}", 120),
        _reminderChip("1${t.dayUnit}", 1440),
      ]),
    ]);
  }

  Widget _reminderChip(String label, int minutes) {
    final sel = reminderMinutes.contains(minutes);
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: sel,
      onSelected: (v) => setState(() { if (v) reminderMinutes.add(minutes); else reminderMinutes.remove(minutes); }),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
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

    if (createMeeting) {
      schedule.type = 1;
      schedule.memberCreateMeeting = true;
      if (!isEditing) {
        final meetingReq = MeetingCreateRequest(
          title: titleCtrl.text,
          scheduledAt: Int64(startDT.millisecondsSinceEpoch),
          maxParticipants: 50,
        );
        final resp = await MeetingApi(sdk).create(meetingReq);
        if (resp.meeting.roomId.isNotEmpty) {
          schedule.roomId = Int64(int.parse(resp.meeting.roomId));
        }
      }
    }

    if (recurrenceType != 0) {
      schedule.cycle = ScheduleCycleRule.create();
      schedule.cycle.startAt = schedule.startTime;
      schedule.cycle.rule = CycleRule.create();
      schedule.cycle.rule.cycleType = recurrenceType;
      schedule.cycle.rule.seq = int.tryParse(recurrenceIntervalCtrl.text) ?? 1;
      if (recurrenceType == 2) schedule.cycle.rule.weekSeqs.addAll(weekDays);
      if (recurrenceEndType == 1) {
        final count = int.tryParse(recurrenceCountCtrl.text) ?? 10;
        schedule.cycle.stopAt = Int64(schedule.startTime.toInt() + count * schedule.cycle.rule.seq * 86400000);
      } else if (recurrenceEndType == 3) {
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

  String _recurrenceUnit(int type) {
    switch (type) {
      case 1: return t.recurrenceUnitDay;
      case 2: return t.recurrenceUnitWeek;
      case 3: return t.recurrenceUnitMonth;
      case 5: return t.recurrenceUnitYear;
      default: return "";
    }
  }
}
