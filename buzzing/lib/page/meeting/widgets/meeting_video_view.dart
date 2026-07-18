import 'package:buzzing/page/meeting/meeting_logic.dart';
import 'package:buzzing/page/meeting/widgets/chat_overlay.dart';
import 'package:buzzing/page/meeting/widgets/meeting_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class MeetingVideoView extends StatelessWidget {
  final RTCVideoRenderer localRenderer;
  final Map<String, RTCVideoRenderer> remoteRenderers;
  final bool inCalling;
  final String layoutMode;
  final String? activeSpeaker;
  final bool isScreenSharing;
  final VoidCallback onToggleScreenShare;
  final VoidCallback onHangUp;
  final VoidCallback? onToggleLayout;
  final List<ChatMessage> chatMessages;
  final int chatUnread;
  final bool chatOpen;
  final void Function(String text) onSendChat;
  final VoidCallback onToggleChat;

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
  final String myUid;

  const MeetingVideoView({
    required this.localRenderer,
    required this.remoteRenderers,
    required this.inCalling,
    this.layoutMode = 'grid',
    this.activeSpeaker,
    required this.isScreenSharing,
    required this.onToggleScreenShare,
    required this.onHangUp,
    this.onToggleLayout,
    this.chatMessages = const [],
    this.chatUnread = 0,
    this.chatOpen = false,
    required this.onSendChat,
    required this.onToggleChat,
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
    required this.myUid,
  });

  @override
  Widget build(BuildContext context) {
    if (!inCalling) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _buildVideoArea(cs),
                    ),
                  ],
                ),
              ),
              ChatOverlay(
                messages: chatMessages,
                unread: chatUnread,
                open: chatOpen,
                onSend: onSendChat,
                onToggle: onToggleChat,
                myUid: myUid,
              ),
            ],
          ),
        ),
        MeetingControls(
          isScreenSharing: isScreenSharing,
          onToggleScreenShare: onToggleScreenShare,
          onHangUp: onHangUp,
          onToggleLayout: onToggleLayout,
          layoutMode: layoutMode,
          onToggleChat: onToggleChat,
          chatUnread: chatUnread,
          micEnabled: micEnabled,
          microphones: microphones,
          selectedMicDeviceId: selectedMicDeviceId,
          onToggleMic: onToggleMic,
          onSelectMicrophone: onSelectMicrophone,
          cameraEnabled: cameraEnabled,
          cameras: cameras,
          selectedCameraDeviceId: selectedCameraDeviceId,
          onToggleCamera: onToggleCamera,
          onSelectCamera: onSelectCamera,
        ),
      ],
    );
  }

  Widget _buildVideoArea(ColorScheme cs) {
    final remoteCount = remoteRenderers.length;
    if (remoteCount == 0) {
      return _localOnlyView(cs);
    }
    if (layoutMode == 'speaker') {
      return _speakerView(cs, remoteCount);
    }
    return _gridView(cs, remoteCount);
  }

  Widget _localOnlyView(ColorScheme cs) {
    return Container(
      color: cs.surfaceContainerLow,
      child: Center(
        child: SizedBox(
          width: 320,
          height: 240,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: RTCVideoView(localRenderer, mirror: true),
          ),
        ),
      ),
    );
  }

  Widget _gridView(ColorScheme cs, int remoteCount) {
    if (remoteCount == 1) {
      return _oneRemoteView(cs);
    }
    if (remoteCount <= 2) {
      return _twoColView(cs);
    }
    return _multiGridView(cs);
  }

  Widget _oneRemoteView(ColorScheme cs) {
    var pair = remoteRenderers.entries.first;
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
              child: RTCVideoView(localRenderer, mirror: true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _twoColView(ColorScheme cs) {
    var renderers = remoteRenderers.values.toList();
    return Row(
      children: [
        Expanded(
          child: Container(
            color: cs.surfaceContainerLow,
            child: RTCVideoView(renderers[0]),
          ),
        ),
        Container(
          width: 2,
          color: cs.outlineVariant,
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: cs.surfaceContainerLow,
                  child: RTCVideoView(renderers.length > 1 ? renderers[1] : localRenderer,
                      mirror: renderers.length <= 1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _multiGridView(ColorScheme cs) {
    var entries = remoteRenderers.entries.toList();
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  color: cs.surfaceContainerLow,
                  child: RTCVideoView(entries[0].value),
                ),
              ),
              Container(width: 2, color: cs.outlineVariant),
              Expanded(
                child: Container(
                  color: cs.surfaceContainerLow,
                  child: RTCVideoView(entries[1].value),
                ),
              ),
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
                  child:
                      RTCVideoView(entries.length > 2 ? entries[2].value : localRenderer,
                          mirror: entries.length <= 2),
                ),
              ),
              Container(width: 2, color: cs.outlineVariant),
              Expanded(
                child: Container(
                  color: cs.surfaceContainerLow,
                  child: RTCVideoView(localRenderer, mirror: true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _speakerView(ColorScheme cs, int remoteCount) {
    var entries = remoteRenderers.entries.toList();

    String? mainPeerId;
    if (activeSpeaker != null && remoteRenderers.containsKey(activeSpeaker)) {
      mainPeerId = activeSpeaker;
    } else if (entries.isNotEmpty) {
      mainPeerId = entries[0].key;
    }

    var mainRenderer =
        mainPeerId != null ? remoteRenderers[mainPeerId] : null;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            color: cs.surfaceContainerLow,
            child: mainRenderer != null
                ? RTCVideoView(mainRenderer)
                : RTCVideoView(localRenderer, mirror: true),
          ),
        ),
        Container(width: 2, color: cs.outlineVariant),
        SizedBox(
          width: 200,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, i) {
                    var entry = entries[i];
                    var isMain = entry.key == mainPeerId;
                    return Container(
                      height: 120,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: isMain
                            ? Border.all(color: cs.primary, width: 2)
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(isMain ? 4 : 6),
                        child: RTCVideoView(entry.value),
                      ),
                    );
                  },
                ),
              ),
              Container(
                height: 100,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: RTCVideoView(localRenderer, mirror: true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
