import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/message.pb.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/res/theme.dart';
import 'package:buzzing/routes/app_routes.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GroupProfilePage extends ConsumerWidget {
  final Int64 chatId;

  const GroupProfilePage({super.key, required this.chatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bt = Theme.of(context).extension<BuzzingTheme>()!;
    final im = ref.watch(imProvider);
    final chat = im.getChat(chatId);
    if (chat == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('群资料')),
        body: const Center(child: Text('群聊不存在')),
      );
    }

    final isOwner = im.userId == chat.ownerId;
    final isAdmin = chat.adminIds.contains(im.userId);

    return Scaffold(
      appBar: AppBar(title: const Text('群资料')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GroupInfoHeader(chat: chat, im: im),
          const SizedBox(height: 24),
          if (isOwner || isAdmin) ...[
            _SectionTitle(title: '群公告'),
            _AnnouncementTile(chat: chat, chatId: chatId, im: im),
            const SizedBox(height: 16),
            _SectionTitle(title: '成员管理'),
            _MemberManagementTile(chatId: chatId, isOwner: isOwner, isAdmin: isAdmin, cs: cs),
            const SizedBox(height: 16),
            _SectionTitle(title: '禁言设置'),
            _MuteManagementTile(chat: chat, chatId: chatId, isOwner: isOwner, isAdmin: isAdmin, im: im, cs: cs),
            const SizedBox(height: 16),
            _SectionTitle(title: '入群方式'),
            _JoinModeTile(chat: chat, chatId: chatId, im: im, isOwner: isOwner, isAdmin: isAdmin, cs: cs),
            const SizedBox(height: 16),
            _SectionTitle(title: '邀请链接'),
            _InviteLinksTile(chatId: chatId, isOwner: isOwner, isAdmin: isAdmin, cs: cs),
            const SizedBox(height: 16),
            _SectionTitle(title: '入群申请'),
            _JoinRequestsTile(chatId: chatId, isOwner: isOwner, isAdmin: isAdmin, cs: cs),
          ],
          const SizedBox(height: 16),
          _DangerZoneTile(chatId: chatId, isOwner: isOwner, im: im, cs: cs, bt: bt),
        ],
      ),
    );
  }
}

class _GroupInfoHeader extends StatelessWidget {
  final Chat chat;
  final ImController im;

  const _GroupInfoHeader({required this.chat, required this.im});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: cs.primaryContainer,
          child: Text(
            chat.name.isNotEmpty ? chat.name[0].toUpperCase() : 'G',
            style: tt.headlineSmall?.copyWith(color: cs.onPrimaryContainer),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(chat.name, style: tt.titleMedium),
              if (chat.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(chat.description,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w600)),
    );
  }
}

class _AnnouncementTile extends ConsumerWidget {
  final Chat chat;
  final Int64 chatId;
  final ImController im;

  const _AnnouncementTile(
      {required this.chat,
      required this.chatId,
      required this.im});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final announcement = im.entity.messages[chatId];
    return Card(
      child: ListTile(
        leading: Icon(Icons.campaign, color: cs.primary),
        title: Text(announcement != null ? '查看公告' : '设置公告'),
        subtitle: announcement != null
            ? Text(announcement.summary.isNotEmpty
                ? announcement.summary
                : '点击查看详情',
                maxLines: 2, overflow: TextOverflow.ellipsis)
            : null,
        trailing: announcement != null
            ? IconButton(
                icon: Icon(Icons.delete_outline, color: cs.error),
                onPressed: () async {
                  await im.deleteAnnouncement(chatId);
                },
              )
            : null,
        onTap: () => _showAnnouncementEditor(context, im, chatId, announcement),
      ),
    );
  }
}

Future<void> _showAnnouncementEditor(
    BuildContext context, ImController im, Int64 chatId, Message? announcement) async {
  final titleCtrl = TextEditingController(text: announcement?.summary ?? '');
  final bodyCtrl = TextEditingController(text: announcement?.content.toString() ?? '');
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('群公告'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleCtrl,
            decoration: const InputDecoration(labelText: '标题', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bodyCtrl,
            decoration: const InputDecoration(labelText: '内容', border: OutlineInputBorder()),
            maxLines: 5,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
        ElevatedButton(
          onPressed: () async {
            await im.setAnnouncement(
                chatId, titleCtrl.text, 0, bodyCtrl.text.codeUnits, titleCtrl.text);
            if (ctx.mounted) Navigator.pop(ctx, true);
          },
          child: const Text('保存'),
        ),
      ],
    ),
  );
}

class _MemberManagementTile extends StatelessWidget {
  final Int64 chatId;
  final bool isOwner;
  final bool isAdmin;
  final ColorScheme cs;

  const _MemberManagementTile(
      {required this.chatId,
      required this.isOwner,
      required this.isAdmin,
      required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.people, color: cs.primary),
        title: const Text('成员列表'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('${AppRoute.MEMBER_LIST}/$chatId'),
      ),
    );
  }
}

