// This is a generated file - do not edit.
//
// Generated from presence.proto.

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

class PresenceUpdateRequest extends $pb.GeneratedMessage {
  factory PresenceUpdateRequest({
    $core.int? status,
    $core.String? statusText,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (statusText != null) result.statusText = statusText;
    return result;
  }

  PresenceUpdateRequest._();

  factory PresenceUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PresenceUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PresenceUpdateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'presence'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'status')
    ..aOS(2, _omitFieldNames ? '' : 'statusText')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresenceUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresenceUpdateRequest copyWith(
          void Function(PresenceUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as PresenceUpdateRequest))
          as PresenceUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PresenceUpdateRequest create() => PresenceUpdateRequest._();
  @$core.override
  PresenceUpdateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PresenceUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PresenceUpdateRequest>(create);
  static PresenceUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get status => $_getIZ(0);
  @$pb.TagNumber(1)
  set status($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get statusText => $_getSZ(1);
  @$pb.TagNumber(2)
  set statusText($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatusText() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatusText() => $_clearField(2);
}

class PresenceUpdateResponse extends $pb.GeneratedMessage {
  factory PresenceUpdateResponse() => create();

  PresenceUpdateResponse._();

  factory PresenceUpdateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PresenceUpdateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PresenceUpdateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'presence'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresenceUpdateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresenceUpdateResponse copyWith(
          void Function(PresenceUpdateResponse) updates) =>
      super.copyWith((message) => updates(message as PresenceUpdateResponse))
          as PresenceUpdateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PresenceUpdateResponse create() => PresenceUpdateResponse._();
  @$core.override
  PresenceUpdateResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PresenceUpdateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PresenceUpdateResponse>(create);
  static PresenceUpdateResponse? _defaultInstance;
}

class PushPresence extends $pb.GeneratedMessage {
  factory PushPresence({
    $fixnum.Int64? userId,
    $core.int? status,
    $core.String? statusText,
    $fixnum.Int64? lastSeenMs,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (status != null) result.status = status;
    if (statusText != null) result.statusText = statusText;
    if (lastSeenMs != null) result.lastSeenMs = lastSeenMs;
    return result;
  }

  PushPresence._();

  factory PushPresence.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushPresence.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushPresence',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'presence'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aI(2, _omitFieldNames ? '' : 'status')
    ..aOS(3, _omitFieldNames ? '' : 'statusText')
    ..aInt64(4, _omitFieldNames ? '' : 'lastSeenMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushPresence clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushPresence copyWith(void Function(PushPresence) updates) =>
      super.copyWith((message) => updates(message as PushPresence))
          as PushPresence;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushPresence create() => PushPresence._();
  @$core.override
  PushPresence createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushPresence getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushPresence>(create);
  static PushPresence? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get status => $_getIZ(1);
  @$pb.TagNumber(2)
  set status($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get statusText => $_getSZ(2);
  @$pb.TagNumber(3)
  set statusText($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStatusText() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatusText() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get lastSeenMs => $_getI64(3);
  @$pb.TagNumber(4)
  set lastSeenMs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLastSeenMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearLastSeenMs() => $_clearField(4);
}

class PresenceSubscribeRequest extends $pb.GeneratedMessage {
  factory PresenceSubscribeRequest({
    $core.Iterable<$fixnum.Int64>? userIds,
  }) {
    final result = create();
    if (userIds != null) result.userIds.addAll(userIds);
    return result;
  }

  PresenceSubscribeRequest._();

  factory PresenceSubscribeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PresenceSubscribeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PresenceSubscribeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'presence'),
      createEmptyInstance: create)
    ..p<$fixnum.Int64>(1, _omitFieldNames ? '' : 'userIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresenceSubscribeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresenceSubscribeRequest copyWith(
          void Function(PresenceSubscribeRequest) updates) =>
      super.copyWith((message) => updates(message as PresenceSubscribeRequest))
          as PresenceSubscribeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PresenceSubscribeRequest create() => PresenceSubscribeRequest._();
  @$core.override
  PresenceSubscribeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PresenceSubscribeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PresenceSubscribeRequest>(create);
  static PresenceSubscribeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$fixnum.Int64> get userIds => $_getList(0);
}

class PresenceSubscribeResponse extends $pb.GeneratedMessage {
  factory PresenceSubscribeResponse() => create();

  PresenceSubscribeResponse._();

  factory PresenceSubscribeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PresenceSubscribeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PresenceSubscribeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'presence'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresenceSubscribeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresenceSubscribeResponse copyWith(
          void Function(PresenceSubscribeResponse) updates) =>
      super.copyWith((message) => updates(message as PresenceSubscribeResponse))
          as PresenceSubscribeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PresenceSubscribeResponse create() => PresenceSubscribeResponse._();
  @$core.override
  PresenceSubscribeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PresenceSubscribeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PresenceSubscribeResponse>(create);
  static PresenceSubscribeResponse? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
