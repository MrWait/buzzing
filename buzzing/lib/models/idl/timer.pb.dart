// This is a generated file - do not edit.
//
// Generated from timer.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class ScheduleMessageRequest extends $pb.GeneratedMessage {
  factory ScheduleMessageRequest({
    $fixnum.Int64? chatId,
    $fixnum.Int64? sendAtMs,
    $core.int? tpy,
    $core.List<$core.int>? content,
    $fixnum.Int64? clientId,
    $fixnum.Int64? atUserId,
    $core.Iterable<$fixnum.Int64>? atUserIds,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (sendAtMs != null) result.sendAtMs = sendAtMs;
    if (tpy != null) result.tpy = tpy;
    if (content != null) result.content = content;
    if (clientId != null) result.clientId = clientId;
    if (atUserId != null) result.atUserId = atUserId;
    if (atUserIds != null) result.atUserIds.addAll(atUserIds);
    return result;
  }

  ScheduleMessageRequest._();

  factory ScheduleMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScheduleMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScheduleMessageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'timer'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..aInt64(2, _omitFieldNames ? '' : 'sendAtMs')
    ..aI(3, _omitFieldNames ? '' : 'tpy')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aInt64(5, _omitFieldNames ? '' : 'clientId')
    ..aInt64(6, _omitFieldNames ? '' : 'atUserId')
    ..p<$fixnum.Int64>(
        7, _omitFieldNames ? '' : 'atUserIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleMessageRequest copyWith(
          void Function(ScheduleMessageRequest) updates) =>
      super.copyWith((message) => updates(message as ScheduleMessageRequest))
          as ScheduleMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScheduleMessageRequest create() => ScheduleMessageRequest._();
  @$core.override
  ScheduleMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScheduleMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScheduleMessageRequest>(create);
  static ScheduleMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get sendAtMs => $_getI64(1);
  @$pb.TagNumber(2)
  set sendAtMs($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSendAtMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearSendAtMs() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get tpy => $_getIZ(2);
  @$pb.TagNumber(3)
  set tpy($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTpy() => $_has(2);
  @$pb.TagNumber(3)
  void clearTpy() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get content => $_getN(3);
  @$pb.TagNumber(4)
  set content($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasContent() => $_has(3);
  @$pb.TagNumber(4)
  void clearContent() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get clientId => $_getI64(4);
  @$pb.TagNumber(5)
  set clientId($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasClientId() => $_has(4);
  @$pb.TagNumber(5)
  void clearClientId() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get atUserId => $_getI64(5);
  @$pb.TagNumber(6)
  set atUserId($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAtUserId() => $_has(5);
  @$pb.TagNumber(6)
  void clearAtUserId() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$fixnum.Int64> get atUserIds => $_getList(6);
}

class ScheduleMessageResponse extends $pb.GeneratedMessage {
  factory ScheduleMessageResponse({
    $fixnum.Int64? scheduleId,
    $fixnum.Int64? scheduleAtMs,
  }) {
    final result = create();
    if (scheduleId != null) result.scheduleId = scheduleId;
    if (scheduleAtMs != null) result.scheduleAtMs = scheduleAtMs;
    return result;
  }

  ScheduleMessageResponse._();

  factory ScheduleMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScheduleMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScheduleMessageResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'timer'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'scheduleId')
    ..aInt64(2, _omitFieldNames ? '' : 'scheduleAtMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleMessageResponse copyWith(
          void Function(ScheduleMessageResponse) updates) =>
      super.copyWith((message) => updates(message as ScheduleMessageResponse))
          as ScheduleMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScheduleMessageResponse create() => ScheduleMessageResponse._();
  @$core.override
  ScheduleMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScheduleMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScheduleMessageResponse>(create);
  static ScheduleMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get scheduleId => $_getI64(0);
  @$pb.TagNumber(1)
  set scheduleId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasScheduleId() => $_has(0);
  @$pb.TagNumber(1)
  void clearScheduleId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get scheduleAtMs => $_getI64(1);
  @$pb.TagNumber(2)
  set scheduleAtMs($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasScheduleAtMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearScheduleAtMs() => $_clearField(2);
}

class CancelScheduleRequest extends $pb.GeneratedMessage {
  factory CancelScheduleRequest({
    $fixnum.Int64? scheduleId,
  }) {
    final result = create();
    if (scheduleId != null) result.scheduleId = scheduleId;
    return result;
  }

  CancelScheduleRequest._();

  factory CancelScheduleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CancelScheduleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CancelScheduleRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'timer'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'scheduleId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelScheduleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelScheduleRequest copyWith(
          void Function(CancelScheduleRequest) updates) =>
      super.copyWith((message) => updates(message as CancelScheduleRequest))
          as CancelScheduleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CancelScheduleRequest create() => CancelScheduleRequest._();
  @$core.override
  CancelScheduleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CancelScheduleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelScheduleRequest>(create);
  static CancelScheduleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get scheduleId => $_getI64(0);
  @$pb.TagNumber(1)
  set scheduleId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasScheduleId() => $_has(0);
  @$pb.TagNumber(1)
  void clearScheduleId() => $_clearField(1);
}

class CancelScheduleResponse extends $pb.GeneratedMessage {
  factory CancelScheduleResponse() => create();

  CancelScheduleResponse._();

  factory CancelScheduleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CancelScheduleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CancelScheduleResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'timer'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelScheduleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelScheduleResponse copyWith(
          void Function(CancelScheduleResponse) updates) =>
      super.copyWith((message) => updates(message as CancelScheduleResponse))
          as CancelScheduleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CancelScheduleResponse create() => CancelScheduleResponse._();
  @$core.override
  CancelScheduleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CancelScheduleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelScheduleResponse>(create);
  static CancelScheduleResponse? _defaultInstance;
}

class GetScheduledMessagesRequest extends $pb.GeneratedMessage {
  factory GetScheduledMessagesRequest({
    $core.int? page,
    $core.int? pageSize,
  }) {
    final result = create();
    if (page != null) result.page = page;
    if (pageSize != null) result.pageSize = pageSize;
    return result;
  }

  GetScheduledMessagesRequest._();

  factory GetScheduledMessagesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetScheduledMessagesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetScheduledMessagesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'timer'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'page')
    ..aI(2, _omitFieldNames ? '' : 'pageSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetScheduledMessagesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetScheduledMessagesRequest copyWith(
          void Function(GetScheduledMessagesRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetScheduledMessagesRequest))
          as GetScheduledMessagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetScheduledMessagesRequest create() =>
      GetScheduledMessagesRequest._();
  @$core.override
  GetScheduledMessagesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetScheduledMessagesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetScheduledMessagesRequest>(create);
  static GetScheduledMessagesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get page => $_getIZ(0);
  @$pb.TagNumber(1)
  set page($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPage() => $_has(0);
  @$pb.TagNumber(1)
  void clearPage() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageSize() => $_clearField(2);
}

class GetScheduledMessagesResponse extends $pb.GeneratedMessage {
  factory GetScheduledMessagesResponse({
    $core.Iterable<ScheduledMessage>? messages,
    $core.int? total,
  }) {
    final result = create();
    if (messages != null) result.messages.addAll(messages);
    if (total != null) result.total = total;
    return result;
  }

  GetScheduledMessagesResponse._();

  factory GetScheduledMessagesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetScheduledMessagesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetScheduledMessagesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'timer'),
      createEmptyInstance: create)
    ..pPM<ScheduledMessage>(1, _omitFieldNames ? '' : 'messages',
        subBuilder: ScheduledMessage.create)
    ..aI(2, _omitFieldNames ? '' : 'total')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetScheduledMessagesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetScheduledMessagesResponse copyWith(
          void Function(GetScheduledMessagesResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetScheduledMessagesResponse))
          as GetScheduledMessagesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetScheduledMessagesResponse create() =>
      GetScheduledMessagesResponse._();
  @$core.override
  GetScheduledMessagesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetScheduledMessagesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetScheduledMessagesResponse>(create);
  static GetScheduledMessagesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ScheduledMessage> get messages => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2)
  set total($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);
}

class ScheduledMessage extends $pb.GeneratedMessage {
  factory ScheduledMessage({
    $fixnum.Int64? id,
    $fixnum.Int64? chatId,
    $fixnum.Int64? sendAtMs,
    $core.int? tpy,
    $core.List<$core.int>? content,
    $core.int? status,
    $fixnum.Int64? createdAtMs,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (chatId != null) result.chatId = chatId;
    if (sendAtMs != null) result.sendAtMs = sendAtMs;
    if (tpy != null) result.tpy = tpy;
    if (content != null) result.content = content;
    if (status != null) result.status = status;
    if (createdAtMs != null) result.createdAtMs = createdAtMs;
    return result;
  }

  ScheduledMessage._();

  factory ScheduledMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScheduledMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScheduledMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'timer'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'chatId')
    ..aInt64(3, _omitFieldNames ? '' : 'sendAtMs')
    ..aI(4, _omitFieldNames ? '' : 'tpy')
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aI(6, _omitFieldNames ? '' : 'status')
    ..aInt64(7, _omitFieldNames ? '' : 'createdAtMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduledMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduledMessage copyWith(void Function(ScheduledMessage) updates) =>
      super.copyWith((message) => updates(message as ScheduledMessage))
          as ScheduledMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScheduledMessage create() => ScheduledMessage._();
  @$core.override
  ScheduledMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScheduledMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScheduledMessage>(create);
  static ScheduledMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get chatId => $_getI64(1);
  @$pb.TagNumber(2)
  set chatId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChatId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChatId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get sendAtMs => $_getI64(2);
  @$pb.TagNumber(3)
  set sendAtMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSendAtMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearSendAtMs() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get tpy => $_getIZ(3);
  @$pb.TagNumber(4)
  set tpy($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTpy() => $_has(3);
  @$pb.TagNumber(4)
  void clearTpy() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get content => $_getN(4);
  @$pb.TagNumber(5)
  set content($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasContent() => $_has(4);
  @$pb.TagNumber(5)
  void clearContent() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get status => $_getIZ(5);
  @$pb.TagNumber(6)
  set status($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get createdAtMs => $_getI64(6);
  @$pb.TagNumber(7)
  set createdAtMs($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAtMs() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAtMs() => $_clearField(7);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
