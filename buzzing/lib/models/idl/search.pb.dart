// This is a generated file - do not edit.
//
// Generated from search.proto.

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

class SearchFilter extends $pb.GeneratedMessage {
  factory SearchFilter({
    $fixnum.Int64? chatId,
    $fixnum.Int64? fromId,
    $core.int? msgType,
    $fixnum.Int64? timeStartMs,
    $fixnum.Int64? timeEndMs,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (fromId != null) result.fromId = fromId;
    if (msgType != null) result.msgType = msgType;
    if (timeStartMs != null) result.timeStartMs = timeStartMs;
    if (timeEndMs != null) result.timeEndMs = timeEndMs;
    return result;
  }

  SearchFilter._();

  factory SearchFilter.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchFilter.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchFilter',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'search'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'chatId')
    ..aInt64(2, _omitFieldNames ? '' : 'fromId')
    ..aI(3, _omitFieldNames ? '' : 'msgType')
    ..aInt64(4, _omitFieldNames ? '' : 'timeStartMs')
    ..aInt64(5, _omitFieldNames ? '' : 'timeEndMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchFilter clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchFilter copyWith(void Function(SearchFilter) updates) =>
      super.copyWith((message) => updates(message as SearchFilter))
          as SearchFilter;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchFilter create() => SearchFilter._();
  @$core.override
  SearchFilter createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchFilter getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchFilter>(create);
  static SearchFilter? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get fromId => $_getI64(1);
  @$pb.TagNumber(2)
  set fromId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFromId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFromId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get msgType => $_getIZ(2);
  @$pb.TagNumber(3)
  set msgType($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMsgType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMsgType() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timeStartMs => $_getI64(3);
  @$pb.TagNumber(4)
  set timeStartMs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimeStartMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimeStartMs() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get timeEndMs => $_getI64(4);
  @$pb.TagNumber(5)
  set timeEndMs($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimeEndMs() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimeEndMs() => $_clearField(5);
}

class SearchRequest extends $pb.GeneratedMessage {
  factory SearchRequest({
    $core.String? keyword,
    $core.int? page,
    $core.int? pageSize,
    SearchFilter? filter,
  }) {
    final result = create();
    if (keyword != null) result.keyword = keyword;
    if (page != null) result.page = page;
    if (pageSize != null) result.pageSize = pageSize;
    if (filter != null) result.filter = filter;
    return result;
  }

  SearchRequest._();

  factory SearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'search'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'keyword')
    ..aI(2, _omitFieldNames ? '' : 'page')
    ..aI(3, _omitFieldNames ? '' : 'pageSize')
    ..aOM<SearchFilter>(4, _omitFieldNames ? '' : 'filter',
        subBuilder: SearchFilter.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchRequest copyWith(void Function(SearchRequest) updates) =>
      super.copyWith((message) => updates(message as SearchRequest))
          as SearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchRequest create() => SearchRequest._();
  @$core.override
  SearchRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchRequest>(create);
  static SearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get keyword => $_getSZ(0);
  @$pb.TagNumber(1)
  set keyword($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKeyword() => $_has(0);
  @$pb.TagNumber(1)
  void clearKeyword() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get page => $_getIZ(1);
  @$pb.TagNumber(2)
  set page($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearPage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get pageSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageSize($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageSize() => $_clearField(3);

  @$pb.TagNumber(4)
  SearchFilter get filter => $_getN(3);
  @$pb.TagNumber(4)
  set filter(SearchFilter value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasFilter() => $_has(3);
  @$pb.TagNumber(4)
  void clearFilter() => $_clearField(4);
  @$pb.TagNumber(4)
  SearchFilter ensureFilter() => $_ensure(3);
}

class MessageSearchResult extends $pb.GeneratedMessage {
  factory MessageSearchResult({
    $0.Message? message,
    $core.String? highlight,
  }) {
    final result = create();
    if (message != null) result.message = message;
    if (highlight != null) result.highlight = highlight;
    return result;
  }

  MessageSearchResult._();

  factory MessageSearchResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageSearchResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageSearchResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'search'),
      createEmptyInstance: create)
    ..aOM<$0.Message>(1, _omitFieldNames ? '' : 'message',
        subBuilder: $0.Message.create)
    ..aOS(2, _omitFieldNames ? '' : 'highlight')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageSearchResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageSearchResult copyWith(void Function(MessageSearchResult) updates) =>
      super.copyWith((message) => updates(message as MessageSearchResult))
          as MessageSearchResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageSearchResult create() => MessageSearchResult._();
  @$core.override
  MessageSearchResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageSearchResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageSearchResult>(create);
  static MessageSearchResult? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Message get message => $_getN(0);
  @$pb.TagNumber(1)
  set message($0.Message value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Message ensureMessage() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get highlight => $_getSZ(1);
  @$pb.TagNumber(2)
  set highlight($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHighlight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHighlight() => $_clearField(2);
}

class SearchMessagesResponse extends $pb.GeneratedMessage {
  factory SearchMessagesResponse({
    $core.Iterable<MessageSearchResult>? results,
    $core.int? total,
  }) {
    final result = create();
    if (results != null) result.results.addAll(results);
    if (total != null) result.total = total;
    return result;
  }

  SearchMessagesResponse._();

  factory SearchMessagesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchMessagesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchMessagesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'search'),
      createEmptyInstance: create)
    ..pPM<MessageSearchResult>(1, _omitFieldNames ? '' : 'results',
        subBuilder: MessageSearchResult.create)
    ..aI(2, _omitFieldNames ? '' : 'total')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchMessagesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchMessagesResponse copyWith(
          void Function(SearchMessagesResponse) updates) =>
      super.copyWith((message) => updates(message as SearchMessagesResponse))
          as SearchMessagesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchMessagesResponse create() => SearchMessagesResponse._();
  @$core.override
  SearchMessagesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchMessagesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchMessagesResponse>(create);
  static SearchMessagesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<MessageSearchResult> get results => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2)
  set total($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);
}

class ChatSearchResult extends $pb.GeneratedMessage {
  factory ChatSearchResult({
    $0.Chat? chat,
    $core.String? highlight,
  }) {
    final result = create();
    if (chat != null) result.chat = chat;
    if (highlight != null) result.highlight = highlight;
    return result;
  }

  ChatSearchResult._();

  factory ChatSearchResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChatSearchResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatSearchResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'search'),
      createEmptyInstance: create)
    ..aOM<$0.Chat>(1, _omitFieldNames ? '' : 'chat', subBuilder: $0.Chat.create)
    ..aOS(2, _omitFieldNames ? '' : 'highlight')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatSearchResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatSearchResult copyWith(void Function(ChatSearchResult) updates) =>
      super.copyWith((message) => updates(message as ChatSearchResult))
          as ChatSearchResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatSearchResult create() => ChatSearchResult._();
  @$core.override
  ChatSearchResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChatSearchResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatSearchResult>(create);
  static ChatSearchResult? _defaultInstance;

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

  @$pb.TagNumber(2)
  $core.String get highlight => $_getSZ(1);
  @$pb.TagNumber(2)
  set highlight($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHighlight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHighlight() => $_clearField(2);
}

class SearchChatsResponse extends $pb.GeneratedMessage {
  factory SearchChatsResponse({
    $core.Iterable<ChatSearchResult>? results,
    $core.int? total,
  }) {
    final result = create();
    if (results != null) result.results.addAll(results);
    if (total != null) result.total = total;
    return result;
  }

  SearchChatsResponse._();

  factory SearchChatsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchChatsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchChatsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'search'),
      createEmptyInstance: create)
    ..pPM<ChatSearchResult>(1, _omitFieldNames ? '' : 'results',
        subBuilder: ChatSearchResult.create)
    ..aI(2, _omitFieldNames ? '' : 'total')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchChatsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchChatsResponse copyWith(void Function(SearchChatsResponse) updates) =>
      super.copyWith((message) => updates(message as SearchChatsResponse))
          as SearchChatsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchChatsResponse create() => SearchChatsResponse._();
  @$core.override
  SearchChatsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchChatsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchChatsResponse>(create);
  static SearchChatsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ChatSearchResult> get results => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2)
  set total($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);
}

class UserSearchResult extends $pb.GeneratedMessage {
  factory UserSearchResult({
    $0.User? user,
    $core.String? highlight,
  }) {
    final result = create();
    if (user != null) result.user = user;
    if (highlight != null) result.highlight = highlight;
    return result;
  }

