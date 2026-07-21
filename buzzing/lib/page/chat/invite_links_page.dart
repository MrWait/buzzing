import 'package:buzzing/controller/im.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InviteLinksPage extends ConsumerStatefulWidget {
  final Int64 chatId;

  const InviteLinksPage({super.key, required this.chatId});

  @override
  _InviteLinksPageState createState() => _InviteLinksPageState();
}

class _InviteLinksPageState extends ConsumerState<InviteLinksPage> {
  String? _currentCode;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('邀请链接')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_currentCode != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('当前邀请链接',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      SelectableText(
                        '邀请码: $_currentCode',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
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
                    ],
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
        ),
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
