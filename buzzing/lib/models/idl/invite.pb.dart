// This is a generated file - do not edit.
//
// Generated from invite.proto.

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

class InviteLink extends $pb.GeneratedMessage {
  factory InviteLink({
    $fixnum.Int64? id,
    $fixnum.Int64? chatId,
    $core.String? chatName,
    $core.String? code,
    $fixnum.Int64? createdBy,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? expiresAt,
    $core.int? maxUses,
    $core.int? useCount,
    $core.bool? isActive,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (chatId != null) result.chatId = chatId;
    if (chatName != null) result.chatName = chatName;
    if (code != null) result.code = code;
    if (createdBy != null) result.createdBy = createdBy;
    if (createdAt != null) result.createdAt = createdAt;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (maxUses != null) result.maxUses = maxUses;
    if (useCount != null) result.useCount = useCount;
    if (isActive != null) result.isActive = isActive;
    return result;
  }

  InviteLink._();

  factory InviteLink.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InviteLink.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InviteLink',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'invite'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'chatId')
    ..aOS(3, _omitFieldNames ? '' : 'chatName')
    ..aOS(4, _omitFieldNames ? '' : 'code')
    ..aInt64(5, _omitFieldNames ? '' : 'createdBy')
    ..aInt64(6, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(7, _omitFieldNames ? '' : 'expiresAt')
    ..aI(8, _omitFieldNames ? '' : 'maxUses')
    ..aI(9, _omitFieldNames ? '' : 'useCount')
    ..aOB(10, _omitFieldNames ? '' : 'isActive')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteLink clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteLink copyWith(void Function(InviteLink) updates) =>
      super.copyWith((message) => updates(message as InviteLink)) as InviteLink;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InviteLink create() => InviteLink._();
  @$core.override
  InviteLink createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InviteLink getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InviteLink>(create);
  static InviteLink? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

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
  $core.String get code => $_getSZ(3);
  @$pb.TagNumber(4)
  set code($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearCode() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get createdBy => $_getI64(4);
  @$pb.TagNumber(5)
  set createdBy($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatedBy() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedBy() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get createdAt => $_getI64(5);
  @$pb.TagNumber(6)
  set createdAt($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get expiresAt => $_getI64(6);
  @$pb.TagNumber(7)
  set expiresAt($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasExpiresAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearExpiresAt() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get maxUses => $_getIZ(7);
  @$pb.TagNumber(8)
  set maxUses($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMaxUses() => $_has(7);
  @$pb.TagNumber(8)
  void clearMaxUses() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get useCount => $_getIZ(8);
  @$pb.TagNumber(9)
  set useCount($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasUseCount() => $_has(8);
  @$pb.TagNumber(9)
  void clearUseCount() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isActive => $_getBF(9);
  @$pb.TagNumber(10)
  set isActive($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasIsActive() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsActive() => $_clearField(10);
}

class InviteLinkCreateRequest extends $pb.GeneratedMessage {
  factory InviteLinkCreateRequest({
    $fixnum.Int64? chatId,
    $fixnum.Int64? expiresAt,
    $core.int? maxUses,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (maxUses != null) result.maxUses = maxUses;
    return result;
  }

  InviteLinkCreateRequest._();

  factory InviteLinkCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InviteLinkCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InviteLinkCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'invite'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..aInt64(2, _omitFieldNames ? '' : 'expiresAt')
    ..aI(3, _omitFieldNames ? '' : 'maxUses')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteLinkCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteLinkCreateRequest copyWith(
          void Function(InviteLinkCreateRequest) updates) =>
      super.copyWith((message) => updates(message as InviteLinkCreateRequest))
          as InviteLinkCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InviteLinkCreateRequest create() => InviteLinkCreateRequest._();
  @$core.override
  InviteLinkCreateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InviteLinkCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InviteLinkCreateRequest>(create);
  static InviteLinkCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expiresAt => $_getI64(1);
  @$pb.TagNumber(2)
  set expiresAt($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpiresAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpiresAt() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get maxUses => $_getIZ(2);
  @$pb.TagNumber(3)
  set maxUses($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxUses() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxUses() => $_clearField(3);
}

class InviteLinkCreateResponse extends $pb.GeneratedMessage {
  factory InviteLinkCreateResponse({
    $core.String? code,
    $core.String? url,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (url != null) result.url = url;
    return result;
  }

  InviteLinkCreateResponse._();

  factory InviteLinkCreateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InviteLinkCreateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InviteLinkCreateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'invite'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteLinkCreateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteLinkCreateResponse copyWith(
          void Function(InviteLinkCreateResponse) updates) =>
      super.copyWith((message) => updates(message as InviteLinkCreateResponse))
          as InviteLinkCreateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InviteLinkCreateResponse create() => InviteLinkCreateResponse._();
  @$core.override
  InviteLinkCreateResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InviteLinkCreateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InviteLinkCreateResponse>(create);
  static InviteLinkCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);
}

class InviteLinkJoinRequest extends $pb.GeneratedMessage {
  factory InviteLinkJoinRequest({
    $core.String? code,
  }) {
    final result = create();
    if (code != null) result.code = code;
    return result;
  }

  InviteLinkJoinRequest._();

  factory InviteLinkJoinRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InviteLinkJoinRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InviteLinkJoinRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'invite'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteLinkJoinRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteLinkJoinRequest copyWith(
          void Function(InviteLinkJoinRequest) updates) =>
      super.copyWith((message) => updates(message as InviteLinkJoinRequest))
          as InviteLinkJoinRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InviteLinkJoinRequest create() => InviteLinkJoinRequest._();
  @$core.override
  InviteLinkJoinRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InviteLinkJoinRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InviteLinkJoinRequest>(create);
  static InviteLinkJoinRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);
}

class InviteLinkJoinResponse extends $pb.GeneratedMessage {
  factory InviteLinkJoinResponse({
    $fixnum.Int64? chatId,
    $0.Chat? chat,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (chat != null) result.chat = chat;
    return result;
  }

  InviteLinkJoinResponse._();

  factory InviteLinkJoinResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InviteLinkJoinResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InviteLinkJoinResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'invite'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..aOM<$0.Chat>(2, _omitFieldNames ? '' : 'chat', subBuilder: $0.Chat.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteLinkJoinResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteLinkJoinResponse copyWith(
          void Function(InviteLinkJoinResponse) updates) =>
      super.copyWith((message) => updates(message as InviteLinkJoinResponse))
          as InviteLinkJoinResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InviteLinkJoinResponse create() => InviteLinkJoinResponse._();
  @$core.override
  InviteLinkJoinResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InviteLinkJoinResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InviteLinkJoinResponse>(create);
  static InviteLinkJoinResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Chat get chat => $_getN(1);
  @$pb.TagNumber(2)
  set chat($0.Chat value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasChat() => $_has(1);
  @$pb.TagNumber(2)
  void clearChat() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Chat ensureChat() => $_ensure(1);
}

class InviteLinkRevokeRequest extends $pb.GeneratedMessage {
  factory InviteLinkRevokeRequest({
    $core.String? code,
  }) {
    final result = create();
    if (code != null) result.code = code;
    return result;
  }

  InviteLinkRevokeRequest._();

  factory InviteLinkRevokeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InviteLinkRevokeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InviteLinkRevokeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'invite'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteLinkRevokeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteLinkRevokeRequest copyWith(
          void Function(InviteLinkRevokeRequest) updates) =>
      super.copyWith((message) => updates(message as InviteLinkRevokeRequest))
          as InviteLinkRevokeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InviteLinkRevokeRequest create() => InviteLinkRevokeRequest._();
  @$core.override
  InviteLinkRevokeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InviteLinkRevokeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InviteLinkRevokeRequest>(create);
  static InviteLinkRevokeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);
}

class InviteLinkRevokeResponse extends $pb.GeneratedMessage {
  factory InviteLinkRevokeResponse() => create();

  InviteLinkRevokeResponse._();

  factory InviteLinkRevokeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InviteLinkRevokeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InviteLinkRevokeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'invite'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteLinkRevokeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteLinkRevokeResponse copyWith(
          void Function(InviteLinkRevokeResponse) updates) =>
      super.copyWith((message) => updates(message as InviteLinkRevokeResponse))
          as InviteLinkRevokeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InviteLinkRevokeResponse create() => InviteLinkRevokeResponse._();
  @$core.override
  InviteLinkRevokeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InviteLinkRevokeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InviteLinkRevokeResponse>(create);
  static InviteLinkRevokeResponse? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
