import 'dart:convert';
import 'dart:typed_data';

import 'package:buzzing/models/const.dart';
import 'package:buzzing/models/idl/chat.pb.dart';
import 'package:buzzing/models/idl/dept.pb.dart';
import 'package:buzzing/models/idl/mute.pb.dart';
import 'package:buzzing/models/idl/invite.pb.dart';
import 'package:buzzing/models/idl/join_request.pb.dart';
import 'package:buzzing/routes/app_navigator.dart';
import 'package:buzzing/utils/data_persistence.dart';
import 'package:go_router/go_router.dart';
import 'package:buzzing/models/idl/message.pb.dart';
import 'package:buzzing/models/idl/user.pb.dart';
import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/event/event_bus.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/models/idl/feed.pb.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/sdk.pb.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:buzzing/widget/feedcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:fixnum/fixnum.dart';

class UserVer {
  var ver = Int64(0);
  User? user;

  UserVer(Int64 version, this.user) {
    ver = version;
  }
}

class ImController extends ChangeNotifier {
  final SdkController sdk;
  final EventBus ev;

  ImController({required this.sdk, required this.ev});

  var feedList = <FeedModel>[];
  var messagePosList = <MessageIndex>[];
  var imInputCtrl = TextEditingController();
  var msgCtrl = ScrollController();
  Map<Int64, UserVer> userVers = {};

  var focusNode = FocusNode();
  var quillController = QuillController.basic();
  var showMentionPopup = false;
  Offset popuppOffset = Offset.zero;
  final LayerLink layerLink = LayerLink();
  final List<String> candidates = ["Atom", "Bob", "Crys", "David"];

  var avatar = "";

  var chatId = Int64(0);
  var userId = Int64(0);
  var debug = true;
  var entity = Entity.create();
  int ver = 0;
  var user = User.create();

  LoginUser loginUser = LoginUser.create();

  // 引用回复目标消息
  Message? replyTarget;

  void setReplyTarget(Message? msg) {
    replyTarget = msg;
    notifyListeners();
  }

  void clearReply() {
    replyTarget = null;
    notifyListeners();
  }

  void onClose() {
    L.w("im logic close");
  }

  void onTextChanged() {
    final text = quillController.document.toPlainText();
    final selection = quillController.selection;
    if (selection.isCollapsed) {
      final offset = selection.baseOffset;
      if (offset > 0 && text.substring(offset - 1, offset) == '@') {
        showMentionPopup = true;
        notifyListeners();
      } else {
        showMentionPopup = false;
        notifyListeners();
      }
    } else {
      showMentionPopup = false;
      notifyListeners();
    }
  }

  void updatePopupPosition() {
    popuppOffset = const Offset(100, 100);
  }

  void insertMention(String name) {
    final selection = quillController.selection;
    final offset = selection.baseOffset;
    quillController.replaceText(
      offset - 1,
      1,
      '',
      TextSelection.collapsed(offset: offset - 1),
    );

    final mentionText = '@$name';
    final delta = Delta()
      ..retain(offset - 1)
      ..insert(mentionText, {
        'color': '#007AFF',
        'fontWeight': 'bold',
        'mention': true,
      });
    quillController.document.compose(delta, ChangeSource.local);

    quillController.updateSelection(
      TextSelection.collapsed(offset: offset - 1 + mentionText.length),
      ChangeSource.local,
    );
    showMentionPopup = false;
    notifyListeners();
  }

  Int64 getUserVer(Int64 id) {
    if (this.userVers.containsKey(id)) {
      return userVers[id]!.ver;
    } else {
      this.userVers[id] = UserVer(Int64(0), null);
      return userVers[id]!.ver;
    }
  }

  User? getUser(Int64 id) {
    if (userVers.containsKey(id) && userVers[id]?.user != null) {
      L.d("[IM] user exist");
    } else {
      L.d("[IM] user not exist, pull from sdk");
      Future.delayed(Duration.zero, () async {
        var user = await this.getUserInfo(id);
      });
    }
    return userVers[id]?.user;
  }

