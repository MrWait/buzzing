// This is a generated file - do not edit.
//
// Generated from sdk.proto.

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
import 'sdk.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'sdk.pbenum.dart';

class InitRequest extends $pb.GeneratedMessage {
  factory InitRequest({
    $core.int? deviceType,
    $core.String? appId,
    $core.String? appVersion,
    $core.String? deviceId,
    $core.String? logPath,
    $core.String? storagePath,
    $core.String? locale,
    $core.String? commonDataPath,
    $core.String? osVersion,
    $0.EnvChannel? env,
    $core.String? pathPrefix,
    $core.String? customLogPath,
    $core.bool? isRelease,
    $core.String? deviceModel,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? settingsQueries,
    $core.String? appChannel,
  }) {
    final result = create();
    if (deviceType != null) result.deviceType = deviceType;
    if (appId != null) result.appId = appId;
    if (appVersion != null) result.appVersion = appVersion;
    if (deviceId != null) result.deviceId = deviceId;
    if (logPath != null) result.logPath = logPath;
    if (storagePath != null) result.storagePath = storagePath;
    if (locale != null) result.locale = locale;
    if (commonDataPath != null) result.commonDataPath = commonDataPath;
    if (osVersion != null) result.osVersion = osVersion;
    if (env != null) result.env = env;
    if (pathPrefix != null) result.pathPrefix = pathPrefix;
    if (customLogPath != null) result.customLogPath = customLogPath;
    if (isRelease != null) result.isRelease = isRelease;
    if (deviceModel != null) result.deviceModel = deviceModel;
    if (settingsQueries != null)
      result.settingsQueries.addEntries(settingsQueries);
    if (appChannel != null) result.appChannel = appChannel;
    return result;
  }

  InitRequest._();

