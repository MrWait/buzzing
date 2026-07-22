// Hand-maintained proto types for M3 + M4 features.
// Field numbers match proto/*.proto definitions.

import 'dart:core' as $core;
import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'entity.pb.dart' as $0;

export 'package:protobuf/protobuf.dart';

// ── pin.proto ────────────────────────────────────────────────

class PinMessageRequest extends $pb.GeneratedMessage {
  factory PinMessageRequest({
    $fixnum.Int64? chatId,
    $fixnum.Int64? messageId,
  }) {
    final r = create();
    if (chatId != null) r.chatId = chatId;
    if (messageId != null) r.messageId = messageId;
    return r;
  }
  PinMessageRequest._();
  factory PinMessageRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  factory PinMessageRequest.fromJson($core.String json, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('PinMessageRequest', package: const $pb.PackageName('pin'), createEmptyInstance: create)
    ..aInt64(1, 'chatId')
    ..aInt64(2, 'messageId')
    ..hasRequiredFields = false;
  PinMessageRequest clone() => deepCopy();
  PinMessageRequest copyWith(void Function(PinMessageRequest) u) => super.copyWith((m) => u(m as PinMessageRequest)) as PinMessageRequest;
  $pb.BuilderInfo get info_ => _i;
  static PinMessageRequest create() => PinMessageRequest._();
  PinMessageRequest createEmptyInstance() => create();
  static PinMessageRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PinMessageRequest>(create);
  static PinMessageRequest? _defaultInstance;
  @$pb.TagNumber(1) $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1) set chatId($fixnum.Int64 v) => $_setInt64(0, v);
  @$pb.TagNumber(1) $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1) void clearChatId() => $_clearField(1);
  @$pb.TagNumber(2) $fixnum.Int64 get messageId => $_getI64(1);
  @$pb.TagNumber(2) set messageId($fixnum.Int64 v) => $_setInt64(1, v);
  @$pb.TagNumber(2) $core.bool hasMessageId() => $_has(1);
  @$pb.TagNumber(2) void clearMessageId() => $_clearField(2);
}

class PinMessageResponse extends $pb.GeneratedMessage {
  factory PinMessageResponse({$0.Entity? entities}) { final r = create(); if (entities != null) r.entities = entities; return r; }
  PinMessageResponse._();
  factory PinMessageResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('PinMessageResponse', package: const $pb.PackageName('pin'), createEmptyInstance: create)
    ..aOM<$0.Entity>(1, 'entities', subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;
  PinMessageResponse clone() => deepCopy();
  PinMessageResponse copyWith(void Function(PinMessageResponse) u) => super.copyWith((m) => u(m as PinMessageResponse)) as PinMessageResponse;
  $pb.BuilderInfo get info_ => _i;
  static PinMessageResponse create() => PinMessageResponse._();
  PinMessageResponse createEmptyInstance() => create();
  static PinMessageResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PinMessageResponse>(create);
  static PinMessageResponse? _defaultInstance;
  @$pb.TagNumber(1) $0.Entity get entities => $_getN(0);
  @$pb.TagNumber(1) set entities($0.Entity v) => $_setField(1, v);
  @$pb.TagNumber(1) $core.bool hasEntities() => $_has(0);
  @$pb.TagNumber(1) void clearEntities() => $_clearField(1);
  @$pb.TagNumber(1) $0.Entity ensureEntities() => $_ensure(0);
}

class UnpinMessageRequest extends $pb.GeneratedMessage {
  factory UnpinMessageRequest({$fixnum.Int64? chatId, $fixnum.Int64? messageId}) { final r = create(); if (chatId != null) r.chatId = chatId; if (messageId != null) r.messageId = messageId; return r; }
  UnpinMessageRequest._();
  factory UnpinMessageRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('UnpinMessageRequest', package: const $pb.PackageName('pin'), createEmptyInstance: create)
    ..aInt64(1, 'chatId')..aInt64(2, 'messageId')
    ..hasRequiredFields = false;
  UnpinMessageRequest clone() => deepCopy();
  UnpinMessageRequest copyWith(void Function(UnpinMessageRequest) u) => super.copyWith((m) => u(m as UnpinMessageRequest)) as UnpinMessageRequest;
  $pb.BuilderInfo get info_ => _i;
  static UnpinMessageRequest create() => UnpinMessageRequest._();
  UnpinMessageRequest createEmptyInstance() => create();
  static UnpinMessageRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnpinMessageRequest>(create);
  static UnpinMessageRequest? _defaultInstance;
  @$pb.TagNumber(1) $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1) set chatId($fixnum.Int64 v) => $_setInt64(0, v);
  @$pb.TagNumber(2) $fixnum.Int64 get messageId => $_getI64(1);
  @$pb.TagNumber(2) set messageId($fixnum.Int64 v) => $_setInt64(1, v);
}

class UnpinMessageResponse extends $pb.GeneratedMessage {
  factory UnpinMessageResponse({$0.Entity? entities}) { final r = create(); if (entities != null) r.entities = entities; return r; }
  UnpinMessageResponse._();
  factory UnpinMessageResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('UnpinMessageResponse', package: const $pb.PackageName('pin'), createEmptyInstance: create)
    ..aOM<$0.Entity>(1, 'entities', subBuilder: $0.Entity.create)
    ..hasRequiredFields = false;
  UnpinMessageResponse clone() => deepCopy();
  UnpinMessageResponse copyWith(void Function(UnpinMessageResponse) u) => super.copyWith((m) => u(m as UnpinMessageResponse)) as UnpinMessageResponse;
  $pb.BuilderInfo get info_ => _i;
  static UnpinMessageResponse create() => UnpinMessageResponse._();
  UnpinMessageResponse createEmptyInstance() => create();
  static UnpinMessageResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnpinMessageResponse>(create);
  static UnpinMessageResponse? _defaultInstance;
  @$pb.TagNumber(1) $0.Entity get entities => $_getN(0);
  @$pb.TagNumber(1) set entities($0.Entity v) => $_setField(1, v);
}

class GetPinnedMessagesRequest extends $pb.GeneratedMessage {
  factory GetPinnedMessagesRequest({$fixnum.Int64? chatId}) { final r = create(); if (chatId != null) r.chatId = chatId; return r; }
  GetPinnedMessagesRequest._();
  factory GetPinnedMessagesRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GetPinnedMessagesRequest', package: const $pb.PackageName('pin'), createEmptyInstance: create)
    ..aInt64(1, 'chatId')
    ..hasRequiredFields = false;
  GetPinnedMessagesRequest clone() => deepCopy();
  GetPinnedMessagesRequest copyWith(void Function(GetPinnedMessagesRequest) u) => super.copyWith((m) => u(m as GetPinnedMessagesRequest)) as GetPinnedMessagesRequest;
  $pb.BuilderInfo get info_ => _i;
  static GetPinnedMessagesRequest create() => GetPinnedMessagesRequest._();
  GetPinnedMessagesRequest createEmptyInstance() => create();
  static GetPinnedMessagesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPinnedMessagesRequest>(create);
  static GetPinnedMessagesRequest? _defaultInstance;
  @$pb.TagNumber(1) $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1) set chatId($fixnum.Int64 v) => $_setInt64(0, v);
}

class GetPinnedMessagesResponse extends $pb.GeneratedMessage {
  factory GetPinnedMessagesResponse({$core.Iterable<$0.Message>? messages}) { final r = create(); if (messages != null) r.messages.addAll(messages); return r; }
  GetPinnedMessagesResponse._();
  factory GetPinnedMessagesResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GetPinnedMessagesResponse', package: const $pb.PackageName('pin'), createEmptyInstance: create)
    ..pOM<$0.Message>(1, 'messages', subBuilder: $0.Message.create)
    ..hasRequiredFields = false;
  GetPinnedMessagesResponse clone() => deepCopy();
  GetPinnedMessagesResponse copyWith(void Function(GetPinnedMessagesResponse) u) => super.copyWith((m) => u(m as GetPinnedMessagesResponse)) as GetPinnedMessagesResponse;
  $pb.BuilderInfo get info_ => _i;
  static GetPinnedMessagesResponse create() => GetPinnedMessagesResponse._();
  GetPinnedMessagesResponse createEmptyInstance() => create();
  static GetPinnedMessagesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPinnedMessagesResponse>(create);
  static GetPinnedMessagesResponse? _defaultInstance;
  @$pb.TagNumber(1) $pb.PbList<$0.Message> get messages => $_getList(0);
}

// ── message.proto — DeleteMessage ─────────────────────────────

class DeleteMessageRequest extends $pb.GeneratedMessage {
  factory DeleteMessageRequest({$fixnum.Int64? messageId, $core.int? mode}) {
    final r = create(); if (messageId != null) r.messageId = messageId; if (mode != null) r.mode = mode; return r;
  }
  DeleteMessageRequest._();
  factory DeleteMessageRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('DeleteMessageRequest', package: const $pb.PackageName('message'), createEmptyInstance: create)
    ..aInt64(1, 'messageId')..aI(2, 'mode')
    ..hasRequiredFields = false;
  DeleteMessageRequest clone() => deepCopy();
  DeleteMessageRequest copyWith(void Function(DeleteMessageRequest) u) => super.copyWith((m) => u(m as DeleteMessageRequest)) as DeleteMessageRequest;
  $pb.BuilderInfo get info_ => _i;
  static DeleteMessageRequest create() => DeleteMessageRequest._();
  DeleteMessageRequest createEmptyInstance() => create();
  static DeleteMessageRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteMessageRequest>(create);
  static DeleteMessageRequest? _defaultInstance;
  @$pb.TagNumber(1) $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1) set messageId($fixnum.Int64 v) => $_setInt64(0, v);
  @$pb.TagNumber(2) $core.int get mode => $_getIZ(1);
  @$pb.TagNumber(2) set mode($core.int v) => $_setSignedInt32(1, v);
}

// ── thread.proto ──────────────────────────────────────────────

