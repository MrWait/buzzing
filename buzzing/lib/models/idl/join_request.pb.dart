// This is a generated file - do not edit.
//
// Generated from join_request.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'entity.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class JoinRequest extends $pb.GeneratedMessage {
  factory JoinRequest({
    $fixnum.Int64? id,
    $fixnum.Int64? chatId,
    $core.String? chatName,
    $fixnum.Int64? userId,
    $core.String? userName,
    $core.int? status,
    $fixnum.Int64? handlerId,
    $fixnum.Int64? handledAt,
    $fixnum.Int64? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (chatId != null) result.chatId = chatId;
    if (chatName != null) result.chatName = chatName;
    if (userId != null) result.userId = userId;
    if (userName != null) result.userName = userName;
    if (status != null) result.status = status;
    if (handlerId != null) result.handlerId = handlerId;
    if (handledAt != null) result.handledAt = handledAt;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  JoinRequest._();

  factory JoinRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JoinRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'join_request'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'chatId')
    ..aOS(3, _omitFieldNames ? '' : 'chatName')
    ..aInt64(4, _omitFieldNames ? '' : 'userId')
    ..aOS(5, _omitFieldNames ? '' : 'userName')
    ..aI(6, _omitFieldNames ? '' : 'status')
    ..aInt64(7, _omitFieldNames ? '' : 'handlerId')
    ..aInt64(8, _omitFieldNames ? '' : 'handledAt')
    ..aInt64(9, _omitFieldNames ? '' : 'createdAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequest copyWith(void Function(JoinRequest) updates) =>
      super.copyWith((message) => updates(message as JoinRequest))
          as JoinRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinRequest create() => JoinRequest._();
  @$core.override
  JoinRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static JoinRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JoinRequest>(create);
  static JoinRequest? _defaultInstance;

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
  $core.String get chatName => $_getSZ(2);
  @$pb.TagNumber(3)
  set chatName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChatName() => $_has(2);
  @$pb.TagNumber(3)
  void clearChatName() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get userId => $_getI64(3);
  @$pb.TagNumber(4)
  set userId($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUserId() => $_has(3);
  @$pb.TagNumber(4)
  void clearUserId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get userName => $_getSZ(4);
  @$pb.TagNumber(5)
  set userName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUserName() => $_has(4);
  @$pb.TagNumber(5)
  void clearUserName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get status => $_getIZ(5);
  @$pb.TagNumber(6)
  set status($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get handlerId => $_getI64(6);
  @$pb.TagNumber(7)
  set handlerId($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasHandlerId() => $_has(6);
  @$pb.TagNumber(7)
  void clearHandlerId() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get handledAt => $_getI64(7);
  @$pb.TagNumber(8)
  set handledAt($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasHandledAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearHandledAt() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get createdAt => $_getI64(8);
  @$pb.TagNumber(9)
  set createdAt($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreatedAt() => $_clearField(9);
}

class JoinRequestCreateRequest extends $pb.GeneratedMessage {
  factory JoinRequestCreateRequest({
    $fixnum.Int64? chatId,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    return result;
  }

  JoinRequestCreateRequest._();

  factory JoinRequestCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JoinRequestCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinRequestCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'join_request'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestCreateRequest copyWith(
          void Function(JoinRequestCreateRequest) updates) =>
      super.copyWith((message) => updates(message as JoinRequestCreateRequest))
          as JoinRequestCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinRequestCreateRequest create() => JoinRequestCreateRequest._();
  @$core.override
  JoinRequestCreateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static JoinRequestCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JoinRequestCreateRequest>(create);
  static JoinRequestCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);
}

class JoinRequestCreateResponse extends $pb.GeneratedMessage {
  factory JoinRequestCreateResponse({
    JoinRequest? request,
    $0.Entity? entities,
  }) {
    final result = create();
    if (request != null) result.request = request;
    if (entities != null) result.entities = entities;
    return result;
  }

  JoinRequestCreateResponse._();

  factory JoinRequestCreateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JoinRequestCreateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinRequestCreateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'join_request'),
      createEmptyInstance: create)
    ..aOM<JoinRequest>(1, _omitFieldNames ? '' : 'request',
        subBuilder: JoinRequest.create)
    ..aOM<$0.Entity>(2, _omitFieldNames ? '' : 'entities',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestCreateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestCreateResponse copyWith(
          void Function(JoinRequestCreateResponse) updates) =>
      super.copyWith((message) => updates(message as JoinRequestCreateResponse))
          as JoinRequestCreateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinRequestCreateResponse create() => JoinRequestCreateResponse._();
  @$core.override
  JoinRequestCreateResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static JoinRequestCreateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JoinRequestCreateResponse>(create);
  static JoinRequestCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  JoinRequest get request => $_getN(0);
  @$pb.TagNumber(1)
  set request(JoinRequest value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRequest() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequest() => $_clearField(1);
  @$pb.TagNumber(1)
  JoinRequest ensureRequest() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.Entity get entities => $_getN(1);
  @$pb.TagNumber(2)
  set entities($0.Entity value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEntities() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntities() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Entity ensureEntities() => $_ensure(1);
}

class JoinRequestApproveRequest extends $pb.GeneratedMessage {
  factory JoinRequestApproveRequest({
    $fixnum.Int64? requestId,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    return result;
  }

  JoinRequestApproveRequest._();

  factory JoinRequestApproveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JoinRequestApproveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinRequestApproveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'join_request'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'requestId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestApproveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestApproveRequest copyWith(
          void Function(JoinRequestApproveRequest) updates) =>
      super.copyWith((message) => updates(message as JoinRequestApproveRequest))
          as JoinRequestApproveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinRequestApproveRequest create() => JoinRequestApproveRequest._();
  @$core.override
  JoinRequestApproveRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static JoinRequestApproveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JoinRequestApproveRequest>(create);
  static JoinRequestApproveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);
}

class JoinRequestApproveResponse extends $pb.GeneratedMessage {
  factory JoinRequestApproveResponse({
    $0.Entity? entities,
  }) {
    final result = create();
    if (entities != null) result.entities = entities;
    return result;
  }

  JoinRequestApproveResponse._();

  factory JoinRequestApproveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JoinRequestApproveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinRequestApproveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'join_request'),
      createEmptyInstance: create)
    ..aOM<$0.Entity>(1, _omitFieldNames ? '' : 'entities',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestApproveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestApproveResponse copyWith(
          void Function(JoinRequestApproveResponse) updates) =>
      super.copyWith(
              (message) => updates(message as JoinRequestApproveResponse))
          as JoinRequestApproveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinRequestApproveResponse create() => JoinRequestApproveResponse._();
  @$core.override
  JoinRequestApproveResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static JoinRequestApproveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JoinRequestApproveResponse>(create);
  static JoinRequestApproveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Entity get entities => $_getN(0);
  @$pb.TagNumber(1)
  set entities($0.Entity value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEntities() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntities() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Entity ensureEntities() => $_ensure(0);
}

class JoinRequestRejectRequest extends $pb.GeneratedMessage {
  factory JoinRequestRejectRequest({
    $fixnum.Int64? requestId,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    return result;
  }

  JoinRequestRejectRequest._();

  factory JoinRequestRejectRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JoinRequestRejectRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinRequestRejectRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'join_request'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'requestId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestRejectRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestRejectRequest copyWith(
          void Function(JoinRequestRejectRequest) updates) =>
      super.copyWith((message) => updates(message as JoinRequestRejectRequest))
          as JoinRequestRejectRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinRequestRejectRequest create() => JoinRequestRejectRequest._();
  @$core.override
  JoinRequestRejectRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static JoinRequestRejectRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JoinRequestRejectRequest>(create);
  static JoinRequestRejectRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);
}

class JoinRequestRejectResponse extends $pb.GeneratedMessage {
  factory JoinRequestRejectResponse() => create();

  JoinRequestRejectResponse._();

  factory JoinRequestRejectResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JoinRequestRejectResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinRequestRejectResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'join_request'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestRejectResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestRejectResponse copyWith(
          void Function(JoinRequestRejectResponse) updates) =>
      super.copyWith((message) => updates(message as JoinRequestRejectResponse))
          as JoinRequestRejectResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinRequestRejectResponse create() => JoinRequestRejectResponse._();
  @$core.override
  JoinRequestRejectResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static JoinRequestRejectResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JoinRequestRejectResponse>(create);
  static JoinRequestRejectResponse? _defaultInstance;
}

class JoinRequestListRequest extends $pb.GeneratedMessage {
  factory JoinRequestListRequest({
    $fixnum.Int64? chatId,
    $core.int? status,
    $core.int? page,
    $core.int? pageSize,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (status != null) result.status = status;
    if (page != null) result.page = page;
    if (pageSize != null) result.pageSize = pageSize;
    return result;
  }

  JoinRequestListRequest._();

  factory JoinRequestListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JoinRequestListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinRequestListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'join_request'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..aI(2, _omitFieldNames ? '' : 'status')
    ..aI(3, _omitFieldNames ? '' : 'page')
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestListRequest copyWith(
          void Function(JoinRequestListRequest) updates) =>
      super.copyWith((message) => updates(message as JoinRequestListRequest))
          as JoinRequestListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinRequestListRequest create() => JoinRequestListRequest._();
  @$core.override
  JoinRequestListRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static JoinRequestListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JoinRequestListRequest>(create);
  static JoinRequestListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get status => $_getIZ(1);
  @$pb.TagNumber(2)
  set status($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get page => $_getIZ(2);
  @$pb.TagNumber(3)
  set page($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPage() => $_has(2);
  @$pb.TagNumber(3)
  void clearPage() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get pageSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set pageSize($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPageSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageSize() => $_clearField(4);
}

class JoinRequestListResponse extends $pb.GeneratedMessage {
  factory JoinRequestListResponse({
    $core.Iterable<JoinRequest>? requests,
    $core.int? total,
  }) {
    final result = create();
    if (requests != null) result.requests.addAll(requests);
    if (total != null) result.total = total;
    return result;
  }

  JoinRequestListResponse._();

  factory JoinRequestListResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JoinRequestListResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinRequestListResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'join_request'),
      createEmptyInstance: create)
    ..pPM<JoinRequest>(1, _omitFieldNames ? '' : 'requests',
        subBuilder: JoinRequest.create)
    ..aI(2, _omitFieldNames ? '' : 'total')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestListResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestListResponse copyWith(
          void Function(JoinRequestListResponse) updates) =>
      super.copyWith((message) => updates(message as JoinRequestListResponse))
          as JoinRequestListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinRequestListResponse create() => JoinRequestListResponse._();
  @$core.override
  JoinRequestListResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static JoinRequestListResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JoinRequestListResponse>(create);
  static JoinRequestListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<JoinRequest> get requests => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2)
  set total($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
