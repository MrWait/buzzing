import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShareToChatDialog extends ConsumerStatefulWidget {
  final String roomId;
  final String title;
  final String hostName;

  const ShareToChatDialog({
    super.key,
    required this.roomId,
    required this.title,
    required this.hostName,
  });

  @override
  ConsumerState<ShareToChatDialog> createState() => _ShareToChatDialogState();

  static Future<void> show(BuildContext context, {
    required String roomId,
    required String title,
    required String hostName,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => ShareToChatDialog(
        roomId: roomId,
        title: title,
        hostName: hostName,
      ),
    );
  }
}

class _ShareToChatDialogState extends ConsumerState<ShareToChatDialog> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final im = ref.read(imProvider);
    final homeCtl = ref.read(meetingHomeLogicProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    var chats = im.entity.chats.values.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
    chats.sort((a, b) => b.updateAtMs.compareTo(a.updateAtMs));

    return AlertDialog(
      title: const Text('分享到聊天'),
      content: SizedBox(
        width: 360,
        height: 400,
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: '搜索聊天',
                prefixIcon: const Icon(Icons.search, size: 18),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: chats.isEmpty
                  ? Center(
                      child: Text('暂无聊天', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                    )
                  : ListView.separated(
                      itemCount: chats.length,
                      separatorBuilder: (_, _2) => Divider(height: 1, color: cs.outlineVariant),
                      itemBuilder: (context, i) {
                        final chat = chats[i];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: cs.primaryContainer,
                            child: Text(
                              chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?',
                              style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer),
                            ),
                          ),
                          title: Text(chat.name, style: tt.bodyMedium),
                          subtitle: Text(
                            chat.chatType == 1 ? '群聊' : '单聊',
                            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                          onTap: () async {
                            await homeCtl.shareMeetingToChat(
                              im: im,
                              chatId: chat.id,
                              roomId: widget.roomId,
                              title: widget.title,
                              hostName: widget.hostName,
                            );
                            if (context.mounted) Navigator.of(context).pop();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('已分享到 ${chat.name}')),
                              );
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.cancel),
        ),
      ],
    );
  }
}