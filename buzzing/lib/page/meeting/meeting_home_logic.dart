import 'package:buzzing/controller/im.dart';
import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/models/idl/command.pbenum.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/meeting.pb.dart';
import 'package:buzzing/page/vc/vc_logic.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';

import 'meeting_api.dart';

class MeetingHomeLogic extends ChangeNotifier {
  final SdkController sdk;
  late final MeetingApi api;

  List<MeetingInfo> activeMeetings = [];
  List<MeetingInfo> scheduledMeetings = [];
  List<MeetingInfo> historyMeetings = [];
  bool isLoading = false;
  int currentTabIndex = 0;

  MeetingHomeLogic({required this.sdk}) {
    api = MeetingApi(sdk);
    // 注册全局 joinApi 回调，供子窗口 VcLogic 在预加入页面调用入会 API。
    // VcWindow 通过 desktop_multi_window 创建，args 只能传 JSON，无法直接传闭包，
    // 因此用 VcLogic.globalJoinApi 静态字段做进程内桥接。
    VcLogic.globalJoinApi = (roomId, password) => joinMeeting(roomId, password: password);
  }

  void init() {
    _registerPush();
    Future.delayed(Duration.zero, loadMeetings);
  }

  void setTabIndex(int index) {
    currentTabIndex = index;
    notifyListeners();
  }

  void _registerPush() {
    sdk.regPushCallback(Command.MEETING_PUSH_UPDATE.value, (List<int> data) {
      try {
        var push = MeetingPushUpdate.fromBuffer(data);
        L.d('meeting push update: action=${push.action}, meeting=${push.meeting?.roomId}');
        loadMeetings();
      } catch (e) {
        L.e('meeting push parse error: $e');
      }
    });
  }

  Future<void> loadMeetings() async {
    isLoading = true;
    notifyListeners();

    try {
      var activeResp = await api.getList(MeetingGetListRequest(
        filter: MeetingListFilter.MEETING_LIST_ACTIVE,
        page: 1,
        pageSize: 50,
      ));
      activeMeetings = activeResp.meetings;

      var scheduledResp = await api.getList(MeetingGetListRequest(
        filter: MeetingListFilter.MEETING_LIST_SCHEDULED,
        page: 1,
        pageSize: 50,
      ));
      scheduledMeetings = scheduledResp.meetings;

      var historyResp = await api.getList(MeetingGetListRequest(
        filter: MeetingListFilter.MEETING_LIST_HISTORY,
        page: 1,
        pageSize: 50,
      ));
      historyMeetings = historyResp.meetings;
    } catch (e) {
      L.e('load meetings error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<MeetingCreateResponse?> createMeeting({
    required String title,
    String? password,
    MeetingSettings? settings,
    int maxParticipants = 0,
  }) async {
    var req = MeetingCreateRequest(
      title: title,
      password: password ?? '',
      maxParticipants: maxParticipants,
      settings: settings,
    );
    try {
      var resp = await api.create(req);
      await loadMeetings();
      return resp;
    } catch (e) {
      L.e('create meeting error: $e');
      return null;
    }
  }

  Future<MeetingCreateResponse?> scheduleMeeting({
    required String title,
    required int scheduledAt,
    String? password,
    MeetingSettings? settings,
    int maxParticipants = 0,
  }) async {
    var req = MeetingCreateRequest(
      title: title,
      password: password ?? '',
      scheduledAt: Int64(scheduledAt),
      maxParticipants: maxParticipants,
      settings: settings,
    );
    try {
      var resp = await api.create(req);
      await loadMeetings();
      return resp;
    } catch (e) {
      L.e('schedule meeting error: $e');
      return null;
    }
  }

  Future<bool> joinMeeting(String roomId, {String? password}) async {
    var req = JoinMeetingRequest(roomId: roomId, password: password ?? '');
    try {
      var resp = await api.join(req);
      return resp.hasMeeting();
    } catch (e) {
      L.e('join meeting error: $e');
      return false;
    }
  }

  Future<bool> endMeeting(String roomId) async {
    try {
      await api.end(roomId);
      await loadMeetings();
      return true;
    } catch (e) {
      L.e('end meeting error: $e');
      return false;
    }
  }

  Future<bool> leaveMeeting(String roomId) async {
    try {
      await api.leave(roomId);
      await loadMeetings();
      return true;
    } catch (e) {
      L.e('leave meeting error: $e');
      return false;
    }
  }

  Future<bool> kickMember(String roomId, int userId) async {
    try {
      await api.kick(roomId, userId);
      await loadMeetings();
      return true;
    } catch (e) {
      L.e('kick member error: $e');
      return false;
    }
  }

  Future<void> shareMeetingToChat({
    required ImController im,
    required Int64 chatId,
    required String roomId,
    required String title,
    required String hostName,
  }) async {
    var invite = MeetingInvite(
      roomId: roomId,
      title: title,
      hostName: hostName,
    );
    var message = Message.create();
    message.tpy = 12;
    message.fromId = sdk.userId;
    message.content = invite.writeToBuffer();
    message.summary = '[会议邀请] $title';
    message.chatId = chatId;

    var stashId = await im.preSendMessage(chatId, message);
    if (stashId != null) {
      await im.sendMessage(stashId, message);
    }
  }
}
