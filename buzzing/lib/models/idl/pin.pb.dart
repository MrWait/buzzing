// This is a generated file - do not edit.
//
// Generated from pin.proto.

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

class PinMessageRequest extends $pb.GeneratedMessage {
  factory PinMessageRequest({
    $fixnum.Int64? chatId,
    $fixnum.Int64? messageId,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (messageId != null) result.messageId = messageId;
    return result;
  }

  PinMessageRequest._();

  factory PinMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PinMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PinMessageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pin'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..aInt64(2, _omitFieldNames ? '' : 'messageId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PinMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PinMessageRequest copyWith(void Function(PinMessageRequest) updates) =>
      super.copyWith((message) => updates(message as PinMessageRequest))
          as PinMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PinMessageRequest create() => PinMessageRequest._();
  @$core.override
  PinMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PinMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PinMessageRequest>(create);
  static PinMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get messageId => $_getI64(1);
  @$pb.TagNumber(2)
  set messageId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageId() => $_clearField(2);
}

class PinMessageResponse extends $pb.GeneratedMessage {
  factory PinMessageResponse({
    $0.Entity? entities,
  }) {
    final result = create();
    if (entities != null) result.entities = entities;
    return result;
  }

  PinMessageResponse._();

  factory PinMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PinMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PinMessageResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pin'),
      createEmptyInstance: create)
    ..aOM<$0.Entity>(1, _omitFieldNames ? '' : 'entities',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PinMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PinMessageResponse copyWith(void Function(PinMessageResponse) updates) =>
      super.copyWith((message) => updates(message as PinMessageResponse))
          as PinMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PinMessageResponse create() => PinMessageResponse._();
  @$core.override
  PinMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PinMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PinMessageResponse>(create);
  static PinMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Entity get entities => $_getN(0);
  @$pb.TagNumber(1)
  set entities($0.Entity value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEntities() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntities() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Entity ensureEntities() => $_ensure(0);
}

class UnpinMessageRequest extends $pb.GeneratedMessage {
  factory UnpinMessageRequest({
    $fixnum.Int64? chatId,
    $fixnum.Int64? messageId,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (messageId != null) result.messageId = messageId;
    return result;
  }

  UnpinMessageRequest._();

  factory UnpinMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnpinMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnpinMessageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pin'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..aInt64(2, _omitFieldNames ? '' : 'messageId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnpinMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnpinMessageRequest copyWith(void Function(UnpinMessageRequest) updates) =>
      super.copyWith((message) => updates(message as UnpinMessageRequest))
          as UnpinMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnpinMessageRequest create() => UnpinMessageRequest._();
  @$core.override
  UnpinMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnpinMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnpinMessageRequest>(create);
  static UnpinMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get messageId => $_getI64(1);
  @$pb.TagNumber(2)
  set messageId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageId() => $_clearField(2);
}

class UnpinMessageResponse extends $pb.GeneratedMessage {
  factory UnpinMessageResponse({
    $0.Entity? entities,
  }) {
    final result = create();
    if (entities != null) result.entities = entities;
    return result;
  }

  UnpinMessageResponse._();

  factory UnpinMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnpinMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnpinMessageResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pin'),
      createEmptyInstance: create)
    ..aOM<$0.Entity>(1, _omitFieldNames ? '' : 'entities',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnpinMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnpinMessageResponse copyWith(void Function(UnpinMessageResponse) updates) =>
      super.copyWith((message) => updates(message as UnpinMessageResponse))
          as UnpinMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnpinMessageResponse create() => UnpinMessageResponse._();
  @$core.override
  UnpinMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnpinMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnpinMessageResponse>(create);
  static UnpinMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Entity get entities => $_getN(0);
  @$pb.TagNumber(1)
  set entities($0.Entity value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEntities() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntities() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Entity ensureEntities() => $_ensure(0);
}

class GetPinnedMessagesRequest extends $pb.GeneratedMessage {
  factory GetPinnedMessagesRequest({
    $fixnum.Int64? chatId,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    return result;
  }

  GetPinnedMessagesRequest._();

  factory GetPinnedMessagesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPinnedMessagesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPinnedMessagesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pin'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPinnedMessagesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPinnedMessagesRequest copyWith(
          void Function(GetPinnedMessagesRequest) updates) =>
      super.copyWith((message) => updates(message as GetPinnedMessagesRequest))
          as GetPinnedMessagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPinnedMessagesRequest create() => GetPinnedMessagesRequest._();
  @$core.override
  GetPinnedMessagesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPinnedMessagesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPinnedMessagesRequest>(create);
  static GetPinnedMessagesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);
}

class GetPinnedMessagesResponse extends $pb.GeneratedMessage {
  factory GetPinnedMessagesResponse({
    $core.Iterable<$0.Message>? messages,
  }) {
    final result = create();
    if (messages != null) result.messages.addAll(messages);
    return result;
  }

  GetPinnedMessagesResponse._();

  factory GetPinnedMessagesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPinnedMessagesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPinnedMessagesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pin'),
      createEmptyInstance: create)
    ..pPM<$0.Message>(1, _omitFieldNames ? '' : 'messages',
        subBuilder: $0.Message.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPinnedMessagesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPinnedMessagesResponse copyWith(
          void Function(GetPinnedMessagesResponse) updates) =>
      super.copyWith((message) => updates(message as GetPinnedMessagesResponse))
          as GetPinnedMessagesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPinnedMessagesResponse create() => GetPinnedMessagesResponse._();
  @$core.override
  GetPinnedMessagesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPinnedMessagesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPinnedMessagesResponse>(create);
  static GetPinnedMessagesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.Message> get messages => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