class GetThreadRequest extends $pb.GeneratedMessage {
  factory GetThreadRequest({$fixnum.Int64? chatId, $fixnum.Int64? rootMessageId, $core.int? page, $core.int? pageSize}) {
    final r = create(); if (chatId != null) r.chatId = chatId; if (rootMessageId != null) r.rootMessageId = rootMessageId; if (page != null) r.page = page; if (pageSize != null) r.pageSize = pageSize; return r;
  }
  GetThreadRequest._();
  factory GetThreadRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GetThreadRequest', package: const $pb.PackageName('thread'), createEmptyInstance: create)
    ..aInt64(1, 'chatId')..aInt64(2, 'rootMessageId')..aI(3, 'page')..aI(4, 'pageSize')
    ..hasRequiredFields = false;
  GetThreadRequest clone() => deepCopy();
  GetThreadRequest copyWith(void Function(GetThreadRequest) u) => super.copyWith((m) => u(m as GetThreadRequest)) as GetThreadRequest;
  $pb.BuilderInfo get info_ => _i;
  static GetThreadRequest create() => GetThreadRequest._();
  GetThreadRequest createEmptyInstance() => create();
  static GetThreadRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetThreadRequest>(create);
  static GetThreadRequest? _defaultInstance;
  @$pb.TagNumber(1) $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1) set chatId($fixnum.Int64 v) => $_setInt64(0, v);
  @$pb.TagNumber(2) $fixnum.Int64 get rootMessageId => $_getI64(1);
  @$pb.TagNumber(2) set rootMessageId($fixnum.Int64 v) => $_setInt64(1, v);
  @$pb.TagNumber(3) $core.int get page => $_getIZ(2);
  @$pb.TagNumber(3) set page($core.int v) => $_setSignedInt32(2, v);
  @$pb.TagNumber(4) $core.int get pageSize => $_getIZ(3);
  @$pb.TagNumber(4) set pageSize($core.int v) => $_setSignedInt32(3, v);
}

class GetThreadResponse extends $pb.GeneratedMessage {
  factory GetThreadResponse({$core.Iterable<$0.Message>? messages, $core.int? total}) { final r = create(); if (messages != null) r.messages.addAll(messages); if (total != null) r.total = total; return r; }
  GetThreadResponse._();
  factory GetThreadResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GetThreadResponse', package: const $pb.PackageName('thread'), createEmptyInstance: create)
    ..pOM<$0.Message>(1, 'messages', subBuilder: $0.Message.create)
    ..aI(2, 'total')
    ..hasRequiredFields = false;
  GetThreadResponse clone() => deepCopy();
  GetThreadResponse copyWith(void Function(GetThreadResponse) u) => super.copyWith((m) => u(m as GetThreadResponse)) as GetThreadResponse;
  $pb.BuilderInfo get info_ => _i;
  static GetThreadResponse create() => GetThreadResponse._();
  GetThreadResponse createEmptyInstance() => create();
  static GetThreadResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetThreadResponse>(create);
  static GetThreadResponse? _defaultInstance;
  @$pb.TagNumber(1) $pb.PbList<$0.Message> get messages => $_getList(0);
  @$pb.TagNumber(2) $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2) set total($core.int v) => $_setSignedInt32(1, v);
}

// ── message.proto — GetReadMembers ────────────────────────────

class GetReadMembersRequest extends $pb.GeneratedMessage {
  factory GetReadMembersRequest({$fixnum.Int64? chatId, $fixnum.Int64? messageId}) { final r = create(); if (chatId != null) r.chatId = chatId; if (messageId != null) r.messageId = messageId; return r; }
  GetReadMembersRequest._();
  factory GetReadMembersRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GetReadMembersRequest', package: const $pb.PackageName('message'), createEmptyInstance: create)
    ..aInt64(1, 'chatId')..aInt64(2, 'messageId')
    ..hasRequiredFields = false;
  GetReadMembersRequest clone() => deepCopy();
  GetReadMembersRequest copyWith(void Function(GetReadMembersRequest) u) => super.copyWith((m) => u(m as GetReadMembersRequest)) as GetReadMembersRequest;
  $pb.BuilderInfo get info_ => _i;
  static GetReadMembersRequest create() => GetReadMembersRequest._();
  GetReadMembersRequest createEmptyInstance() => create();
  static GetReadMembersRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetReadMembersRequest>(create);
  static GetReadMembersRequest? _defaultInstance;
  @$pb.TagNumber(1) $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1) set chatId($fixnum.Int64 v) => $_setInt64(0, v);
  @$pb.TagNumber(2) $fixnum.Int64 get messageId => $_getI64(1);
  @$pb.TagNumber(2) set messageId($fixnum.Int64 v) => $_setInt64(1, v);
}

class ReadMemberItem extends $pb.GeneratedMessage {
  factory ReadMemberItem({$fixnum.Int64? userId, $core.String? name, $core.String? avatar, $core.bool? isRead}) {
    final r = create(); if (userId != null) r.userId = userId; if (name != null) r.name = name; if (avatar != null) r.avatar = avatar; if (isRead != null) r.isRead = isRead; return r;
  }
  ReadMemberItem._();
  factory ReadMemberItem.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ReadMemberItem', package: const $pb.PackageName('message'), createEmptyInstance: create)
    ..aInt64(1, 'userId')..aOS(2, 'name')..aOS(3, 'avatar')..aOB(4, 'isRead')
    ..hasRequiredFields = false;
  ReadMemberItem clone() => deepCopy();
  ReadMemberItem copyWith(void Function(ReadMemberItem) u) => super.copyWith((m) => u(m as ReadMemberItem)) as ReadMemberItem;
  $pb.BuilderInfo get info_ => _i;
  static ReadMemberItem create() => ReadMemberItem._();
  ReadMemberItem createEmptyInstance() => create();
  static ReadMemberItem getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReadMemberItem>(create);
  static ReadMemberItem? _defaultInstance;
  @$pb.TagNumber(1) $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1) set userId($fixnum.Int64 v) => $_setInt64(0, v);
  @$pb.TagNumber(2) $core.String get name => $_getS(1);
  @$pb.TagNumber(2) set name($core.String v) => $_setString(1, v);
  @$pb.TagNumber(3) $core.String get avatar => $_getS(2);
  @$pb.TagNumber(3) set avatar($core.String v) => $_setString(2, v);
  @$pb.TagNumber(4) $core.bool get isRead => $_getBF(3);
  @$pb.TagNumber(4) set isRead($core.bool v) => $_setBool(3, v);
}

class GetReadMembersResponse extends $pb.GeneratedMessage {
  factory GetReadMembersResponse({$core.Iterable<ReadMemberItem>? members}) { final r = create(); if (members != null) r.members.addAll(members); return r; }
  GetReadMembersResponse._();
  factory GetReadMembersResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GetReadMembersResponse', package: const $pb.PackageName('message'), createEmptyInstance: create)
    ..pOM<ReadMemberItem>(1, 'members', subBuilder: ReadMemberItem.create)
    ..hasRequiredFields = false;
  GetReadMembersResponse clone() => deepCopy();
  GetReadMembersResponse copyWith(void Function(GetReadMembersResponse) u) => super.copyWith((m) => u(m as GetReadMembersResponse)) as GetReadMembersResponse;
  $pb.BuilderInfo get info_ => _i;
  static GetReadMembersResponse create() => GetReadMembersResponse._();
  GetReadMembersResponse createEmptyInstance() => create();
  static GetReadMembersResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetReadMembersResponse>(create);
  static GetReadMembersResponse? _defaultInstance;
  @$pb.TagNumber(1) $pb.PbList<ReadMemberItem> get members => $_getList(0);
}

// ── typing.proto ──────────────────────────────────────────────

class TypingRequest extends $pb.GeneratedMessage {
  factory TypingRequest({$fixnum.Int64? chatId}) { final r = create(); if (chatId != null) r.chatId = chatId; return r; }
  TypingRequest._();
  factory TypingRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TypingRequest', package: const $pb.PackageName('typing'), createEmptyInstance: create)
    ..aInt64(1, 'chatId')
    ..hasRequiredFields = false;
  TypingRequest clone() => deepCopy();
  TypingRequest copyWith(void Function(TypingRequest) u) => super.copyWith((m) => u(m as TypingRequest)) as TypingRequest;
  $pb.BuilderInfo get info_ => _i;
  static TypingRequest create() => TypingRequest._();
  TypingRequest createEmptyInstance() => create();
  static TypingRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TypingRequest>(create);
  static TypingRequest? _defaultInstance;
  @$pb.TagNumber(1) $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1) set chatId($fixnum.Int64 v) => $_setInt64(0, v);
}

class PushTyping extends $pb.GeneratedMessage {
  factory PushTyping({$fixnum.Int64? chatId, $fixnum.Int64? userId, $core.String? userName, $fixnum.Int64? expireAtMs}) {
    final r = create(); if (chatId != null) r.chatId = chatId; if (userId != null) r.userId = userId; if (userName != null) r.userName = userName; if (expireAtMs != null) r.expireAtMs = expireAtMs; return r;
  }
  PushTyping._();
  factory PushTyping.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('PushTyping', package: const $pb.PackageName('typing'), createEmptyInstance: create)
    ..aInt64(1, 'chatId')..aInt64(2, 'userId')..aOS(3, 'userName')..aInt64(4, 'expireAtMs')
    ..hasRequiredFields = false;
  PushTyping clone() => deepCopy();
  PushTyping copyWith(void Function(PushTyping) u) => super.copyWith((m) => u(m as PushTyping)) as PushTyping;
  $pb.BuilderInfo get info_ => _i;
  static PushTyping create() => PushTyping._();
  PushTyping createEmptyInstance() => create();
  static PushTyping getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PushTyping>(create);
  static PushTyping? _defaultInstance;
  @$pb.TagNumber(1) $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1) set chatId($fixnum.Int64 v) => $_setInt64(0, v);
  @$pb.TagNumber(2) $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2) set userId($fixnum.Int64 v) => $_setInt64(1, v);
  @$pb.TagNumber(3) $core.String get userName => $_getS(2);
  @$pb.TagNumber(3) set userName($core.String v) => $_setString(2, v);
  @$pb.TagNumber(4) $fixnum.Int64 get expireAtMs => $_getI64(3);
  @$pb.TagNumber(4) set expireAtMs($fixnum.Int64 v) => $_setInt64(3, v);
}

// ── presence.proto ────────────────────────────────────────────

