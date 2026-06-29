// This is a generated file - do not edit.
//
// Generated from feed.proto.

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

class PullFeedListRequest extends $pb.GeneratedMessage {
  factory PullFeedListRequest({
    $fixnum.Int64? cursor,
    $core.int? count,
    $fixnum.Int64? prevCursor,
  }) {
    final result = create();
    if (cursor != null) result.cursor = cursor;
    if (count != null) result.count = count;
    if (prevCursor != null) result.prevCursor = prevCursor;
    return result;
  }

  PullFeedListRequest._();

  factory PullFeedListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PullFeedListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PullFeedListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'cursor')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'count', $pb.PbFieldType.O3)
    ..aInt64(3, _omitFieldNames ? '' : 'prevCursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullFeedListRequest clone() => PullFeedListRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullFeedListRequest copyWith(void Function(PullFeedListRequest) updates) =>
      super.copyWith((message) => updates(message as PullFeedListRequest))
          as PullFeedListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PullFeedListRequest create() => PullFeedListRequest._();
  @$core.override
  PullFeedListRequest createEmptyInstance() => create();
  static $pb.PbList<PullFeedListRequest> createRepeated() =>
      $pb.PbList<PullFeedListRequest>();
  @$core.pragma('dart2js:noInline')
  static PullFeedListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PullFeedListRequest>(create);
  static PullFeedListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get cursor => $_getI64(0);
  @$pb.TagNumber(1)
  set cursor($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCursor() => $_has(0);
  @$pb.TagNumber(1)
  void clearCursor() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get count => $_getIZ(1);
  @$pb.TagNumber(2)
  set count($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get prevCursor => $_getI64(2);
  @$pb.TagNumber(3)
  set prevCursor($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrevCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevCursor() => $_clearField(3);
}

class PullFeedListResponse extends $pb.GeneratedMessage {
  factory PullFeedListResponse({
    $fixnum.Int64? cursor,
    $core.bool? hasMore,
    $0.Entity? entity,
  }) {
    final result = create();
    if (cursor != null) result.cursor = cursor;
    if (hasMore != null) result.hasMore = hasMore;
    if (entity != null) result.entity = entity;
    return result;
  }

  PullFeedListResponse._();

  factory PullFeedListResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PullFeedListResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PullFeedListResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'cursor')
    ..aOB(2, _omitFieldNames ? '' : 'hasMore')
    ..aOM<$0.Entity>(4, _omitFieldNames ? '' : 'entity',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullFeedListResponse clone() =>
      PullFeedListResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullFeedListResponse copyWith(void Function(PullFeedListResponse) updates) =>
      super.copyWith((message) => updates(message as PullFeedListResponse))
          as PullFeedListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PullFeedListResponse create() => PullFeedListResponse._();
  @$core.override
  PullFeedListResponse createEmptyInstance() => create();
  static $pb.PbList<PullFeedListResponse> createRepeated() =>
      $pb.PbList<PullFeedListResponse>();
  @$core.pragma('dart2js:noInline')
  static PullFeedListResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PullFeedListResponse>(create);
  static PullFeedListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get cursor => $_getI64(0);
  @$pb.TagNumber(1)
  set cursor($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCursor() => $_has(0);
  @$pb.TagNumber(1)
  void clearCursor() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get hasMore => $_getBF(1);
  @$pb.TagNumber(2)
  set hasMore($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHasMore() => $_has(1);
  @$pb.TagNumber(2)
  void clearHasMore() => $_clearField(2);

  @$pb.TagNumber(4)
  $0.Entity get entity => $_getN(2);
  @$pb.TagNumber(4)
  set entity($0.Entity value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasEntity() => $_has(2);
  @$pb.TagNumber(4)
  void clearEntity() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Entity ensureEntity() => $_ensure(2);
}

class PushFeedList extends $pb.GeneratedMessage {
  factory PushFeedList({
    $0.Entity? entity,
  }) {
    final result = create();
    if (entity != null) result.entity = entity;
    return result;
  }

  PushFeedList._();

  factory PushFeedList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushFeedList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushFeedList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aOM<$0.Entity>(1, _omitFieldNames ? '' : 'entity',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushFeedList clone() => PushFeedList()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushFeedList copyWith(void Function(PushFeedList) updates) =>
      super.copyWith((message) => updates(message as PushFeedList))
          as PushFeedList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushFeedList create() => PushFeedList._();
  @$core.override
  PushFeedList createEmptyInstance() => create();
  static $pb.PbList<PushFeedList> createRepeated() =>
      $pb.PbList<PushFeedList>();
  @$core.pragma('dart2js:noInline')
  static PushFeedList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushFeedList>(create);
  static PushFeedList? _defaultInstance;

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

class PullFeedByIdsRequest extends $pb.GeneratedMessage {
  factory PullFeedByIdsRequest({
    $core.Iterable<$fixnum.Int64>? ids,
  }) {
    final result = create();
    if (ids != null) result.ids.addAll(ids);
    return result;
  }

  PullFeedByIdsRequest._();

  factory PullFeedByIdsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PullFeedByIdsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PullFeedByIdsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..p<$fixnum.Int64>(1, _omitFieldNames ? '' : 'ids', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullFeedByIdsRequest clone() =>
      PullFeedByIdsRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullFeedByIdsRequest copyWith(void Function(PullFeedByIdsRequest) updates) =>
      super.copyWith((message) => updates(message as PullFeedByIdsRequest))
          as PullFeedByIdsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PullFeedByIdsRequest create() => PullFeedByIdsRequest._();
  @$core.override
  PullFeedByIdsRequest createEmptyInstance() => create();
  static $pb.PbList<PullFeedByIdsRequest> createRepeated() =>
      $pb.PbList<PullFeedByIdsRequest>();
  @$core.pragma('dart2js:noInline')
  static PullFeedByIdsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PullFeedByIdsRequest>(create);
  static PullFeedByIdsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$fixnum.Int64> get ids => $_getList(0);
}

class PullFeedByIdsResponse extends $pb.GeneratedMessage {
  factory PullFeedByIdsResponse({
    $0.Entity? entity,
  }) {
    final result = create();
    if (entity != null) result.entity = entity;
    return result;
  }

  PullFeedByIdsResponse._();

  factory PullFeedByIdsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PullFeedByIdsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PullFeedByIdsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aOM<$0.Entity>(1, _omitFieldNames ? '' : 'entity',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullFeedByIdsResponse clone() =>
      PullFeedByIdsResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullFeedByIdsResponse copyWith(
          void Function(PullFeedByIdsResponse) updates) =>
      super.copyWith((message) => updates(message as PullFeedByIdsResponse))
          as PullFeedByIdsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PullFeedByIdsResponse create() => PullFeedByIdsResponse._();
  @$core.override
  PullFeedByIdsResponse createEmptyInstance() => create();
  static $pb.PbList<PullFeedByIdsResponse> createRepeated() =>
      $pb.PbList<PullFeedByIdsResponse>();
  @$core.pragma('dart2js:noInline')
  static PullFeedByIdsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PullFeedByIdsResponse>(create);
  static PullFeedByIdsResponse? _defaultInstance;

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

class RemoveFeedRequest extends $pb.GeneratedMessage {
  factory RemoveFeedRequest({
    $fixnum.Int64? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  RemoveFeedRequest._();

  factory RemoveFeedRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveFeedRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveFeedRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveFeedRequest clone() => RemoveFeedRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveFeedRequest copyWith(void Function(RemoveFeedRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveFeedRequest))
          as RemoveFeedRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveFeedRequest create() => RemoveFeedRequest._();
  @$core.override
  RemoveFeedRequest createEmptyInstance() => create();
  static $pb.PbList<RemoveFeedRequest> createRepeated() =>
      $pb.PbList<RemoveFeedRequest>();
  @$core.pragma('dart2js:noInline')
  static RemoveFeedRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveFeedRequest>(create);
  static RemoveFeedRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class RemoveFeedResponse extends $pb.GeneratedMessage {
  factory RemoveFeedResponse() => create();

  RemoveFeedResponse._();

  factory RemoveFeedResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveFeedResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveFeedResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveFeedResponse clone() => RemoveFeedResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveFeedResponse copyWith(void Function(RemoveFeedResponse) updates) =>
      super.copyWith((message) => updates(message as RemoveFeedResponse))
          as RemoveFeedResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveFeedResponse create() => RemoveFeedResponse._();
  @$core.override
  RemoveFeedResponse createEmptyInstance() => create();
  static $pb.PbList<RemoveFeedResponse> createRepeated() =>
      $pb.PbList<RemoveFeedResponse>();
  @$core.pragma('dart2js:noInline')
  static RemoveFeedResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveFeedResponse>(create);
  static RemoveFeedResponse? _defaultInstance;
}

class SetFeedTopRequest extends $pb.GeneratedMessage {
  factory SetFeedTopRequest({
    $fixnum.Int64? id,
    $core.bool? top,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (top != null) result.top = top;
    return result;
  }

  SetFeedTopRequest._();

  factory SetFeedTopRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetFeedTopRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetFeedTopRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOB(2, _omitFieldNames ? '' : 'top')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFeedTopRequest clone() => SetFeedTopRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFeedTopRequest copyWith(void Function(SetFeedTopRequest) updates) =>
      super.copyWith((message) => updates(message as SetFeedTopRequest))
          as SetFeedTopRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetFeedTopRequest create() => SetFeedTopRequest._();
  @$core.override
  SetFeedTopRequest createEmptyInstance() => create();
  static $pb.PbList<SetFeedTopRequest> createRepeated() =>
      $pb.PbList<SetFeedTopRequest>();
  @$core.pragma('dart2js:noInline')
  static SetFeedTopRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetFeedTopRequest>(create);
  static SetFeedTopRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get top => $_getBF(1);
  @$pb.TagNumber(2)
  set top($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTop() => $_has(1);
  @$pb.TagNumber(2)
  void clearTop() => $_clearField(2);
}

class SetFeedTopResponse extends $pb.GeneratedMessage {
  factory SetFeedTopResponse() => create();

  SetFeedTopResponse._();

  factory SetFeedTopResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetFeedTopResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetFeedTopResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFeedTopResponse clone() => SetFeedTopResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFeedTopResponse copyWith(void Function(SetFeedTopResponse) updates) =>
      super.copyWith((message) => updates(message as SetFeedTopResponse))
          as SetFeedTopResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetFeedTopResponse create() => SetFeedTopResponse._();
  @$core.override
  SetFeedTopResponse createEmptyInstance() => create();
  static $pb.PbList<SetFeedTopResponse> createRepeated() =>
      $pb.PbList<SetFeedTopResponse>();
  @$core.pragma('dart2js:noInline')
  static SetFeedTopResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetFeedTopResponse>(create);
  static SetFeedTopResponse? _defaultInstance;
}

class SetFeedMuteRequest extends $pb.GeneratedMessage {
  factory SetFeedMuteRequest({
    $fixnum.Int64? id,
    $core.bool? mute,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (mute != null) result.mute = mute;
    return result;
  }

  SetFeedMuteRequest._();

  factory SetFeedMuteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetFeedMuteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetFeedMuteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOB(2, _omitFieldNames ? '' : 'mute')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFeedMuteRequest clone() => SetFeedMuteRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFeedMuteRequest copyWith(void Function(SetFeedMuteRequest) updates) =>
      super.copyWith((message) => updates(message as SetFeedMuteRequest))
          as SetFeedMuteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetFeedMuteRequest create() => SetFeedMuteRequest._();
  @$core.override
  SetFeedMuteRequest createEmptyInstance() => create();
  static $pb.PbList<SetFeedMuteRequest> createRepeated() =>
      $pb.PbList<SetFeedMuteRequest>();
  @$core.pragma('dart2js:noInline')
  static SetFeedMuteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetFeedMuteRequest>(create);
  static SetFeedMuteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get mute => $_getBF(1);
  @$pb.TagNumber(2)
  set mute($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMute() => $_has(1);
  @$pb.TagNumber(2)
  void clearMute() => $_clearField(2);
}

class SetFeedMuteResponse extends $pb.GeneratedMessage {
  factory SetFeedMuteResponse() => create();

  SetFeedMuteResponse._();

  factory SetFeedMuteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetFeedMuteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetFeedMuteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFeedMuteResponse clone() => SetFeedMuteResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFeedMuteResponse copyWith(void Function(SetFeedMuteResponse) updates) =>
      super.copyWith((message) => updates(message as SetFeedMuteResponse))
          as SetFeedMuteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetFeedMuteResponse create() => SetFeedMuteResponse._();
  @$core.override
  SetFeedMuteResponse createEmptyInstance() => create();
  static $pb.PbList<SetFeedMuteResponse> createRepeated() =>
      $pb.PbList<SetFeedMuteResponse>();
  @$core.pragma('dart2js:noInline')
  static SetFeedMuteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetFeedMuteResponse>(create);
  static SetFeedMuteResponse? _defaultInstance;
}

class GetFeedTopListRequest extends $pb.GeneratedMessage {
  factory GetFeedTopListRequest() => create();

  GetFeedTopListRequest._();

  factory GetFeedTopListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFeedTopListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFeedTopListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFeedTopListRequest clone() =>
      GetFeedTopListRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFeedTopListRequest copyWith(
          void Function(GetFeedTopListRequest) updates) =>
      super.copyWith((message) => updates(message as GetFeedTopListRequest))
          as GetFeedTopListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFeedTopListRequest create() => GetFeedTopListRequest._();
  @$core.override
  GetFeedTopListRequest createEmptyInstance() => create();
  static $pb.PbList<GetFeedTopListRequest> createRepeated() =>
      $pb.PbList<GetFeedTopListRequest>();
  @$core.pragma('dart2js:noInline')
  static GetFeedTopListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFeedTopListRequest>(create);
  static GetFeedTopListRequest? _defaultInstance;
}

class GetFeedTopListResponse extends $pb.GeneratedMessage {
  factory GetFeedTopListResponse({
    $core.Iterable<$fixnum.Int64>? ids,
    $fixnum.Int64? version,
    $0.Entity? entity,
  }) {
    final result = create();
    if (ids != null) result.ids.addAll(ids);
    if (version != null) result.version = version;
    if (entity != null) result.entity = entity;
    return result;
  }

  GetFeedTopListResponse._();

  factory GetFeedTopListResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFeedTopListResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFeedTopListResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..p<$fixnum.Int64>(1, _omitFieldNames ? '' : 'ids', $pb.PbFieldType.K6)
    ..aInt64(2, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Entity>(3, _omitFieldNames ? '' : 'entity',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFeedTopListResponse clone() =>
      GetFeedTopListResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFeedTopListResponse copyWith(
          void Function(GetFeedTopListResponse) updates) =>
      super.copyWith((message) => updates(message as GetFeedTopListResponse))
          as GetFeedTopListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFeedTopListResponse create() => GetFeedTopListResponse._();
  @$core.override
  GetFeedTopListResponse createEmptyInstance() => create();
  static $pb.PbList<GetFeedTopListResponse> createRepeated() =>
      $pb.PbList<GetFeedTopListResponse>();
  @$core.pragma('dart2js:noInline')
  static GetFeedTopListResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFeedTopListResponse>(create);
  static GetFeedTopListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$fixnum.Int64> get ids => $_getList(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get version => $_getI64(1);
  @$pb.TagNumber(2)
  set version($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Entity get entity => $_getN(2);
  @$pb.TagNumber(3)
  set entity($0.Entity value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEntity() => $_has(2);
  @$pb.TagNumber(3)
  void clearEntity() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Entity ensureEntity() => $_ensure(2);
}

class ActiveFeedRequest extends $pb.GeneratedMessage {
  factory ActiveFeedRequest({
    $fixnum.Int64? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  ActiveFeedRequest._();

  factory ActiveFeedRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ActiveFeedRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActiveFeedRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActiveFeedRequest clone() => ActiveFeedRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActiveFeedRequest copyWith(void Function(ActiveFeedRequest) updates) =>
      super.copyWith((message) => updates(message as ActiveFeedRequest))
          as ActiveFeedRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ActiveFeedRequest create() => ActiveFeedRequest._();
  @$core.override
  ActiveFeedRequest createEmptyInstance() => create();
  static $pb.PbList<ActiveFeedRequest> createRepeated() =>
      $pb.PbList<ActiveFeedRequest>();
  @$core.pragma('dart2js:noInline')
  static ActiveFeedRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActiveFeedRequest>(create);
  static ActiveFeedRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class ActiveFeedResponse extends $pb.GeneratedMessage {
  factory ActiveFeedResponse() => create();

  ActiveFeedResponse._();

  factory ActiveFeedResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ActiveFeedResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActiveFeedResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActiveFeedResponse clone() => ActiveFeedResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActiveFeedResponse copyWith(void Function(ActiveFeedResponse) updates) =>
      super.copyWith((message) => updates(message as ActiveFeedResponse))
          as ActiveFeedResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ActiveFeedResponse create() => ActiveFeedResponse._();
  @$core.override
  ActiveFeedResponse createEmptyInstance() => create();
  static $pb.PbList<ActiveFeedResponse> createRepeated() =>
      $pb.PbList<ActiveFeedResponse>();
  @$core.pragma('dart2js:noInline')
  static ActiveFeedResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActiveFeedResponse>(create);
  static ActiveFeedResponse? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
