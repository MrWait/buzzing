import 'dart:convert';
import 'dart:io';

import 'package:buzzing/controller/im.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/entity.pbenum.dart';
import 'package:buzzing/models/idl/im_ext.pb.dart';
import 'package:buzzing/models/idl/meeting.pb.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/widget/forward_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBox extends ConsumerStatefulWidget {
  final User user;
  final Message msg;

  const MessageBox({required this.msg, required this.user});

  @override
  _MessageBoxState createState() => _MessageBoxState();
}

class _MessageBoxState extends ConsumerState<MessageBox> {
  var _hovering = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final im = ref.watch(imProvider);
    final msg = widget.msg;
    final user = widget.user;
    final isSelf = msg.fromId == im.userId;
    final showAvatar = !isSelf;
    final isSystem = msg.tpy == MessageType.SYSTEM.value;
    final isDeleted = msg.status == EntityStatus.DELETED.value || msg.status == 5;

    if (isDeleted) {
      return _DeletedMessage(msg: msg, cs: cs, tt: tt);
    }

    if (isSystem) {
      return _SystemContent(msg: msg, tt: tt, cs: cs);
    }

    final bubbleColor = isSelf ? cs.primary : cs.surfaceContainerHigh;
    final textColor = isSelf ? cs.onPrimary : cs.onSurface;

    final bubble = Column(
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
        if (msg.hasRefData() || msg.refMessageId != Int64(0))
          _ReplyDecorator(msg: msg, cs: cs, tt: tt),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: DefaultTextStyle(
            style: tt.bodyMedium!.copyWith(color: textColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildContent(im),
                // M5-F: translation result
                if (im.translationCache[msg.id]?.containsKey('zh') == true) ...[
                  const SizedBox(height: 6),
                  Divider(height: 1, color: cs.outlineVariant.withOpacity(0.3)),
                  const SizedBox(height: 4),
                  Text(
                    im.translationCache[msg.id]!['zh']!,
                    style: tt.bodySmall?.copyWith(
                      color: isSelf ? cs.onPrimary.withOpacity(0.85) : cs.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (msg.hasReadState() && !isSelf)
                GestureDetector(
                  onTap: () => _showReadDetail(context, im, msg),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '${msg.readState.readCount}/${msg.readState.total} 已读',
                      style: tt.labelSmall?.copyWith(color: cs.primary),
                    ),
                  ),
                ),
              if (im.pinnedMessages.any((m) => m.id == msg.id))
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.push_pin, size: 12, color: cs.primary),
                      const SizedBox(width: 2),
                      Text('已置顶', style: tt.labelSmall?.copyWith(color: cs.primary)),
                    ],
                  ),
                ),
              Text(
                _formatTime(msg.createTimeMs),
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );

