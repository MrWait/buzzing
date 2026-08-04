import 'dart:convert';
import 'dart:math' as math;

import 'package:buzzing/controller/im.dart';
import 'package:buzzing/utils/platform.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/entity.pbenum.dart';

import 'package:buzzing/models/idl/meeting.pb.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/widget/forward_picker.dart';
import 'package:buzzing/utils/logger_util.dart';
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

  const MessageBox({super.key, required this.msg, required this.user});

  @override
  _MessageBoxState createState() => _MessageBoxState();
}

class _MessageBoxState extends ConsumerState<MessageBox> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final im = ref.watch(imProvider);
    final msg = widget.msg;
    final user = widget.user;
    final isSelf = msg.fromId == im.userId;
    final isSystem = msg.tpy == MessageType.SYSTEM.value;
    final isDeleted = msg.status == EntityStatus.DELETED.value || msg.status == 5;
    final isGroupChat = im.entity.chats[msg.chatId]?.chatType == 2;

    if (isDeleted) {
      return _DeletedMessage(msg: msg, cs: cs, tt: tt);
    }

    if (isSystem) {
      return _SystemContent(msg: msg, tt: tt, cs: cs);
    }

    final bubble = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.name,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(msg.createTimeMs),
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        if (msg.hasRefData() || msg.refMessageId != Int64(0))
          _ReplyDecorator(msg: msg, cs: cs, tt: tt),
        _BubbleWithMenu(
          isSelf: isSelf,
          showRead: isSelf && isGroupChat,
          readState: im.entity.readstates[msg.id] ?? ReadState.create(),
          onReadTap: () => _showReadDetail(context, im, msg),
          hoverMenuBuilder: () => _buildHoverActions(context, cs, tt, im, isSelf),
          cs: cs,
          tt: tt,
          msg: msg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildContent(im),
              if (im.translationCache[msg.id]?.containsKey('zh') == true) ...[
                const SizedBox(height: 6),
                Divider(height: 1, color: cs.outlineVariant.withOpacity(0.3)),
                const SizedBox(height: 4),
                Text(
                  im.translationCache[msg.id]!['zh']!,
                  style: tt.bodySmall?.copyWith(
                    color: isSelf ? cs.onPrimaryContainer.withOpacity(0.85) : cs.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
            ],
          ),
        ),
      ],
    );

    final desktop = isDesktop;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: desktop
          ? _buildDesktopMessage(context, cs, tt, im, isSelf, bubble)
          : _buildMobileMessage(bubble),
    );
  }

  Widget _buildMobileMessage(Widget bubble) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(),
        const SizedBox(width: 8),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: bubble,
          ),
        ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onSecondaryTap: () => _showContextMenu(context, cs, tt, im),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
              const SizedBox(width: 8),
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth - 36),
                  child: bubble,
                ),
              ),
            ],
          ),
        );
      },
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
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _actionBtn(Icons.emoji_emotions_outlined, '反应', () {
            _showReactionPicker(context, im);
          }, cs),
          _actionBtn(Icons.reply_rounded, '回复', () {
            im.setReplyTarget(msg);
          }, cs),
          _actionBtn(Icons.forward_rounded, '转发', () {
            _showForwardDialog(context, im);
          }, cs),
          _moreBtn(context, cs, tt, im),
        ],
      ),
    );
  }

  Widget _moreBtn(BuildContext context, ColorScheme cs, TextTheme tt, ImController im) {
    final msg = widget.msg;
    return Tooltip(
      message: '更多',
      child: InkWell(
        onTap: () {
          final btn = context.findRenderObject() as RenderBox?;
          final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
          if (btn == null || overlay == null) return;
          final offset = btn.localToGlobal(Offset.zero, ancestor: overlay);
          showMenu<String>(
            context: context,
            position: RelativeRect.fromLTRB(offset.dx, offset.dy - 120, offset.dx + 40, offset.dy),
            items: [
              PopupMenuItem(value: 'thread', child: ListTile(
                leading: Icon(Icons.forum_outlined, size: 18),
                title: Text('Thread', style: tt.bodySmall),
                dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero,
              )),
              PopupMenuItem(value: 'favorite', child: ListTile(
                leading: Icon(Icons.star_outline, size: 18),
                title: Text('收藏', style: tt.bodySmall),
                dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero,
              )),
              if (im.pinnedMessages.any((m) => m.id == msg.id))
                PopupMenuItem(value: 'unpin', child: ListTile(
                  leading: Icon(Icons.push_pin, size: 18),
                  title: Text('取消置顶', style: tt.bodySmall),
                  dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero,
                ))
              else
                PopupMenuItem(value: 'pin', child: ListTile(
                  leading: Icon(Icons.push_pin_outlined, size: 18),
                  title: Text('置顶', style: tt.bodySmall),
                  dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero,
                )),
              if (msg.tpy == 4)
                PopupMenuItem(value: 'transcribe', child: ListTile(
                  leading: Icon(Icons.notes, size: 18),
                  title: Text(t.transcribe, style: tt.bodySmall),
                  dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero,
                )),
              if ([1, 11, 13].contains(msg.tpy))
                PopupMenuItem(value: 'translate', child: ListTile(
                  leading: Icon(Icons.translate, size: 18),
                  title: Text('翻译', style: tt.bodySmall),
                  dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero,
                )),
              PopupMenuItem(value: 'delete', child: ListTile(
                leading: Icon(Icons.delete_outline, size: 18),
                title: Text('删除', style: tt.bodySmall),
                dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero,
              )),
            ],
          ).then((value) {
            if (value == 'thread') {
              im.openThread(msg);
            } else if (value == 'favorite') {
              im.favoriteMessage(msg);
            } else if (value == 'pin') {
              im.pinMessage(msg.chatId, msg.id);
            } else if (value == 'unpin') {
              im.unpinMessage(msg.chatId, msg.id);
            } else if (value == 'transcribe') {
              im.transcribeVoice(msg.id, msg.chatId);
            } else if (value == 'translate') {
              im.translateMessage(msg.id, msg.chatId, 'zh');
            } else if (value == 'delete') {
              _confirmDelete(context, im, msg);
            }
          });
        },
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          child: Icon(Icons.more_horiz, size: 16, color: cs.onSurfaceVariant),
        ),
      ),
    );
  }

  void _showReactionPicker(BuildContext context, ImController im) {
    final msg = widget.msg;
    showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 100, 100),
      items: const [
        PopupMenuItem(value: 1, child: Text('👍')),
        PopupMenuItem(value: 2, child: Text('❤️')),
        PopupMenuItem(value: 3, child: Text('😄')),
        PopupMenuItem(value: 4, child: Text('😮')),
        PopupMenuItem(value: 5, child: Text('😢')),
        PopupMenuItem(value: 6, child: Text('🙏')),
      ],
    ).then((value) {
      if (value != null) {
        // TODO: implement reaction via SDK
        L.d("reaction: $value on message ${msg.id}");
      }
    });
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
    final u = widget.user;
    final im = ref.watch(imProvider);
    final presence = im.presenceMap[u.id];
    final isOnline = presence?.status == 1;
    return GestureDetector(
      onTap: () {},
      child: Stack(
        children: [
          _MessageAvatar(user: u),
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
    Future<dynamic> load() async {
      return im.getReadMembers(msg.chatId, msg.id);
    }

    final resp = await load();
    if (resp == null || context.mounted == false) return;
    if (isDesktop) {
      _showReadDetailDesktop(context, msg, resp, load);
    } else {
      _showReadDetailMobile(context, msg, resp, load);
    }
  }

  void _showReadDetailMobile(BuildContext context, Message msg, dynamic resp, Future<dynamic> Function() load) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return _ReadDetailSheet(resp: resp, load: load, cs: cs, tt: tt);
      },
    );
  }

  void _showReadDetailDesktop(BuildContext context, Message msg, dynamic resp, Future<dynamic> Function() load) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: 420,
            height: 400,
            child: _ReadDetailPanel(resp: resp, load: load, cs: cs, tt: tt),
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