  UserSearchResult._();

  factory UserSearchResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserSearchResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserSearchResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'search'),
      createEmptyInstance: create)
    ..aOM<$0.User>(1, _omitFieldNames ? '' : 'user', subBuilder: $0.User.create)
    ..aOS(2, _omitFieldNames ? '' : 'highlight')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserSearchResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserSearchResult copyWith(void Function(UserSearchResult) updates) =>
      super.copyWith((message) => updates(message as UserSearchResult))
          as UserSearchResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserSearchResult create() => UserSearchResult._();
  @$core.override
  UserSearchResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UserSearchResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserSearchResult>(create);
  static UserSearchResult? _defaultInstance;

  @$pb.TagNumber(1)
  $0.User get user => $_getN(0);
  @$pb.TagNumber(1)
  set user($0.User value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasUser() => $_has(0);
  @$pb.TagNumber(1)
  void clearUser() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.User ensureUser() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get highlight => $_getSZ(1);
  @$pb.TagNumber(2)
  set highlight($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHighlight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHighlight() => $_clearField(2);
}

class SearchUsersResponse extends $pb.GeneratedMessage {
  factory SearchUsersResponse({
    $core.Iterable<UserSearchResult>? results,
    $core.int? total,
  }) {
    final result = create();
    if (results != null) result.results.addAll(results);
    if (total != null) result.total = total;
    return result;
  }

  SearchUsersResponse._();

  factory SearchUsersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchUsersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchUsersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'search'),
      createEmptyInstance: create)
    ..pPM<UserSearchResult>(1, _omitFieldNames ? '' : 'results',
        subBuilder: UserSearchResult.create)
    ..aI(2, _omitFieldNames ? '' : 'total')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUsersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUsersResponse copyWith(void Function(SearchUsersResponse) updates) =>
      super.copyWith((message) => updates(message as SearchUsersResponse))
          as SearchUsersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchUsersResponse create() => SearchUsersResponse._();
  @$core.override
  SearchUsersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchUsersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchUsersResponse>(create);
  static SearchUsersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<UserSearchResult> get results => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2)
  set total($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);
}

