// This is a generated file - do not edit.
//
// Generated from translate.proto.

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

class TranslateMessageRequest extends $pb.GeneratedMessage {
  factory TranslateMessageRequest({
    $fixnum.Int64? messageId,
    $fixnum.Int64? chatId,
    $core.String? targetLang,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (chatId != null) result.chatId = chatId;
    if (targetLang != null) result.targetLang = targetLang;
    return result;
  }

  TranslateMessageRequest._();

  factory TranslateMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TranslateMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TranslateMessageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'translate'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'messageId')
    ..aInt64(2, _omitFieldNames ? '' : 'chatId')
    ..aOS(3, _omitFieldNames ? '' : 'targetLang')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TranslateMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TranslateMessageRequest copyWith(
          void Function(TranslateMessageRequest) updates) =>
      super.copyWith((message) => updates(message as TranslateMessageRequest))
          as TranslateMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TranslateMessageRequest create() => TranslateMessageRequest._();
  @$core.override
  TranslateMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TranslateMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TranslateMessageRequest>(create);
  static TranslateMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1)
  set messageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get chatId => $_getI64(1);
  @$pb.TagNumber(2)
  set chatId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChatId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChatId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get targetLang => $_getSZ(2);
  @$pb.TagNumber(3)
  set targetLang($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTargetLang() => $_has(2);
  @$pb.TagNumber(3)
  void clearTargetLang() => $_clearField(3);
}

class TranslateMessageResponse extends $pb.GeneratedMessage {
  factory TranslateMessageResponse({
    $fixnum.Int64? messageId,
    $core.String? originalText,
    $core.String? translatedText,
    $core.String? targetLang,
    $core.String? sourceLang,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (originalText != null) result.originalText = originalText;
    if (translatedText != null) result.translatedText = translatedText;
    if (targetLang != null) result.targetLang = targetLang;
    if (sourceLang != null) result.sourceLang = sourceLang;
    return result;
  }

  TranslateMessageResponse._();

  factory TranslateMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TranslateMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TranslateMessageResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'translate'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'messageId')
    ..aOS(2, _omitFieldNames ? '' : 'originalText')
    ..aOS(3, _omitFieldNames ? '' : 'translatedText')
    ..aOS(4, _omitFieldNames ? '' : 'targetLang')
    ..aOS(5, _omitFieldNames ? '' : 'sourceLang')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TranslateMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TranslateMessageResponse copyWith(
          void Function(TranslateMessageResponse) updates) =>
      super.copyWith((message) => updates(message as TranslateMessageResponse))
          as TranslateMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TranslateMessageResponse create() => TranslateMessageResponse._();
  @$core.override
  TranslateMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TranslateMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TranslateMessageResponse>(create);
  static TranslateMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1)
  set messageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get originalText => $_getSZ(1);
  @$pb.TagNumber(2)
  set originalText($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOriginalText() => $_has(1);
  @$pb.TagNumber(2)
  void clearOriginalText() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get translatedText => $_getSZ(2);
  @$pb.TagNumber(3)
  set translatedText($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTranslatedText() => $_has(2);
  @$pb.TagNumber(3)
  void clearTranslatedText() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get targetLang => $_getSZ(3);
  @$pb.TagNumber(4)
  set targetLang($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTargetLang() => $_has(3);
  @$pb.TagNumber(4)
  void clearTargetLang() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get sourceLang => $_getSZ(4);
  @$pb.TagNumber(5)
  set sourceLang($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSourceLang() => $_has(4);
  @$pb.TagNumber(5)
  void clearSourceLang() => $_clearField(5);
}

class GetTranslationLanguagesRequest extends $pb.GeneratedMessage {
  factory GetTranslationLanguagesRequest() => create();

  GetTranslationLanguagesRequest._();

  factory GetTranslationLanguagesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTranslationLanguagesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTranslationLanguagesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'translate'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTranslationLanguagesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTranslationLanguagesRequest copyWith(
          void Function(GetTranslationLanguagesRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetTranslationLanguagesRequest))
          as GetTranslationLanguagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTranslationLanguagesRequest create() =>
      GetTranslationLanguagesRequest._();
  @$core.override
  GetTranslationLanguagesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTranslationLanguagesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTranslationLanguagesRequest>(create);
  static GetTranslationLanguagesRequest? _defaultInstance;
}

class GetTranslationLanguagesResponse extends $pb.GeneratedMessage {
  factory GetTranslationLanguagesResponse({
    $core.Iterable<TranslateLanguage>? languages,
  }) {
    final result = create();
    if (languages != null) result.languages.addAll(languages);
    return result;
  }

  GetTranslationLanguagesResponse._();

  factory GetTranslationLanguagesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTranslationLanguagesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTranslationLanguagesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'translate'),
      createEmptyInstance: create)
    ..pPM<TranslateLanguage>(1, _omitFieldNames ? '' : 'languages',
        subBuilder: TranslateLanguage.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTranslationLanguagesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTranslationLanguagesResponse copyWith(
          void Function(GetTranslationLanguagesResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetTranslationLanguagesResponse))
          as GetTranslationLanguagesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTranslationLanguagesResponse create() =>
      GetTranslationLanguagesResponse._();
  @$core.override
  GetTranslationLanguagesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTranslationLanguagesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTranslationLanguagesResponse>(
          create);
  static GetTranslationLanguagesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TranslateLanguage> get languages => $_getList(0);
}

class TranslateLanguage extends $pb.GeneratedMessage {
  factory TranslateLanguage({
    $core.String? code,
    $core.String? name,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (name != null) result.name = name;
    return result;
  }

  TranslateLanguage._();

  factory TranslateLanguage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TranslateLanguage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TranslateLanguage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'translate'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TranslateLanguage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TranslateLanguage copyWith(void Function(TranslateLanguage) updates) =>
      super.copyWith((message) => updates(message as TranslateLanguage))
          as TranslateLanguage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TranslateLanguage create() => TranslateLanguage._();
  @$core.override
  TranslateLanguage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TranslateLanguage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TranslateLanguage>(create);
  static TranslateLanguage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
