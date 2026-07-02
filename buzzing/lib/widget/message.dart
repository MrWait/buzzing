import 'dart:convert';

import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/provider/im_provider.dart';
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
