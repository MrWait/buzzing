import 'dart:math' as math;

import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/chat.pb.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/entity.pbenum.dart';
import 'package:buzzing/page/chat/group_share.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/res/theme.dart';
import 'package:buzzing/routes/app_routes.dart';
import 'package:buzzing/utils/platform.dart';
import 'package:buzzing/widget/member_picker/member_picker.dart';
import 'package:buzzing/widget/announcement_dialog.dart';
import 'package:buzzing/widget/user_list_item.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GroupProfilePage extends ConsumerWidget {
  final Int64 chatId;

  const GroupProfilePage({super.key, required this.chatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final im = ref.watch(imProvider);
    final chat = im.getChat(chatId);
    if (chat == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('群资料')),
        body: const Center(child: Text('群聊不存在')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: GroupProfileContent(chatId: chatId),
    );
  }
}

/// 群资料/群设置内容区，移动端作为整页展示，桌面端嵌入右侧面板
class GroupProfileContent extends ConsumerWidget {
  final Int64 chatId;

  const GroupProfileContent({super.key, required this.chatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final bt = Theme.of(context).extension<BuzzingTheme>()!;
    final im = ref.watch(imProvider);
    final chat = im.getChat(chatId);
    if (chat == null) {
      return const Center(child: Text('群聊不存在'));
    }

    final isOwner = im.userId == chat.ownerId;
    final isAdmin = chat.adminIds.contains(im.userId);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _GroupInfoHeader(chat: chat, im: im),
        const SizedBox(height: 24),
        _SectionTitle(title: '群公告'),
        _AnnouncementTile(
            chat: chat,
            chatId: chatId,
            im: im,
            isOwner: isOwner,
            isAdmin: isAdmin),
        const SizedBox(height: 16),
        _GroupMembersSection(chatId: chatId),
        const SizedBox(height: 16),
        if (isOwner || isAdmin) ...[
          _SectionTitle(title: '群管理'),
          _GroupManageTile(chatId: chatId, cs: cs),
          const SizedBox(height: 16),
        ],
        _DangerZoneTile(chatId: chatId, isOwner: isOwner, im: im, cs: cs, bt: bt),
      ],
    );
  }
}

class _GroupInfoHeader extends ConsumerWidget {
  final Chat chat;
  final ImController im;

  const _GroupInfoHeader({required this.chat, required this.im});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isOwner = im.userId == chat.ownerId;
    final isAdmin = chat.adminIds.contains(im.userId);

    return Row(
      children: [
        GestureDetector(
          onTap: (isOwner || isAdmin) ? () => _openEdit(context) : null,
          child: Stack(
            children: [
              UserAvatar(
                  name: chat.name, avatar: chat.avatar, size: 36, radius: 18),
              if (isOwner || isAdmin)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt, size: 12, color: cs.onPrimary),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(chat.name,
                  style: tt.titleSmall, overflow: TextOverflow.ellipsis),
              if (chat.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(chat.description,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.ios_share, size: 18, color: cs.onSurfaceVariant),
          tooltip: '分享',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () => _share(context),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right, size: 20, color: cs.onSurfaceVariant),
          tooltip: '群信息',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () => _openEdit(context),
        ),
      ],
    );
  }

  void _openEdit(BuildContext context) {
    if (isDesktop) {
      im.openGroupEdit();
    } else {
      context.push('${AppRoute.GROUP_EDIT}/${chat.id}');
    }
  }

