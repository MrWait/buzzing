import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 回归测试：验证 hover 菜单位置测量在 State 复用到新消息时不会残留
/// 上一条（较宽）消息的气泡宽度，导致短消息的菜单误翻转。
/// 实现与 lib/widget/message.dart 中 _BubbleWithMenuState 保持一致。
class _BubbleWithMenu extends StatefulWidget {
  const _BubbleWithMenu({required this.msgId, required this.child});
  final int msgId;
  final Widget child;

  @override
  State<_BubbleWithMenu> createState() => _BubbleWithMenuState();
}

class _BubbleWithMenuState extends State<_BubbleWithMenu> {
  static const menuKey = ValueKey('menu');
  final _bubbleKey = GlobalKey();
  double _bubbleW = 0;
  int _measuredMsgId = -1;
  int _hoverToken = 0;
  int _measureToken = -1;
  var _hovering = false;

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

  bool _showOnRight(double maxW) {
    const menuW = 116.0;
    return maxW - _bubbleW >= menuW;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovering = true;
          _hoverToken += 1;
          _measureToken = -1;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
      },
      onExit: (_) => setState(() => _hovering = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: LayoutBuilder(
              builder: (context, c) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      key: _bubbleKey,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: DefaultTextStyle(
                        style: const TextStyle(fontSize: 14),
                        child: widget.child,
                      ),
                    ),
                    if (_hovering &&
                        _measureToken == _hoverToken &&
                        _measuredMsgId == widget.msgId &&
                        _bubbleW > 0)
                      Positioned(
                        left: _showOnRight(c.maxWidth) ? _bubbleW + 4 : null,
                        right: _showOnRight(c.maxWidth) ? null : 4,
                        top: 0,
                        child: SizedBox(
                          key: menuKey,
                          width: 116,
                          height: 30,
                          child: const ColoredBox(color: Color(0xFFEEEEEE)),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  Widget wrap({required int msgId, required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 600,
          child: _BubbleWithMenu(msgId: msgId, child: child),
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
}
