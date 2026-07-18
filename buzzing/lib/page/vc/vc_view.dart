import 'dart:async';
import 'dart:convert';

import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/page/meeting/widgets/chat_overlay.dart';
import 'package:buzzing/page/meeting/widgets/meeting_controls.dart';
import 'package:buzzing/page/meeting/widgets/screen_share_dialog.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:window_manager/window_manager.dart';

import '../meeting/signaling/signaling.dart';
import 'vc_logic.dart';

class VcWindow extends StatefulWidget {
  final WindowController windowController;
  final Map? args;
  final String id;

  const VcWindow({
    required this.windowController,
    required this.args,
    required this.id,
  });

  @override
  State<VcWindow> createState() => _VcWindowState();
}

class _VcWindowState extends State<VcWindow> with WindowListener {
  late VcLogic _logic;
  // 控制 sub_window_tick 循环退出
  bool _tickActive = false;
  // 防止 onWindowClose 重复触发（hide 是异步的，期间可能再次进入）
  bool _hiding = false;
  // 应用退出时强制销毁（不走隐藏流程）
  bool _forceDestroy = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    // 拦截原生关闭：onWindowClose 中改为隐藏窗口 + 释放重资源，保留 engine
    windowManager.setPreventClose(true);
    _startTick();
    // 注册子窗口的 method handler，主窗口通过 controller.invokeMethod 调用
    // 必须用 windowController.setWindowMethodHandler（基于 windowId 的 unidirectional channel），
    // 而非 widget.channel（WindowMethodChannel('VcWindow'), bidirectional，主窗口未注册会失败）
    widget.windowController.setWindowMethodHandler(_onMethodCall);

