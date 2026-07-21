import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/chat.pb.dart';
import 'package:buzzing/models/idl/user.pb.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/res/theme.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemberListPage extends ConsumerStatefulWidget {
  final Int64 chatId;

  const MemberListPage({super.key, required this.chatId});

  @override
  _MemberListPageState createState() => _MemberListPageState();
}

class _MemberListPageState extends ConsumerState<MemberListPage> {
  List<MemberItem> _members = [];
  bool _loading = false;
  int _page = 1;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMembers();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('成员列表'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: '搜索成员',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (_) {
                _page = 1;
                _loadMembers(refresh: true);
              },
            ),
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: _members.length,
        separatorBuilder: (_, __) => Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final item = _members[index];
          final isItemOwner = item.userId == chat?.ownerId;
          final isItemAdmin = chat?.adminIds.contains(item.userId) ?? false;
          final isSelf = item.userId == im.userId;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: cs.primaryContainer,
              child: Text(
                item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                style: TextStyle(color: cs.onPrimaryContainer),
              ),
            ),
            title: Text(item.name),
            subtitle: Text(
              isItemOwner ? '群主' : (isItemAdmin ? '管理员' : '成员'),
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
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
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: Text('移出', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
