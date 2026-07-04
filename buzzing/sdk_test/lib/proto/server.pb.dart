// This is a generated file - do not edit.
//
// Generated from server.proto.

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

class PullPacketsBySidsRequest extends $pb.GeneratedMessage {
  factory PullPacketsBySidsRequest({
    $core.String? sids,
  }) {
    final result = create();
    if (sids != null) result.sids = sids;
    return result;
  }

  PullPacketsBySidsRequest._();

  factory PullPacketsBySidsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PullPacketsBySidsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PullPacketsBySidsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'server'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sids')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullPacketsBySidsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullPacketsBySidsRequest copyWith(
          void Function(PullPacketsBySidsRequest) updates) =>
      super.copyWith((message) => updates(message as PullPacketsBySidsRequest))
          as PullPacketsBySidsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PullPacketsBySidsRequest create() => PullPacketsBySidsRequest._();
  @$core.override
  PullPacketsBySidsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PullPacketsBySidsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PullPacketsBySidsRequest>(create);
  static PullPacketsBySidsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sids => $_getSZ(0);
  @$pb.TagNumber(1)
  set sids($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSids() => $_has(0);
  @$pb.TagNumber(1)
  void clearSids() => $_clearField(1);
}

class PullPacketsBySidsResponse extends $pb.GeneratedMessage {
  factory PullPacketsBySidsResponse({
    $core.Iterable<$core.MapEntry<$core.String, $0.Packet>>? packets,
  }) {
    final result = create();
    if (packets != null) result.packets.addEntries(packets);
    return result;
  }

  PullPacketsBySidsResponse._();

  factory PullPacketsBySidsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PullPacketsBySidsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PullPacketsBySidsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'server'),
      createEmptyInstance: create)
    ..m<$core.String, $0.Packet>(1, _omitFieldNames ? '' : 'packets',
        entryClassName: 'PullPacketsBySidsResponse.PacketsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: $0.Packet.create,
        valueDefaultOrMaker: $0.Packet.getDefault,
        packageName: const $pb.PackageName('server'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullPacketsBySidsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullPacketsBySidsResponse copyWith(
          void Function(PullPacketsBySidsResponse) updates) =>
      super.copyWith((message) => updates(message as PullPacketsBySidsResponse))
          as PullPacketsBySidsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PullPacketsBySidsResponse create() => PullPacketsBySidsResponse._();
  @$core.override
  PullPacketsBySidsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PullPacketsBySidsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PullPacketsBySidsResponse>(create);
  static PullPacketsBySidsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, $0.Packet> get packets => $_getMap(0);
}

class ProcessMultiPacketsRequest extends $pb.GeneratedMessage {
  factory ProcessMultiPacketsRequest({
    $core.Iterable<$core.List<$core.int>>? packets,
  }) {
    final result = create();
    if (packets != null) result.packets.addAll(packets);
    return result;
  }

  ProcessMultiPacketsRequest._();

  factory ProcessMultiPacketsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProcessMultiPacketsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProcessMultiPacketsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'server'),
      createEmptyInstance: create)
    ..p<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'packets', $pb.PbFieldType.PY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessMultiPacketsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessMultiPacketsRequest copyWith(
          void Function(ProcessMultiPacketsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ProcessMultiPacketsRequest))
          as ProcessMultiPacketsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProcessMultiPacketsRequest create() => ProcessMultiPacketsRequest._();
  @$core.override
  ProcessMultiPacketsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProcessMultiPacketsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProcessMultiPacketsRequest>(create);
  static ProcessMultiPacketsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.List<$core.int>> get packets => $_getList(0);
}

class ProcessMultiPacketsResponse extends $pb.GeneratedMessage {
  factory ProcessMultiPacketsResponse({
    $core.Iterable<$core.List<$core.int>>? results,
    $core.Iterable<$core.MapEntry<$core.int, MultiPacketResultExt>>?
        resultsExtension,
  }) {
    final result = create();
    if (results != null) result.results.addAll(results);
    if (resultsExtension != null)
      result.resultsExtension.addEntries(resultsExtension);
    return result;
  }

