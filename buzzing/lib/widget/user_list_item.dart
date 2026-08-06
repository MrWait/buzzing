import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/controller/im.dart';
import 'package:buzzing/widget/profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';

/// 用户头像：优先展示真实头像，头像为空或加载失败时 fallback 到首字母。
/// 形状统一为圆形（见 docs/flutter/client_style.md 头像形状规范）。
class UserAvatar extends StatefulWidget {
  final String name;
  final String avatar;
  final double size;

  const UserAvatar({
    super.key,
    required this.name,
    required this.avatar,
    this.size = 32,
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
        shape: BoxShape.circle,
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

  /// 整行点击回调：传出**头像的全局矩形**，用于以头像为锚点弹出资料浮层
  /// （头像右侧对齐）。与 [onTapUp] 二选一（优先于 [onTap]）。
  final void Function(Rect avatarRect)? onAvatarTapUp;

  /// 包含点击点位置的回调：与 [onTap] 二选一（onTapUp 优先）。
  /// 用于需要在点击位置弹出用户资料浮层的场景。
  final void Function(TapUpDetails details)? onTapUp;
  final double avatarSize;

  /// 传入后，点击头像就地在头像位置弹出对应用户的资料浮层；
  /// 不传则头像不弹浮层（如选中态的选择器场景）。
  final ImController? im;
  final Int64? userId;

  const UserListItem({
    super.key,
    required this.name,
    required this.avatar,
    this.tags = const [],
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onAvatarTapUp,
    this.onTapUp,
    this.avatarSize = 32,
    this.im,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final avatarKey = GlobalKey();
    Widget avatarW = UserAvatar(
      key: avatarKey,
      name: name,
      avatar: avatar,
      size: avatarSize,
    );
    // 点击头像弹资料浮层：优先于行的 onTap
    if (im != null && userId != null) {
      avatarW = AvatarUserPopup(
        im: im!,
        id: userId!,
        url: avatar,
        ver: im!.getUserVer(userId!),
        child: avatarW,
      );
    }
    return GestureDetector(
      onTapUp: onAvatarTapUp != null
          ? (details) {
              final box =
                  avatarKey.currentContext?.findRenderObject() as RenderBox?;
              if (box == null) return;
              onAvatarTapUp!(box.localToGlobal(Offset.zero) & box.size);
            }
          : onTapUp ?? ((details) => onTap?.call()),
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            avatarW,
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