    final token = widget.args?['token'] as String? ?? '';
    final uid = widget.args?['uid'] as String? ?? '';
    final userName = widget.args?['user_name'] as String? ?? '';
    final roomId = widget.args?['room_id'] as String?;
    final roomTitle = widget.args?['room_title'] as String?;
    // 同步语言设置
    var localeCode = widget.args?['locale'] as String?;
    if (localeCode != null && localeCode.isNotEmpty) {
      var locale = AppLocale.values.where((l) => l.languageCode == localeCode).firstOrNull;
      if (locale != null) {
        LocaleSettings.setLocale(locale);
        L.d('[VcWindow] locale synced: $localeCode');
      }
    }
    // 预加入模式：仅初始化本地预览，不连接 signaling、不进入房间
    // 由用户在预加入页面点击"加入会议"后，VcLogic.confirmJoin 才会 connect + joinRoom
    _logic = VcLogic(token: token, uid: uid, userName: userName, roomId: roomId, roomTitle: roomTitle);
    _logic.init();
  }

  void _startTick() {
    _tickActive = true;
    Future.delayed(Duration.zero, () async {
      while (_tickActive && mounted) {
        var channel = WindowMethodChannel('Main');
        try {
          await channel.invokeMethod(
            'sub_window_tick',
            jsonEncode({'id': widget.id}),
          );
        } catch (_) {
          // 主窗口已关闭或通道异常，停止 tick
          break;
        }
        // 隐藏时降低 tick 频率到 5 秒，节省 CPU；可见时 1 秒保持响应
        var interval = _logic.isHidden ? 5 : 1;
        await Future.delayed(Duration(seconds: interval));
      }
    });
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    L.d('sub window call handler: ${call.method}');
    switch (call.method) {
      case 'reactivate':
        // 主窗口复用本子窗口时调用：携带新的 room_id/room_title
        final args = call.arguments is String
            ? jsonDecode(call.arguments as String) as Map<String, dynamic>
            : (call.arguments as Map? ?? {});
        final roomId = args['room_id'] as String?;
        final roomTitle = args['room_title'] as String?;
        var localeCode = args['locale'] as String?;
        if (localeCode != null && localeCode.isNotEmpty) {
          var locale = AppLocale.values.where((l) => l.languageCode == localeCode).firstOrNull;
          if (locale != null) {
            LocaleSettings.setLocale(locale);
          }
        }
        await _logic.reactivate(roomId: roomId, roomTitle: roomTitle);
        break;
      case 'destroy':
        // 主窗口应用退出时强制销毁所有子窗口
        await destroyForAppExit();
        break;
      case 'close':
      case 'show':
      case 'join':
      case 'leave':
        break;
    }
  }

  /// 应用退出时调用：真正销毁 engine + 释放所有资源
  Future<void> destroyForAppExit() async {
    L.d('[VcWindow] destroyForAppExit');
    _forceDestroy = true;
    _tickActive = false;
    await _logic.disposeAsync();
    await windowManager.setPreventClose(false);
    try {
      await windowManager.close();
    } catch (e) {
      L.e('[VcWindow] destroy close failed: $e');
    }
  }

  @override
  void dispose() {
    L.d('sub window dispose');
    _tickActive = false;
    windowManager.removeListener(this);
    widget.windowController.setWindowMethodHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    var currentLocale = LocaleSettings.instance.currentLocale.flutterLocale;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: currentLocale,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocaleUtils.supportedLocales,
      home: Scaffold(
        backgroundColor: cs.surfaceContainerLow,
        body: ListenableBuilder(
          listenable: _logic,
          builder: (context, _) {
            switch (_logic.phase) {
              case VcPhase.prejoin:
                return _PreJoinView(logic: _logic);
              case VcPhase.inMeeting:
                if (!_logic.inCalling) {
                  // 已确认加入但尚未收到本地流，展示过渡 Connecting 视图
                  return _ConnectingView();
                }
                return _buildMeetingView(cs);
              case VcPhase.ended:
                // leaveAndHide 已将 phase 重置为 prejoin，正常不会进入此分支
                return _ConnectingView();
            }
          },
        ),
      ),
    );
  }

  Widget _buildMeetingView(ColorScheme cs) {
    var remoteCount = _logic.remoteRenderers.length;
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: remoteCount == 0
                    ? _localOnlyView(cs)
                    : remoteCount == 1
                        ? _oneRemoteView(cs)
                        : _multiGridView(cs),
              ),
              ChatOverlay(
                messages: _logic.chatMessages,
                unread: _logic.chatUnread,
                open: _logic.chatOpen,
                onSend: _logic.sendChatMessage,
                onToggle: _logic.toggleChat,
                myUid: _logic.uid,
              ),
            ],
          ),
        ),
        MeetingControls(
          isScreenSharing: _logic.signaling?.videoSource == VideoSource.Screen,
          onToggleScreenShare: () {
            if (_logic.signaling?.videoSource == VideoSource.Screen) {
              _logic.stopScreenSharing();
            } else {
              showScreenShareDialog(context, _logic.startScreenSharing);
            }
          },
          onHangUp: _hideWindow,
          onToggleLayout: () =>
              _logic.setLayoutMode(
            _logic.layoutMode == 'grid' ? 'speaker' : 'grid',
          ),
          layoutMode: _logic.layoutMode,
          onToggleChat: _logic.toggleChat,
          chatUnread: _logic.chatUnread,
          micEnabled: _logic.micEnabled,
          microphones: _logic.micList,
          selectedMicDeviceId: _logic.selectedMicDeviceId,
          onToggleMic: _logic.toggleMic,
          onSelectMicrophone: _logic.switchMicrophoneDevice,
          cameraEnabled: _logic.cameraEnabled,
          cameras: _logic.cameraList,
          selectedCameraDeviceId: _logic.selectedCameraDeviceId,
          onToggleCamera: _logic.toggleCamera,
          onSelectCamera: _logic.switchCameraDevice,
        ),
      ],
    );
  }

  Widget _localOnlyView(ColorScheme cs) {
    return Center(
      child: Container(
        width: 320,
        height: 240,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: RTCVideoView(_logic.localRenderer, mirror: true),
        ),
      ),
    );
  }

  Widget _oneRemoteView(ColorScheme cs) {
    var pair = _logic.remoteRenderers.entries.first;
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: cs.surfaceContainerLow,
            child: RTCVideoView(pair.value),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: RTCVideoView(_logic.localRenderer, mirror: true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _multiGridView(ColorScheme cs) {
    var entries = _logic.remoteRenderers.entries.toList();
    if (entries.length == 1) {
      return Row(
        children: [
          Expanded(child: RTCVideoView(entries[0].value)),
          Container(width: 2, color: cs.outlineVariant),
          Expanded(child: RTCVideoView(_logic.localRenderer, mirror: true)),
        ],
      );
    }
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: Container(color: cs.surfaceContainerLow, child: RTCVideoView(entries[0].value))),
              Container(width: 2, color: cs.outlineVariant),
              Expanded(child: Container(color: cs.surfaceContainerLow, child: RTCVideoView(entries[1].value))),
            ],
          ),
        ),
        Container(height: 2, color: cs.outlineVariant),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  color: cs.surfaceContainerLow,
                  child: RTCVideoView(entries.length > 2 ? entries[2].value : _logic.localRenderer,
                      mirror: entries.length <= 2),
                ),
              ),
              Container(width: 2, color: cs.outlineVariant),
              Expanded(
                child: Container(
                  color: cs.surfaceContainerLow,
                  child: RTCVideoView(_logic.localRenderer, mirror: true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _hideWindow() async {
    if (_hiding) return;
    _hiding = true;
    L.d('[VcWindow] hide window');
    // 释放 WebRTC 重资源（PC/localStream/socket），保留 VcLogic + renderer + widget tree
    await _logic.leaveAndHide();
    // 通知主窗口：本子窗口已隐藏（windows[tag] 保留，下次复用）
    var channel = WindowMethodChannel('Main');
    try {
      await channel.invokeMethod(
        'sub_window_hide',
        jsonEncode({'id': widget.id}),
      );
    } catch (_) {}
    // 隐藏窗口，engine 保留
    try {
      await windowManager.hide();
    } catch (e) {
      L.e('[VcWindow] hide failed: $e');
    }
    _hiding = false;
  }

  @override
  void onWindowClose() async {
    // 应用退出时走强制销毁流程
    if (_forceDestroy) {
      super.onWindowClose();
      return;
    }
    await _hideWindow();
  }
}

/// 过渡视图：已确认加入但尚未收到本地流，或预加入页面取消后等待窗口关闭
class _ConnectingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.videocam, size: 64, color: cs.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'Connecting...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

/// 预加入页面：入会前检查本地麦克风/摄像头状态
/// 类似飞书的预加入页面：顶部会议信息 + 中间本地视频预览 + 底部设备控制
class _PreJoinView extends StatelessWidget {
  final VcLogic logic;

  const _PreJoinView({required this.logic});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 顶部：会议信息
            _MeetingInfoHeader(logic: logic, cs: cs, tt: tt),
            const SizedBox(height: 24),
            // 中间：本地视频预览
            _PreviewArea(logic: logic, cs: cs),
            const SizedBox(height: 24),
            // 设备控制行：开关 + 弹出列表复合模式
            _DeviceControlRow(logic: logic, cs: cs, tt: tt),
            const SizedBox(height: 24),
            // 加入会议主按钮
            _JoinButton(logic: logic, cs: cs, tt: tt),
          ],
        ),
      ),
    );
  }
}

