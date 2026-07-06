import 'package:buzzing/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class MeetingControls extends StatelessWidget {
  final VoidCallback onSwitchCamera;
  final VoidCallback onScreenShare;
  final VoidCallback onHangUp;
  final VoidCallback onMuteMic;

  const MeetingControls({
    required this.onSwitchCamera,
    required this.onScreenShare,
    required this.onHangUp,
    required this.onMuteMic,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ControlBtn(
            icon: Icons.switch_camera,
            tooltip: t.switchCamera,
            onTap: onSwitchCamera,
          ),
          const SizedBox(width: 16),
          _ControlBtn(
            icon: Icons.desktop_mac,
            tooltip: t.shareScreen,
            onTap: onScreenShare,
          ),
          const SizedBox(width: 16),
          _ControlBtn(
            icon: Icons.call_end,
            tooltip: t.hangup,
            onTap: onHangUp,
            color: cs.error,
            size: 36,
          ),
          const SizedBox(width: 16),
          _ControlBtn(
            icon: Icons.mic_off,
            tooltip: t.muteMic,
            onTap: onMuteMic,
          ),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;
  final double size;

  const _ControlBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        icon: Icon(icon, size: 20, color: color ?? cs.onSurface),
        onPressed: onTap,
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: size, minHeight: size),
      ),
    );
  }
}
