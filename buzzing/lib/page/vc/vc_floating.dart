import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/routes/app_routes.dart';
import 'package:buzzing/utils/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';

OverlayEntry? _vcOverlayEntry;

/// 显示 VC 浮窗（移动端使用），VcPage pop 后保持会议连接可见
void showVcFloating(BuildContext context) {
  if (!isMobile) return;
  if (_vcOverlayEntry != null) return;

  _vcOverlayEntry = OverlayEntry(
    builder: (ctx) => _VcFloatingWidget(
      onTap: () {
        hideVcFloating();
        context.push(AppRoute.VC);
      },
    ),
  );
  Overlay.of(context).insert(_vcOverlayEntry!);
}

/// 移除 VC 浮窗
void hideVcFloating() {
  _vcOverlayEntry?.remove();
  _vcOverlayEntry = null;
}

class _VcFloatingWidget extends ConsumerStatefulWidget {
  final VoidCallback onTap;

  const _VcFloatingWidget({required this.onTap});

  @override
  ConsumerState<_VcFloatingWidget> createState() => _VcFloatingWidgetState();
}

class _VcFloatingWidgetState extends ConsumerState<_VcFloatingWidget> {
  Offset _position = const Offset(16, 100);
  final double _size = 48;

  @override
  Widget build(BuildContext context) {
    final logic = ref.watch(vcLogicProvider);
    final cs = Theme.of(context).colorScheme;

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        onTap: widget.onTap,
        child: Material(
          elevation: 6,
          shape: const CircleBorder(),
          color: cs.primaryContainer,
          child: SizedBox(
            width: _size,
            height: _size,
            child: ClipOval(
              child: logic.cameraEnabled && logic.localRenderer.srcObject != null
                  ? RTCVideoView(logic.localRenderer, mirror: true)
                  : Icon(Icons.videocam, size: 24, color: cs.onPrimaryContainer),
            ),
          ),
        ),
      ),
    );
  }
}
