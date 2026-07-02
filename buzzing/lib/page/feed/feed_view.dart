import 'package:buzzing/controller/im.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/widget/feedcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final im = ref.watch(imProvider);

    return Container(
      width: 300,
      color: cs.surfaceVariant,
      child: ListenableBuilder(
        listenable: im,
        builder: (ctx, _) {
          if (im.feedList.isEmpty) {
            return Center(
              child: Text(
                '暂无对话',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            );
          }
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              for (var m in im.feedList)
                ConversationItem(
                  model: m,
                  selected: m.feed.id == im.chatId,
                  onTap: () => im.enterChat(m.feed.id),
                ),
            ],
          );
        },
      ),
    );
  }
}
