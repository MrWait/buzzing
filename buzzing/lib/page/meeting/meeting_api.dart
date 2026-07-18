import 'package:buzzing/controller/sdk_controller.dart';
import 'package:fixnum/fixnum.dart';
import 'package:buzzing/models/idl/command.pbenum.dart';
import 'package:buzzing/models/idl/meeting.pb.dart';

class MeetingApi {
  final SdkController sdk;

  MeetingApi(this.sdk);

  Future<MeetingCreateResponse> create(MeetingCreateRequest req) async {
    var ret = await sdk.invokeAsync(Command.MEETING_CREATE, req.writeToBuffer());
    if (ret.data != null) {
      return MeetingCreateResponse.fromBuffer(ret.data!);
    }
    return MeetingCreateResponse();
  }

  Future<JoinMeetingResponse> join(JoinMeetingRequest req) async {
    var ret = await sdk.invokeAsync(Command.MEETING_JOIN, req.writeToBuffer());
    if (ret.data != null) {
      return JoinMeetingResponse.fromBuffer(ret.data!);
    }
    return JoinMeetingResponse();
  }

  Future<void> leave(String roomId) async {
    var req = LeaveMeetingRequest.create();
    req.roomId = roomId;
    await sdk.invokeAsync(Command.MEETING_LEAVE, req.writeToBuffer());
  }

  Future<void> end(String roomId) async {
    var req = EndMeetingRequest.create();
    req.roomId = roomId;
    await sdk.invokeAsync(Command.MEETING_END, req.writeToBuffer());
  }

  Future<GetMeetingInfoResponse> getInfo(String roomId) async {
    var req = GetMeetingInfoRequest.create();
    req.roomId = roomId;
    var ret = await sdk.invokeAsync(Command.MEETING_GET_INFO, req.writeToBuffer());
    if (ret.data != null) {
      return GetMeetingInfoResponse.fromBuffer(ret.data!);
    }
    return GetMeetingInfoResponse();
  }

  Future<MeetingGetListResponse> getList(MeetingGetListRequest req) async {
    var ret = await sdk.invokeAsync(Command.MEETING_GET_LIST, req.writeToBuffer());
    if (ret.data != null) {
      return MeetingGetListResponse.fromBuffer(ret.data!);
    }
    return MeetingGetListResponse();
  }

  Future<void> kick(String roomId, int userId) async {
    var req = KickMeetingRequest(
      roomId: roomId,
      targetId: Int64(userId),
    );
    await sdk.invokeAsync(Command.MEETING_KICK, req.writeToBuffer());
  }

  Future<void> setRole(String roomId, int userId, int role) async {
    var req = SetRoleRequest(
      roomId: roomId,
      targetId: Int64(userId),
      role: role,
    );
    await sdk.invokeAsync(Command.MEETING_SET_ROLE, req.writeToBuffer());
  }

  Future<InviteMeetingResponse> invite(InviteMeetingRequest req) async {
    var ret = await sdk.invokeAsync(Command.MEETING_INVITE, req.writeToBuffer());
    if (ret.data != null) {
      return InviteMeetingResponse.fromBuffer(ret.data!);
    }
    return InviteMeetingResponse();
  }
}