class _MeetingInfoHeader extends StatelessWidget {
  final VcLogic logic;
  final ColorScheme cs;
  final TextTheme tt;

  const _MeetingInfoHeader({
    required this.logic,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    final title = (logic.roomTitle == null || logic.roomTitle!.isEmpty)
        ? t.readyToJoin
        : logic.roomTitle!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: tt.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
        if (logic.roomId != null && logic.roomId!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '${t.meetingNo}: ${logic.roomId}',
            style: tt.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _PreviewArea extends StatelessWidget {
  final VcLogic logic;
  final ColorScheme cs;

  const _PreviewArea({required this.logic, required this.cs});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: logic.cameraEnabled
              ? RTCVideoView(logic.localRenderer, mirror: true)
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam_off, size: 48, color: cs.onSurfaceVariant),
                      const SizedBox(height: 8),
                      Text(
                        t.cameraDevice + ' ' + t.cancel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// 设备控制行：麦克风 + 摄像头，开关与设备列表合二为一
class _DeviceControlRow extends StatelessWidget {
  final VcLogic logic;
  final ColorScheme cs;
  final TextTheme tt;

  const _DeviceControlRow({
    required this.logic,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DeviceControl(
            enabledIcon: Icons.mic,
            disabledIcon: Icons.mic_off,
            enabled: logic.micEnabled,
            devices: logic.micList,
            selectedDeviceId: logic.selectedMicDeviceId,
            cs: cs,
            tt: tt,
            onToggle: logic.toggleMic,
            onSelectDevice: logic.switchMicrophoneDevice,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DeviceControl(
            enabledIcon: Icons.videocam,
            disabledIcon: Icons.videocam_off,
            enabled: logic.cameraEnabled,
            devices: logic.cameraList,
            selectedDeviceId: logic.selectedCameraDeviceId,
            cs: cs,
            tt: tt,
            onToggle: logic.toggleCamera,
            onSelectDevice: logic.switchCameraDevice,
          ),
        ),
      ],
    );
  }
}

/// 单个设备控制：开关按钮 + 右侧弹出设备列表
class _DeviceControl extends StatelessWidget {
  final IconData enabledIcon;
  final IconData disabledIcon;
  final bool enabled;
  final List<Map<String, String>> devices;
  final String? selectedDeviceId;
  final ColorScheme cs;
  final TextTheme tt;
  final VoidCallback onToggle;
  final void Function(String deviceId) onSelectDevice;

  const _DeviceControl({
    required this.enabledIcon,
    required this.disabledIcon,
    required this.enabled,
    required this.devices,
    required this.selectedDeviceId,
    required this.cs,
    required this.tt,
    required this.onToggle,
    required this.onSelectDevice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? cs.primaryContainer : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          // 开关按钮区域
          Expanded(
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      enabled ? enabledIcon : disabledIcon,
                      size: 18,
                      color: enabled ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        devices.isEmpty
                            ? ''
                            : (devices.first['label'] ?? ''),
                        style: tt.bodySmall?.copyWith(
                          color: enabled ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 弹出设备列表
          PopupMenuButton<String>(
            tooltip: '',
            icon: Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: enabled ? cs.onPrimaryContainer : cs.onSurfaceVariant,
            ),
            padding: EdgeInsets.zero,
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
                      Icon(Icons.check, size: 16, color: cs.primary),
                    if (isSelected)
                      const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        text,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall?.copyWith(
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

class _JoinButton extends StatelessWidget {
  final VcLogic logic;
  final ColorScheme cs;
  final TextTheme tt;

  const _JoinButton({required this.logic, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () async {
          final ok = await logic.confirmJoin();
          if (!ok && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t.joinMeeting + ' ' + t.cancel)),
            );
          }
        },
        child: Text(t.joinMeeting, style: tt.titleMedium?.copyWith(color: cs.onPrimary)),
      ),
    );
  }
}
