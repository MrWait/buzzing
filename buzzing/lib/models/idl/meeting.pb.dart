// This is a generated file - do not edit.
//
// Generated from meeting.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'meeting.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'meeting.pbenum.dart';

class MeetingSettings extends $pb.GeneratedMessage {
  factory MeetingSettings({
    $core.bool? muteOnEntry,
    $core.bool? allowScreenShare,
    $core.bool? recordEnabled,
  }) {
    final result = create();
    if (muteOnEntry != null) result.muteOnEntry = muteOnEntry;
    if (allowScreenShare != null) result.allowScreenShare = allowScreenShare;
    if (recordEnabled != null) result.recordEnabled = recordEnabled;
    return result;
  }

  MeetingSettings._();

  factory MeetingSettings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MeetingSettings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MeetingSettings',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'muteOnEntry')
    ..aOB(2, _omitFieldNames ? '' : 'allowScreenShare')
    ..aOB(3, _omitFieldNames ? '' : 'recordEnabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeetingSettings clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeetingSettings copyWith(void Function(MeetingSettings) updates) =>
      super.copyWith((message) => updates(message as MeetingSettings))
          as MeetingSettings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MeetingSettings create() => MeetingSettings._();
  @$core.override
  MeetingSettings createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MeetingSettings getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MeetingSettings>(create);
  static MeetingSettings? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get muteOnEntry => $_getBF(0);
  @$pb.TagNumber(1)
  set muteOnEntry($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMuteOnEntry() => $_has(0);
  @$pb.TagNumber(1)
  void clearMuteOnEntry() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get allowScreenShare => $_getBF(1);
  @$pb.TagNumber(2)
  set allowScreenShare($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAllowScreenShare() => $_has(1);
  @$pb.TagNumber(2)
  void clearAllowScreenShare() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get recordEnabled => $_getBF(2);
  @$pb.TagNumber(3)
  set recordEnabled($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRecordEnabled() => $_has(2);
  @$pb.TagNumber(3)
  void clearRecordEnabled() => $_clearField(3);
}

class MeetingMember extends $pb.GeneratedMessage {
  factory MeetingMember({
    $fixnum.Int64? userId,
    $core.int? role,
    $core.int? status,
    $fixnum.Int64? joinedAt,
    $fixnum.Int64? leftAt,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (role != null) result.role = role;
    if (status != null) result.status = status;
    if (joinedAt != null) result.joinedAt = joinedAt;
    if (leftAt != null) result.leftAt = leftAt;
    return result;
  }

  MeetingMember._();

  factory MeetingMember.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MeetingMember.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MeetingMember',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aI(2, _omitFieldNames ? '' : 'role')
    ..aI(3, _omitFieldNames ? '' : 'status')
    ..aInt64(4, _omitFieldNames ? '' : 'joinedAt')
    ..aInt64(5, _omitFieldNames ? '' : 'leftAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeetingMember clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeetingMember copyWith(void Function(MeetingMember) updates) =>
      super.copyWith((message) => updates(message as MeetingMember))
          as MeetingMember;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MeetingMember create() => MeetingMember._();
  @$core.override
  MeetingMember createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MeetingMember getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MeetingMember>(create);
  static MeetingMember? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get role => $_getIZ(1);
  @$pb.TagNumber(2)
  set role($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRole() => $_has(1);
  @$pb.TagNumber(2)
  void clearRole() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get status => $_getIZ(2);
  @$pb.TagNumber(3)
  set status($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get joinedAt => $_getI64(3);
  @$pb.TagNumber(4)
  set joinedAt($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasJoinedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearJoinedAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get leftAt => $_getI64(4);
  @$pb.TagNumber(5)
  set leftAt($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLeftAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearLeftAt() => $_clearField(5);
}

class MeetingInfo extends $pb.GeneratedMessage {
  factory MeetingInfo({
    $core.String? roomId,
    $fixnum.Int64? hostId,
    $core.Iterable<$fixnum.Int64>? memberIds,
    $core.String? title,
    $fixnum.Int64? createdAt,
    $core.String? password,
    MeetingStatus? status,
    $fixnum.Int64? id,
    $fixnum.Int64? scheduledAt,
    $fixnum.Int64? startedAt,
    $fixnum.Int64? endedAt,
    $fixnum.Int64? tenantId,
    $core.Iterable<MeetingMember>? members,
    MeetingSettings? settings,
    $core.int? maxParticipants,
  }) {
    final result = create();
    if (roomId != null) result.roomId = roomId;
    if (hostId != null) result.hostId = hostId;
    if (memberIds != null) result.memberIds.addAll(memberIds);
    if (title != null) result.title = title;
    if (createdAt != null) result.createdAt = createdAt;
    if (password != null) result.password = password;
    if (status != null) result.status = status;
    if (id != null) result.id = id;
    if (scheduledAt != null) result.scheduledAt = scheduledAt;
    if (startedAt != null) result.startedAt = startedAt;
    if (endedAt != null) result.endedAt = endedAt;
    if (tenantId != null) result.tenantId = tenantId;
    if (members != null) result.members.addAll(members);
    if (settings != null) result.settings = settings;
    if (maxParticipants != null) result.maxParticipants = maxParticipants;
    return result;
  }

  MeetingInfo._();

  factory MeetingInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MeetingInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MeetingInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..aInt64(2, _omitFieldNames ? '' : 'hostId')
    ..p<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'memberIds', $pb.PbFieldType.K6)
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aInt64(5, _omitFieldNames ? '' : 'createdAt')
    ..aOS(6, _omitFieldNames ? '' : 'password')
    ..aE<MeetingStatus>(7, _omitFieldNames ? '' : 'status',
        enumValues: MeetingStatus.values)
    ..aInt64(8, _omitFieldNames ? '' : 'id')
    ..aInt64(9, _omitFieldNames ? '' : 'scheduledAt')
    ..aInt64(10, _omitFieldNames ? '' : 'startedAt')
    ..aInt64(11, _omitFieldNames ? '' : 'endedAt')
    ..aInt64(12, _omitFieldNames ? '' : 'tenantId')
    ..pPM<MeetingMember>(13, _omitFieldNames ? '' : 'members',
        subBuilder: MeetingMember.create)
    ..aOM<MeetingSettings>(14, _omitFieldNames ? '' : 'settings',
        subBuilder: MeetingSettings.create)
    ..aI(15, _omitFieldNames ? '' : 'maxParticipants')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeetingInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeetingInfo copyWith(void Function(MeetingInfo) updates) =>
      super.copyWith((message) => updates(message as MeetingInfo))
          as MeetingInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MeetingInfo create() => MeetingInfo._();
  @$core.override
  MeetingInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MeetingInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MeetingInfo>(create);
  static MeetingInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get hostId => $_getI64(1);
  @$pb.TagNumber(2)
  set hostId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHostId() => $_has(1);
  @$pb.TagNumber(2)
  void clearHostId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$fixnum.Int64> get memberIds => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get title => $_getSZ(3);
  @$pb.TagNumber(4)
  set title($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTitle() => $_has(3);
  @$pb.TagNumber(4)
  void clearTitle() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get createdAt => $_getI64(4);
  @$pb.TagNumber(5)
  set createdAt($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get password => $_getSZ(5);
  @$pb.TagNumber(6)
  set password($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPassword() => $_has(5);
  @$pb.TagNumber(6)
  void clearPassword() => $_clearField(6);

  @$pb.TagNumber(7)
  MeetingStatus get status => $_getN(6);
  @$pb.TagNumber(7)
  set status(MeetingStatus value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  /// M3 additions
  @$pb.TagNumber(8)
  $fixnum.Int64 get id => $_getI64(7);
  @$pb.TagNumber(8)
  set id($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasId() => $_has(7);
  @$pb.TagNumber(8)
  void clearId() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get scheduledAt => $_getI64(8);
  @$pb.TagNumber(9)
  set scheduledAt($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasScheduledAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearScheduledAt() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get startedAt => $_getI64(9);
  @$pb.TagNumber(10)
  set startedAt($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasStartedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearStartedAt() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get endedAt => $_getI64(10);
  @$pb.TagNumber(11)
  set endedAt($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasEndedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearEndedAt() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get tenantId => $_getI64(11);
  @$pb.TagNumber(12)
  set tenantId($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasTenantId() => $_has(11);
  @$pb.TagNumber(12)
  void clearTenantId() => $_clearField(12);

  @$pb.TagNumber(13)
  $pb.PbList<MeetingMember> get members => $_getList(12);

  @$pb.TagNumber(14)
  MeetingSettings get settings => $_getN(13);
  @$pb.TagNumber(14)
  set settings(MeetingSettings value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasSettings() => $_has(13);
  @$pb.TagNumber(14)
  void clearSettings() => $_clearField(14);
  @$pb.TagNumber(14)
  MeetingSettings ensureSettings() => $_ensure(13);

  @$pb.TagNumber(15)
  $core.int get maxParticipants => $_getIZ(14);
  @$pb.TagNumber(15)
  set maxParticipants($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasMaxParticipants() => $_has(14);
  @$pb.TagNumber(15)
  void clearMaxParticipants() => $_clearField(15);
}

class MeetingCreateRequest extends $pb.GeneratedMessage {
  factory MeetingCreateRequest({
    $core.String? title,
    $core.String? password,
    $fixnum.Int64? scheduledAt,
    $core.int? maxParticipants,
    MeetingSettings? settings,
  }) {
    final result = create();
    if (title != null) result.title = title;
    if (password != null) result.password = password;
    if (scheduledAt != null) result.scheduledAt = scheduledAt;
    if (maxParticipants != null) result.maxParticipants = maxParticipants;
    if (settings != null) result.settings = settings;
    return result;
  }

  MeetingCreateRequest._();

  factory MeetingCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MeetingCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MeetingCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..aInt64(3, _omitFieldNames ? '' : 'scheduledAt')
    ..aI(4, _omitFieldNames ? '' : 'maxParticipants')
    ..aOM<MeetingSettings>(5, _omitFieldNames ? '' : 'settings',
        subBuilder: MeetingSettings.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeetingCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeetingCreateRequest copyWith(void Function(MeetingCreateRequest) updates) =>
      super.copyWith((message) => updates(message as MeetingCreateRequest))
          as MeetingCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MeetingCreateRequest create() => MeetingCreateRequest._();
  @$core.override
  MeetingCreateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MeetingCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MeetingCreateRequest>(create);
  static MeetingCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get scheduledAt => $_getI64(2);
  @$pb.TagNumber(3)
  set scheduledAt($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScheduledAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearScheduledAt() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get maxParticipants => $_getIZ(3);
  @$pb.TagNumber(4)
  set maxParticipants($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMaxParticipants() => $_has(3);
  @$pb.TagNumber(4)
  void clearMaxParticipants() => $_clearField(4);

  @$pb.TagNumber(5)
  MeetingSettings get settings => $_getN(4);
  @$pb.TagNumber(5)
  set settings(MeetingSettings value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSettings() => $_has(4);
  @$pb.TagNumber(5)
  void clearSettings() => $_clearField(5);
  @$pb.TagNumber(5)
  MeetingSettings ensureSettings() => $_ensure(4);
}

class MeetingCreateResponse extends $pb.GeneratedMessage {
  factory MeetingCreateResponse({
    MeetingInfo? meeting,
  }) {
    final result = create();
    if (meeting != null) result.meeting = meeting;
    return result;
  }

  MeetingCreateResponse._();

  factory MeetingCreateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MeetingCreateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MeetingCreateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..aOM<MeetingInfo>(1, _omitFieldNames ? '' : 'meeting',
        subBuilder: MeetingInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeetingCreateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeetingCreateResponse copyWith(
          void Function(MeetingCreateResponse) updates) =>
      super.copyWith((message) => updates(message as MeetingCreateResponse))
          as MeetingCreateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MeetingCreateResponse create() => MeetingCreateResponse._();
  @$core.override
  MeetingCreateResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MeetingCreateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MeetingCreateResponse>(create);
  static MeetingCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MeetingInfo get meeting => $_getN(0);
  @$pb.TagNumber(1)
  set meeting(MeetingInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMeeting() => $_has(0);
  @$pb.TagNumber(1)
  void clearMeeting() => $_clearField(1);
  @$pb.TagNumber(1)
  MeetingInfo ensureMeeting() => $_ensure(0);
}

class MeetingGetListRequest extends $pb.GeneratedMessage {
  factory MeetingGetListRequest({
    MeetingListFilter? filter,
    $core.int? page,
    $core.int? pageSize,
  }) {
    final result = create();
    if (filter != null) result.filter = filter;
    if (page != null) result.page = page;
    if (pageSize != null) result.pageSize = pageSize;
    return result;
  }

  MeetingGetListRequest._();

  factory MeetingGetListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MeetingGetListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MeetingGetListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..aE<MeetingListFilter>(1, _omitFieldNames ? '' : 'filter',
        enumValues: MeetingListFilter.values)
    ..aI(2, _omitFieldNames ? '' : 'page')
    ..aI(3, _omitFieldNames ? '' : 'pageSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeetingGetListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeetingGetListRequest copyWith(
          void Function(MeetingGetListRequest) updates) =>
      super.copyWith((message) => updates(message as MeetingGetListRequest))
          as MeetingGetListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MeetingGetListRequest create() => MeetingGetListRequest._();
  @$core.override
  MeetingGetListRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MeetingGetListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MeetingGetListRequest>(create);
  static MeetingGetListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  MeetingListFilter get filter => $_getN(0);
  @$pb.TagNumber(1)
  set filter(MeetingListFilter value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFilter() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilter() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get page => $_getIZ(1);
  @$pb.TagNumber(2)
  set page($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearPage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get pageSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageSize($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageSize() => $_clearField(3);
}

class MeetingGetListResponse extends $pb.GeneratedMessage {
  factory MeetingGetListResponse({
    $core.Iterable<MeetingInfo>? meetings,
    $core.int? total,
  }) {
    final result = create();
    if (meetings != null) result.meetings.addAll(meetings);
    if (total != null) result.total = total;
    return result;
  }

  MeetingGetListResponse._();

  factory MeetingGetListResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MeetingGetListResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MeetingGetListResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..pPM<MeetingInfo>(1, _omitFieldNames ? '' : 'meetings',
        subBuilder: MeetingInfo.create)
    ..aI(2, _omitFieldNames ? '' : 'total')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeetingGetListResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeetingGetListResponse copyWith(
          void Function(MeetingGetListResponse) updates) =>
      super.copyWith((message) => updates(message as MeetingGetListResponse))
          as MeetingGetListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MeetingGetListResponse create() => MeetingGetListResponse._();
  @$core.override
  MeetingGetListResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MeetingGetListResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MeetingGetListResponse>(create);
  static MeetingGetListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<MeetingInfo> get meetings => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2)
  set total($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);
}

class MeetingPushUpdate extends $pb.GeneratedMessage {
  factory MeetingPushUpdate({
    MeetingInfo? meeting,
    MeetingPushAction? action,
  }) {
    final result = create();
    if (meeting != null) result.meeting = meeting;
    if (action != null) result.action = action;
    return result;
  }

  MeetingPushUpdate._();

  factory MeetingPushUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MeetingPushUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MeetingPushUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..aOM<MeetingInfo>(1, _omitFieldNames ? '' : 'meeting',
        subBuilder: MeetingInfo.create)
    ..aE<MeetingPushAction>(2, _omitFieldNames ? '' : 'action',
        enumValues: MeetingPushAction.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeetingPushUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeetingPushUpdate copyWith(void Function(MeetingPushUpdate) updates) =>
      super.copyWith((message) => updates(message as MeetingPushUpdate))
          as MeetingPushUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MeetingPushUpdate create() => MeetingPushUpdate._();
  @$core.override
  MeetingPushUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MeetingPushUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MeetingPushUpdate>(create);
  static MeetingPushUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  MeetingInfo get meeting => $_getN(0);
  @$pb.TagNumber(1)
  set meeting(MeetingInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMeeting() => $_has(0);
  @$pb.TagNumber(1)
  void clearMeeting() => $_clearField(1);
  @$pb.TagNumber(1)
  MeetingInfo ensureMeeting() => $_ensure(0);

  @$pb.TagNumber(2)
  MeetingPushAction get action => $_getN(1);
  @$pb.TagNumber(2)
  set action(MeetingPushAction value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAction() => $_has(1);
  @$pb.TagNumber(2)
  void clearAction() => $_clearField(2);
}

class MeetingInvite extends $pb.GeneratedMessage {
  factory MeetingInvite({
    $core.String? roomId,
    $fixnum.Int64? meetingId,
    $core.String? title,
    $fixnum.Int64? hostId,
    $core.String? hostName,
  }) {
    final result = create();
    if (roomId != null) result.roomId = roomId;
    if (meetingId != null) result.meetingId = meetingId;
    if (title != null) result.title = title;
    if (hostId != null) result.hostId = hostId;
    if (hostName != null) result.hostName = hostName;
    return result;
  }

  MeetingInvite._();

  factory MeetingInvite.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MeetingInvite.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MeetingInvite',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..aInt64(2, _omitFieldNames ? '' : 'meetingId')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aInt64(4, _omitFieldNames ? '' : 'hostId')
    ..aOS(5, _omitFieldNames ? '' : 'hostName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeetingInvite clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeetingInvite copyWith(void Function(MeetingInvite) updates) =>
      super.copyWith((message) => updates(message as MeetingInvite))
          as MeetingInvite;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MeetingInvite create() => MeetingInvite._();
  @$core.override
  MeetingInvite createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MeetingInvite getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MeetingInvite>(create);
  static MeetingInvite? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get meetingId => $_getI64(1);
  @$pb.TagNumber(2)
  set meetingId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMeetingId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMeetingId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get hostId => $_getI64(3);
  @$pb.TagNumber(4)
  set hostId($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHostId() => $_has(3);
  @$pb.TagNumber(4)
  void clearHostId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get hostName => $_getSZ(4);
  @$pb.TagNumber(5)
  set hostName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHostName() => $_has(4);
  @$pb.TagNumber(5)
  void clearHostName() => $_clearField(5);
}

class JoinMeetingRequest extends $pb.GeneratedMessage {
  factory JoinMeetingRequest({
    $core.String? roomId,
    $core.String? password,
  }) {
    final result = create();
    if (roomId != null) result.roomId = roomId;
    if (password != null) result.password = password;
    return result;
  }

  JoinMeetingRequest._();

  factory JoinMeetingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JoinMeetingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinMeetingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinMeetingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinMeetingRequest copyWith(void Function(JoinMeetingRequest) updates) =>
      super.copyWith((message) => updates(message as JoinMeetingRequest))
          as JoinMeetingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinMeetingRequest create() => JoinMeetingRequest._();
  @$core.override
  JoinMeetingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static JoinMeetingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JoinMeetingRequest>(create);
  static JoinMeetingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);
}

class JoinMeetingResponse extends $pb.GeneratedMessage {
  factory JoinMeetingResponse({
    MeetingInfo? meeting,
  }) {
    final result = create();
    if (meeting != null) result.meeting = meeting;
    return result;
  }

  JoinMeetingResponse._();

  factory JoinMeetingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JoinMeetingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinMeetingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..aOM<MeetingInfo>(1, _omitFieldNames ? '' : 'meeting',
        subBuilder: MeetingInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinMeetingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinMeetingResponse copyWith(void Function(JoinMeetingResponse) updates) =>
      super.copyWith((message) => updates(message as JoinMeetingResponse))
          as JoinMeetingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinMeetingResponse create() => JoinMeetingResponse._();
  @$core.override
  JoinMeetingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static JoinMeetingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JoinMeetingResponse>(create);
  static JoinMeetingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MeetingInfo get meeting => $_getN(0);
  @$pb.TagNumber(1)
  set meeting(MeetingInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMeeting() => $_has(0);
  @$pb.TagNumber(1)
  void clearMeeting() => $_clearField(1);
  @$pb.TagNumber(1)
  MeetingInfo ensureMeeting() => $_ensure(0);
}

class LeaveMeetingRequest extends $pb.GeneratedMessage {
  factory LeaveMeetingRequest({
    $core.String? roomId,
  }) {
    final result = create();
    if (roomId != null) result.roomId = roomId;
    return result;
  }

  LeaveMeetingRequest._();

  factory LeaveMeetingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LeaveMeetingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LeaveMeetingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaveMeetingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaveMeetingRequest copyWith(void Function(LeaveMeetingRequest) updates) =>
      super.copyWith((message) => updates(message as LeaveMeetingRequest))
          as LeaveMeetingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeaveMeetingRequest create() => LeaveMeetingRequest._();
  @$core.override
  LeaveMeetingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LeaveMeetingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LeaveMeetingRequest>(create);
  static LeaveMeetingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => $_clearField(1);
}

class LeaveMeetingResponse extends $pb.GeneratedMessage {
  factory LeaveMeetingResponse() => create();

  LeaveMeetingResponse._();

  factory LeaveMeetingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LeaveMeetingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LeaveMeetingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaveMeetingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaveMeetingResponse copyWith(void Function(LeaveMeetingResponse) updates) =>
      super.copyWith((message) => updates(message as LeaveMeetingResponse))
          as LeaveMeetingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeaveMeetingResponse create() => LeaveMeetingResponse._();
  @$core.override
  LeaveMeetingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LeaveMeetingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LeaveMeetingResponse>(create);
  static LeaveMeetingResponse? _defaultInstance;
}

class EndMeetingRequest extends $pb.GeneratedMessage {
  factory EndMeetingRequest({
    $core.String? roomId,
  }) {
    final result = create();
    if (roomId != null) result.roomId = roomId;
    return result;
  }

  EndMeetingRequest._();

  factory EndMeetingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EndMeetingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EndMeetingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EndMeetingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EndMeetingRequest copyWith(void Function(EndMeetingRequest) updates) =>
      super.copyWith((message) => updates(message as EndMeetingRequest))
          as EndMeetingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EndMeetingRequest create() => EndMeetingRequest._();
  @$core.override
  EndMeetingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EndMeetingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EndMeetingRequest>(create);
  static EndMeetingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => $_clearField(1);
}

class EndMeetingResponse extends $pb.GeneratedMessage {
  factory EndMeetingResponse() => create();

  EndMeetingResponse._();

  factory EndMeetingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EndMeetingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EndMeetingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EndMeetingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EndMeetingResponse copyWith(void Function(EndMeetingResponse) updates) =>
      super.copyWith((message) => updates(message as EndMeetingResponse))
          as EndMeetingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EndMeetingResponse create() => EndMeetingResponse._();
  @$core.override
  EndMeetingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EndMeetingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EndMeetingResponse>(create);
  static EndMeetingResponse? _defaultInstance;
}

class GetMeetingInfoRequest extends $pb.GeneratedMessage {
  factory GetMeetingInfoRequest({
    $core.String? roomId,
  }) {
    final result = create();
    if (roomId != null) result.roomId = roomId;
    return result;
  }

  GetMeetingInfoRequest._();

  factory GetMeetingInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMeetingInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMeetingInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMeetingInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMeetingInfoRequest copyWith(
          void Function(GetMeetingInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetMeetingInfoRequest))
          as GetMeetingInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMeetingInfoRequest create() => GetMeetingInfoRequest._();
  @$core.override
  GetMeetingInfoRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMeetingInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMeetingInfoRequest>(create);
  static GetMeetingInfoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => $_clearField(1);
}

class GetMeetingInfoResponse extends $pb.GeneratedMessage {
  factory GetMeetingInfoResponse({
    MeetingInfo? meeting,
  }) {
    final result = create();
    if (meeting != null) result.meeting = meeting;
    return result;
  }

  GetMeetingInfoResponse._();

  factory GetMeetingInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMeetingInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMeetingInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..aOM<MeetingInfo>(1, _omitFieldNames ? '' : 'meeting',
        subBuilder: MeetingInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMeetingInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMeetingInfoResponse copyWith(
          void Function(GetMeetingInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetMeetingInfoResponse))
          as GetMeetingInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMeetingInfoResponse create() => GetMeetingInfoResponse._();
  @$core.override
  GetMeetingInfoResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMeetingInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMeetingInfoResponse>(create);
  static GetMeetingInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MeetingInfo get meeting => $_getN(0);
  @$pb.TagNumber(1)
  set meeting(MeetingInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMeeting() => $_has(0);
  @$pb.TagNumber(1)
  void clearMeeting() => $_clearField(1);
  @$pb.TagNumber(1)
  MeetingInfo ensureMeeting() => $_ensure(0);
}

class KickMeetingRequest extends $pb.GeneratedMessage {
  factory KickMeetingRequest({
    $core.String? roomId,
    $fixnum.Int64? targetId,
  }) {
    final result = create();
    if (roomId != null) result.roomId = roomId;
    if (targetId != null) result.targetId = targetId;
    return result;
  }

  KickMeetingRequest._();

  factory KickMeetingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory KickMeetingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'KickMeetingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..aInt64(2, _omitFieldNames ? '' : 'targetId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KickMeetingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KickMeetingRequest copyWith(void Function(KickMeetingRequest) updates) =>
      super.copyWith((message) => updates(message as KickMeetingRequest))
          as KickMeetingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KickMeetingRequest create() => KickMeetingRequest._();
  @$core.override
  KickMeetingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static KickMeetingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<KickMeetingRequest>(create);
  static KickMeetingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get targetId => $_getI64(1);
  @$pb.TagNumber(2)
  set targetId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTargetId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetId() => $_clearField(2);
}

class KickMeetingResponse extends $pb.GeneratedMessage {
  factory KickMeetingResponse() => create();

  KickMeetingResponse._();

  factory KickMeetingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory KickMeetingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'KickMeetingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KickMeetingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KickMeetingResponse copyWith(void Function(KickMeetingResponse) updates) =>
      super.copyWith((message) => updates(message as KickMeetingResponse))
          as KickMeetingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KickMeetingResponse create() => KickMeetingResponse._();
  @$core.override
  KickMeetingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static KickMeetingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<KickMeetingResponse>(create);
  static KickMeetingResponse? _defaultInstance;
}

class SetRoleRequest extends $pb.GeneratedMessage {
  factory SetRoleRequest({
    $core.String? roomId,
    $fixnum.Int64? targetId,
    $core.int? role,
  }) {
    final result = create();
    if (roomId != null) result.roomId = roomId;
    if (targetId != null) result.targetId = targetId;
    if (role != null) result.role = role;
    return result;
  }

  SetRoleRequest._();

  factory SetRoleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetRoleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetRoleRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..aInt64(2, _omitFieldNames ? '' : 'targetId')
    ..aI(3, _omitFieldNames ? '' : 'role')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetRoleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetRoleRequest copyWith(void Function(SetRoleRequest) updates) =>
      super.copyWith((message) => updates(message as SetRoleRequest))
          as SetRoleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetRoleRequest create() => SetRoleRequest._();
  @$core.override
  SetRoleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetRoleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetRoleRequest>(create);
  static SetRoleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get targetId => $_getI64(1);
  @$pb.TagNumber(2)
  set targetId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTargetId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get role => $_getIZ(2);
  @$pb.TagNumber(3)
  set role($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRole() => $_has(2);
  @$pb.TagNumber(3)
  void clearRole() => $_clearField(3);
}

class SetRoleResponse extends $pb.GeneratedMessage {
  factory SetRoleResponse() => create();

  SetRoleResponse._();

  factory SetRoleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetRoleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetRoleResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetRoleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetRoleResponse copyWith(void Function(SetRoleResponse) updates) =>
      super.copyWith((message) => updates(message as SetRoleResponse))
          as SetRoleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetRoleResponse create() => SetRoleResponse._();
  @$core.override
  SetRoleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetRoleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetRoleResponse>(create);
  static SetRoleResponse? _defaultInstance;
}

class InviteMeetingRequest extends $pb.GeneratedMessage {
  factory InviteMeetingRequest({
    $core.String? roomId,
    $core.Iterable<$fixnum.Int64>? targetIds,
  }) {
    final result = create();
    if (roomId != null) result.roomId = roomId;
    if (targetIds != null) result.targetIds.addAll(targetIds);
    return result;
  }

  InviteMeetingRequest._();

  factory InviteMeetingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InviteMeetingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InviteMeetingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roomId')
    ..p<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'targetIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteMeetingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteMeetingRequest copyWith(void Function(InviteMeetingRequest) updates) =>
      super.copyWith((message) => updates(message as InviteMeetingRequest))
          as InviteMeetingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InviteMeetingRequest create() => InviteMeetingRequest._();
  @$core.override
  InviteMeetingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InviteMeetingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InviteMeetingRequest>(create);
  static InviteMeetingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roomId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roomId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$fixnum.Int64> get targetIds => $_getList(1);
}

class InviteMeetingResponse extends $pb.GeneratedMessage {
  factory InviteMeetingResponse() => create();

  InviteMeetingResponse._();

  factory InviteMeetingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InviteMeetingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InviteMeetingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meeting'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteMeetingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteMeetingResponse copyWith(
          void Function(InviteMeetingResponse) updates) =>
      super.copyWith((message) => updates(message as InviteMeetingResponse))
          as InviteMeetingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InviteMeetingResponse create() => InviteMeetingResponse._();
  @$core.override
  InviteMeetingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InviteMeetingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InviteMeetingResponse>(create);
  static InviteMeetingResponse? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
