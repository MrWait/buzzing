import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/join_request.pb.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JoinRequestsPage extends ConsumerStatefulWidget {
  final Int64 chatId;

  const JoinRequestsPage({super.key, required this.chatId});

  @override
  _JoinRequestsPageState createState() => _JoinRequestsPageState();
}

class _JoinRequestsPageState extends ConsumerState<JoinRequestsPage> {
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
    if (resp != null) {
      setState(() {
        _requests = resp.requests;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('入群申请')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(
                  child: Text('暂无待处理的申请',
                      style: TextStyle(color: cs.onSurfaceVariant)))
              : ListView.separated(
                  itemCount: _requests.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final req = _requests[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cs.primaryContainer,
                        child: Text('${req.userId}',
                            style: TextStyle(color: cs.onPrimaryContainer)),
                      ),
                      title: Text('用户 ${req.userId}'),
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
                ),
    );
  }
}