  Tenant? getTenant() {
    return loginUser.tenant;
  }

  void setUserId(Int64 id) {
    this.userId = id;
    Future.delayed(Duration.zero, () async {
      var req = GetUserByIdsRequest.create();
      req.ids.add(id);
      var result = await sdk.invokeAsync(
        Command.USER_GET_BY_IDS,
        req.writeToBuffer(),
      );
      if (result.data != null) {
        var resp = GetUserByIdsResponse.fromBuffer(result.data!);
        L.d("get user info: ${resp} ");
        for (var u in resp.users) {
          if (u.id == id) {
            this.user = u;
            this.avatar = u.avatar;
            notifyListeners();
          }
        }
      }
    });
  }

  Future<User?> getUserInfo(Int64 id) async {
    L.d("[IM] get user info start: ${id}");
    var user = userVers[id]?.user;
    if (user == null) {
      var req = GetUserByIdsRequest.create();
      req.ids.add(id);
      var result = await sdk.invokeAsync(
        Command.USER_GET_BY_IDS,
        req.writeToBuffer(),
      );
      if (result.data == null) {
        return null;
      }
      var resp = GetUserByIdsResponse.fromBuffer(result.data!);
      for (var u in resp.users) {
        if (userVers.containsKey(id)) {
          userVers[id]!.ver = u.version;
          userVers[id]!.user = u;
        } else {
          userVers[id] = UserVer(u.version, u);
        }

        if (u.id == id) {
          user = u;
        }

        if (u.id == userId) {
          avatar = u.avatar;
          notifyListeners();
        }
      }
    }
    L.d("[IM] get user info, ${user}");
    return user;
  }

  FeedModel? parseFeed(Entity entity, Int64 id) {
    var feed = entity.feeds[id];
    if (feed == null) {
      return null;
    }
    var model = FeedModel();
    model.feed = feed;
    model.chat = entity.chats[id];
    model.message = entity.messages[feed.referId];
    if (model.message != null) {
      model.rankTime = model.message!.updateTimeMs;
    } else {
      model.rankTime = model.feed.rankTimeMs;
    }
    return model;
  }

  List<Int64> updateFeedList() {
    var msgIds = <Int64>[];
    feedList.clear();
    entity.feeds.forEach((k, v) {
      msgIds.add(v.referId);
      var feed = parseFeed(entity, v.id);
      if (feed != null) {
        feedList.add(feed);
      }
    });
    feedList.sort((l, r) {
      if (l.rankTime > r.rankTime) {
        return -1;
      }
      return 1;
    });
    L.d("feed list: ${feedList}");
    notifyListeners();
    return msgIds;
  }

  void updateMessage(List<Int64>? referIds, List<Int64> curMsgIds) {
    L.d(
      "update message, referIds: ${referIds}, curMsgIds: ${curMsgIds}, : ${entity.messages.keys}",
    );
    if (referIds != null) {
      entity.messages.removeWhere((id, msg) {
        var keep = (referIds.contains(id) || msg.chatId == chatId);
        return !keep;
      });
    }

    if (curMsgIds.length > 0) {
      messagePosList.clear();
      entity.messages.forEach((id, msg) {
        if (msg.chatId == chatId) {
          messagePosList.add(
            MessageIndex(msg.id, msg.fromId, msg.pos, msg.createTimeMs),
          );
        }
      });
      L.d("messagePosList: ${messagePosList}");
      messagePosList.sort((l, r) {
        if (l.pos < r.pos) {
          return -1;
        }
        if (l.pos == r.pos && (l.createTime < r.createTime)) {
          return -1;
        }
        return 1;
      });
      notifyListeners();
      jumpToEnd();
    }
  }

  void jumpToEnd() {
    Future.delayed(Duration(milliseconds: 32), () async {
      if (msgCtrl.hasClients) {
        await msgCtrl.animateTo(
          msgCtrl.position.maxScrollExtent,
          duration: Duration(milliseconds: 120),
          curve: Curves.ease,
        );
      }
    });
  }

