import 'package:buzzing/controller/im.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/utils/platform.dart';
import 'package:buzzing/widget/feedcard.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  void _showContextMenu(BuildContext context, WidgetRef ref, FeedModel m, Offset pos) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx + 1, pos.dy + 1),
      items: [
        const PopupMenuItem(value: 'pin', child: Text('置顶')),
        const PopupMenuItem(value: 'mute', child: Text('免打扰')),
        const PopupMenuItem(value: 'done', child: Text('完成')),
      ],
    ).then((value) {
      if (value == null) return;
      final im = ref.read(imProvider);
      switch (value) {
        case 'pin':
          im.topFeed(m.feed.id);
        case 'mute':
          break;
        case 'done':
          im.markFeedRead(m.feed.id);
      }
    });
  }

  void _onTapFeed(BuildContext context, WidgetRef ref, Int64 feedId) {
    if (isMobile) {
      context.push('/im/chat/${feedId}');
    } else {
      ref.read(imProvider).enterChat(feedId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final im = ref.watch(imProvider);

    return Container(
      width: isDesktop ? 300 : null,
      color: cs.surfaceVariant,
      child: Column(
        children: [
          if (isDesktop)
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Text(
                t.message,
                style: tt.titleMedium,
              ),
            ),
          if (isDesktop)
            Divider(height: 1, color: cs.outlineVariant),
          Expanded(
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
                      _buildItem(context, ref, im, m, cs, tt),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, WidgetRef ref, ImController im, FeedModel m, ColorScheme cs, TextTheme tt) {
    final item = ConversationItem(
      model: m,
      selected: isDesktop && m.feed.id == im.chatId,
      onTap: () => _onTapFeed(context, ref, m.feed.id),
      onSecondaryTapDown: isDesktop
          ? (details) => _showContextMenu(context, ref, m, details.globalPosition)
          : null,
      onLongPressStart: isMobile
          ? (details) => _showContextMenu(context, ref, m, details.globalPosition)
          : null,
    );

    if (isMobile) {
      return Dismissible(
        key: ValueKey(m.feed.id),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            im.topFeed(m.feed.id);
          } else {
            im.markFeedRead(m.feed.id);
          }
          return false;
        },
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 24),
          color: cs.primary,
          child: const Text('完成', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          color: cs.tertiary,
          child: const Text('置顶', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ),
        child: item,
      );
    }

    return item;
  }
}
