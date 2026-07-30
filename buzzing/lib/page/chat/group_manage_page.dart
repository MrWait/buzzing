import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/chat.pb.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/routes/app_routes.dart';
import 'package:buzzing/widget/member_picker/member_picker.dart';
import 'package:buzzing/widget/user_list_item.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 群管理页（移动端整页展示）
class GroupManagePage extends StatelessWidget {
  final Int64 chatId;

  const GroupManagePage({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('群管理')),
      body: GroupManageView(chatId: chatId),
    );
  }
}

/// 群管理内容区：移动端作为整页，桌面端嵌入群资料面板作为二级页面。
/// 管理员/群主在此调整群权限设置：全员禁言、入群方式、入群申请、管理员设置。
class GroupManageView extends ConsumerStatefulWidget {
  final Int64 chatId;

  const GroupManageView({super.key, required this.chatId});

  @override
  GroupManageViewState createState() => GroupManageViewState();
}

class GroupManageViewState extends ConsumerState<GroupManageView> {
  List<MemberItem> _admins = [];
  bool _loadingAdmins = false;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  /// 拉取当前管理员列表（过滤 getMembers 结果中的 adminIds）
  Future<void> _loadAdmins() async {
    final im = ref.read(imProvider);
    final chat = im.getChat(widget.chatId);
    if (chat == null || chat.adminIds.isEmpty) {
      if (mounted) setState(() => _admins = []);
      return;
    }
    setState(() => _loadingAdmins = true);
    final resp = await im.getMembers(widget.chatId, page: 1, pageSize: 200);
    if (mounted) {
      setState(() {
        _admins = (resp?.members ?? <MemberItem>[])
            .where((m) => chat.adminIds.contains(m.userId))
            .toList();
        _loadingAdmins = false;
      });
    }
  }

  void _addAdmin() {
    final im = ref.read(imProvider);
    final excludeIds = <Int64>[..._admins.map((m) => m.userId), im.userId];
    showDialog(
      context: context,
      builder: (ctx) => MemberPicker(
        im: im,
        options: MemberPickerOptions(
          excludeIds: excludeIds,
          onConfirm: (selected) async {
            await im.updateChat(widget.chatId,
                adminIdsAdd: selected.map((u) => u.id).toList());
            if (mounted) _loadAdmins();
          },
        ),
      ),
    );
  }

  void _removeAdmin(MemberItem admin) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('移除管理员'),
        content: Text('确定要将「${admin.name}」移出管理员吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(imProvider)
                  .updateChat(widget.chatId, adminIdsRemove: [admin.userId]);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) _loadAdmins();
            },
            child: const Text('移除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final im = ref.watch(imProvider);
    final chat = im.getChat(widget.chatId);
    if (chat == null) {
      return const Center(child: Text('群聊不存在'));
    }
    final isOwner = im.userId == chat.ownerId;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle(title: '群权限'),
        Card(
          child: Column(
            children: [
              _GlobalMuteTile(chat: chat, im: im),
              const Divider(height: 1),
              _JoinModeTile(chat: chat, im: im),
              const Divider(height: 1),
              _JoinRequestsTile(chatId: widget.chatId, cs: cs),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _SectionTitle(title: '管理员设置'),
        Card(child: _buildAdminSection(cs, isOwner)),
      ],
    );
  }

  Widget _buildAdminSection(ColorScheme cs, bool isOwner) {
    if (_loadingAdmins) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_admins.isEmpty) {
      return ListTile(
        leading: Icon(Icons.admin_panel_settings, color: cs.primary),
        title: const Text('暂无管理员'),
        subtitle: const Text('群主可添加管理员协助管理群聊'),
        trailing: isOwner
            ? IconButton(
                icon: Icon(Icons.add, color: cs.onSurfaceVariant),
                onPressed: _addAdmin,
              )
            : null,
      );
    }
    return Column(
      children: [
        for (final admin in _admins)
          ListTile(
            dense: true,
            leading:
                UserAvatar(name: admin.name, avatar: admin.avatar, size: 32),
            title: Text(admin.name),
            trailing: isOwner
                ? IconButton(
                    icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                    onPressed: () => _removeAdmin(admin),
                  )
                : null,
          ),
        if (isOwner)
          ListTile(
            leading: Icon(Icons.add, color: cs.primary),
            title: const Text('添加管理员'),
            onTap: _addAdmin,
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
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

/// 全员禁言开关
class _GlobalMuteTile extends ConsumerStatefulWidget {
  final Chat chat;
  final ImController im;

  const _GlobalMuteTile({required this.chat, required this.im});

  @override
  _GlobalMuteTileState createState() => _GlobalMuteTileState();
}

class _GlobalMuteTileState extends ConsumerState<_GlobalMuteTile> {
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
    return SwitchListTile(
      secondary: Icon(Icons.volume_off, color: cs.error),
      title: const Text('全员禁言'),
      subtitle: Text(_globalMuted ? '已开启' : '已关闭'),
      value: _globalMuted,
      onChanged: (val) async {
        final untilMs = val
            ? Int64(DateTime.now().millisecondsSinceEpoch + 86400000 * 365)
            : Int64.ZERO;
        await widget.im.globalMute(widget.chat.id, untilMs);
        setState(() => _globalMuted = val);
      },
    );
  }
}

/// 入群方式（允许任何人 / 需要审核 / 禁止加入）
class _JoinModeTile extends ConsumerStatefulWidget {
  final Chat chat;
  final ImController im;

  const _JoinModeTile({required this.chat, required this.im});

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
    return ListTile(
      leading: Icon(Icons.verified_user, color: cs.primary),
      title: const Text('入群方式'),
      subtitle: Text(labels[_joinMode.clamp(0, 2)]),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showJoinModePicker(context),
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
              await widget.im.updateChat(widget.chat.id, joinMode: 0);
              setState(() => _joinMode = 0);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('允许任何人'),
          ),
          SimpleDialogOption(
            onPressed: () async {
              await widget.im.updateChat(widget.chat.id, joinMode: 1);
              setState(() => _joinMode = 1);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('需要审核'),
          ),
          SimpleDialogOption(
            onPressed: () async {
              await widget.im.updateChat(widget.chat.id, joinMode: 2);
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

/// 入群申请入口（跳转申请列表页）
class _JoinRequestsTile extends StatelessWidget {
  final Int64 chatId;
  final ColorScheme cs;

  const _JoinRequestsTile({required this.chatId, required this.cs});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.pending_actions, color: cs.primary),
      title: const Text('入群申请'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('${AppRoute.JOIN_REQUESTS}/$chatId'),
    );
  }
}
