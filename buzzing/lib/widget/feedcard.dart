import 'package:buzzing/controller/im.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';

class ConversationItem extends StatelessWidget {
  final FeedModel model;
  final bool selected;
  final VoidCallback onTap;

  const ConversationItem({
    required this.model,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final chat = model.chat;
    final message = model.message;
    final name = chat?.name ?? '[${model.feed.id}]';
    final summary = message?.summary ?? '';
    final time = model.feed.rankTimeMs;
    final badge = model.feed.badge;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: selected ? cs.secondaryContainer : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(cs, tt, name),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: tt.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(time),
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          summary,
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badge > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge > 99 ? '99+' : '$badge',
                            style: tt.labelSmall?.copyWith(color: cs.onError),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ColorScheme cs, TextTheme tt, String name) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: tt.bodyMedium?.copyWith(color: cs.onPrimary),
      ),
    );
  }

  String _formatTime(Int64 ms) {
    var dt = DateTime.fromMillisecondsSinceEpoch(ms.toInt());
    var now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.month}/${dt.day}';
  }
}
