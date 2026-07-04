// This is a generated file - do not edit.
//
// Generated from chat.proto.

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

class CreateChatRequest extends $pb.GeneratedMessage {
  factory CreateChatRequest({
    $0.Chat? chat,
  }) {
    final result = create();
    if (chat != null) result.chat = chat;
    return result;
  }

  CreateChatRequest._();

  factory CreateChatRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateChatRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateChatRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOM<$0.Chat>(1, _omitFieldNames ? '' : 'chat', subBuilder: $0.Chat.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateChatRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateChatRequest copyWith(void Function(CreateChatRequest) updates) =>
      super.copyWith((message) => updates(message as CreateChatRequest))
          as CreateChatRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateChatRequest create() => CreateChatRequest._();
  @$core.override
  CreateChatRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateChatRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateChatRequest>(create);
  static CreateChatRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Chat get chat => $_getN(0);
  @$pb.TagNumber(1)
  set chat($0.Chat value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasChat() => $_has(0);
  @$pb.TagNumber(1)
  void clearChat() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Chat ensureChat() => $_ensure(0);
}

class CreateChatResponse extends $pb.GeneratedMessage {
  factory CreateChatResponse({
    $fixnum.Int64? chatId,
    $0.Entity? entities,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (entities != null) result.entities = entities;
    return result;
  }

  CreateChatResponse._();

  factory CreateChatResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateChatResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateChatResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..aOM<$0.Entity>(2, _omitFieldNames ? '' : 'entities',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateChatResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateChatResponse copyWith(void Function(CreateChatResponse) updates) =>
      super.copyWith((message) => updates(message as CreateChatResponse))
          as CreateChatResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateChatResponse create() => CreateChatResponse._();
  @$core.override
  CreateChatResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateChatResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateChatResponse>(create);
  static CreateChatResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Entity get entities => $_getN(1);
  @$pb.TagNumber(2)
  set entities($0.Entity value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEntities() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntities() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Entity ensureEntities() => $_ensure(1);
}

class GetChatByIdsRequest extends $pb.GeneratedMessage {
  factory GetChatByIdsRequest({
    $core.Iterable<$fixnum.Int64>? ids,
  }) {
    final result = create();
    if (ids != null) result.ids.addAll(ids);
    return result;
  }

  GetChatByIdsRequest._();

  factory GetChatByIdsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetChatByIdsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetChatByIdsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..p<$fixnum.Int64>(1, _omitFieldNames ? '' : 'ids', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChatByIdsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChatByIdsRequest copyWith(void Function(GetChatByIdsRequest) updates) =>
      super.copyWith((message) => updates(message as GetChatByIdsRequest))
          as GetChatByIdsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChatByIdsRequest create() => GetChatByIdsRequest._();
  @$core.override
  GetChatByIdsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetChatByIdsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetChatByIdsRequest>(create);
  static GetChatByIdsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$fixnum.Int64> get ids => $_getList(0);
}

class GetChatByIdsResponse extends $pb.GeneratedMessage {
  factory GetChatByIdsResponse({
    $0.Entity? entities,
  }) {
    final result = create();
    if (entities != null) result.entities = entities;
    return result;
  }

  GetChatByIdsResponse._();

  factory GetChatByIdsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetChatByIdsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetChatByIdsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOM<$0.Entity>(1, _omitFieldNames ? '' : 'entities',
        subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChatByIdsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChatByIdsResponse copyWith(void Function(GetChatByIdsResponse) updates) =>
      super.copyWith((message) => updates(message as GetChatByIdsResponse))
          as GetChatByIdsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChatByIdsResponse create() => GetChatByIdsResponse._();
  @$core.override
  GetChatByIdsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetChatByIdsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetChatByIdsResponse>(create);
  static GetChatByIdsResponse? _defaultInstance;

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

class SetChatDraftRequest extends $pb.GeneratedMessage {
  factory SetChatDraftRequest({
    $fixnum.Int64? chatId,
    $core.List<$core.int>? content,
    $fixnum.Int64? timeMs,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (content != null) result.content = content;
    if (timeMs != null) result.timeMs = timeMs;
    return result;
  }

  SetChatDraftRequest._();

  factory SetChatDraftRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetChatDraftRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetChatDraftRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aInt64(3, _omitFieldNames ? '' : 'timeMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetChatDraftRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetChatDraftRequest copyWith(void Function(SetChatDraftRequest) updates) =>
      super.copyWith((message) => updates(message as SetChatDraftRequest))
          as SetChatDraftRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetChatDraftRequest create() => SetChatDraftRequest._();
  @$core.override
  SetChatDraftRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetChatDraftRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetChatDraftRequest>(create);
  static SetChatDraftRequest? _defaultInstance;

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
  $fixnum.Int64 get timeMs => $_getI64(2);
  @$pb.TagNumber(3)
  set timeMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimeMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimeMs() => $_clearField(3);
}

class SetChatDraftResponse extends $pb.GeneratedMessage {
  factory SetChatDraftResponse() => create();

  SetChatDraftResponse._();

  factory SetChatDraftResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetChatDraftResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetChatDraftResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetChatDraftResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetChatDraftResponse copyWith(void Function(SetChatDraftResponse) updates) =>
      super.copyWith((message) => updates(message as SetChatDraftResponse))
          as SetChatDraftResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetChatDraftResponse create() => SetChatDraftResponse._();
  @$core.override
  SetChatDraftResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetChatDraftResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetChatDraftResponse>(create);
  static SetChatDraftResponse? _defaultInstance;
}

class GetChatDraftRequest extends $pb.GeneratedMessage {
  factory GetChatDraftRequest({
    $fixnum.Int64? chatId,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    return result;
  }

  GetChatDraftRequest._();

  factory GetChatDraftRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetChatDraftRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetChatDraftRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChatDraftRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChatDraftRequest copyWith(void Function(GetChatDraftRequest) updates) =>
      super.copyWith((message) => updates(message as GetChatDraftRequest))
          as GetChatDraftRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChatDraftRequest create() => GetChatDraftRequest._();
  @$core.override
  GetChatDraftRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetChatDraftRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetChatDraftRequest>(create);
  static GetChatDraftRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);
}

class GetChatDraftResponse extends $pb.GeneratedMessage {
  factory GetChatDraftResponse({
    $fixnum.Int64? chatId,
    $core.List<$core.int>? content,
    $fixnum.Int64? timeMs,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (content != null) result.content = content;
    if (timeMs != null) result.timeMs = timeMs;
    return result;
  }

  GetChatDraftResponse._();

  factory GetChatDraftResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetChatDraftResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetChatDraftResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aInt64(3, _omitFieldNames ? '' : 'timeMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChatDraftResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChatDraftResponse copyWith(void Function(GetChatDraftResponse) updates) =>
      super.copyWith((message) => updates(message as GetChatDraftResponse))
          as GetChatDraftResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChatDraftResponse create() => GetChatDraftResponse._();
  @$core.override
  GetChatDraftResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetChatDraftResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetChatDraftResponse>(create);
  static GetChatDraftResponse? _defaultInstance;

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
  $fixnum.Int64 get timeMs => $_getI64(2);
  @$pb.TagNumber(3)
  set timeMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimeMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimeMs() => $_clearField(3);
}

class DismissChatRequest extends $pb.GeneratedMessage {
  factory DismissChatRequest({
    $fixnum.Int64? chatId,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    return result;
  }

  DismissChatRequest._();

  factory DismissChatRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DismissChatRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DismissChatRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DismissChatRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DismissChatRequest copyWith(void Function(DismissChatRequest) updates) =>
      super.copyWith((message) => updates(message as DismissChatRequest))
          as DismissChatRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DismissChatRequest create() => DismissChatRequest._();
  @$core.override
  DismissChatRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DismissChatRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DismissChatRequest>(create);
  static DismissChatRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);
}

class DismissChatResponse extends $pb.GeneratedMessage {
  factory DismissChatResponse() => create();

  DismissChatResponse._();

  factory DismissChatResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DismissChatResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DismissChatResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DismissChatResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DismissChatResponse copyWith(void Function(DismissChatResponse) updates) =>
      super.copyWith((message) => updates(message as DismissChatResponse))
          as DismissChatResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DismissChatResponse create() => DismissChatResponse._();
  @$core.override
  DismissChatResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DismissChatResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DismissChatResponse>(create);
  static DismissChatResponse? _defaultInstance;
}

class UpdateChatRequest extends $pb.GeneratedMessage {
  factory UpdateChatRequest({
    $0.Chat? chat,
  }) {
    final result = create();
    if (chat != null) result.chat = chat;
    return result;
  }

  UpdateChatRequest._();

  factory UpdateChatRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateChatRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateChatRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOM<$0.Chat>(1, _omitFieldNames ? '' : 'chat', subBuilder: $0.Chat.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateChatRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateChatRequest copyWith(void Function(UpdateChatRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateChatRequest))
          as UpdateChatRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateChatRequest create() => UpdateChatRequest._();
  @$core.override
  UpdateChatRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateChatRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateChatRequest>(create);
  static UpdateChatRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Chat get chat => $_getN(0);
  @$pb.TagNumber(1)
  set chat($0.Chat value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasChat() => $_has(0);
  @$pb.TagNumber(1)
  void clearChat() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Chat ensureChat() => $_ensure(0);
}

class UpdateChatResponse extends $pb.GeneratedMessage {
  factory UpdateChatResponse() => create();

  UpdateChatResponse._();

  factory UpdateChatResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateChatResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateChatResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateChatResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateChatResponse copyWith(void Function(UpdateChatResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateChatResponse))
          as UpdateChatResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateChatResponse create() => UpdateChatResponse._();
  @$core.override
  UpdateChatResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateChatResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateChatResponse>(create);
  static UpdateChatResponse? _defaultInstance;
}

class AddChatChatterRequest extends $pb.GeneratedMessage {
  factory AddChatChatterRequest({
    $fixnum.Int64? chatId,
    $core.Iterable<$fixnum.Int64>? ids,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (ids != null) result.ids.addAll(ids);
    return result;
  }

  AddChatChatterRequest._();

  factory AddChatChatterRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddChatChatterRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddChatChatterRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..p<$fixnum.Int64>(2, _omitFieldNames ? '' : 'ids', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddChatChatterRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddChatChatterRequest copyWith(
          void Function(AddChatChatterRequest) updates) =>
      super.copyWith((message) => updates(message as AddChatChatterRequest))
          as AddChatChatterRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddChatChatterRequest create() => AddChatChatterRequest._();
  @$core.override
  AddChatChatterRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddChatChatterRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddChatChatterRequest>(create);
  static AddChatChatterRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$fixnum.Int64> get ids => $_getList(1);
}

class AddChatChatterResponse extends $pb.GeneratedMessage {
  factory AddChatChatterResponse() => create();

  AddChatChatterResponse._();

  factory AddChatChatterResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddChatChatterResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddChatChatterResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddChatChatterResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddChatChatterResponse copyWith(
          void Function(AddChatChatterResponse) updates) =>
      super.copyWith((message) => updates(message as AddChatChatterResponse))
          as AddChatChatterResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddChatChatterResponse create() => AddChatChatterResponse._();
  @$core.override
  AddChatChatterResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddChatChatterResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddChatChatterResponse>(create);
  static AddChatChatterResponse? _defaultInstance;
}

class RemoveChatChatterRequest extends $pb.GeneratedMessage {
  factory RemoveChatChatterRequest({
    $fixnum.Int64? chatId,
    $core.Iterable<$fixnum.Int64>? ids,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (ids != null) result.ids.addAll(ids);
    return result;
  }

  RemoveChatChatterRequest._();

  factory RemoveChatChatterRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveChatChatterRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveChatChatterRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..p<$fixnum.Int64>(2, _omitFieldNames ? '' : 'ids', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveChatChatterRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveChatChatterRequest copyWith(
          void Function(RemoveChatChatterRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveChatChatterRequest))
          as RemoveChatChatterRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveChatChatterRequest create() => RemoveChatChatterRequest._();
  @$core.override
  RemoveChatChatterRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveChatChatterRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveChatChatterRequest>(create);
  static RemoveChatChatterRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$fixnum.Int64> get ids => $_getList(1);
}

class RemoveChatChatterResponse extends $pb.GeneratedMessage {
  factory RemoveChatChatterResponse() => create();

  RemoveChatChatterResponse._();

  factory RemoveChatChatterResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveChatChatterResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveChatChatterResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveChatChatterResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveChatChatterResponse copyWith(
          void Function(RemoveChatChatterResponse) updates) =>
      super.copyWith((message) => updates(message as RemoveChatChatterResponse))
          as RemoveChatChatterResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveChatChatterResponse create() => RemoveChatChatterResponse._();
  @$core.override
  RemoveChatChatterResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveChatChatterResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveChatChatterResponse>(create);
  static RemoveChatChatterResponse? _defaultInstance;
}

class ReadChatMessageRequest extends $pb.GeneratedMessage {
  factory ReadChatMessageRequest({
    $fixnum.Int64? chatId,
    $core.int? pos,
    $core.Iterable<$fixnum.Int64>? messageIds,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (pos != null) result.pos = pos;
    if (messageIds != null) result.messageIds.addAll(messageIds);
    return result;
  }

  ReadChatMessageRequest._();

  factory ReadChatMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReadChatMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReadChatMessageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..aI(2, _omitFieldNames ? '' : 'pos')
    ..p<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'messageIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadChatMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadChatMessageRequest copyWith(
          void Function(ReadChatMessageRequest) updates) =>
      super.copyWith((message) => updates(message as ReadChatMessageRequest))
          as ReadChatMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReadChatMessageRequest create() => ReadChatMessageRequest._();
  @$core.override
  ReadChatMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReadChatMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReadChatMessageRequest>(create);
  static ReadChatMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get pos => $_getIZ(1);
  @$pb.TagNumber(2)
  set pos($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPos() => $_has(1);
  @$pb.TagNumber(2)
  void clearPos() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$fixnum.Int64> get messageIds => $_getList(2);
}

class ReadChatMessageResponse extends $pb.GeneratedMessage {
  factory ReadChatMessageResponse() => create();

  ReadChatMessageResponse._();

  factory ReadChatMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReadChatMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReadChatMessageResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadChatMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadChatMessageResponse copyWith(
          void Function(ReadChatMessageResponse) updates) =>
      super.copyWith((message) => updates(message as ReadChatMessageResponse))
          as ReadChatMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReadChatMessageResponse create() => ReadChatMessageResponse._();
  @$core.override
  ReadChatMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReadChatMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReadChatMessageResponse>(create);
  static ReadChatMessageResponse? _defaultInstance;
}

class QuitChatRequest extends $pb.GeneratedMessage {
  factory QuitChatRequest({
    $fixnum.Int64? chatId,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    return result;
  }

  QuitChatRequest._();

  factory QuitChatRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QuitChatRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QuitChatRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuitChatRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuitChatRequest copyWith(void Function(QuitChatRequest) updates) =>
      super.copyWith((message) => updates(message as QuitChatRequest))
          as QuitChatRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QuitChatRequest create() => QuitChatRequest._();
  @$core.override
  QuitChatRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static QuitChatRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QuitChatRequest>(create);
  static QuitChatRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);
}

class QuitChatResponse extends $pb.GeneratedMessage {
  factory QuitChatResponse() => create();

  QuitChatResponse._();

  factory QuitChatResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QuitChatResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QuitChatResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuitChatResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuitChatResponse copyWith(void Function(QuitChatResponse) updates) =>
      super.copyWith((message) => updates(message as QuitChatResponse))
          as QuitChatResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QuitChatResponse create() => QuitChatResponse._();
  @$core.override
  QuitChatResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static QuitChatResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QuitChatResponse>(create);
  static QuitChatResponse? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
