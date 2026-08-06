import 'dart:async';
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
import 'package:buzzing/models/idl/pin.pb.dart';
import 'package:buzzing/models/idl/thread.pb.dart';
import 'package:buzzing/models/idl/typing.pb.dart';
import 'package:buzzing/models/idl/presence.pb.dart';
import 'package:buzzing/models/idl/search.pb.dart';
import 'package:buzzing/models/idl/translate.pb.dart';
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
  String _lastText = '';
  Offset popuppOffset = Offset.zero;
  final LayerLink layerLink = LayerLink();
  final List<({Int64 id, String name})> mentionCandidates = [];
  var typingUsers = <Int64, ({String name, Int64 expireAtMs})>{};
  var presenceMap = <Int64, ({int status, String statusText, Int64 lastSeenMs})>{};
  var pinnedMessages = <Message>[];
  var translationCache = <Int64, Map<String, String>>{}; // messageId -> (targetLang -> text)

  var avatar = "";

  /// 全局总未读数：SDK 本地聚合各会话未读（refer_badge - read_badge），客户端只读不计算
  var totalUnread = 0;

  /// 全局未读数变化回调（用于原生 app badge 等），由应用层注入
  void Function(int count)? onBadgeChanged;

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
    // 仅在 mention 弹窗开闭状态真正变化时才通知，避免光标移动/聚焦等
    // 纯 selection 变化触发下游（如消息列表）无谓的全量重建。
    final wantPopup = selection.isCollapsed &&
        selection.baseOffset > 0 &&
        selection.baseOffset <= text.length &&
        text.substring(selection.baseOffset - 1, selection.baseOffset) == '@';
    if (wantPopup != showMentionPopup) {
      showMentionPopup = wantPopup;
      notifyListeners();
    }
    // 文本真正变化时才发送 typing 信号（过滤纯光标移动）
    if (text != _lastText) {
      _lastText = text;
      sendTyping(chatId);
    }
  }

  void updatePopupPosition() {
    popuppOffset = const Offset(100, 100);
  }

  Future<void> loadMentionCandidates() async {
    var chat = entity.chats[chatId];
    if (chat == null) return;
    if (chat.chatType == ChatType.CHAT_GROUP.value) {
      var resp = await getMembers(chatId, pageSize: 200);
      if (resp != null) {
        mentionCandidates.clear();
        if (chat.chatType == ChatType.CHAT_GROUP.value) {
          mentionCandidates.add((id: Int64(0), name: '所有成员'));
        }
        for (var m in resp.members) {
          mentionCandidates.add((id: m.userId, name: m.name ?? ''));
        }
        notifyListeners();
      }
    } else {
      // P2P: the other user
      var peerId = chat.peerAId == userId ? chat.peerBId : chat.peerAId;
      var u = await getUserInfo(peerId);
      if (u != null) {
        mentionCandidates.clear();
        mentionCandidates.add((id: u.id, name: u.name));
        notifyListeners();
      }
    }
  }

  void insertMention(String name, {Int64 mentionId = Int64.ZERO}) {
    final selection = quillController.selection;
    final offset = selection.baseOffset;
    quillController.replaceText(
      offset - 1,
      1,
      '',
      TextSelection.collapsed(offset: offset - 1),
    );

    final mentionText = '@$name';
    final attrs = <String, dynamic>{
      'color': '#007AFF',
      'fontWeight': 'bold',
      'mention': true,
    };
    if (mentionId > Int64(0)) {
      attrs['mentionId'] = mentionId.toInt().toString();
    }
    final delta = Delta()
      ..retain(offset - 1)
      ..insert(mentionText, attrs);
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
      L.d("[IM] user exist: ${id}");
    } else {
      L.d("[IM] user not exist, pull from sdk");
      Future.delayed(Duration.zero, () async {
        var user = await this.getUserInfo(id);
      });
    }
    return userVers[id]?.user;
  }

  // P2P 会话对方 id（memberIds 中非自己的那个）
  Int64 peerIdOf(Chat chat) {
    return chat.peerAId == userId ? chat.peerBId : chat.peerAId;
  }

  // 会话展示名：群聊用群名；P2P 无 name，取对方昵称
  String chatDisplayName(Chat? chat, {String fallback = ''}) {
    if (chat == null) return fallback;
    if (chat.chatType == 2) {
      return chat.name.isNotEmpty ? chat.name : fallback;
    }
    if (chat.name.isNotEmpty) return chat.name;
    final peer = getUser(peerIdOf(chat));
    if (peer != null && peer.name.isNotEmpty) return peer.name;
    return fallback;
  }

  Tenant? getTenant() {
    return loginUser.tenant;
  }

  /// 应用登录身份：登录选择身份成功后、或启动自动登录后调用。
  /// ImController 是全局单例（非 autoDispose），必须显式刷新身份，
  /// 否则 A 退出后 B 登录会继续沿用 A 的用户数据。
  void applyLoginUser(LoginUser user) {
    L.w("apply login user: uid=${user.user.id}, tenant=${user.tenant.id}");
    loginUser = user;
    userId = user.user.id;
    avatar = user.user.avatar;
    setUserId(user.user.id);
    notifyListeners();
    Future.delayed(Duration.zero, () => fetchFeed());
  }

  /// 清空所有与登录用户绑定的内存状态（登出时调用）。
  /// 注意：ImController 为全局单例，这里不清理会导致下一个用户看到上一个用户的数据。
  void reset() {
    L.w("reset im controller state");
    // 身份
    loginUser = LoginUser.create();
    userId = Int64(0);
    user = User.create();
    avatar = "";

    // 会话与消息
    entity = Entity.create();
    feedList = [];
    messagePosList = [];
    userVers = {};
    chatId = Int64(0);
    ver = 0;
    totalUnread = 0;
    onBadgeChanged?.call(0);

    // 输入区
    replyTarget = null;
    imInputCtrl.clear();
    // 先释放编辑器焦点，避免登出时 QuillEditor 反挂载过程中
    // 触发 FocusNode 通知访问已 deactivated 的元素
    focusNode.unfocus();
    quillController.document = Document();
    showMentionPopup = false;
    mentionCandidates.clear();

    // 各类缓存
    typingUsers = {};
    presenceMap = {};
    pinnedMessages = [];
    translationCache = {};

    // thread / 群面板
    threadRootMessage = null;
    threadReplies = [];
    isThreadPanelOpen = false;
    isGroupProfileOpen = false;
    isGroupMemberListOpen = false;
    isGroupEditOpen = false;
    isGroupManageOpen = false;
    isAnnouncementOpen = false;

    // 会话内搜索
    chatSearchResults = [];
    chatSearchKeyword = '';
    chatSearchIndex = 0;
    chatSearchVisible = false;

    notifyListeners();
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
      // Skip dissolved/deleted feeds (status >= DISMISS_PENDING)
      if (v.status >= EntityStatus.DISMISS_PENDING.value) {
        return;
      }
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
        // 跳过公告消息（公告 id == chatId）
        if (msg.chatId == chatId && msg.id != chatId) {
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
isGroupProfileOpen = false;
    isGroupMemberListOpen = false;
    isGroupEditOpen = false;
    isGroupManageOpen = false;
    isAnnouncementOpen = false;
      isThreadPanelOpen = false;
      threadRootMessage = null;
      messagePosList.clear();
      chatId = id;
      var chat = entity.chats[id];
      if (chat != null) {
        preloadMessage(chatId, chat.lastMessagePos, 30);
        loadMentionCandidates();
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
    var entity = push.entity;
    var annDetail = entity?.messages.values
        .where((m) => m.tpy == MessageType.ANNOUNCEMENT.value)
        .map((m) => "id=${m.id} status=${m.status} chatId=${m.chatId}")
        .toList();
    L.d(
        "sdk push message list, chatId=${chatId}, msgCnt=${entity?.messages.length}, "
        "announcement=${annDetail}, all=${push}");
    mergeEntity(push.entity);
  }

  StreamSubscription<GlobalEvent>? _loginedSub;
  var _disposed = false;

  void onInit() {
    L.w("init im logic");

    sdk.regPushCallback(Command.PUSH_FEED_LIST.value, onPushFeedList);
    sdk.regPushCallback(Command.PUSH_MESSAGES.value, onPushMessages);
    sdk.regPushCallback(Command.PUSH_TYPING.value, onPushTyping);
    sdk.regPushCallback(Command.PUSH_PRESENCE.value, onPushPresence);
    _loginedSub = ev.stream.where((e) => e == GlobalEvent.logined).listen((_) {
      Future.delayed(Duration.zero, () async {
        L.d("sdk logined, fetch feed");
        await fetchFeed();
      });
    });

    quillController.addListener(onTextChanged);
  }

  @override
  void notifyListeners() {
    // 登出后 provider 会被 invalidate，此时可能仍有在途异步回调；
    // 对已释放实例静默忽略通知，避免抛出 "used after dispose"
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    L.w("dispose im logic");
    _disposed = true;
    // provider 被 invalidate 时释放订阅，避免旧实例继续响应事件造成数据串号
    _loginedSub?.cancel();
    _loginedSub = null;
    quillController.removeListener(onTextChanged);
    super.dispose();
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
    var sideLen = src.readstates.length + src.reactions.length;
    var chatLen = src.chats.length;
    L.d(
      "merge entity, chatId: ${chatId}, feeds: ${src.feeds.keys}, chats: ${src.chats.keys}, messages: ${src.messages.keys}, readstates: ${src.readstates.keys}, reactions: ${src.reactions.keys}",
    );
    var currentMsgIds = <Int64>[];
    src.messages.forEach((id, msg) {
      if (msg.chatId == chatId) {
        currentMsgIds.add(msg.id);
      }
    });
    entity.mergeFromMessage(src);

    // 排重：确认消息（client_id != 0 且 id 已变为服务端新 id）到达时，移除对应的
    // 本地 stash（id == client_id），避免同一消息同屏展示两条。
    src.messages.forEach((id, msg) {
      if (msg.clientId.toInt() != 0 && msg.clientId != msg.id) {
        final stashId = msg.clientId;
        if (entity.messages.containsKey(stashId)) {
          entity.messages.remove(stashId);
        }
      }
    });

    var msgIds = null;
    if (feedLen > 0) {
      msgIds = updateFeedList();
      // 会话未读变化时，同步刷新全局总未读数
      refreshTotalUnread();
    } else if (chatLen > 0) {
      // chat-only 变更（改群名/描述/权限等）：更新会话面板标题与 feed 上的群名。
      // feedList 里的 FeedModel 持有旧的 chat 引用，需重建 feed 列表后通知刷新。
      updateFeedList();
    }

    if (msgLen > 0) {
      updateMessage(msgIds, currentMsgIds);
    } else if (sideLen > 0) {
      // 仅已读/表情独立实体变更：刷新消息行，重读 readstates / reactions map
      notifyListeners();
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
      if (resp.hasEntity()) {
        mergeEntity(resp.entity);
      }
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
    // 从 delta 中提取 @mention 的 userId
    var atUserIds = <Int64>[];
    try {
      var ops = delta.toJson();
      for (var op in ops) {
        if (op is Map && op['attributes'] is Map) {
          var attrs = op['attributes'] as Map;
          if (attrs['mention'] == true && attrs['mentionId'] != null) {
            var id = Int64(int.tryParse(attrs['mentionId'].toString()) ?? 0);
            if (id > Int64(0) && !atUserIds.contains(id)) {
              atUserIds.add(id);
            }
          }
        }
      }
    } catch (_) {}
    L.d("send message, text: ${text}, type: $msgType, summary: $summary, atUserIds: $atUserIds");
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
        message.atUserIds.addAll(atUserIds);

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
      quillController.clear();
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
      if (resp.hasEntities()) {
        mergeEntity(resp.entities);
      }
      return resp.chatId;
    } else {
      L.e("create chat error");
      return null;
    }
  }

  Future<void> topFeed(Int64 feedId) async {
    var req = SetFeedTopRequest(id: feedId, top: true);
    await sdk.invokeAsync(Command.FEED_SET_TOP, req.writeToBuffer());
  }

  Future<void> markFeedRead(Int64 feedId) async {
    var req = ActiveFeedRequest(id: feedId);
    await sdk.invokeAsync(Command.FEED_ACTIVE, req.writeToBuffer());
  }

  /// 上屏已读上报：会话已读位置（maxPos + 透传 badgeCount）与消息级已读（可见非本人精确 id）同入口上报，
  /// 服务端按两套独立语义拆分（见 data_sync §6.2 / §6.3）。客户端不产数据，只透传服务端生成的 badge_count。
  /// 刷新全局总未读数：向 SDK 请求聚合未读数（FEED_GET_BADGE_COUNT），
  /// 变化时通知 UI 并透传应用层（原生 badge）。SDK 本地算好直接返回，客户端不计算。
  Future<void> refreshTotalUnread() async {
    try {
      final resp = await sdk.invokeAsync(Command.FEED_GET_BADGE_COUNT, Uint8List(0));
      if (resp.data == null) return;
      final badge = GetFeedBadgeCountResponse.fromBuffer(resp.data!);
      final count = badge.count;
      if (count != totalUnread) {
        totalUnread = count;
        notifyListeners();
        onBadgeChanged?.call(count);
      }
    } catch (e) {
      L.e("refresh total unread failed: $e");
    }
  }

  Future<void> reportSeen(
    Int64 chatId,
    List<Int64> seenMessageIds,
    int maxPos,
    int maxBadgeCount,
  ) async {
    if (chatId == Int64.ZERO) return;
    var req = MessageReadRequest.create();
    req.chatId = chatId;
    req.maxPos = maxPos;
    req.maxBadgeCount = maxBadgeCount;
    req.messageIds.addAll(seenMessageIds);
    L.d(
      "report seen: chat=$chatId maxPos=$maxPos maxBadge=$maxBadgeCount "
      "ids=${seenMessageIds.length}",
    );
    await sdk.invokeAsync(Command.MESSAGE_READ, req.writeToBuffer());
  }

  Future<void> muteFeed(Int64 feedId) async {
    var req = SetFeedMuteRequest(id: feedId, mute: true);
    await sdk.invokeAsync(Command.FEED_SET_MUTE, req.writeToBuffer());
  }

  // ─── M3: Pin ─────────────────────────────────────────────────

  Future<void> pinMessage(Int64 chatId, Int64 messageId) async {
    var req = PinMessageRequest(chatId: chatId, messageId: messageId);
    var result = await sdk.invokeAsync(
      Command.CHAT_PIN_MESSAGE,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = PinMessageResponse.fromBuffer(result.data!);
      mergeEntity(resp.entities);
      await loadPinnedMessages();
    }
  }

  Future<void> unpinMessage(Int64 chatId, Int64 messageId) async {
    var req = UnpinMessageRequest(chatId: chatId, messageId: messageId);
    var result = await sdk.invokeAsync(
      Command.CHAT_UNPIN_MESSAGE,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = UnpinMessageResponse.fromBuffer(result.data!);
      mergeEntity(resp.entities);
      await loadPinnedMessages();
    }
  }

  Future<void> loadPinnedMessages() async {
    if (chatId == Int64(0)) return;
    var req = GetPinnedMessagesRequest(chatId: chatId);
    var result = await sdk.invokeAsync(
      Command.CHAT_GET_PINNED_MESSAGES,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = GetPinnedMessagesResponse.fromBuffer(result.data!);
      pinnedMessages = resp.messages.toList();
      notifyListeners();
    }
  }

  // ─── M5-A: Voice ─────────────────────────────────────────────

  Future<void> transcribeVoice(Int64 messageId, Int64 chatId) async {
    var req = TranscribeVoiceRequest(messageId: messageId, chatId: chatId);
    var result = await sdk.invokeAsync(
      Command.VOICE_TRANSCRIBE,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = TranscribeVoiceResponse.fromBuffer(result.data!);
      // update local message content's transcription
      var msg = entity.messages[messageId];
      if (msg != null) {
        try {
          var voice = VoiceContent.fromBuffer(msg.content);
          voice.transcription = resp.transcription;
          voice.transcriptionStatus = 2;
          msg.content = voice.writeToBuffer();
          msg.summary = '[语音] ${resp.transcription}';
          entity.messages[messageId] = msg;
          notifyListeners();
        } catch (_) {}
      }
    }
  }

  // ─── M5-F: Translate ──────────────────────────────────────────

  Future<String?> translateMessage(Int64 messageId, Int64 chatId, String targetLang) async {
    // check cache
    final cached = translationCache[messageId]?[targetLang];
    if (cached != null) return cached;

    try {
      var req = TranslateMessageRequest(messageId: messageId, chatId: chatId, targetLang: targetLang);
      var result = await sdk.invokeAsync(
        Command.TRANSLATE_MESSAGE,
        req.writeToBuffer(),
      );
      var resp = TranslateMessageResponse.fromBuffer(result.data!);
      translationCache[messageId] ??= {};
      translationCache[messageId]![targetLang] = resp.translatedText;
      return resp.translatedText;
    } catch (e) {
      L.e("translate error: $e");
      return null;
    }
  }

  // ─── M3: Thread ────────────────────────────────────────────────

  Future<List<Message>> getThread(Int64 chatId, Int64 rootMessageId, {int page = 1, int pageSize = 50}) async {
    var req = GetThreadRequest(chatId: chatId, rootMessageId: rootMessageId, page: page, pageSize: pageSize);
    var result = await sdk.invokeAsync(
      Command.MESSAGE_GET_THREAD,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = GetThreadResponse.fromBuffer(result.data!);
      for (var msg in resp.messages) {
        entity.messages[msg.id] = msg;
      }
      notifyListeners();
      return resp.messages.toList();
    }
    return [];
  }

  // 当前打开的 thread 信息
  Message? threadRootMessage;
  List<Message> threadReplies = [];
  var isThreadPanelOpen = false;

  // 群设置侧边面板（桌面端从右侧展开）
  var isGroupProfileOpen = false;

  // 群成员列表作为群资料面板的二级页面（仅桌面端）
  var isGroupMemberListOpen = false;

  // 群信息编辑作为群资料面板的二级页面（仅桌面端）
  var isGroupEditOpen = false;

  // 群管理作为群资料面板的二级页面（仅桌面端）
  var isGroupManageOpen = false;

  // 入群申请作为群资料面板的二级页面（仅桌面端）
  var isGroupJoinRequestsOpen = false;

  // 群公告查看/编辑覆盖层（覆盖消息列表区域，含消息输入框）
  var isAnnouncementOpen = false;

  void openGroupProfile() {
    isGroupProfileOpen = true;
    notifyListeners();
  }

  void closeGroupProfile() {
    isGroupProfileOpen = false;
    isGroupMemberListOpen = false;
    isGroupEditOpen = false;
    isGroupManageOpen = false;
    isGroupJoinRequestsOpen = false;
    notifyListeners();
  }

  void openAnnouncement() {
    isAnnouncementOpen = true;
    notifyListeners();
  }

  void closeAnnouncement() {
    isAnnouncementOpen = false;
    notifyListeners();
  }

  void openGroupMemberList() {
    isGroupMemberListOpen = true;
    notifyListeners();
  }

  void closeGroupMemberList() {
    isGroupMemberListOpen = false;
    notifyListeners();
  }

  void openGroupEdit() {
    isGroupEditOpen = true;
    notifyListeners();
  }

  void closeGroupEdit() {
    isGroupEditOpen = false;
    notifyListeners();
  }

  void openGroupManage() {
    isGroupManageOpen = true;
    notifyListeners();
  }

  void closeGroupManage() {
    isGroupManageOpen = false;
    notifyListeners();
  }

  void openGroupJoinRequests() {
    isGroupJoinRequestsOpen = true;
    notifyListeners();
  }

  void closeGroupJoinRequests() {
    isGroupJoinRequestsOpen = false;
    notifyListeners();
  }

  void openThread(Message rootMsg) {
    threadRootMessage = rootMsg;
    threadReplies = [];
    isThreadPanelOpen = true;
    notifyListeners();
    Future.delayed(Duration.zero, () async {
      var replies = await getThread(chatId, rootMsg.id);
      threadReplies = replies;
      notifyListeners();
    });
  }

  void closeThread() {
    isThreadPanelOpen = false;
    threadRootMessage = null;
    threadReplies = [];
    notifyListeners();
  }

  Future<void> sendThreadReply(String text) async {
    if (threadRootMessage == null || chatId == Int64(0)) return;
    var message = Message.create();
    var inner = MessageText.create();
    inner.text = text;
    message.tpy = MessageType.TEXT.value;
    message.fromId = userId;
    message.content = inner.writeToBuffer();
    message.summary = text;
    message.chatId = chatId;
    message.threadRootId = threadRootMessage!.id;
    var stashId = await preSendMessage(chatId, message);
    if (stashId != null) {
      await sendMessage(stashId, message);
    }
  }

  // ─── M3: 已读详情 ─────────────────────────────────────────────

  Future<GetReadMembersResponse?> getReadMembers(Int64 chatId, Int64 messageId) async {
    var req = GetReadMembersRequest(chatId: chatId, messageId: messageId);
    var result = await sdk.invokeAsync(
      Command.MESSAGE_GET_READ_MEMBERS,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      return GetReadMembersResponse.fromBuffer(result.data!);
    }
    return null;
  }

  // ─── M3: Typing ────────────────────────────────────────────────

  DateTime _lastTypingSent = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> sendTyping(Int64 chatId) async {
    var now = DateTime.now();
    if (now.difference(_lastTypingSent).inMilliseconds < 3000) return;
    _lastTypingSent = now;
    var req = TypingRequest(chatId: chatId);
    sdk.invokeWithoutAck(Command.TYPING, req.writeToBuffer());
  }

  void onPushTyping(List<int> data) {
    var push = PushTyping.fromBuffer(data);
    L.d("push typing: chatId=${push.chatId}, userId=${push.userId}");
    if (push.chatId == chatId && push.userId != userId) {
      typingUsers[push.userId] = (name: push.userName, expireAtMs: push.expireAtMs);
      notifyListeners();
      Future.delayed(Duration(seconds: 5), () {
        typingUsers.remove(push.userId);
        notifyListeners();
      });
    }
  }

  // ─── M3: Presence ──────────────────────────────────────────────

  Future<void> updatePresence(int status, {String statusText = ''}) async {
    var req = PresenceUpdateRequest(status: status, statusText: statusText);
    await sdk.invokeAsync(Command.USER_PRESENCE_UPDATE, req.writeToBuffer());
  }

  void onPushPresence(List<int> data) {
    var push = PushPresence.fromBuffer(data);
    L.d("push presence: userId=${push.userId}, status=${push.status}");
    presenceMap[push.userId] = (status: push.status, statusText: push.statusText, lastSeenMs: push.lastSeenMs);
    notifyListeners();
  }

  Future<void> subscribePresence(List<Int64> userIds) async {
    var req = PresenceSubscribeRequest(userIds: userIds);
    await sdk.invokeAsync(Command.USER_PRESENCE_SUBSCRIBE, req.writeToBuffer());
  }

  // ─── M4: 全局搜索 ──────────────────────────────────────────────

  // ─── M4: 会话内搜索 ────────────────────────────────────────────
  var chatSearchResults = <MessageSearchResult>[];
  var chatSearchKeyword = '';
  var chatSearchIndex = 0;
  var chatSearchVisible = false;

  Future<void> doChatSearch(Int64 chatId, String keyword) async {
    if (keyword.trim().isEmpty) {
      chatSearchResults = [];
      chatSearchKeyword = '';
      chatSearchIndex = 0;
      notifyListeners();
      return;
    }
    chatSearchKeyword = keyword;
    chatSearchIndex = 0;
    final resp = await searchMessages(keyword, chatId: chatId, pageSize: 50);
    chatSearchResults = resp.results;
    notifyListeners();

    if (resp.results.isNotEmpty) {
      _jumpToChatSearchResult(0);
    }
  }

  void nextChatSearchResult() {
    if (chatSearchResults.isEmpty) return;
    chatSearchIndex = (chatSearchIndex + 1) % chatSearchResults.length;
    _jumpToChatSearchResult(chatSearchIndex);
    notifyListeners();
  }

  void prevChatSearchResult() {
    if (chatSearchResults.isEmpty) return;
    chatSearchIndex = (chatSearchIndex - 1 + chatSearchResults.length) % chatSearchResults.length;
    _jumpToChatSearchResult(chatSearchIndex);
    notifyListeners();
  }

  void _jumpToChatSearchResult(int index) {
    if (index < 0 || index >= chatSearchResults.length) return;
    final msg = chatSearchResults[index].message;
    if (msg == null) return;
    final match = messagePosList.where((m) => m.id == msg.id).firstOrNull;
    if (match != null) {
      jumpToMessage(match.globalKey);
    }
  }

  void toggleChatSearch() {
    chatSearchVisible = !chatSearchVisible;
    if (!chatSearchVisible) {
      chatSearchKeyword = '';
      chatSearchResults = [];
      chatSearchIndex = 0;
    }
    notifyListeners();
  }

  Future<SearchMessagesResponse> searchMessages(
    String keyword, {
    int page = 1,
    int pageSize = 20,
    Int64? chatId,
    Int64? fromId,
    int? msgType,
    Int64? timeStartMs,
    Int64? timeEndMs,
  }) async {
    var filter = SearchFilter(
      chatId: chatId ?? Int64(0),
      fromId: fromId ?? Int64(0),
      msgType: msgType ?? 0,
      timeStartMs: timeStartMs ?? Int64(0),
      timeEndMs: timeEndMs ?? Int64(0),
    );
    var req = SearchRequest(
      keyword: keyword,
      page: page,
      pageSize: pageSize,
      filter: filter,
    );
    var result = await sdk.invokeAsync(Command.SEARCH_MESSAGE, req.writeToBuffer());
    if (result.data != null) {
      return SearchMessagesResponse.fromBuffer(result.data!);
    }
    return SearchMessagesResponse();
  }

  Future<SearchChatsResponse> searchChats(String keyword, {int page = 1, int pageSize = 20}) async {
    var req = SearchRequest(keyword: keyword, page: page, pageSize: pageSize);
    var result = await sdk.invokeAsync(Command.SEARCH_CHAT, req.writeToBuffer());
    if (result.data != null) {
      return SearchChatsResponse.fromBuffer(result.data!);
    }
    return SearchChatsResponse();
  }

  Future<SearchUsersResponse> searchUsers(String keyword, {int page = 1, int pageSize = 20}) async {
    var req = SearchRequest(keyword: keyword, page: page, pageSize: pageSize);
    var result = await sdk.invokeAsync(Command.SEARCH_USER, req.writeToBuffer());
    if (result.data != null) {
      return SearchUsersResponse.fromBuffer(result.data!);
    }
    return SearchUsersResponse();
  }

  Future<SearchFilesResponse> searchFiles(String keyword, {int page = 1, int pageSize = 20}) async {
    var req = SearchRequest(keyword: keyword, page: page, pageSize: pageSize);
    var result = await sdk.invokeAsync(Command.SEARCH_FILES, req.writeToBuffer());
    if (result.data != null) {
      return SearchFilesResponse.fromBuffer(result.data!);
    }
    return SearchFilesResponse();
  }

  Future<GlobalSearchResponse> globalSearch(String keyword, {int page = 1, int pageSize = 5, List<String>? types}) async {
    var req = GlobalSearchRequest(keyword: keyword, page: page, pageSize: pageSize);
    if (types != null) req.types.addAll(types);
    var result = await sdk.invokeAsync(Command.GLOBAL_SEARCH, req.writeToBuffer());
    if (result.data != null) {
      return GlobalSearchResponse.fromBuffer(result.data!);
    }
    return GlobalSearchResponse();
  }

  // ─── M3: 消息删除 ──────────────────────────────────────────────

  Future<void> deleteMessage(Int64 messageId, {int mode = 0}) async {
    var req = DeleteMessageRequest(messageId: messageId, mode: mode);
    await sdk.invokeAsync(Command.MESSAGE_DELETE, req.writeToBuffer());
    entity.messages.remove(messageId);
    notifyListeners();
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

  // ─── M2: 成员添加/移除 ───────────────────────────────────────────

  Future<void> addChatters(Int64 chatId, List<Int64> userIds) async {
    var req = AddChatChatterRequest.create();
    req.chatId = chatId;
    req.ids.addAll(userIds);
    L.d("add chatters: chat=$chatId ids=$userIds");
    await sdk.invokeAsync(
      Command.CHAT_ADD_CHATTERS,
      req.writeToBuffer(),
    );
  }

  Future<void> removeChatters(Int64 chatId, List<Int64> userIds) async {
    var req = RemoveChatChatterRequest.create();
    req.chatId = chatId;
    req.ids.addAll(userIds);
    L.d("remove chatters: chat=$chatId ids=$userIds");
    await sdk.invokeAsync(
      Command.CHAT_DELETE_CHATTERS,
      req.writeToBuffer(),
    );
  }

  /// 退出登录：先断开 SDK 会话，再清理本地持久化与内存状态，最后跳转登录页。
  /// [onReset] 由调用方注入（一般是 ref.invalidate(imProvider) 等 provider 兜底清理）。
  void logout(GoRouter router, {void Function()? onReset}) {
    Future.delayed(Duration.zero, () async {
      L.d("logout user");
      // 1. 通知 SDK 登出，释放 DB/网络连接与身份缓存
      try {
        await sdk.logout();
      } catch (e) {
        L.e("sdk logout error: $e");
      }
      // 2. 清理本地持久化的账号信息
      await DataPersistence.removeAccount();
      // 3. 清理内存中的用户态，避免下一个用户复用
      reset();
      // 4. 兜底：由调用方 invalidate 相关 provider
      onReset?.call();
      // 5. 跳转登录页
      AppNavigator.startLogin(router);
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
