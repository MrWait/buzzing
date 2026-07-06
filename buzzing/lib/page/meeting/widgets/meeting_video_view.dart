import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/page/meeting/widgets/meeting_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class MeetingVideoView extends StatelessWidget {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final bool inCalling;
  final VoidCallback onSwitchCamera;
  final VoidCallback onScreenShare;
  final VoidCallback onHangUp;
  final VoidCallback onMuteMic;

  const MeetingVideoView({
    required this.localRenderer,
    required this.remoteRenderer,
    required this.inCalling,
    required this.onSwitchCamera,
    required this.onScreenShare,
    required this.onHangUp,
    required this.onMuteMic,
  });

  @override
  Widget build(BuildContext context) {
    if (!inCalling) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: OrientationBuilder(
            builder: (context, orientation) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: cs.surfaceContainerLow,
                      child: RTCVideoView(remoteRenderer),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 20,
                    child: Container(
                      width: orientation == Orientation.portrait ? 90 : 120,
                      height: orientation == Orientation.portrait ? 120 : 90,
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
                  if (!inCalling)
                    Center(
                      child: Text(
                        t.callConnecting,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        MeetingControls(
          onSwitchCamera: onSwitchCamera,
          onScreenShare: onScreenShare,
          onHangUp: onHangUp,
          onMuteMic: onMuteMic,
        ),
      ],
    );
  }
}

class PeerListItem extends StatelessWidget {
  final dynamic peer;
  final bool isSelf;
  final VoidCallback onVideoCall;
  final VoidCallback onScreenShare;

  const PeerListItem({
    required this.peer,
    required this.isSelf,
    required this.onVideoCall,
    required this.onScreenShare,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        ListTile(
          title: Text(
            '${peer['name']}, ID: ${peer['id']}${isSelf ? ' [${t.self}]' : ''}',
            style: tt.bodyMedium,
          ),
          subtitle: Text(
            '[${peer['user_agent']}]',
            style: tt.bodySmall,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  isSelf ? Icons.close : Icons.videocam,
                  color: isSelf ? Colors.grey : cs.onSurface,
                ),
                onPressed: isSelf ? null : onVideoCall,
                tooltip: t.videoCall,
              ),
              IconButton(
                icon: Icon(
                  isSelf ? Icons.close : Icons.screen_share,
                  color: isSelf ? Colors.grey : cs.onSurface,
                ),
                onPressed: isSelf ? null : onScreenShare,
                tooltip: t.shareScreen,
              ),
            ],
          ),
        ),
        Divider(height: 1, color: cs.outlineVariant),
      ],
    );
  }
}
