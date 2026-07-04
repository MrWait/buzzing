// This is a generated file - do not edit.
//
// Generated from pipeline.proto.

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

class PullPipelineRequest extends $pb.GeneratedMessage {
  factory PullPipelineRequest({
    $fixnum.Int64? sid,
    $core.int? count,
  }) {
    final result = create();
    if (sid != null) result.sid = sid;
    if (count != null) result.count = count;
    return result;
  }

  PullPipelineRequest._();

  factory PullPipelineRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PullPipelineRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PullPipelineRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pipeline'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'sid')
    ..aI(2, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullPipelineRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullPipelineRequest copyWith(void Function(PullPipelineRequest) updates) =>
      super.copyWith((message) => updates(message as PullPipelineRequest))
          as PullPipelineRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PullPipelineRequest create() => PullPipelineRequest._();
  @$core.override
  PullPipelineRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PullPipelineRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PullPipelineRequest>(create);
  static PullPipelineRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get sid => $_getI64(0);
  @$pb.TagNumber(1)
  set sid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSid() => $_has(0);
  @$pb.TagNumber(1)
  void clearSid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get count => $_getIZ(1);
  @$pb.TagNumber(2)
  set count($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCount() => $_clearField(2);
}

class PullPipelineResponse extends $pb.GeneratedMessage {
  factory PullPipelineResponse({
    $fixnum.Int64? sid,
    $core.Iterable<$0.Packet>? packets,
    $core.bool? hasMore,
  }) {
    final result = create();
    if (sid != null) result.sid = sid;
    if (packets != null) result.packets.addAll(packets);
    if (hasMore != null) result.hasMore = hasMore;
    return result;
  }

  PullPipelineResponse._();

  factory PullPipelineResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PullPipelineResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PullPipelineResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pipeline'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'sid')
    ..pPM<$0.Packet>(2, _omitFieldNames ? '' : 'packets',
        subBuilder: $0.Packet.create)
    ..aOB(3, _omitFieldNames ? '' : 'hasMore')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullPipelineResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullPipelineResponse copyWith(void Function(PullPipelineResponse) updates) =>
      super.copyWith((message) => updates(message as PullPipelineResponse))
          as PullPipelineResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PullPipelineResponse create() => PullPipelineResponse._();
  @$core.override
  PullPipelineResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PullPipelineResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PullPipelineResponse>(create);
  static PullPipelineResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get sid => $_getI64(0);
  @$pb.TagNumber(1)
  set sid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSid() => $_has(0);
  @$pb.TagNumber(1)
  void clearSid() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$0.Packet> get packets => $_getList(1);

  @$pb.TagNumber(3)
  $core.bool get hasMore => $_getBF(2);
  @$pb.TagNumber(3)
  set hasMore($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHasMore() => $_has(2);
  @$pb.TagNumber(3)
  void clearHasMore() => $_clearField(3);
}

class PushEntityChanged extends $pb.GeneratedMessage {
  factory PushEntityChanged({
    $core.Iterable<$0.EntityChange>? changes,
  }) {
    final result = create();
    if (changes != null) result.changes.addAll(changes);
    return result;
  }

  PushEntityChanged._();

  factory PushEntityChanged.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushEntityChanged.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushEntityChanged',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pipeline'),
      createEmptyInstance: create)
    ..pPM<$0.EntityChange>(1, _omitFieldNames ? '' : 'changes',
        subBuilder: $0.EntityChange.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushEntityChanged clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushEntityChanged copyWith(void Function(PushEntityChanged) updates) =>
      super.copyWith((message) => updates(message as PushEntityChanged))
          as PushEntityChanged;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushEntityChanged create() => PushEntityChanged._();
  @$core.override
  PushEntityChanged createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushEntityChanged getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushEntityChanged>(create);
  static PushEntityChanged? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.EntityChange> get changes => $_getList(0);
}

class PullEntityRequest extends $pb.GeneratedMessage {
  factory PullEntityRequest({
    $core.Iterable<$0.EntityId>? ids,
  }) {
    final result = create();
    if (ids != null) result.ids.addAll(ids);
    return result;
  }

  PullEntityRequest._();

  factory PullEntityRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PullEntityRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PullEntityRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pipeline'),
      createEmptyInstance: create)
    ..pPM<$0.EntityId>(1, _omitFieldNames ? '' : 'ids',
        subBuilder: $0.EntityId.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullEntityRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullEntityRequest copyWith(void Function(PullEntityRequest) updates) =>
      super.copyWith((message) => updates(message as PullEntityRequest))
          as PullEntityRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PullEntityRequest create() => PullEntityRequest._();
  @$core.override
  PullEntityRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PullEntityRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PullEntityRequest>(create);
  static PullEntityRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.EntityId> get ids => $_getList(0);
}

class PullEntityResponse extends $pb.GeneratedMessage {
  factory PullEntityResponse({
    $0.Entity? entity,
  }) {
    final result = create();
    if (entity != null) result.entity = entity;
    return result;
  }

  PullEntityResponse._();

  factory PullEntityResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PullEntityResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PullEntityResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pipeline'),
      createEmptyInstance: create)
    ..aOM<$0.Entity>(2, _omitFieldNames ? '' : 'entity',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullEntityResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullEntityResponse copyWith(void Function(PullEntityResponse) updates) =>
      super.copyWith((message) => updates(message as PullEntityResponse))
          as PullEntityResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PullEntityResponse create() => PullEntityResponse._();
  @$core.override
  PullEntityResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PullEntityResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PullEntityResponse>(create);
  static PullEntityResponse? _defaultInstance;

  @$pb.TagNumber(2)
  $0.Entity get entity => $_getN(0);
  @$pb.TagNumber(2)
  set entity($0.Entity value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEntity() => $_has(0);
  @$pb.TagNumber(2)
  void clearEntity() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Entity ensureEntity() => $_ensure(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