class PresenceUpdateRequest extends $pb.GeneratedMessage {
  factory PresenceUpdateRequest({$core.int? status, $core.String? statusText}) { final r = create(); if (status != null) r.status = status; if (statusText != null) r.statusText = statusText; return r; }
  PresenceUpdateRequest._();
  factory PresenceUpdateRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('PresenceUpdateRequest', package: const $pb.PackageName('presence'), createEmptyInstance: create)
    ..aI(1, 'status')..aOS(2, 'statusText')
    ..hasRequiredFields = false;
  PresenceUpdateRequest clone() => deepCopy();
  PresenceUpdateRequest copyWith(void Function(PresenceUpdateRequest) u) => super.copyWith((m) => u(m as PresenceUpdateRequest)) as PresenceUpdateRequest;
  $pb.BuilderInfo get info_ => _i;
  static PresenceUpdateRequest create() => PresenceUpdateRequest._();
  PresenceUpdateRequest createEmptyInstance() => create();
  static PresenceUpdateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PresenceUpdateRequest>(create);
  static PresenceUpdateRequest? _defaultInstance;
  @$pb.TagNumber(1) $core.int get status => $_getIZ(0);
  @$pb.TagNumber(1) set status($core.int v) => $_setSignedInt32(0, v);
  @$pb.TagNumber(2) $core.String get statusText => $_getS(1);
  @$pb.TagNumber(2) set statusText($core.String v) => $_setString(1, v);
}

class PushPresence extends $pb.GeneratedMessage {
  factory PushPresence({$fixnum.Int64? userId, $core.int? status, $core.String? statusText, $fixnum.Int64? lastSeenMs}) {
    final r = create(); if (userId != null) r.userId = userId; if (status != null) r.status = status; if (statusText != null) r.statusText = statusText; if (lastSeenMs != null) r.lastSeenMs = lastSeenMs; return r;
  }
  PushPresence._();
  factory PushPresence.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('PushPresence', package: const $pb.PackageName('presence'), createEmptyInstance: create)
    ..aInt64(1, 'userId')..aI(2, 'status')..aOS(3, 'statusText')..aInt64(4, 'lastSeenMs')
    ..hasRequiredFields = false;
  PushPresence clone() => deepCopy();
  PushPresence copyWith(void Function(PushPresence) u) => super.copyWith((m) => u(m as PushPresence)) as PushPresence;
  $pb.BuilderInfo get info_ => _i;
  static PushPresence create() => PushPresence._();
  PushPresence createEmptyInstance() => create();
  static PushPresence getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PushPresence>(create);
  static PushPresence? _defaultInstance;
  @$pb.TagNumber(1) $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1) set userId($fixnum.Int64 v) => $_setInt64(0, v);
  @$pb.TagNumber(2) $core.int get status => $_getIZ(1);
  @$pb.TagNumber(2) set status($core.int v) => $_setSignedInt32(1, v);
  @$pb.TagNumber(3) $core.String get statusText => $_getS(2);
  @$pb.TagNumber(3) set statusText($core.String v) => $_setString(2, v);
  @$pb.TagNumber(4) $fixnum.Int64 get lastSeenMs => $_getI64(3);
  @$pb.TagNumber(4) set lastSeenMs($fixnum.Int64 v) => $_setInt64(3, v);
}

class PresenceSubscribeRequest extends $pb.GeneratedMessage {
  factory PresenceSubscribeRequest({$core.Iterable<$fixnum.Int64>? userIds}) { final r = create(); if (userIds != null) r.userIds.addAll(userIds); return r; }
  PresenceSubscribeRequest._();
  factory PresenceSubscribeRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('PresenceSubscribeRequest', package: const $pb.PackageName('presence'), createEmptyInstance: create)
    ..p<$fixnum.Int64>(1, 'userIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;
  PresenceSubscribeRequest clone() => deepCopy();
  PresenceSubscribeRequest copyWith(void Function(PresenceSubscribeRequest) u) => super.copyWith((m) => u(m as PresenceSubscribeRequest)) as PresenceSubscribeRequest;
  $pb.BuilderInfo get info_ => _i;
  static PresenceSubscribeRequest create() => PresenceSubscribeRequest._();
  PresenceSubscribeRequest createEmptyInstance() => create();
  static PresenceSubscribeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PresenceSubscribeRequest>(create);
  static PresenceSubscribeRequest? _defaultInstance;
  @$pb.TagNumber(1) $pb.PbList<$fixnum.Int64> get userIds => $_getList(0);
}

// ── search.proto ──────────────────────────────────────────────

class SearchFilter extends $pb.GeneratedMessage {
  factory SearchFilter({$fixnum.Int64? chatId, $fixnum.Int64? fromId, $core.int? msgType, $fixnum.Int64? timeStartMs, $fixnum.Int64? timeEndMs}) {
    final r = create(); if (chatId != null) r.chatId = chatId; if (fromId != null) r.fromId = fromId; if (msgType != null) r.msgType = msgType; if (timeStartMs != null) r.timeStartMs = timeStartMs; if (timeEndMs != null) r.timeEndMs = timeEndMs; return r;
  }
  SearchFilter._();
  factory SearchFilter.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SearchFilter', package: const $pb.PackageName('search'), createEmptyInstance: create)
    ..aInt64(1, 'chatId')..aInt64(2, 'fromId')..aI(3, 'msgType')..aInt64(4, 'timeStartMs')..aInt64(5, 'timeEndMs')
    ..hasRequiredFields = false;
  SearchFilter clone() => deepCopy();
  SearchFilter copyWith(void Function(SearchFilter) u) => super.copyWith((m) => u(m as SearchFilter)) as SearchFilter;
  $pb.BuilderInfo get info_ => _i;
  static SearchFilter create() => SearchFilter._();
  SearchFilter createEmptyInstance() => create();
  static SearchFilter getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchFilter>(create);
  static SearchFilter? _defaultInstance;
  @$pb.TagNumber(1) $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1) set chatId($fixnum.Int64 v) => $_setInt64(0, v);
  @$pb.TagNumber(2) $fixnum.Int64 get fromId => $_getI64(1);
  @$pb.TagNumber(2) set fromId($fixnum.Int64 v) => $_setInt64(1, v);
  @$pb.TagNumber(3) $core.int get msgType => $_getIZ(2);
  @$pb.TagNumber(3) set msgType($core.int v) => $_setSignedInt32(2, v);
  @$pb.TagNumber(4) $fixnum.Int64 get timeStartMs => $_getI64(3);
  @$pb.TagNumber(4) set timeStartMs($fixnum.Int64 v) => $_setInt64(3, v);
  @$pb.TagNumber(5) $fixnum.Int64 get timeEndMs => $_getI64(4);
  @$pb.TagNumber(5) set timeEndMs($fixnum.Int64 v) => $_setInt64(4, v);
}

class SearchRequest extends $pb.GeneratedMessage {
  factory SearchRequest({$core.String? keyword, $core.int? page, $core.int? pageSize, SearchFilter? filter}) {
    final r = create(); if (keyword != null) r.keyword = keyword; if (page != null) r.page = page; if (pageSize != null) r.pageSize = pageSize; if (filter != null) r.filter = filter; return r;
  }
  SearchRequest._();
  factory SearchRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SearchRequest', package: const $pb.PackageName('search'), createEmptyInstance: create)
    ..aOS(1, 'keyword')..aI(2, 'page')..aI(3, 'pageSize')
    ..aOM<SearchFilter>(4, 'filter', subBuilder: SearchFilter.create)
    ..hasRequiredFields = false;
  SearchRequest clone() => deepCopy();
  SearchRequest copyWith(void Function(SearchRequest) u) => super.copyWith((m) => u(m as SearchRequest)) as SearchRequest;
  $pb.BuilderInfo get info_ => _i;
  static SearchRequest create() => SearchRequest._();
  SearchRequest createEmptyInstance() => create();
  static SearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchRequest>(create);
  static SearchRequest? _defaultInstance;
  @$pb.TagNumber(1) $core.String get keyword => $_getS(0);
  @$pb.TagNumber(1) set keyword($core.String v) => $_setString(0, v);
  @$pb.TagNumber(2) $core.int get page => $_getIZ(1);
  @$pb.TagNumber(2) set page($core.int v) => $_setSignedInt32(1, v);
  @$pb.TagNumber(3) $core.int get pageSize => $_getIZ(2);
  @$pb.TagNumber(3) set pageSize($core.int v) => $_setSignedInt32(2, v);
  @$pb.TagNumber(4) SearchFilter get filter => $_getN(3);
  @$pb.TagNumber(4) set filter(SearchFilter v) => $_setField(4, v);
  @$pb.TagNumber(4) $core.bool hasFilter() => $_has(3);
  @$pb.TagNumber(4) void clearFilter() => $_clearField(4);
  @$pb.TagNumber(4) SearchFilter ensureFilter() => $_ensure(3);
}

class MessageSearchResult extends $pb.GeneratedMessage {
  factory MessageSearchResult({$0.Message? message, $core.String? highlight}) { final r = create(); if (message != null) r.message = message; if (highlight != null) r.highlight = highlight; return r; }
  MessageSearchResult._();
  factory MessageSearchResult.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('MessageSearchResult', package: const $pb.PackageName('search'), createEmptyInstance: create)
    ..aOM<$0.Message>(1, 'message', subBuilder: $0.Message.create)..aOS(2, 'highlight')
    ..hasRequiredFields = false;
  MessageSearchResult clone() => deepCopy();
  MessageSearchResult copyWith(void Function(MessageSearchResult) u) => super.copyWith((m) => u(m as MessageSearchResult)) as MessageSearchResult;
  $pb.BuilderInfo get info_ => _i;
  static MessageSearchResult create() => MessageSearchResult._();
  MessageSearchResult createEmptyInstance() => create();
  static MessageSearchResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageSearchResult>(create);
  static MessageSearchResult? _defaultInstance;
  @$pb.TagNumber(1) $0.Message get message => $_getN(0);
  @$pb.TagNumber(1) set message($0.Message v) => $_setField(1, v);
  @$pb.TagNumber(2) $core.String get highlight => $_getS(1);
  @$pb.TagNumber(2) set highlight($core.String v) => $_setString(1, v);
}

