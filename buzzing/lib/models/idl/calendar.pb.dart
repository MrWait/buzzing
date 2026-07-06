// This is a generated file - do not edit.
//
// Generated from calendar.proto.

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

class CalendarGetListRequest extends $pb.GeneratedMessage {
  factory CalendarGetListRequest() => create();

  CalendarGetListRequest._();

  factory CalendarGetListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarGetListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarGetListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarGetListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarGetListRequest copyWith(
          void Function(CalendarGetListRequest) updates) =>
      super.copyWith((message) => updates(message as CalendarGetListRequest))
          as CalendarGetListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarGetListRequest create() => CalendarGetListRequest._();
  @$core.override
  CalendarGetListRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarGetListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarGetListRequest>(create);
  static CalendarGetListRequest? _defaultInstance;
}

class CalendarGetListResponse extends $pb.GeneratedMessage {
  factory CalendarGetListResponse({
    $core.Iterable<$0.Calendar>? calendars,
  }) {
    final result = create();
    if (calendars != null) result.calendars.addAll(calendars);
    return result;
  }

  CalendarGetListResponse._();

  factory CalendarGetListResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarGetListResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarGetListResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..pPM<$0.Calendar>(1, _omitFieldNames ? '' : 'calendars',
        subBuilder: $0.Calendar.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarGetListResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarGetListResponse copyWith(
          void Function(CalendarGetListResponse) updates) =>
      super.copyWith((message) => updates(message as CalendarGetListResponse))
          as CalendarGetListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarGetListResponse create() => CalendarGetListResponse._();
  @$core.override
  CalendarGetListResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarGetListResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarGetListResponse>(create);
  static CalendarGetListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.Calendar> get calendars => $_getList(0);
}

class CalendarCreateRequest extends $pb.GeneratedMessage {
  factory CalendarCreateRequest({
    $0.Calendar? calendar,
  }) {
    final result = create();
    if (calendar != null) result.calendar = calendar;
    return result;
  }

  CalendarCreateRequest._();

