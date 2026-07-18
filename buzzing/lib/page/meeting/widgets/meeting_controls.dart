import 'package:buzzing/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class MeetingControls extends StatelessWidget {
  final bool isScreenSharing;
  final VoidCallback onToggleScreenShare;
  final VoidCallback onHangUp;
  final VoidCallback? onToggleLayout;
  final String? layoutMode;
  final VoidCallback? onToggleChat;
  final int chatUnread;

  final bool micEnabled;
  final List<Map<String, String>> microphones;
  final String? selectedMicDeviceId;
  final VoidCallback onToggleMic;
  final void Function(String deviceId) onSelectMicrophone;

  final bool cameraEnabled;
  final List<Map<String, String>> cameras;
  final String? selectedCameraDeviceId;
  final VoidCallback onToggleCamera;
  final void Function(String deviceId) onSelectCamera;

  const MeetingControls({
    required this.isScreenSharing,
    required this.onToggleScreenShare,
    required this.onHangUp,
    this.onToggleLayout,
    this.layoutMode,
    this.onToggleChat,
    this.chatUnread = 0,
    required this.micEnabled,
    this.microphones = const [],
    this.selectedMicDeviceId,
    required this.onToggleMic,
    required this.onSelectMicrophone,
    required this.cameraEnabled,
    this.cameras = const [],
    this.selectedCameraDeviceId,
    required this.onToggleCamera,
    required this.onSelectCamera,
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
          _ToggleDeviceBtn(
            tooltip: t.muteMic,
            enabled: micEnabled,
            enabledIcon: Icons.mic,
            disabledIcon: Icons.mic_off,
            onToggle: onToggleMic,
            devices: microphones,
            selectedDeviceId: selectedMicDeviceId,
            onSelectDevice: onSelectMicrophone,
          ),
          const SizedBox(width: 16),
          _ToggleDeviceBtn(
            tooltip: t.switchCamera,
            enabled: cameraEnabled,
            enabledIcon: Icons.videocam,
            disabledIcon: Icons.videocam_off,
            onToggle: onToggleCamera,
            devices: cameras,
            selectedDeviceId: selectedCameraDeviceId,
            onSelectDevice: onSelectCamera,
          ),
          const SizedBox(width: 16),
          _ControlBtn(
            icon: isScreenSharing ? Icons.desktop_windows : Icons.desktop_mac,
            tooltip: isScreenSharing ? t.stopScreenShare : t.shareScreen,
            onTap: onToggleScreenShare,
            color: isScreenSharing ? cs.primary : null,
          ),
          const SizedBox(width: 16),
          if (onToggleLayout != null)
            _ControlBtn(
              icon: layoutMode == 'grid'
                  ? Icons.view_column
                  : Icons.grid_view,
              tooltip: layoutMode == 'grid' ? t.speakerView : t.gridView,
              onTap: onToggleLayout!,
            ),
          if (onToggleLayout != null) const SizedBox(width: 16),
          if (onToggleChat != null)
            _ControlBtn(
              icon: Icons.chat_bubble_outline,
              tooltip: t.meetingChat,
              onTap: onToggleChat!,
              badge: chatUnread > 0 ? chatUnread.toString() : null,
            ),
          if (onToggleChat != null) const SizedBox(width: 16),
          _ControlBtn(
            icon: Icons.call_end,
            tooltip: t.hangup,
            onTap: onHangUp,
            color: cs.error,
            size: 36,
          ),
        ],
      ),
    );
  }
}

class _ToggleDeviceBtn extends StatelessWidget {
  final String tooltip;
  final bool enabled;
  final IconData enabledIcon;
  final IconData disabledIcon;
  final VoidCallback onToggle;
  final List<Map<String, String>> devices;
  final String? selectedDeviceId;
  final void Function(String deviceId) onSelectDevice;

  const _ToggleDeviceBtn({
    required this.tooltip,
    required this.enabled,
    required this.enabledIcon,
    required this.disabledIcon,
    required this.onToggle,
    required this.devices,
    this.selectedDeviceId,
    required this.onSelectDevice,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    var icon = enabled ? enabledIcon : disabledIcon;
    var iconColor = enabled ? cs.onSurface : cs.onSurfaceVariant;

    return SizedBox(
      height: 32,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              icon: Icon(icon, size: 20, color: iconColor),
              onPressed: onToggle,
              tooltip: tooltip,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: '',
            icon: Icon(Icons.arrow_drop_down, size: 16, color: iconColor),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onSelected: onSelectDevice,
            itemBuilder: (context) => devices.map((d) {
              var text = d['label'] ?? '';
              if (text.isEmpty) text = d['deviceId'] ?? '';
              var isSelected = d['deviceId'] == selectedDeviceId;
              return PopupMenuItem(
                value: d['deviceId'],
                child: Row(
                  children: [
                    if (isSelected)
                      Icon(Icons.check, size: 14, color: cs.primary),
                    if (isSelected) const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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
  final String? badge;

  const _ControlBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
    this.size = 32,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(icon, size: 20, color: color ?? cs.onSurface),
            onPressed: onTap,
            tooltip: tooltip,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: size, minHeight: size),
          ),
          if (badge != null)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cs.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: cs.onError,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