class SearchMessagesResponse extends $pb.GeneratedMessage {
  factory SearchMessagesResponse({$core.Iterable<MessageSearchResult>? results, $core.int? total}) { final r = create(); if (results != null) r.results.addAll(results); if (total != null) r.total = total; return r; }
  SearchMessagesResponse._();
  factory SearchMessagesResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SearchMessagesResponse', package: const $pb.PackageName('search'), createEmptyInstance: create)
    ..pOM<MessageSearchResult>(1, 'results', subBuilder: MessageSearchResult.create)..aI(2, 'total')
    ..hasRequiredFields = false;
  SearchMessagesResponse clone() => deepCopy();
  SearchMessagesResponse copyWith(void Function(SearchMessagesResponse) u) => super.copyWith((m) => u(m as SearchMessagesResponse)) as SearchMessagesResponse;
  $pb.BuilderInfo get info_ => _i;
  static SearchMessagesResponse create() => SearchMessagesResponse._();
  SearchMessagesResponse createEmptyInstance() => create();
  static SearchMessagesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchMessagesResponse>(create);
  static SearchMessagesResponse? _defaultInstance;
  @$pb.TagNumber(1) $pb.PbList<MessageSearchResult> get results => $_getList(0);
  @$pb.TagNumber(2) $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2) set total($core.int v) => $_setSignedInt32(1, v);
}

class ChatSearchResult extends $pb.GeneratedMessage {
  factory ChatSearchResult({$0.Chat? chat, $core.String? highlight}) { final r = create(); if (chat != null) r.chat = chat; if (highlight != null) r.highlight = highlight; return r; }
  ChatSearchResult._();
  factory ChatSearchResult.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ChatSearchResult', package: const $pb.PackageName('search'), createEmptyInstance: create)
    ..aOM<$0.Chat>(1, 'chat', subBuilder: $0.Chat.create)..aOS(2, 'highlight')
    ..hasRequiredFields = false;
  ChatSearchResult clone() => deepCopy();
  ChatSearchResult copyWith(void Function(ChatSearchResult) u) => super.copyWith((m) => u(m as ChatSearchResult)) as ChatSearchResult;
  $pb.BuilderInfo get info_ => _i;
  static ChatSearchResult create() => ChatSearchResult._();
  ChatSearchResult createEmptyInstance() => create();
  static ChatSearchResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatSearchResult>(create);
  static ChatSearchResult? _defaultInstance;
  @$pb.TagNumber(1) $0.Chat get chat => $_getN(0);
  @$pb.TagNumber(1) set chat($0.Chat v) => $_setField(1, v);
  @$pb.TagNumber(2) $core.String get highlight => $_getS(1);
  @$pb.TagNumber(2) set highlight($core.String v) => $_setString(1, v);
}

class SearchChatsResponse extends $pb.GeneratedMessage {
  factory SearchChatsResponse({$core.Iterable<ChatSearchResult>? results, $core.int? total}) { final r = create(); if (results != null) r.results.addAll(results); if (total != null) r.total = total; return r; }
  SearchChatsResponse._();
  factory SearchChatsResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SearchChatsResponse', package: const $pb.PackageName('search'), createEmptyInstance: create)
    ..pOM<ChatSearchResult>(1, 'results', subBuilder: ChatSearchResult.create)..aI(2, 'total')
    ..hasRequiredFields = false;
  SearchChatsResponse clone() => deepCopy();
  SearchChatsResponse copyWith(void Function(SearchChatsResponse) u) => super.copyWith((m) => u(m as SearchChatsResponse)) as SearchChatsResponse;
  $pb.BuilderInfo get info_ => _i;
  static SearchChatsResponse create() => SearchChatsResponse._();
  SearchChatsResponse createEmptyInstance() => create();
  static SearchChatsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchChatsResponse>(create);
  static SearchChatsResponse? _defaultInstance;
  @$pb.TagNumber(1) $pb.PbList<ChatSearchResult> get results => $_getList(0);
  @$pb.TagNumber(2) $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2) set total($core.int v) => $_setSignedInt32(1, v);
}

class UserSearchResult extends $pb.GeneratedMessage {
  factory UserSearchResult({$0.User? user, $core.String? highlight}) { final r = create(); if (user != null) r.user = user; if (highlight != null) r.highlight = highlight; return r; }
  UserSearchResult._();
  factory UserSearchResult.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('UserSearchResult', package: const $pb.PackageName('search'), createEmptyInstance: create)
    ..aOM<$0.User>(1, 'user', subBuilder: $0.User.create)..aOS(2, 'highlight')
    ..hasRequiredFields = false;
  UserSearchResult clone() => deepCopy();
  UserSearchResult copyWith(void Function(UserSearchResult) u) => super.copyWith((m) => u(m as UserSearchResult)) as UserSearchResult;
  $pb.BuilderInfo get info_ => _i;
  static UserSearchResult create() => UserSearchResult._();
  UserSearchResult createEmptyInstance() => create();
  static UserSearchResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserSearchResult>(create);
  static UserSearchResult? _defaultInstance;
  @$pb.TagNumber(1) $0.User get user => $_getN(0);
  @$pb.TagNumber(1) set user($0.User v) => $_setField(1, v);
  @$pb.TagNumber(2) $core.String get highlight => $_getS(1);
  @$pb.TagNumber(2) set highlight($core.String v) => $_setString(1, v);
}

class SearchUsersResponse extends $pb.GeneratedMessage {
  factory SearchUsersResponse({$core.Iterable<UserSearchResult>? results, $core.int? total}) { final r = create(); if (results != null) r.results.addAll(results); if (total != null) r.total = total; return r; }
  SearchUsersResponse._();
  factory SearchUsersResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SearchUsersResponse', package: const $pb.PackageName('search'), createEmptyInstance: create)
    ..pOM<UserSearchResult>(1, 'results', subBuilder: UserSearchResult.create)..aI(2, 'total')
    ..hasRequiredFields = false;
  SearchUsersResponse clone() => deepCopy();
  SearchUsersResponse copyWith(void Function(SearchUsersResponse) u) => super.copyWith((m) => u(m as SearchUsersResponse)) as SearchUsersResponse;
  $pb.BuilderInfo get info_ => _i;
  static SearchUsersResponse create() => SearchUsersResponse._();
  SearchUsersResponse createEmptyInstance() => create();
  static SearchUsersResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchUsersResponse>(create);
  static SearchUsersResponse? _defaultInstance;
  @$pb.TagNumber(1) $pb.PbList<UserSearchResult> get results => $_getList(0);
  @$pb.TagNumber(2) $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2) set total($core.int v) => $_setSignedInt32(1, v);
}

class FileSearchResult extends $pb.GeneratedMessage {
  factory FileSearchResult({$core.String? fileId, $core.String? fileName, $core.String? mimeType, $fixnum.Int64? size, $core.String? url, $core.String? highlight, $fixnum.Int64? createdAtMs, $fixnum.Int64? uploaderId}) {
    final r = create(); if (fileId != null) r.fileId = fileId; if (fileName != null) r.fileName = fileName; if (mimeType != null) r.mimeType = mimeType; if (size != null) r.size = size; if (url != null) r.url = url; if (highlight != null) r.highlight = highlight; if (createdAtMs != null) r.createdAtMs = createdAtMs; if (uploaderId != null) r.uploaderId = uploaderId; return r;
  }
  FileSearchResult._();
  factory FileSearchResult.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('FileSearchResult', package: const $pb.PackageName('search'), createEmptyInstance: create)
    ..aOS(1, 'fileId')..aOS(2, 'fileName')..aOS(3, 'mimeType')..aInt64(4, 'size')..aOS(5, 'url')..aOS(6, 'highlight')..aInt64(7, 'createdAtMs')..aInt64(8, 'uploaderId')
    ..hasRequiredFields = false;
  FileSearchResult clone() => deepCopy();
  FileSearchResult copyWith(void Function(FileSearchResult) u) => super.copyWith((m) => u(m as FileSearchResult)) as FileSearchResult;
  $pb.BuilderInfo get info_ => _i;
  static FileSearchResult create() => FileSearchResult._();
  FileSearchResult createEmptyInstance() => create();
  static FileSearchResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FileSearchResult>(create);
  static FileSearchResult? _defaultInstance;
  @$pb.TagNumber(1) $core.String get fileId => $_getS(0);
  @$pb.TagNumber(1) set fileId($core.String v) => $_setString(0, v);
  @$pb.TagNumber(2) $core.String get fileName => $_getS(1);
  @$pb.TagNumber(2) set fileName($core.String v) => $_setString(1, v);
  @$pb.TagNumber(3) $core.String get mimeType => $_getS(2);
  @$pb.TagNumber(3) set mimeType($core.String v) => $_setString(2, v);
  @$pb.TagNumber(4) $fixnum.Int64 get size => $_getI64(3);
  @$pb.TagNumber(4) set size($fixnum.Int64 v) => $_setInt64(3, v);
  @$pb.TagNumber(5) $core.String get url => $_getS(4);
  @$pb.TagNumber(5) set url($core.String v) => $_setString(4, v);
  @$pb.TagNumber(6) $core.String get highlight => $_getS(5);
  @$pb.TagNumber(6) set highlight($core.String v) => $_setString(5, v);
  @$pb.TagNumber(7) $fixnum.Int64 get createdAtMs => $_getI64(6);
  @$pb.TagNumber(7) set createdAtMs($fixnum.Int64 v) => $_setInt64(6, v);
  @$pb.TagNumber(8) $fixnum.Int64 get uploaderId => $_getI64(7);
  @$pb.TagNumber(8) set uploaderId($fixnum.Int64 v) => $_setInt64(7, v);
}

class SearchFilesResponse extends $pb.GeneratedMessage {
  factory SearchFilesResponse({$core.Iterable<FileSearchResult>? results, $core.int? total}) { final r = create(); if (results != null) r.results.addAll(results); if (total != null) r.total = total; return r; }
  SearchFilesResponse._();
  factory SearchFilesResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SearchFilesResponse', package: const $pb.PackageName('search'), createEmptyInstance: create)
    ..pOM<FileSearchResult>(1, 'results', subBuilder: FileSearchResult.create)..aI(2, 'total')
    ..hasRequiredFields = false;
  SearchFilesResponse clone() => deepCopy();
  SearchFilesResponse copyWith(void Function(SearchFilesResponse) u) => super.copyWith((m) => u(m as SearchFilesResponse)) as SearchFilesResponse;
  $pb.BuilderInfo get info_ => _i;
  static SearchFilesResponse create() => SearchFilesResponse._();
  SearchFilesResponse createEmptyInstance() => create();
  static SearchFilesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchFilesResponse>(create);
  static SearchFilesResponse? _defaultInstance;
  @$pb.TagNumber(1) $pb.PbList<FileSearchResult> get results => $_getList(0);
  @$pb.TagNumber(2) $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2) set total($core.int v) => $_setSignedInt32(1, v);
}