  factory CalendarCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..aOM<$0.Calendar>(1, _omitFieldNames ? '' : 'calendar',
        subBuilder: $0.Calendar.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarCreateRequest copyWith(
          void Function(CalendarCreateRequest) updates) =>
      super.copyWith((message) => updates(message as CalendarCreateRequest))
          as CalendarCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarCreateRequest create() => CalendarCreateRequest._();
  @$core.override
  CalendarCreateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarCreateRequest>(create);
  static CalendarCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Calendar get calendar => $_getN(0);
  @$pb.TagNumber(1)
  set calendar($0.Calendar value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCalendar() => $_has(0);
  @$pb.TagNumber(1)
  void clearCalendar() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Calendar ensureCalendar() => $_ensure(0);
}

class CalendarCreateResponse extends $pb.GeneratedMessage {
  factory CalendarCreateResponse({
    $0.Calendar? calendar,
  }) {
    final result = create();
    if (calendar != null) result.calendar = calendar;
    return result;
  }

  CalendarCreateResponse._();

  factory CalendarCreateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarCreateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarCreateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..aOM<$0.Calendar>(1, _omitFieldNames ? '' : 'calendar',
        subBuilder: $0.Calendar.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarCreateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarCreateResponse copyWith(
          void Function(CalendarCreateResponse) updates) =>
      super.copyWith((message) => updates(message as CalendarCreateResponse))
          as CalendarCreateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarCreateResponse create() => CalendarCreateResponse._();
  @$core.override
  CalendarCreateResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarCreateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarCreateResponse>(create);
  static CalendarCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Calendar get calendar => $_getN(0);
  @$pb.TagNumber(1)
  set calendar($0.Calendar value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCalendar() => $_has(0);
  @$pb.TagNumber(1)
  void clearCalendar() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Calendar ensureCalendar() => $_ensure(0);
}

class CalendarUpdateRequest extends $pb.GeneratedMessage {
  factory CalendarUpdateRequest({
    $0.Calendar? calendar,
  }) {
    final result = create();
    if (calendar != null) result.calendar = calendar;
    return result;
  }

  CalendarUpdateRequest._();

  factory CalendarUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarUpdateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..aOM<$0.Calendar>(1, _omitFieldNames ? '' : 'calendar',
        subBuilder: $0.Calendar.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarUpdateRequest copyWith(
          void Function(CalendarUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as CalendarUpdateRequest))
          as CalendarUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarUpdateRequest create() => CalendarUpdateRequest._();
  @$core.override
  CalendarUpdateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarUpdateRequest>(create);
  static CalendarUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Calendar get calendar => $_getN(0);
  @$pb.TagNumber(1)
  set calendar($0.Calendar value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCalendar() => $_has(0);
  @$pb.TagNumber(1)
  void clearCalendar() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Calendar ensureCalendar() => $_ensure(0);
}

class CalendarUpdateResponse extends $pb.GeneratedMessage {
  factory CalendarUpdateResponse({
    $0.Calendar? calendar,
  }) {
    final result = create();
    if (calendar != null) result.calendar = calendar;
    return result;
  }

  CalendarUpdateResponse._();

  factory CalendarUpdateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarUpdateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarUpdateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..aOM<$0.Calendar>(1, _omitFieldNames ? '' : 'calendar',
        subBuilder: $0.Calendar.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarUpdateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarUpdateResponse copyWith(
          void Function(CalendarUpdateResponse) updates) =>
      super.copyWith((message) => updates(message as CalendarUpdateResponse))
          as CalendarUpdateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarUpdateResponse create() => CalendarUpdateResponse._();
  @$core.override
  CalendarUpdateResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarUpdateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarUpdateResponse>(create);
  static CalendarUpdateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Calendar get calendar => $_getN(0);
  @$pb.TagNumber(1)
  set calendar($0.Calendar value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCalendar() => $_has(0);
  @$pb.TagNumber(1)
  void clearCalendar() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Calendar ensureCalendar() => $_ensure(0);
}

class CalendarDeleteRequest extends $pb.GeneratedMessage {
  factory CalendarDeleteRequest({
    $fixnum.Int64? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  CalendarDeleteRequest._();

  factory CalendarDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarDeleteRequest copyWith(
          void Function(CalendarDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as CalendarDeleteRequest))
          as CalendarDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarDeleteRequest create() => CalendarDeleteRequest._();
  @$core.override
  CalendarDeleteRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarDeleteRequest>(create);
  static CalendarDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class CalendarDeleteResponse extends $pb.GeneratedMessage {
  factory CalendarDeleteResponse() => create();

  CalendarDeleteResponse._();

  factory CalendarDeleteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarDeleteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarDeleteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarDeleteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarDeleteResponse copyWith(
          void Function(CalendarDeleteResponse) updates) =>
      super.copyWith((message) => updates(message as CalendarDeleteResponse))
          as CalendarDeleteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarDeleteResponse create() => CalendarDeleteResponse._();
  @$core.override
  CalendarDeleteResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarDeleteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarDeleteResponse>(create);
  static CalendarDeleteResponse? _defaultInstance;
}

class CalendarSearchRequest extends $pb.GeneratedMessage {
  factory CalendarSearchRequest({
    $core.String? key,
    $core.int? limit,
    $core.int? offset,
  }) {
    final result = create();
    if (key != null) result.key = key;
    if (limit != null) result.limit = limit;
    if (offset != null) result.offset = offset;
    return result;
  }

  CalendarSearchRequest._();

  factory CalendarSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aI(2, _omitFieldNames ? '' : 'limit')
    ..aI(3, _omitFieldNames ? '' : 'offset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarSearchRequest copyWith(
          void Function(CalendarSearchRequest) updates) =>
      super.copyWith((message) => updates(message as CalendarSearchRequest))
          as CalendarSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarSearchRequest create() => CalendarSearchRequest._();
  @$core.override
  CalendarSearchRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarSearchRequest>(create);
  static CalendarSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get offset => $_getIZ(2);
  @$pb.TagNumber(3)
  set offset($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOffset() => $_has(2);
  @$pb.TagNumber(3)
  void clearOffset() => $_clearField(3);
}

class CalendarSearchResponse extends $pb.GeneratedMessage {
  factory CalendarSearchResponse({
    $core.Iterable<$0.Calendar>? calendars,
  }) {
    final result = create();
    if (calendars != null) result.calendars.addAll(calendars);
    return result;
  }

  CalendarSearchResponse._();

  factory CalendarSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..pPM<$0.Calendar>(1, _omitFieldNames ? '' : 'calendars',
        subBuilder: $0.Calendar.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarSearchResponse copyWith(
          void Function(CalendarSearchResponse) updates) =>
      super.copyWith((message) => updates(message as CalendarSearchResponse))
          as CalendarSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarSearchResponse create() => CalendarSearchResponse._();
  @$core.override
  CalendarSearchResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarSearchResponse>(create);
  static CalendarSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.Calendar> get calendars => $_getList(0);
}

class CalendarPushListRequest extends $pb.GeneratedMessage {
  factory CalendarPushListRequest({
    $core.Iterable<$0.Calendar>? calendars,
  }) {
    final result = create();
    if (calendars != null) result.calendars.addAll(calendars);
    return result;
  }

  CalendarPushListRequest._();

  factory CalendarPushListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarPushListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarPushListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..pPM<$0.Calendar>(1, _omitFieldNames ? '' : 'calendars',
        subBuilder: $0.Calendar.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarPushListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarPushListRequest copyWith(
          void Function(CalendarPushListRequest) updates) =>
      super.copyWith((message) => updates(message as CalendarPushListRequest))
          as CalendarPushListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarPushListRequest create() => CalendarPushListRequest._();
  @$core.override
  CalendarPushListRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarPushListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarPushListRequest>(create);
  static CalendarPushListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.Calendar> get calendars => $_getList(0);
}

class CalendarSubscribeRequest extends $pb.GeneratedMessage {
  factory CalendarSubscribeRequest({
    $fixnum.Int64? id,
    $core.bool? subscribe,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (subscribe != null) result.subscribe = subscribe;
    return result;
  }

  CalendarSubscribeRequest._();

  factory CalendarSubscribeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarSubscribeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarSubscribeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOB(2, _omitFieldNames ? '' : 'subscribe')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarSubscribeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarSubscribeRequest copyWith(
          void Function(CalendarSubscribeRequest) updates) =>
      super.copyWith((message) => updates(message as CalendarSubscribeRequest))
          as CalendarSubscribeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarSubscribeRequest create() => CalendarSubscribeRequest._();
  @$core.override
  CalendarSubscribeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarSubscribeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarSubscribeRequest>(create);
  static CalendarSubscribeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get subscribe => $_getBF(1);
  @$pb.TagNumber(2)
  set subscribe($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSubscribe() => $_has(1);
  @$pb.TagNumber(2)
  void clearSubscribe() => $_clearField(2);
}

class CalendarSubscribeResponse extends $pb.GeneratedMessage {
  factory CalendarSubscribeResponse() => create();

  CalendarSubscribeResponse._();

  factory CalendarSubscribeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarSubscribeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarSubscribeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarSubscribeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarSubscribeResponse copyWith(
          void Function(CalendarSubscribeResponse) updates) =>
      super.copyWith((message) => updates(message as CalendarSubscribeResponse))
          as CalendarSubscribeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarSubscribeResponse create() => CalendarSubscribeResponse._();
  @$core.override
  CalendarSubscribeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarSubscribeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarSubscribeResponse>(create);
  static CalendarSubscribeResponse? _defaultInstance;
}

class CalendarPushUpdateRequest extends $pb.GeneratedMessage {
  factory CalendarPushUpdateRequest({
    $0.Calendar? calendar,
  }) {
    final result = create();
    if (calendar != null) result.calendar = calendar;
    return result;
  }

  CalendarPushUpdateRequest._();

  factory CalendarPushUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarPushUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarPushUpdateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..aOM<$0.Calendar>(1, _omitFieldNames ? '' : 'calendar',
        subBuilder: $0.Calendar.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarPushUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarPushUpdateRequest copyWith(
          void Function(CalendarPushUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as CalendarPushUpdateRequest))
          as CalendarPushUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarPushUpdateRequest create() => CalendarPushUpdateRequest._();
  @$core.override
  CalendarPushUpdateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarPushUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarPushUpdateRequest>(create);
  static CalendarPushUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Calendar get calendar => $_getN(0);
  @$pb.TagNumber(1)
  set calendar($0.Calendar value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCalendar() => $_has(0);
  @$pb.TagNumber(1)
  void clearCalendar() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Calendar ensureCalendar() => $_ensure(0);
}

class ScheduleCreateRequest extends $pb.GeneratedMessage {
  factory ScheduleCreateRequest({
    $0.Schedule? schedule,
  }) {
    final result = create();
    if (schedule != null) result.schedule = schedule;
    return result;
  }

  ScheduleCreateRequest._();

  factory ScheduleCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScheduleCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScheduleCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..aOM<$0.Schedule>(1, _omitFieldNames ? '' : 'schedule',
        subBuilder: $0.Schedule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleCreateRequest copyWith(
          void Function(ScheduleCreateRequest) updates) =>
      super.copyWith((message) => updates(message as ScheduleCreateRequest))
          as ScheduleCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScheduleCreateRequest create() => ScheduleCreateRequest._();
  @$core.override
  ScheduleCreateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScheduleCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScheduleCreateRequest>(create);
  static ScheduleCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Schedule get schedule => $_getN(0);
  @$pb.TagNumber(1)
  set schedule($0.Schedule value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSchedule() => $_has(0);
  @$pb.TagNumber(1)
  void clearSchedule() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Schedule ensureSchedule() => $_ensure(0);
}

class ScheduleCreateResponse extends $pb.GeneratedMessage {
  factory ScheduleCreateResponse({
    $0.Schedule? schedule,
  }) {
    final result = create();
    if (schedule != null) result.schedule = schedule;
    return result;
  }

  ScheduleCreateResponse._();

  factory ScheduleCreateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScheduleCreateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScheduleCreateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..aOM<$0.Schedule>(1, _omitFieldNames ? '' : 'schedule',
        subBuilder: $0.Schedule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleCreateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleCreateResponse copyWith(
          void Function(ScheduleCreateResponse) updates) =>
      super.copyWith((message) => updates(message as ScheduleCreateResponse))
          as ScheduleCreateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScheduleCreateResponse create() => ScheduleCreateResponse._();
  @$core.override
  ScheduleCreateResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScheduleCreateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScheduleCreateResponse>(create);
  static ScheduleCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Schedule get schedule => $_getN(0);
  @$pb.TagNumber(1)
  set schedule($0.Schedule value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSchedule() => $_has(0);
  @$pb.TagNumber(1)
  void clearSchedule() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Schedule ensureSchedule() => $_ensure(0);
}

class ScheduleRemoveRequest extends $pb.GeneratedMessage {
  factory ScheduleRemoveRequest({
    $fixnum.Int64? id,
    $fixnum.Int64? cycleId,
    $core.int? modifyScope,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (cycleId != null) result.cycleId = cycleId;
    if (modifyScope != null) result.modifyScope = modifyScope;
    return result;
  }

  ScheduleRemoveRequest._();

  factory ScheduleRemoveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScheduleRemoveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScheduleRemoveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'cycleId')
    ..aI(3, _omitFieldNames ? '' : 'modifyScope')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleRemoveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleRemoveRequest copyWith(
          void Function(ScheduleRemoveRequest) updates) =>
      super.copyWith((message) => updates(message as ScheduleRemoveRequest))
          as ScheduleRemoveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScheduleRemoveRequest create() => ScheduleRemoveRequest._();
  @$core.override
  ScheduleRemoveRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScheduleRemoveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScheduleRemoveRequest>(create);
  static ScheduleRemoveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get cycleId => $_getI64(1);
  @$pb.TagNumber(2)
  set cycleId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCycleId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCycleId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get modifyScope => $_getIZ(2);
  @$pb.TagNumber(3)
  set modifyScope($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasModifyScope() => $_has(2);
  @$pb.TagNumber(3)
  void clearModifyScope() => $_clearField(3);
}

class ScheduleRemoveResponse extends $pb.GeneratedMessage {
  factory ScheduleRemoveResponse() => create();

  ScheduleRemoveResponse._();

  factory ScheduleRemoveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScheduleRemoveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScheduleRemoveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleRemoveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleRemoveResponse copyWith(
          void Function(ScheduleRemoveResponse) updates) =>
      super.copyWith((message) => updates(message as ScheduleRemoveResponse))
          as ScheduleRemoveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScheduleRemoveResponse create() => ScheduleRemoveResponse._();
  @$core.override
  ScheduleRemoveResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScheduleRemoveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScheduleRemoveResponse>(create);
  static ScheduleRemoveResponse? _defaultInstance;
}

class ScheduleUpdateRequest extends $pb.GeneratedMessage {
  factory ScheduleUpdateRequest({
    $0.Schedule? schedule,
    $core.int? modifyScope,
  }) {
    final result = create();
    if (schedule != null) result.schedule = schedule;
    if (modifyScope != null) result.modifyScope = modifyScope;
    return result;
  }

  ScheduleUpdateRequest._();

  factory ScheduleUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScheduleUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScheduleUpdateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..aOM<$0.Schedule>(1, _omitFieldNames ? '' : 'schedule',
        subBuilder: $0.Schedule.create)
    ..aI(3, _omitFieldNames ? '' : 'modifyScope')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleUpdateRequest copyWith(
          void Function(ScheduleUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as ScheduleUpdateRequest))
          as ScheduleUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScheduleUpdateRequest create() => ScheduleUpdateRequest._();
  @$core.override
  ScheduleUpdateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScheduleUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScheduleUpdateRequest>(create);
  static ScheduleUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Schedule get schedule => $_getN(0);
  @$pb.TagNumber(1)
  set schedule($0.Schedule value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSchedule() => $_has(0);
  @$pb.TagNumber(1)
  void clearSchedule() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Schedule ensureSchedule() => $_ensure(0);

  @$pb.TagNumber(3)
  $core.int get modifyScope => $_getIZ(1);
  @$pb.TagNumber(3)
  set modifyScope($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(3)
  $core.bool hasModifyScope() => $_has(1);
  @$pb.TagNumber(3)
  void clearModifyScope() => $_clearField(3);
}

class ScheduleUpdateResponse extends $pb.GeneratedMessage {
  factory ScheduleUpdateResponse({
    $0.Schedule? schedule,
  }) {
    final result = create();
    if (schedule != null) result.schedule = schedule;
    return result;
  }

  ScheduleUpdateResponse._();

  factory ScheduleUpdateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScheduleUpdateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScheduleUpdateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..aOM<$0.Schedule>(1, _omitFieldNames ? '' : 'schedule',
        subBuilder: $0.Schedule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleUpdateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleUpdateResponse copyWith(
          void Function(ScheduleUpdateResponse) updates) =>
      super.copyWith((message) => updates(message as ScheduleUpdateResponse))
          as ScheduleUpdateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScheduleUpdateResponse create() => ScheduleUpdateResponse._();
  @$core.override
  ScheduleUpdateResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScheduleUpdateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScheduleUpdateResponse>(create);
  static ScheduleUpdateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Schedule get schedule => $_getN(0);
  @$pb.TagNumber(1)
  set schedule($0.Schedule value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSchedule() => $_has(0);
  @$pb.TagNumber(1)
  void clearSchedule() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Schedule ensureSchedule() => $_ensure(0);
}

class SchedulePullByIdsRequest extends $pb.GeneratedMessage {
  factory SchedulePullByIdsRequest({
    $fixnum.Int64? calendarId,
    $core.Iterable<$fixnum.Int64>? ids,
  }) {
    final result = create();
    if (calendarId != null) result.calendarId = calendarId;
    if (ids != null) result.ids.addAll(ids);
    return result;
  }

  SchedulePullByIdsRequest._();

  factory SchedulePullByIdsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SchedulePullByIdsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SchedulePullByIdsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'calendarId')
    ..p<$fixnum.Int64>(2, _omitFieldNames ? '' : 'ids', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePullByIdsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePullByIdsRequest copyWith(
          void Function(SchedulePullByIdsRequest) updates) =>
      super.copyWith((message) => updates(message as SchedulePullByIdsRequest))
          as SchedulePullByIdsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SchedulePullByIdsRequest create() => SchedulePullByIdsRequest._();
  @$core.override
  SchedulePullByIdsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SchedulePullByIdsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SchedulePullByIdsRequest>(create);
  static SchedulePullByIdsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get calendarId => $_getI64(0);
  @$pb.TagNumber(1)
  set calendarId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCalendarId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCalendarId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$fixnum.Int64> get ids => $_getList(1);
}

class SchedulePullByIdsResponse extends $pb.GeneratedMessage {
  factory SchedulePullByIdsResponse({
    $core.Iterable<$0.Schedule>? schedules,
    $0.Entity? entity,
  }) {
    final result = create();
    if (schedules != null) result.schedules.addAll(schedules);
    if (entity != null) result.entity = entity;
    return result;
  }

  SchedulePullByIdsResponse._();

  factory SchedulePullByIdsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SchedulePullByIdsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SchedulePullByIdsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..pPM<$0.Schedule>(1, _omitFieldNames ? '' : 'schedules',
        subBuilder: $0.Schedule.create)
    ..aOM<$0.Entity>(2, _omitFieldNames ? '' : 'entity',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePullByIdsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePullByIdsResponse copyWith(
          void Function(SchedulePullByIdsResponse) updates) =>
      super.copyWith((message) => updates(message as SchedulePullByIdsResponse))
          as SchedulePullByIdsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SchedulePullByIdsResponse create() => SchedulePullByIdsResponse._();
  @$core.override
  SchedulePullByIdsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SchedulePullByIdsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SchedulePullByIdsResponse>(create);
  static SchedulePullByIdsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.Schedule> get schedules => $_getList(0);

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

class SchedulePullByCalendarIdsRequest extends $pb.GeneratedMessage {
  factory SchedulePullByCalendarIdsRequest({
    $core.Iterable<$fixnum.Int64>? calendarIds,
    $fixnum.Int64? startTime,
    $fixnum.Int64? endTime,
  }) {
    final result = create();
    if (calendarIds != null) result.calendarIds.addAll(calendarIds);
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    return result;
  }

  SchedulePullByCalendarIdsRequest._();

  factory SchedulePullByCalendarIdsRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SchedulePullByCalendarIdsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SchedulePullByCalendarIdsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..p<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'calendarIds', $pb.PbFieldType.K6)
    ..aInt64(2, _omitFieldNames ? '' : 'startTime')
    ..aInt64(3, _omitFieldNames ? '' : 'endTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePullByCalendarIdsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePullByCalendarIdsRequest copyWith(
          void Function(SchedulePullByCalendarIdsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SchedulePullByCalendarIdsRequest))
          as SchedulePullByCalendarIdsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SchedulePullByCalendarIdsRequest create() =>
      SchedulePullByCalendarIdsRequest._();
  @$core.override
  SchedulePullByCalendarIdsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SchedulePullByCalendarIdsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SchedulePullByCalendarIdsRequest>(
          create);
  static SchedulePullByCalendarIdsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$fixnum.Int64> get calendarIds => $_getList(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startTime => $_getI64(1);
  @$pb.TagNumber(2)
  set startTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get endTime => $_getI64(2);
  @$pb.TagNumber(3)
  set endTime($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEndTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndTime() => $_clearField(3);
}

class SchedulePullByCalendarIdsResponse extends $pb.GeneratedMessage {
  factory SchedulePullByCalendarIdsResponse({
    $core.Iterable<$0.Schedule>? schedules,
  }) {
    final result = create();
    if (schedules != null) result.schedules.addAll(schedules);
    return result;
  }

  SchedulePullByCalendarIdsResponse._();

  factory SchedulePullByCalendarIdsResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SchedulePullByCalendarIdsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SchedulePullByCalendarIdsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..pPM<$0.Schedule>(1, _omitFieldNames ? '' : 'schedules',
        subBuilder: $0.Schedule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePullByCalendarIdsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePullByCalendarIdsResponse copyWith(
          void Function(SchedulePullByCalendarIdsResponse) updates) =>
      super.copyWith((message) =>
              updates(message as SchedulePullByCalendarIdsResponse))
          as SchedulePullByCalendarIdsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SchedulePullByCalendarIdsResponse create() =>
      SchedulePullByCalendarIdsResponse._();
  @$core.override
  SchedulePullByCalendarIdsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SchedulePullByCalendarIdsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SchedulePullByCalendarIdsResponse>(
          create);
  static SchedulePullByCalendarIdsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.Schedule> get schedules => $_getList(0);
}

class SchedulePullBusyRequest extends $pb.GeneratedMessage {
  factory SchedulePullBusyRequest({
    $core.Iterable<$fixnum.Int64>? userIds,
    $fixnum.Int64? startTime,
    $fixnum.Int64? endTime,
  }) {
    final result = create();
    if (userIds != null) result.userIds.addAll(userIds);
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    return result;
  }

  SchedulePullBusyRequest._();

  factory SchedulePullBusyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SchedulePullBusyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SchedulePullBusyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..p<$fixnum.Int64>(1, _omitFieldNames ? '' : 'userIds', $pb.PbFieldType.K6)
    ..aInt64(2, _omitFieldNames ? '' : 'startTime')
    ..aInt64(3, _omitFieldNames ? '' : 'endTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePullBusyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePullBusyRequest copyWith(
          void Function(SchedulePullBusyRequest) updates) =>
      super.copyWith((message) => updates(message as SchedulePullBusyRequest))
          as SchedulePullBusyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SchedulePullBusyRequest create() => SchedulePullBusyRequest._();
  @$core.override
  SchedulePullBusyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SchedulePullBusyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SchedulePullBusyRequest>(create);
  static SchedulePullBusyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$fixnum.Int64> get userIds => $_getList(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startTime => $_getI64(1);
  @$pb.TagNumber(2)
  set startTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get endTime => $_getI64(2);
  @$pb.TagNumber(3)
  set endTime($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEndTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndTime() => $_clearField(3);
}

class SchedulePullBusyResponse extends $pb.GeneratedMessage {
  factory SchedulePullBusyResponse({
    $core.Iterable<$core.MapEntry<$fixnum.Int64, $0.UserScheduleBrief>>?
        schedules,
  }) {
    final result = create();
    if (schedules != null) result.schedules.addEntries(schedules);
    return result;
  }

  SchedulePullBusyResponse._();

  factory SchedulePullBusyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SchedulePullBusyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SchedulePullBusyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..m<$fixnum.Int64, $0.UserScheduleBrief>(
        1, _omitFieldNames ? '' : 'schedules',
        entryClassName: 'SchedulePullBusyResponse.SchedulesEntry',
        keyFieldType: $pb.PbFieldType.O6,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: $0.UserScheduleBrief.create,
        valueDefaultOrMaker: $0.UserScheduleBrief.getDefault,
        packageName: const $pb.PackageName('calendar'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePullBusyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePullBusyResponse copyWith(
          void Function(SchedulePullBusyResponse) updates) =>
      super.copyWith((message) => updates(message as SchedulePullBusyResponse))
          as SchedulePullBusyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SchedulePullBusyResponse create() => SchedulePullBusyResponse._();
  @$core.override
  SchedulePullBusyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SchedulePullBusyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SchedulePullBusyResponse>(create);
  static SchedulePullBusyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$fixnum.Int64, $0.UserScheduleBrief> get schedules => $_getMap(0);
}

class SchedulePushUpdateRequest extends $pb.GeneratedMessage {
  factory SchedulePushUpdateRequest({
    $core.Iterable<$0.Schedule>? schedules,
  }) {
    final result = create();
    if (schedules != null) result.schedules.addAll(schedules);
    return result;
  }

  SchedulePushUpdateRequest._();

  factory SchedulePushUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SchedulePushUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SchedulePushUpdateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..pPM<$0.Schedule>(1, _omitFieldNames ? '' : 'schedules',
        subBuilder: $0.Schedule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePushUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePushUpdateRequest copyWith(
          void Function(SchedulePushUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as SchedulePushUpdateRequest))
          as SchedulePushUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SchedulePushUpdateRequest create() => SchedulePushUpdateRequest._();
  @$core.override
  SchedulePushUpdateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SchedulePushUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SchedulePushUpdateRequest>(create);
  static SchedulePushUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.Schedule> get schedules => $_getList(0);
}

class SchedulePullByCycleRequest extends $pb.GeneratedMessage {
  factory SchedulePullByCycleRequest({
    $fixnum.Int64? ruleId,
    $fixnum.Int64? startAt,
    $fixnum.Int64? endAt,
  }) {
    final result = create();
    if (ruleId != null) result.ruleId = ruleId;
    if (startAt != null) result.startAt = startAt;
    if (endAt != null) result.endAt = endAt;
    return result;
  }

  SchedulePullByCycleRequest._();

  factory SchedulePullByCycleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SchedulePullByCycleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SchedulePullByCycleRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'ruleId')
    ..aInt64(2, _omitFieldNames ? '' : 'startAt')
    ..aInt64(3, _omitFieldNames ? '' : 'endAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePullByCycleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePullByCycleRequest copyWith(
          void Function(SchedulePullByCycleRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SchedulePullByCycleRequest))
          as SchedulePullByCycleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SchedulePullByCycleRequest create() => SchedulePullByCycleRequest._();
  @$core.override
  SchedulePullByCycleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SchedulePullByCycleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SchedulePullByCycleRequest>(create);
  static SchedulePullByCycleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get ruleId => $_getI64(0);
  @$pb.TagNumber(1)
  set ruleId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRuleId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRuleId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startAt => $_getI64(1);
  @$pb.TagNumber(2)
  set startAt($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartAt() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get endAt => $_getI64(2);
  @$pb.TagNumber(3)
  set endAt($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEndAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndAt() => $_clearField(3);
}

class SchedulePullByCycleResponse extends $pb.GeneratedMessage {
  factory SchedulePullByCycleResponse({
    $core.Iterable<$0.Schedule>? schedules,
  }) {
    final result = create();
    if (schedules != null) result.schedules.addAll(schedules);
    return result;
  }

  SchedulePullByCycleResponse._();

  factory SchedulePullByCycleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SchedulePullByCycleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SchedulePullByCycleResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..pPM<$0.Schedule>(1, _omitFieldNames ? '' : 'schedules',
        subBuilder: $0.Schedule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePullByCycleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePullByCycleResponse copyWith(
          void Function(SchedulePullByCycleResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SchedulePullByCycleResponse))
          as SchedulePullByCycleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SchedulePullByCycleResponse create() =>
      SchedulePullByCycleResponse._();
  @$core.override
  SchedulePullByCycleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SchedulePullByCycleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SchedulePullByCycleResponse>(create);
  static SchedulePullByCycleResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.Schedule> get schedules => $_getList(0);
}

/// 服务端/SDK → 客户端：日程变更影响范围推送
class SchedulePushByRange extends $pb.GeneratedMessage {
  factory SchedulePushByRange({
    $core.Iterable<$fixnum.Int64>? calendarIds,
    $fixnum.Int64? startTime,
    $fixnum.Int64? endTime,
  }) {
    final result = create();
    if (calendarIds != null) result.calendarIds.addAll(calendarIds);
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    return result;
  }

  SchedulePushByRange._();

  factory SchedulePushByRange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SchedulePushByRange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SchedulePushByRange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..p<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'calendarIds', $pb.PbFieldType.K6)
    ..aInt64(2, _omitFieldNames ? '' : 'startTime')
    ..aInt64(3, _omitFieldNames ? '' : 'endTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePushByRange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SchedulePushByRange copyWith(void Function(SchedulePushByRange) updates) =>
      super.copyWith((message) => updates(message as SchedulePushByRange))
          as SchedulePushByRange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SchedulePushByRange create() => SchedulePushByRange._();
  @$core.override
  SchedulePushByRange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SchedulePushByRange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SchedulePushByRange>(create);
  static SchedulePushByRange? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$fixnum.Int64> get calendarIds => $_getList(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startTime => $_getI64(1);
  @$pb.TagNumber(2)
  set startTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get endTime => $_getI64(2);
  @$pb.TagNumber(3)
  set endTime($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEndTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndTime() => $_clearField(3);
}

/// 服务端→客户端：批量日程删除推送
class ScheduleDeletePush extends $pb.GeneratedMessage {
  factory ScheduleDeletePush({
    $core.Iterable<$fixnum.Int64>? ids,
    $fixnum.Int64? cycleRuleId,
    $fixnum.Int64? startTime,
  }) {
    final result = create();
    if (ids != null) result.ids.addAll(ids);
    if (cycleRuleId != null) result.cycleRuleId = cycleRuleId;
    if (startTime != null) result.startTime = startTime;
    return result;
  }

  ScheduleDeletePush._();

  factory ScheduleDeletePush.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScheduleDeletePush.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScheduleDeletePush',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..p<$fixnum.Int64>(1, _omitFieldNames ? '' : 'ids', $pb.PbFieldType.K6)
    ..aInt64(2, _omitFieldNames ? '' : 'cycleRuleId')
    ..aInt64(3, _omitFieldNames ? '' : 'startTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleDeletePush clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleDeletePush copyWith(void Function(ScheduleDeletePush) updates) =>
      super.copyWith((message) => updates(message as ScheduleDeletePush))
          as ScheduleDeletePush;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScheduleDeletePush create() => ScheduleDeletePush._();
  @$core.override
  ScheduleDeletePush createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScheduleDeletePush getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScheduleDeletePush>(create);
  static ScheduleDeletePush? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$fixnum.Int64> get ids => $_getList(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get cycleRuleId => $_getI64(1);
  @$pb.TagNumber(2)
  set cycleRuleId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCycleRuleId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCycleRuleId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get startTime => $_getI64(2);
  @$pb.TagNumber(3)
  set startTime($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStartTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearStartTime() => $_clearField(3);
}

/// 服务端→客户端：日程提醒推送
class ScheduleRemindPush extends $pb.GeneratedMessage {
  factory ScheduleRemindPush({
    $fixnum.Int64? scheduleId,
    $fixnum.Int64? startTime,
    $fixnum.Int64? endTime,
    $core.String? title,
    $core.String? location,
    $core.int? notifyMinute,
  }) {
    final result = create();
    if (scheduleId != null) result.scheduleId = scheduleId;
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    if (title != null) result.title = title;
    if (location != null) result.location = location;
    if (notifyMinute != null) result.notifyMinute = notifyMinute;
    return result;
  }

  ScheduleRemindPush._();

  factory ScheduleRemindPush.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScheduleRemindPush.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScheduleRemindPush',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'calendar'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'scheduleId')
    ..aInt64(2, _omitFieldNames ? '' : 'startTime')
    ..aInt64(3, _omitFieldNames ? '' : 'endTime')
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aOS(5, _omitFieldNames ? '' : 'location')
    ..aI(6, _omitFieldNames ? '' : 'notifyMinute')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleRemindPush clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleRemindPush copyWith(void Function(ScheduleRemindPush) updates) =>
      super.copyWith((message) => updates(message as ScheduleRemindPush))
          as ScheduleRemindPush;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScheduleRemindPush create() => ScheduleRemindPush._();
  @$core.override
  ScheduleRemindPush createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScheduleRemindPush getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScheduleRemindPush>(create);
  static ScheduleRemindPush? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get scheduleId => $_getI64(0);
  @$pb.TagNumber(1)
  set scheduleId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasScheduleId() => $_has(0);
  @$pb.TagNumber(1)
  void clearScheduleId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startTime => $_getI64(1);
  @$pb.TagNumber(2)
  set startTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get endTime => $_getI64(2);
  @$pb.TagNumber(3)
  set endTime($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEndTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndTime() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get title => $_getSZ(3);
  @$pb.TagNumber(4)
  set title($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTitle() => $_has(3);
  @$pb.TagNumber(4)
  void clearTitle() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get location => $_getSZ(4);
  @$pb.TagNumber(5)
  set location($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLocation() => $_has(4);
  @$pb.TagNumber(5)
  void clearLocation() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get notifyMinute => $_getIZ(5);
  @$pb.TagNumber(6)
  set notifyMinute($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNotifyMinute() => $_has(5);
  @$pb.TagNumber(6)
  void clearNotifyMinute() => $_clearField(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
