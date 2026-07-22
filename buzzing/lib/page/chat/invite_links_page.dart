import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/entity.pbenum.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InviteLinksPage extends ConsumerStatefulWidget {
  final Int64 chatId;

  const InviteLinksPage({super.key, required this.chatId});

  @override
  _InviteLinksPageState createState() => _InviteLinksPageState();
}

class _InviteLinksPageState extends ConsumerState<InviteLinksPage> {
  String? _currentCode;
  final _codeCtrl = TextEditingController();
  bool _joining = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _joinByCode() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;

    setState(() => _joining = true);
    try {
      final im = ref.read(imProvider);
      final resp = await im.joinByInviteLink(code);
      if (resp != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已加入群聊: ${resp.chat?.name ?? ''}')),
          );
          _codeCtrl.clear();
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('邀请码无效或已过期')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加入失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<void> _applyToJoin() async {
    final im = ref.read(imProvider);
    await im.createJoinRequest(widget.chatId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已提交入群申请，请等待管理员审核')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final im = ref.watch(imProvider);
    final chat = im.getChat(widget.chatId);
    final isOwner = im.userId == chat?.ownerId;
    final isAdmin = chat?.adminIds.contains(im.userId) ?? false;
    final isMember = chat?.memberIds.contains(im.userId) ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('邀请')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 通过邀请码加入
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('使用邀请码加入群聊',
                      style: tt.titleSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codeCtrl,
                          decoration: const InputDecoration(
                            hintText: '输入邀请码',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _joining ? null : _joinByCode,
                        child: _joining
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('加入'),
                      ),
                    ],
                  ),
                  // 申请加入
                  if (!isMember && chat?.chatType == 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: OutlinedButton.icon(
                        onPressed: _applyToJoin,
                        icon: const Icon(Icons.person_add),
                        label: const Text('申请加入该群聊'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 管理员区域的邀请链接管理
          if (isOwner || isAdmin) ...[
            if (_currentCode != null) ...[
              // 二维码
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('扫一扫加入群聊',
                          style: tt.titleSmall),
                      const SizedBox(height: 12),
                      QrImageView(
                        data: _currentCode!,
                        version: QrVersions.auto,
                        size: 180,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: cs.primary,
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        '邀请码: $_currentCode',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 撤销链接
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(imProvider).revokeInviteLink(_currentCode!);
                    setState(() => _currentCode = null);
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('撤销链接'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.error,
                    side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              onPressed: _createLink,
              icon: const Icon(Icons.add),
              label: const Text('生成新邀请链接'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _createLink() async {
    final im = ref.read(imProvider);
    final code = await im.createInviteLink(widget.chatId);
    if (code != null) {
      setState(() => _currentCode = code);
    }
  }
}