class GlobalSearchRequest extends $pb.GeneratedMessage {
  factory GlobalSearchRequest({$core.String? keyword, $core.int? page, $core.int? pageSize, $core.Iterable<$core.String>? types}) {
    final r = create(); if (keyword != null) r.keyword = keyword; if (page != null) r.page = page; if (pageSize != null) r.pageSize = pageSize; if (types != null) r.types.addAll(types); return r;
  }
  GlobalSearchRequest._();
  factory GlobalSearchRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GlobalSearchRequest', package: const $pb.PackageName('search'), createEmptyInstance: create)
    ..aOS(1, 'keyword')..aI(2, 'page')..aI(3, 'pageSize')..pPS(4, 'types')
    ..hasRequiredFields = false;
  GlobalSearchRequest clone() => deepCopy();
  GlobalSearchRequest copyWith(void Function(GlobalSearchRequest) u) => super.copyWith((m) => u(m as GlobalSearchRequest)) as GlobalSearchRequest;
  $pb.BuilderInfo get info_ => _i;
  static GlobalSearchRequest create() => GlobalSearchRequest._();
  GlobalSearchRequest createEmptyInstance() => create();
  static GlobalSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GlobalSearchRequest>(create);
  static GlobalSearchRequest? _defaultInstance;
  @$pb.TagNumber(1) $core.String get keyword => $_getS(0);
  @$pb.TagNumber(1) set keyword($core.String v) => $_setString(0, v);
  @$pb.TagNumber(2) $core.int get page => $_getIZ(1);
  @$pb.TagNumber(2) set page($core.int v) => $_setSignedInt32(1, v);
  @$pb.TagNumber(3) $core.int get pageSize => $_getIZ(2);
  @$pb.TagNumber(3) set pageSize($core.int v) => $_setSignedInt32(2, v);
  @$pb.TagNumber(4) $pb.PbList<$core.String> get types => $_getList(3);
}

class GlobalSearchResponse extends $pb.GeneratedMessage {
  factory GlobalSearchResponse({
    $core.Iterable<MessageSearchResult>? messages, $core.Iterable<ChatSearchResult>? chats,
    $core.Iterable<UserSearchResult>? users, $core.Iterable<FileSearchResult>? files,
    $core.int? messageTotal, $core.int? chatTotal, $core.int? userTotal, $core.int? fileTotal,
  }) {
    final r = create(); if (messages != null) r.messages.addAll(messages); if (chats != null) r.chats.addAll(chats);
    if (users != null) r.users.addAll(users); if (files != null) r.files.addAll(files);
    if (messageTotal != null) r.messageTotal = messageTotal; if (chatTotal != null) r.chatTotal = chatTotal;
    if (userTotal != null) r.userTotal = userTotal; if (fileTotal != null) r.fileTotal = fileTotal; return r;
  }
  GlobalSearchResponse._();
  factory GlobalSearchResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GlobalSearchResponse', package: const $pb.PackageName('search'), createEmptyInstance: create)
    ..pOM<MessageSearchResult>(1, 'messages', subBuilder: MessageSearchResult.create)
    ..pOM<ChatSearchResult>(2, 'chats', subBuilder: ChatSearchResult.create)
    ..pOM<UserSearchResult>(3, 'users', subBuilder: UserSearchResult.create)
    ..pOM<FileSearchResult>(4, 'files', subBuilder: FileSearchResult.create)
    ..aI(5, 'messageTotal')..aI(6, 'chatTotal')..aI(7, 'userTotal')..aI(8, 'fileTotal')
    ..hasRequiredFields = false;
  GlobalSearchResponse clone() => deepCopy();
  GlobalSearchResponse copyWith(void Function(GlobalSearchResponse) u) => super.copyWith((m) => u(m as GlobalSearchResponse)) as GlobalSearchResponse;
  $pb.BuilderInfo get info_ => _i;
  static GlobalSearchResponse create() => GlobalSearchResponse._();
  GlobalSearchResponse createEmptyInstance() => create();
  static GlobalSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GlobalSearchResponse>(create);
  static GlobalSearchResponse? _defaultInstance;
  @$pb.TagNumber(1) $pb.PbList<MessageSearchResult> get messages => $_getList(0);
  @$pb.TagNumber(2) $pb.PbList<ChatSearchResult> get chats => $_getList(1);
  @$pb.TagNumber(3) $pb.PbList<UserSearchResult> get users => $_getList(2);
  @$pb.TagNumber(4) $pb.PbList<FileSearchResult> get files => $_getList(3);
  @$pb.TagNumber(5) $core.int get messageTotal => $_getIZ(4);
  @$pb.TagNumber(5) set messageTotal($core.int v) => $_setSignedInt32(4, v);
  @$pb.TagNumber(6) $core.int get chatTotal => $_getIZ(5);
  @$pb.TagNumber(6) set chatTotal($core.int v) => $_setSignedInt32(5, v);
  @$pb.TagNumber(7) $core.int get userTotal => $_getIZ(6);
  @$pb.TagNumber(7) set userTotal($core.int v) => $_setSignedInt32(6, v);
  @$pb.TagNumber(8) $core.int get fileTotal => $_getIZ(7);
  @$pb.TagNumber(8) set fileTotal($core.int v) => $_setSignedInt32(7, v);
}

// ── entity.proto — M5 content types ───────────────────────────

class VoiceContent extends $pb.GeneratedMessage {
  factory VoiceContent({$core.String? fileId, $core.String? url, $core.int? durationSec, $core.String? transcription, $core.int? transcriptionStatus}) {
    final r = create(); if (fileId != null) r.fileId = fileId; if (url != null) r.url = url; if (durationSec != null) r.durationSec = durationSec; if (transcription != null) r.transcription = transcription; if (transcriptionStatus != null) r.transcriptionStatus = transcriptionStatus; return r;
  }
  VoiceContent._();
  factory VoiceContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('VoiceContent', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..aOS(1, 'fileId')..aOS(2, 'url')..a<$core.int>(3, 'durationSec', $pb.PbFieldType.O3)..aOS(4, 'transcription')..a<$core.int>(5, 'transcriptionStatus', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;
  VoiceContent clone() => deepCopy();
  VoiceContent copyWith(void Function(VoiceContent) u) => super.copyWith((m) => u(m as VoiceContent)) as VoiceContent;
  $pb.BuilderInfo get info_ => _i;
  static VoiceContent create() => VoiceContent._();
  VoiceContent createEmptyInstance() => create();
  static VoiceContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoiceContent>(create);
  static VoiceContent? _defaultInstance;
  @$pb.TagNumber(1) $core.String get fileId => $_getS(0);
  @$pb.TagNumber(1) set fileId($core.String v) => $_setString(0, v);
  @$pb.TagNumber(2) $core.String get url => $_getS(1);
  @$pb.TagNumber(2) set url($core.String v) => $_setString(1, v);
  @$pb.TagNumber(3) $core.int get durationSec => $_getIZ(2);
  @$pb.TagNumber(3) set durationSec($core.int v) => $_setSignedInt32(2, v);
  @$pb.TagNumber(4) $core.String get transcription => $_getS(3);
  @$pb.TagNumber(4) set transcription($core.String v) => $_setString(3, v);
  @$pb.TagNumber(5) $core.int get transcriptionStatus => $_getIZ(4);
  @$pb.TagNumber(5) set transcriptionStatus($core.int v) => $_setSignedInt32(4, v);
}

class TranscribeVoiceRequest extends $pb.GeneratedMessage {
  factory TranscribeVoiceRequest({$fixnum.Int64? messageId, $fixnum.Int64? chatId}) { final r = create(); if (messageId != null) r.messageId = messageId; if (chatId != null) r.chatId = chatId; return r; }
  TranscribeVoiceRequest._();
  factory TranscribeVoiceRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TranscribeVoiceRequest', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..aInt64(1, 'messageId')..aInt64(2, 'chatId')
    ..hasRequiredFields = false;
  TranscribeVoiceRequest clone() => deepCopy();
  TranscribeVoiceRequest copyWith(void Function(TranscribeVoiceRequest) u) => super.copyWith((m) => u(m as TranscribeVoiceRequest)) as TranscribeVoiceRequest;
  $pb.BuilderInfo get info_ => _i;
  static TranscribeVoiceRequest create() => TranscribeVoiceRequest._();
  TranscribeVoiceRequest createEmptyInstance() => create();
  static TranscribeVoiceRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TranscribeVoiceRequest>(create);
  static TranscribeVoiceRequest? _defaultInstance;
  @$pb.TagNumber(1) $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1) set messageId($fixnum.Int64 v) => $_setInt64(0, v);
  @$pb.TagNumber(2) $fixnum.Int64 get chatId => $_getI64(1);
  @$pb.TagNumber(2) set chatId($fixnum.Int64 v) => $_setInt64(1, v);
}

class TranscribeVoiceResponse extends $pb.GeneratedMessage {
  factory TranscribeVoiceResponse({$fixnum.Int64? messageId, $core.String? transcription}) { final r = create(); if (messageId != null) r.messageId = messageId; if (transcription != null) r.transcription = transcription; return r; }
  TranscribeVoiceResponse._();
  factory TranscribeVoiceResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TranscribeVoiceResponse', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..aInt64(1, 'messageId')..aOS(2, 'transcription')
    ..hasRequiredFields = false;
  TranscribeVoiceResponse clone() => deepCopy();
  TranscribeVoiceResponse copyWith(void Function(TranscribeVoiceResponse) u) => super.copyWith((m) => u(m as TranscribeVoiceResponse)) as TranscribeVoiceResponse;
  $pb.BuilderInfo get info_ => _i;
  static TranscribeVoiceResponse create() => TranscribeVoiceResponse._();
  TranscribeVoiceResponse createEmptyInstance() => create();
  static TranscribeVoiceResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TranscribeVoiceResponse>(create);
  static TranscribeVoiceResponse? _defaultInstance;
  @$pb.TagNumber(1) $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1) set messageId($fixnum.Int64 v) => $_setInt64(0, v);
  @$pb.TagNumber(2) $core.String get transcription => $_getS(1);
  @$pb.TagNumber(2) set transcription($core.String v) => $_setString(1, v);
}

