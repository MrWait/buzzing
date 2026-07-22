import 'package:buzzing/controller/im.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/const.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/entity.pbenum.dart';
import 'package:buzzing/models/idl/im_ext.pb.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/res/theme.dart';
import 'package:buzzing/routes/app_routes.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:buzzing/widget/message.dart';
import 'package:buzzing/widget/message_input.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bt = Theme.of(context).extension<BuzzingTheme>()!;
    final im = ref.watch(imProvider);
    return Container(
      color: bt.mentionBg,
      child: ListenableBuilder(
        listenable: im,
        builder: (ctx, _) {
          var chatId = im.chatId;
          var chat = im.getChat(chatId);
          if (chatId == 0) {
            return Center(
              child: Text(
                '选择一个会话开始聊天',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          final announcement = chat?.chatType == 2
              ? im.entity.messages[chatId]
              : null;
          return Column(
            children: [
              _ChatHeader(chat: chat, chatId: chatId, im: im),
              if (announcement != null &&
                  announcement.tpy == MessageType.ANNOUNCEMENT.value)
                _AnnouncementBanner(
                  message: announcement,
                  isOwner: im.userId == chat?.ownerId,
                  isAdmin: chat?.adminIds.contains(im.userId) ?? false,
                  im: im,
                  chatId: chatId,
                ),
              if (im.pinnedMessages.isNotEmpty)
                _PinnedBanner(
                  pinnedMessages: im.pinnedMessages,
                  im: im,
                ),
              if (im.chatSearchVisible)
                _ChatSearchBar(im: im, chatId: chatId),
              Expanded(
                child: im.isThreadPanelOpen && im.threadRootMessage != null
                    ? _ThreadPanel(im: im)
                    : MessageView(),
              ),
              if (!im.isThreadPanelOpen) MessageInput(),
            ],
          );
        },
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final dynamic chat;
  final Int64 chatId;
  final ImController im;

  const _ChatHeader({required this.chat, required this.chatId, required this.im});

  String _typingText() {
    if (im.typingUsers.isEmpty) return '';
    var names = im.typingUsers.values.map((e) => e.name).join('、');
    return '$names 正在输入...';
  }

  String _presenceText() {
    if (chat?.chatType == 2) return '';
    var peerId = chat?.peerAId == im.userId ? chat?.peerBId : chat?.peerAId;
    if (peerId == null) return '';
    var p = im.presenceMap[peerId];
    if (p == null) return '';
    switch (p.status) {
      case 1: return '在线';
      case 2: return '离开';
      case 3: return '忙碌';
      default: return '离线';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    var name = '';
    if (chat != null) {
      name = chat.name;
    }
    if (name.length > 40) name = '${name.substring(0, 40)}...';

    final typing = _typingText();
    final presence = _presenceText();

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Stack(
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
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: tt.bodySmall?.copyWith(color: cs.onPrimary),
                ),
              ),
              // 在线状态圆点 (仅 P2P)
              if (presence.isNotEmpty)
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: presence == '在线' ? cs.primary : cs.onSurfaceVariant,
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.surface, width: 1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: tt.titleSmall),
                if (typing.isNotEmpty)
                  Text(typing, style: tt.bodySmall?.copyWith(color: cs.primary, fontSize: 11))
                else if (presence.isNotEmpty)
                  Text(presence, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, size: 20, color: cs.onSurfaceVariant),
            onPressed: () => im.toggleChatSearch(),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          if (chat != null && chat.chatType == 2) ...[
            IconButton(
              icon: Icon(Icons.more_horiz, size: 20, color: cs.onSurfaceVariant),
              onPressed: () {
                context.push('${AppRoute.GROUP_PROFILE}/$chatId');
              },
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnnouncementBanner extends ConsumerWidget {
  final dynamic message;
  final bool isOwner;
  final bool isAdmin;
  final ImController im;
  final Int64 chatId;

  const _AnnouncementBanner({
    required this.message,
    required this.isOwner,
    required this.isAdmin,
    required this.im,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final msg = message as dynamic;
    return GestureDetector(
      onTap: () => _showAnnouncementDetail(context, msg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.3),
          border: Border(bottom: BorderSide(color: cs.outlineVariant)),
        ),
        child: Row(
          children: [
            Icon(Icons.campaign, size: 16, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg.summary.isNotEmpty ? msg.summary : '群公告',
                    style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (msg.summary.isNotEmpty)
                    Text(
                      msg.summary,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (isOwner || isAdmin)
              GestureDetector(
                onTap: () async {
                  await im.deleteAnnouncement(chatId);
                },
                child: Icon(Icons.close, size: 16, color: cs.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }

  void _showAnnouncementDetail(BuildContext context, dynamic msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(msg.summary.isNotEmpty ? msg.summary : '群公告'),
        content: Text(
          msg.content.toString(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

class _PinnedBanner extends ConsumerWidget {
  final List<Message> pinnedMessages;
  final ImController im;

  const _PinnedBanner({required this.pinnedMessages, required this.im});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      constraints: const BoxConstraints(maxHeight: 80),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.3),
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Row(
              children: [
                Icon(Icons.push_pin, size: 14, color: cs.primary),
                const SizedBox(width: 4),
                Text('置顶消息', style: tt.labelSmall?.copyWith(color: cs.primary)),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: pinnedMessages.length,
              itemBuilder: (ctx, i) {
                final msg = pinnedMessages[i];
                final sender = im.getUser(msg.fromId);
                return InkWell(
                  onTap: () {
                    // TODO: scroll to message
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${sender?.name ?? ''}: ${msg.summary}',
                            style: tt.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => im.unpinMessage(im.chatId, msg.id),
                          child: Icon(Icons.close, size: 14, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadPanel extends ConsumerWidget {
  final ImController im;

  const _ThreadPanel({required this.im});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final root = im.threadRootMessage!;
    final textCtrl = TextEditingController();

    return Container(
      color: cs.surface,
      child: Column(
        children: [
          // Header
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant)),
            ),
            child: Row(
              children: [
                Text('Thread', style: tt.titleSmall),
                const Spacer(),
                GestureDetector(
                  onTap: im.closeThread,
                  child: Icon(Icons.close, size: 18, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          // Root message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              border: Border(bottom: BorderSide(color: cs.outlineVariant)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  im.getUser(root.fromId)?.name ?? '',
                  style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(root.summary, style: tt.bodyMedium),
              ],
            ),
          ),
          // Replies
          Expanded(
            child: ListView.builder(
              itemCount: im.threadReplies.length,
              itemBuilder: (ctx, i) {
                final reply = im.threadReplies[i];
                final user = im.getUser(reply.fromId);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(4)),
                        alignment: Alignment.center,
                        child: Text(
                          (user?.name ?? '?')[0].toUpperCase(),
                          style: tt.labelSmall?.copyWith(color: cs.onPrimary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.name ?? '', style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                            Text(reply.summary, style: tt.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: cs.outlineVariant)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textCtrl,
                    decoration: const InputDecoration(
                      hintText: '回复到 Thread...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, size: 18, color: cs.primary),
                  onPressed: () {
                    var t = textCtrl.text.trim();
                    if (t.isNotEmpty) {
                      im.sendThreadReply(t);
                      textCtrl.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final im = ref.watch(imProvider);
    return ListenableBuilder(
      listenable: im,
      builder: (ctx, _) {
        L.d("rebuild message view, count: ${im.messagePosList.length}");
        return Container(
          color: cs.surface,
          child: SelectionArea(
            child: ListView.builder(
              controller: im.msgCtrl,
              itemCount: im.messagePosList.length,
              itemBuilder: (context, index) {
                var mi = im.messagePosList[index];
                var msg = im.entity.messages[mi.id] ?? Message();
                var user = im.entity.users[msg.fromId] ?? User();
                return MessageBox(key: mi.globalKey, msg: msg, user: user);
              },
            ),
          ),
        );
      },
    );
  }
}

class _ChatSearchBar extends StatefulWidget {
  final ImController im;
  final Int64 chatId;
  const _ChatSearchBar({required this.im, required this.chatId});

  @override
  _ChatSearchBarState createState() => _ChatSearchBarState();
}

class _ChatSearchBarState extends State<_ChatSearchBar> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final im = widget.im;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              focusNode: _focusNode,
              onSubmitted: (v) => im.doChatSearch(widget.chatId, v),
              decoration: InputDecoration(
                hintText: '${t.searchInChat}...',
                hintStyle: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: tt.bodySmall,
            ),
          ),
          if (im.chatSearchResults.isNotEmpty) ...[
            Text(
              '${im.chatSearchIndex + 1}/${im.chatSearchResults.length}',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            IconButton(
              icon: Icon(Icons.keyboard_arrow_up, size: 18),
              onPressed: im.prevChatSearchResult,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 24, minHeight: 24),
            ),
            IconButton(
              icon: Icon(Icons.keyboard_arrow_down, size: 18),
              onPressed: im.nextChatSearchResult,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
          IconButton(
            icon: Icon(Icons.close, size: 16),
            onPressed: () => im.toggleChatSearch(),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }
}
