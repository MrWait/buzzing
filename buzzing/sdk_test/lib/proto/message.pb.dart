// This is a generated file - do not edit.
//
// Generated from message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'entity.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class CreateMessageDraftRequest extends $pb.GeneratedMessage {
  factory CreateMessageDraftRequest({
    $fixnum.Int64? chatId,
    $0.Message? message,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (message != null) result.message = message;
    return result;
  }

  CreateMessageDraftRequest._();

  factory CreateMessageDraftRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateMessageDraftRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateMessageDraftRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..aOM<$0.Message>(2, _omitFieldNames ? '' : 'message',
        subBuilder: $0.Message.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateMessageDraftRequest clone() =>
      CreateMessageDraftRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateMessageDraftRequest copyWith(
          void Function(CreateMessageDraftRequest) updates) =>
      super.copyWith((message) => updates(message as CreateMessageDraftRequest))
          as CreateMessageDraftRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateMessageDraftRequest create() => CreateMessageDraftRequest._();
  @$core.override
  CreateMessageDraftRequest createEmptyInstance() => create();
  static $pb.PbList<CreateMessageDraftRequest> createRepeated() =>
      $pb.PbList<CreateMessageDraftRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateMessageDraftRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateMessageDraftRequest>(create);
  static CreateMessageDraftRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Message get message => $_getN(1);
  @$pb.TagNumber(2)
  set message($0.Message value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Message ensureMessage() => $_ensure(1);
}

class CreateMessageDraftResponse extends $pb.GeneratedMessage {
  factory CreateMessageDraftResponse({
    $fixnum.Int64? clientId,
  }) {
    final result = create();
    if (clientId != null) result.clientId = clientId;
    return result;
  }

  CreateMessageDraftResponse._();

  factory CreateMessageDraftResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateMessageDraftResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateMessageDraftResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'clientId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateMessageDraftResponse clone() =>
      CreateMessageDraftResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateMessageDraftResponse copyWith(
          void Function(CreateMessageDraftResponse) updates) =>
      super.copyWith(
              (message) => updates(message as CreateMessageDraftResponse))
          as CreateMessageDraftResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateMessageDraftResponse create() => CreateMessageDraftResponse._();
  @$core.override
  CreateMessageDraftResponse createEmptyInstance() => create();
  static $pb.PbList<CreateMessageDraftResponse> createRepeated() =>
      $pb.PbList<CreateMessageDraftResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateMessageDraftResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateMessageDraftResponse>(create);
  static CreateMessageDraftResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get clientId => $_getI64(0);
  @$pb.TagNumber(1)
  set clientId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => $_clearField(1);
}

class SendMessageRequest extends $pb.GeneratedMessage {
  factory SendMessageRequest({
    $fixnum.Int64? clientId,
    $0.Message? message,
  }) {
    final result = create();
    if (clientId != null) result.clientId = clientId;
    if (message != null) result.message = message;
    return result;
  }

  SendMessageRequest._();

  factory SendMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendMessageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'clientId')
    ..aOM<$0.Message>(2, _omitFieldNames ? '' : 'message',
        subBuilder: $0.Message.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageRequest clone() => SendMessageRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageRequest copyWith(void Function(SendMessageRequest) updates) =>
      super.copyWith((message) => updates(message as SendMessageRequest))
          as SendMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendMessageRequest create() => SendMessageRequest._();
  @$core.override
  SendMessageRequest createEmptyInstance() => create();
  static $pb.PbList<SendMessageRequest> createRepeated() =>
      $pb.PbList<SendMessageRequest>();
  @$core.pragma('dart2js:noInline')
  static SendMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendMessageRequest>(create);
  static SendMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get clientId => $_getI64(0);
  @$pb.TagNumber(1)
  set clientId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Message get message => $_getN(1);
  @$pb.TagNumber(2)
  set message($0.Message value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Message ensureMessage() => $_ensure(1);
}

class SendMessageResponse extends $pb.GeneratedMessage {
  factory SendMessageResponse({
    $fixnum.Int64? id,
    $0.Entity? entity,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (entity != null) result.entity = entity;
    return result;
  }

  SendMessageResponse._();

  factory SendMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendMessageResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOM<$0.Entity>(2, _omitFieldNames ? '' : 'entity',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageResponse clone() => SendMessageResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageResponse copyWith(void Function(SendMessageResponse) updates) =>
      super.copyWith((message) => updates(message as SendMessageResponse))
          as SendMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendMessageResponse create() => SendMessageResponse._();
  @$core.override
  SendMessageResponse createEmptyInstance() => create();
  static $pb.PbList<SendMessageResponse> createRepeated() =>
      $pb.PbList<SendMessageResponse>();
  @$core.pragma('dart2js:noInline')
  static SendMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendMessageResponse>(create);
  static SendMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Entity get entity => $_getN(1);
  @$pb.TagNumber(2)
  set entity($0.Entity value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEntity() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntity() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Entity ensureEntity() => $_ensure(1);
}

class GetMessageByRangeRequest extends $pb.GeneratedMessage {
  factory GetMessageByRangeRequest({
    $fixnum.Int64? chatId,
    $core.int? pos,
    $core.int? count,
    $core.int? direct,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (pos != null) result.pos = pos;
    if (count != null) result.count = count;
    if (direct != null) result.direct = direct;
    return result;
  }

  GetMessageByRangeRequest._();

  factory GetMessageByRangeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMessageByRangeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMessageByRangeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'pos', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'count', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'direct', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessageByRangeRequest clone() =>
      GetMessageByRangeRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessageByRangeRequest copyWith(
          void Function(GetMessageByRangeRequest) updates) =>
      super.copyWith((message) => updates(message as GetMessageByRangeRequest))
          as GetMessageByRangeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMessageByRangeRequest create() => GetMessageByRangeRequest._();
  @$core.override
  GetMessageByRangeRequest createEmptyInstance() => create();
  static $pb.PbList<GetMessageByRangeRequest> createRepeated() =>
      $pb.PbList<GetMessageByRangeRequest>();
  @$core.pragma('dart2js:noInline')
  static GetMessageByRangeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMessageByRangeRequest>(create);
  static GetMessageByRangeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get pos => $_getIZ(1);
  @$pb.TagNumber(2)
  set pos($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPos() => $_has(1);
  @$pb.TagNumber(2)
  void clearPos() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get count => $_getIZ(2);
  @$pb.TagNumber(3)
  set count($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get direct => $_getIZ(3);
  @$pb.TagNumber(4)
  set direct($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDirect() => $_has(3);
  @$pb.TagNumber(4)
  void clearDirect() => $_clearField(4);
}

class GetMessageByRangeResponse extends $pb.GeneratedMessage {
  factory GetMessageByRangeResponse({
    $0.Entity? entity,
  }) {
    final result = create();
    if (entity != null) result.entity = entity;
    return result;
  }

  GetMessageByRangeResponse._();

  factory GetMessageByRangeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMessageByRangeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMessageByRangeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aOM<$0.Entity>(1, _omitFieldNames ? '' : 'entity',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessageByRangeResponse clone() =>
      GetMessageByRangeResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessageByRangeResponse copyWith(
          void Function(GetMessageByRangeResponse) updates) =>
      super.copyWith((message) => updates(message as GetMessageByRangeResponse))
          as GetMessageByRangeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMessageByRangeResponse create() => GetMessageByRangeResponse._();
  @$core.override
  GetMessageByRangeResponse createEmptyInstance() => create();
  static $pb.PbList<GetMessageByRangeResponse> createRepeated() =>
      $pb.PbList<GetMessageByRangeResponse>();
  @$core.pragma('dart2js:noInline')
  static GetMessageByRangeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMessageByRangeResponse>(create);
  static GetMessageByRangeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Entity get entity => $_getN(0);
  @$pb.TagNumber(1)
  set entity($0.Entity value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEntity() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntity() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Entity ensureEntity() => $_ensure(0);
}

class GetMessageByPosRequest extends $pb.GeneratedMessage {
  factory GetMessageByPosRequest({
    $fixnum.Int64? chatId,
    $core.Iterable<$core.int>? pos,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (pos != null) result.pos.addAll(pos);
    return result;
  }

  GetMessageByPosRequest._();

  factory GetMessageByPosRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMessageByPosRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMessageByPosRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..p<$core.int>(2, _omitFieldNames ? '' : 'pos', $pb.PbFieldType.K3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessageByPosRequest clone() =>
      GetMessageByPosRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessageByPosRequest copyWith(
          void Function(GetMessageByPosRequest) updates) =>
      super.copyWith((message) => updates(message as GetMessageByPosRequest))
          as GetMessageByPosRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMessageByPosRequest create() => GetMessageByPosRequest._();
  @$core.override
  GetMessageByPosRequest createEmptyInstance() => create();
  static $pb.PbList<GetMessageByPosRequest> createRepeated() =>
      $pb.PbList<GetMessageByPosRequest>();
  @$core.pragma('dart2js:noInline')
  static GetMessageByPosRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMessageByPosRequest>(create);
  static GetMessageByPosRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.int> get pos => $_getList(1);
}

class GetMessageByPosResponse extends $pb.GeneratedMessage {
  factory GetMessageByPosResponse({
    $0.Entity? entity,
  }) {
    final result = create();
    if (entity != null) result.entity = entity;
    return result;
  }

  GetMessageByPosResponse._();

  factory GetMessageByPosResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMessageByPosResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMessageByPosResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aOM<$0.Entity>(1, _omitFieldNames ? '' : 'entity',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessageByPosResponse clone() =>
      GetMessageByPosResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessageByPosResponse copyWith(
          void Function(GetMessageByPosResponse) updates) =>
      super.copyWith((message) => updates(message as GetMessageByPosResponse))
          as GetMessageByPosResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMessageByPosResponse create() => GetMessageByPosResponse._();
  @$core.override
  GetMessageByPosResponse createEmptyInstance() => create();
  static $pb.PbList<GetMessageByPosResponse> createRepeated() =>
      $pb.PbList<GetMessageByPosResponse>();
  @$core.pragma('dart2js:noInline')
  static GetMessageByPosResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMessageByPosResponse>(create);
  static GetMessageByPosResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Entity get entity => $_getN(0);
  @$pb.TagNumber(1)
  set entity($0.Entity value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEntity() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntity() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Entity ensureEntity() => $_ensure(0);
}

class GetMessageByIdsRequest extends $pb.GeneratedMessage {
  factory GetMessageByIdsRequest({
    $core.Iterable<$fixnum.Int64>? ids,
    $core.bool? withFull,
  }) {
    final result = create();
    if (ids != null) result.ids.addAll(ids);
    if (withFull != null) result.withFull = withFull;
    return result;
  }

  GetMessageByIdsRequest._();

  factory GetMessageByIdsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMessageByIdsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMessageByIdsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..p<$fixnum.Int64>(1, _omitFieldNames ? '' : 'ids', $pb.PbFieldType.K6)
    ..aOB(2, _omitFieldNames ? '' : 'withFull')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessageByIdsRequest clone() =>
      GetMessageByIdsRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessageByIdsRequest copyWith(
          void Function(GetMessageByIdsRequest) updates) =>
      super.copyWith((message) => updates(message as GetMessageByIdsRequest))
          as GetMessageByIdsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMessageByIdsRequest create() => GetMessageByIdsRequest._();
  @$core.override
  GetMessageByIdsRequest createEmptyInstance() => create();
  static $pb.PbList<GetMessageByIdsRequest> createRepeated() =>
      $pb.PbList<GetMessageByIdsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetMessageByIdsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMessageByIdsRequest>(create);
  static GetMessageByIdsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$fixnum.Int64> get ids => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get withFull => $_getBF(1);
  @$pb.TagNumber(2)
  set withFull($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWithFull() => $_has(1);
  @$pb.TagNumber(2)
  void clearWithFull() => $_clearField(2);
}

class GetMessageByIdsResponse extends $pb.GeneratedMessage {
  factory GetMessageByIdsResponse({
    $0.Entity? entity,
  }) {
    final result = create();
    if (entity != null) result.entity = entity;
    return result;
  }

  GetMessageByIdsResponse._();

  factory GetMessageByIdsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMessageByIdsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMessageByIdsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aOM<$0.Entity>(1, _omitFieldNames ? '' : 'entity',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessageByIdsResponse clone() =>
      GetMessageByIdsResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessageByIdsResponse copyWith(
          void Function(GetMessageByIdsResponse) updates) =>
      super.copyWith((message) => updates(message as GetMessageByIdsResponse))
          as GetMessageByIdsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMessageByIdsResponse create() => GetMessageByIdsResponse._();
  @$core.override
  GetMessageByIdsResponse createEmptyInstance() => create();
  static $pb.PbList<GetMessageByIdsResponse> createRepeated() =>
      $pb.PbList<GetMessageByIdsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetMessageByIdsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMessageByIdsResponse>(create);
  static GetMessageByIdsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Entity get entity => $_getN(0);
  @$pb.TagNumber(1)
  set entity($0.Entity value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEntity() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntity() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Entity ensureEntity() => $_ensure(0);
}

class PushMessages extends $pb.GeneratedMessage {
  factory PushMessages({
    $0.Entity? entity,
  }) {
    final result = create();
    if (entity != null) result.entity = entity;
    return result;
  }

  PushMessages._();

  factory PushMessages.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushMessages.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushMessages',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aOM<$0.Entity>(1, _omitFieldNames ? '' : 'entity',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushMessages clone() => PushMessages()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushMessages copyWith(void Function(PushMessages) updates) =>
      super.copyWith((message) => updates(message as PushMessages))
          as PushMessages;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushMessages create() => PushMessages._();
  @$core.override
  PushMessages createEmptyInstance() => create();
  static $pb.PbList<PushMessages> createRepeated() =>
      $pb.PbList<PushMessages>();
  @$core.pragma('dart2js:noInline')
  static PushMessages getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushMessages>(create);
  static PushMessages? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Entity get entity => $_getN(0);
  @$pb.TagNumber(1)
  set entity($0.Entity value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEntity() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntity() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Entity ensureEntity() => $_ensure(0);
}

class FavoriteAddRequest extends $pb.GeneratedMessage {
  factory FavoriteAddRequest({
    $0.Favorite? favorite,
  }) {
    final result = create();
    if (favorite != null) result.favorite = favorite;
    return result;
  }

  FavoriteAddRequest._();

  factory FavoriteAddRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FavoriteAddRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FavoriteAddRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aOM<$0.Favorite>(1, _omitFieldNames ? '' : 'favorite',
        subBuilder: $0.Favorite.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FavoriteAddRequest clone() => FavoriteAddRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FavoriteAddRequest copyWith(void Function(FavoriteAddRequest) updates) =>
      super.copyWith((message) => updates(message as FavoriteAddRequest))
          as FavoriteAddRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FavoriteAddRequest create() => FavoriteAddRequest._();
  @$core.override
  FavoriteAddRequest createEmptyInstance() => create();
  static $pb.PbList<FavoriteAddRequest> createRepeated() =>
      $pb.PbList<FavoriteAddRequest>();
  @$core.pragma('dart2js:noInline')
  static FavoriteAddRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FavoriteAddRequest>(create);
  static FavoriteAddRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Favorite get favorite => $_getN(0);
  @$pb.TagNumber(1)
  set favorite($0.Favorite value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFavorite() => $_has(0);
  @$pb.TagNumber(1)
  void clearFavorite() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Favorite ensureFavorite() => $_ensure(0);
}

class FavoriteAddResponse extends $pb.GeneratedMessage {
  factory FavoriteAddResponse() => create();

  FavoriteAddResponse._();

  factory FavoriteAddResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FavoriteAddResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FavoriteAddResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FavoriteAddResponse clone() => FavoriteAddResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FavoriteAddResponse copyWith(void Function(FavoriteAddResponse) updates) =>
      super.copyWith((message) => updates(message as FavoriteAddResponse))
          as FavoriteAddResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FavoriteAddResponse create() => FavoriteAddResponse._();
  @$core.override
  FavoriteAddResponse createEmptyInstance() => create();
  static $pb.PbList<FavoriteAddResponse> createRepeated() =>
      $pb.PbList<FavoriteAddResponse>();
  @$core.pragma('dart2js:noInline')
  static FavoriteAddResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FavoriteAddResponse>(create);
  static FavoriteAddResponse? _defaultInstance;
}

class FavoriteRemoveRequest extends $pb.GeneratedMessage {
  factory FavoriteRemoveRequest({
    $fixnum.Int64? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  FavoriteRemoveRequest._();

  factory FavoriteRemoveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FavoriteRemoveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FavoriteRemoveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FavoriteRemoveRequest clone() =>
      FavoriteRemoveRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FavoriteRemoveRequest copyWith(
          void Function(FavoriteRemoveRequest) updates) =>
      super.copyWith((message) => updates(message as FavoriteRemoveRequest))
          as FavoriteRemoveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FavoriteRemoveRequest create() => FavoriteRemoveRequest._();
  @$core.override
  FavoriteRemoveRequest createEmptyInstance() => create();
  static $pb.PbList<FavoriteRemoveRequest> createRepeated() =>
      $pb.PbList<FavoriteRemoveRequest>();
  @$core.pragma('dart2js:noInline')
  static FavoriteRemoveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FavoriteRemoveRequest>(create);
  static FavoriteRemoveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class FavoriteRemoveResponse extends $pb.GeneratedMessage {
  factory FavoriteRemoveResponse() => create();

  FavoriteRemoveResponse._();

  factory FavoriteRemoveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FavoriteRemoveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FavoriteRemoveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FavoriteRemoveResponse clone() =>
      FavoriteRemoveResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FavoriteRemoveResponse copyWith(
          void Function(FavoriteRemoveResponse) updates) =>
      super.copyWith((message) => updates(message as FavoriteRemoveResponse))
          as FavoriteRemoveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FavoriteRemoveResponse create() => FavoriteRemoveResponse._();
  @$core.override
  FavoriteRemoveResponse createEmptyInstance() => create();
  static $pb.PbList<FavoriteRemoveResponse> createRepeated() =>
      $pb.PbList<FavoriteRemoveResponse>();
  @$core.pragma('dart2js:noInline')
  static FavoriteRemoveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FavoriteRemoveResponse>(create);
  static FavoriteRemoveResponse? _defaultInstance;
}

class PushFavoriteList extends $pb.GeneratedMessage {
  factory PushFavoriteList({
    $fixnum.Int64? version,
    $core.Iterable<$0.Favorite>? favorites,
  }) {
    final result = create();
    if (version != null) result.version = version;
    if (favorites != null) result.favorites.addAll(favorites);
    return result;
  }

  PushFavoriteList._();

  factory PushFavoriteList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushFavoriteList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushFavoriteList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'version')
    ..pc<$0.Favorite>(2, _omitFieldNames ? '' : 'favorites', $pb.PbFieldType.PM,
        subBuilder: $0.Favorite.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushFavoriteList clone() => PushFavoriteList()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushFavoriteList copyWith(void Function(PushFavoriteList) updates) =>
      super.copyWith((message) => updates(message as PushFavoriteList))
          as PushFavoriteList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushFavoriteList create() => PushFavoriteList._();
  @$core.override
  PushFavoriteList createEmptyInstance() => create();
  static $pb.PbList<PushFavoriteList> createRepeated() =>
      $pb.PbList<PushFavoriteList>();
  @$core.pragma('dart2js:noInline')
  static PushFavoriteList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushFavoriteList>(create);
  static PushFavoriteList? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get version => $_getI64(0);
  @$pb.TagNumber(1)
  set version($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$0.Favorite> get favorites => $_getList(1);
}

class GetFavoriteListRequest extends $pb.GeneratedMessage {
  factory GetFavoriteListRequest() => create();

  GetFavoriteListRequest._();

  factory GetFavoriteListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFavoriteListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFavoriteListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFavoriteListRequest clone() =>
      GetFavoriteListRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFavoriteListRequest copyWith(
          void Function(GetFavoriteListRequest) updates) =>
      super.copyWith((message) => updates(message as GetFavoriteListRequest))
          as GetFavoriteListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFavoriteListRequest create() => GetFavoriteListRequest._();
  @$core.override
  GetFavoriteListRequest createEmptyInstance() => create();
  static $pb.PbList<GetFavoriteListRequest> createRepeated() =>
      $pb.PbList<GetFavoriteListRequest>();
  @$core.pragma('dart2js:noInline')
  static GetFavoriteListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFavoriteListRequest>(create);
  static GetFavoriteListRequest? _defaultInstance;
}

class GetFavoriteListResponse extends $pb.GeneratedMessage {
  factory GetFavoriteListResponse({
    $fixnum.Int64? version,
    $0.FavoriteList? favorites,
  }) {
    final result = create();
    if (version != null) result.version = version;
    if (favorites != null) result.favorites = favorites;
    return result;
  }

  GetFavoriteListResponse._();

  factory GetFavoriteListResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFavoriteListResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFavoriteListResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'version')
    ..aOM<$0.FavoriteList>(2, _omitFieldNames ? '' : 'favorites',
        subBuilder: $0.FavoriteList.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFavoriteListResponse clone() =>
      GetFavoriteListResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFavoriteListResponse copyWith(
          void Function(GetFavoriteListResponse) updates) =>
      super.copyWith((message) => updates(message as GetFavoriteListResponse))
          as GetFavoriteListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFavoriteListResponse create() => GetFavoriteListResponse._();
  @$core.override
  GetFavoriteListResponse createEmptyInstance() => create();
  static $pb.PbList<GetFavoriteListResponse> createRepeated() =>
      $pb.PbList<GetFavoriteListResponse>();
  @$core.pragma('dart2js:noInline')
  static GetFavoriteListResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFavoriteListResponse>(create);
  static GetFavoriteListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get version => $_getI64(0);
  @$pb.TagNumber(1)
  set version($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.FavoriteList get favorites => $_getN(1);
  @$pb.TagNumber(2)
  set favorites($0.FavoriteList value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasFavorites() => $_has(1);
  @$pb.TagNumber(2)
  void clearFavorites() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.FavoriteList ensureFavorites() => $_ensure(1);
}

class MessageReadRequest extends $pb.GeneratedMessage {
  factory MessageReadRequest({
    $fixnum.Int64? chatId,
    $core.int? maxPos,
    $core.Iterable<$fixnum.Int64>? messageIds,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (maxPos != null) result.maxPos = maxPos;
    if (messageIds != null) result.messageIds.addAll(messageIds);
    return result;
  }

  MessageReadRequest._();

  factory MessageReadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageReadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageReadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'maxPos', $pb.PbFieldType.O3)
    ..p<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'messageIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageReadRequest clone() => MessageReadRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageReadRequest copyWith(void Function(MessageReadRequest) updates) =>
      super.copyWith((message) => updates(message as MessageReadRequest))
          as MessageReadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageReadRequest create() => MessageReadRequest._();
  @$core.override
  MessageReadRequest createEmptyInstance() => create();
  static $pb.PbList<MessageReadRequest> createRepeated() =>
      $pb.PbList<MessageReadRequest>();
  @$core.pragma('dart2js:noInline')
  static MessageReadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageReadRequest>(create);
  static MessageReadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get maxPos => $_getIZ(1);
  @$pb.TagNumber(2)
  set maxPos($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxPos() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxPos() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$fixnum.Int64> get messageIds => $_getList(2);
}

class MessageReadResponse extends $pb.GeneratedMessage {
  factory MessageReadResponse() => create();

  MessageReadResponse._();

  factory MessageReadResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageReadResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageReadResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageReadResponse clone() => MessageReadResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageReadResponse copyWith(void Function(MessageReadResponse) updates) =>
      super.copyWith((message) => updates(message as MessageReadResponse))
          as MessageReadResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageReadResponse create() => MessageReadResponse._();
  @$core.override
  MessageReadResponse createEmptyInstance() => create();
  static $pb.PbList<MessageReadResponse> createRepeated() =>
      $pb.PbList<MessageReadResponse>();
  @$core.pragma('dart2js:noInline')
  static MessageReadResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageReadResponse>(create);
  static MessageReadResponse? _defaultInstance;
}

class PushReadMessageRequest extends $pb.GeneratedMessage {
  factory PushReadMessageRequest({
    $0.Entity? entity,
  }) {
    final result = create();
    if (entity != null) result.entity = entity;
    return result;
  }

  PushReadMessageRequest._();

  factory PushReadMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushReadMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushReadMessageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aOM<$0.Entity>(1, _omitFieldNames ? '' : 'entity',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushReadMessageRequest clone() =>
      PushReadMessageRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushReadMessageRequest copyWith(
          void Function(PushReadMessageRequest) updates) =>
      super.copyWith((message) => updates(message as PushReadMessageRequest))
          as PushReadMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushReadMessageRequest create() => PushReadMessageRequest._();
  @$core.override
  PushReadMessageRequest createEmptyInstance() => create();
  static $pb.PbList<PushReadMessageRequest> createRepeated() =>
      $pb.PbList<PushReadMessageRequest>();
  @$core.pragma('dart2js:noInline')
  static PushReadMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushReadMessageRequest>(create);
  static PushReadMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Entity get entity => $_getN(0);
  @$pb.TagNumber(1)
  set entity($0.Entity value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEntity() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntity() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Entity ensureEntity() => $_ensure(0);
}

class SetMessageReactitonRequest extends $pb.GeneratedMessage {
  factory SetMessageReactitonRequest({
    $fixnum.Int64? messageId,
    $core.int? reaction,
    $core.bool? set,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (reaction != null) result.reaction = reaction;
    if (set != null) result.set = set;
    return result;
  }

  SetMessageReactitonRequest._();

  factory SetMessageReactitonRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetMessageReactitonRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetMessageReactitonRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'messageId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'reaction', $pb.PbFieldType.O3)
    ..aOB(3, _omitFieldNames ? '' : 'set')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMessageReactitonRequest clone() =>
      SetMessageReactitonRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMessageReactitonRequest copyWith(
          void Function(SetMessageReactitonRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SetMessageReactitonRequest))
          as SetMessageReactitonRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetMessageReactitonRequest create() => SetMessageReactitonRequest._();
  @$core.override
  SetMessageReactitonRequest createEmptyInstance() => create();
  static $pb.PbList<SetMessageReactitonRequest> createRepeated() =>
      $pb.PbList<SetMessageReactitonRequest>();
  @$core.pragma('dart2js:noInline')
  static SetMessageReactitonRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetMessageReactitonRequest>(create);
  static SetMessageReactitonRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1)
  set messageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get reaction => $_getIZ(1);
  @$pb.TagNumber(2)
  set reaction($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReaction() => $_has(1);
  @$pb.TagNumber(2)
  void clearReaction() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get set => $_getBF(2);
  @$pb.TagNumber(3)
  set set($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSet() => $_has(2);
  @$pb.TagNumber(3)
  void clearSet() => $_clearField(3);
}

class SetMessageReactitonResponse extends $pb.GeneratedMessage {
  factory SetMessageReactitonResponse() => create();

  SetMessageReactitonResponse._();

  factory SetMessageReactitonResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetMessageReactitonResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetMessageReactitonResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMessageReactitonResponse clone() =>
      SetMessageReactitonResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMessageReactitonResponse copyWith(
          void Function(SetMessageReactitonResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SetMessageReactitonResponse))
          as SetMessageReactitonResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetMessageReactitonResponse create() =>
      SetMessageReactitonResponse._();
  @$core.override
  SetMessageReactitonResponse createEmptyInstance() => create();
  static $pb.PbList<SetMessageReactitonResponse> createRepeated() =>
      $pb.PbList<SetMessageReactitonResponse>();
  @$core.pragma('dart2js:noInline')
  static SetMessageReactitonResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetMessageReactitonResponse>(create);
  static SetMessageReactitonResponse? _defaultInstance;
}

class PushMessageReactionRequest extends $pb.GeneratedMessage {
  factory PushMessageReactionRequest({
    $0.Entity? entity,
  }) {
    final result = create();
    if (entity != null) result.entity = entity;
    return result;
  }

  PushMessageReactionRequest._();

  factory PushMessageReactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushMessageReactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushMessageReactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aOM<$0.Entity>(1, _omitFieldNames ? '' : 'entity',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushMessageReactionRequest clone() =>
      PushMessageReactionRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushMessageReactionRequest copyWith(
          void Function(PushMessageReactionRequest) updates) =>
      super.copyWith(
              (message) => updates(message as PushMessageReactionRequest))
          as PushMessageReactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushMessageReactionRequest create() => PushMessageReactionRequest._();
  @$core.override
  PushMessageReactionRequest createEmptyInstance() => create();
  static $pb.PbList<PushMessageReactionRequest> createRepeated() =>
      $pb.PbList<PushMessageReactionRequest>();
  @$core.pragma('dart2js:noInline')
  static PushMessageReactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushMessageReactionRequest>(create);
  static PushMessageReactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Entity get entity => $_getN(0);
  @$pb.TagNumber(1)
  set entity($0.Entity value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEntity() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntity() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Entity ensureEntity() => $_ensure(0);
}

class RecallMessageRequest extends $pb.GeneratedMessage {
  factory RecallMessageRequest({
    $fixnum.Int64? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  RecallMessageRequest._();

  factory RecallMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RecallMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecallMessageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecallMessageRequest clone() =>
      RecallMessageRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecallMessageRequest copyWith(void Function(RecallMessageRequest) updates) =>
      super.copyWith((message) => updates(message as RecallMessageRequest))
          as RecallMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecallMessageRequest create() => RecallMessageRequest._();
  @$core.override
  RecallMessageRequest createEmptyInstance() => create();
  static $pb.PbList<RecallMessageRequest> createRepeated() =>
      $pb.PbList<RecallMessageRequest>();
  @$core.pragma('dart2js:noInline')
  static RecallMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecallMessageRequest>(create);
  static RecallMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class RecallMessageResponse extends $pb.GeneratedMessage {
  factory RecallMessageResponse({
    $0.Entity? entity,
  }) {
    final result = create();
    if (entity != null) result.entity = entity;
    return result;
  }

  RecallMessageResponse._();

  factory RecallMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RecallMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecallMessageResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'message'),
      createEmptyInstance: create)
    ..aOM<$0.Entity>(1, _omitFieldNames ? '' : 'entity',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecallMessageResponse clone() =>
      RecallMessageResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecallMessageResponse copyWith(
          void Function(RecallMessageResponse) updates) =>
      super.copyWith((message) => updates(message as RecallMessageResponse))
          as RecallMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecallMessageResponse create() => RecallMessageResponse._();
  @$core.override
  RecallMessageResponse createEmptyInstance() => create();
  static $pb.PbList<RecallMessageResponse> createRepeated() =>
      $pb.PbList<RecallMessageResponse>();
  @$core.pragma('dart2js:noInline')
  static RecallMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecallMessageResponse>(create);
  static RecallMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Entity get entity => $_getN(0);
  @$pb.TagNumber(1)
  set entity($0.Entity value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEntity() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntity() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Entity ensureEntity() => $_ensure(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
