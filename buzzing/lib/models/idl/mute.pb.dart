// This is a generated file - do not edit.
//
// Generated from mute.proto.

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

class MuteMemberRequest extends $pb.GeneratedMessage {
  factory MuteMemberRequest({
    $fixnum.Int64? chatId,
    $fixnum.Int64? memberId,
    $fixnum.Int64? untilMs,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (memberId != null) result.memberId = memberId;
    if (untilMs != null) result.untilMs = untilMs;
    return result;
  }

  MuteMemberRequest._();

  factory MuteMemberRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MuteMemberRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MuteMemberRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mute'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..aInt64(2, _omitFieldNames ? '' : 'memberId')
    ..aInt64(3, _omitFieldNames ? '' : 'untilMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MuteMemberRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MuteMemberRequest copyWith(void Function(MuteMemberRequest) updates) =>
      super.copyWith((message) => updates(message as MuteMemberRequest))
          as MuteMemberRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MuteMemberRequest create() => MuteMemberRequest._();
  @$core.override
  MuteMemberRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MuteMemberRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MuteMemberRequest>(create);
  static MuteMemberRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get memberId => $_getI64(1);
  @$pb.TagNumber(2)
  set memberId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMemberId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemberId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get untilMs => $_getI64(2);
  @$pb.TagNumber(3)
  set untilMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUntilMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearUntilMs() => $_clearField(3);
}

class MuteMemberResponse extends $pb.GeneratedMessage {
  factory MuteMemberResponse() => create();

  MuteMemberResponse._();

  factory MuteMemberResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MuteMemberResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MuteMemberResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mute'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MuteMemberResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MuteMemberResponse copyWith(void Function(MuteMemberResponse) updates) =>
      super.copyWith((message) => updates(message as MuteMemberResponse))
          as MuteMemberResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MuteMemberResponse create() => MuteMemberResponse._();
  @$core.override
  MuteMemberResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MuteMemberResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MuteMemberResponse>(create);
  static MuteMemberResponse? _defaultInstance;
}

class GlobalMuteRequest extends $pb.GeneratedMessage {
  factory GlobalMuteRequest({
    $fixnum.Int64? chatId,
    $fixnum.Int64? untilMs,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (untilMs != null) result.untilMs = untilMs;
    return result;
  }

  GlobalMuteRequest._();

  factory GlobalMuteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GlobalMuteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GlobalMuteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mute'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..aInt64(2, _omitFieldNames ? '' : 'untilMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GlobalMuteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GlobalMuteRequest copyWith(void Function(GlobalMuteRequest) updates) =>
      super.copyWith((message) => updates(message as GlobalMuteRequest))
          as GlobalMuteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GlobalMuteRequest create() => GlobalMuteRequest._();
  @$core.override
  GlobalMuteRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GlobalMuteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GlobalMuteRequest>(create);
  static GlobalMuteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get untilMs => $_getI64(1);
  @$pb.TagNumber(2)
  set untilMs($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUntilMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearUntilMs() => $_clearField(2);
}

class GlobalMuteResponse extends $pb.GeneratedMessage {
  factory GlobalMuteResponse() => create();

  GlobalMuteResponse._();

  factory GlobalMuteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GlobalMuteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GlobalMuteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mute'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GlobalMuteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GlobalMuteResponse copyWith(void Function(GlobalMuteResponse) updates) =>
      super.copyWith((message) => updates(message as GlobalMuteResponse))
          as GlobalMuteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GlobalMuteResponse create() => GlobalMuteResponse._();
  @$core.override
  GlobalMuteResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GlobalMuteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GlobalMuteResponse>(create);
  static GlobalMuteResponse? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