/// 已读详情 - 移动端 bottom sheet（带刷新）。
/// 数据一次性全量返回（仅 ID 级别、量小）；已读状态最多承载到 2000 人群，超大群仅展示 at 成员，后续单独处理。
class _ReadDetailSheet extends StatefulWidget {
  final dynamic resp;
  final Future<dynamic> Function() load;
  final ColorScheme cs;
  final TextTheme tt;
  const _ReadDetailSheet({
    required this.resp,
    required this.load,
    required this.cs,
    required this.tt,
  });

  @override
  State<_ReadDetailSheet> createState() => _ReadDetailSheetState();
}

class _ReadDetailSheetState extends State<_ReadDetailSheet> {
  late List<dynamic> _members = List<dynamic>.from(widget.resp?.members ?? []);

  Future<void> _refresh() async {
    final resp = await widget.load();
    if (!mounted || resp == null) return;
    setState(() {
      _members = List<dynamic>.from(resp.members ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tt = widget.tt;
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(maxHeight: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(t.readDetailTitle, style: tt.titleSmall)),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                tooltip: t.refresh,
                onPressed: _refresh,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _members.length,
              itemBuilder: (ctx, i) {
                final m = _members[i];
                return _ReadMemberRow(m: m, cs: widget.cs, tt: tt, showStatus: true);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 已读详情 - 桌面端两栏面板（已读/未读各一栏，带刷新）。
class _ReadDetailPanel extends StatefulWidget {
  final dynamic resp;
  final Future<dynamic> Function() load;
  final ColorScheme cs;
  final TextTheme tt;
  const _ReadDetailPanel({
    required this.resp,
    required this.load,
    required this.cs,
    required this.tt,
  });

  @override
  State<_ReadDetailPanel> createState() => _ReadDetailPanelState();
}

class _ReadDetailPanelState extends State<_ReadDetailPanel> {
  late List<dynamic> _members = List<dynamic>.from(widget.resp?.members ?? []);
  final _scrolls = [ScrollController(), ScrollController()];

  @override
  void dispose() {
    _scrolls[0].dispose();
    _scrolls[1].dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final resp = await widget.load();
    if (!mounted || resp == null) return;
    setState(() {
      _members = List<dynamic>.from(resp.members ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tt = widget.tt;
    final read = _members.where((m) => m.isRead).toList();
    final unread = _members.where((m) => !m.isRead).toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ReadColumn(
            title: '${read.length} ${t.haveRead}',
            members: read,
            cs: widget.cs,
            tt: tt,
            scroll: _scrolls[0],
            onRefresh: _refresh,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _ReadColumn(
            title: '${unread.length} ${t.unread}',
            members: unread,
            cs: widget.cs,
            tt: tt,
            scroll: _scrolls[1],
            onRefresh: _refresh,
          ),
        ),
      ],
    );
  }
}

class _ReadColumn extends StatelessWidget {
  final String title;
  final List<dynamic> members;
  final ColorScheme cs;
  final TextTheme tt;
  final ScrollController scroll;
  final Future<void> Function() onRefresh;
  const _ReadColumn({
    required this.title,
    required this.members,
    required this.cs,
    required this.tt,
    required this.scroll,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: tt.titleSmall),
              IconButton(
                icon: const Icon(Icons.refresh, size: 16),
                tooltip: t.refresh,
                onPressed: onRefresh,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            controller: scroll,
            itemCount: members.length,
            itemBuilder: (ctx, i) => _ReadMemberRow(m: members[i], cs: cs, tt: tt, showStatus: false),
          ),
        ),
      ],
    );
  }
}

/// 已读详情单行成员。
class _ReadMemberRow extends StatelessWidget {
  final dynamic m;
  final ColorScheme cs;
  final TextTheme tt;
  final bool showStatus;
  const _ReadMemberRow({
    required this.m,
    required this.cs,
    required this.tt,
    required this.showStatus,
  });

  @override
  Widget build(BuildContext context) {
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
      trailing: showStatus
          ? Icon(
              m.isRead ? Icons.check_circle : Icons.access_time,
              size: 16,
              color: m.isRead ? cs.primary : cs.onSurfaceVariant,
            )
          : null,
    );
  }
}

/// 消息气泡 + 已读标记 + hover 菜单的合并组件。
/// hover 菜单仅在鼠标悬停时挂载，位置基于布局后测量的气泡宽度计算，
/// 不在 build 期读取 RenderBox size，避免 "could not get size during build"。
class _BubbleWithMenu extends StatefulWidget {
  final Widget child;
  final bool isSelf;
  final bool showRead;
  final ReadState readState;
  final VoidCallback onReadTap;
  final Widget Function() hoverMenuBuilder;
  final ColorScheme cs;
  final TextTheme tt;
  final Message msg;

  const _BubbleWithMenu({    required this.child,
    required this.isSelf,
    required this.showRead,
    required this.readState,
    required this.onReadTap,
    required this.hoverMenuBuilder,
    required this.cs,
    required this.tt,
    required this.msg,
  });

  @override
  State<_BubbleWithMenu> createState() => _BubbleWithMenuState();
}

class _BubbleWithMenuState extends State<_BubbleWithMenu> {
  var _hovering = false;
  final _bubbleKey = GlobalKey();
  double _bubbleW = 0;
  // 记录 _bubbleW 对应测量的是哪条消息。ListView 会复用 State，
  // 避免用上一条较宽消息的残留宽度导致短消息的 hover 菜单误翻转。
  int _measuredMsgId = -1;
  // hover 令牌：每次进入 hover 自增。菜单只有在“本次 hover 的测量”完成后
  // （_measureToken 与该次 hover 令牌一致）才渲染，从根上杜绝用旧测量结果
  // 定位菜单导致的误翻转。
  int _hoverToken = 0;
  int _measureToken = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(covariant _BubbleWithMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 消息/列宽变化（含 State 被 ListView 复用到新消息）时，立即作废上一条
    // 消息的测量结果，避免用旧气泡宽度误判位置；随后重新测量。
    if (oldWidget.msg.id != widget.msg.id) {
      if (_measuredMsgId != widget.msg.id.toInt()) {
        _measuredMsgId = -1;
        _bubbleW = 0;
        _measureToken = -1;
      }
      _scheduleMeasure();
    }
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  /// 布局完成后测量气泡实际宽度，供 hover 菜单位置使用。
  void _measure() {
    if (!mounted) return;
    final w = _bubbleKey.currentContext?.size?.width;
    if (w == null) return;
    final mid = widget.msg.id.toInt();
    if (w != _bubbleW ||
        _measuredMsgId != mid ||
        _measureToken != _hoverToken) {
      setState(() {
        _bubbleW = w;
        _measuredMsgId = mid;
        _measureToken = _hoverToken;
      });
    }
  }

  void _onHoverEnter() {
    setState(() {
      _hovering = true;
      // 本次 hover 尚未完成测量，先失效旧测量结果，隐藏菜单直到重新测量。
      _hoverToken += 1;
      _measureToken = -1;
    });
    _scheduleMeasure();
  }

  void _onHoverExit() {
    setState(() => _hovering = false);
  }

  /// hover 菜单是否放在气泡右侧；右侧空间不足时放在左侧。
  /// maxW 来自布局时的可用宽度（Flexible 的约束上限），换算后
  /// 右侧可用空间 = maxW - 气泡宽，无需依赖外部缓存的行宽。
  bool _showOnRight(double maxW) {
    const menuW = 116.0;
    return maxW - _bubbleW >= menuW;
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    final tt = widget.tt;
    final isSelf = widget.isSelf;
    final bubbleColor = isSelf ? cs.primaryContainer : cs.surfaceContainerHigh;
    final textColor = isSelf ? cs.onPrimaryContainer : cs.onSurface;

    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      key: _bubbleKey,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DefaultTextStyle(
                        style: tt.bodyMedium!.copyWith(color: textColor),
                        child: widget.child,
                      ),
                    ),
                    if (isDesktop &&
                        _hovering &&
                        _measureToken == _hoverToken &&
                        _measuredMsgId == widget.msg.id.toInt() &&
                        _bubbleW > 0)
                      Positioned(
                        left: _showOnRight(constraints.maxWidth)
                            ? _bubbleW + 4
                            : null,
                        right: _showOnRight(constraints.maxWidth) ? null : 4,
                        top: 0,
                        child: widget.hoverMenuBuilder(),
                      ),
                  ],
                );
              },
            ),
          ),
          if (widget.showRead)
            _ReadCircle(
              readState: widget.readState,
              onTap: widget.onReadTap,
            ),
        ],
      ),
    );
  }
}

