import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/idl/meeting.pb.dart';
import 'package:buzzing/page/meeting/widgets/meeting_create_sheet.dart';
import 'package:buzzing/page/meeting/widgets/meeting_join_dialog.dart';
import 'package:buzzing/page/meeting/widgets/meeting_video_view.dart';
import 'package:buzzing/page/meeting/widgets/participant_panel.dart';
import 'package:buzzing/page/meeting/widgets/screen_share_dialog.dart';
import 'package:buzzing/page/meeting/widgets/share_to_chat_dialog.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/widget/header_bar.dart';
import 'package:buzzing/widget/navigate_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../meeting/signaling/signaling.dart';
import 'meeting_home_logic.dart';
import 'meeting_logic.dart';

class MeetingPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ctl = ref.watch(meetingLogicProvider);
    final homeCtl = ref.watch(meetingHomeLogicProvider);
    // Provider.autoDispose 不会监听 ChangeNotifier.notifyListeners，
    // 这里用 ListenableBuilder 包裹依赖 homeCtl/ctl 状态的部分，确保 tab 切换、push 刷新等能重建 UI
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
                  child: ListenableBuilder(
                    listenable: Listenable.merge([homeCtl, ctl]),
                    builder: (context, _) {
                      return Row(
                        children: [
                          _MeetingSidebar(
                            homeCtl: homeCtl,
                            ctl: ctl,
                            tt: tt,
                            cs: cs,
                            onTabSelected: (index) {
                              homeCtl.setTabIndex(index);
                            },
                          ),
                          Expanded(
                            child: Container(
                              color: cs.surfaceVariant,
                              child: ctl.inCalling
                                  ? _buildVideoView(context, ctl, homeCtl)
                                  : _MeetingHomeContent(homeCtl: homeCtl, ctl: ctl),
                            ),
                          ),
                          if (ctl.inCalling && homeCtl.currentTabIndex == 0)
                            ParticipantPanel(
                              members: [],
                              hostId: 0,
                              currentUserId: 0,
                              isHost: true,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoView(BuildContext context, MeetingLogic ctl, MeetingHomeLogic homeCtl) {
    return MeetingVideoView(
      localRenderer: ctl.localRenderer,
      remoteRenderers: ctl.remoteRenderers,
      inCalling: ctl.inCalling,
      layoutMode: ctl.layoutMode,
      activeSpeaker: ctl.activeSpeaker,
      isScreenSharing: ctl.signaling?.videoSource == VideoSource.Screen,
      onToggleScreenShare: () {
        if (ctl.signaling?.videoSource == VideoSource.Screen) {
          ctl.stopScreenSharing();
        } else {
          showScreenShareDialog(context, ctl.startScreenSharing);
        }
      },
      onHangUp: ctl.hangUp,
      onToggleLayout: () => ctl.setLayoutMode(
        ctl.layoutMode == 'grid' ? 'speaker' : 'grid',
      ),
      chatMessages: ctl.chatMessages,
      chatUnread: ctl.chatUnread,
      chatOpen: ctl.chatOpen,
      onSendChat: ctl.sendChatMessage,
      onToggleChat: ctl.toggleChat,
      micEnabled: ctl.micEnabled,
      microphones: ctl.micList,
      selectedMicDeviceId: ctl.selectedMicDeviceId,
      onToggleMic: ctl.toggleMic,
      onSelectMicrophone: ctl.switchMicrophoneDevice,
      cameraEnabled: ctl.cameraEnabled,
      cameras: ctl.cameraList,
      selectedCameraDeviceId: ctl.selectedCameraDeviceId,
      onToggleCamera: ctl.toggleCamera,
      onSelectCamera: ctl.switchCameraDevice,
      myUid: ctl.uid,
    );
  }
}

class _MeetingSidebar extends StatelessWidget {
  final MeetingHomeLogic homeCtl;
  final MeetingLogic ctl;
  final TextTheme tt;
  final ColorScheme cs;
  final void Function(int index) onTabSelected;

  const _MeetingSidebar({
    required this.homeCtl,
    required this.ctl,
    required this.tt,
    required this.cs,
    required this.onTabSelected,
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
                  icon: Icons.add,
                  onTap: () {
                    MeetingCreateSheet.show(context, onCreated: (req) async {
                      var created = await homeCtl.createMeeting(
                        title: req.title,
                        password: req.password,
                      );
                      if (created != null && created.hasMeeting()) {
                        // 创建成功后打开 VC 窗口（预加入页面），入会 API 由 VcLogic.confirmJoin 调用
                        ctl.createMeeting(
                          roomId: created.meeting.roomId,
                          roomTitle: created.meeting.title,
                        );
                      }
                    });
                  },
                ),
                const SizedBox(height: 8),
                _SidebarBtn(
                  label: t.joinMeeting,
                  icon: Icons.video_call,
                  onTap: () {
                    MeetingJoinDialog.show(context, onJoin: (roomId, password) async {
                      // 直接打开预加入窗口；入会 API 由 VcLogic.confirmJoin 在用户确认后调用
                      ctl.joinMeeting(roomId);
                    });
                  },
                ),
                const SizedBox(height: 8),
                _SidebarBtn(
                  label: t.scheduleMeeting,
                  icon: Icons.schedule,
                  onTap: () {
                    MeetingCreateSheet.show(
                      context,
                      isSchedule: true,
                      onCreated: (req) {
                        homeCtl.scheduleMeeting(
                          title: req.title,
                          scheduledAt: req.scheduledAt.toInt(),
                          password: req.password,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          _SidebarTab(
            icon: Icons.play_circle_outline,
            label: '进行中',
            count: homeCtl.activeMeetings.length,
            isSelected: homeCtl.currentTabIndex == 0,
            onTap: () => onTabSelected(0),
          ),
          _SidebarTab(
            icon: Icons.schedule,
            label: '已预定',
            count: homeCtl.scheduledMeetings.length,
            isSelected: homeCtl.currentTabIndex == 1,
            onTap: () => onTabSelected(1),
          ),
          _SidebarTab(
            icon: Icons.history,
            label: t.historyMeeting,
            count: homeCtl.historyMeetings.length,
            isSelected: homeCtl.currentTabIndex == 2,
            onTap: () => onTabSelected(2),
          ),
        ],
      ),
    );
  }
}

class _SidebarTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarTab({
    required this.icon,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: isSelected ? cs.primary : cs.onSurfaceVariant),
      title: Row(
        children: [
          Text(label, style: TextStyle(color: isSelected ? cs.primary : cs.onSurfaceVariant)),
          const Spacer(),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$count', style: TextStyle(fontSize: 11, color: cs.onPrimaryContainer)),
            ),
        ],
      ),
      selected: isSelected,
      selectedTileColor: cs.primaryContainer.withAlpha(60),
      onTap: onTap,
    );
  }
}

class _SidebarBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SidebarBtn({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          backgroundColor: cs.primaryContainer,
          foregroundColor: cs.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}

class _MeetingHomeContent extends StatelessWidget {
  final MeetingHomeLogic homeCtl;
  final MeetingLogic ctl;

  const _MeetingHomeContent({required this.homeCtl, required this.ctl});

  @override
  Widget build(BuildContext context) {
    switch (homeCtl.currentTabIndex) {
      case 0:
        return _MeetingList(meetings: homeCtl.activeMeetings, emptyText: '暂无进行中的会议', showJoinButton: true, homeCtl: homeCtl, ctl: ctl);
      case 1:
        return _MeetingList(meetings: homeCtl.scheduledMeetings, emptyText: '暂无已预定的会议', showJoinButton: false, homeCtl: homeCtl, ctl: ctl);
      case 2:
        return _MeetingList(meetings: homeCtl.historyMeetings, emptyText: '暂无历史会议', showJoinButton: false, homeCtl: homeCtl, ctl: ctl);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _MeetingList extends StatelessWidget {
  final List<MeetingInfo> meetings;
  final String emptyText;
  final bool showJoinButton;
  final MeetingHomeLogic homeCtl;
  final MeetingLogic ctl;

  const _MeetingList({
    required this.meetings,
    required this.emptyText,
    required this.showJoinButton,
    required this.homeCtl,
    required this.ctl,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (meetings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam, size: 48, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(emptyText, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: meetings.length,
      itemBuilder: (context, i) {
        var m = meetings[i];
        return _MeetingCard(
          meeting: m,
          showJoinButton: showJoinButton,
          onTap: () async {
            if (showJoinButton) {
              // 直接打开预加入窗口；入会 API 由 VcLogic.confirmJoin 在用户确认后调用
              ctl.joinMeeting(m.roomId, roomTitle: m.title);
            }
          },
        );
      },
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final MeetingInfo meeting;
  final bool showJoinButton;
  final VoidCallback? onTap;

  const _MeetingCard({
    required this.meeting,
    required this.showJoinButton,
    this.onTap,
  });

  String _formatTime(int ms) {
    var dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meeting.title.isNotEmpty ? meeting.title : '未命名会议',
                    style: tt.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '会议号: ${meeting.roomId}',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatTime(meeting.createdAt.toInt())}',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  if (meeting.members.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '参与者: ${meeting.members.length} 人',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
            if (showJoinButton)
              ElevatedButton(
                onPressed: onTap,
                child: const Text('加入'),
              ),
            if (meeting.roomId.isNotEmpty) ...[
              if (showJoinButton) const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.share, size: 18),
                tooltip: '分享到聊天',
                onPressed: () {
                  ShareToChatDialog.show(
                    context,
                    roomId: meeting.roomId,
                    title: meeting.title,
                    hostName: '',
                  );
                },
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
