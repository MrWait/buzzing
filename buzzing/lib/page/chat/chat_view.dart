import 'package:buzzing/controller/im.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/const.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/entity.pbenum.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/page/chat/group_edit_page.dart';
import 'package:buzzing/page/chat/group_manage_page.dart';
import 'package:buzzing/page/chat/group_profile_page.dart';
import 'package:buzzing/page/chat/member_list_page.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/routes/app_routes.dart';
import 'package:buzzing/res/theme.dart';
import 'package:buzzing/utils/data_persistence.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:buzzing/utils/platform.dart';
import 'package:buzzing/widget/announcement_dialog.dart';
import 'package:buzzing/widget/message.dart';
import 'package:buzzing/widget/message_input.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String? routeChatId;

  const ChatPage({super.key, this.routeChatId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  @override
  void initState() {
    super.initState();
    _enterChatFromRoute();
  }

  @override
  void didUpdateWidget(ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.routeChatId != oldWidget.routeChatId) {
      _enterChatFromRoute();
    }
  }

  void _enterChatFromRoute() {
    if (widget.routeChatId != null) {
      final id = Int64(int.parse(widget.routeChatId!));
      ref.read(imProvider).enterChat(id);
    }
  }

  void _startMeeting(BuildContext context) {
    final im = ref.read(imProvider);
    if (im.chatId == Int64(0)) return;

    final meetingHome = ref.read(meetingHomeLogicProvider);
    final account = DataPersistence.getAccount();
    final hostName = account?.loginUser?.user.name ?? '';

    meetingHome.createMeeting(title: '群聊会议').then((resp) {
      if (resp == null || !resp.hasMeeting()) return;
      meetingHome.shareMeetingToChat(
        im: im,
        chatId: im.chatId,
        roomId: resp.meeting.roomId,
        title: resp.meeting.title,
        hostName: hostName,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已发送会议邀请'), duration: Duration(seconds: 2)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bt = Theme.of(context).extension<BuzzingTheme>()!;
    final im = ref.watch(imProvider);

    if (isMobile && widget.routeChatId != null) {
      final cs = Theme.of(context).colorScheme;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: cs.surface,
          foregroundColor: cs.onSurface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(im.getChat(im.chatId)?.name ?? ''),
          actions: [
            IconButton(
              icon: const Icon(Icons.videocam),
              onPressed: () => _startMeeting(context),
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () => context.push('${AppRoute.GROUP_PROFILE}/${im.chatId}'),
            ),
          ],
        ),
        body: ListenableBuilder(
          listenable: im,
          builder: (ctx, _) => _ChatBody(bt: bt, im: im, showHeader: false),
        ),
      );
    }

    return Container(
      color: bt.mentionBg,
      child: ListenableBuilder(
        listenable: im,
        builder: (ctx, _) => _ChatBody(bt: bt, im: im),
      ),
    );
  }
}

class _ChatBody extends StatelessWidget {
  final BuzzingTheme bt;
  final ImController im;
  final bool showHeader;

  const _ChatBody({required this.bt, required this.im, this.showHeader = true});

  @override
  Widget build(BuildContext context) {
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
    if (announcement != null) {
      L.d(
        "chat body announcement, id=${announcement.id} tpy=${announcement.tpy} "
        "status=${announcement.status} summary=${announcement.summary}",
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            children: [
              if (showHeader)
                _ChatHeader(chat: chat, chatId: chatId, im: im),
              if (announcement != null &&
                  announcement.tpy == MessageType.ANNOUNCEMENT.value &&
                  announcement.status != EntityStatus.DELETED.value)
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
                    : const MessageView(),
              ),
              if (!im.isThreadPanelOpen) MessageInput(),
            ],
          ),
        ),
        if (isDesktop && im.isGroupProfileOpen)
          _GroupProfilePanel(im: im, chatId: chatId),
      ],
    );
  }
}

class _GroupProfilePanel extends ConsumerWidget {
  final ImController im;
  final Int64 chatId;

  const _GroupProfilePanel({required this.im, required this.chatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final inMemberList = im.isGroupMemberListOpen;
    final inGroupEdit = im.isGroupEditOpen;
    final inGroupManage = im.isGroupManageOpen;
    final subTitle = inMemberList
        ? '群成员'
        : (inGroupEdit
            ? '群信息'
            : (inGroupManage ? '群管理' : '设置'));
    final titleStyle = (inMemberList || inGroupEdit || inGroupManage)
        ? tt.titleSmall
        : tt.titleMedium;
    final onBack = inMemberList
        ? im.closeGroupMemberList
        : (inGroupEdit ? im.closeGroupEdit : im.closeGroupManage);
    return Container(
      width: 320,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: cs.outlineVariant)),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant)),
            ),
            child: Row(
              children: [
                if (inMemberList || inGroupEdit || inGroupManage) ...[
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        size: 18, color: cs.onSurfaceVariant),
                    onPressed: onBack,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(subTitle, style: titleStyle),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, size: 18, color: cs.onSurfaceVariant),
                  onPressed: im.closeGroupProfile,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          Expanded(
            child: inMemberList
                ? MemberListView(chatId: chatId)
                : inGroupEdit
                    ? GroupEditView(chatId: chatId)
                    : inGroupManage
                        ? GroupManageView(chatId: chatId)
                        : GroupProfileContent(chatId: chatId),
          ),
        ],
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
                if (isDesktop) {
                  im.openGroupProfile();
                } else {
                  context.push('${AppRoute.GROUP_PROFILE}/$chatId');
                }
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
  final Message message;
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
    final title = announcementTitle(message);
    final body = announcementBodyText(message);
    return GestureDetector(
      onTap: () => showAnnouncementViewer(context, message, im: im),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    title.isNotEmpty ? title : '群公告',
                    style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (body.isNotEmpty)
                    Text(
                      body,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (isOwner || isAdmin) ...[
              IconButton(
                icon: Icon(Icons.edit_outlined,
                    size: 16, color: cs.onSurfaceVariant),
                tooltip: '编辑公告',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: () =>
                    showAnnouncementEditor(context, im, chatId, message),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 16, color: cs.onSurfaceVariant),
                tooltip: '删除公告',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除公告'),
        content: const Text('确定要删除该群公告吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              im.deleteAnnouncement(chatId);
              Navigator.pop(ctx);
            },
            child: Text('删除',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.error)),
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
  const MessageView({super.key});

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
                return MessageBox(msg: msg, user: user);
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