class _MuteManagementTile extends ConsumerStatefulWidget {
  final Chat chat;
  final Int64 chatId;
  final bool isOwner;
  final bool isAdmin;
  final ImController im;
  final ColorScheme cs;

  const _MuteManagementTile(
      {required this.chat,
      required this.chatId,
      required this.isOwner,
      required this.isAdmin,
      required this.im,
      required this.cs});

  @override
  _MuteManagementTileState createState() => _MuteManagementTileState();
}

class _MuteManagementTileState extends ConsumerState<_MuteManagementTile> {
  bool _globalMuted = false;

  @override
  void initState() {
    super.initState();
    final until = widget.chat.globalMuteUntil;
    _globalMuted = until != Int64.ZERO &&
        (until > Int64(DateTime.now().millisecondsSinceEpoch));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: Icon(Icons.volume_off, color: cs.error),
            title: const Text('全员禁言'),
            subtitle: Text(_globalMuted ? '已开启' : '已关闭'),
            value: _globalMuted,
            onChanged: (val) async {
              final untilMs =
                  val ? Int64(DateTime.now().millisecondsSinceEpoch + 86400000 * 365) : Int64.ZERO;
              await widget.im.globalMute(widget.chatId, untilMs);
              setState(() => _globalMuted = val);
            },
          ),
        ],
      ),
    );
  }
}

class _JoinModeTile extends ConsumerStatefulWidget {
  final Chat chat;
  final Int64 chatId;
  final ImController im;
  final bool isOwner;
  final bool isAdmin;
  final ColorScheme cs;

  const _JoinModeTile(
      {required this.chat,
      required this.chatId,
      required this.im,
      required this.isOwner,
      required this.isAdmin,
      required this.cs});

  @override
  _JoinModeTileState createState() => _JoinModeTileState();
}

class _JoinModeTileState extends ConsumerState<_JoinModeTile> {
  late int _joinMode;

  @override
  void initState() {
    super.initState();
    _joinMode = widget.chat.joinMode;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final labels = ['允许任何人', '需要审核', '禁止加入'];
    return Card(
      child: ListTile(
        leading: Icon(Icons.verified_user, color: cs.primary),
        title: const Text('入群方式'),
        subtitle: Text(labels[_joinMode.clamp(0, 2)]),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showJoinModePicker(context),
      ),
    );
  }

  void _showJoinModePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('选择入群方式'),
        children: [
          SimpleDialogOption(
            onPressed: () async {
              await widget.im.updateChat(widget.chatId, joinMode: 0);
              setState(() => _joinMode = 0);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('允许任何人'),
          ),
          SimpleDialogOption(
            onPressed: () async {
              await widget.im.updateChat(widget.chatId, joinMode: 1);
              setState(() => _joinMode = 1);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('需要审核'),
          ),
          SimpleDialogOption(
            onPressed: () async {
              await widget.im.updateChat(widget.chatId, joinMode: 2);
              setState(() => _joinMode = 2);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('禁止加入'),
          ),
        ],
      ),
    );
  }
}

class _InviteLinksTile extends StatelessWidget {
  final Int64 chatId;
  final bool isOwner;
  final bool isAdmin;
  final ColorScheme cs;

  const _InviteLinksTile(
      {required this.chatId,
      required this.isOwner,
      required this.isAdmin,
      required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.link, color: cs.primary),
        title: const Text('邀请链接'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('${AppRoute.INVITE_LINKS}/$chatId'),
      ),
    );
  }
}

class _JoinRequestsTile extends StatelessWidget {
  final Int64 chatId;
  final bool isOwner;
  final bool isAdmin;
  final ColorScheme cs;

  const _JoinRequestsTile(
      {required this.chatId,
      required this.isOwner,
      required this.isAdmin,
      required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.pending_actions, color: cs.primary),
        title: const Text('入群申请'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('${AppRoute.JOIN_REQUESTS}/$chatId'),
      ),
    );
  }
}

class _DangerZoneTile extends StatelessWidget {
  final Int64 chatId;
  final bool isOwner;
  final ImController im;
  final ColorScheme cs;
  final BuzzingTheme bt;

  const _DangerZoneTile(
      {required this.chatId,
      required this.isOwner,
      required this.im,
      required this.cs,
      required this.bt});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isOwner)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showTransferOwnerDialog(context),
              icon: Icon(Icons.swap_horiz, color: cs.primary),
              label: const Text('转让群主'),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.primary,
                side: BorderSide(color: cs.outline),
              ),
            ),
          ),
        if (!isOwner)
          const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmLeaveGroup(context),
            icon: Icon(Icons.exit_to_app, color: cs.error),
            label: const Text('退出群聊'),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.error,
              side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }

  void _showTransferOwnerDialog(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('转让群主'),
        content: const Text('此功能需要在成员列表中操作。请前往成员列表，长按目标成员选择「转让群主」。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('知道了')),
        ],
      ),
    );
  }

  void _confirmLeaveGroup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出群聊'),
        content: const Text('确定要退出该群聊吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: Text('退出', style: TextStyle(color: cs.error)),
          ),
        ],
      ),
    );
  }
}