  void _share(BuildContext context) {
    if (isDesktop) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          title: const Text('分享'),
          content: SizedBox(
            width: 560,
            height: 480,
            child: GroupShareView(chatId: chat.id),
          ),
        ),
      );
    } else {
      context.push('${AppRoute.GROUP_SHARE}/${chat.id}');
    }
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
  final bool isOwner;
  final bool isAdmin;

  const _AnnouncementTile(
      {required this.chat,
      required this.chatId,
      required this.im,
      required this.isOwner,
      required this.isAdmin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final canEdit = isOwner || isAdmin;
    var announcement = im.entity.messages[chatId];
    if (announcement != null &&
        announcement.status == EntityStatus.DELETED.value) {
      announcement = null;
    }
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
        trailing: canEdit && announcement != null
            ? IconButton(
                icon: Icon(Icons.delete_outline, color: cs.error),
                onPressed: () async {
                  await im.deleteAnnouncement(chatId);
                },
              )
            : null,
        onTap: canEdit
            ? () => showAnnouncementEditor(context, im, chatId, announcement)
            : announcement != null
                ? () => showAnnouncementViewer(context, announcement!)
                : null,
      ),
    );
  }
}

class _GroupMembersSection extends ConsumerStatefulWidget {
  final Int64 chatId;

  const _GroupMembersSection({required this.chatId});

  @override
  _GroupMembersSectionState createState() => _GroupMembersSectionState();
}

class _GroupMembersSectionState extends ConsumerState<_GroupMembersSection> {
  final _searchCtrl = TextEditingController();
  List<MemberItem> _members = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    final im = ref.read(imProvider);
    setState(() => _loading = true);
    final resp = await im.getMembers(widget.chatId,
        page: 1, pageSize: 100, keyword: _searchCtrl.text.trim());
    if (mounted) {
      setState(() {
        _members = resp?.members ?? [];
        _loading = false;
      });
    }
  }

  void _addMembers() {
    final im = ref.read(imProvider);
    showDialog(
      context: context,
      builder: (ctx) => MemberPicker(
        im: im,
        options: MemberPickerOptions(
          excludeIds: <Int64>[..._members.map((m) => m.userId), im.userId],
          onConfirm: (selected) async {
            await im.addChatters(
                widget.chatId, selected.map((u) => u.id).toList());
            if (mounted) _loadMembers();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final im = ref.watch(imProvider);
    final chat = im.getChat(widget.chatId);
    final memberCount = chat?.memberIds.length ?? _members.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            if (isDesktop) {
              ref.read(imProvider).openGroupMemberList();
            } else {
              context.push('${AppRoute.MEMBER_LIST}/${widget.chatId}');
            }
          },
          child: Row(
            children: [
              Text('群成员',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('$memberCount人',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchCtrl,
          onChanged: (_) => _loadMembers(),
          decoration: InputDecoration(
            hintText: '搜索群成员',
            prefixIcon: const Icon(Icons.search),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) =>
                _buildAvatarRow(constraints.maxWidth),
          ),
      ],
    );
  }

  Widget _buildAvatarRow(double maxWidth) {
    const avatarSize = 36.0;
    const spacing = 8.0;
    final slotWidth = avatarSize + spacing;
    final maxSlots =
        maxWidth > 0 ? ((maxWidth + spacing) / slotWidth).floor() : 0;
    final memberSlots = math.max(0, maxSlots - 1); // 预留一个槽位给「+」按钮
    final shown = _members.take(memberSlots).toList();

    return Row(
      children: [
        for (final m in shown)
          Padding(
            padding: const EdgeInsets.only(right: spacing),
            child: UserAvatar(name: m.name, avatar: m.avatar, size: 36, radius: 18),
          ),
        _AddMemberButton(onTap: _addMembers),
      ],
    );
  }
}

class _AddMemberButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddMemberButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          shape: BoxShape.circle,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Icon(Icons.add, size: 20, color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _GroupManageTile extends ConsumerWidget {
  final Int64 chatId;
  final ColorScheme cs;

  const _GroupManageTile({required this.chatId, required this.cs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.admin_panel_settings, color: cs.primary),
        title: const Text('群管理'),
        subtitle: const Text('禁言、入群方式、管理员设置'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (isDesktop) {
            ref.read(imProvider).openGroupManage();
          } else {
            context.push('${AppRoute.GROUP_MANAGE}/$chatId');
          }
        },
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
