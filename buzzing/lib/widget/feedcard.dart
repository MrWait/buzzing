import 'dart:math' as math;

import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';

class ConversationItem extends StatelessWidget {
  final FeedModel model;
  final bool selected;
  final ImController im;
  final VoidCallback onTap;
  final void Function(TapDownDetails)? onSecondaryTapDown;
  final void Function(LongPressStartDetails)? onLongPressStart;

  const ConversationItem({
    required this.model,
    required this.selected,
    required this.im,
    required this.onTap,
    this.onSecondaryTapDown,
    this.onLongPressStart,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final chat = model.chat;
    final message = model.message;
    final name = im.chatDisplayName(chat, fallback: '[${model.feed.id}]');
    // 消息预览：群聊展示「发送人: 摘要」；单聊展示摘要，自己发送时左侧带已读标记
    final isGroup = chat?.chatType == 2;
    final isSelf = !isGroup && message != null && message.fromId == im.userId;
    // 单聊用对方（peer）用户头像；群聊用群头像
    final avatarUrl = (chat == null)
        ? ''
        : (isGroup ? chat.avatar : (im.getUser(im.peerIdOf(chat))?.avatar ?? ''));
    var avatar = _buildAvatar(cs, tt, name, avatarUrl);
    final summary = message?.summary ?? '';
    final time = model.feed.rankTimeMs;
    final badge = model.feed.badge;
    var preview = summary;
    if (isGroup && message != null && message.fromId > Int64(0)) {
      final senderName = im.getUser(message.fromId)?.name ?? '';
      if (senderName.isNotEmpty) preview = '$senderName: $summary';
    }

    return GestureDetector(
      onTap: onTap,
      onSecondaryTapDown: onSecondaryTapDown,
      onLongPressStart: onLongPressStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: selected ? cs.secondaryContainer : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            avatar,
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
                      // 单聊自己发送的消息，左侧展示已读标记。
                      // 样式/计数与会话面板该消息右侧的已读圈一致（绿圈按已读比例填充、满格✓），只读不响应点击。
                      if (isSelf) ...[
                        _ReadStateIndicator(
                          readState: im.entity.readstates[message.id] ?? ReadState.create(),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          preview,
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

  Widget _buildAvatar(ColorScheme cs, TextTheme tt, String name, String avatarUrl) {
    final url = CommonUtils.fixResourceUrl(avatarUrl);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: cs.primary,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: url.isNotEmpty
          ? Image(
              image: CachedNetworkImageProvider(url),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildAvatarText(cs, tt, name),
            )
          : _buildAvatarText(cs, tt, name),
    );
  }

  Widget _buildAvatarText(ColorScheme cs, TextTheme tt, String name) {
    return Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: tt.bodyMedium?.copyWith(color: cs.onPrimary),
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

/// 会话列表单聊自家消息预览左侧的已读标记（只读）。
/// 样式与已读计数与会话消息面板该消息右侧的已读圈一致（绿圈按已读比例填充、满格 ✓），但不可点击。
/// 消息尚无已读数据（如发送确认中，total=0）时渲染为空，避免展示误导性的空环。
class _ReadStateIndicator extends StatelessWidget {
  final ReadState readState;

  const _ReadStateIndicator({required this.readState});

  /// 与 message.dart `_readPercent` 一致：0 起步、10% 一档、上限 100。
  int get _percent {
    final total = readState.total;
    if (total <= 0) return 0;
    final pct = (readState.readCount / total * 100).round();
    if (pct >= 100) return 100;
    return ((pct / 10).floor() * 10).clamp(10, 90);
  }

  @override
  Widget build(BuildContext context) {
    if (readState.total <= 0) return const SizedBox.shrink();
    final pct = _percent;
    const green = Color(0xFF4ADE80);
    return SizedBox(
      width: 14,
      height: 14,
      child: CustomPaint(
        painter: _ReadCirclePainter(percent: pct, color: green),
        child: pct >= 100
            ? Center(
                child: Text(
                  '✓',
                  style: TextStyle(color: green, fontSize: 9, fontWeight: FontWeight.w700),
                ),
              )
            : null,
      ),
    );
  }
}

class _ReadCirclePainter extends CustomPainter {
  final int percent;
  final Color color;

  _ReadCirclePainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(rect, bgPaint);

    if (percent > 0) {
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -math.pi / 2, (percent / 100) * 2 * math.pi, false, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ReadCirclePainter old) =>
      old.percent != percent || old.color != color;
}
