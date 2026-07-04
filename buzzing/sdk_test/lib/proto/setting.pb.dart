// This is a generated file - do not edit.
//
// Generated from setting.proto.

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

class GetAllSettingsRequest extends $pb.GeneratedMessage {
  factory GetAllSettingsRequest() => create();

  GetAllSettingsRequest._();

  factory GetAllSettingsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAllSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAllSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'setting'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAllSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAllSettingsRequest copyWith(
          void Function(GetAllSettingsRequest) updates) =>
      super.copyWith((message) => updates(message as GetAllSettingsRequest))
          as GetAllSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAllSettingsRequest create() => GetAllSettingsRequest._();
  @$core.override
  GetAllSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAllSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAllSettingsRequest>(create);
  static GetAllSettingsRequest? _defaultInstance;
}

class GetAllSettingsResponse extends $pb.GeneratedMessage {
  factory GetAllSettingsResponse({
    $0.Settings? settings,
  }) {
    final result = create();
    if (settings != null) result.settings = settings;
    return result;
  }

  GetAllSettingsResponse._();

  factory GetAllSettingsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAllSettingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAllSettingsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'setting'),
      createEmptyInstance: create)
    ..aOM<$0.Settings>(1, _omitFieldNames ? '' : 'settings',
        subBuilder: $0.Settings.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAllSettingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAllSettingsResponse copyWith(
          void Function(GetAllSettingsResponse) updates) =>
      super.copyWith((message) => updates(message as GetAllSettingsResponse))
          as GetAllSettingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAllSettingsResponse create() => GetAllSettingsResponse._();
  @$core.override
  GetAllSettingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAllSettingsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAllSettingsResponse>(create);
  static GetAllSettingsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Settings get settings => $_getN(0);
  @$pb.TagNumber(1)
  set settings($0.Settings value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSettings() => $_has(0);
  @$pb.TagNumber(1)
  void clearSettings() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Settings ensureSettings() => $_ensure(0);
}

class GetSettingByTypeRequest extends $pb.GeneratedMessage {
  factory GetSettingByTypeRequest({
    $core.int? type,
  }) {
    final result = create();
    if (type != null) result.type = type;
    return result;
  }

  GetSettingByTypeRequest._();

  factory GetSettingByTypeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSettingByTypeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSettingByTypeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'setting'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'type')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSettingByTypeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSettingByTypeRequest copyWith(
          void Function(GetSettingByTypeRequest) updates) =>
      super.copyWith((message) => updates(message as GetSettingByTypeRequest))
          as GetSettingByTypeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSettingByTypeRequest create() => GetSettingByTypeRequest._();
  @$core.override
  GetSettingByTypeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSettingByTypeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSettingByTypeRequest>(create);
  static GetSettingByTypeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);
}

class GetSettingByTypeResponse extends $pb.GeneratedMessage {
  factory GetSettingByTypeResponse({
    $0.Setting? setting,
  }) {
    final result = create();
    if (setting != null) result.setting = setting;
    return result;
  }

  GetSettingByTypeResponse._();

