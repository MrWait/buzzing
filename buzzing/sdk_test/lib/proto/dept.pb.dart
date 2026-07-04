// This is a generated file - do not edit.
//
// Generated from dept.proto.

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

class GetDeptRequest extends $pb.GeneratedMessage {
  factory GetDeptRequest({
    $fixnum.Int64? id,
    $fixnum.Int64? tenantId,
    $core.bool? recursive,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (recursive != null) result.recursive = recursive;
    return result;
  }

  GetDeptRequest._();

  factory GetDeptRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDeptRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDeptRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dept'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'tenantId')
    ..aOB(3, _omitFieldNames ? '' : 'recursive')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDeptRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDeptRequest copyWith(void Function(GetDeptRequest) updates) =>
      super.copyWith((message) => updates(message as GetDeptRequest))
          as GetDeptRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDeptRequest create() => GetDeptRequest._();
  @$core.override
  GetDeptRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDeptRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDeptRequest>(create);
  static GetDeptRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get tenantId => $_getI64(1);
  @$pb.TagNumber(2)
  set tenantId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get recursive => $_getBF(2);
  @$pb.TagNumber(3)
  set recursive($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRecursive() => $_has(2);
  @$pb.TagNumber(3)
  void clearRecursive() => $_clearField(3);
}

class GetDeptResponse extends $pb.GeneratedMessage {
  factory GetDeptResponse({
    $core.Iterable<$core.MapEntry<$fixnum.Int64, $0.Department>>? depts,
    $core.Iterable<$core.MapEntry<$fixnum.Int64, $0.User>>? users,
  }) {
    final result = create();
    if (depts != null) result.depts.addEntries(depts);
    if (users != null) result.users.addEntries(users);
    return result;
  }

  GetDeptResponse._();

  factory GetDeptResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDeptResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDeptResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dept'),
      createEmptyInstance: create)
    ..m<$fixnum.Int64, $0.Department>(1, _omitFieldNames ? '' : 'depts',
        entryClassName: 'GetDeptResponse.DeptsEntry',
        keyFieldType: $pb.PbFieldType.O6,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: $0.Department.create,
        valueDefaultOrMaker: $0.Department.getDefault,
        packageName: const $pb.PackageName('dept'))
    ..m<$fixnum.Int64, $0.User>(2, _omitFieldNames ? '' : 'users',
        entryClassName: 'GetDeptResponse.UsersEntry',
        keyFieldType: $pb.PbFieldType.O6,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: $0.User.create,
        valueDefaultOrMaker: $0.User.getDefault,
        packageName: const $pb.PackageName('dept'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDeptResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDeptResponse copyWith(void Function(GetDeptResponse) updates) =>
      super.copyWith((message) => updates(message as GetDeptResponse))
          as GetDeptResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDeptResponse create() => GetDeptResponse._();
  @$core.override
  GetDeptResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDeptResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDeptResponse>(create);
  static GetDeptResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$fixnum.Int64, $0.Department> get depts => $_getMap(0);

  @$pb.TagNumber(2)
  $pb.PbMap<$fixnum.Int64, $0.User> get users => $_getMap(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