  void jumpToMessage(GlobalKey? key) {
    if (key == null) {
      return;
    }
    Future.delayed(Duration(milliseconds: 32), () async {
      final keyContext = key.currentContext;
      if (keyContext != null && keyContext.mounted) {
        final box = keyContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        msgCtrl.animateTo(
          position.dy - 100,
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        );
      }
    });
  }

  Future<Int64?> createP2PChat(Int64 userId) async {
    var req = CreateChatRequest.create();
    var chat = Chat.create();
    chat.chatType = ChatType.CHAT_P2P.value;
    chat.peerAId = this.userId;
    chat.peerBId = userId;
    req.chat = chat;
    var result = await sdk.invokeAsync(
      Command.CHAT_CREATE,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = CreateChatResponse.fromBuffer(result.data!);
      return resp.chatId;
    } else {
      return null;
    }
  }

  void enterChat(Int64 id) {
    L.d("enter chat ${id}, cur: ${chatId}");
    if (chatId != id) {
      messagePosList.clear();
      chatId = id;
      var chat = entity.chats[id];
      if (chat != null) {
        preloadMessage(chatId, chat.lastMessagePos, 30);
      } else {
        L.w("chat not exists: ${id}");
      }
    }
  }

  void onPushFeedList(List<int> data) {
    var push = PushFeedList.fromBuffer(data);
    L.d("sdk push feed list, ver: ${ver}, ${push}");
    mergeEntity(push.entity);
  }

  void onPushMessages(List<int> data) {
    var push = PushMessages.fromBuffer(data);
    L.d("sdk push message list, ${push}");
    mergeEntity(push.entity);
  }

  void onInit() {
    L.w("init im logic");

    sdk.regPushCallback(Command.PUSH_FEED_LIST.value, onPushFeedList);
    sdk.regPushCallback(Command.PUSH_MESSAGES.value, onPushMessages);
    ev.stream.where((e) => e == GlobalEvent.logined).listen((_) {
      Future.delayed(Duration.zero, () async {
        L.d("sdk logined, fetch feed");
        await fetchFeed();
      });
    });

    quillController.addListener(onTextChanged);
  }

  Future<void> fetchFeed() async {
    var req = PullFeedListRequest.create();
    req.cursor = Int64.MAX_VALUE;
    req.count = 50;
    var result = await sdk.invokeAsync(
      Command.FEED_GET_LIST,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = PullFeedListResponse.fromBuffer(result.data!);
      L.d("fetch feed from sdk success: $resp");
      mergeEntity(resp.entity);
    } else {
      L.d("pull feed list error");
    }
  }

  Chat? getChat(Int64 id) {
    return entity.chats[id];
  }

  void mergeEntity(Entity src) {
    var feedLen = src.feeds.length;
    var msgLen = src.messages.length;
    L.d(
      "merge entity, chatId: ${chatId}, feeds: ${src.feeds.keys}, messages: ${src.messages.keys}",
    );
    var currentMsgIds = <Int64>[];
    src.messages.forEach((id, msg) {
      if (msg.chatId == chatId) {
        currentMsgIds.add(msg.id);
      }
    });
    entity.mergeFromMessage(src);

    var msgIds = null;
    if (feedLen > 0) {
      msgIds = updateFeedList();
    }

    if (msgLen > 0) {
      updateMessage(msgIds, currentMsgIds);
    }
  }

  Future<void> loadMessage(Int64 chatId, int pos, int count) async {
    var chat = entity.chats[chatId];
    if (chat == null) {
      L.d("chat not exists: ${chatId}");
      return;
    }

    if (pos > chat!.lastMessagePos) {
      pos = chat!.lastMessagePos;
    }

    var req = GetMessageByRangeRequest.create();
    req.chatId = chatId;
    req.pos = pos;
    req.count = count;
    req.direct = Direct.BOTH.value;
    var result = await sdk.invokeAsync(
      Command.MESSAGE_GET_BY_RANGE,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = GetMessageByRangeResponse.fromBuffer(result.data!);
      L.d("get message from sdk success: ${resp}");
      mergeEntity(resp.entity);
    } else {
      L.e("load message error");
    }
  }

