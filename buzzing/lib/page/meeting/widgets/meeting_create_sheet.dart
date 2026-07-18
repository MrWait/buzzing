import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/idl/meeting.pb.dart';
import 'package:buzzing/res/theme.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';

class MeetingCreateSheetArgs {
  final bool isSchedule;
  final String? initialTitle;

  MeetingCreateSheetArgs({this.isSchedule = false, this.initialTitle});
}

class MeetingCreateSheet extends StatefulWidget {
  final bool isSchedule;
  final void Function(MeetingCreateRequest req) onCreated;

  const MeetingCreateSheet({
    super.key,
    this.isSchedule = false,
    required this.onCreated,
  });

  static Future<void> show(BuildContext context, {
    bool isSchedule = false,
    required void Function(MeetingCreateRequest req) onCreated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: MeetingCreateSheet(isSchedule: isSchedule, onCreated: onCreated),
      ),
    );
  }

  @override
  State<MeetingCreateSheet> createState() => _MeetingCreateSheetState();
}

class _MeetingCreateSheetState extends State<MeetingCreateSheet> {
  final _titleCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _maxParticipantsCtrl = TextEditingController(text: '0');
  DateTime _scheduledDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _scheduledTime = TimeOfDay(hour: 9, minute: 0);
  bool _muteOnEntry = false;
  bool _allowScreenShare = true;
  bool _recordEnabled = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _passwordCtrl.dispose();
    _maxParticipantsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    var title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    var settings = MeetingSettings(
      muteOnEntry: _muteOnEntry,
      allowScreenShare: _allowScreenShare,
      recordEnabled: _recordEnabled,
    );

    var req = MeetingCreateRequest(
      title: title,
      password: _passwordCtrl.text.trim(),
      maxParticipants: int.tryParse(_maxParticipantsCtrl.text) ?? 0,
      settings: settings,
    );

    if (widget.isSchedule) {
      var dt = DateTime(
        _scheduledDate.year,
        _scheduledDate.month,
        _scheduledDate.day,
        _scheduledTime.hour,
        _scheduledTime.minute,
      );
      req.scheduledAt = Int64(dt.millisecondsSinceEpoch);
    }

    widget.onCreated(req);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.isSchedule ? t.scheduleMeeting : t.createMeeting,
            style: tt.titleLarge,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: t.meetingSubjectIs.replaceFirst('%s', ''),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: t.meetingNo,
              hintText: '设置密码（可选）',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.isSchedule) ...[
            Row(
              children: [
                Expanded(
                    child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      '${_scheduledDate.year}-${_scheduledDate.month.toString().padLeft(2, '0')}-${_scheduledDate.day.toString().padLeft(2, '0')}',
                    ),
                    onPressed: () async {
                      var d = await showDatePicker(
                        context: context,
                        initialDate: _scheduledDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (d != null) setState(() => _scheduledDate = d);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 18),
                    label: Text(_scheduledTime.format(context)),
                    onPressed: () async {
                      var t = await showTimePicker(
                        context: context,
                        initialTime: _scheduledTime,
                      );
                      if (t != null) setState(() => _scheduledTime = t);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _maxParticipantsCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '最大参与人数',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('会议设置', style: tt.titleSmall),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('入会时静音'),
            value: _muteOnEntry,
            onChanged: (v) => setState(() => _muteOnEntry = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('允许屏幕共享'),
            value: _allowScreenShare,
            onChanged: (v) => setState(() => _allowScreenShare = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('开启录制'),
            value: _recordEnabled,
            onChanged: (v) => setState(() => _recordEnabled = v),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: Text(widget.isSchedule ? t.scheduleMeeting : t.createMeeting),
            ),
          ),
        ],
      ),
    );
  }
}
