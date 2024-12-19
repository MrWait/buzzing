// This is a generated file - do not edit.
//
// Generated from gateway.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'entity.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class RpcRequest extends $pb.GeneratedMessage {
  factory RpcRequest({
    $core.String? name,
  }) {
    final result = create();
    if (name != null) result.name = name;
    return result;
  }

  RpcRequest._();

  factory RpcRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RpcRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RpcRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gateway'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RpcRequest clone() => RpcRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RpcRequest copyWith(void Function(RpcRequest) updates) =>
      super.copyWith((message) => updates(message as RpcRequest)) as RpcRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RpcRequest create() => RpcRequest._();
  @$core.override
  RpcRequest createEmptyInstance() => create();
  static $pb.PbList<RpcRequest> createRepeated() => $pb.PbList<RpcRequest>();
  @$core.pragma('dart2js:noInline')
  static RpcRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RpcRequest>(create);
  static RpcRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);
}

class RpcResponse extends $pb.GeneratedMessage {
  factory RpcResponse({
    $core.String? msg,
  }) {
    final result = create();
    if (msg != null) result.msg = msg;
    return result;
  }

  RpcResponse._();

  factory RpcResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RpcResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RpcResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gateway'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'msg')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RpcResponse clone() => RpcResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RpcResponse copyWith(void Function(RpcResponse) updates) =>
      super.copyWith((message) => updates(message as RpcResponse))
          as RpcResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RpcResponse create() => RpcResponse._();
  @$core.override
  RpcResponse createEmptyInstance() => create();
  static $pb.PbList<RpcResponse> createRepeated() => $pb.PbList<RpcResponse>();
  @$core.pragma('dart2js:noInline')
  static RpcResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RpcResponse>(create);
  static RpcResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get msg => $_getSZ(0);
  @$pb.TagNumber(1)
  set msg($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsg() => $_clearField(1);
}

class GatewayInvokeRequest extends $pb.GeneratedMessage {
  factory GatewayInvokeRequest({
    $0.Packet? req,
  }) {
    final result = create();
    if (req != null) result.req = req;
    return result;
  }

  GatewayInvokeRequest._();

  factory GatewayInvokeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GatewayInvokeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GatewayInvokeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gateway'),
      createEmptyInstance: create)
    ..aOM<$0.Packet>(1, _omitFieldNames ? '' : 'req',
        subBuilder: $0.Packet.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GatewayInvokeRequest clone() =>
      GatewayInvokeRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GatewayInvokeRequest copyWith(void Function(GatewayInvokeRequest) updates) =>
      super.copyWith((message) => updates(message as GatewayInvokeRequest))
          as GatewayInvokeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GatewayInvokeRequest create() => GatewayInvokeRequest._();
  @$core.override
  GatewayInvokeRequest createEmptyInstance() => create();
  static $pb.PbList<GatewayInvokeRequest> createRepeated() =>
      $pb.PbList<GatewayInvokeRequest>();
  @$core.pragma('dart2js:noInline')
  static GatewayInvokeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GatewayInvokeRequest>(create);
  static GatewayInvokeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Packet get req => $_getN(0);
  @$pb.TagNumber(1)
  set req($0.Packet value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReq() => $_has(0);
  @$pb.TagNumber(1)
  void clearReq() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Packet ensureReq() => $_ensure(0);
}

class GatewayInvokeResponse extends $pb.GeneratedMessage {
  factory GatewayInvokeResponse({
    $0.Packet? res,
  }) {
    final result = create();
    if (res != null) result.res = res;
    return result;
  }

  GatewayInvokeResponse._();

  factory GatewayInvokeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GatewayInvokeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GatewayInvokeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gateway'),
      createEmptyInstance: create)
    ..aOM<$0.Packet>(1, _omitFieldNames ? '' : 'res',
        subBuilder: $0.Packet.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GatewayInvokeResponse clone() =>
      GatewayInvokeResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GatewayInvokeResponse copyWith(
          void Function(GatewayInvokeResponse) updates) =>
      super.copyWith((message) => updates(message as GatewayInvokeResponse))
          as GatewayInvokeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GatewayInvokeResponse create() => GatewayInvokeResponse._();
  @$core.override
  GatewayInvokeResponse createEmptyInstance() => create();
  static $pb.PbList<GatewayInvokeResponse> createRepeated() =>
      $pb.PbList<GatewayInvokeResponse>();
  @$core.pragma('dart2js:noInline')
  static GatewayInvokeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GatewayInvokeResponse>(create);
  static GatewayInvokeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Packet get res => $_getN(0);
  @$pb.TagNumber(1)
  set res($0.Packet value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRes() => $_has(0);
  @$pb.TagNumber(1)
  void clearRes() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Packet ensureRes() => $_ensure(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