  Future<void> sendMessage(Int64 stashId, Message? message) async {
    var req = SendMessageRequest.create();
    req.clientId = stashId;
    if (message != null) {
      req.message = message;
    }
    var result = await sdk.invokeAsync(
      Command.MESSAGE_SEND,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = SendMessageResponse.fromBuffer(result.data!);
      L.d("send message success: ${resp}");
    }
  }

  Future<void> forwardMessage(Int64 targetChatId, Int64 sourceChatId,
      List<Int64> messageIds, {int forwardType = 0}) async {
    var req = ForwardMessageRequest.create();
    req.chatId = targetChatId;
    req.forwardType = forwardType;
    req.sourceChatId = sourceChatId;
    req.messageIds.addAll(messageIds);
    var result = await sdk.invokeAsync(
      Command.MESSAGE_FORWARD,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = ForwardMessageResponse.fromBuffer(result.data!);
      L.d("forward message success: ${resp}");
      mergeEntity(resp.entity);
    }
  }

  Future<Int64?> preSendMessage(Int64 chatId, Message message) async {
    var req = CreateMessageDraftRequest.create();
    req.chatId = chatId;
    req.message = message;
    var result = await sdk.invokeAsync(
      Command.MESSAGE_CREATE_DRAFT,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = CreateMessageDraftResponse.fromBuffer(result.data!);
      return resp.clientId;
    }
    return null;
  }

  void onSendMessage(String text) {
    var delta = quillController.document.toDelta();
    var summary = quillController.document.toPlainText();
    summary = summary.replaceAll("\u{2028}", " ").trim();
    var msgType = MessageType.RICH_TEXT_QUILL.value;
    if (delta.length == 1 && delta.first.isPlain) {
      msgType = MessageType.TEXT.value;
      text = delta.first.value.toString().trimRight();
    } else {
      text = jsonEncode(delta.toJson());
    }
    L.d("send message, text: ${text}, type: $msgType, summary: $summary");
    if (chatId == 0) {
      return;
    }

    var chat = entity.chats[chatId];
    if (chat != null) {
      Future.delayed(Duration.zero, () async {
        var message = Message.create();
        var inner = MessageText.create();

        inner.text = text;
        message.tpy = msgType;
        message.fromId = userId;
        message.content = inner.writeToBuffer();
        message.summary = summary;
        message.chatId = chatId;

        // 引用回复时填充 ref_* 字段
        if (replyTarget != null) {
          message.refMessageId = replyTarget!.id;
          message.refData = MessageReference.create()
            ..chatId = replyTarget!.chatId
            ..content = replyTarget!.content
            ..summary = replyTarget!.summary
            ..tpy = replyTarget!.tpy
            ..senderName = replyTarget!.tpy == MessageType.SYSTEM.value
                ? '系统'
                : (getUser(replyTarget!.fromId)?.name ?? '');
        }

        var stashId = await preSendMessage(chatId, message);
        if (stashId != null) {
          await sendMessage(stashId, message);
        }
        clearReply();
      });
      imInputCtrl.clear();
    } else {
      L.w("chat not exists");
    }
  }

  Future<void> recallMessage(Int64 messageId) async {
    var req = RecallMessageRequest.create();
    req.id = messageId;
    await sdk.invokeAsync(Command.MESSAGE_RECALL, req.writeToBuffer());
  }

  Future<void> favoriteMessage(Message msg) async {
    var fav = Favorite.create();
    fav.tpy = msg.tpy;
    fav.message = msg;
    var req = FavoriteAddRequest.create();
    req.favorite = fav;
    await sdk.invokeAsync(Command.FAVORITE_ADD, req.writeToBuffer());
  }

  void preloadMessage(Int64 chatId, int pos, int count) {
    if (chatId == 0) {
      return;
    }
    Future.delayed(Duration.zero, () async {
      L.d("start load message, ${chatId}, ${pos}, ${count}");
      await loadMessage(chatId, pos, count);
    });
  }

