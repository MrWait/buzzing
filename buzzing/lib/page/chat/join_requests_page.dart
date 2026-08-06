import 'package:buzzing/models/idl/join_request.pb.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/widget/profile.dart';
import 'package:buzzing/widget/user_list_item.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 入群申请页（移动端整页展示）
class JoinRequestsPage extends StatelessWidget {
  final Int64 chatId;

  const JoinRequestsPage({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('入群申请')),
      body: JoinRequestsView(chatId: chatId),
    );
  }
}

/// 入群申请内容区：移动端作为整页，桌面端嵌入群资料面板作为二级页面。
class JoinRequestsView extends ConsumerStatefulWidget {
  final Int64 chatId;

  const JoinRequestsView({super.key, required this.chatId});

  @override
  JoinRequestsViewState createState() => JoinRequestsViewState();
}

class JoinRequestsViewState extends ConsumerState<JoinRequestsView> {
  List<JoinRequest> _requests = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final im = ref.read(imProvider);
    final resp = await im.listJoinRequests(widget.chatId, status: 0);
    if (mounted) {
      setState(() {
        _requests = resp?.requests ?? [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_requests.isEmpty) {
      return Center(
        child: Text('暂无待处理的申请',
            style: TextStyle(color: cs.onSurfaceVariant)),
      );
    }
    return ListView.separated(
      itemCount: _requests.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final req = _requests[i];
        final im = ref.read(imProvider);
        return ListTile(
          leading: AvatarUserPopup(
            im: im,
            id: req.userId,
            url: '',
            ver: im.getUserVer(req.userId),
            child: UserAvatar(
                name: req.userName.isEmpty ? '${req.userId}' : req.userName,
                avatar: '',
                size: 32),
          ),
          title: Text(req.userName.isNotEmpty ? req.userName : '用户 ${req.userId}'),
          subtitle: req.userName.isNotEmpty
              ? Text(req.userName)
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  ref.read(imProvider).approveJoinRequest(req.id);
                  setState(() => _requests.removeAt(i));
                },
                child: const Text('通过'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(imProvider).rejectJoinRequest(req.id);
                  setState(() => _requests.removeAt(i));
                },
                child: Text('拒绝',
                    style: TextStyle(color: cs.error)),
              ),
            ],
          ),
        );
      },
    );
  }
}