  factory InitRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InitRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InitRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sdk'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'deviceType')
    ..aOS(2, _omitFieldNames ? '' : 'appId')
    ..aOS(3, _omitFieldNames ? '' : 'appVersion')
    ..aOS(4, _omitFieldNames ? '' : 'deviceId')
    ..aOS(5, _omitFieldNames ? '' : 'logPath')
    ..aOS(6, _omitFieldNames ? '' : 'storagePath')
    ..aOS(8, _omitFieldNames ? '' : 'locale')
    ..aOS(9, _omitFieldNames ? '' : 'commonDataPath')
    ..aOS(10, _omitFieldNames ? '' : 'osVersion')
    ..aE<$0.EnvChannel>(11, _omitFieldNames ? '' : 'env',
        enumValues: $0.EnvChannel.values)
    ..aOS(12, _omitFieldNames ? '' : 'pathPrefix')
    ..aOS(13, _omitFieldNames ? '' : 'customLogPath')
    ..aOB(14, _omitFieldNames ? '' : 'isRelease')
    ..aOS(15, _omitFieldNames ? '' : 'deviceModel')
    ..m<$core.String, $core.String>(
        16, _omitFieldNames ? '' : 'settingsQueries',
        entryClassName: 'InitRequest.SettingsQueriesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('sdk'))
    ..aOS(17, _omitFieldNames ? '' : 'appChannel')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitRequest copyWith(void Function(InitRequest) updates) =>
      super.copyWith((message) => updates(message as InitRequest))
          as InitRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InitRequest create() => InitRequest._();
  @$core.override
  InitRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InitRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InitRequest>(create);
  static InitRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get deviceType => $_getIZ(0);
  @$pb.TagNumber(1)
  set deviceType($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceType() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get appId => $_getSZ(1);
  @$pb.TagNumber(2)
  set appId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAppId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAppId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get appVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set appVersion($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAppVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearAppVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get deviceId => $_getSZ(3);
  @$pb.TagNumber(4)
  set deviceId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDeviceId() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeviceId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get logPath => $_getSZ(4);
  @$pb.TagNumber(5)
  set logPath($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLogPath() => $_has(4);
  @$pb.TagNumber(5)
  void clearLogPath() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get storagePath => $_getSZ(5);
  @$pb.TagNumber(6)
  set storagePath($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStoragePath() => $_has(5);
  @$pb.TagNumber(6)
  void clearStoragePath() => $_clearField(6);

  @$pb.TagNumber(8)
  $core.String get locale => $_getSZ(6);
  @$pb.TagNumber(8)
  set locale($core.String value) => $_setString(6, value);
  @$pb.TagNumber(8)
  $core.bool hasLocale() => $_has(6);
  @$pb.TagNumber(8)
  void clearLocale() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get commonDataPath => $_getSZ(7);
  @$pb.TagNumber(9)
  set commonDataPath($core.String value) => $_setString(7, value);
  @$pb.TagNumber(9)
  $core.bool hasCommonDataPath() => $_has(7);
  @$pb.TagNumber(9)
  void clearCommonDataPath() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get osVersion => $_getSZ(8);
  @$pb.TagNumber(10)
  set osVersion($core.String value) => $_setString(8, value);
  @$pb.TagNumber(10)
  $core.bool hasOsVersion() => $_has(8);
  @$pb.TagNumber(10)
  void clearOsVersion() => $_clearField(10);

  @$pb.TagNumber(11)
  $0.EnvChannel get env => $_getN(9);
  @$pb.TagNumber(11)
  set env($0.EnvChannel value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasEnv() => $_has(9);
  @$pb.TagNumber(11)
  void clearEnv() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get pathPrefix => $_getSZ(10);
  @$pb.TagNumber(12)
  set pathPrefix($core.String value) => $_setString(10, value);
  @$pb.TagNumber(12)
  $core.bool hasPathPrefix() => $_has(10);
  @$pb.TagNumber(12)
  void clearPathPrefix() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get customLogPath => $_getSZ(11);
  @$pb.TagNumber(13)
  set customLogPath($core.String value) => $_setString(11, value);
  @$pb.TagNumber(13)
  $core.bool hasCustomLogPath() => $_has(11);
  @$pb.TagNumber(13)
  void clearCustomLogPath() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get isRelease => $_getBF(12);
  @$pb.TagNumber(14)
  set isRelease($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(14)
  $core.bool hasIsRelease() => $_has(12);
  @$pb.TagNumber(14)
  void clearIsRelease() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get deviceModel => $_getSZ(13);
  @$pb.TagNumber(15)
  set deviceModel($core.String value) => $_setString(13, value);
  @$pb.TagNumber(15)
  $core.bool hasDeviceModel() => $_has(13);
  @$pb.TagNumber(15)
  void clearDeviceModel() => $_clearField(15);

  @$pb.TagNumber(16)
  $pb.PbMap<$core.String, $core.String> get settingsQueries => $_getMap(14);

  @$pb.TagNumber(17)
  $core.String get appChannel => $_getSZ(15);
  @$pb.TagNumber(17)
  set appChannel($core.String value) => $_setString(15, value);
  @$pb.TagNumber(17)
  $core.bool hasAppChannel() => $_has(15);
  @$pb.TagNumber(17)
  void clearAppChannel() => $_clearField(17);
}

class InvokeRequest extends $pb.GeneratedMessage {
  factory InvokeRequest({
    $core.int? seq,
    $core.int? command,
    $fixnum.Int64? userId,
    $core.int? source,
    $core.List<$core.int>? payload,
  }) {
    final result = create();
    if (seq != null) result.seq = seq;
    if (command != null) result.command = command;
    if (userId != null) result.userId = userId;
    if (source != null) result.source = source;
    if (payload != null) result.payload = payload;
    return result;
  }

  InvokeRequest._();

  factory InvokeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InvokeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvokeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sdk'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'seq')
    ..aI(2, _omitFieldNames ? '' : 'command')
    ..aInt64(4, _omitFieldNames ? '' : 'userId')
    ..aI(5, _omitFieldNames ? '' : 'source')
    ..a<$core.List<$core.int>>(
        20, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvokeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvokeRequest copyWith(void Function(InvokeRequest) updates) =>
      super.copyWith((message) => updates(message as InvokeRequest))
          as InvokeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvokeRequest create() => InvokeRequest._();
  @$core.override
  InvokeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InvokeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvokeRequest>(create);
  static InvokeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get seq => $_getIZ(0);
  @$pb.TagNumber(1)
  set seq($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSeq() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeq() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get command => $_getIZ(1);
  @$pb.TagNumber(2)
  set command($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommand() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommand() => $_clearField(2);

  @$pb.TagNumber(4)
  $fixnum.Int64 get userId => $_getI64(2);
  @$pb.TagNumber(4)
  set userId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(4)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(4)
  void clearUserId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get source => $_getIZ(3);
  @$pb.TagNumber(5)
  set source($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(5)
  $core.bool hasSource() => $_has(3);
  @$pb.TagNumber(5)
  void clearSource() => $_clearField(5);

  @$pb.TagNumber(20)
  $core.List<$core.int> get payload => $_getN(4);
  @$pb.TagNumber(20)
  set payload($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(20)
  $core.bool hasPayload() => $_has(4);
  @$pb.TagNumber(20)
  void clearPayload() => $_clearField(20);
}

class InvokeResponse extends $pb.GeneratedMessage {
  factory InvokeResponse({
    $core.int? seq,
    $core.int? status,
    $fixnum.Int64? userId,
    $core.List<$core.int>? payload,
  }) {
    final result = create();
    if (seq != null) result.seq = seq;
    if (status != null) result.status = status;
    if (userId != null) result.userId = userId;
    if (payload != null) result.payload = payload;
    return result;
  }

  InvokeResponse._();

  factory InvokeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InvokeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvokeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sdk'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'seq')
    ..aI(2, _omitFieldNames ? '' : 'status')
    ..aInt64(3, _omitFieldNames ? '' : 'userId')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvokeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvokeResponse copyWith(void Function(InvokeResponse) updates) =>
      super.copyWith((message) => updates(message as InvokeResponse))
          as InvokeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvokeResponse create() => InvokeResponse._();
  @$core.override
  InvokeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InvokeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvokeResponse>(create);
  static InvokeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get seq => $_getIZ(0);
  @$pb.TagNumber(1)
  set seq($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSeq() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeq() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get status => $_getIZ(1);
  @$pb.TagNumber(2)
  set status($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get userId => $_getI64(2);
  @$pb.TagNumber(3)
  set userId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get payload => $_getN(3);
  @$pb.TagNumber(4)
  set payload($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPayload() => $_has(3);
  @$pb.TagNumber(4)
  void clearPayload() => $_clearField(4);
}

class SdkPushPacket extends $pb.GeneratedMessage {
  factory SdkPushPacket({
    $core.int? command,
    $fixnum.Int64? userId,
    $core.int? seq,
    $core.List<$core.int>? payload,
  }) {
    final result = create();
    if (command != null) result.command = command;
    if (userId != null) result.userId = userId;
    if (seq != null) result.seq = seq;
    if (payload != null) result.payload = payload;
    return result;
  }

  SdkPushPacket._();

  factory SdkPushPacket.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SdkPushPacket.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SdkPushPacket',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sdk'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'command')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..aI(3, _omitFieldNames ? '' : 'seq')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdkPushPacket clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdkPushPacket copyWith(void Function(SdkPushPacket) updates) =>
      super.copyWith((message) => updates(message as SdkPushPacket))
          as SdkPushPacket;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SdkPushPacket create() => SdkPushPacket._();
  @$core.override
  SdkPushPacket createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SdkPushPacket getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SdkPushPacket>(create);
  static SdkPushPacket? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get command => $_getIZ(0);
  @$pb.TagNumber(1)
  set command($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCommand() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommand() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get seq => $_getIZ(2);
  @$pb.TagNumber(3)
  set seq($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSeq() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeq() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get payload => $_getN(3);
  @$pb.TagNumber(4)
  set payload($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPayload() => $_has(3);
  @$pb.TagNumber(4)
  void clearPayload() => $_clearField(4);
}

class SdkLoginUserRequest extends $pb.GeneratedMessage {
  factory SdkLoginUserRequest({
    $fixnum.Int64? userId,
    $fixnum.Int64? tenantId,
    $core.String? accessToken,
    $core.int? unionId,
    $core.String? unionClientConfig,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (tenantId != null) result.tenantId = tenantId;
    if (accessToken != null) result.accessToken = accessToken;
    if (unionId != null) result.unionId = unionId;
    if (unionClientConfig != null) result.unionClientConfig = unionClientConfig;
    return result;
  }

  SdkLoginUserRequest._();

  factory SdkLoginUserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SdkLoginUserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SdkLoginUserRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sdk'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aInt64(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'accessToken')
    ..aI(4, _omitFieldNames ? '' : 'unionId')
    ..aOS(5, _omitFieldNames ? '' : 'unionClientConfig')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdkLoginUserRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdkLoginUserRequest copyWith(void Function(SdkLoginUserRequest) updates) =>
      super.copyWith((message) => updates(message as SdkLoginUserRequest))
          as SdkLoginUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SdkLoginUserRequest create() => SdkLoginUserRequest._();
  @$core.override
  SdkLoginUserRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SdkLoginUserRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SdkLoginUserRequest>(create);
  static SdkLoginUserRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get tenantId => $_getI64(1);
  @$pb.TagNumber(2)
  set tenantId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get accessToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set accessToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAccessToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccessToken() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get unionId => $_getIZ(3);
  @$pb.TagNumber(4)
  set unionId($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUnionId() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnionId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get unionClientConfig => $_getSZ(4);
  @$pb.TagNumber(5)
  set unionClientConfig($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUnionClientConfig() => $_has(4);
  @$pb.TagNumber(5)
  void clearUnionClientConfig() => $_clearField(5);
}

class SdkLoginUserResponse extends $pb.GeneratedMessage {
  factory SdkLoginUserResponse() => create();

  SdkLoginUserResponse._();

  factory SdkLoginUserResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SdkLoginUserResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SdkLoginUserResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sdk'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdkLoginUserResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdkLoginUserResponse copyWith(void Function(SdkLoginUserResponse) updates) =>
      super.copyWith((message) => updates(message as SdkLoginUserResponse))
          as SdkLoginUserResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SdkLoginUserResponse create() => SdkLoginUserResponse._();
  @$core.override
  SdkLoginUserResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SdkLoginUserResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SdkLoginUserResponse>(create);
  static SdkLoginUserResponse? _defaultInstance;
}

class SdkLogoutUserRequest extends $pb.GeneratedMessage {
  factory SdkLogoutUserRequest() => create();

  SdkLogoutUserRequest._();

  factory SdkLogoutUserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SdkLogoutUserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SdkLogoutUserRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sdk'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdkLogoutUserRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdkLogoutUserRequest copyWith(void Function(SdkLogoutUserRequest) updates) =>
      super.copyWith((message) => updates(message as SdkLogoutUserRequest))
          as SdkLogoutUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SdkLogoutUserRequest create() => SdkLogoutUserRequest._();
  @$core.override
  SdkLogoutUserRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SdkLogoutUserRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SdkLogoutUserRequest>(create);
  static SdkLogoutUserRequest? _defaultInstance;
}

class SdkLogoutUserResponse extends $pb.GeneratedMessage {
  factory SdkLogoutUserResponse() => create();

  SdkLogoutUserResponse._();

  factory SdkLogoutUserResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SdkLogoutUserResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SdkLogoutUserResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sdk'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdkLogoutUserResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdkLogoutUserResponse copyWith(
          void Function(SdkLogoutUserResponse) updates) =>
      super.copyWith((message) => updates(message as SdkLogoutUserResponse))
          as SdkLogoutUserResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SdkLogoutUserResponse create() => SdkLogoutUserResponse._();
  @$core.override
  SdkLogoutUserResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SdkLogoutUserResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SdkLogoutUserResponse>(create);
  static SdkLogoutUserResponse? _defaultInstance;
}

class PushDeviceKickoffResponse extends $pb.GeneratedMessage {
  factory PushDeviceKickoffResponse() => create();

  PushDeviceKickoffResponse._();

  factory PushDeviceKickoffResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushDeviceKickoffResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushDeviceKickoffResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sdk'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushDeviceKickoffResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushDeviceKickoffResponse copyWith(
          void Function(PushDeviceKickoffResponse) updates) =>
      super.copyWith((message) => updates(message as PushDeviceKickoffResponse))
          as PushDeviceKickoffResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushDeviceKickoffResponse create() => PushDeviceKickoffResponse._();
  @$core.override
  PushDeviceKickoffResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushDeviceKickoffResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushDeviceKickoffResponse>(create);
  static PushDeviceKickoffResponse? _defaultInstance;
}

class PushFeedCardsResponse extends $pb.GeneratedMessage {
  factory PushFeedCardsResponse() => create();

  PushFeedCardsResponse._();

  factory PushFeedCardsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushFeedCardsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushFeedCardsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sdk'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushFeedCardsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushFeedCardsResponse copyWith(
          void Function(PushFeedCardsResponse) updates) =>
      super.copyWith((message) => updates(message as PushFeedCardsResponse))
          as PushFeedCardsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushFeedCardsResponse create() => PushFeedCardsResponse._();
  @$core.override
  PushFeedCardsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushFeedCardsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushFeedCardsResponse>(create);
  static PushFeedCardsResponse? _defaultInstance;
}

class GetSdkVersionRequest extends $pb.GeneratedMessage {
  factory GetSdkVersionRequest() => create();

  GetSdkVersionRequest._();

  factory GetSdkVersionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSdkVersionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSdkVersionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sdk'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSdkVersionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSdkVersionRequest copyWith(void Function(GetSdkVersionRequest) updates) =>
      super.copyWith((message) => updates(message as GetSdkVersionRequest))
          as GetSdkVersionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSdkVersionRequest create() => GetSdkVersionRequest._();
  @$core.override
  GetSdkVersionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSdkVersionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSdkVersionRequest>(create);
  static GetSdkVersionRequest? _defaultInstance;
}

class GetSdkVersionResponse extends $pb.GeneratedMessage {
  factory GetSdkVersionResponse({
    $core.String? sdkVersion,
  }) {
    final result = create();
    if (sdkVersion != null) result.sdkVersion = sdkVersion;
    return result;
  }

  GetSdkVersionResponse._();

  factory GetSdkVersionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSdkVersionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSdkVersionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sdk'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sdkVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSdkVersionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSdkVersionResponse copyWith(
          void Function(GetSdkVersionResponse) updates) =>
      super.copyWith((message) => updates(message as GetSdkVersionResponse))
          as GetSdkVersionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSdkVersionResponse create() => GetSdkVersionResponse._();
  @$core.override
  GetSdkVersionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSdkVersionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSdkVersionResponse>(create);
  static GetSdkVersionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sdkVersion => $_getSZ(0);
  @$pb.TagNumber(1)
  set sdkVersion($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSdkVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearSdkVersion() => $_clearField(1);
}

class AvatarKey extends $pb.GeneratedMessage {
  factory AvatarKey({
    $core.String? entityId,
    $core.String? key,
    AvatarKey_EntityType? entityType,
  }) {
    final result = create();
    if (entityId != null) result.entityId = entityId;
    if (key != null) result.key = key;
    if (entityType != null) result.entityType = entityType;
    return result;
  }

  AvatarKey._();

  factory AvatarKey.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AvatarKey.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AvatarKey',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sdk'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'entityId')
    ..aOS(2, _omitFieldNames ? '' : 'key')
    ..aE<AvatarKey_EntityType>(3, _omitFieldNames ? '' : 'entityType',
        enumValues: AvatarKey_EntityType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AvatarKey clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AvatarKey copyWith(void Function(AvatarKey) updates) =>
      super.copyWith((message) => updates(message as AvatarKey)) as AvatarKey;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AvatarKey create() => AvatarKey._();
  @$core.override
  AvatarKey createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AvatarKey getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AvatarKey>(create);
  static AvatarKey? _defaultInstance;

  /// entity_id(optional) + key 唯一标识一个头像。
  @$pb.TagNumber(1)
  $core.String get entityId => $_getSZ(0);
  @$pb.TagNumber(1)
  set entityId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEntityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntityId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get key => $_getSZ(1);
  @$pb.TagNumber(2)
  set key($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearKey() => $_clearField(2);

  @$pb.TagNumber(3)
  AvatarKey_EntityType get entityType => $_getN(2);
  @$pb.TagNumber(3)
  set entityType(AvatarKey_EntityType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEntityType() => $_has(2);
  @$pb.TagNumber(3)
  void clearEntityType() => $_clearField(3);
}

class WriteClientLog extends $pb.GeneratedMessage {
  factory WriteClientLog({
    $core.String? msg,
    $core.int? level,
    $core.String? error,
    $core.String? backtrace,
  }) {
    final result = create();
    if (msg != null) result.msg = msg;
    if (level != null) result.level = level;
    if (error != null) result.error = error;
    if (backtrace != null) result.backtrace = backtrace;
    return result;
  }

  WriteClientLog._();

  factory WriteClientLog.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WriteClientLog.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WriteClientLog',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sdk'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'msg')
    ..aI(2, _omitFieldNames ? '' : 'level')
    ..aOS(3, _omitFieldNames ? '' : 'error')
    ..aOS(4, _omitFieldNames ? '' : 'backtrace')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteClientLog clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteClientLog copyWith(void Function(WriteClientLog) updates) =>
      super.copyWith((message) => updates(message as WriteClientLog))
          as WriteClientLog;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WriteClientLog create() => WriteClientLog._();
  @$core.override
  WriteClientLog createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WriteClientLog getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WriteClientLog>(create);
  static WriteClientLog? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get msg => $_getSZ(0);
  @$pb.TagNumber(1)
  set msg($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsg() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get level => $_getIZ(1);
  @$pb.TagNumber(2)
  set level($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLevel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLevel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get error => $_getSZ(2);
  @$pb.TagNumber(3)
  set error($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get backtrace => $_getSZ(3);
  @$pb.TagNumber(4)
  set backtrace($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBacktrace() => $_has(3);
  @$pb.TagNumber(4)
  void clearBacktrace() => $_clearField(4);
}

/// response with entity.Packet
class NetRequest extends $pb.GeneratedMessage {
  factory NetRequest({
    $core.int? cmd,
    $core.List<$core.int>? body,
  }) {
    final result = create();
    if (cmd != null) result.cmd = cmd;
    if (body != null) result.body = body;
    return result;
  }

  NetRequest._();

  factory NetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sdk'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'cmd')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'body', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NetRequest copyWith(void Function(NetRequest) updates) =>
      super.copyWith((message) => updates(message as NetRequest)) as NetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NetRequest create() => NetRequest._();
  @$core.override
  NetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NetRequest>(create);
  static NetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get cmd => $_getIZ(0);
  @$pb.TagNumber(1)
  set cmd($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCmd() => $_has(0);
  @$pb.TagNumber(1)
  void clearCmd() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get body => $_getN(1);
  @$pb.TagNumber(2)
  set body($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBody() => $_has(1);
  @$pb.TagNumber(2)
  void clearBody() => $_clearField(2);
}

class PushEntityChangeRequest extends $pb.GeneratedMessage {
  factory PushEntityChangeRequest({
    $core.Iterable<$core.int>? types,
    $0.Entity? entity,
  }) {
    final result = create();
    if (types != null) result.types.addAll(types);
    if (entity != null) result.entity = entity;
    return result;
  }

  PushEntityChangeRequest._();

  factory PushEntityChangeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushEntityChangeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushEntityChangeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sdk'),
      createEmptyInstance: create)
    ..p<$core.int>(1, _omitFieldNames ? '' : 'types', $pb.PbFieldType.K3)
    ..aOM<$0.Entity>(2, _omitFieldNames ? '' : 'entity',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushEntityChangeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushEntityChangeRequest copyWith(
          void Function(PushEntityChangeRequest) updates) =>
      super.copyWith((message) => updates(message as PushEntityChangeRequest))
          as PushEntityChangeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushEntityChangeRequest create() => PushEntityChangeRequest._();
  @$core.override
  PushEntityChangeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushEntityChangeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushEntityChangeRequest>(create);
  static PushEntityChangeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.int> get types => $_getList(0);

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

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