  Future<GetDeptResponse?> getDeptInfo(Int64 id) async {
    var req = GetDeptRequest.create();
    req.id = id;
    if (id == 0) {
      L.d("fallback to loginUser: ${loginUser}");
      req.id = loginUser.tenant.rootDepartmentId;
      req.tenantId = loginUser.tenant.id;
    }

    L.d("get dept info, req: ${req}");

    var result = await sdk.invokeAsync(
      Command.DEPT_GET_BY_ID,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = GetDeptResponse.fromBuffer(result.data!);
      L.d("get dept info ok, resp: ${resp} ");
      return resp;
    } else {
      L.d("get dept info error");
      return null;
    }
  }

  Future<Int64?> createChat(
    String name,
    bool p2p,
    Int64 peer,
    List<Int64> ids,
  ) async {
    var req = CreateChatRequest.create();
    req.chat = Chat.create();
    req.chat.name = name;
    req.chat.memberIds.addAll(ids);
    if (p2p) {
      req.chat.chatType = ChatType.CHAT_P2P.value;
    } else {
      req.chat.chatType = ChatType.CHAT_GROUP.value;
    }
    var result = await sdk.invokeAsync(
      Command.CHAT_CREATE,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = CreateChatResponse.fromBuffer(result.data!);
      L.d("create chat success, ${resp}");
      return resp.chatId;
    } else {
      L.e("create chat error");
      return null;
    }
  }

  // ─── M2: 群公告 ─────────────────────────────────────────────────

  Future<void> setAnnouncement(Int64 chatId, String title, int tpy, List<int> body, String summary) async {
    var req = SetAnnouncementRequest.create();
    req.chatId = chatId;
    req.title = title;
    req.tpy = tpy;
    req.body = body;
    req.summary = summary;
    var result = await sdk.invokeAsync(
      Command.CHAT_SET_ANNOUNCEMENT,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = SetAnnouncementResponse.fromBuffer(result.data!);
      mergeEntity(resp.entities);
    }
  }

  Future<void> deleteAnnouncement(Int64 chatId) async {
    var req = DeleteAnnouncementRequest.create();
    req.chatId = chatId;
    var result = await sdk.invokeAsync(
      Command.CHAT_DELETE_ANNOUNCEMENT,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = DeleteAnnouncementResponse.fromBuffer(result.data!);
      mergeEntity(resp.entities);
    }
  }

  // ─── M2: 群资料更新 ─────────────────────────────────────────────

  Future<void> updateChat(Int64 chatId, {String? name, String? avatar, String? description, Int64? ownerId, List<Int64>? adminIdsAdd, List<Int64>? adminIdsRemove, int? joinMode}) async {
    var req = UpdateChatRequest.create();
    req.chatId = chatId;
    if (name != null) req.name = name;
    if (avatar != null) req.avatar = avatar;
    if (description != null) req.description = description;
    if (ownerId != null) req.ownerId = ownerId;
    if (adminIdsAdd != null) req.adminIdsAdd.addAll(adminIdsAdd);
    if (adminIdsRemove != null) req.adminIdsRemove.addAll(adminIdsRemove);
    if (joinMode != null) req.joinMode = joinMode;
    var result = await sdk.invokeAsync(
      Command.CHAT_UPDATE,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = UpdateChatResponse.fromBuffer(result.data!);
      mergeEntity(resp.entities);
    }
  }

  // ─── M2: 禁言 ───────────────────────────────────────────────────

  Future<void> muteMember(Int64 chatId, Int64 memberId, Int64 untilMs) async {
    var req = MuteMemberRequest.create();
    req.chatId = chatId;
    req.memberId = memberId;
    req.untilMs = untilMs;
    await sdk.invokeAsync(Command.CHAT_MUTE_MEMBER, req.writeToBuffer());
  }

  Future<void> globalMute(Int64 chatId, Int64 untilMs) async {
    var req = GlobalMuteRequest.create();
    req.chatId = chatId;
    req.untilMs = untilMs;
    await sdk.invokeAsync(Command.CHAT_GLOBAL_MUTE, req.writeToBuffer());
  }

