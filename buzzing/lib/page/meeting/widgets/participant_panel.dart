import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/idl/meeting.pb.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:flutter/material.dart';

class ParticipantPanel extends StatelessWidget {
  final List<MeetingMember> members;
  final int hostId;
  final int currentUserId;
  final bool isHost;
  final void Function(int userId)? onKick;
  final void Function(int userId, int role)? onSetRole;
  final VoidCallback? onEndMeeting;

  const ParticipantPanel({
    super.key,
    required this.members,
    required this.hostId,
    required this.currentUserId,
    required this.isHost,
    this.onKick,
    this.onSetRole,
    this.onEndMeeting,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(left: BorderSide(color: cs.outlineVariant)),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              '参与者 (${members.length})',
              style: tt.titleSmall,
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant),
          Expanded(
            child: members.isEmpty
                ? Center(
                    child: Text('暂无参与者', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                  )
                : ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, i) {
                      var member = members[i];
                      var isSelf = member.userId == currentUserId;
                      var isHostUser = member.userId == hostId;
                      return _ParticipantTile(
                        member: member,
                        isSelf: isSelf,
                        isHostUser: isHostUser,
                        isCurrentHost: isHost,
                        onKick: isHost && !isSelf ? () => onKick?.call(member.userId.toInt()) : null,
                        onTransferHost: isHost && !isSelf
                            ? () {
                                onSetRole?.call(member.userId.toInt(), 1);
                                L.d('transfer host to ${member.userId}');
                              }
                            : null,
                      );
                    },
                  ),
          ),
          if (isHost) ...[
            Divider(height: 1, color: cs.outlineVariant),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.call_end, size: 18),
                  label: const Text('结束会议'),
                  style: OutlinedButton.styleFrom(foregroundColor: cs.error),
                  onPressed: onEndMeeting,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final MeetingMember member;
  final bool isSelf;
  final bool isHostUser;
  final bool isCurrentHost;
  final VoidCallback? onKick;
  final VoidCallback? onTransferHost;

  const _ParticipantTile({
    required this.member,
    required this.isSelf,
    required this.isHostUser,
    required this.isCurrentHost,
    this.onKick,
    this.onTransferHost,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: cs.primaryContainer,
        child: Text(
          '${member.userId}',
          style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer),
        ),
      ),
      title: Text(
        isSelf ? '我 (${member.userId})' : '用户 ${member.userId}',
        style: tt.bodyMedium,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHostUser)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('主持人', style: tt.labelSmall?.copyWith(color: cs.onPrimaryContainer)),
            ),
          if (isCurrentHost && !isSelf)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 18, color: cs.onSurfaceVariant),
              onSelected: (v) {
                if (v == 'kick') onKick?.call();
                if (v == 'transfer') onTransferHost?.call();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'kick', child: Text('移出会议')),
                const PopupMenuItem(value: 'transfer', child: Text('转让主持')),
              ],
            ),
        ],
      ),
    );
  }
}
