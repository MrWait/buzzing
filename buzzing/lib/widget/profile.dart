import 'dart:math' as math;

import 'package:buzzing/controller/im.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/utils/platform.dart';
import 'package:buzzing/widget/user_list_item.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:fixnum/fixnum.dart';
import 'package:go_router/go_router.dart';

/// 用户资料浮层内容（飞书风格：大头像 + 信息卡片 + 操作按钮 + 详情字段）。
///
/// 复用点：
/// 1. [AvatarUserPopup]：包在某个头像外层，点击头像就在点击位置弹浮层；
/// 2. [showUserMenu]：@提及、通讯录整行 等场景，在点击位置弹浮层。
///
/// 浮层位置跟随点击点，并按实际内容高度自适应，避免溢出屏幕（见 [_FollowPointerMenu]）。
/// [onClose] 由宿主（Overlay）注入，用于关闭浮层。
Widget UserMenu(
  BuildContext context, {
  required ImController im,
  required Int64 id,
  required String url,
  required Int64 ver,
  required VoidCallback onClose,
}) {
  final cs = Theme.of(context).colorScheme;
  final tt = Theme.of(context).textTheme;
  final user = im.getUser(id);
  L.d("[profile] show user menu, id: ${id}, user: ${user?.name}");

  return Material(
    color: Colors.transparent,
    child: Container(
      width: 320,
      constraints: BoxConstraints(
        minHeight: math.min(
          440,
          MediaQuery.of(context).size.height * 0.7,
        ),
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UserAvatar(
                    name: user?.name ?? '',
                    avatar: url,
                    size: 80,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? '',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  if (user != null && user.position.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.position,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _ActionButtons(im: im, user: user, onClose: onClose),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _InfoFields(im: im, user: user),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// 操作按钮行：消息、语音、视频
class _ActionButtons extends StatelessWidget {
  final ImController im;
  final dynamic user;
  final VoidCallback onClose;

  const _ActionButtons({
    required this.im,
    required this.user,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          label: t.sendMessage,
          onTap: () async {
            if (user == null) {
              onClose();
              return;
            }
            var chatId = await im.createP2PChat(user.id);
            if (chatId != null && context.mounted) {
              im.enterChat(chatId);
              if (isMobile) {
                context.push('/im/chat/$chatId');
              } else {
                context.go('/im');
              }
            }
            onClose();
          },
        ),
        const SizedBox(width: 12),
        _ActionButton(
          icon: Icons.phone_outlined,
          label: t.voiceCall,
          onTap: () {},
          enabled: false,
        ),
        const SizedBox(width: 12),
        _ActionButton(
          icon: Icons.videocam_outlined,
          label: t.videoCall,
          onTap: () {},
          enabled: false,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = enabled ? cs.primary : cs.onSurfaceVariant.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: enabled
                  ? cs.primary.withValues(alpha: 0.1)
                  : cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: tt.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// 信息字段列表
class _InfoFields extends StatelessWidget {
  final ImController im;
  final dynamic user;

  const _InfoFields({required this.im, required this.user});

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();

    return Column(
      children: [
        if (user.deptId > 0)
          _InfoField(
            label: t.department,
            valueWidget: _DeptName(im: im, deptId: user.deptId),
            isLink: true,
          ),
        if (user.superiorId > 0 && user.superiorName.isNotEmpty)
          _InfoField(
            label: t.directSuperior,
            value: user.superiorName,
            isLink: true,
          ),
        if (user.position.isNotEmpty)
          _InfoField(label: t.position, value: user.position),
        if (user.phone.isNotEmpty)
          _PhoneField(phone: user.phone),
        if (user.email.isNotEmpty)
          _InfoField(
            label: t.email,
            value: user.email,
            isLink: true,
          ),
        if (user.city.isNotEmpty)
          _InfoField(label: t.city, value: user.city),
      ],
    );
  }
}

class _DeptName extends StatefulWidget {
  final ImController im;
  final Int64 deptId;

  const _DeptName({required this.im, required this.deptId});

  @override
  State<_DeptName> createState() => _DeptNameState();
}

class _DeptNameState extends State<_DeptName> {
  String _name = '';

  @override
  void initState() {
    super.initState();
    _loadDeptName();
  }

  Future<void> _loadDeptName() async {
    final resp = await widget.im.getDeptInfo(widget.deptId);
    if (resp != null && mounted) {
      final dept = resp.depts[widget.deptId];
      if (dept != null) {
        setState(() {
          _name = dept.name;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _name.isNotEmpty ? _name : '${widget.deptId}',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final Widget? valueWidget;
  final String? value;
  final bool isLink;

  const _InfoField({
    required this.label,
    this.valueWidget,
    this.value,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: valueWidget ??
                Text(
                  value ?? '',
                  style: tt.bodyMedium?.copyWith(
                    color: isLink ? cs.primary : cs.onSurface,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _PhoneField extends StatefulWidget {
  final String phone;

  const _PhoneField({required this.phone});

  @override
  State<_PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<_PhoneField> {
  bool _showFull = false;

  String get _displayPhone {
    if (_showFull) return widget.phone;
    if (widget.phone.length <= 7) return widget.phone;
    return widget.phone.replaceAll(RegExp(r'(?<=\d{3})\d+(?=\d{4})'), '****');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              t.phoneNumber,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _displayPhone,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showFull = !_showFull),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _showFull ? t.hide : t.show,
                      style: tt.bodySmall?.copyWith(color: cs.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 把任意 [child]（通常是头像）包成点击后弹出用户资料浮层的组件。
///
/// 浮层锚定在头像**右侧**：上边框对齐头像上边界；若下方空间不足，
/// 按真实高度整体上移以免溢出（见 [_AnchoredUserMenu]）。
Widget AvatarUserPopup({
  required ImController im,
  required Int64 id,
  required String url,
  required Int64 ver,
  required Widget child,
}) {
  final avatarKey = GlobalKey();
  return Builder(
    builder: (ctx) => GestureDetector(
      onTapUp: (details) {
        final box = avatarKey.currentContext?.findRenderObject() as RenderBox?;
        if (box == null) return;
        final rect = box.localToGlobal(Offset.zero) & box.size;
        showUserMenu(
          ctx,
          rect: rect,
          im: im,
          id: id,
          url: url,
          ver: ver,
        );
      },
      child: KeyedSubtree(key: avatarKey, child: child),
    ),
  );
}

/// 弹出用户资料浮层。
///
/// - 传入 [rect]（目标元素全局矩形，如头像）：浮层出现在矩形**右侧**，
///   上边框对齐其上边；下方放不下则整体上移。用于头像点击。
/// - 传入 [point]：浮层跟随点击点，优先显示在下方，放不下则显示在上方。
///   用于 @提及、通讯录整行 等无明确元素锚点的场景。
///
/// 浮层实际高度以内容为准（首帧测量），避免固定高度导致的溢出。
void showUserMenu(
  BuildContext context, {
  Rect? rect,
  Offset? point,
  required ImController im,
  required Int64 id,
  required String url,
  required Int64 ver,
}) {
  // 使用最近（Navigator）的 Overlay：rootOverlay 会落到 EasyLoading 在
  // Navigator 之上插入的 Overlay，脱离 GoRouter 作用域，导致弹层内 context.go 报错。
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  final showMenu = _AnchoredUserMenu(
    anchorRect: rect,
    anchorPoint: point,
    im: im,
    id: id,
    url: url,
    ver: ver,
    onClose: () => entry.remove(),
  );
  entry = OverlayEntry(builder: (ctx) => showMenu);
  overlay.insert(entry);
}

/// 浮层定位支架：按锚点（头像矩形 / 点击点）弹出，首帧测量真实尺寸后修正位置，
/// 始终把浮层约束在屏幕内（各边留白 8），防止高度或宽度溢出。
class _AnchoredUserMenu extends StatefulWidget {
  /// 元素锚点（头像矩形），优先于 [anchorPoint]。
  final Rect? anchorRect;

  /// 点击点锚点。
  final Offset? anchorPoint;

  final ImController im;
  final Int64 id;
  final String url;
  final Int64 ver;
  final VoidCallback onClose;

  const _AnchoredUserMenu({
    required this.anchorRect,
    required this.anchorPoint,
    required this.im,
    required this.id,
    required this.url,
    required this.ver,
    required this.onClose,
  });

  @override
  State<_AnchoredUserMenu> createState() => _AnchoredUserMenuState();
}

class _AnchoredUserMenuState extends State<_AnchoredUserMenu> {
  final GlobalKey _menuKey = GlobalKey();
  Offset? _pos;
  static const _gap = 8.0;
  static const _margin = 8.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndFix());
  }

  void _measureAndFix() {
    if (!mounted) return;
    final box = _menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final menuSize = box.size;
    final screen = MediaQuery.of(context).size;
    setState(() => _pos = _fitPos(menuSize, screen));
  }

  Offset _fitPos(Size menuSize, Size screen) {
    const margin = _margin;
    if (widget.anchorRect != null) {
      final r = widget.anchorRect!;
      // 头像右侧 + 间距
      var left = r.right + _gap;
      left = left.clamp(
          margin, math.max(margin, screen.width - menuSize.width - margin));
      // 优先：上边框对齐头像上边界
      var top = r.top;
      // 下方空间不足：整体上移，让底部落回屏幕内
      if (top + menuSize.height > screen.height - margin) {
        top = screen.height - margin - menuSize.height;
      }
      top = top.clamp(
          margin, math.max(margin, screen.height - menuSize.height - margin));
      return Offset(left, top);
    }
    // 点击点锚定：优先放下方，放不下放上方
    final p = widget.anchorPoint!;
    var left = p.dx - menuSize.width / 2;
    left = left.clamp(
        margin, math.max(margin, screen.width - menuSize.width - margin));
    final putBelow = p.dy + _gap * 2 + menuSize.height < screen.height - margin;
    final top = putBelow
        ? p.dy + _gap * 2
        : p.dy - menuSize.height - _gap * 2;
    return Offset(
      left,
      top.clamp(
          margin, math.max(margin, screen.height - menuSize.height - margin)),
    );
  }

  Offset _guess() {
    final screen = MediaQuery.of(context).size;
    if (widget.anchorRect != null) {
      final r = widget.anchorRect!;
      return Offset(
        (r.right + _gap).clamp(_margin, screen.width),
        r.top.clamp(_margin, screen.height),
      );
    }
    final p = widget.anchorPoint!;
    return Offset(p.dx - 160, p.dy);
  }

  @override
  Widget build(BuildContext context) {
    final guess = _guess();
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onClose,
          ),
        ),
        Positioned(
          left: _pos?.dx ?? guess.dx,
          top: _pos?.dy ?? guess.dy,
          child: Opacity(
            opacity: _pos == null ? 0 : 1,
            child: KeyedSubtree(
              key: _menuKey,
              child: UserMenu(
                context,
                im: widget.im,
                id: widget.id,
                url: widget.url,
                ver: widget.ver,
                onClose: widget.onClose,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