  // ─── M2: 邀请链接 ───────────────────────────────────────────────

  Future<String?> createInviteLink(Int64 chatId, {Int64 expiresAt = Int64.ZERO, int maxUses = 0}) async {
    var req = InviteLinkCreateRequest.create();
    req.chatId = chatId;
    req.expiresAt = expiresAt;
    req.maxUses = maxUses;
    var result = await sdk.invokeAsync(
      Command.CHAT_INVITE_LINK_CREATE,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = InviteLinkCreateResponse.fromBuffer(result.data!);
      return resp.code;
    }
    return null;
  }

  Future<InviteLinkJoinResponse?> joinByInviteLink(String code) async {
    var req = InviteLinkJoinRequest.create();
    req.code = code;
    var result = await sdk.invokeAsync(
      Command.CHAT_INVITE_LINK_JOIN,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = InviteLinkJoinResponse.fromBuffer(result.data!);
      mergeEntity(Entity()..chats[resp.chatId] = resp.chat);
      return resp;
    }
    return null;
  }

  Future<void> revokeInviteLink(String code) async {
    var req = InviteLinkRevokeRequest.create();
    req.code = code;
    await sdk.invokeAsync(Command.CHAT_INVITE_LINK_REVOKE, req.writeToBuffer());
  }

  // ─── M2: 加群申请 ───────────────────────────────────────────────

  Future<void> createJoinRequest(Int64 chatId) async {
    var req = JoinRequestCreateRequest.create();
    req.chatId = chatId;
    await sdk.invokeAsync(Command.CHAT_JOIN_REQUEST_CREATE, req.writeToBuffer());
  }

  Future<void> approveJoinRequest(Int64 requestId) async {
    var req = JoinRequestApproveRequest.create();
    req.requestId = requestId;
    await sdk.invokeAsync(Command.CHAT_JOIN_REQUEST_APPROVE, req.writeToBuffer());
  }

  Future<void> rejectJoinRequest(Int64 requestId) async {
    var req = JoinRequestRejectRequest.create();
    req.requestId = requestId;
    await sdk.invokeAsync(Command.CHAT_JOIN_REQUEST_REJECT, req.writeToBuffer());
  }

  Future<JoinRequestListResponse?> listJoinRequests(Int64 chatId, {int status = 0, int page = 1, int pageSize = 20}) async {
    var req = JoinRequestListRequest.create();
    req.chatId = chatId;
    req.status = status;
    req.page = page;
    req.pageSize = pageSize;
    var result = await sdk.invokeAsync(
      Command.CHAT_JOIN_REQUEST_LIST,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      return JoinRequestListResponse.fromBuffer(result.data!);
    }
    return null;
  }

  // ─── M2: 成员列表 ───────────────────────────────────────────────

  Future<GetMembersResponse?> getMembers(Int64 chatId, {int page = 1, int pageSize = 50, String keyword = ''}) async {
    var req = GetMembersRequest.create();
    req.chatId = chatId;
    req.page = page;
    req.pageSize = pageSize;
    req.keyword = keyword;
    var result = await sdk.invokeAsync(
      Command.CHAT_GET_MEMBERS,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      return GetMembersResponse.fromBuffer(result.data!);
    }
    return null;
  }

  void logout(GoRouter router) {
    Future.delayed(Duration.zero, () async {
      L.d("logout user");
      await DataPersistence.removeAccount();
      router.pop();
      AppNavigator.startLogin(router);
      await sdk.logout();
    });
  }
}

class FeedModel {
  Int64 id = Int64(0);
  Int64 rankTime = Int64(0);
  late Feed feed;
  late Chat? chat;
  late Message? message;

}

class MessageIndex {
  Int64 id = Int64(0);
  int pos = 0;
  Int64 createTime = Int64(0);
  Int64 fromId = Int64(0);
  var globalKey = GlobalKey();

  MessageIndex(Int64 id, Int64 fromId, int pos, Int64 createTime)
    : id = id,
      fromId = fromId,
      pos = pos,
      createTime = createTime;
}
