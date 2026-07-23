// This is a generated file - do not edit.
//
// Generated from typing.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class TypingRequest extends $pb.GeneratedMessage {
  factory TypingRequest({
    $fixnum.Int64? chatId,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    return result;
  }

  TypingRequest._();

  factory TypingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TypingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TypingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'typing'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TypingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TypingRequest copyWith(void Function(TypingRequest) updates) =>
      super.copyWith((message) => updates(message as TypingRequest))
          as TypingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TypingRequest create() => TypingRequest._();
  @$core.override
  TypingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TypingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TypingRequest>(create);
  static TypingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);
}

class TypingResponse extends $pb.GeneratedMessage {
  factory TypingResponse() => create();

  TypingResponse._();

  factory TypingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TypingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TypingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'typing'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TypingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TypingResponse copyWith(void Function(TypingResponse) updates) =>
      super.copyWith((message) => updates(message as TypingResponse))
          as TypingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TypingResponse create() => TypingResponse._();
  @$core.override
  TypingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TypingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TypingResponse>(create);
  static TypingResponse? _defaultInstance;
}

class PushTyping extends $pb.GeneratedMessage {
  factory PushTyping({
    $fixnum.Int64? chatId,
    $fixnum.Int64? userId,
    $core.String? userName,
    $fixnum.Int64? expireAtMs,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (userId != null) result.userId = userId;
    if (userName != null) result.userName = userName;
    if (expireAtMs != null) result.expireAtMs = expireAtMs;
    return result;
  }

  PushTyping._();

  factory PushTyping.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushTyping.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushTyping',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'typing'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'userName')
    ..aInt64(4, _omitFieldNames ? '' : 'expireAtMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushTyping clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushTyping copyWith(void Function(PushTyping) updates) =>
      super.copyWith((message) => updates(message as PushTyping)) as PushTyping;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushTyping create() => PushTyping._();
  @$core.override
  PushTyping createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushTyping getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushTyping>(create);
  static PushTyping? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get userName => $_getSZ(2);
  @$pb.TagNumber(3)
  set userName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserName() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserName() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get expireAtMs => $_getI64(3);
  @$pb.TagNumber(4)
  set expireAtMs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpireAtMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpireAtMs() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
