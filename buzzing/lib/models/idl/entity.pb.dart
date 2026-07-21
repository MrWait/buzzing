// This is a generated file - do not edit.
//
// Generated from entity.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'entity.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'entity.pbenum.dart';

class CommonError extends $pb.GeneratedMessage {
  factory CommonError({
    $core.int? status,
    $core.int? code,
    $core.String? displayMessage,
    $core.String? displayTitle,
    $core.String? serverMessage,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (code != null) result.code = code;
    if (displayMessage != null) result.displayMessage = displayMessage;
    if (displayTitle != null) result.displayTitle = displayTitle;
    if (serverMessage != null) result.serverMessage = serverMessage;
    return result;
  }

  CommonError._();

  factory CommonError.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommonError.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommonError',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'status')
    ..aI(2, _omitFieldNames ? '' : 'code')
    ..aOS(3, _omitFieldNames ? '' : 'displayMessage')
    ..aOS(4, _omitFieldNames ? '' : 'displayTitle')
    ..aOS(5, _omitFieldNames ? '' : 'serverMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommonError clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommonError copyWith(void Function(CommonError) updates) =>
      super.copyWith((message) => updates(message as CommonError))
          as CommonError;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommonError create() => CommonError._();
  @$core.override
  CommonError createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CommonError getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommonError>(create);
  static CommonError? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get status => $_getIZ(0);
  @$pb.TagNumber(1)
  set status($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get code => $_getIZ(1);
  @$pb.TagNumber(2)
  set code($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get displayMessage => $_getSZ(2);
  @$pb.TagNumber(3)
  set displayMessage($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDisplayMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearDisplayMessage() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get displayTitle => $_getSZ(3);
  @$pb.TagNumber(4)
  set displayTitle($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDisplayTitle() => $_has(3);
  @$pb.TagNumber(4)
  void clearDisplayTitle() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get serverMessage => $_getSZ(4);
  @$pb.TagNumber(5)
  set serverMessage($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasServerMessage() => $_has(4);
  @$pb.TagNumber(5)
  void clearServerMessage() => $_clearField(5);
}

class Setting extends $pb.GeneratedMessage {
  factory Setting({
    $fixnum.Int64? version,
    $core.List<$core.int>? data,
  }) {
    final result = create();
    if (version != null) result.version = version;
    if (data != null) result.data = data;
    return result;
  }

  Setting._();

  factory Setting.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Setting.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Setting',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'version')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Setting clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Setting copyWith(void Function(Setting) updates) =>
      super.copyWith((message) => updates(message as Setting)) as Setting;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Setting create() => Setting._();
  @$core.override
  Setting createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Setting getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Setting>(create);
  static Setting? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get version => $_getI64(0);
  @$pb.TagNumber(1)
  set version($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => $_clearField(2);
}

class Settings extends $pb.GeneratedMessage {
  factory Settings({
    $core.Iterable<$core.MapEntry<$core.int, Setting>>? settings,
  }) {
    final result = create();
    if (settings != null) result.settings.addEntries(settings);
    return result;
  }

  Settings._();

  factory Settings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Settings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Settings',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..m<$core.int, Setting>(1, _omitFieldNames ? '' : 'settings',
        entryClassName: 'Settings.SettingsEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Setting.create,
        valueDefaultOrMaker: Setting.getDefault,
        packageName: const $pb.PackageName('entity'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Settings clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Settings copyWith(void Function(Settings) updates) =>
      super.copyWith((message) => updates(message as Settings)) as Settings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Settings create() => Settings._();
  @$core.override
  Settings createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Settings getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Settings>(create);
  static Settings? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.int, Setting> get settings => $_getMap(0);
}

class User extends $pb.GeneratedMessage {
  factory User({
    $fixnum.Int64? id,
    $core.String? name,
    $core.int? status,
    $fixnum.Int64? tenantId,
    $fixnum.Int64? version,
    $core.String? avatar,
    $fixnum.Int64? deptId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (status != null) result.status = status;
    if (tenantId != null) result.tenantId = tenantId;
    if (version != null) result.version = version;
    if (avatar != null) result.avatar = avatar;
    if (deptId != null) result.deptId = deptId;
    return result;
  }

  User._();

  factory User.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory User.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'User',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aI(3, _omitFieldNames ? '' : 'status')
    ..aInt64(4, _omitFieldNames ? '' : 'tenantId')
    ..aInt64(5, _omitFieldNames ? '' : 'version')
    ..aOS(6, _omitFieldNames ? '' : 'avatar')
    ..aInt64(7, _omitFieldNames ? '' : 'deptId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  User clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  User copyWith(void Function(User) updates) =>
      super.copyWith((message) => updates(message as User)) as User;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static User create() => User._();
  @$core.override
  User createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static User getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<User>(create);
  static User? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get status => $_getIZ(2);
  @$pb.TagNumber(3)
  set status($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get tenantId => $_getI64(3);
  @$pb.TagNumber(4)
  set tenantId($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTenantId() => $_has(3);
  @$pb.TagNumber(4)
  void clearTenantId() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get version => $_getI64(4);
  @$pb.TagNumber(5)
  set version($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get avatar => $_getSZ(5);
  @$pb.TagNumber(6)
  set avatar($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAvatar() => $_has(5);
  @$pb.TagNumber(6)
  void clearAvatar() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get deptId => $_getI64(6);
  @$pb.TagNumber(7)
  set deptId($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDeptId() => $_has(6);
  @$pb.TagNumber(7)
  void clearDeptId() => $_clearField(7);
}

class UserLite extends $pb.GeneratedMessage {
  factory UserLite({
    $fixnum.Int64? id,
    $core.String? name,
    $core.int? status,
    $fixnum.Int64? tenantId,
    $fixnum.Int64? version,
    $core.String? avatar,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (status != null) result.status = status;
    if (tenantId != null) result.tenantId = tenantId;
    if (version != null) result.version = version;
    if (avatar != null) result.avatar = avatar;
    return result;
  }

  UserLite._();

  factory UserLite.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserLite.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserLite',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aI(3, _omitFieldNames ? '' : 'status')
    ..aInt64(4, _omitFieldNames ? '' : 'tenantId')
    ..aInt64(5, _omitFieldNames ? '' : 'version')
    ..aOS(6, _omitFieldNames ? '' : 'avatar')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserLite clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserLite copyWith(void Function(UserLite) updates) =>
      super.copyWith((message) => updates(message as UserLite)) as UserLite;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserLite create() => UserLite._();
  @$core.override
  UserLite createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UserLite getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserLite>(create);
  static UserLite? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get status => $_getIZ(2);
  @$pb.TagNumber(3)
  set status($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get tenantId => $_getI64(3);
  @$pb.TagNumber(4)
  set tenantId($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTenantId() => $_has(3);
  @$pb.TagNumber(4)
  void clearTenantId() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get version => $_getI64(4);
  @$pb.TagNumber(5)
  set version($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get avatar => $_getSZ(5);
  @$pb.TagNumber(6)
  set avatar($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAvatar() => $_has(5);
  @$pb.TagNumber(6)
  void clearAvatar() => $_clearField(6);
}

class EntityId extends $pb.GeneratedMessage {
  factory EntityId({
    $fixnum.Int64? id,
    EntityType? type,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    return result;
  }

  EntityId._();

  factory EntityId.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EntityId.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EntityId',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aE<EntityType>(2, _omitFieldNames ? '' : 'type',
        enumValues: EntityType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntityId clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntityId copyWith(void Function(EntityId) updates) =>
      super.copyWith((message) => updates(message as EntityId)) as EntityId;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EntityId create() => EntityId._();
  @$core.override
  EntityId createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EntityId getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EntityId>(create);
  static EntityId? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  EntityType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(EntityType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);
}

class IdList extends $pb.GeneratedMessage {
  factory IdList({
    $core.Iterable<$fixnum.Int64>? ids,
  }) {
    final result = create();
    if (ids != null) result.ids.addAll(ids);
    return result;
  }

  IdList._();

  factory IdList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IdList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IdList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..p<$fixnum.Int64>(1, _omitFieldNames ? '' : 'ids', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IdList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IdList copyWith(void Function(IdList) updates) =>
      super.copyWith((message) => updates(message as IdList)) as IdList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IdList create() => IdList._();
  @$core.override
  IdList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IdList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IdList>(create);
  static IdList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$fixnum.Int64> get ids => $_getList(0);
}

class EntityChange extends $pb.GeneratedMessage {
  factory EntityChange({
    $fixnum.Int64? id,
    $core.int? type,
    $fixnum.Int64? version,
    $core.int? operate,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    if (version != null) result.version = version;
    if (operate != null) result.operate = operate;
    return result;
  }

  EntityChange._();

  factory EntityChange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EntityChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EntityChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'type')
    ..aInt64(3, _omitFieldNames ? '' : 'version')
    ..aI(4, _omitFieldNames ? '' : 'operate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntityChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntityChange copyWith(void Function(EntityChange) updates) =>
      super.copyWith((message) => updates(message as EntityChange))
          as EntityChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EntityChange create() => EntityChange._();
  @$core.override
  EntityChange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EntityChange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EntityChange>(create);
  static EntityChange? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get type => $_getIZ(1);
  @$pb.TagNumber(2)
  set type($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get version => $_getI64(2);
  @$pb.TagNumber(3)
  set version($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get operate => $_getIZ(3);
  @$pb.TagNumber(4)
  set operate($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOperate() => $_has(3);
  @$pb.TagNumber(4)
  void clearOperate() => $_clearField(4);
}

class I18nValue extends $pb.GeneratedMessage {
  factory I18nValue({
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? value,
  }) {
    final result = create();
    if (value != null) result.value.addEntries(value);
    return result;
  }

  I18nValue._();

  factory I18nValue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory I18nValue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'I18nValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..m<$core.String, $core.String>(1, _omitFieldNames ? '' : 'value',
        entryClassName: 'I18nValue.ValueEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('entity'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  I18nValue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  I18nValue copyWith(void Function(I18nValue) updates) =>
      super.copyWith((message) => updates(message as I18nValue)) as I18nValue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static I18nValue create() => I18nValue._();
  @$core.override
  I18nValue createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static I18nValue getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<I18nValue>(create);
  static I18nValue? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, $core.String> get value => $_getMap(0);
}

class Chat extends $pb.GeneratedMessage {
  factory Chat({
    $fixnum.Int64? id,
    $core.int? chatType,
    $core.int? status,
    $core.String? name,
    $fixnum.Int64? peerAId,
    $fixnum.Int64? peerBId,
    $fixnum.Int64? ownerId,
    $core.Iterable<$fixnum.Int64>? memberIds,
    $fixnum.Int64? createAtMs,
    $fixnum.Int64? updateAtMs,
    $fixnum.Int64? lastMessageId,
    $core.int? lastMessageBadgeCount,
    $core.int? lastMessagePos,
    $core.Iterable<$fixnum.Int64>? adminIds,
    $fixnum.Int64? version,
    $core.String? avatar,
    $core.int? color,
    $core.String? description,
    $core.int? joinMode,
    $fixnum.Int64? globalMuteUntil,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (chatType != null) result.chatType = chatType;
    if (status != null) result.status = status;
    if (name != null) result.name = name;
    if (peerAId != null) result.peerAId = peerAId;
    if (peerBId != null) result.peerBId = peerBId;
    if (ownerId != null) result.ownerId = ownerId;
    if (memberIds != null) result.memberIds.addAll(memberIds);
    if (createAtMs != null) result.createAtMs = createAtMs;
    if (updateAtMs != null) result.updateAtMs = updateAtMs;
    if (lastMessageId != null) result.lastMessageId = lastMessageId;
    if (lastMessageBadgeCount != null)
      result.lastMessageBadgeCount = lastMessageBadgeCount;
    if (lastMessagePos != null) result.lastMessagePos = lastMessagePos;
    if (adminIds != null) result.adminIds.addAll(adminIds);
    if (version != null) result.version = version;
    if (avatar != null) result.avatar = avatar;
    if (color != null) result.color = color;
    if (description != null) result.description = description;
    if (joinMode != null) result.joinMode = joinMode;
    if (globalMuteUntil != null) result.globalMuteUntil = globalMuteUntil;
    return result;
  }

  Chat._();

  factory Chat.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Chat.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Chat',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'chatType')
    ..aI(3, _omitFieldNames ? '' : 'status')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aInt64(5, _omitFieldNames ? '' : 'peerAId')
    ..aInt64(6, _omitFieldNames ? '' : 'peerBId')
    ..aInt64(7, _omitFieldNames ? '' : 'ownerId')
    ..p<$fixnum.Int64>(
        8, _omitFieldNames ? '' : 'memberIds', $pb.PbFieldType.K6)
    ..aInt64(9, _omitFieldNames ? '' : 'createAtMs')
    ..aInt64(10, _omitFieldNames ? '' : 'updateAtMs')
    ..aInt64(11, _omitFieldNames ? '' : 'lastMessageId')
    ..aI(12, _omitFieldNames ? '' : 'lastMessageBadgeCount')
    ..aI(13, _omitFieldNames ? '' : 'lastMessagePos')
    ..p<$fixnum.Int64>(
        14, _omitFieldNames ? '' : 'adminIds', $pb.PbFieldType.K6)
    ..aInt64(15, _omitFieldNames ? '' : 'version')
    ..aOS(16, _omitFieldNames ? '' : 'avatar')
    ..aI(17, _omitFieldNames ? '' : 'color')
    ..aOS(18, _omitFieldNames ? '' : 'description')
    ..aI(19, _omitFieldNames ? '' : 'joinMode')
    ..aInt64(20, _omitFieldNames ? '' : 'globalMuteUntil')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Chat clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Chat copyWith(void Function(Chat) updates) =>
      super.copyWith((message) => updates(message as Chat)) as Chat;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Chat create() => Chat._();
  @$core.override
  Chat createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Chat getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Chat>(create);
  static Chat? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get chatType => $_getIZ(1);
  @$pb.TagNumber(2)
  set chatType($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChatType() => $_has(1);
  @$pb.TagNumber(2)
  void clearChatType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get status => $_getIZ(2);
  @$pb.TagNumber(3)
  set status($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get peerAId => $_getI64(4);
  @$pb.TagNumber(5)
  set peerAId($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPeerAId() => $_has(4);
  @$pb.TagNumber(5)
  void clearPeerAId() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get peerBId => $_getI64(5);
  @$pb.TagNumber(6)
  set peerBId($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPeerBId() => $_has(5);
  @$pb.TagNumber(6)
  void clearPeerBId() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get ownerId => $_getI64(6);
  @$pb.TagNumber(7)
  set ownerId($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOwnerId() => $_has(6);
  @$pb.TagNumber(7)
  void clearOwnerId() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$fixnum.Int64> get memberIds => $_getList(7);

  @$pb.TagNumber(9)
  $fixnum.Int64 get createAtMs => $_getI64(8);
  @$pb.TagNumber(9)
  set createAtMs($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCreateAtMs() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreateAtMs() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get updateAtMs => $_getI64(9);
  @$pb.TagNumber(10)
  set updateAtMs($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasUpdateAtMs() => $_has(9);
  @$pb.TagNumber(10)
  void clearUpdateAtMs() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get lastMessageId => $_getI64(10);
  @$pb.TagNumber(11)
  set lastMessageId($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasLastMessageId() => $_has(10);
  @$pb.TagNumber(11)
  void clearLastMessageId() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get lastMessageBadgeCount => $_getIZ(11);
  @$pb.TagNumber(12)
  set lastMessageBadgeCount($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasLastMessageBadgeCount() => $_has(11);
  @$pb.TagNumber(12)
  void clearLastMessageBadgeCount() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get lastMessagePos => $_getIZ(12);
  @$pb.TagNumber(13)
  set lastMessagePos($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasLastMessagePos() => $_has(12);
  @$pb.TagNumber(13)
  void clearLastMessagePos() => $_clearField(13);

  @$pb.TagNumber(14)
  $pb.PbList<$fixnum.Int64> get adminIds => $_getList(13);

  @$pb.TagNumber(15)
  $fixnum.Int64 get version => $_getI64(14);
  @$pb.TagNumber(15)
  set version($fixnum.Int64 value) => $_setInt64(14, value);
  @$pb.TagNumber(15)
  $core.bool hasVersion() => $_has(14);
  @$pb.TagNumber(15)
  void clearVersion() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get avatar => $_getSZ(15);
  @$pb.TagNumber(16)
  set avatar($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasAvatar() => $_has(15);
  @$pb.TagNumber(16)
  void clearAvatar() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.int get color => $_getIZ(16);
  @$pb.TagNumber(17)
  set color($core.int value) => $_setSignedInt32(16, value);
  @$pb.TagNumber(17)
  $core.bool hasColor() => $_has(16);
  @$pb.TagNumber(17)
  void clearColor() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.String get description => $_getSZ(17);
  @$pb.TagNumber(18)
  set description($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasDescription() => $_has(17);
  @$pb.TagNumber(18)
  void clearDescription() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.int get joinMode => $_getIZ(18);
  @$pb.TagNumber(19)
  set joinMode($core.int value) => $_setSignedInt32(18, value);
  @$pb.TagNumber(19)
  $core.bool hasJoinMode() => $_has(18);
  @$pb.TagNumber(19)
  void clearJoinMode() => $_clearField(19);

  @$pb.TagNumber(20)
  $fixnum.Int64 get globalMuteUntil => $_getI64(19);
  @$pb.TagNumber(20)
  set globalMuteUntil($fixnum.Int64 value) => $_setInt64(19, value);
  @$pb.TagNumber(20)
  $core.bool hasGlobalMuteUntil() => $_has(19);
  @$pb.TagNumber(20)
  void clearGlobalMuteUntil() => $_clearField(20);
}

class Feed extends $pb.GeneratedMessage {
  factory Feed({
    $fixnum.Int64? id,
    $core.int? type,
    $core.int? badge,
    $fixnum.Int64? updateTimeMs,
    $fixnum.Int64? rankTimeMs,
    $fixnum.Int64? referId,
    $core.int? referPos,
    $core.int? referBadge,
    $core.int? readPos,
    $core.int? readBadge,
    $fixnum.Int64? version,
    $core.int? isTop,
    $core.int? isMute,
    $core.int? status,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    if (badge != null) result.badge = badge;
    if (updateTimeMs != null) result.updateTimeMs = updateTimeMs;
    if (rankTimeMs != null) result.rankTimeMs = rankTimeMs;
    if (referId != null) result.referId = referId;
    if (referPos != null) result.referPos = referPos;
    if (referBadge != null) result.referBadge = referBadge;
    if (readPos != null) result.readPos = readPos;
    if (readBadge != null) result.readBadge = readBadge;
    if (version != null) result.version = version;
    if (isTop != null) result.isTop = isTop;
    if (isMute != null) result.isMute = isMute;
    if (status != null) result.status = status;
    return result;
  }

  Feed._();

  factory Feed.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Feed.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Feed',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'type')
    ..aI(3, _omitFieldNames ? '' : 'badge')
    ..aInt64(4, _omitFieldNames ? '' : 'updateTimeMs')
    ..aInt64(5, _omitFieldNames ? '' : 'rankTimeMs')
    ..aInt64(6, _omitFieldNames ? '' : 'referId')
    ..aI(7, _omitFieldNames ? '' : 'referPos')
    ..aI(8, _omitFieldNames ? '' : 'referBadge')
    ..aI(9, _omitFieldNames ? '' : 'readPos')
    ..aI(10, _omitFieldNames ? '' : 'readBadge')
    ..aInt64(11, _omitFieldNames ? '' : 'version')
    ..aI(12, _omitFieldNames ? '' : 'isTop')
    ..aI(13, _omitFieldNames ? '' : 'isMute')
    ..aI(14, _omitFieldNames ? '' : 'status')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Feed clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Feed copyWith(void Function(Feed) updates) =>
      super.copyWith((message) => updates(message as Feed)) as Feed;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Feed create() => Feed._();
  @$core.override
  Feed createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Feed getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Feed>(create);
  static Feed? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get type => $_getIZ(1);
  @$pb.TagNumber(2)
  set type($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get badge => $_getIZ(2);
  @$pb.TagNumber(3)
  set badge($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBadge() => $_has(2);
  @$pb.TagNumber(3)
  void clearBadge() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get updateTimeMs => $_getI64(3);
  @$pb.TagNumber(4)
  set updateTimeMs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUpdateTimeMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearUpdateTimeMs() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get rankTimeMs => $_getI64(4);
  @$pb.TagNumber(5)
  set rankTimeMs($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRankTimeMs() => $_has(4);
  @$pb.TagNumber(5)
  void clearRankTimeMs() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get referId => $_getI64(5);
  @$pb.TagNumber(6)
  set referId($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasReferId() => $_has(5);
  @$pb.TagNumber(6)
  void clearReferId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get referPos => $_getIZ(6);
  @$pb.TagNumber(7)
  set referPos($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasReferPos() => $_has(6);
  @$pb.TagNumber(7)
  void clearReferPos() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get referBadge => $_getIZ(7);
  @$pb.TagNumber(8)
  set referBadge($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasReferBadge() => $_has(7);
  @$pb.TagNumber(8)
  void clearReferBadge() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get readPos => $_getIZ(8);
  @$pb.TagNumber(9)
  set readPos($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasReadPos() => $_has(8);
  @$pb.TagNumber(9)
  void clearReadPos() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get readBadge => $_getIZ(9);
  @$pb.TagNumber(10)
  set readBadge($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasReadBadge() => $_has(9);
  @$pb.TagNumber(10)
  void clearReadBadge() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get version => $_getI64(10);
  @$pb.TagNumber(11)
  set version($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasVersion() => $_has(10);
  @$pb.TagNumber(11)
  void clearVersion() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get isTop => $_getIZ(11);
  @$pb.TagNumber(12)
  set isTop($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasIsTop() => $_has(11);
  @$pb.TagNumber(12)
  void clearIsTop() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get isMute => $_getIZ(12);
  @$pb.TagNumber(13)
  set isMute($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasIsMute() => $_has(12);
  @$pb.TagNumber(13)
  void clearIsMute() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get status => $_getIZ(13);
  @$pb.TagNumber(14)
  set status($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasStatus() => $_has(13);
  @$pb.TagNumber(14)
  void clearStatus() => $_clearField(14);
}

class Favorite extends $pb.GeneratedMessage {
  factory Favorite({
    $fixnum.Int64? id,
    $core.int? tpy,
    Message? message,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tpy != null) result.tpy = tpy;
    if (message != null) result.message = message;
    return result;
  }

  Favorite._();

  factory Favorite.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Favorite.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Favorite',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'tpy')
    ..aOM<Message>(3, _omitFieldNames ? '' : 'message',
        subBuilder: Message.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Favorite clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Favorite copyWith(void Function(Favorite) updates) =>
      super.copyWith((message) => updates(message as Favorite)) as Favorite;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Favorite create() => Favorite._();
  @$core.override
  Favorite createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Favorite getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Favorite>(create);
  static Favorite? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get tpy => $_getIZ(1);
  @$pb.TagNumber(2)
  set tpy($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTpy() => $_has(1);
  @$pb.TagNumber(2)
  void clearTpy() => $_clearField(2);

  @$pb.TagNumber(3)
  Message get message => $_getN(2);
  @$pb.TagNumber(3)
  set message(Message value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);
  @$pb.TagNumber(3)
  Message ensureMessage() => $_ensure(2);
}

class FavoriteList extends $pb.GeneratedMessage {
  factory FavoriteList({
    $core.Iterable<Favorite>? favorites,
  }) {
    final result = create();
    if (favorites != null) result.favorites.addAll(favorites);
    return result;
  }

  FavoriteList._();

  factory FavoriteList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FavoriteList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FavoriteList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..pPM<Favorite>(1, _omitFieldNames ? '' : 'favorites',
        subBuilder: Favorite.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FavoriteList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FavoriteList copyWith(void Function(FavoriteList) updates) =>
      super.copyWith((message) => updates(message as FavoriteList))
          as FavoriteList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FavoriteList create() => FavoriteList._();
  @$core.override
  FavoriteList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FavoriteList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FavoriteList>(create);
  static FavoriteList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Favorite> get favorites => $_getList(0);
}

class ReadState extends $pb.GeneratedMessage {
  factory ReadState({
    $core.int? total,
    $core.int? readCount,
    $core.int? unreadCount,
    $core.bool? meRead,
    $core.Iterable<$fixnum.Int64>? topReadIds,
  }) {
    final result = create();
    if (total != null) result.total = total;
    if (readCount != null) result.readCount = readCount;
    if (unreadCount != null) result.unreadCount = unreadCount;
    if (meRead != null) result.meRead = meRead;
    if (topReadIds != null) result.topReadIds.addAll(topReadIds);
    return result;
  }

  ReadState._();

  factory ReadState.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReadState.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReadState',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'total')
    ..aI(2, _omitFieldNames ? '' : 'readCount')
    ..aI(3, _omitFieldNames ? '' : 'unreadCount')
    ..aOB(4, _omitFieldNames ? '' : 'meRead')
    ..p<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'topReadIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadState clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadState copyWith(void Function(ReadState) updates) =>
      super.copyWith((message) => updates(message as ReadState)) as ReadState;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReadState create() => ReadState._();
  @$core.override
  ReadState createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReadState getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReadState>(create);
  static ReadState? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get total => $_getIZ(0);
  @$pb.TagNumber(1)
  set total($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotal() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotal() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get readCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set readCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReadCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearReadCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get unreadCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set unreadCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUnreadCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnreadCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get meRead => $_getBF(3);
  @$pb.TagNumber(4)
  set meRead($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMeRead() => $_has(3);
  @$pb.TagNumber(4)
  void clearMeRead() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$fixnum.Int64> get topReadIds => $_getList(4);
}

class Reaction extends $pb.GeneratedMessage {
  factory Reaction({
    $core.int? total,
    $core.bool? meRead,
    $core.Iterable<$fixnum.Int64>? topIds,
  }) {
    final result = create();
    if (total != null) result.total = total;
    if (meRead != null) result.meRead = meRead;
    if (topIds != null) result.topIds.addAll(topIds);
    return result;
  }

  Reaction._();

  factory Reaction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Reaction.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Reaction',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'total')
    ..aOB(2, _omitFieldNames ? '' : 'meRead')
    ..p<$fixnum.Int64>(3, _omitFieldNames ? '' : 'topIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Reaction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Reaction copyWith(void Function(Reaction) updates) =>
      super.copyWith((message) => updates(message as Reaction)) as Reaction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Reaction create() => Reaction._();
  @$core.override
  Reaction createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Reaction getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Reaction>(create);
  static Reaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get total => $_getIZ(0);
  @$pb.TagNumber(1)
  set total($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotal() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotal() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get meRead => $_getBF(1);
  @$pb.TagNumber(2)
  set meRead($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMeRead() => $_has(1);
  @$pb.TagNumber(2)
  void clearMeRead() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$fixnum.Int64> get topIds => $_getList(2);
}

class Reactions extends $pb.GeneratedMessage {
  factory Reactions({
    $core.Iterable<$core.MapEntry<$core.int, Reaction>>? reactions,
  }) {
    final result = create();
    if (reactions != null) result.reactions.addEntries(reactions);
    return result;
  }

  Reactions._();

  factory Reactions.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Reactions.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Reactions',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..m<$core.int, Reaction>(1, _omitFieldNames ? '' : 'reactions',
        entryClassName: 'Reactions.ReactionsEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Reaction.create,
        valueDefaultOrMaker: Reaction.getDefault,
        packageName: const $pb.PackageName('entity'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Reactions clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Reactions copyWith(void Function(Reactions) updates) =>
      super.copyWith((message) => updates(message as Reactions)) as Reactions;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Reactions create() => Reactions._();
  @$core.override
  Reactions createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Reactions getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Reactions>(create);
  static Reactions? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.int, Reaction> get reactions => $_getMap(0);
}

class Message extends $pb.GeneratedMessage {
  factory Message({
    $core.int? tpy,
    $fixnum.Int64? id,
    $fixnum.Int64? chatId,
    $fixnum.Int64? fromId,
    $core.int? pos,
    $core.int? badgeCount,
    $core.int? status,
    $fixnum.Int64? clientId,
    $fixnum.Int64? createTimeMs,
    $fixnum.Int64? updateTimeMs,
    $core.Iterable<$fixnum.Int64>? atUserIds,
    $core.List<$core.int>? content,
    $core.String? summary,
    $fixnum.Int64? version,
    ReadState? readState,
    $core.Iterable<$core.MapEntry<$core.int, Reaction>>? reactions,
    $fixnum.Int64? refMessageId,
    MessageReference? refData,
  }) {
    final result = create();
    if (tpy != null) result.tpy = tpy;
    if (id != null) result.id = id;
    if (chatId != null) result.chatId = chatId;
    if (fromId != null) result.fromId = fromId;
    if (pos != null) result.pos = pos;
    if (badgeCount != null) result.badgeCount = badgeCount;
    if (status != null) result.status = status;
    if (clientId != null) result.clientId = clientId;
    if (createTimeMs != null) result.createTimeMs = createTimeMs;
    if (updateTimeMs != null) result.updateTimeMs = updateTimeMs;
    if (atUserIds != null) result.atUserIds.addAll(atUserIds);
    if (content != null) result.content = content;
    if (summary != null) result.summary = summary;
    if (version != null) result.version = version;
    if (readState != null) result.readState = readState;
    if (reactions != null) result.reactions.addEntries(reactions);
    if (refMessageId != null) result.refMessageId = refMessageId;
    if (refData != null) result.refData = refData;
    return result;
  }

  Message._();

  factory Message.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Message.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Message',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'tpy')
    ..aInt64(2, _omitFieldNames ? '' : 'id')
    ..aInt64(3, _omitFieldNames ? '' : 'chatId')
    ..aInt64(4, _omitFieldNames ? '' : 'fromId')
    ..aI(5, _omitFieldNames ? '' : 'pos')
    ..aI(6, _omitFieldNames ? '' : 'badgeCount')
    ..aI(7, _omitFieldNames ? '' : 'status')
    ..aInt64(8, _omitFieldNames ? '' : 'clientId')
    ..aInt64(9, _omitFieldNames ? '' : 'createTimeMs')
    ..aInt64(10, _omitFieldNames ? '' : 'updateTimeMs')
    ..p<$fixnum.Int64>(
        11, _omitFieldNames ? '' : 'atUserIds', $pb.PbFieldType.K6)
    ..a<$core.List<$core.int>>(
        20, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aOS(21, _omitFieldNames ? '' : 'summary')
    ..aInt64(22, _omitFieldNames ? '' : 'version')
    ..aOM<ReadState>(23, _omitFieldNames ? '' : 'readState',
        subBuilder: ReadState.create)
    ..m<$core.int, Reaction>(24, _omitFieldNames ? '' : 'reactions',
        entryClassName: 'Message.ReactionsEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Reaction.create,
        valueDefaultOrMaker: Reaction.getDefault,
        packageName: const $pb.PackageName('entity'))
    ..aInt64(31, _omitFieldNames ? '' : 'refMessageId')
    ..aOM<MessageReference>(32, _omitFieldNames ? '' : 'refData',
        subBuilder: MessageReference.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Message clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Message copyWith(void Function(Message) updates) =>
      super.copyWith((message) => updates(message as Message)) as Message;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Message create() => Message._();
  @$core.override
  Message createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Message getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Message>(create);
  static Message? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get tpy => $_getIZ(0);
  @$pb.TagNumber(1)
  set tpy($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTpy() => $_has(0);
  @$pb.TagNumber(1)
  void clearTpy() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get id => $_getI64(1);
  @$pb.TagNumber(2)
  set id($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get chatId => $_getI64(2);
  @$pb.TagNumber(3)
  set chatId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChatId() => $_has(2);
  @$pb.TagNumber(3)
  void clearChatId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get fromId => $_getI64(3);
  @$pb.TagNumber(4)
  set fromId($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFromId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFromId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get pos => $_getIZ(4);
  @$pb.TagNumber(5)
  set pos($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPos() => $_has(4);
  @$pb.TagNumber(5)
  void clearPos() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get badgeCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set badgeCount($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBadgeCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearBadgeCount() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get status => $_getIZ(6);
  @$pb.TagNumber(7)
  set status($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get clientId => $_getI64(7);
  @$pb.TagNumber(8)
  set clientId($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasClientId() => $_has(7);
  @$pb.TagNumber(8)
  void clearClientId() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get createTimeMs => $_getI64(8);
  @$pb.TagNumber(9)
  set createTimeMs($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCreateTimeMs() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreateTimeMs() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get updateTimeMs => $_getI64(9);
  @$pb.TagNumber(10)
  set updateTimeMs($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasUpdateTimeMs() => $_has(9);
  @$pb.TagNumber(10)
  void clearUpdateTimeMs() => $_clearField(10);

  @$pb.TagNumber(11)
  $pb.PbList<$fixnum.Int64> get atUserIds => $_getList(10);

  @$pb.TagNumber(20)
  $core.List<$core.int> get content => $_getN(11);
  @$pb.TagNumber(20)
  set content($core.List<$core.int> value) => $_setBytes(11, value);
  @$pb.TagNumber(20)
  $core.bool hasContent() => $_has(11);
  @$pb.TagNumber(20)
  void clearContent() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.String get summary => $_getSZ(12);
  @$pb.TagNumber(21)
  set summary($core.String value) => $_setString(12, value);
  @$pb.TagNumber(21)
  $core.bool hasSummary() => $_has(12);
  @$pb.TagNumber(21)
  void clearSummary() => $_clearField(21);

  @$pb.TagNumber(22)
  $fixnum.Int64 get version => $_getI64(13);
  @$pb.TagNumber(22)
  set version($fixnum.Int64 value) => $_setInt64(13, value);
  @$pb.TagNumber(22)
  $core.bool hasVersion() => $_has(13);
  @$pb.TagNumber(22)
  void clearVersion() => $_clearField(22);

  @$pb.TagNumber(23)
  ReadState get readState => $_getN(14);
  @$pb.TagNumber(23)
  set readState(ReadState value) => $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasReadState() => $_has(14);
  @$pb.TagNumber(23)
  void clearReadState() => $_clearField(23);
  @$pb.TagNumber(23)
  ReadState ensureReadState() => $_ensure(14);

  @$pb.TagNumber(24)
  $pb.PbMap<$core.int, Reaction> get reactions => $_getMap(15);

  /// 引用回复：ref_message_id ≠ 0 时表示引用其他消息
  @$pb.TagNumber(31)
  $fixnum.Int64 get refMessageId => $_getI64(16);
  @$pb.TagNumber(31)
  set refMessageId($fixnum.Int64 value) => $_setInt64(16, value);
  @$pb.TagNumber(31)
  $core.bool hasRefMessageId() => $_has(16);
  @$pb.TagNumber(31)
  void clearRefMessageId() => $_clearField(31);

  @$pb.TagNumber(32)
  MessageReference get refData => $_getN(17);
  @$pb.TagNumber(32)
  set refData(MessageReference value) => $_setField(32, value);
  @$pb.TagNumber(32)
  $core.bool hasRefData() => $_has(17);
  @$pb.TagNumber(32)
  void clearRefData() => $_clearField(32);
  @$pb.TagNumber(32)
  MessageReference ensureRefData() => $_ensure(17);
}

class MessageReference extends $pb.GeneratedMessage {
  factory MessageReference({
    $fixnum.Int64? chatId,
    $core.List<$core.int>? content,
    $core.String? summary,
    $core.int? tpy,
    $core.String? senderName,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (content != null) result.content = content;
    if (summary != null) result.summary = summary;
    if (tpy != null) result.tpy = tpy;
    if (senderName != null) result.senderName = senderName;
    return result;
  }

  MessageReference._();

  factory MessageReference.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageReference.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageReference',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aOS(3, _omitFieldNames ? '' : 'summary')
    ..aI(4, _omitFieldNames ? '' : 'tpy')
    ..aOS(5, _omitFieldNames ? '' : 'senderName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageReference clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageReference copyWith(void Function(MessageReference) updates) =>
      super.copyWith((message) => updates(message as MessageReference))
          as MessageReference;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageReference create() => MessageReference._();
  @$core.override
  MessageReference createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageReference getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageReference>(create);
  static MessageReference? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get content => $_getN(1);
  @$pb.TagNumber(2)
  set content($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get summary => $_getSZ(2);
  @$pb.TagNumber(3)
  set summary($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSummary() => $_has(2);
  @$pb.TagNumber(3)
  void clearSummary() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get tpy => $_getIZ(3);
  @$pb.TagNumber(4)
  set tpy($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTpy() => $_has(3);
  @$pb.TagNumber(4)
  void clearTpy() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get senderName => $_getSZ(4);
  @$pb.TagNumber(5)
  set senderName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSenderName() => $_has(4);
  @$pb.TagNumber(5)
  void clearSenderName() => $_clearField(5);
}

class AnnouncementContent extends $pb.GeneratedMessage {
  factory AnnouncementContent({
    $core.String? title,
    $core.int? tpy,
    $core.List<$core.int>? body,
  }) {
    final result = create();
    if (title != null) result.title = title;
    if (tpy != null) result.tpy = tpy;
    if (body != null) result.body = body;
    return result;
  }

  AnnouncementContent._();

  factory AnnouncementContent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AnnouncementContent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AnnouncementContent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aI(2, _omitFieldNames ? '' : 'tpy')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'body', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnnouncementContent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnnouncementContent copyWith(void Function(AnnouncementContent) updates) =>
      super.copyWith((message) => updates(message as AnnouncementContent))
          as AnnouncementContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnnouncementContent create() => AnnouncementContent._();
  @$core.override
  AnnouncementContent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AnnouncementContent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AnnouncementContent>(create);
  static AnnouncementContent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get tpy => $_getIZ(1);
  @$pb.TagNumber(2)
  set tpy($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTpy() => $_has(1);
  @$pb.TagNumber(2)
  void clearTpy() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get body => $_getN(2);
  @$pb.TagNumber(3)
  set body($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBody() => $_has(2);
  @$pb.TagNumber(3)
  void clearBody() => $_clearField(3);
}

class Mention extends $pb.GeneratedMessage {
  factory Mention({
    $fixnum.Int64? userId,
    $core.String? name,
    $core.int? offset,
    $core.int? length,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (name != null) result.name = name;
    if (offset != null) result.offset = offset;
    if (length != null) result.length = length;
    return result;
  }

  Mention._();

  factory Mention.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Mention.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Mention',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aI(3, _omitFieldNames ? '' : 'offset')
    ..aI(4, _omitFieldNames ? '' : 'length')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Mention clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Mention copyWith(void Function(Mention) updates) =>
      super.copyWith((message) => updates(message as Mention)) as Mention;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Mention create() => Mention._();
  @$core.override
  Mention createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Mention getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Mention>(create);
  static Mention? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get offset => $_getIZ(2);
  @$pb.TagNumber(3)
  set offset($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOffset() => $_has(2);
  @$pb.TagNumber(3)
  void clearOffset() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get length => $_getIZ(3);
  @$pb.TagNumber(4)
  set length($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLength() => $_has(3);
  @$pb.TagNumber(4)
  void clearLength() => $_clearField(4);
}

class MessageText extends $pb.GeneratedMessage {
  factory MessageText({
    $core.String? text,
    $core.Iterable<Mention>? mentions,
  }) {
    final result = create();
    if (text != null) result.text = text;
    if (mentions != null) result.mentions.addAll(mentions);
    return result;
  }

  MessageText._();

  factory MessageText.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageText.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageText',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..pPM<Mention>(2, _omitFieldNames ? '' : 'mentions',
        subBuilder: Mention.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageText clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageText copyWith(void Function(MessageText) updates) =>
      super.copyWith((message) => updates(message as MessageText))
          as MessageText;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageText create() => MessageText._();
  @$core.override
  MessageText createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageText getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageText>(create);
  static MessageText? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<Mention> get mentions => $_getList(1);
}

class MessageImage extends $pb.GeneratedMessage {
  factory MessageImage({
    $core.String? url,
    $core.String? thumbnailUrl,
    $core.int? width,
    $core.int? height,
    $core.String? altText,
  }) {
    final result = create();
    if (url != null) result.url = url;
    if (thumbnailUrl != null) result.thumbnailUrl = thumbnailUrl;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (altText != null) result.altText = altText;
    return result;
  }

  MessageImage._();

  factory MessageImage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageImage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageImage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aOS(2, _omitFieldNames ? '' : 'thumbnailUrl')
    ..aI(3, _omitFieldNames ? '' : 'width')
    ..aI(4, _omitFieldNames ? '' : 'height')
    ..aOS(5, _omitFieldNames ? '' : 'altText')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageImage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageImage copyWith(void Function(MessageImage) updates) =>
      super.copyWith((message) => updates(message as MessageImage))
          as MessageImage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageImage create() => MessageImage._();
  @$core.override
  MessageImage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageImage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageImage>(create);
  static MessageImage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get thumbnailUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set thumbnailUrl($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasThumbnailUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearThumbnailUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get width => $_getIZ(2);
  @$pb.TagNumber(3)
  set width($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWidth() => $_has(2);
  @$pb.TagNumber(3)
  void clearWidth() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get height => $_getIZ(3);
  @$pb.TagNumber(4)
  set height($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeight() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get altText => $_getSZ(4);
  @$pb.TagNumber(5)
  set altText($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAltText() => $_has(4);
  @$pb.TagNumber(5)
  void clearAltText() => $_clearField(5);
}

class MessageFile extends $pb.GeneratedMessage {
  factory MessageFile({
    $core.String? name,
    $fixnum.Int64? size,
    $core.String? mimeType,
    $core.String? url,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (size != null) result.size = size;
    if (mimeType != null) result.mimeType = mimeType;
    if (url != null) result.url = url;
    return result;
  }

  MessageFile._();

  factory MessageFile.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageFile.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageFile',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aInt64(2, _omitFieldNames ? '' : 'size')
    ..aOS(3, _omitFieldNames ? '' : 'mimeType')
    ..aOS(4, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageFile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageFile copyWith(void Function(MessageFile) updates) =>
      super.copyWith((message) => updates(message as MessageFile))
          as MessageFile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageFile create() => MessageFile._();
  @$core.override
  MessageFile createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageFile getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageFile>(create);
  static MessageFile? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get size => $_getI64(1);
  @$pb.TagNumber(2)
  set size($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearSize() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get mimeType => $_getSZ(2);
  @$pb.TagNumber(3)
  set mimeType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMimeType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMimeType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get url => $_getSZ(3);
  @$pb.TagNumber(4)
  set url($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearUrl() => $_clearField(4);
}

class MessageRichText extends $pb.GeneratedMessage {
  factory MessageRichText({
    $core.String? delta,
  }) {
    final result = create();
    if (delta != null) result.delta = delta;
    return result;
  }

  MessageRichText._();

  factory MessageRichText.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageRichText.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageRichText',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'delta')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageRichText clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageRichText copyWith(void Function(MessageRichText) updates) =>
      super.copyWith((message) => updates(message as MessageRichText))
          as MessageRichText;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageRichText create() => MessageRichText._();
  @$core.override
  MessageRichText createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageRichText getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageRichText>(create);
  static MessageRichText? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get delta => $_getSZ(0);
  @$pb.TagNumber(1)
  set delta($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDelta() => $_has(0);
  @$pb.TagNumber(1)
  void clearDelta() => $_clearField(1);
}

class MessageMarkdown extends $pb.GeneratedMessage {
  factory MessageMarkdown({
    $core.String? text,
    $core.String? fallback,
  }) {
    final result = create();
    if (text != null) result.text = text;
    if (fallback != null) result.fallback = fallback;
    return result;
  }

  MessageMarkdown._();

  factory MessageMarkdown.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageMarkdown.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageMarkdown',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..aOS(2, _omitFieldNames ? '' : 'fallback')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageMarkdown clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageMarkdown copyWith(void Function(MessageMarkdown) updates) =>
      super.copyWith((message) => updates(message as MessageMarkdown))
          as MessageMarkdown;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageMarkdown create() => MessageMarkdown._();
  @$core.override
  MessageMarkdown createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageMarkdown getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageMarkdown>(create);
  static MessageMarkdown? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fallback => $_getSZ(1);
  @$pb.TagNumber(2)
  set fallback($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFallback() => $_has(1);
  @$pb.TagNumber(2)
  void clearFallback() => $_clearField(2);
}

class MessageForward extends $pb.GeneratedMessage {
  factory MessageForward({
    $core.int? type,
    $fixnum.Int64? chatId,
    $core.String? chatName,
    $core.int? messageCount,
    $core.String? title,
    $core.Iterable<ForwardItem>? items,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (chatId != null) result.chatId = chatId;
    if (chatName != null) result.chatName = chatName;
    if (messageCount != null) result.messageCount = messageCount;
    if (title != null) result.title = title;
    if (items != null) result.items.addAll(items);
    return result;
  }

  MessageForward._();

  factory MessageForward.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageForward.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageForward',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'type')
    ..aInt64(2, _omitFieldNames ? '' : 'chatId')
    ..aOS(3, _omitFieldNames ? '' : 'chatName')
    ..aI(4, _omitFieldNames ? '' : 'messageCount')
    ..aOS(5, _omitFieldNames ? '' : 'title')
    ..pPM<ForwardItem>(6, _omitFieldNames ? '' : 'items',
        subBuilder: ForwardItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageForward clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageForward copyWith(void Function(MessageForward) updates) =>
      super.copyWith((message) => updates(message as MessageForward))
          as MessageForward;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageForward create() => MessageForward._();
  @$core.override
  MessageForward createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageForward getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageForward>(create);
  static MessageForward? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

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
  $core.int get messageCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set messageCount($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMessageCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessageCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get title => $_getSZ(4);
  @$pb.TagNumber(5)
  set title($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTitle() => $_has(4);
  @$pb.TagNumber(5)
  void clearTitle() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<ForwardItem> get items => $_getList(5);
}

class ForwardItem extends $pb.GeneratedMessage {
  factory ForwardItem({
    $fixnum.Int64? userId,
    $core.String? userName,
    $core.int? tpy,
    $core.String? summary,
    $fixnum.Int64? messageId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (userName != null) result.userName = userName;
    if (tpy != null) result.tpy = tpy;
    if (summary != null) result.summary = summary;
    if (messageId != null) result.messageId = messageId;
    return result;
  }

  ForwardItem._();

  factory ForwardItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ForwardItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ForwardItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'userName')
    ..aI(3, _omitFieldNames ? '' : 'tpy')
    ..aOS(4, _omitFieldNames ? '' : 'summary')
    ..aInt64(5, _omitFieldNames ? '' : 'messageId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardItem copyWith(void Function(ForwardItem) updates) =>
      super.copyWith((message) => updates(message as ForwardItem))
          as ForwardItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ForwardItem create() => ForwardItem._();
  @$core.override
  ForwardItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ForwardItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ForwardItem>(create);
  static ForwardItem? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userName => $_getSZ(1);
  @$pb.TagNumber(2)
  set userName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserName() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get tpy => $_getIZ(2);
  @$pb.TagNumber(3)
  set tpy($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTpy() => $_has(2);
  @$pb.TagNumber(3)
  void clearTpy() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get summary => $_getSZ(3);
  @$pb.TagNumber(4)
  set summary($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSummary() => $_has(3);
  @$pb.TagNumber(4)
  void clearSummary() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get messageId => $_getI64(4);
  @$pb.TagNumber(5)
  set messageId($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMessageId() => $_has(4);
  @$pb.TagNumber(5)
  void clearMessageId() => $_clearField(5);
}

class MessageSystem extends $pb.GeneratedMessage {
  factory MessageSystem({
    $core.int? action,
    $core.String? text,
    $fixnum.Int64? operatorId,
    $core.Iterable<$fixnum.Int64>? targetIds,
  }) {
    final result = create();
    if (action != null) result.action = action;
    if (text != null) result.text = text;
    if (operatorId != null) result.operatorId = operatorId;
    if (targetIds != null) result.targetIds.addAll(targetIds);
    return result;
  }

  MessageSystem._();

  factory MessageSystem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageSystem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageSystem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'action')
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..aInt64(3, _omitFieldNames ? '' : 'operatorId')
    ..p<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'targetIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageSystem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageSystem copyWith(void Function(MessageSystem) updates) =>
      super.copyWith((message) => updates(message as MessageSystem))
          as MessageSystem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageSystem create() => MessageSystem._();
  @$core.override
  MessageSystem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageSystem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageSystem>(create);
  static MessageSystem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get action => $_getIZ(0);
  @$pb.TagNumber(1)
  set action($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAction() => $_has(0);
  @$pb.TagNumber(1)
  void clearAction() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get operatorId => $_getI64(2);
  @$pb.TagNumber(3)
  set operatorId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOperatorId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOperatorId() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$fixnum.Int64> get targetIds => $_getList(3);
}

class FileInfo extends $pb.GeneratedMessage {
  factory FileInfo({
    $core.String? id,
    $core.String? name,
    $fixnum.Int64? size,
    $core.String? mimeType,
    $core.String? url,
    $fixnum.Int64? uploaderId,
    $fixnum.Int64? createdAtMs,
    $core.String? thumbnailUrl,
    $core.int? width,
    $core.int? height,
    $core.String? md5,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (size != null) result.size = size;
    if (mimeType != null) result.mimeType = mimeType;
    if (url != null) result.url = url;
    if (uploaderId != null) result.uploaderId = uploaderId;
    if (createdAtMs != null) result.createdAtMs = createdAtMs;
    if (thumbnailUrl != null) result.thumbnailUrl = thumbnailUrl;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (md5 != null) result.md5 = md5;
    return result;
  }

  FileInfo._();

  factory FileInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FileInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aInt64(3, _omitFieldNames ? '' : 'size')
    ..aOS(4, _omitFieldNames ? '' : 'mimeType')
    ..aOS(5, _omitFieldNames ? '' : 'url')
    ..aInt64(6, _omitFieldNames ? '' : 'uploaderId')
    ..aInt64(7, _omitFieldNames ? '' : 'createdAtMs')
    ..aOS(8, _omitFieldNames ? '' : 'thumbnailUrl')
    ..aI(9, _omitFieldNames ? '' : 'width')
    ..aI(10, _omitFieldNames ? '' : 'height')
    ..aOS(11, _omitFieldNames ? '' : 'md5')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileInfo copyWith(void Function(FileInfo) updates) =>
      super.copyWith((message) => updates(message as FileInfo)) as FileInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileInfo create() => FileInfo._();
  @$core.override
  FileInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FileInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FileInfo>(create);
  static FileInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get size => $_getI64(2);
  @$pb.TagNumber(3)
  set size($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearSize() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get mimeType => $_getSZ(3);
  @$pb.TagNumber(4)
  set mimeType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMimeType() => $_has(3);
  @$pb.TagNumber(4)
  void clearMimeType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get url => $_getSZ(4);
  @$pb.TagNumber(5)
  set url($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearUrl() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get uploaderId => $_getI64(5);
  @$pb.TagNumber(6)
  set uploaderId($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUploaderId() => $_has(5);
  @$pb.TagNumber(6)
  void clearUploaderId() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get createdAtMs => $_getI64(6);
  @$pb.TagNumber(7)
  set createdAtMs($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAtMs() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAtMs() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get thumbnailUrl => $_getSZ(7);
  @$pb.TagNumber(8)
  set thumbnailUrl($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasThumbnailUrl() => $_has(7);
  @$pb.TagNumber(8)
  void clearThumbnailUrl() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get width => $_getIZ(8);
  @$pb.TagNumber(9)
  set width($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasWidth() => $_has(8);
  @$pb.TagNumber(9)
  void clearWidth() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get height => $_getIZ(9);
  @$pb.TagNumber(10)
  set height($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasHeight() => $_has(9);
  @$pb.TagNumber(10)
  void clearHeight() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get md5 => $_getSZ(10);
  @$pb.TagNumber(11)
  set md5($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasMd5() => $_has(10);
  @$pb.TagNumber(11)
  void clearMd5() => $_clearField(11);
}

class UserConfig extends $pb.GeneratedMessage {
  factory UserConfig() => create();

  UserConfig._();

  factory UserConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserConfig',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserConfig copyWith(void Function(UserConfig) updates) =>
      super.copyWith((message) => updates(message as UserConfig)) as UserConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserConfig create() => UserConfig._();
  @$core.override
  UserConfig createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UserConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserConfig>(create);
  static UserConfig? _defaultInstance;
}

class LoginUser extends $pb.GeneratedMessage {
  factory LoginUser({
    User? user,
    $core.String? token,
    Tenant? tenant,
    $fixnum.Int64? tokenExpire,
  }) {
    final result = create();
    if (user != null) result.user = user;
    if (token != null) result.token = token;
    if (tenant != null) result.tenant = tenant;
    if (tokenExpire != null) result.tokenExpire = tokenExpire;
    return result;
  }

  LoginUser._();

  factory LoginUser.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LoginUser.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoginUser',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aOM<User>(1, _omitFieldNames ? '' : 'user', subBuilder: User.create)
    ..aOS(2, _omitFieldNames ? '' : 'token')
    ..aOM<Tenant>(3, _omitFieldNames ? '' : 'tenant', subBuilder: Tenant.create)
    ..aInt64(4, _omitFieldNames ? '' : 'tokenExpire')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginUser clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginUser copyWith(void Function(LoginUser) updates) =>
      super.copyWith((message) => updates(message as LoginUser)) as LoginUser;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoginUser create() => LoginUser._();
  @$core.override
  LoginUser createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LoginUser getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoginUser>(create);
  static LoginUser? _defaultInstance;

  @$pb.TagNumber(1)
  User get user => $_getN(0);
  @$pb.TagNumber(1)
  set user(User value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasUser() => $_has(0);
  @$pb.TagNumber(1)
  void clearUser() => $_clearField(1);
  @$pb.TagNumber(1)
  User ensureUser() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get token => $_getSZ(1);
  @$pb.TagNumber(2)
  set token($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearToken() => $_clearField(2);

  @$pb.TagNumber(3)
  Tenant get tenant => $_getN(2);
  @$pb.TagNumber(3)
  set tenant(Tenant value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTenant() => $_has(2);
  @$pb.TagNumber(3)
  void clearTenant() => $_clearField(3);
  @$pb.TagNumber(3)
  Tenant ensureTenant() => $_ensure(2);

  @$pb.TagNumber(4)
  $fixnum.Int64 get tokenExpire => $_getI64(3);
  @$pb.TagNumber(4)
  set tokenExpire($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTokenExpire() => $_has(3);
  @$pb.TagNumber(4)
  void clearTokenExpire() => $_clearField(4);
}

class Account extends $pb.GeneratedMessage {
  factory Account({
    $fixnum.Int64? id,
    $core.String? name,
    $core.Iterable<LoginUser>? users,
    $fixnum.Int64? version,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (users != null) result.users.addAll(users);
    if (version != null) result.version = version;
    return result;
  }

  Account._();

  factory Account.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Account.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Account',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..pPM<LoginUser>(3, _omitFieldNames ? '' : 'users',
        subBuilder: LoginUser.create)
    ..aInt64(4, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Account clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Account copyWith(void Function(Account) updates) =>
      super.copyWith((message) => updates(message as Account)) as Account;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Account create() => Account._();
  @$core.override
  Account createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Account getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Account>(create);
  static Account? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<LoginUser> get users => $_getList(2);

  @$pb.TagNumber(4)
  $fixnum.Int64 get version => $_getI64(3);
  @$pb.TagNumber(4)
  set version($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearVersion() => $_clearField(4);
}

class Tenant extends $pb.GeneratedMessage {
  factory Tenant({
    $fixnum.Int64? id,
    $core.String? name,
    $fixnum.Int64? rootDepartmentId,
    $fixnum.Int64? ownerId,
    $fixnum.Int64? version,
    $core.String? avatar,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (rootDepartmentId != null) result.rootDepartmentId = rootDepartmentId;
    if (ownerId != null) result.ownerId = ownerId;
    if (version != null) result.version = version;
    if (avatar != null) result.avatar = avatar;
    return result;
  }

  Tenant._();

  factory Tenant.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Tenant.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Tenant',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aInt64(3, _omitFieldNames ? '' : 'rootDepartmentId')
    ..aInt64(4, _omitFieldNames ? '' : 'ownerId')
    ..aInt64(5, _omitFieldNames ? '' : 'version')
    ..aOS(6, _omitFieldNames ? '' : 'avatar')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tenant clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tenant copyWith(void Function(Tenant) updates) =>
      super.copyWith((message) => updates(message as Tenant)) as Tenant;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Tenant create() => Tenant._();
  @$core.override
  Tenant createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Tenant getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Tenant>(create);
  static Tenant? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get rootDepartmentId => $_getI64(2);
  @$pb.TagNumber(3)
  set rootDepartmentId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRootDepartmentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRootDepartmentId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get ownerId => $_getI64(3);
  @$pb.TagNumber(4)
  set ownerId($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOwnerId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOwnerId() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get version => $_getI64(4);
  @$pb.TagNumber(5)
  set version($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get avatar => $_getSZ(5);
  @$pb.TagNumber(6)
  set avatar($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAvatar() => $_has(5);
  @$pb.TagNumber(6)
  void clearAvatar() => $_clearField(6);
}

class Department extends $pb.GeneratedMessage {
  factory Department({
    $fixnum.Int64? id,
    $fixnum.Int64? parentId,
    $fixnum.Int64? tenantId,
    $core.Iterable<$fixnum.Int64>? memberIds,
    $core.Iterable<$fixnum.Int64>? subDepartmentIds,
    $core.String? name,
    $fixnum.Int64? version,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (parentId != null) result.parentId = parentId;
    if (tenantId != null) result.tenantId = tenantId;
    if (memberIds != null) result.memberIds.addAll(memberIds);
    if (subDepartmentIds != null)
      result.subDepartmentIds.addAll(subDepartmentIds);
    if (name != null) result.name = name;
    if (version != null) result.version = version;
    return result;
  }

  Department._();

  factory Department.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Department.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Department',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'parentId')
    ..aInt64(3, _omitFieldNames ? '' : 'tenantId')
    ..p<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'memberIds', $pb.PbFieldType.K6)
    ..p<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'subDepartmentIds', $pb.PbFieldType.K6)
    ..aOS(6, _omitFieldNames ? '' : 'name')
    ..aInt64(7, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Department clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Department copyWith(void Function(Department) updates) =>
      super.copyWith((message) => updates(message as Department)) as Department;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Department create() => Department._();
  @$core.override
  Department createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Department getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Department>(create);
  static Department? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get parentId => $_getI64(1);
  @$pb.TagNumber(2)
  set parentId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasParentId() => $_has(1);
  @$pb.TagNumber(2)
  void clearParentId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get tenantId => $_getI64(2);
  @$pb.TagNumber(3)
  set tenantId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTenantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTenantId() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$fixnum.Int64> get memberIds => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$fixnum.Int64> get subDepartmentIds => $_getList(4);

  @$pb.TagNumber(6)
  $core.String get name => $_getSZ(5);
  @$pb.TagNumber(6)
  set name($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasName() => $_has(5);
  @$pb.TagNumber(6)
  void clearName() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get version => $_getI64(6);
  @$pb.TagNumber(7)
  set version($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasVersion() => $_has(6);
  @$pb.TagNumber(7)
  void clearVersion() => $_clearField(7);
}

class Packet extends $pb.GeneratedMessage {
  factory Packet({
    $fixnum.Int64? rid,
    $core.int? cmd,
    $core.int? code,
    $core.bool? http,
    $core.List<$core.int>? payload,
  }) {
    final result = create();
    if (rid != null) result.rid = rid;
    if (cmd != null) result.cmd = cmd;
    if (code != null) result.code = code;
    if (http != null) result.http = http;
    if (payload != null) result.payload = payload;
    return result;
  }

  Packet._();

  factory Packet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Packet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Packet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'rid')
    ..aI(2, _omitFieldNames ? '' : 'cmd')
    ..aI(3, _omitFieldNames ? '' : 'code')
    ..aOB(4, _omitFieldNames ? '' : 'http')
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Packet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Packet copyWith(void Function(Packet) updates) =>
      super.copyWith((message) => updates(message as Packet)) as Packet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Packet create() => Packet._();
  @$core.override
  Packet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Packet getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Packet>(create);
  static Packet? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get rid => $_getI64(0);
  @$pb.TagNumber(1)
  set rid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRid() => $_has(0);
  @$pb.TagNumber(1)
  void clearRid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get cmd => $_getIZ(1);
  @$pb.TagNumber(2)
  set cmd($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCmd() => $_has(1);
  @$pb.TagNumber(2)
  void clearCmd() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get code => $_getIZ(2);
  @$pb.TagNumber(3)
  set code($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearCode() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get http => $_getBF(3);
  @$pb.TagNumber(4)
  set http($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHttp() => $_has(3);
  @$pb.TagNumber(4)
  void clearHttp() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get payload => $_getN(4);
  @$pb.TagNumber(5)
  set payload($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPayload() => $_has(4);
  @$pb.TagNumber(5)
  void clearPayload() => $_clearField(5);
}

class Entity extends $pb.GeneratedMessage {
  factory Entity({
    $core.Iterable<$core.MapEntry<$fixnum.Int64, $fixnum.Int64>>? entityIds,
    $core.Iterable<$core.MapEntry<$fixnum.Int64, User>>? users,
    $core.Iterable<$core.MapEntry<$fixnum.Int64, Chat>>? chats,
    $core.Iterable<$core.MapEntry<$fixnum.Int64, Message>>? messages,
    $core.Iterable<$core.MapEntry<$fixnum.Int64, Feed>>? feeds,
    $core.Iterable<$core.MapEntry<$core.String, FileInfo>>? files,
  }) {
    final result = create();
    if (entityIds != null) result.entityIds.addEntries(entityIds);
    if (users != null) result.users.addEntries(users);
    if (chats != null) result.chats.addEntries(chats);
    if (messages != null) result.messages.addEntries(messages);
    if (feeds != null) result.feeds.addEntries(feeds);
    if (files != null) result.files.addEntries(files);
    return result;
  }

  Entity._();

  factory Entity.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Entity.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Entity',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..m<$fixnum.Int64, $fixnum.Int64>(1, _omitFieldNames ? '' : 'entityIds',
        entryClassName: 'Entity.EntityIdsEntry',
        keyFieldType: $pb.PbFieldType.O6,
        valueFieldType: $pb.PbFieldType.O6,
        packageName: const $pb.PackageName('entity'))
    ..m<$fixnum.Int64, User>(2, _omitFieldNames ? '' : 'users',
        entryClassName: 'Entity.UsersEntry',
        keyFieldType: $pb.PbFieldType.O6,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: User.create,
        valueDefaultOrMaker: User.getDefault,
        packageName: const $pb.PackageName('entity'))
    ..m<$fixnum.Int64, Chat>(3, _omitFieldNames ? '' : 'chats',
        entryClassName: 'Entity.ChatsEntry',
        keyFieldType: $pb.PbFieldType.O6,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Chat.create,
        valueDefaultOrMaker: Chat.getDefault,
        packageName: const $pb.PackageName('entity'))
    ..m<$fixnum.Int64, Message>(4, _omitFieldNames ? '' : 'messages',
        entryClassName: 'Entity.MessagesEntry',
        keyFieldType: $pb.PbFieldType.O6,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Message.create,
        valueDefaultOrMaker: Message.getDefault,
        packageName: const $pb.PackageName('entity'))
    ..m<$fixnum.Int64, Feed>(5, _omitFieldNames ? '' : 'feeds',
        entryClassName: 'Entity.FeedsEntry',
        keyFieldType: $pb.PbFieldType.O6,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Feed.create,
        valueDefaultOrMaker: Feed.getDefault,
        packageName: const $pb.PackageName('entity'))
    ..m<$core.String, FileInfo>(6, _omitFieldNames ? '' : 'files',
        entryClassName: 'Entity.FilesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: FileInfo.create,
        valueDefaultOrMaker: FileInfo.getDefault,
        packageName: const $pb.PackageName('entity'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Entity clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Entity copyWith(void Function(Entity) updates) =>
      super.copyWith((message) => updates(message as Entity)) as Entity;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Entity create() => Entity._();
  @$core.override
  Entity createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Entity getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Entity>(create);
  static Entity? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$fixnum.Int64, $fixnum.Int64> get entityIds => $_getMap(0);

  @$pb.TagNumber(2)
  $pb.PbMap<$fixnum.Int64, User> get users => $_getMap(1);

  @$pb.TagNumber(3)
  $pb.PbMap<$fixnum.Int64, Chat> get chats => $_getMap(2);

  @$pb.TagNumber(4)
  $pb.PbMap<$fixnum.Int64, Message> get messages => $_getMap(3);

  @$pb.TagNumber(5)
  $pb.PbMap<$fixnum.Int64, Feed> get feeds => $_getMap(4);

  @$pb.TagNumber(6)
  $pb.PbMap<$core.String, FileInfo> get files => $_getMap(5);
}

class EntityImage extends $pb.GeneratedMessage {
  factory EntityImage({
    $core.String? url,
    $core.int? width,
    $core.int? height,
    $core.int? size,
  }) {
    final result = create();
    if (url != null) result.url = url;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (size != null) result.size = size;
    return result;
  }

  EntityImage._();

  factory EntityImage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EntityImage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EntityImage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aI(3, _omitFieldNames ? '' : 'width')
    ..aI(4, _omitFieldNames ? '' : 'height')
    ..aI(5, _omitFieldNames ? '' : 'size')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntityImage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntityImage copyWith(void Function(EntityImage) updates) =>
      super.copyWith((message) => updates(message as EntityImage))
          as EntityImage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EntityImage create() => EntityImage._();
  @$core.override
  EntityImage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EntityImage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EntityImage>(create);
  static EntityImage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  @$pb.TagNumber(3)
  $core.int get width => $_getIZ(1);
  @$pb.TagNumber(3)
  set width($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(3)
  $core.bool hasWidth() => $_has(1);
  @$pb.TagNumber(3)
  void clearWidth() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get height => $_getIZ(2);
  @$pb.TagNumber(4)
  set height($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(4)
  $core.bool hasHeight() => $_has(2);
  @$pb.TagNumber(4)
  void clearHeight() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get size => $_getIZ(3);
  @$pb.TagNumber(5)
  set size($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(5)
  $core.bool hasSize() => $_has(3);
  @$pb.TagNumber(5)
  void clearSize() => $_clearField(5);
}

class ImageIcon extends $pb.GeneratedMessage {
  factory ImageIcon({
    $core.int? type,
    $core.String? key,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (key != null) result.key = key;
    return result;
  }

  ImageIcon._();

  factory ImageIcon.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImageIcon.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImageIcon',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'Key', protoName: 'Key')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageIcon clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageIcon copyWith(void Function(ImageIcon) updates) =>
      super.copyWith((message) => updates(message as ImageIcon)) as ImageIcon;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImageIcon create() => ImageIcon._();
  @$core.override
  ImageIcon createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImageIcon getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImageIcon>(create);
  static ImageIcon? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get key => $_getSZ(1);
  @$pb.TagNumber(2)
  set key($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearKey() => $_clearField(2);
}

class PipeUpdateItem extends $pb.GeneratedMessage {
  factory PipeUpdateItem({
    $fixnum.Int64? sid,
    $core.int? typ,
    $fixnum.Int64? id,
    $fixnum.Int64? version,
  }) {
    final result = create();
    if (sid != null) result.sid = sid;
    if (typ != null) result.typ = typ;
    if (id != null) result.id = id;
    if (version != null) result.version = version;
    return result;
  }

  PipeUpdateItem._();

  factory PipeUpdateItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PipeUpdateItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PipeUpdateItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'sid')
    ..aI(2, _omitFieldNames ? '' : 'typ')
    ..aInt64(3, _omitFieldNames ? '' : 'id')
    ..aInt64(4, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PipeUpdateItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PipeUpdateItem copyWith(void Function(PipeUpdateItem) updates) =>
      super.copyWith((message) => updates(message as PipeUpdateItem))
          as PipeUpdateItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PipeUpdateItem create() => PipeUpdateItem._();
  @$core.override
  PipeUpdateItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PipeUpdateItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PipeUpdateItem>(create);
  static PipeUpdateItem? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get sid => $_getI64(0);
  @$pb.TagNumber(1)
  set sid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSid() => $_has(0);
  @$pb.TagNumber(1)
  void clearSid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get typ => $_getIZ(1);
  @$pb.TagNumber(2)
  set typ($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTyp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTyp() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get id => $_getI64(2);
  @$pb.TagNumber(3)
  set id($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get version => $_getI64(3);
  @$pb.TagNumber(4)
  set version($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearVersion() => $_clearField(4);
}

class MemberStatus extends $pb.GeneratedMessage {
  factory MemberStatus({
    $fixnum.Int64? id,
    $fixnum.Int64? finishTime,
    $core.int? status,
    $core.bool? subscribe,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (finishTime != null) result.finishTime = finishTime;
    if (status != null) result.status = status;
    if (subscribe != null) result.subscribe = subscribe;
    return result;
  }

  MemberStatus._();

  factory MemberStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MemberStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MemberStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'finishTime')
    ..aI(3, _omitFieldNames ? '' : 'status')
    ..aOB(4, _omitFieldNames ? '' : 'subscribe')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberStatus copyWith(void Function(MemberStatus) updates) =>
      super.copyWith((message) => updates(message as MemberStatus))
          as MemberStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MemberStatus create() => MemberStatus._();
  @$core.override
  MemberStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MemberStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MemberStatus>(create);
  static MemberStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get finishTime => $_getI64(1);
  @$pb.TagNumber(2)
  set finishTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFinishTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearFinishTime() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get status => $_getIZ(2);
  @$pb.TagNumber(3)
  set status($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get subscribe => $_getBF(3);
  @$pb.TagNumber(4)
  set subscribe($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSubscribe() => $_has(3);
  @$pb.TagNumber(4)
  void clearSubscribe() => $_clearField(4);
}

class Task extends $pb.GeneratedMessage {
  factory Task({
    $fixnum.Int64? id,
    $fixnum.Int64? creator,
    $core.String? title,
    $fixnum.Int64? createTime,
    $fixnum.Int64? updateTime,
    $fixnum.Int64? startTime,
    $fixnum.Int64? deadline,
    $core.Iterable<MemberStatus>? status,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (creator != null) result.creator = creator;
    if (title != null) result.title = title;
    if (createTime != null) result.createTime = createTime;
    if (updateTime != null) result.updateTime = updateTime;
    if (startTime != null) result.startTime = startTime;
    if (deadline != null) result.deadline = deadline;
    if (status != null) result.status.addAll(status);
    return result;
  }

  Task._();

  factory Task.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Task.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Task',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'creator')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aInt64(4, _omitFieldNames ? '' : 'createTime')
    ..aInt64(6, _omitFieldNames ? '' : 'updateTime')
    ..aInt64(7, _omitFieldNames ? '' : 'startTime')
    ..aInt64(8, _omitFieldNames ? '' : 'deadline')
    ..pPM<MemberStatus>(9, _omitFieldNames ? '' : 'status',
        subBuilder: MemberStatus.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Task clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Task copyWith(void Function(Task) updates) =>
      super.copyWith((message) => updates(message as Task)) as Task;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Task create() => Task._();
  @$core.override
  Task createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Task getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Task>(create);
  static Task? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get creator => $_getI64(1);
  @$pb.TagNumber(2)
  set creator($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCreator() => $_has(1);
  @$pb.TagNumber(2)
  void clearCreator() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get createTime => $_getI64(3);
  @$pb.TagNumber(4)
  set createTime($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCreateTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreateTime() => $_clearField(4);

  @$pb.TagNumber(6)
  $fixnum.Int64 get updateTime => $_getI64(4);
  @$pb.TagNumber(6)
  set updateTime($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(6)
  $core.bool hasUpdateTime() => $_has(4);
  @$pb.TagNumber(6)
  void clearUpdateTime() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get startTime => $_getI64(5);
  @$pb.TagNumber(7)
  set startTime($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(7)
  $core.bool hasStartTime() => $_has(5);
  @$pb.TagNumber(7)
  void clearStartTime() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get deadline => $_getI64(6);
  @$pb.TagNumber(8)
  set deadline($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(8)
  $core.bool hasDeadline() => $_has(6);
  @$pb.TagNumber(8)
  void clearDeadline() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<MemberStatus> get status => $_getList(7);
}

class Todo extends $pb.GeneratedMessage {
  factory Todo({
    $fixnum.Int64? id,
    Task? main,
    $core.int? messageCount,
    $core.Iterable<Task>? subTask,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (main != null) result.main = main;
    if (messageCount != null) result.messageCount = messageCount;
    if (subTask != null) result.subTask.addAll(subTask);
    return result;
  }

  Todo._();

  factory Todo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Todo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Todo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOM<Task>(2, _omitFieldNames ? '' : 'main', subBuilder: Task.create)
    ..aI(3, _omitFieldNames ? '' : 'messageCount')
    ..pPM<Task>(4, _omitFieldNames ? '' : 'subTask', subBuilder: Task.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Todo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Todo copyWith(void Function(Todo) updates) =>
      super.copyWith((message) => updates(message as Todo)) as Todo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Todo create() => Todo._();
  @$core.override
  Todo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Todo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Todo>(create);
  static Todo? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  Task get main => $_getN(1);
  @$pb.TagNumber(2)
  set main(Task value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMain() => $_has(1);
  @$pb.TagNumber(2)
  void clearMain() => $_clearField(2);
  @$pb.TagNumber(2)
  Task ensureMain() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.int get messageCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set messageCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessageCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessageCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<Task> get subTask => $_getList(3);
}

class CalendarSubscribers extends $pb.GeneratedMessage {
  factory CalendarSubscribers({
    $core.Iterable<$core.MapEntry<$fixnum.Int64, Calendar_Subscriber>>?
        subscribers,
  }) {
    final result = create();
    if (subscribers != null) result.subscribers.addEntries(subscribers);
    return result;
  }

  CalendarSubscribers._();

  factory CalendarSubscribers.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarSubscribers.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarSubscribers',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..m<$fixnum.Int64, Calendar_Subscriber>(
        1, _omitFieldNames ? '' : 'subscribers',
        entryClassName: 'CalendarSubscribers.SubscribersEntry',
        keyFieldType: $pb.PbFieldType.O6,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Calendar_Subscriber.create,
        valueDefaultOrMaker: Calendar_Subscriber.getDefault,
        packageName: const $pb.PackageName('entity'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarSubscribers clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarSubscribers copyWith(void Function(CalendarSubscribers) updates) =>
      super.copyWith((message) => updates(message as CalendarSubscribers))
          as CalendarSubscribers;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarSubscribers create() => CalendarSubscribers._();
  @$core.override
  CalendarSubscribers createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarSubscribers getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarSubscribers>(create);
  static CalendarSubscribers? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$fixnum.Int64, Calendar_Subscriber> get subscribers => $_getMap(0);
}

class Calendar_Subscriber extends $pb.GeneratedMessage {
  factory Calendar_Subscriber({
    $fixnum.Int64? id,
    $fixnum.Int64? subscribeTime,
    $core.int? role,
    $core.int? color,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (subscribeTime != null) result.subscribeTime = subscribeTime;
    if (role != null) result.role = role;
    if (color != null) result.color = color;
    return result;
  }

  Calendar_Subscriber._();

  factory Calendar_Subscriber.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Calendar_Subscriber.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Calendar.Subscriber',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'subscribeTime')
    ..aI(3, _omitFieldNames ? '' : 'role')
    ..aI(4, _omitFieldNames ? '' : 'color')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Calendar_Subscriber clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Calendar_Subscriber copyWith(void Function(Calendar_Subscriber) updates) =>
      super.copyWith((message) => updates(message as Calendar_Subscriber))
          as Calendar_Subscriber;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Calendar_Subscriber create() => Calendar_Subscriber._();
  @$core.override
  Calendar_Subscriber createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Calendar_Subscriber getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Calendar_Subscriber>(create);
  static Calendar_Subscriber? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get subscribeTime => $_getI64(1);
  @$pb.TagNumber(2)
  set subscribeTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSubscribeTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearSubscribeTime() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get role => $_getIZ(2);
  @$pb.TagNumber(3)
  set role($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRole() => $_has(2);
  @$pb.TagNumber(3)
  void clearRole() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get color => $_getIZ(3);
  @$pb.TagNumber(4)
  set color($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasColor() => $_has(3);
  @$pb.TagNumber(4)
  void clearColor() => $_clearField(4);
}

class Calendar extends $pb.GeneratedMessage {
  factory Calendar({
    $fixnum.Int64? id,
    $fixnum.Int64? creater,
    $fixnum.Int64? tenantId,
    $fixnum.Int64? version,
    $core.int? color,
    $core.String? name,
    $core.String? desc,
    $core.bool? isDefault,
    $core.bool? public,
    $core.bool? enable,
    CalendarSubscribers? subscribers,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (creater != null) result.creater = creater;
    if (tenantId != null) result.tenantId = tenantId;
    if (version != null) result.version = version;
    if (color != null) result.color = color;
    if (name != null) result.name = name;
    if (desc != null) result.desc = desc;
    if (isDefault != null) result.isDefault = isDefault;
    if (public != null) result.public = public;
    if (enable != null) result.enable = enable;
    if (subscribers != null) result.subscribers = subscribers;
    return result;
  }

  Calendar._();

  factory Calendar.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Calendar.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Calendar',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(3, _omitFieldNames ? '' : 'creater')
    ..aInt64(5, _omitFieldNames ? '' : 'tenantId')
    ..aInt64(6, _omitFieldNames ? '' : 'version')
    ..aI(7, _omitFieldNames ? '' : 'color')
    ..aOS(8, _omitFieldNames ? '' : 'name')
    ..aOS(9, _omitFieldNames ? '' : 'desc')
    ..aOB(10, _omitFieldNames ? '' : 'isDefault')
    ..aOB(11, _omitFieldNames ? '' : 'public')
    ..aOB(12, _omitFieldNames ? '' : 'enable')
    ..aOM<CalendarSubscribers>(20, _omitFieldNames ? '' : 'subscribers',
        subBuilder: CalendarSubscribers.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Calendar clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Calendar copyWith(void Function(Calendar) updates) =>
      super.copyWith((message) => updates(message as Calendar)) as Calendar;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Calendar create() => Calendar._();
  @$core.override
  Calendar createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Calendar getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Calendar>(create);
  static Calendar? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get creater => $_getI64(1);
  @$pb.TagNumber(3)
  set creater($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(3)
  $core.bool hasCreater() => $_has(1);
  @$pb.TagNumber(3)
  void clearCreater() => $_clearField(3);

  @$pb.TagNumber(5)
  $fixnum.Int64 get tenantId => $_getI64(2);
  @$pb.TagNumber(5)
  set tenantId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(5)
  $core.bool hasTenantId() => $_has(2);
  @$pb.TagNumber(5)
  void clearTenantId() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get version => $_getI64(3);
  @$pb.TagNumber(6)
  set version($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(6)
  $core.bool hasVersion() => $_has(3);
  @$pb.TagNumber(6)
  void clearVersion() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get color => $_getIZ(4);
  @$pb.TagNumber(7)
  set color($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(7)
  $core.bool hasColor() => $_has(4);
  @$pb.TagNumber(7)
  void clearColor() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get name => $_getSZ(5);
  @$pb.TagNumber(8)
  set name($core.String value) => $_setString(5, value);
  @$pb.TagNumber(8)
  $core.bool hasName() => $_has(5);
  @$pb.TagNumber(8)
  void clearName() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get desc => $_getSZ(6);
  @$pb.TagNumber(9)
  set desc($core.String value) => $_setString(6, value);
  @$pb.TagNumber(9)
  $core.bool hasDesc() => $_has(6);
  @$pb.TagNumber(9)
  void clearDesc() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isDefault => $_getBF(7);
  @$pb.TagNumber(10)
  set isDefault($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(10)
  $core.bool hasIsDefault() => $_has(7);
  @$pb.TagNumber(10)
  void clearIsDefault() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get public => $_getBF(8);
  @$pb.TagNumber(11)
  set public($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(11)
  $core.bool hasPublic() => $_has(8);
  @$pb.TagNumber(11)
  void clearPublic() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get enable => $_getBF(9);
  @$pb.TagNumber(12)
  set enable($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(12)
  $core.bool hasEnable() => $_has(9);
  @$pb.TagNumber(12)
  void clearEnable() => $_clearField(12);

  @$pb.TagNumber(20)
  CalendarSubscribers get subscribers => $_getN(10);
  @$pb.TagNumber(20)
  set subscribers(CalendarSubscribers value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasSubscribers() => $_has(10);
  @$pb.TagNumber(20)
  void clearSubscribers() => $_clearField(20);
  @$pb.TagNumber(20)
  CalendarSubscribers ensureSubscribers() => $_ensure(10);
}

class SubscribeCalendarList extends $pb.GeneratedMessage {
  factory SubscribeCalendarList({
    $core.Iterable<Calendar>? calendars,
  }) {
    final result = create();
    if (calendars != null) result.calendars.addAll(calendars);
    return result;
  }

  SubscribeCalendarList._();

  factory SubscribeCalendarList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubscribeCalendarList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscribeCalendarList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..pPM<Calendar>(1, _omitFieldNames ? '' : 'calendars',
        subBuilder: Calendar.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeCalendarList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeCalendarList copyWith(
          void Function(SubscribeCalendarList) updates) =>
      super.copyWith((message) => updates(message as SubscribeCalendarList))
          as SubscribeCalendarList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeCalendarList create() => SubscribeCalendarList._();
  @$core.override
  SubscribeCalendarList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubscribeCalendarList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscribeCalendarList>(create);
  static SubscribeCalendarList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Calendar> get calendars => $_getList(0);
}

class UserScheduleBrief_Brief extends $pb.GeneratedMessage {
  factory UserScheduleBrief_Brief({
    $fixnum.Int64? id,
    $fixnum.Int64? calendarId,
    $core.String? name,
    $fixnum.Int64? startTime,
    $fixnum.Int64? endTime,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (calendarId != null) result.calendarId = calendarId;
    if (name != null) result.name = name;
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    return result;
  }

  UserScheduleBrief_Brief._();

  factory UserScheduleBrief_Brief.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserScheduleBrief_Brief.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserScheduleBrief.Brief',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'calendarId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aInt64(4, _omitFieldNames ? '' : 'startTime')
    ..aInt64(5, _omitFieldNames ? '' : 'endTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserScheduleBrief_Brief clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserScheduleBrief_Brief copyWith(
          void Function(UserScheduleBrief_Brief) updates) =>
      super.copyWith((message) => updates(message as UserScheduleBrief_Brief))
          as UserScheduleBrief_Brief;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserScheduleBrief_Brief create() => UserScheduleBrief_Brief._();
  @$core.override
  UserScheduleBrief_Brief createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UserScheduleBrief_Brief getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserScheduleBrief_Brief>(create);
  static UserScheduleBrief_Brief? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get calendarId => $_getI64(1);
  @$pb.TagNumber(2)
  set calendarId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCalendarId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCalendarId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get startTime => $_getI64(3);
  @$pb.TagNumber(4)
  set startTime($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStartTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearStartTime() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get endTime => $_getI64(4);
  @$pb.TagNumber(5)
  set endTime($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEndTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearEndTime() => $_clearField(5);
}

class UserScheduleBrief extends $pb.GeneratedMessage {
  factory UserScheduleBrief({
    $core.Iterable<UserScheduleBrief_Brief>? briefs,
  }) {
    final result = create();
    if (briefs != null) result.briefs.addAll(briefs);
    return result;
  }

  UserScheduleBrief._();

  factory UserScheduleBrief.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserScheduleBrief.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserScheduleBrief',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..pPM<UserScheduleBrief_Brief>(1, _omitFieldNames ? '' : 'briefs',
        subBuilder: UserScheduleBrief_Brief.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserScheduleBrief clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserScheduleBrief copyWith(void Function(UserScheduleBrief) updates) =>
      super.copyWith((message) => updates(message as UserScheduleBrief))
          as UserScheduleBrief;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserScheduleBrief create() => UserScheduleBrief._();
  @$core.override
  UserScheduleBrief createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UserScheduleBrief getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserScheduleBrief>(create);
  static UserScheduleBrief? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<UserScheduleBrief_Brief> get briefs => $_getList(0);
}

class Schedule extends $pb.GeneratedMessage {
  factory Schedule({
    $fixnum.Int64? id,
    $fixnum.Int64? calendarId,
    $core.int? type,
    $fixnum.Int64? tenantId,
    $fixnum.Int64? owner,
    $fixnum.Int64? version,
    $fixnum.Int64? summaryDocId,
    $fixnum.Int64? roomId,
    $fixnum.Int64? chatId,
    $fixnum.Int64? cycleRuleId,
    $fixnum.Int64? startTime,
    $fixnum.Int64? endTime,
    $core.int? color,
    $core.int? publicPermision,
    $core.int? memberCount,
    $core.bool? memberViewList,
    $core.bool? memberInviteOther,
    $core.bool? memberAlterSchedule,
    $core.bool? memberCreateSummary,
    $core.bool? memberCreateMeeting,
    $core.bool? needCheckin,
    $core.bool? showAsIdle,
    $core.bool? exception,
    $core.bool? fullDay,
    $core.String? location,
    $core.String? archive,
    $core.String? desc,
    $core.String? title,
    $core.Iterable<$fixnum.Int64>? memberIds,
    $core.Iterable<$core.int>? notifyTime,
    ScheduleCycleRule? cycle,
    $core.int? modifyScope,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (calendarId != null) result.calendarId = calendarId;
    if (type != null) result.type = type;
    if (tenantId != null) result.tenantId = tenantId;
    if (owner != null) result.owner = owner;
    if (version != null) result.version = version;
    if (summaryDocId != null) result.summaryDocId = summaryDocId;
    if (roomId != null) result.roomId = roomId;
    if (chatId != null) result.chatId = chatId;
    if (cycleRuleId != null) result.cycleRuleId = cycleRuleId;
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    if (color != null) result.color = color;
    if (publicPermision != null) result.publicPermision = publicPermision;
    if (memberCount != null) result.memberCount = memberCount;
    if (memberViewList != null) result.memberViewList = memberViewList;
    if (memberInviteOther != null) result.memberInviteOther = memberInviteOther;
    if (memberAlterSchedule != null)
      result.memberAlterSchedule = memberAlterSchedule;
    if (memberCreateSummary != null)
      result.memberCreateSummary = memberCreateSummary;
    if (memberCreateMeeting != null)
      result.memberCreateMeeting = memberCreateMeeting;
    if (needCheckin != null) result.needCheckin = needCheckin;
    if (showAsIdle != null) result.showAsIdle = showAsIdle;
    if (exception != null) result.exception = exception;
    if (fullDay != null) result.fullDay = fullDay;
    if (location != null) result.location = location;
    if (archive != null) result.archive = archive;
    if (desc != null) result.desc = desc;
    if (title != null) result.title = title;
    if (memberIds != null) result.memberIds.addAll(memberIds);
    if (notifyTime != null) result.notifyTime.addAll(notifyTime);
    if (cycle != null) result.cycle = cycle;
    if (modifyScope != null) result.modifyScope = modifyScope;
    return result;
  }

  Schedule._();

  factory Schedule.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Schedule.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Schedule',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'calendarId')
    ..aI(3, _omitFieldNames ? '' : 'type')
    ..aInt64(4, _omitFieldNames ? '' : 'tenantId')
    ..aInt64(5, _omitFieldNames ? '' : 'owner')
    ..aInt64(6, _omitFieldNames ? '' : 'version')
    ..aInt64(7, _omitFieldNames ? '' : 'summaryDocId')
    ..aInt64(8, _omitFieldNames ? '' : 'roomId')
    ..aInt64(9, _omitFieldNames ? '' : 'chatId')
    ..aInt64(10, _omitFieldNames ? '' : 'cycleRuleId')
    ..aInt64(11, _omitFieldNames ? '' : 'startTime')
    ..aInt64(12, _omitFieldNames ? '' : 'endTime')
    ..aI(13, _omitFieldNames ? '' : 'color')
    ..aI(14, _omitFieldNames ? '' : 'publicPermision')
    ..aI(15, _omitFieldNames ? '' : 'memberCount')
    ..aOB(16, _omitFieldNames ? '' : 'memberViewList')
    ..aOB(17, _omitFieldNames ? '' : 'memberInviteOther')
    ..aOB(18, _omitFieldNames ? '' : 'memberAlterSchedule')
    ..aOB(19, _omitFieldNames ? '' : 'memberCreateSummary')
    ..aOB(20, _omitFieldNames ? '' : 'memberCreateMeeting')
    ..aOB(21, _omitFieldNames ? '' : 'needCheckin')
    ..aOB(22, _omitFieldNames ? '' : 'showAsIdle')
    ..aOB(23, _omitFieldNames ? '' : 'exception')
    ..aOB(24, _omitFieldNames ? '' : 'fullDay')
    ..aOS(25, _omitFieldNames ? '' : 'location')
    ..aOS(26, _omitFieldNames ? '' : 'archive')
    ..aOS(27, _omitFieldNames ? '' : 'desc')
    ..aOS(28, _omitFieldNames ? '' : 'title')
    ..p<$fixnum.Int64>(
        29, _omitFieldNames ? '' : 'memberIds', $pb.PbFieldType.K6)
    ..p<$core.int>(30, _omitFieldNames ? '' : 'notifyTime', $pb.PbFieldType.K3)
    ..aOM<ScheduleCycleRule>(31, _omitFieldNames ? '' : 'cycle',
        subBuilder: ScheduleCycleRule.create)
    ..aI(32, _omitFieldNames ? '' : 'modifyScope')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Schedule clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Schedule copyWith(void Function(Schedule) updates) =>
      super.copyWith((message) => updates(message as Schedule)) as Schedule;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Schedule create() => Schedule._();
  @$core.override
  Schedule createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Schedule getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Schedule>(create);
  static Schedule? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get calendarId => $_getI64(1);
  @$pb.TagNumber(2)
  set calendarId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCalendarId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCalendarId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get type => $_getIZ(2);
  @$pb.TagNumber(3)
  set type($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get tenantId => $_getI64(3);
  @$pb.TagNumber(4)
  set tenantId($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTenantId() => $_has(3);
  @$pb.TagNumber(4)
  void clearTenantId() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get owner => $_getI64(4);
  @$pb.TagNumber(5)
  set owner($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOwner() => $_has(4);
  @$pb.TagNumber(5)
  void clearOwner() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get version => $_getI64(5);
  @$pb.TagNumber(6)
  set version($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersion() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get summaryDocId => $_getI64(6);
  @$pb.TagNumber(7)
  set summaryDocId($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSummaryDocId() => $_has(6);
  @$pb.TagNumber(7)
  void clearSummaryDocId() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get roomId => $_getI64(7);
  @$pb.TagNumber(8)
  set roomId($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRoomId() => $_has(7);
  @$pb.TagNumber(8)
  void clearRoomId() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get chatId => $_getI64(8);
  @$pb.TagNumber(9)
  set chatId($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasChatId() => $_has(8);
  @$pb.TagNumber(9)
  void clearChatId() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get cycleRuleId => $_getI64(9);
  @$pb.TagNumber(10)
  set cycleRuleId($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCycleRuleId() => $_has(9);
  @$pb.TagNumber(10)
  void clearCycleRuleId() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get startTime => $_getI64(10);
  @$pb.TagNumber(11)
  set startTime($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasStartTime() => $_has(10);
  @$pb.TagNumber(11)
  void clearStartTime() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get endTime => $_getI64(11);
  @$pb.TagNumber(12)
  set endTime($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasEndTime() => $_has(11);
  @$pb.TagNumber(12)
  void clearEndTime() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get color => $_getIZ(12);
  @$pb.TagNumber(13)
  set color($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasColor() => $_has(12);
  @$pb.TagNumber(13)
  void clearColor() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get publicPermision => $_getIZ(13);
  @$pb.TagNumber(14)
  set publicPermision($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasPublicPermision() => $_has(13);
  @$pb.TagNumber(14)
  void clearPublicPermision() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.int get memberCount => $_getIZ(14);
  @$pb.TagNumber(15)
  set memberCount($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasMemberCount() => $_has(14);
  @$pb.TagNumber(15)
  void clearMemberCount() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.bool get memberViewList => $_getBF(15);
  @$pb.TagNumber(16)
  set memberViewList($core.bool value) => $_setBool(15, value);
  @$pb.TagNumber(16)
  $core.bool hasMemberViewList() => $_has(15);
  @$pb.TagNumber(16)
  void clearMemberViewList() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.bool get memberInviteOther => $_getBF(16);
  @$pb.TagNumber(17)
  set memberInviteOther($core.bool value) => $_setBool(16, value);
  @$pb.TagNumber(17)
  $core.bool hasMemberInviteOther() => $_has(16);
  @$pb.TagNumber(17)
  void clearMemberInviteOther() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.bool get memberAlterSchedule => $_getBF(17);
  @$pb.TagNumber(18)
  set memberAlterSchedule($core.bool value) => $_setBool(17, value);
  @$pb.TagNumber(18)
  $core.bool hasMemberAlterSchedule() => $_has(17);
  @$pb.TagNumber(18)
  void clearMemberAlterSchedule() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.bool get memberCreateSummary => $_getBF(18);
  @$pb.TagNumber(19)
  set memberCreateSummary($core.bool value) => $_setBool(18, value);
  @$pb.TagNumber(19)
  $core.bool hasMemberCreateSummary() => $_has(18);
  @$pb.TagNumber(19)
  void clearMemberCreateSummary() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.bool get memberCreateMeeting => $_getBF(19);
  @$pb.TagNumber(20)
  set memberCreateMeeting($core.bool value) => $_setBool(19, value);
  @$pb.TagNumber(20)
  $core.bool hasMemberCreateMeeting() => $_has(19);
  @$pb.TagNumber(20)
  void clearMemberCreateMeeting() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.bool get needCheckin => $_getBF(20);
  @$pb.TagNumber(21)
  set needCheckin($core.bool value) => $_setBool(20, value);
  @$pb.TagNumber(21)
  $core.bool hasNeedCheckin() => $_has(20);
  @$pb.TagNumber(21)
  void clearNeedCheckin() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.bool get showAsIdle => $_getBF(21);
  @$pb.TagNumber(22)
  set showAsIdle($core.bool value) => $_setBool(21, value);
  @$pb.TagNumber(22)
  $core.bool hasShowAsIdle() => $_has(21);
  @$pb.TagNumber(22)
  void clearShowAsIdle() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.bool get exception => $_getBF(22);
  @$pb.TagNumber(23)
  set exception($core.bool value) => $_setBool(22, value);
  @$pb.TagNumber(23)
  $core.bool hasException() => $_has(22);
  @$pb.TagNumber(23)
  void clearException() => $_clearField(23);

  @$pb.TagNumber(24)
  $core.bool get fullDay => $_getBF(23);
  @$pb.TagNumber(24)
  set fullDay($core.bool value) => $_setBool(23, value);
  @$pb.TagNumber(24)
  $core.bool hasFullDay() => $_has(23);
  @$pb.TagNumber(24)
  void clearFullDay() => $_clearField(24);

  @$pb.TagNumber(25)
  $core.String get location => $_getSZ(24);
  @$pb.TagNumber(25)
  set location($core.String value) => $_setString(24, value);
  @$pb.TagNumber(25)
  $core.bool hasLocation() => $_has(24);
  @$pb.TagNumber(25)
  void clearLocation() => $_clearField(25);

  @$pb.TagNumber(26)
  $core.String get archive => $_getSZ(25);
  @$pb.TagNumber(26)
  set archive($core.String value) => $_setString(25, value);
  @$pb.TagNumber(26)
  $core.bool hasArchive() => $_has(25);
  @$pb.TagNumber(26)
  void clearArchive() => $_clearField(26);

  @$pb.TagNumber(27)
  $core.String get desc => $_getSZ(26);
  @$pb.TagNumber(27)
  set desc($core.String value) => $_setString(26, value);
  @$pb.TagNumber(27)
  $core.bool hasDesc() => $_has(26);
  @$pb.TagNumber(27)
  void clearDesc() => $_clearField(27);

  @$pb.TagNumber(28)
  $core.String get title => $_getSZ(27);
  @$pb.TagNumber(28)
  set title($core.String value) => $_setString(27, value);
  @$pb.TagNumber(28)
  $core.bool hasTitle() => $_has(27);
  @$pb.TagNumber(28)
  void clearTitle() => $_clearField(28);

  @$pb.TagNumber(29)
  $pb.PbList<$fixnum.Int64> get memberIds => $_getList(28);

  @$pb.TagNumber(30)
  $pb.PbList<$core.int> get notifyTime => $_getList(29);

  @$pb.TagNumber(31)
  ScheduleCycleRule get cycle => $_getN(30);
  @$pb.TagNumber(31)
  set cycle(ScheduleCycleRule value) => $_setField(31, value);
  @$pb.TagNumber(31)
  $core.bool hasCycle() => $_has(30);
  @$pb.TagNumber(31)
  void clearCycle() => $_clearField(31);
  @$pb.TagNumber(31)
  ScheduleCycleRule ensureCycle() => $_ensure(30);

  @$pb.TagNumber(32)
  $core.int get modifyScope => $_getIZ(31);
  @$pb.TagNumber(32)
  set modifyScope($core.int value) => $_setSignedInt32(31, value);
  @$pb.TagNumber(32)
  $core.bool hasModifyScope() => $_has(31);
  @$pb.TagNumber(32)
  void clearModifyScope() => $_clearField(32);
}

/// by day => seq: 0, week_seqs: [0, 1, 2, 3, 4, ?5, ?6]
/// by week => seq: 0, week_seqs: [?0, ?1, ?2, ?3, ?4, ?5, ?6]
/// by month => seq: 0~30, week_seqs: []
/// by month week => seq: 0~5, week_seqs: [?0, ?1, ?2, ?3, ?4, ?5, ?6]
/// by year: => seq: 0~30
class CycleRule extends $pb.GeneratedMessage {
  factory CycleRule({
    $core.int? cycleType,
    $core.int? seq,
    $core.Iterable<$core.int>? weekSeqs,
  }) {
    final result = create();
    if (cycleType != null) result.cycleType = cycleType;
    if (seq != null) result.seq = seq;
    if (weekSeqs != null) result.weekSeqs.addAll(weekSeqs);
    return result;
  }

  CycleRule._();

  factory CycleRule.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CycleRule.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CycleRule',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'cycleType')
    ..aI(2, _omitFieldNames ? '' : 'seq')
    ..p<$core.int>(3, _omitFieldNames ? '' : 'weekSeqs', $pb.PbFieldType.K3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CycleRule clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CycleRule copyWith(void Function(CycleRule) updates) =>
      super.copyWith((message) => updates(message as CycleRule)) as CycleRule;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CycleRule create() => CycleRule._();
  @$core.override
  CycleRule createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CycleRule getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CycleRule>(create);
  static CycleRule? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get cycleType => $_getIZ(0);
  @$pb.TagNumber(1)
  set cycleType($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCycleType() => $_has(0);
  @$pb.TagNumber(1)
  void clearCycleType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get seq => $_getIZ(1);
  @$pb.TagNumber(2)
  set seq($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSeq() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeq() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.int> get weekSeqs => $_getList(2);
}

class ScheduleCycleRule extends $pb.GeneratedMessage {
  factory ScheduleCycleRule({
    $fixnum.Int64? id,
    $fixnum.Int64? calendarId,
    $fixnum.Int64? startAt,
    $fixnum.Int64? stopAt,
    CycleRule? rule,
    $core.Iterable<$fixnum.Int64>? exceptionTimes,
    $fixnum.Int64? version,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (calendarId != null) result.calendarId = calendarId;
    if (startAt != null) result.startAt = startAt;
    if (stopAt != null) result.stopAt = stopAt;
    if (rule != null) result.rule = rule;
    if (exceptionTimes != null) result.exceptionTimes.addAll(exceptionTimes);
    if (version != null) result.version = version;
    return result;
  }

  ScheduleCycleRule._();

  factory ScheduleCycleRule.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScheduleCycleRule.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScheduleCycleRule',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'entity'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'calendarId')
    ..aInt64(3, _omitFieldNames ? '' : 'startAt')
    ..aInt64(4, _omitFieldNames ? '' : 'stopAt')
    ..aOM<CycleRule>(5, _omitFieldNames ? '' : 'rule',
        subBuilder: CycleRule.create)
    ..p<$fixnum.Int64>(
        6, _omitFieldNames ? '' : 'exceptionTimes', $pb.PbFieldType.K6)
    ..aInt64(7, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleCycleRule clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleCycleRule copyWith(void Function(ScheduleCycleRule) updates) =>
      super.copyWith((message) => updates(message as ScheduleCycleRule))
          as ScheduleCycleRule;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScheduleCycleRule create() => ScheduleCycleRule._();
  @$core.override
  ScheduleCycleRule createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScheduleCycleRule getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScheduleCycleRule>(create);
  static ScheduleCycleRule? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get calendarId => $_getI64(1);
  @$pb.TagNumber(2)
  set calendarId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCalendarId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCalendarId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get startAt => $_getI64(2);
  @$pb.TagNumber(3)
  set startAt($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStartAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearStartAt() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get stopAt => $_getI64(3);
  @$pb.TagNumber(4)
  set stopAt($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStopAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearStopAt() => $_clearField(4);

  @$pb.TagNumber(5)
  CycleRule get rule => $_getN(4);
  @$pb.TagNumber(5)
  set rule(CycleRule value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasRule() => $_has(4);
  @$pb.TagNumber(5)
  void clearRule() => $_clearField(5);
  @$pb.TagNumber(5)
  CycleRule ensureRule() => $_ensure(4);

  @$pb.TagNumber(6)
  $pb.PbList<$fixnum.Int64> get exceptionTimes => $_getList(5);

  @$pb.TagNumber(7)
  $fixnum.Int64 get version => $_getI64(6);
  @$pb.TagNumber(7)
  set version($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasVersion() => $_has(6);
  @$pb.TagNumber(7)
  void clearVersion() => $_clearField(7);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