  factory GetSettingByTypeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSettingByTypeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSettingByTypeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'setting'),
      createEmptyInstance: create)
    ..aOM<$0.Setting>(1, _omitFieldNames ? '' : 'setting',
        subBuilder: $0.Setting.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSettingByTypeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSettingByTypeResponse copyWith(
          void Function(GetSettingByTypeResponse) updates) =>
      super.copyWith((message) => updates(message as GetSettingByTypeResponse))
          as GetSettingByTypeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSettingByTypeResponse create() => GetSettingByTypeResponse._();
  @$core.override
  GetSettingByTypeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSettingByTypeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSettingByTypeResponse>(create);
  static GetSettingByTypeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Setting get setting => $_getN(0);
  @$pb.TagNumber(1)
  set setting($0.Setting value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSetting() => $_has(0);
  @$pb.TagNumber(1)
  void clearSetting() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Setting ensureSetting() => $_ensure(0);
}

class GetSettingByVersionRequest extends $pb.GeneratedMessage {
  factory GetSettingByVersionRequest({
    $fixnum.Int64? version,
  }) {
    final result = create();
    if (version != null) result.version = version;
    return result;
  }

  GetSettingByVersionRequest._();

  factory GetSettingByVersionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSettingByVersionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSettingByVersionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'setting'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSettingByVersionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSettingByVersionRequest copyWith(
          void Function(GetSettingByVersionRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetSettingByVersionRequest))
          as GetSettingByVersionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSettingByVersionRequest create() => GetSettingByVersionRequest._();
  @$core.override
  GetSettingByVersionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSettingByVersionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSettingByVersionRequest>(create);
  static GetSettingByVersionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get version => $_getI64(0);
  @$pb.TagNumber(1)
  set version($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);
}

class GetSettingByVersionResponse extends $pb.GeneratedMessage {
  factory GetSettingByVersionResponse({
    $0.Setting? settings,
  }) {
    final result = create();
    if (settings != null) result.settings = settings;
    return result;
  }

  GetSettingByVersionResponse._();

  factory GetSettingByVersionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSettingByVersionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSettingByVersionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'setting'),
      createEmptyInstance: create)
    ..aOM<$0.Setting>(1, _omitFieldNames ? '' : 'settings',
        subBuilder: $0.Setting.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSettingByVersionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSettingByVersionResponse copyWith(
          void Function(GetSettingByVersionResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetSettingByVersionResponse))
          as GetSettingByVersionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSettingByVersionResponse create() =>
      GetSettingByVersionResponse._();
  @$core.override
  GetSettingByVersionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSettingByVersionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSettingByVersionResponse>(create);
  static GetSettingByVersionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Setting get settings => $_getN(0);
  @$pb.TagNumber(1)
  set settings($0.Setting value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSettings() => $_has(0);
  @$pb.TagNumber(1)
  void clearSettings() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Setting ensureSettings() => $_ensure(0);
}

class PushSettingsRequest extends $pb.GeneratedMessage {
  factory PushSettingsRequest({
    $0.Settings? settings,
  }) {
    final result = create();
    if (settings != null) result.settings = settings;
    return result;
  }

  PushSettingsRequest._();

  factory PushSettingsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'setting'),
      createEmptyInstance: create)
    ..aOM<$0.Settings>(1, _omitFieldNames ? '' : 'settings',
        subBuilder: $0.Settings.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushSettingsRequest copyWith(void Function(PushSettingsRequest) updates) =>
      super.copyWith((message) => updates(message as PushSettingsRequest))
          as PushSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushSettingsRequest create() => PushSettingsRequest._();
  @$core.override
  PushSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushSettingsRequest>(create);
  static PushSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Settings get settings => $_getN(0);
  @$pb.TagNumber(1)
  set settings($0.Settings value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSettings() => $_has(0);
  @$pb.TagNumber(1)
  void clearSettings() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Settings ensureSettings() => $_ensure(0);
}

class UpdateSettingRequest extends $pb.GeneratedMessage {
  factory UpdateSettingRequest({
    $core.int? type,
    $core.List<$core.int>? value,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (value != null) result.value = value;
    return result;
  }

  UpdateSettingRequest._();

  factory UpdateSettingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateSettingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateSettingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'setting'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'type')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'value', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSettingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSettingRequest copyWith(void Function(UpdateSettingRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateSettingRequest))
          as UpdateSettingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateSettingRequest create() => UpdateSettingRequest._();
  @$core.override
  UpdateSettingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateSettingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateSettingRequest>(create);
  static UpdateSettingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get value => $_getN(1);
  @$pb.TagNumber(2)
  set value($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
}

class UpdateSettingResponse extends $pb.GeneratedMessage {
  factory UpdateSettingResponse() => create();

  UpdateSettingResponse._();

  factory UpdateSettingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateSettingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateSettingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'setting'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSettingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSettingResponse copyWith(
          void Function(UpdateSettingResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateSettingResponse))
          as UpdateSettingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateSettingResponse create() => UpdateSettingResponse._();
  @$core.override
  UpdateSettingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateSettingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateSettingResponse>(create);
  static UpdateSettingResponse? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
