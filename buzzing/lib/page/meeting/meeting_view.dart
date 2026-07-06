import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/page/meeting/widgets/meeting_video_view.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/res/theme.dart';
import 'package:buzzing/widget/header_bar.dart';
import 'package:buzzing/widget/navigate_bar.dart';
import 'package:buzzing/utils/screen_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'meeting_logic.dart';

class MeetingPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ctl = ref.watch(meetingLogicProvider);
    return Scaffold(
      backgroundColor: cs.surface,
      body: Row(
        children: [
          NaviBar(),
          Expanded(
            child: Column(
              children: [
                HeaderBarWindows(),
                Expanded(
                  child: Row(
                    children: [
                      _MeetingSidebar(ctl: ctl, tt: tt, cs: cs),
                      Expanded(
                        child: Container(
                          color: cs.surfaceVariant,
                          child: Column(
                            children: [
                              _MeetingToolbar(ctl: ctl),
                              Expanded(
                                child: ctl.inCalling
                                    ? MeetingVideoView(
                                        localRenderer: ctl.localRenderer,
                                        remoteRenderer: ctl.remoteRenderer,
                                        inCalling: ctl.inCalling,
                                        onSwitchCamera: ctl.switchCamera,
                                        onScreenShare: () => _selectScreenSource(context),
                                        onHangUp: ctl.hangUp,
                                        onMuteMic: ctl.muteMic,
                                      )
                                    : _PeerListView(ctl: ctl),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectScreenSource(BuildContext context) async {}
}

class _MeetingSidebar extends StatelessWidget {
  final MeetingLogic ctl;
  final TextTheme tt;
  final ColorScheme cs;

  const _MeetingSidebar({
    required this.ctl,
    required this.tt,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: cs.surfaceVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(t.meeting, style: tt.titleMedium),
          ),
          Divider(height: 1, color: cs.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SidebarBtn(
                  label: t.createMeeting,
                  onTap: ctl.createMeeting,
                ),
                const SizedBox(height: 8),
                _SidebarBtn(
                  label: t.joinMeeting,
                  onTap: ctl.joinMeeting,
                ),
                const SizedBox(height: 8),
                _SidebarBtn(
                  label: t.scheduleMeeting,
                  onTap: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(t.comingMeeting, style: tt.titleSmall),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(t.historyMeeting, style: tt.titleSmall),
          ),
        ],
      ),
    );
  }
}

class _SidebarBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SidebarBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          backgroundColor: cs.primaryContainer,
          foregroundColor: cs.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}

class _MeetingToolbar extends StatelessWidget {
  final MeetingLogic ctl;

  const _MeetingToolbar({required this.ctl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          TextButton.icon(
            icon: Icon(Icons.link, size: 18, color: cs.primary),
            label: Text(t.connect),
            onPressed: () => ctl.connect(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          const Spacer(),
          Text(
            '${t.peers}: ${ctl.peers.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _PeerListView extends StatelessWidget {
  final MeetingLogic ctl;

  const _PeerListView({required this.ctl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    if (ctl.peers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam, size: 48, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(t.noPeers, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ctl.peers.length,
      itemBuilder: (context, i) {
        final peer = ctl.peers[i];
        final isSelf = peer['id'] == ctl.uid;
        return PeerListItem(
          peer: peer,
          isSelf: isSelf,
          onVideoCall: () => ctl.invitePeer(context, peer['id'], false),
          onScreenShare: () => ctl.invitePeer(context, peer['id'], true),
        );
      },
    );
  }
}
