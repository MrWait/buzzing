import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 回归测试：hover 菜单行为
/// 1. hover 菜单位置测量在 State 复用到新消息时不残留上一条（较宽）消息的
///    气泡宽度，避免短消息的菜单误翻转。
/// 2. hover 命中整行（含气泡右侧空白区域），而非仅气泡本身。
///
/// 实现与 lib/widget/message.dart 中 _MessageBoxState / _BubbleWithMenuState
/// 保持一致：hover 态由外层整行的 MouseRegion 维护，通过 hovering 传入气泡。

/// 对应 _MessageBoxState：整行 MouseRegion + 撑满宽度的 Row
class _MessageRow extends StatefulWidget {
  const _MessageRow({required this.msgId, required this.child});
  final int msgId;
  final Widget child;

  @override
  State<_MessageRow> createState() => _MessageRowState();
}

class _MessageRowState extends State<_MessageRow> {
  var _rowHovering = false;

  void _setRowHover(bool hovering) {
    if (_rowHovering == hovering) return;
    setState(() => _rowHovering = hovering);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setRowHover(true),
      onExit: (_) => _setRowHover(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: _BubbleWithMenu(
                msgId: widget.msgId,
                hovering: _rowHovering,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 对应 _BubbleWithMenu：hover 态由外部传入
class _BubbleWithMenu extends StatefulWidget {
  const _BubbleWithMenu({
    required this.msgId,
    required this.hovering,
    required this.child,
  });
  final int msgId;
  final bool hovering;
  final Widget child;

  @override
  State<_BubbleWithMenu> createState() => _BubbleWithMenuState();
}

class _BubbleWithMenuState extends State<_BubbleWithMenu> {
  static const menuKey = ValueKey('menu');
  static const _menuW = 116.0;

  final _bubbleKey = GlobalKey();
  double _bubbleW = 0;
  int _measuredMsgId = -1;
  int _hoverToken = 0;
  int _measureToken = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(covariant _BubbleWithMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.msgId != widget.msgId) {
      _measuredMsgId = -1;
      _bubbleW = 0;
      _measureToken = -1;
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
    if (!oldWidget.hovering && widget.hovering) {
      _hoverToken += 1;
      _measureToken = -1;
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
  }

  void _measure() {
    if (!mounted) return;
    final w = _bubbleKey.currentContext?.size?.width;
    if (w == null) return;
    if (w != _bubbleW ||
        _measuredMsgId != widget.msgId ||
        _measureToken != _hoverToken) {
      setState(() {
        _bubbleW = w;
        _measuredMsgId = widget.msgId;
        _measureToken = _hoverToken;
      });
    }
  }

  bool _showOnRight(double maxW) => maxW - _bubbleW >= _menuW;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final menuVisible = widget.hovering &&
            _measureToken == _hoverToken &&
            _measuredMsgId == widget.msgId &&
            _bubbleW > 0;
        final onRight = _showOnRight(c.maxWidth);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: Container(
                    key: _bubbleKey,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: DefaultTextStyle(
                      style: const TextStyle(fontSize: 14),
                      child: widget.child,
                    ),
                  ),
                ),
              ],
            ),
            if (menuVisible)
              Positioned(
                left: onRight ? _bubbleW + 4 : null,
                right: onRight ? null : 4,
                top: 0,
                child: const SizedBox(
                  key: menuKey,
                  width: _menuW,
                  height: 30,
                  child: ColoredBox(color: Color(0xFFEEEEEE)),
                ),
              ),
          ],
        );
      },
    );
  }
}

void main() {
  Widget wrap({required int msgId, required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 600,
          child: _MessageRow(msgId: msgId, child: child),
        ),
      ),
    );
  }

  Widget longChild() => Text('非常长的消息内容' * 8);
  Widget shortChild() => const Text('x');
  final menu = find.byKey(const ValueKey('menu'));

  testWidgets('复用 State 后短消息菜单不残留旧宽度，菜单贴在气泡右侧', (tester) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset(10, 10));

    // 1) 渲染一条长消息（宽气泡，占满整行），hover -> 菜单应贴左侧（右侧空间不足）
    await tester.pumpWidget(wrap(msgId: 1, child: longChild()));
    await tester.pump(); // post-frame measure（长消息）
    await gesture.moveTo(const Offset(400, 20));
    await tester.pump(); // hover 生效（本次 hover 测量未完成，菜单暂不显示）
    await tester.pump(); // post-frame 完成本次测量 -> 菜单显示
    await tester.pump(); // 兜底
    expect(menu, findsOneWidget);
    expect(tester.getTopLeft(menu).dx, closeTo(600 - 4 - 116, 10),
        reason: '长消息右侧空间不足，菜单应贴右缘放在左侧');

    // 2) 模拟 ListView 复用：同一 State 换绑到一条短消息
    await tester.pumpWidget(wrap(msgId: 2, child: shortChild()));
    await tester.pump(); // didUpdateWidget 立即作废 + post-frame 重新测量

    // 3) hover 短消息 -> 菜单必须在气泡右侧，不能复用长消息的宽度
    await gesture.moveTo(const Offset(400, 20));
    await tester.pump(); // hover 生效
    await tester.pump(); // post-frame 完成本次测量 -> 菜单显示
    expect(menu, findsOneWidget);
    expect(tester.getTopLeft(menu).dx, closeTo(38 + 4, 10),
        reason: '短消息右侧空间充足，菜单应贴在气泡右侧，不能反转');
  });

  testWidgets('hover 气泡右侧空白区域也应弹出菜单', (tester) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset(10, 300));

    // 短消息：气泡宽度约 38px，右侧 560px 都是空白区域
    await tester.pumpWidget(wrap(msgId: 1, child: shortChild()));
    await tester.pump();
    expect(menu, findsNothing, reason: '未 hover 时不应显示菜单');

    // 把鼠标移到远离气泡的右侧空白处（x=550，远超气泡宽度）
    await gesture.moveTo(const Offset(550, 20));
    await tester.pump(); // hover 生效
    await tester.pump(); // post-frame 完成测量 -> 菜单显示
    expect(menu, findsOneWidget,
        reason: 'hover 到气泡右侧空白区域应命中整行并弹出菜单');
    expect(tester.getTopLeft(menu).dx, closeTo(38 + 4, 10),
        reason: '菜单仍应贴在气泡右侧');

    // 移出该行后菜单收起
    await gesture.moveTo(const Offset(550, 400));
    await tester.pump();
    expect(menu, findsNothing, reason: '鼠标移出该行后菜单应收起');
  });

  testWidgets('菜单落在 Stack 边界内，可被点击命中', (tester) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset(10, 300));

    await tester.pumpWidget(wrap(msgId: 1, child: shortChild()));
    await tester.pump();
    await gesture.moveTo(const Offset(300, 20));
    await tester.pump();
    await tester.pump();
    expect(menu, findsOneWidget);

    // 菜单整体必须位于行宽 600 之内，否则超出父级边界无法接收点击
    final rect = tester.getRect(menu);
    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.right, lessThanOrEqualTo(600),
        reason: '菜单超出 Stack 边界会导致按钮无法点击');
  });
}