// ── entity.proto — M5-B video content ────────────────────────

class MediaContent extends $pb.GeneratedMessage {
  factory MediaContent({$core.String? fileId, $core.String? url, $core.String? thumbnailUrl, $core.int? width, $core.int? height, $core.int? durationSec, $fixnum.Int64? fileSize, $core.String? mimeType}) {
    final r = create(); if (fileId != null) r.fileId = fileId; if (url != null) r.url = url; if (thumbnailUrl != null) r.thumbnailUrl = thumbnailUrl; if (width != null) r.width = width; if (height != null) r.height = height; if (durationSec != null) r.durationSec = durationSec; if (fileSize != null) r.fileSize = fileSize; if (mimeType != null) r.mimeType = mimeType; return r;
  }
  MediaContent._();
  factory MediaContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('MediaContent', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..aOS(1, 'fileId')..aOS(2, 'url')..aOS(3, 'thumbnailUrl')..a<$core.int>(4, 'width', $pb.PbFieldType.O3)..a<$core.int>(5, 'height', $pb.PbFieldType.O3)..a<$core.int>(6, 'durationSec', $pb.PbFieldType.O3)..aInt64(7, 'fileSize')..aOS(8, 'mimeType')
    ..hasRequiredFields = false;
  MediaContent clone() => deepCopy();
  MediaContent copyWith(void Function(MediaContent) u) => super.copyWith((m) => u(m as MediaContent)) as MediaContent;
  $pb.BuilderInfo get info_ => _i;
  static MediaContent create() => MediaContent._();
  MediaContent createEmptyInstance() => create();
  static MediaContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MediaContent>(create);
  static MediaContent? _defaultInstance;
  @$pb.TagNumber(1) $core.String get fileId => $_getS(0);
  @$pb.TagNumber(1) set fileId($core.String v) => $_setString(0, v);
  @$pb.TagNumber(2) $core.String get url => $_getS(1);
  @$pb.TagNumber(2) set url($core.String v) => $_setString(1, v);
  @$pb.TagNumber(3) $core.String get thumbnailUrl => $_getS(2);
  @$pb.TagNumber(3) set thumbnailUrl($core.String v) => $_setString(2, v);
  @$pb.TagNumber(4) $core.int get width => $_getIZ(3);
  @$pb.TagNumber(4) set width($core.int v) => $_setSignedInt32(3, v);
  @$pb.TagNumber(5) $core.int get height => $_getIZ(4);
  @$pb.TagNumber(5) set height($core.int v) => $_setSignedInt32(4, v);
  @$pb.TagNumber(6) $core.int get durationSec => $_getIZ(5);
  @$pb.TagNumber(6) set durationSec($core.int v) => $_setSignedInt32(5, v);
  @$pb.TagNumber(7) $fixnum.Int64 get fileSize => $_getI64(6);
  @$pb.TagNumber(7) set fileSize($fixnum.Int64 v) => $_setInt64(6, v);
  @$pb.TagNumber(8) $core.String get mimeType => $_getS(7);
  @$pb.TagNumber(8) set mimeType($core.String v) => $_setString(7, v);
}

// ── entity.proto — M5-C location content ─────────────────────

class LocationContent extends $pb.GeneratedMessage {
  factory LocationContent({$core.String? name, $core.String? address, $core.double? latitude, $core.double? longitude, $core.int? zoom, $core.String? mapUrl}) {
    final r = create(); if (name != null) r.name = name; if (address != null) r.address = address; if (latitude != null) r.latitude = latitude; if (longitude != null) r.longitude = longitude; if (zoom != null) r.zoom = zoom; if (mapUrl != null) r.mapUrl = mapUrl; return r;
  }
  LocationContent._();
  factory LocationContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('LocationContent', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..aOS(1, 'name')..aOS(2, 'address')..a<$core.double>(3, 'latitude', $pb.PbFieldType.OD)..a<$core.double>(4, 'longitude', $pb.PbFieldType.OD)..a<$core.int>(5, 'zoom', $pb.PbFieldType.O3)..aOS(6, 'mapUrl')
    ..hasRequiredFields = false;
  LocationContent clone() => deepCopy();
  LocationContent copyWith(void Function(LocationContent) u) => super.copyWith((m) => u(m as LocationContent)) as LocationContent;
  $pb.BuilderInfo get info_ => _i;
  static LocationContent create() => LocationContent._();
  LocationContent createEmptyInstance() => create();
  static LocationContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LocationContent>(create);
  static LocationContent? _defaultInstance;
  @$pb.TagNumber(1) $core.String get name => $_getS(0);
  @$pb.TagNumber(1) set name($core.String v) => $_setString(0, v);
  @$pb.TagNumber(2) $core.String get address => $_getS(1);
  @$pb.TagNumber(2) set address($core.String v) => $_setString(1, v);
  @$pb.TagNumber(3) $core.double get latitude => $_getF(2);
  @$pb.TagNumber(3) set latitude($core.double v) => $_setDouble(2, v);
  @$pb.TagNumber(4) $core.double get longitude => $_getF(3);
  @$pb.TagNumber(4) set longitude($core.double v) => $_setDouble(3, v);
  @$pb.TagNumber(5) $core.int get zoom => $_getIZ(4);
  @$pb.TagNumber(5) set zoom($core.int v) => $_setSignedInt32(4, v);
  @$pb.TagNumber(6) $core.String get mapUrl => $_getS(5);
  @$pb.TagNumber(6) set mapUrl($core.String v) => $_setString(5, v);
}

// ── entity.proto — M5-D card content ─────────────────────────

class CardContent extends $pb.GeneratedMessage {
  factory CardContent({$core.String? title, $core.String? description, $core.String? iconUrl, $core.String? imageUrl, $core.String? url, $core.Iterable<CardAction>? actions}) {
    final r = create(); if (title != null) r.title = title; if (description != null) r.description = description; if (iconUrl != null) r.iconUrl = iconUrl; if (imageUrl != null) r.imageUrl = imageUrl; if (url != null) r.url = url; if (actions != null) r.actions.addAll(actions); return r;
  }
  CardContent._();
  factory CardContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('CardContent', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..aOS(1, 'title')..aOS(2, 'description')..aOS(3, 'iconUrl')..aOS(4, 'imageUrl')..aOS(5, 'url')..pOM<CardAction>(6, 'actions', subBuilder: CardAction.create)
    ..hasRequiredFields = false;
  CardContent clone() => deepCopy();
  CardContent copyWith(void Function(CardContent) u) => super.copyWith((m) => u(m as CardContent)) as CardContent;
  $pb.BuilderInfo get info_ => _i;
  static CardContent create() => CardContent._();
  CardContent createEmptyInstance() => create();
  static CardContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CardContent>(create);
  static CardContent? _defaultInstance;
  @$pb.TagNumber(1) $core.String get title => $_getS(0);
  @$pb.TagNumber(1) set title($core.String v) => $_setString(0, v);
  @$pb.TagNumber(2) $core.String get description => $_getS(1);
  @$pb.TagNumber(2) set description($core.String v) => $_setString(1, v);
  @$pb.TagNumber(3) $core.String get iconUrl => $_getS(2);
  @$pb.TagNumber(3) set iconUrl($core.String v) => $_setString(2, v);
  @$pb.TagNumber(4) $core.String get imageUrl => $_getS(3);
  @$pb.TagNumber(4) set imageUrl($core.String v) => $_setString(3, v);
  @$pb.TagNumber(5) $core.String get url => $_getS(4);
  @$pb.TagNumber(5) set url($core.String v) => $_setString(4, v);
  @$pb.TagNumber(6) $pb.PbList<CardAction> get actions => $_getList(5);
}

class CardAction extends $pb.GeneratedMessage {
  factory CardAction({$core.String? label, $core.String? url, $core.int? actionType, $core.String? value}) {
    final r = create(); if (label != null) r.label = label; if (url != null) r.url = url; if (actionType != null) r.actionType = actionType; if (value != null) r.value = value; return r;
  }
  CardAction._();
  factory CardAction.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('CardAction', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..aOS(1, 'label')..aOS(2, 'url')..a<$core.int>(3, 'actionType', $pb.PbFieldType.O3)..aOS(4, 'value')
    ..hasRequiredFields = false;
  CardAction clone() => deepCopy();
  CardAction copyWith(void Function(CardAction) u) => super.copyWith((m) => u(m as CardAction)) as CardAction;
  $pb.BuilderInfo get info_ => _i;
  static CardAction create() => CardAction._();
  CardAction createEmptyInstance() => create();
  static CardAction getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CardAction>(create);
  static CardAction? _defaultInstance;
  @$pb.TagNumber(1) $core.String get label => $_getS(0);
  @$pb.TagNumber(1) set label($core.String v) => $_setString(0, v);
  @$pb.TagNumber(2) $core.String get url => $_getS(1);
  @$pb.TagNumber(2) set url($core.String v) => $_setString(1, v);
  @$pb.TagNumber(3) $core.int get actionType => $_getIZ(2);
  @$pb.TagNumber(3) set actionType($core.int v) => $_setSignedInt32(2, v);
  @$pb.TagNumber(4) $core.String get value => $_getS(3);
  @$pb.TagNumber(4) set value($core.String v) => $_setString(3, v);
}

// ── M5-E timer types ─────────────────────────────────────

class ScheduleMessageRequest extends $pb.GeneratedMessage {
  factory ScheduleMessageRequest({$core.int? chatId, $core.int? sendAtMs, $core.int? tpy, $core.List<$core.int>? content, $core.int? clientId, $core.int? atUserId, $core.Iterable<$core.int>? atUserIds}) {
    final r = create(); if (chatId != null) r.chatId = chatId; if (sendAtMs != null) r.sendAtMs = sendAtMs; if (tpy != null) r.tpy = tpy; if (content != null) r.content = content; if (clientId != null) r.clientId = clientId; if (atUserId != null) r.atUserId = atUserId; if (atUserIds != null) r.atUserIds.addAll(atUserIds); return r;
  }
  ScheduleMessageRequest._();
  factory ScheduleMessageRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ScheduleMessageRequest', package: const $pb.PackageName('timer'), createEmptyInstance: create)
    ..a<$core.int>(1, 'chatId', $pb.PbFieldType.O6)..a<$core.int>(2, 'sendAtMs', $pb.PbFieldType.O6)..a<$core.int>(3, 'tpy', $pb.PbFieldType.O3)..a<$core.List<$core.int>>(4, 'content', $pb.PbFieldType.O12)..a<$core.int>(5, 'clientId', $pb.PbFieldType.O6)..a<$core.int>(6, 'atUserId', $pb.PbFieldType.O6)..p<$core.int>(7, 'atUserIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;
  ScheduleMessageRequest clone() => deepCopy();
  ScheduleMessageRequest copyWith(void Function(ScheduleMessageRequest) u) => super.copyWith((m) => u(m as ScheduleMessageRequest)) as ScheduleMessageRequest;
  $pb.BuilderInfo get info_ => _i;
  static ScheduleMessageRequest create() => ScheduleMessageRequest._();
  ScheduleMessageRequest createEmptyInstance() => create();
  static ScheduleMessageRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScheduleMessageRequest>(create);
  static ScheduleMessageRequest? _defaultInstance;
  @$pb.TagNumber(1) $core.int get chatId => $_getIZ(0);
  @$pb.TagNumber(1) set chatId($core.int v) => $_setSignedInt64(0, v);
  @$pb.TagNumber(2) $core.int get sendAtMs => $_getIZ(1);
  @$pb.TagNumber(2) set sendAtMs($core.int v) => $_setSignedInt64(1, v);
  @$pb.TagNumber(3) $core.int get tpy => $_getIZ(2);
  @$pb.TagNumber(3) set tpy($core.int v) => $_setSignedInt32(2, v);
  @$pb.TagNumber(4) $core.List<$core.int> get content => $_getS(3);
  @$pb.TagNumber(4) set content($core.List<$core.int> v) => $_setBytes(3, v);
  @$pb.TagNumber(5) $core.int get clientId => $_getIZ(4);
  @$pb.TagNumber(5) set clientId($core.int v) => $_setSignedInt64(4, v);
  @$pb.TagNumber(6) $core.int get atUserId => $_getIZ(5);
  @$pb.TagNumber(6) set atUserId($core.int v) => $_setSignedInt64(5, v);
  @$pb.TagNumber(7) $pb.PbList<$core.int> get atUserIds => $_getList(6);
}

class ScheduleMessageResponse extends $pb.GeneratedMessage {
  factory ScheduleMessageResponse({$core.int? scheduleId, $core.int? scheduleAtMs}) {
    final r = create(); if (scheduleId != null) r.scheduleId = scheduleId; if (scheduleAtMs != null) r.scheduleAtMs = scheduleAtMs; return r;
  }
  ScheduleMessageResponse._();
  factory ScheduleMessageResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ScheduleMessageResponse', package: const $pb.PackageName('timer'), createEmptyInstance: create)
    ..a<$core.int>(1, 'scheduleId', $pb.PbFieldType.O6)..a<$core.int>(2, 'scheduleAtMs', $pb.PbFieldType.O6)
    ..hasRequiredFields = false;
  ScheduleMessageResponse clone() => deepCopy();
  ScheduleMessageResponse copyWith(void Function(ScheduleMessageResponse) u) => super.copyWith((m) => u(m as ScheduleMessageResponse)) as ScheduleMessageResponse;
  $pb.BuilderInfo get info_ => _i;
  static ScheduleMessageResponse create() => ScheduleMessageResponse._();
  ScheduleMessageResponse createEmptyInstance() => create();
  static ScheduleMessageResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScheduleMessageResponse>(create);
  static ScheduleMessageResponse? _defaultInstance;
  @$pb.TagNumber(1) $core.int get scheduleId => $_getIZ(0);
  @$pb.TagNumber(1) set scheduleId($core.int v) => $_setSignedInt64(0, v);
  @$pb.TagNumber(2) $core.int get scheduleAtMs => $_getIZ(1);
  @$pb.TagNumber(2) set scheduleAtMs($core.int v) => $_setSignedInt64(1, v);
}

class CancelScheduleRequest extends $pb.GeneratedMessage {
  factory CancelScheduleRequest({$core.int? scheduleId}) {
    final r = create(); if (scheduleId != null) r.scheduleId = scheduleId; return r;
  }
  CancelScheduleRequest._();
  factory CancelScheduleRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('CancelScheduleRequest', package: const $pb.PackageName('timer'), createEmptyInstance: create)
    ..a<$core.int>(1, 'scheduleId', $pb.PbFieldType.O6)
    ..hasRequiredFields = false;
  CancelScheduleRequest clone() => deepCopy();
  CancelScheduleRequest copyWith(void Function(CancelScheduleRequest) u) => super.copyWith((m) => u(m as CancelScheduleRequest)) as CancelScheduleRequest;
  $pb.BuilderInfo get info_ => _i;
  static CancelScheduleRequest create() => CancelScheduleRequest._();
  CancelScheduleRequest createEmptyInstance() => create();
  static CancelScheduleRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CancelScheduleRequest>(create);
  static CancelScheduleRequest? _defaultInstance;
  @$pb.TagNumber(1) $core.int get scheduleId => $_getIZ(0);
  @$pb.TagNumber(1) set scheduleId($core.int v) => $_setSignedInt64(0, v);
}

class CancelScheduleResponse extends $pb.GeneratedMessage {
  factory CancelScheduleResponse() => create();
  CancelScheduleResponse._();
  factory CancelScheduleResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('CancelScheduleResponse', package: const $pb.PackageName('timer'), createEmptyInstance: create)
    ..hasRequiredFields = false;
  CancelScheduleResponse clone() => deepCopy();
  CancelScheduleResponse copyWith(void Function(CancelScheduleResponse) u) => super.copyWith((m) => u(m as CancelScheduleResponse)) as CancelScheduleResponse;
  $pb.BuilderInfo get info_ => _i;
  static CancelScheduleResponse create() => CancelScheduleResponse._();
  CancelScheduleResponse createEmptyInstance() => create();
  static CancelScheduleResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CancelScheduleResponse>(create);
  static CancelScheduleResponse? _defaultInstance;
}

class GetScheduledMessagesRequest extends $pb.GeneratedMessage {
  factory GetScheduledMessagesRequest({$core.int? page, $core.int? pageSize}) {
    final r = create(); if (page != null) r.page = page; if (pageSize != null) r.pageSize = pageSize; return r;
  }
  GetScheduledMessagesRequest._();
  factory GetScheduledMessagesRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GetScheduledMessagesRequest', package: const $pb.PackageName('timer'), createEmptyInstance: create)
    ..a<$core.int>(1, 'page', $pb.PbFieldType.O3)..a<$core.int>(2, 'pageSize', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;
  GetScheduledMessagesRequest clone() => deepCopy();
  GetScheduledMessagesRequest copyWith(void Function(GetScheduledMessagesRequest) u) => super.copyWith((m) => u(m as GetScheduledMessagesRequest)) as GetScheduledMessagesRequest;
  $pb.BuilderInfo get info_ => _i;
  static GetScheduledMessagesRequest create() => GetScheduledMessagesRequest._();
  GetScheduledMessagesRequest createEmptyInstance() => create();
  static GetScheduledMessagesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetScheduledMessagesRequest>(create);
  static GetScheduledMessagesRequest? _defaultInstance;
  @$pb.TagNumber(1) $core.int get page => $_getIZ(0);
  @$pb.TagNumber(1) set page($core.int v) => $_setSignedInt32(0, v);
  @$pb.TagNumber(2) $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2) set pageSize($core.int v) => $_setSignedInt32(1, v);
}

class GetScheduledMessagesResponse extends $pb.GeneratedMessage {
  factory GetScheduledMessagesResponse({$core.Iterable<ScheduledMessage>? messages, $core.int? total}) {
    final r = create(); if (messages != null) r.messages.addAll(messages); if (total != null) r.total = total; return r;
  }
  GetScheduledMessagesResponse._();
  factory GetScheduledMessagesResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GetScheduledMessagesResponse', package: const $pb.PackageName('timer'), createEmptyInstance: create)
    ..pOM<ScheduledMessage>(1, 'messages', subBuilder: ScheduledMessage.create)..a<$core.int>(2, 'total', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;
  GetScheduledMessagesResponse clone() => deepCopy();
  GetScheduledMessagesResponse copyWith(void Function(GetScheduledMessagesResponse) u) => super.copyWith((m) => u(m as GetScheduledMessagesResponse)) as GetScheduledMessagesResponse;
  $pb.BuilderInfo get info_ => _i;
  static GetScheduledMessagesResponse create() => GetScheduledMessagesResponse._();
  GetScheduledMessagesResponse createEmptyInstance() => create();
  static GetScheduledMessagesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetScheduledMessagesResponse>(create);
  static GetScheduledMessagesResponse? _defaultInstance;
  @$pb.TagNumber(1) $pb.PbList<ScheduledMessage> get messages => $_getList(0);
  @$pb.TagNumber(2) $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2) set total($core.int v) => $_setSignedInt32(1, v);
}

class ScheduledMessage extends $pb.GeneratedMessage {
  factory ScheduledMessage({$core.int? id, $core.int? chatId, $core.int? sendAtMs, $core.int? tpy, $core.List<$core.int>? content, $core.int? status, $core.int? createdAtMs}) {
    final r = create(); if (id != null) r.id = id; if (chatId != null) r.chatId = chatId; if (sendAtMs != null) r.sendAtMs = sendAtMs; if (tpy != null) r.tpy = tpy; if (content != null) r.content = content; if (status != null) r.status = status; if (createdAtMs != null) r.createdAtMs = createdAtMs; return r;
  }
  ScheduledMessage._();
  factory ScheduledMessage.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ScheduledMessage', package: const $pb.PackageName('timer'), createEmptyInstance: create)
    ..a<$core.int>(1, 'id', $pb.PbFieldType.O6)..a<$core.int>(2, 'chatId', $pb.PbFieldType.O6)..a<$core.int>(3, 'sendAtMs', $pb.PbFieldType.O6)..a<$core.int>(4, 'tpy', $pb.PbFieldType.O3)..a<$core.List<$core.int>>(5, 'content', $pb.PbFieldType.O12)..a<$core.int>(6, 'status', $pb.PbFieldType.O3)..a<$core.int>(7, 'createdAtMs', $pb.PbFieldType.O6)
    ..hasRequiredFields = false;
  ScheduledMessage clone() => deepCopy();
  ScheduledMessage copyWith(void Function(ScheduledMessage) u) => super.copyWith((m) => u(m as ScheduledMessage)) as ScheduledMessage;
  $pb.BuilderInfo get info_ => _i;
  static ScheduledMessage create() => ScheduledMessage._();
  ScheduledMessage createEmptyInstance() => create();
  static ScheduledMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScheduledMessage>(create);
  static ScheduledMessage? _defaultInstance;
  @$pb.TagNumber(1) $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1) set id($core.int v) => $_setSignedInt64(0, v);
  @$pb.TagNumber(2) $core.int get chatId => $_getIZ(1);
  @$pb.TagNumber(2) set chatId($core.int v) => $_setSignedInt64(1, v);
  @$pb.TagNumber(3) $core.int get sendAtMs => $_getIZ(2);
  @$pb.TagNumber(3) set sendAtMs($core.int v) => $_setSignedInt64(2, v);
  @$pb.TagNumber(4) $core.int get tpy => $_getIZ(3);
  @$pb.TagNumber(4) set tpy($core.int v) => $_setSignedInt32(3, v);
  @$pb.TagNumber(5) $core.List<$core.int> get content => $_getS(4);
  @$pb.TagNumber(5) set content($core.List<$core.int> v) => $_setBytes(4, v);
  @$pb.TagNumber(6) $core.int get status => $_getIZ(5);
  @$pb.TagNumber(6) set status($core.int v) => $_setSignedInt32(5, v);
  @$pb.TagNumber(7) $core.int get createdAtMs => $_getIZ(6);
  @$pb.TagNumber(7) set createdAtMs($core.int v) => $_setSignedInt64(6, v);
}

// ── M5-F translate types ─────────────────────────────────

class TranslateMessageRequest extends $pb.GeneratedMessage {
  factory TranslateMessageRequest({$core.int? messageId, $core.int? chatId, $core.String? targetLang}) {
    final r = create(); if (messageId != null) r.messageId = messageId; if (chatId != null) r.chatId = chatId; if (targetLang != null) r.targetLang = targetLang; return r;
  }
  TranslateMessageRequest._();
  factory TranslateMessageRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TranslateMessageRequest', package: const $pb.PackageName('translate'), createEmptyInstance: create)
    ..a<$core.int>(1, 'messageId', $pb.PbFieldType.O6)..a<$core.int>(2, 'chatId', $pb.PbFieldType.O6)..aOS(3, 'targetLang')
    ..hasRequiredFields = false;
  TranslateMessageRequest clone() => deepCopy();
  TranslateMessageRequest copyWith(void Function(TranslateMessageRequest) u) => super.copyWith((m) => u(m as TranslateMessageRequest)) as TranslateMessageRequest;
  $pb.BuilderInfo get info_ => _i;
  static TranslateMessageRequest create() => TranslateMessageRequest._();
  TranslateMessageRequest createEmptyInstance() => create();
  static TranslateMessageRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TranslateMessageRequest>(create);
  static TranslateMessageRequest? _defaultInstance;
  @$pb.TagNumber(1) $core.int get messageId => $_getIZ(0);
  @$pb.TagNumber(1) set messageId($core.int v) => $_setSignedInt64(0, v);
  @$pb.TagNumber(2) $core.int get chatId => $_getIZ(1);
  @$pb.TagNumber(2) set chatId($core.int v) => $_setSignedInt64(1, v);
  @$pb.TagNumber(3) $core.String get targetLang => $_getS(2);
  @$pb.TagNumber(3) set targetLang($core.String v) => $_setString(2, v);
}

class TranslateMessageResponse extends $pb.GeneratedMessage {
  factory TranslateMessageResponse({$core.int? messageId, $core.String? originalText, $core.String? translatedText, $core.String? targetLang, $core.String? sourceLang}) {
    final r = create(); if (messageId != null) r.messageId = messageId; if (originalText != null) r.originalText = originalText; if (translatedText != null) r.translatedText = translatedText; if (targetLang != null) r.targetLang = targetLang; if (sourceLang != null) r.sourceLang = sourceLang; return r;
  }
  TranslateMessageResponse._();
  factory TranslateMessageResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TranslateMessageResponse', package: const $pb.PackageName('translate'), createEmptyInstance: create)
    ..a<$core.int>(1, 'messageId', $pb.PbFieldType.O6)..aOS(2, 'originalText')..aOS(3, 'translatedText')..aOS(4, 'targetLang')..aOS(5, 'sourceLang')
    ..hasRequiredFields = false;
  TranslateMessageResponse clone() => deepCopy();
  TranslateMessageResponse copyWith(void Function(TranslateMessageResponse) u) => super.copyWith((m) => u(m as TranslateMessageResponse)) as TranslateMessageResponse;
  $pb.BuilderInfo get info_ => _i;
  static TranslateMessageResponse create() => TranslateMessageResponse._();
  TranslateMessageResponse createEmptyInstance() => create();
  static TranslateMessageResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TranslateMessageResponse>(create);
  static TranslateMessageResponse? _defaultInstance;
  @$pb.TagNumber(1) $core.int get messageId => $_getIZ(0);
  @$pb.TagNumber(1) set messageId($core.int v) => $_setSignedInt64(0, v);
  @$pb.TagNumber(2) $core.String get originalText => $_getS(1);
  @$pb.TagNumber(2) set originalText($core.String v) => $_setString(1, v);
  @$pb.TagNumber(3) $core.String get translatedText => $_getS(2);
  @$pb.TagNumber(3) set translatedText($core.String v) => $_setString(2, v);
  @$pb.TagNumber(4) $core.String get targetLang => $_getS(3);
  @$pb.TagNumber(4) set targetLang($core.String v) => $_setString(3, v);
  @$pb.TagNumber(5) $core.String get sourceLang => $_getS(4);
  @$pb.TagNumber(5) set sourceLang($core.String v) => $_setString(4, v);
}

class GetTranslationLanguagesRequest extends $pb.GeneratedMessage {
  factory GetTranslationLanguagesRequest() => create();
  GetTranslationLanguagesRequest._();
  factory GetTranslationLanguagesRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GetTranslationLanguagesRequest', package: const $pb.PackageName('translate'), createEmptyInstance: create)
    ..hasRequiredFields = false;
  GetTranslationLanguagesRequest clone() => deepCopy();
  GetTranslationLanguagesRequest copyWith(void Function(GetTranslationLanguagesRequest) u) => super.copyWith((m) => u(m as GetTranslationLanguagesRequest)) as GetTranslationLanguagesRequest;
  $pb.BuilderInfo get info_ => _i;
  static GetTranslationLanguagesRequest create() => GetTranslationLanguagesRequest._();
  GetTranslationLanguagesRequest createEmptyInstance() => create();
  static GetTranslationLanguagesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTranslationLanguagesRequest>(create);
  static GetTranslationLanguagesRequest? _defaultInstance;
}

class GetTranslationLanguagesResponse extends $pb.GeneratedMessage {
  factory GetTranslationLanguagesResponse({$core.Iterable<TranslateLanguage>? languages}) {
    final r = create(); if (languages != null) r.languages.addAll(languages); return r;
  }
  GetTranslationLanguagesResponse._();
  factory GetTranslationLanguagesResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GetTranslationLanguagesResponse', package: const $pb.PackageName('translate'), createEmptyInstance: create)
    ..pOM<TranslateLanguage>(1, 'languages', subBuilder: TranslateLanguage.create)
    ..hasRequiredFields = false;
  GetTranslationLanguagesResponse clone() => deepCopy();
  GetTranslationLanguagesResponse copyWith(void Function(GetTranslationLanguagesResponse) u) => super.copyWith((m) => u(m as GetTranslationLanguagesResponse)) as GetTranslationLanguagesResponse;
  $pb.BuilderInfo get info_ => _i;
  static GetTranslationLanguagesResponse create() => GetTranslationLanguagesResponse._();
  GetTranslationLanguagesResponse createEmptyInstance() => create();
  static GetTranslationLanguagesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTranslationLanguagesResponse>(create);
  static GetTranslationLanguagesResponse? _defaultInstance;
  @$pb.TagNumber(1) $pb.PbList<TranslateLanguage> get languages => $_getList(0);
}

class TranslateLanguage extends $pb.GeneratedMessage {
  factory TranslateLanguage({$core.String? code, $core.String? name}) {
    final r = create(); if (code != null) r.code = code; if (name != null) r.name = name; return r;
  }
  TranslateLanguage._();
  factory TranslateLanguage.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, r);
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TranslateLanguage', package: const $pb.PackageName('translate'), createEmptyInstance: create)
    ..aOS(1, 'code')..aOS(2, 'name')
    ..hasRequiredFields = false;
  TranslateLanguage clone() => deepCopy();
  TranslateLanguage copyWith(void Function(TranslateLanguage) u) => super.copyWith((m) => u(m as TranslateLanguage)) as TranslateLanguage;
  $pb.BuilderInfo get info_ => _i;
  static TranslateLanguage create() => TranslateLanguage._();
  TranslateLanguage createEmptyInstance() => create();
  static TranslateLanguage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TranslateLanguage>(create);
  static TranslateLanguage? _defaultInstance;
  @$pb.TagNumber(1) $core.String get code => $_getS(0);
  @$pb.TagNumber(1) set code($core.String v) => $_setString(0, v);
  @$pb.TagNumber(2) $core.String get name => $_getS(1);
  @$pb.TagNumber(2) set name($core.String v) => $_setString(1, v);
}
