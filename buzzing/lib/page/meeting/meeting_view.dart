import 'package:buzzing/models/const.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/res/theme.dart';
import 'package:buzzing/widget/button.dart';
import 'package:buzzing/widget/code_input_box.dart';
import 'package:buzzing/widget/debounce_button.dart';
import 'package:buzzing/widget/header_bar.dart';
import 'package:buzzing/widget/navigate_bar.dart';
import 'package:buzzing/widget/phone_input_box.dart';
import 'package:buzzing/widget/pwd_input_box.dart';
import 'package:buzzing/widget/touch_close_keyboard.dart';
import 'package:buzzing/controller/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buzzing/utils/screen_ext.dart';

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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(child: HeaderBarWindows()),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        height: 1.sh,
                        width: 260,
                        color: cs.onSurfaceVariant,
                        child: Column(
                          children: [
                            Text("Meeting", style: tt.bodyMedium),
                            TextButton(
                              child: Text(t.createMeeting),
                              onPressed: () {
                                ctl.createMeeting();
                              },
                            ),
                            TextButton(
                              child: Text(t.joinMeeting),
                              onPressed: () {
                                ctl.joinMeeting();
                              },
                            ),
                            TextButton(
                              child: Text(t.scheduleMeeting),
                              onPressed: () {},
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(t.comingMeeting),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(t.historyMeeting),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1.sh,
                          child: Column(
                            children: [
                              TextButton(
                                child: Text("connect"),
                                onPressed: () async {
                                  ctl.connect(context);
                                },
                              ),
                              Container(height: 500, child: MeetingView()),
                            ],
                          ),
                          color: cs.surfaceVariant,
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
}

class MeetingView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctl = ref.watch(meetingLogicProvider);
    final cs = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: ctl,
      builder: (ctx, _) => Scaffold(
        appBar: AppBar(title: Text("Meeting View")),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: ctl.inCalling
            ? SizedBox(
                width: 240.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FloatingActionButton(
                      child: const Icon(Icons.switch_camera),
                      tooltip: "Camera",
                      onPressed: ctl.switchCamera,
                    ),
                    FloatingActionButton(
                      child: const Icon(Icons.desktop_mac),
                      tooltip: "Screen Sharing",
                      onPressed: () => selectScreenSourceDialog(context),
                    ),
                    FloatingActionButton(
                      child: const Icon(Icons.call_end),
                      tooltip: "Hangup",
                      onPressed: ctl.hangUp,
                      backgroundColor: cs.error,
                    ),
                    FloatingActionButton(
                      child: const Icon(Icons.mic_off),
                      tooltip: "Mute Mic",
                      onPressed: ctl.muteMic,
                    ),
                  ],
                ),
              )
            : null,
        body: ctl.inCalling
            ? OrientationBuilder(
                builder: (context, orientation) {
                  return Container(
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: 0.0,
                          right: 0.0,
                          top: 0.0,
                          bottom: 0.0,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: RTCVideoView(ctl.remoteRenderer),
                            decoration: BoxDecoration(
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20.0,
                          top: 20.0,
                          child: Container(
                            width: orientation == Orientation.portrait
                                ? 90.0
                                : 120.0,
                            height: orientation == Orientation.portrait
                                ? 120.0
                                : 90.0,
                            child: RTCVideoView(
                              ctl.localRenderer,
                              mirror: true,
                            ),
                            decoration: BoxDecoration(
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(0.0),
                  itemCount: (ctl.peers != null ? ctl.peers.length : 0),
                  itemBuilder: (context, i) {
                    return buildRow(context, ctl, ctl.peers[i]);
                  },
                ),
      ),
    );
  }

  Widget buildRow(BuildContext context, MeetingLogic ctl, peer) {
    final cs = Theme.of(context).colorScheme;
    var self = (peer['id'] == ctl.uid);
    return ListBody(
      children: <Widget>[
        ListTile(
          title: Text(
            self
                ? peer['name'] + ', ID: ${peer['id']}' + ' [Your Self]'
                : peer['name'] + ', ID: ${peer['id']}',
          ),
          onTap: null,
          trailing: SizedBox(
            width: 100.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    self ? Icons.close : Icons.videocam,
                    color: self ? Colors.grey : cs.onSurface,
                  ),
                  onPressed: () => ctl.invitePeer(context, peer['id'], false),
                  tooltip: "Video Calling",
                ),
                IconButton(
                  icon: Icon(
                    self ? Icons.close : Icons.screen_share,
                    color: self ? Colors.grey : cs.onSurface,
                  ),
                  onPressed: () => ctl.invitePeer(context, peer['id'], true),
                  tooltip: "Screen Sharing",
                ),
              ],
            ),
          ),
          subtitle: Text('[' + peer['user_agent'] + ']'),
        ),
        Divider(),
      ],
    );
  }

  Future<void> selectScreenSourceDialog(BuildContext context) async {}
}