class FileSearchResult extends $pb.GeneratedMessage {
  factory FileSearchResult({
    $core.String? fileId,
    $core.String? fileName,
    $core.String? mimeType,
    $fixnum.Int64? size,
    $core.String? url,
    $core.String? highlight,
    $fixnum.Int64? createdAtMs,
    $fixnum.Int64? uploaderId,
  }) {
    final result = create();
    if (fileId != null) result.fileId = fileId;
    if (fileName != null) result.fileName = fileName;
    if (mimeType != null) result.mimeType = mimeType;
    if (size != null) result.size = size;
    if (url != null) result.url = url;
    if (highlight != null) result.highlight = highlight;
    if (createdAtMs != null) result.createdAtMs = createdAtMs;
    if (uploaderId != null) result.uploaderId = uploaderId;
    return result;
  }

  FileSearchResult._();

  factory FileSearchResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FileSearchResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileSearchResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'search'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fileId')
    ..aOS(2, _omitFieldNames ? '' : 'fileName')
    ..aOS(3, _omitFieldNames ? '' : 'mimeType')
    ..aInt64(4, _omitFieldNames ? '' : 'size')
    ..aOS(5, _omitFieldNames ? '' : 'url')
    ..aOS(6, _omitFieldNames ? '' : 'highlight')
    ..aInt64(7, _omitFieldNames ? '' : 'createdAtMs')
    ..aInt64(8, _omitFieldNames ? '' : 'uploaderId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileSearchResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileSearchResult copyWith(void Function(FileSearchResult) updates) =>
      super.copyWith((message) => updates(message as FileSearchResult))
          as FileSearchResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileSearchResult create() => FileSearchResult._();
  @$core.override
  FileSearchResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FileSearchResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FileSearchResult>(create);
  static FileSearchResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fileId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fileId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFileId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFileId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fileName => $_getSZ(1);
  @$pb.TagNumber(2)
  set fileName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFileName() => $_has(1);
  @$pb.TagNumber(2)
  void clearFileName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get mimeType => $_getSZ(2);
  @$pb.TagNumber(3)
  set mimeType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMimeType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMimeType() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get size => $_getI64(3);
  @$pb.TagNumber(4)
  set size($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearSize() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get url => $_getSZ(4);
  @$pb.TagNumber(5)
  set url($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearUrl() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get highlight => $_getSZ(5);
  @$pb.TagNumber(6)
  set highlight($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHighlight() => $_has(5);
  @$pb.TagNumber(6)
  void clearHighlight() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get createdAtMs => $_getI64(6);
  @$pb.TagNumber(7)
  set createdAtMs($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAtMs() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAtMs() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get uploaderId => $_getI64(7);
  @$pb.TagNumber(8)
  set uploaderId($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUploaderId() => $_has(7);
  @$pb.TagNumber(8)
  void clearUploaderId() => $_clearField(8);
}

class SearchFilesResponse extends $pb.GeneratedMessage {
  factory SearchFilesResponse({
    $core.Iterable<FileSearchResult>? results,
    $core.int? total,
  }) {
    final result = create();
    if (results != null) result.results.addAll(results);
    if (total != null) result.total = total;
    return result;
  }

  SearchFilesResponse._();

  factory SearchFilesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchFilesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchFilesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'search'),
      createEmptyInstance: create)
    ..pPM<FileSearchResult>(1, _omitFieldNames ? '' : 'results',
        subBuilder: FileSearchResult.create)
    ..aI(2, _omitFieldNames ? '' : 'total')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchFilesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchFilesResponse copyWith(void Function(SearchFilesResponse) updates) =>
      super.copyWith((message) => updates(message as SearchFilesResponse))
          as SearchFilesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchFilesResponse create() => SearchFilesResponse._();
  @$core.override
  SearchFilesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchFilesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchFilesResponse>(create);
  static SearchFilesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FileSearchResult> get results => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2)
  set total($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);
}

class GlobalSearchRequest extends $pb.GeneratedMessage {
  factory GlobalSearchRequest({
    $core.String? keyword,
    $core.int? page,
    $core.int? pageSize,
    $core.Iterable<$core.String>? types,
  }) {
    final result = create();
    if (keyword != null) result.keyword = keyword;
    if (page != null) result.page = page;
    if (pageSize != null) result.pageSize = pageSize;
    if (types != null) result.types.addAll(types);
    return result;
  }

  GlobalSearchRequest._();

  factory GlobalSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GlobalSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GlobalSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'search'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'keyword')
    ..aI(2, _omitFieldNames ? '' : 'page')
    ..aI(3, _omitFieldNames ? '' : 'pageSize')
    ..pPS(4, _omitFieldNames ? '' : 'types')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GlobalSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GlobalSearchRequest copyWith(void Function(GlobalSearchRequest) updates) =>
      super.copyWith((message) => updates(message as GlobalSearchRequest))
          as GlobalSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GlobalSearchRequest create() => GlobalSearchRequest._();
  @$core.override
  GlobalSearchRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GlobalSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GlobalSearchRequest>(create);
  static GlobalSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get keyword => $_getSZ(0);
  @$pb.TagNumber(1)
  set keyword($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKeyword() => $_has(0);
  @$pb.TagNumber(1)
  void clearKeyword() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get page => $_getIZ(1);
  @$pb.TagNumber(2)
  set page($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearPage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get pageSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageSize($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageSize() => $_clearField(3);

  /// 限定搜索范围，空列表 = 搜全部
  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get types => $_getList(3);
}

class GlobalSearchResponse extends $pb.GeneratedMessage {
  factory GlobalSearchResponse({
    $core.Iterable<MessageSearchResult>? messages,
    $core.Iterable<ChatSearchResult>? chats,
    $core.Iterable<UserSearchResult>? users,
    $core.Iterable<FileSearchResult>? files,
    $core.int? messageTotal,
    $core.int? chatTotal,
    $core.int? userTotal,
    $core.int? fileTotal,
  }) {
    final result = create();
    if (messages != null) result.messages.addAll(messages);
    if (chats != null) result.chats.addAll(chats);
    if (users != null) result.users.addAll(users);
    if (files != null) result.files.addAll(files);
    if (messageTotal != null) result.messageTotal = messageTotal;
    if (chatTotal != null) result.chatTotal = chatTotal;
    if (userTotal != null) result.userTotal = userTotal;
    if (fileTotal != null) result.fileTotal = fileTotal;
    return result;
  }

  GlobalSearchResponse._();

  factory GlobalSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GlobalSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GlobalSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'search'),
      createEmptyInstance: create)
    ..pPM<MessageSearchResult>(1, _omitFieldNames ? '' : 'messages',
        subBuilder: MessageSearchResult.create)
    ..pPM<ChatSearchResult>(2, _omitFieldNames ? '' : 'chats',
        subBuilder: ChatSearchResult.create)
    ..pPM<UserSearchResult>(3, _omitFieldNames ? '' : 'users',
        subBuilder: UserSearchResult.create)
    ..pPM<FileSearchResult>(4, _omitFieldNames ? '' : 'files',
        subBuilder: FileSearchResult.create)
    ..aI(5, _omitFieldNames ? '' : 'messageTotal')
    ..aI(6, _omitFieldNames ? '' : 'chatTotal')
    ..aI(7, _omitFieldNames ? '' : 'userTotal')
    ..aI(8, _omitFieldNames ? '' : 'fileTotal')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GlobalSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GlobalSearchResponse copyWith(void Function(GlobalSearchResponse) updates) =>
      super.copyWith((message) => updates(message as GlobalSearchResponse))
          as GlobalSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GlobalSearchResponse create() => GlobalSearchResponse._();
  @$core.override
  GlobalSearchResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GlobalSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GlobalSearchResponse>(create);
  static GlobalSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<MessageSearchResult> get messages => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<ChatSearchResult> get chats => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<UserSearchResult> get users => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<FileSearchResult> get files => $_getList(3);

  @$pb.TagNumber(5)
  $core.int get messageTotal => $_getIZ(4);
  @$pb.TagNumber(5)
  set messageTotal($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMessageTotal() => $_has(4);
  @$pb.TagNumber(5)
  void clearMessageTotal() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get chatTotal => $_getIZ(5);
  @$pb.TagNumber(6)
  set chatTotal($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasChatTotal() => $_has(5);
  @$pb.TagNumber(6)
  void clearChatTotal() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get userTotal => $_getIZ(6);
  @$pb.TagNumber(7)
  set userTotal($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUserTotal() => $_has(6);
  @$pb.TagNumber(7)
  void clearUserTotal() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get fileTotal => $_getIZ(7);
  @$pb.TagNumber(8)
  set fileTotal($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFileTotal() => $_has(7);
  @$pb.TagNumber(8)
  void clearFileTotal() => $_clearField(8);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
