import 'package:buzzing/controller/im.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/models/idl/timer.pb.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:flutter/material.dart';

class ScheduledMessagesPage extends StatefulWidget {
  final ImController im;
  const ScheduledMessagesPage({required this.im, super.key});

  @override
  State<ScheduledMessagesPage> createState() => _ScheduledMessagesPageState();
}

class _ScheduledMessagesPageState extends State<ScheduledMessagesPage> {
  List<ScheduledMessage> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final req = GetScheduledMessagesRequest(page: 1, pageSize: 50);
      final data = await widget.im.sdk.invokeAsync(
        Command.GET_SCHEDULED_MESSAGES,
        req.writeToBuffer(),
      );
      final resp = GetScheduledMessagesResponse.fromBuffer(data);
      setState(() {
        _messages = resp.messages.toList();
        _loading = false;
      });
    } catch (e) {
      L.e("load scheduled messages error: $e");
      setState(() => _loading = false);
    }
  }

  String _statusLabel(int status) {
    switch (status) {
      case 0:
        return t.pending;
      case 1:
        return t.sent;
      case 2:
        return t.cancelled;
      default:
        return '未知';
    }
  }

  Color _statusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _cancel(int scheduleId) async {
    try {
      final req = CancelScheduleRequest(scheduleId: scheduleId);
      await widget.im.sdk.invokeAsync(Command.CANCEL_SCHEDULE, req.writeToBuffer());
      _load();
    } catch (e) {
      L.e("cancel schedule error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(t.scheduledMessages)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
              ? Center(
                  child: Text('暂无定时消息', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    itemCount: _messages.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: cs.outlineVariant),
                    itemBuilder: (ctx, i) {
                      final m = _messages[i];
                      final sendAt = DateTime.fromMillisecondsSinceEpoch(m.sendAtMs);
                      final createdAt = DateTime.fromMillisecondsSinceEpoch(m.createdAtMs);
                      return ListTile(
                        leading: Icon(
                          m.status == 0 ? Icons.schedule : m.status == 1 ? Icons.check_circle_outline : Icons.cancel_outlined,
                          color: _statusColor(m.status),
                        ),
                        title: Text('chat_${m.chatId}', style: tt.bodyMedium),
                        subtitle: Text(
                          '${sendAt.year}-${sendAt.month.toString().padLeft(2, '0')}-${sendAt.day.toString().padLeft(2, '0')} '
                          '${sendAt.hour.toString().padLeft(2, '0')}:${sendAt.minute.toString().padLeft(2, '0')}',
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _statusColor(m.status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _statusLabel(m.status),
                                style: tt.labelSmall?.copyWith(color: _statusColor(m.status)),
                              ),
                            ),
                            if (m.status == 0) ...[
                              const SizedBox(width: 4),
                              IconButton(
                                icon: Icon(Icons.close, size: 16, color: cs.error),
                                onPressed: () => _cancel(m.id),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
