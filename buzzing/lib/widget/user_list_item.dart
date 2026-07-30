import 'package:buzzing/utils/common_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// 用户头像：优先展示真实头像，头像为空或加载失败时 fallback 到首字母
class UserAvatar extends StatefulWidget {
  final String name;
  final String avatar;
  final double size;
  final double radius;

  const UserAvatar({
    super.key,
    required this.name,
    required this.avatar,
    this.size = 32,
    this.radius = 4,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  bool _failed = false;

  @override
  void didUpdateWidget(UserAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatar != widget.avatar) _failed = false;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final url = CommonUtils.fixResourceUrl(widget.avatar);
    final showImage = url.isNotEmpty && !_failed;
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: showImage
          ? Image(
              image: CachedNetworkImageProvider(url),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                if (!_failed) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _failed = true);
                  });
                }
                return _buildFallback(tt, cs);
              },
            )
          : _buildFallback(tt, cs),
    );
  }

  Widget _buildFallback(TextTheme tt, ColorScheme cs) {
    return Center(
      child: Text(
        widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
        style: tt.bodySmall?.copyWith(color: cs.onPrimary),
      ),
    );
  }
}

/// 场景标签（如 群主 / 管理员），由各场景自定义注入
class UserTag extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? backgroundColor;

  const UserTag({
    super.key,
    required this.text,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = color ?? cs.primary;
    final bgColor = backgroundColor ?? textColor.withValues(alpha: 0.12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 通用用户条目：联系人、群成员等场景复用，支持注入自定义 tag
class UserListItem extends StatelessWidget {
  final String name;
  final String avatar;
  final List<Widget> tags;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double avatarSize;

  const UserListItem({
    super.key,
    required this.name,
    required this.avatar,
    this.tags = const [],
    this.subtitle,
    this.trailing,
    this.onTap,
    this.avatarSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            UserAvatar(name: name, avatar: avatar, size: avatarSize),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: tt.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      for (final tag in tags) ...[
                        const SizedBox(width: 6),
                        tag,
                      ],
                    ],
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
