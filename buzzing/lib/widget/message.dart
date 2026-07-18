import 'dart:convert';

import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/meeting.pb.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:flutter/material.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

class MessageBox extends ConsumerWidget {
  final User user;
  final Message msg;

  MessageBox({required this.msg, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final im = ref.watch(imProvider);
    final isSelf = msg.fromId == im.userId;
    final showAvatar = !isSelf;

    Widget render;
    switch (msg.tpy) {
      case 1:
        var m = MessageText.fromBuffer(msg.content);
        render = Text(m.text, style: tt.bodyMedium);
        break;
      case 11:
        var m = MessageText.fromBuffer(msg.content);
        try {
          final controller = QuillController.basic();
          controller.document = Document.fromJson(jsonDecode(m.text));
          controller.readOnly = true;
          render = QuillEditor.basic(
            controller: controller,
            config: QuillEditorConfig(
              showCursor: false,
              minHeight: 100,
              maxHeight: 300,
              embedBuilders: FlutterQuillEmbeds.editorBuilders(),
            ),
          );
        } catch (_) {
          render = Text(msg.summary, style: tt.bodyMedium);
        }
        break;
      case 12:
        final invite = MeetingInvite.fromBuffer(msg.content);
        render = _MeetingInviteCard(invite: invite, isSelf: isSelf, cs: cs, tt: tt);
        break;
      default:
        render = Text(msg.summary, style: tt.bodyMedium);
    }

    final bubbleColor = isSelf ? cs.primary : cs.surfaceContainerHigh;
    final textColor = isSelf ? cs.onPrimary : cs.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAvatar) ...[
            _buildAvatar(cs, tt, im, user),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      user.name,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DefaultTextStyle(
                    style: tt.bodyMedium!.copyWith(color: textColor),
                    child: render,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    _formatTime(msg.createTimeMs),
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          if (isSelf) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildAvatar(ColorScheme cs, TextTheme tt, ImController im, User u) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
          style: tt.bodySmall?.copyWith(color: cs.onPrimary),
        ),
      ),
    );
  }

  String _formatTime(Int64 ms) {
    var dt = DateTime.fromMillisecondsSinceEpoch(ms.toInt());
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _MeetingInviteCard extends ConsumerWidget {
  final MeetingInvite invite;
  final bool isSelf;
  final ColorScheme cs;
  final TextTheme tt;

  const _MeetingInviteCard({
    required this.invite,
    required this.isSelf,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctl = ref.read(meetingLogicProvider);
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () async {
        // 直接打开预加入窗口；入会 API 由 VcLogic.confirmJoin 在用户确认后调用
        ctl.joinMeeting(invite.roomId, roomTitle: invite.title);
      },
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Icon(Icons.videocam, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text('会议邀请', style: tt.labelSmall?.copyWith(color: cs.primary)),
            ]),
            const SizedBox(height: 8),
            Text(invite.title.isNotEmpty ? invite.title : '未命名会议',
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            if (invite.hostName.isNotEmpty)
              Text('发起人: ${invite.hostName}',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            Text('会议号: ${invite.roomId}',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: null,
                style: TextButton.styleFrom(
                  backgroundColor: cs.primaryContainer,
                  foregroundColor: cs.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text('加入会议', style: tt.labelSmall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
