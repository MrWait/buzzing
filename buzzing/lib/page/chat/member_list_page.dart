import 'package:buzzing/models/idl/chat.pb.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/widget/member_picker/member_picker.dart';
import 'package:buzzing/widget/user_list_item.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 群成员列表页（移动端整页展示）
class MemberListPage extends StatelessWidget {
  final Int64 chatId;

  const MemberListPage({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('群成员')),
      body: MemberListView(chatId: chatId),
    );
  }
}

/// 群成员列表内容区：移动端作为整页，桌面端嵌入群资料面板作为二级页面
class MemberListView extends ConsumerStatefulWidget {
  final Int64 chatId;

  const MemberListView({super.key, required this.chatId});

  @override
  MemberListViewState createState() => MemberListViewState();
}

class MemberListViewState extends ConsumerState<MemberListView> {
  List<MemberItem> _members = [];
  bool _loading = false;
  int _page = 1;
  final _searchCtrl = TextEditingController();

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

  Future<void> _loadMembers({bool refresh = false}) async {
    if (_loading) return;
    setState(() => _loading = true);
    final im = ref.read(imProvider);
    final resp = await im.getMembers(widget.chatId,
        page: refresh ? 1 : _page, pageSize: 50, keyword: _searchCtrl.text);
    if (resp != null) {
      setState(() {
        if (refresh || _page == 1) {
          _members = resp.members;
        } else {
          _members.addAll(resp.members);
        }
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final im = ref.watch(imProvider);
    final chat = im.getChat(widget.chatId);
    final isOwner = im.userId == chat?.ownerId;
    final isAdmin = chat?.adminIds.contains(im.userId) ?? false;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: '搜索成员',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                  onChanged: (_) {
                    _page = 1;
                    _loadMembers(refresh: true);
                  },
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.person_add_alt),
                tooltip: '添加成员',
                onPressed: _showAddMemberDialog,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _members.length,
            separatorBuilder: (_, _) => Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final item = _members[index];
              final isItemOwner = item.userId == chat?.ownerId;
              final isItemAdmin = chat?.adminIds.contains(item.userId) ?? false;
              final isSelf = item.userId == im.userId;

              final tags = <Widget>[
                if (isItemOwner)
                  const UserTag(text: '群主', color: Color(0xFFE53935)),
                if (isItemAdmin)
                  UserTag(text: '管理员', color: cs.primary),
              ];

              return UserListItem(
                name: item.name,
                avatar: item.avatar,
                tags: tags,
                trailing: (isOwner || isAdmin) && !isSelf
                    ? PopupMenuButton<String>(
                        onSelected: (val) => _handleMemberAction(val, item.userId),
                        itemBuilder: (_) => [
                          if (isOwner && !isItemAdmin && !isItemOwner)
                            const PopupMenuItem(value: 'set_admin', child: Text('设为管理员')),
                          if (isOwner && isItemAdmin)
                            const PopupMenuItem(value: 'remove_admin', child: Text('移除管理员')),
                          if (isOwner && !isItemOwner)
                            const PopupMenuItem(value: 'transfer_owner', child: Text('转让群主')),
                          if ((isOwner || isAdmin) && !isItemOwner)
                            const PopupMenuItem(value: 'mute', child: Text('禁言')),
                          if ((isOwner || isAdmin) && !isItemOwner)
                            const PopupMenuItem(value: 'kick', child: Text('移出群聊')),
                        ],
                      )
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleMemberAction(String action, Int64 targetUserId) {
    final im = ref.read(imProvider);
    switch (action) {
      case 'set_admin':
        im.updateChat(widget.chatId, adminIdsAdd: [targetUserId]);
        break;
      case 'remove_admin':
        im.updateChat(widget.chatId, adminIdsRemove: [targetUserId]);
        break;
      case 'transfer_owner':
        _confirmTransferOwner(targetUserId);
        break;
      case 'mute':
        _showMuteDurationPicker(targetUserId);
        break;
      case 'kick':
        _confirmKick(targetUserId);
        break;
    }
  }

  void _confirmTransferOwner(Int64 targetUserId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('转让群主'),
        content: const Text('确定要将群主转让给该成员吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              ref.read(imProvider).updateChat(widget.chatId, ownerId: targetUserId);
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showMuteDurationPicker(Int64 targetUserId) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('选择禁言时长'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              ref.read(imProvider).muteMember(widget.chatId, targetUserId,
                  Int64(DateTime.now().millisecondsSinceEpoch + 3600000));
              Navigator.pop(ctx);
            },
            child: const Text('1小时'),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(imProvider).muteMember(widget.chatId, targetUserId,
                  Int64(DateTime.now().millisecondsSinceEpoch + 86400000));
              Navigator.pop(ctx);
            },
            child: const Text('24小时'),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(imProvider).muteMember(widget.chatId, targetUserId,
                  Int64(DateTime.now().millisecondsSinceEpoch + 604800000));
              Navigator.pop(ctx);
            },
            child: const Text('7天'),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(imProvider).muteMember(widget.chatId, targetUserId,
                  Int64(DateTime.now().millisecondsSinceEpoch + 2592000000));
              Navigator.pop(ctx);
            },
            child: const Text('30天'),
          ),
        ],
      ),
    );
  }

  void _confirmKick(Int64 targetUserId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('移出群聊'),
        content: const Text('确定要将该成员移出群聊吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              await ref
                  .read(imProvider)
                  .removeChatters(widget.chatId, [targetUserId]);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) _loadMembers(refresh: true);
            },
            child: Text('移出', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog() {
    final im = ref.read(imProvider);
    final excludeIds = <Int64>[
      ..._members.map((m) => m.userId),
      im.userId,
    ];
    showDialog(
      context: context,
      builder: (ctx) => MemberPicker(
        im: im,
        options: MemberPickerOptions(
          excludeIds: excludeIds,
          onConfirm: (selected) async {
            await im.addChatters(
                widget.chatId, selected.map((u) => u.id).toList());
            if (mounted) _loadMembers(refresh: true);
          },
        ),
      ),
    );
  }
}
