import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/res/theme.dart';
import 'package:flutter/material.dart';

class MeetingJoinDialog extends StatefulWidget {
  final void Function(String roomId, String password) onJoin;

  const MeetingJoinDialog({super.key, required this.onJoin});

  static Future<void> show(BuildContext context, {
    required void Function(String roomId, String password) onJoin,
  }) {
    return showDialog(
      context: context,
      builder: (_) => MeetingJoinDialog(onJoin: onJoin),
    );
  }

  @override
  State<MeetingJoinDialog> createState() => _MeetingJoinDialogState();
}

class _MeetingJoinDialogState extends State<MeetingJoinDialog> {
  final _roomCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _roomCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    var roomId = _roomCtrl.text.trim();
    if (roomId.isEmpty) return;
    widget.onJoin(roomId, _passwordCtrl.text.trim());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return AlertDialog(
      title: Text(t.joinMeeting, style: tt.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _roomCtrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: t.meetingNo,
              hintText: '请输入会议号',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: '密码（可选）',
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.cancel, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(t.joinMeeting),
        ),
      ],
    );
  }
}