    final isDesktop = Platform.isMacOS || Platform.isWindows || Platform.isLinux;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: isDesktop
          ? _buildDesktopMessage(context, cs, tt, im, isSelf, bubble)
          : _buildMobileMessage(isSelf, bubble),
    );
  }

  Widget _buildMobileMessage(bool isSelf, Widget bubble) {
    return Row(
      mainAxisAlignment: isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isSelf) ...[
          _buildAvatar(),
          const SizedBox(width: 8),
        ],
        Flexible(child: bubble),
        if (isSelf) const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDesktopMessage(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
    ImController im,
    bool isSelf,
    Widget bubble,
  ) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onSecondaryTap: () => _showContextMenu(context, cs, tt, im),
        child: Row(
          mainAxisAlignment: isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSelf) ...[
              _buildAvatar(),
              const SizedBox(width: 8),
            ],
            Flexible(child: bubble),
            if (isSelf) const SizedBox(width: 8),
            if (_hovering)
              _buildHoverActions(context, cs, tt, im, isSelf),
          ],
        ),
      ),
    );
  }

  Widget _buildHoverActions(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
    ImController im,
    bool isSelf,
  ) {
    final msg = widget.msg;
    return FittedBox(
      child: Container(
        height: 28,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionBtn(Icons.reply_rounded, '回复', () {
              im.setReplyTarget(msg);
            }, cs),
            _actionBtn(Icons.forum_outlined, 'Thread', () {
              im.openThread(msg);
            }, cs),
            _actionBtn(Icons.forward_rounded, '转发', () {
              _showForwardDialog(context, im);
            }, cs),
            _actionBtn(Icons.star_outline, '收藏', () {
              im.favoriteMessage(msg);
            }, cs),
            // 检查消息是否已被置顶（通过 pinnedMessages 列表判断）
            if (im.pinnedMessages.any((m) => m.id == msg.id))
              _actionBtn(Icons.push_pin, '取消置顶', () {
                im.unpinMessage(msg.chatId, msg.id);
              }, cs)
            else
              _actionBtn(Icons.push_pin_outlined, '置顶', () {
                im.pinMessage(msg.chatId, msg.id);
              }, cs),
            // M5-A: voice transcribe
            if (msg.tpy == 4)
              _actionBtn(Icons.notes, t.transcribe, () {
                im.transcribeVoice(msg.id, msg.chatId);
              }, cs),
            // M5-F: translate (for text/richtext/markdown)
            if ([1, 11, 13].contains(msg.tpy))
              _actionBtn(Icons.translate, '翻译', () {
                im.translateMessage(msg.id, msg.chatId, 'zh');
              }, cs),
            _actionBtn(Icons.delete_outline, '删除', () {
              _confirmDelete(context, im, msg);
            }, cs),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String tooltip, VoidCallback onTap, ColorScheme cs) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: cs.onSurfaceVariant),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, ColorScheme cs, TextTheme tt, ImController im) {
    final msg = widget.msg;
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 100, 100),
      items: [
        PopupMenuItem(value: 'reply', child: ListTile(
          leading: Icon(Icons.reply_rounded, size: 18),
          title: Text('回复', style: tt.bodySmall),
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: EdgeInsets.zero,
        )),
        PopupMenuItem(value: 'thread', child: ListTile(
          leading: Icon(Icons.forum_outlined, size: 18),
          title: Text('Thread', style: tt.bodySmall),
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: EdgeInsets.zero,
        )),
        PopupMenuItem(value: 'forward', child: ListTile(
          leading: Icon(Icons.forward_rounded, size: 18),
          title: Text('转发', style: tt.bodySmall),
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: EdgeInsets.zero,
        )),
        PopupMenuItem(value: 'favorite', child: ListTile(
          leading: Icon(Icons.star_outline, size: 18),
          title: Text('收藏', style: tt.bodySmall),
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: EdgeInsets.zero,
        )),
        if (im.pinnedMessages.any((m) => m.id == msg.id))
          PopupMenuItem(value: 'unpin', child: ListTile(
            leading: Icon(Icons.push_pin, size: 18),
            title: Text('取消置顶', style: tt.bodySmall),
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: EdgeInsets.zero,
          ))
        else
          PopupMenuItem(value: 'pin', child: ListTile(
            leading: Icon(Icons.push_pin_outlined, size: 18),
            title: Text('置顶', style: tt.bodySmall),
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: EdgeInsets.zero,
          )),
        // M5-A: voice transcribe
        if (msg.tpy == 4)
          PopupMenuItem(value: 'transcribe', child: ListTile(
            leading: Icon(Icons.notes, size: 18),
            title: Text(t.transcribe, style: tt.bodySmall),
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: EdgeInsets.zero,
          )),
        // M5-F: translate
        if ([1, 11, 13].contains(msg.tpy))
          PopupMenuItem(value: 'translate', child: ListTile(
            leading: Icon(Icons.translate, size: 18),
            title: Text('翻译', style: tt.bodySmall),
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: EdgeInsets.zero,
          )),
        PopupMenuItem(value: 'delete', child: ListTile(
          leading: Icon(Icons.delete_outline, size: 18),
          title: Text('删除', style: tt.bodySmall),
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: EdgeInsets.zero,
        )),
      ],
    ).then((value) {
      if (value == 'reply') {
        im.setReplyTarget(msg);
      } else if (value == 'thread') {
        im.openThread(msg);
      } else if (value == 'forward') {
        _showForwardDialog(context, im);
      } else if (value == 'favorite') {
        im.favoriteMessage(msg);
      } else if (value == 'pin') {
        im.pinMessage(msg.chatId, msg.id);
      } else if (value == 'unpin') {
        im.unpinMessage(msg.chatId, msg.id);
      } else if (value == 'delete') {
        _confirmDelete(context, im, msg);
      } else if (value == 'transcribe') {
        im.transcribeVoice(msg.id, msg.chatId);
      } else if (value == 'translate') {
        im.translateMessage(msg.id, msg.chatId, 'zh');
      }
    });
  }

  void _showForwardDialog(BuildContext context, ImController im) {
    final msg = widget.msg;
    showDialog(
      context: context,
      builder: (ctx) => ForwardPickerDialog(
        im: im,
        initialMessageIds: [msg.id],
        sourceChatId: msg.chatId,
      ),
    );
  }

  void _confirmDelete(BuildContext context, ImController im, Message msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除消息'),
        content: const Text('选择删除方式：'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              im.deleteMessage(msg.id, mode: 0);
            },
            child: const Text('删除（仅对我）'),
          ),
          if (msg.fromId == im.userId)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                im.deleteMessage(msg.id, mode: 1);
              },
              child: const Text('删除（对所有成员）'),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(ImController im) {
    final msg = widget.msg;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isSelf = msg.fromId == im.userId;

    switch (msg.tpy) {
      case 1:
        var m = MessageText.fromBuffer(msg.content);
        return _buildTextWithMentions(m.text, tt.bodyMedium!, cs);
      case 2:
        return _ImageContent(msg: msg, cs: cs, tt: tt);
      case 3:
        return _FileContent(msg: msg, cs: cs, tt: tt);
      case 4:
        return _VoiceContent(msg: msg, im: im, cs: cs, tt: tt);
      case 5:
        return _VideoContent(msg: msg, cs: cs, tt: tt);
      case 7:
        return _LocationContent(msg: msg, cs: cs, tt: tt);
      case 8:
        return _CardContent(msg: msg, cs: cs, tt: tt);
      case 11:
        var m = MessageText.fromBuffer(msg.content);
        try {
          final controller = QuillController.basic();
          controller.document = Document.fromJson(jsonDecode(m.text));
          controller.readOnly = true;
          return QuillEditor.basic(
            controller: controller,
            config: QuillEditorConfig(
              showCursor: false,
              minHeight: 100,
              maxHeight: 300,
              embedBuilders: FlutterQuillEmbeds.editorBuilders(),
            ),
          );
        } catch (_) {
          return Text(msg.summary, style: tt.bodyMedium);
        }
      case 12:
        final invite = MeetingInvite.fromBuffer(msg.content);
        return _MeetingInviteCard(invite: invite, isSelf: isSelf, cs: cs, tt: tt);
      case 13:
        return _MarkdownContent(msg: msg, tt: tt);
      case 14:
        return _ForwardContent(msg: msg, cs: cs, tt: tt, isSelf: isSelf);
      default:
        return Text(msg.summary, style: tt.bodyMedium);
    }
  }

  Widget _buildAvatar() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final u = widget.user;
    final im = ref.watch(imProvider);
    final presence = im.presenceMap[u.id];
    final isOnline = presence?.status == 1;
    return GestureDetector(
      onTap: () {},
      child: Stack(
        children: [
          Container(
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
          if (presence != null)
            Positioned(
              right: 0, bottom: 0,
              child: Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: isOnline ? cs.primary : cs.onSurfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.surface, width: 1),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showReadDetail(BuildContext context, ImController im, Message msg) async {
    final resp = await im.getReadMembers(msg.chatId, msg.id);
    if (resp == null || context.mounted == false) return;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;
        return Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('已读详情 (${msg.readState.readCount}/${msg.readState.total})', style: tt.titleSmall),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: resp.members.length,
                  itemBuilder: (ctx, i) {
                    final m = resp.members[i];
                    return ListTile(
                      dense: true,
                      leading: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(4)),
                        alignment: Alignment.center,
                        child: Text(
                          (m.name.isNotEmpty ? m.name : '?')[0].toUpperCase(),
                          style: tt.bodySmall?.copyWith(color: cs.onPrimary),
                        ),
                      ),
                      title: Text(m.name, style: tt.bodySmall),
                      trailing: Icon(
                        m.isRead ? Icons.check_circle : Icons.access_time,
                        size: 16,
                        color: m.isRead ? cs.primary : cs.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(Int64 ms) {
    var dt = DateTime.fromMillisecondsSinceEpoch(ms.toInt());
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _ReplyDecorator extends StatelessWidget {
  final Message msg;
  final ColorScheme cs;
  final TextTheme tt;

  const _ReplyDecorator({required this.msg, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    final ref = msg.refData;
    final preview = ref.summary.isNotEmpty ? ref.summary : '(消息已撤回)';
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: cs.primary, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.senderName.isNotEmpty ? ref.senderName : '未知用户',
            style: tt.bodySmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            preview,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ImageContent extends StatelessWidget {
  final Message msg;
  final ColorScheme cs;
  final TextTheme tt;

  const _ImageContent({required this.msg, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    final img = MessageImage.fromBuffer(msg.content);
    final url = img.url;
    if (url.isEmpty) {
      return Container(
        width: 120,
        height: 120,
        color: cs.surfaceContainerLow,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return GestureDetector(
      onTap: () => _previewImage(context, url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: url,
          width: img.width > 0 ? img.width.toDouble() : 200,
          height: img.height > 0 ? img.height.toDouble() : 200,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            width: 200,
            height: 200,
            color: cs.surfaceContainerLow,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (_, __, ___) => Container(
            width: 200,
            height: 200,
            color: cs.errorContainer,
            child: Icon(Icons.broken_image, color: cs.onErrorContainer),
          ),
        ),
      ),
    );
  }

  void _previewImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _FileContent extends StatelessWidget {
  final Message msg;
  final ColorScheme cs;
  final TextTheme tt;

  const _FileContent({required this.msg, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    final file = MessageFile.fromBuffer(msg.content);
    final sizeStr = _formatSize(file.size);
    return Container(
      width: 240,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file_outlined, size: 32, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  file.name.isNotEmpty ? file.name : '文件',
                  style: tt.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(sizeStr, style: tt.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatSize(Int64 bytes) {
    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;
    final b = bytes.toInt();
    if (b >= gb) return '${(b / gb).toStringAsFixed(1)} GB';
    if (b >= mb) return '${(b / mb).toStringAsFixed(1)} MB';
    if (b >= kb) return '${(b / kb).toStringAsFixed(0)} KB';
    return '$b B';
  }
}

/// M5-B: video message bubble
class _VideoContent extends StatelessWidget {
  final Message msg;
  final ColorScheme cs;
  final TextTheme tt;

  const _VideoContent({required this.msg, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    MediaContent media;
    try {
      media = MediaContent.fromBuffer(msg.content);
    } catch (_) {
      return Text(msg.summary, style: tt.bodyMedium);
    }
    final durText = media.durationSec > 0
        ? '${media.durationSec ~/ 60}:${(media.durationSec % 60).toString().padLeft(2, '0')}'
        : null;

    return GestureDetector(
      onTap: () {
        // TODO: open full-screen video player using url
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: media.thumbnailUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: media.thumbnailUrl,
                    width: 200,
                    height: 150,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 200,
                      height: 150,
                      color: cs.surfaceContainerHighest,
                      child: Icon(Icons.movie_creation_outlined, size: 40, color: cs.onSurfaceVariant),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 200,
                      height: 150,
                      color: cs.surfaceContainerHighest,
                      child: Icon(Icons.movie_creation_outlined, size: 40, color: cs.onSurfaceVariant),
                    ),
                  )
                : Container(
                    width: 200,
                    height: 150,
                    color: cs.surfaceContainerHighest,
                    child: Icon(Icons.movie_creation_outlined, size: 40, color: cs.onSurfaceVariant),
                  ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.play_arrow, size: 32, color: cs.onSurface),
          ),
          if (durText != null)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(durText, style: tt.labelSmall?.copyWith(color: cs.onSurface)),
              ),
            ),
        ],
      ),
    );
  }
}

/// M5-C: location message bubble
class _LocationContent extends StatelessWidget {
  final Message msg;
  final ColorScheme cs;
  final TextTheme tt;

  const _LocationContent({
    required this.msg,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    final loc = LocationContent.fromBuffer(msg.content);
    final name = loc.name.isNotEmpty ? loc.name : loc.address;
    final lat = loc.latitude;
    final lng = loc.longitude;

    // static map thumbnail via OSM
    final staticMapUrl = lat != 0 && lng != 0
        ? 'https://staticmap.openstreetmap.de/staticmap.php?center=$lat,$lng&zoom=14&size=240x160&markers=$lat,$lng,red-pushpin'
        : null;

    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(
          'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=15/$lat/$lng',
        );
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (staticMapUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                staticMapUrl,
                width: 240,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 240,
                  height: 160,
                  color: cs.surfaceContainerHighest,
                  child: Icon(Icons.map, size: 48, color: cs.onSurfaceVariant),
                ),
              ),
            ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, size: 16, color: cs.primary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  name,
                  style: tt.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// M5-D: card message bubble
class _CardContent extends StatelessWidget {
  final Message msg;
  final ColorScheme cs;
  final TextTheme tt;

  const _CardContent({
    required this.msg,
    required this.cs,
    required this.tt,
  });

  void _handleAction(BuildContext context, CardAction action) {
    switch (action.actionType) {
      case 0: // URL
        if (action.url.isNotEmpty) {
          launchUrl(Uri.parse(action.url));
        }
      case 1: // 复制文本
        Clipboard.setData(ClipboardData(text: action.value));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已复制')),
          );
        }
      case 2: // 回调
        // For now, just show a toast; server callback can be added later
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('操作: ${action.label}')),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = CardContent.fromBuffer(msg.content);
    final hasActions = card.actions.isNotEmpty;

    Widget? banner;
    if (card.imageUrl.isNotEmpty) {
      banner = ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        child: Image.network(
          card.imageUrl,
          width: double.infinity,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 120,
            color: cs.surfaceContainerHighest,
            child: Icon(Icons.broken_image, color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    return Container(
      width: 260,
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (banner != null) banner,
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, hasActions ? 4 : 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (card.iconUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Image.network(
                      card.iconUrl,
                      width: 20,
                      height: 20,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(card.title, style: tt.titleSmall),
                      if (card.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          card.description,
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (card.url.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: InkWell(
                onTap: () => launchUrl(Uri.parse(card.url)),
                child: Text(
                  '查看详情',
                  style: tt.labelSmall?.copyWith(color: cs.primary),
                ),
              ),
            ),
          if (hasActions)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: cs.outlineVariant)),
              ),
              child: Row(
                children: card.actions.map((a) {
                  return Expanded(
                    child: InkWell(
                      onTap: () => _handleAction(context, a),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        child: Text(
                          a.label,
                          style: tt.labelSmall?.copyWith(color: cs.primary),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

/// M5-A: voice message bubble
class _VoiceContent extends StatefulWidget {
  final Message msg;
  final ImController im;
  final ColorScheme cs;
  final TextTheme tt;

  const _VoiceContent({required this.msg, required this.im, required this.cs, required this.tt});

  @override
  _VoiceContentState createState() => _VoiceContentState();
}

class _VoiceContentState extends State<_VoiceContent> {
  var _playing = false;

  @override
  Widget build(BuildContext context) {
    final msg = widget.msg;
    VoiceContent voice;
    try {
      voice = VoiceContent.fromBuffer(msg.content);
    } catch (_) {
      return Text(msg.summary, style: widget.tt.bodyMedium);
    }
    final isSelf = msg.fromId == widget.im.userId;
    final durText = '${voice.durationSec}${t.seconds}';
    final hasTranscript =
        voice.transcriptionStatus == 2 && voice.transcription.isNotEmpty;

    return InkWell(
      onTap: () {
        // TODO: play/pause via audioplayers package
        setState(() => _playing = !_playing);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
              size: 32,
              color: widget.cs.onPrimary,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(durText, style: widget.tt.bodyMedium?.copyWith(color: widget.cs.onPrimary)),
                if (hasTranscript)
                  Text(
                    voice.transcription,
                    style: widget.tt.bodySmall?.copyWith(color: widget.cs.onPrimary.withValues(alpha: 0.7)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            // unplayed dot (for received msgs only)
            if (!isSelf && !_playing)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: widget.cs.error,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MarkdownContent extends StatelessWidget {
  final Message msg;
  final TextTheme tt;

  const _MarkdownContent({required this.msg, required this.tt});

  @override
  Widget build(BuildContext context) {
    final md = MessageMarkdown.fromBuffer(msg.content);
    final text = md.text;
    if (text.isEmpty) return const SizedBox.shrink();

    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('### ')) {
          return Text(line.substring(4), style: tt.titleSmall);
        } else if (line.startsWith('## ')) {
          return Text(line.substring(3), style: tt.titleMedium);
        } else if (line.startsWith('# ')) {
          return Text(line.substring(2), style: tt.titleLarge);
        } else if (line.startsWith('- ') || line.startsWith('* ')) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('  •  '),
              Expanded(child: Text(line.substring(2))),
            ],
          );
        }
        return Text(line);
      }).toList(),
    );
  }
}

class _ForwardContent extends StatelessWidget {
  final Message msg;
  final ColorScheme cs;
  final TextTheme tt;
  final bool isSelf;

  const _ForwardContent({
    required this.msg,
    required this.cs,
    required this.tt,
    required this.isSelf,
  });

  @override
  Widget build(BuildContext context) {
    final fwd = MessageForward.fromBuffer(msg.content);
    final isMerged = fwd.type == 1;
    return Container(
      width: 260,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Icon(Icons.forward_rounded, size: 14, color: cs.primary),
            const SizedBox(width: 4),
            Text(
              isMerged ? '聊天记录' : '转发消息',
              style: tt.labelSmall?.copyWith(color: cs.primary),
            ),
          ]),
          if (isMerged && fwd.chatName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('来源: ${fwd.chatName}', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
          if (isMerged) ...[
            const SizedBox(height: 4),
            Text('共 ${fwd.messageCount} 条消息', style: tt.labelSmall),
          ],
          if (isMerged && fwd.items.isNotEmpty)
            ...fwd.items.take(4).map((item) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${item.userName}: ${item.summary}',
                    style: tt.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
          if (fwd.items.length > 4)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '等 ${fwd.items.length} 条消息',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}

class _DeletedMessage extends StatelessWidget {
  final Message msg;
  final ColorScheme cs;
  final TextTheme tt;

  const _DeletedMessage({required this.msg, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                '消息已被删除',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemContent extends StatelessWidget {
  final Message msg;
  final TextTheme tt;
  final ColorScheme cs;

  const _SystemContent({required this.msg, required this.tt, required this.cs});

  @override
  Widget build(BuildContext context) {
    final sys = MessageSystem.fromBuffer(msg.content);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            sys.text.isNotEmpty ? sys.text : msg.summary,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// 将文本中的 @xxx 高亮渲染
Widget _buildTextWithMentions(String text, TextStyle baseStyle, ColorScheme cs) {
  final pattern = RegExp(r'@\S+');
  final spans = <InlineSpan>[];
  int lastEnd = 0;
  for (final match in pattern.allMatches(text)) {
    if (match.start > lastEnd) {
      spans.add(TextSpan(text: text.substring(lastEnd, match.start), style: baseStyle));
    }
    spans.add(TextSpan(
      text: match.group(0),
      style: baseStyle.copyWith(color: cs.primary, fontWeight: FontWeight.w600, backgroundColor: cs.primary.withValues(alpha: 0.1)),
    ));
    lastEnd = match.end;
  }
  if (lastEnd < text.length) {
    spans.add(TextSpan(text: text.substring(lastEnd), style: baseStyle));
  }
  return RichText(text: TextSpan(children: spans));
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