int _readPercent(ReadState rs) {
  if (rs.total <= 0) return 0;
  final pct = (rs.readCount / rs.total * 100).round();
  if (pct >= 100) return 100;
  return ((pct / 10).floor() * 10).clamp(10, 90);
}

class _ReadCircle extends StatelessWidget {
  final ReadState readState;
  final VoidCallback onTap;

  const _ReadCircle({
    required this.readState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = _readPercent(readState);
    const green = Color(0xFF4ADE80);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CustomPaint(
            painter: _CirclePainter(percent: pct, color: green),
            child: pct >= 100
                ? Center(
                    child: Text('✓', style: TextStyle(color: green, fontSize: 11, fontWeight: FontWeight.w700)),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final int percent;
  final Color color;

  _CirclePainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(rect, bgPaint);

    if (percent > 0) {
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -math.pi / 2, (percent / 100) * 2 * math.pi, false, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CirclePainter old) => old.percent != percent;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // 限制最大展示尺寸：宽不超过可用区域，高不超过 maxH，超限按比例缩放
        const maxH = 360.0;
        final maxW = constraints.hasBoundedWidth ? constraints.maxWidth : 360.0;
        final ow = img.width.toDouble();
        final oh = img.height.toDouble();
        var w = ow > 0 ? ow : 200.0;
        var h = oh > 0 ? oh : 200.0;
        if (w > maxW || h > maxH) {
          final scale = math.min(maxW / w, maxH / h);
          if (scale < 1) {
            w *= scale;
            h *= scale;
          }
        }
        return GestureDetector(
          onTap: () => _previewImage(context, url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: url,
              width: w,
              height: h,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: w,
                height: h,
                color: cs.surfaceContainerLow,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (_, __, ___) => Container(
                width: w,
                height: h,
                color: cs.errorContainer,
                child: Icon(Icons.broken_image, color: cs.onErrorContainer),
              ),
            ),
          ),
        );
      },
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
            padding: EdgeInsets.fromLTRB(12, 10, 12, hasActions ? 4 : 10),
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

/// 消息发送者头像：优先展示真实头像，头像为空或加载失败时 fallback 到首字母默认头像
class _MessageAvatar extends StatefulWidget {
  final User user;

  const _MessageAvatar({required this.user});

  @override
  State<_MessageAvatar> createState() => _MessageAvatarState();
}

class _MessageAvatarState extends State<_MessageAvatar> {
  bool _failed = false;

  @override
  void didUpdateWidget(_MessageAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.avatar != widget.user.avatar) {
      _failed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final u = widget.user;
    final avatarUrl = CommonUtils.fixResourceUrl(u.avatar);
    final showImage = avatarUrl.isNotEmpty && !_failed;

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: showImage
          ? Image(
              image: CachedNetworkImageProvider(avatarUrl),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                if (!_failed) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _failed = true);
                  });
                }
                return _buildFallback();
              },
            )
          : _buildFallback(),
    );
  }

  Widget _buildFallback() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final u = widget.user;
    return Center(
      child: Text(
        u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
        style: tt.bodySmall?.copyWith(color: cs.onPrimary),
      ),
    );
  }
}