  ProcessMultiPacketsResponse._();

  factory ProcessMultiPacketsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProcessMultiPacketsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProcessMultiPacketsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'server'),
      createEmptyInstance: create)
    ..p<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'results', $pb.PbFieldType.PY)
    ..m<$core.int, MultiPacketResultExt>(
        2, _omitFieldNames ? '' : 'resultsExtension',
        entryClassName: 'ProcessMultiPacketsResponse.ResultsExtensionEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: MultiPacketResultExt.create,
        valueDefaultOrMaker: MultiPacketResultExt.getDefault,
        packageName: const $pb.PackageName('server'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessMultiPacketsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessMultiPacketsResponse copyWith(
          void Function(ProcessMultiPacketsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ProcessMultiPacketsResponse))
          as ProcessMultiPacketsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProcessMultiPacketsResponse create() =>
      ProcessMultiPacketsResponse._();
  @$core.override
  ProcessMultiPacketsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProcessMultiPacketsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProcessMultiPacketsResponse>(create);
  static ProcessMultiPacketsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.List<$core.int>> get results => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.int, MultiPacketResultExt> get resultsExtension =>
      $_getMap(1);
}

class MultiPacketResultExt extends $pb.GeneratedMessage {
  factory MultiPacketResultExt({
    $core.int? statusCode,
  }) {
    final result = create();
    if (statusCode != null) result.statusCode = statusCode;
    return result;
  }

  MultiPacketResultExt._();

  factory MultiPacketResultExt.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MultiPacketResultExt.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MultiPacketResultExt',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'server'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'statusCode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultiPacketResultExt clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultiPacketResultExt copyWith(void Function(MultiPacketResultExt) updates) =>
      super.copyWith((message) => updates(message as MultiPacketResultExt))
          as MultiPacketResultExt;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MultiPacketResultExt create() => MultiPacketResultExt._();
  @$core.override
  MultiPacketResultExt createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MultiPacketResultExt getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MultiPacketResultExt>(create);
  static MultiPacketResultExt? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get statusCode => $_getIZ(0);
  @$pb.TagNumber(1)
  set statusCode($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStatusCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatusCode() => $_clearField(1);
}

class PullPacketsBySeqIdRequest extends $pb.GeneratedMessage {
  factory PullPacketsBySeqIdRequest({
    $core.String? sid,
    $core.int? count,
    $core.int? version,
    $core.bool? frontierDowngrade,
    $core.String? batchUniqId,
    $fixnum.Int64? batchIndex,
  }) {
    final result = create();
    if (sid != null) result.sid = sid;
    if (count != null) result.count = count;
    if (version != null) result.version = version;
    if (frontierDowngrade != null) result.frontierDowngrade = frontierDowngrade;
    if (batchUniqId != null) result.batchUniqId = batchUniqId;
    if (batchIndex != null) result.batchIndex = batchIndex;
    return result;
  }

  PullPacketsBySeqIdRequest._();

  factory PullPacketsBySeqIdRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PullPacketsBySeqIdRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PullPacketsBySeqIdRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'server'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sid')
    ..aI(2, _omitFieldNames ? '' : 'count', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'version', fieldType: $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'frontierDowngrade')
    ..aOS(5, _omitFieldNames ? '' : 'batchUniqId')
    ..aInt64(6, _omitFieldNames ? '' : 'batchIndex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullPacketsBySeqIdRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullPacketsBySeqIdRequest copyWith(
          void Function(PullPacketsBySeqIdRequest) updates) =>
      super.copyWith((message) => updates(message as PullPacketsBySeqIdRequest))
          as PullPacketsBySeqIdRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PullPacketsBySeqIdRequest create() => PullPacketsBySeqIdRequest._();
  @$core.override
  PullPacketsBySeqIdRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PullPacketsBySeqIdRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PullPacketsBySeqIdRequest>(create);
  static PullPacketsBySeqIdRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sid => $_getSZ(0);
  @$pb.TagNumber(1)
  set sid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSid() => $_has(0);
  @$pb.TagNumber(1)
  void clearSid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get count => $_getIZ(1);
  @$pb.TagNumber(2)
  set count($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get version => $_getIZ(2);
  @$pb.TagNumber(3)
  set version($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get frontierDowngrade => $_getBF(3);
  @$pb.TagNumber(4)
  set frontierDowngrade($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFrontierDowngrade() => $_has(3);
  @$pb.TagNumber(4)
  void clearFrontierDowngrade() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get batchUniqId => $_getSZ(4);
  @$pb.TagNumber(5)
  set batchUniqId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBatchUniqId() => $_has(4);
  @$pb.TagNumber(5)
  void clearBatchUniqId() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get batchIndex => $_getI64(5);
  @$pb.TagNumber(6)
  set batchIndex($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBatchIndex() => $_has(5);
  @$pb.TagNumber(6)
  void clearBatchIndex() => $_clearField(6);
}

class PullPacketsBySeqIdResponse extends $pb.GeneratedMessage {
  factory PullPacketsBySeqIdResponse({
    $core.bool? hasMore,
    $core.Iterable<$0.Packet>? packets,
    $fixnum.Int64? lastPacketCreateTime,
    $core.String? lastSid,
    $fixnum.Int64? responseTime,
    $fixnum.Int64? maxBatchIndex,
  }) {
    final result = create();
    if (hasMore != null) result.hasMore = hasMore;
    if (packets != null) result.packets.addAll(packets);
    if (lastPacketCreateTime != null)
      result.lastPacketCreateTime = lastPacketCreateTime;
    if (lastSid != null) result.lastSid = lastSid;
    if (responseTime != null) result.responseTime = responseTime;
    if (maxBatchIndex != null) result.maxBatchIndex = maxBatchIndex;
    return result;
  }

  PullPacketsBySeqIdResponse._();

  factory PullPacketsBySeqIdResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PullPacketsBySeqIdResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PullPacketsBySeqIdResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'server'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'hasMore')
    ..pPM<$0.Packet>(2, _omitFieldNames ? '' : 'packets',
        subBuilder: $0.Packet.create)
    ..aInt64(3, _omitFieldNames ? '' : 'lastPacketCreateTime')
    ..aOS(4, _omitFieldNames ? '' : 'lastSid')
    ..aInt64(5, _omitFieldNames ? '' : 'responseTime')
    ..aInt64(6, _omitFieldNames ? '' : 'maxBatchIndex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullPacketsBySeqIdResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullPacketsBySeqIdResponse copyWith(
          void Function(PullPacketsBySeqIdResponse) updates) =>
      super.copyWith(
              (message) => updates(message as PullPacketsBySeqIdResponse))
          as PullPacketsBySeqIdResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PullPacketsBySeqIdResponse create() => PullPacketsBySeqIdResponse._();
  @$core.override
  PullPacketsBySeqIdResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PullPacketsBySeqIdResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PullPacketsBySeqIdResponse>(create);
  static PullPacketsBySeqIdResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get hasMore => $_getBF(0);
  @$pb.TagNumber(1)
  set hasMore($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHasMore() => $_has(0);
  @$pb.TagNumber(1)
  void clearHasMore() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$0.Packet> get packets => $_getList(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get lastPacketCreateTime => $_getI64(2);
  @$pb.TagNumber(3)
  set lastPacketCreateTime($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLastPacketCreateTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastPacketCreateTime() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get lastSid => $_getSZ(3);
  @$pb.TagNumber(4)
  set lastSid($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLastSid() => $_has(3);
  @$pb.TagNumber(4)
  void clearLastSid() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get responseTime => $_getI64(4);
  @$pb.TagNumber(5)
  set responseTime($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasResponseTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearResponseTime() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get maxBatchIndex => $_getI64(5);
  @$pb.TagNumber(6)
  set maxBatchIndex($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxBatchIndex() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxBatchIndex() => $_clearField(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
