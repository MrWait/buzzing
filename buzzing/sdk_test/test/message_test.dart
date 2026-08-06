import 'dart:convert';

import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

import '../lib/proto/command.pbenum.dart';
import '../lib/proto/entity.pb.dart';
import '../lib/proto/feed.pb.dart';
import '../lib/proto/message.pb.dart';
import 'test_util.dart';

/// 消息引用回复测试 —— 见 message_spec.yaml
///
/// 回归背景：客户端「回复消息」编辑区渲染正常，但发送后气泡看不到引用内容。
/// 根因是 SDK 本地 SQLite message 表没有 ref_message_id / ref_data 列，
/// 落库与读回都会丢引用字段。本文件验证：带引用创建的草稿，经
/// MESSAGE_GET_BY_CHAT 读回后 ref_* 字段完整保留。
void main() {
  late Int64 chatId;

  setUpAll(() async {
    await initSdk(
      libPath: '../rust/target/release/librust_lib_buzzing.dylib',
    );
    await autoLoginOrFullFlow();
    // 等待一轮 feed 同步，拿到一个可用会话
    await Future.delayed(const Duration(seconds: 3));
    final req = PullFeedListRequest.create()
      ..cursor = Int64.MAX_VALUE
      ..count = 50;
    final resp = await invoke(
      Command.FEED_GET_LIST.value,
      req.writeToBuffer(),
    );
    final feeds = PullFeedListResponse.fromBuffer(resp.payload).entity.feeds;
    expect(feeds, isNotEmpty, reason: '登录后应存在至少一个会话');
    chatId = feeds.keys.first;
  });

  tearDownAll(() async {
    await logoutUser();
  });

  group('Message | reply reference', () {
    // DRAFT_KEEPS_REPLY_REF
    test('带引用创建草稿，读回后 ref_message_id / ref_data 不丢失', () async {
      final ref = MessageReference.create()
        ..chatId = chatId
        ..content = utf8.encode('引用内容')
        ..summary = '引用摘要'
        ..tpy = MessageType.TEXT.value
        ..senderName = 'refSender';
      final msg = Message.create()
        ..tpy = MessageType.TEXT.value
        ..fromId = Int64(1)
        ..chatId = chatId
        ..content = utf8.encode('回复正文')
        ..summary = '回复摘要'
        ..refMessageId = Int64(123456)
        ..refData = ref;

      // 1. 创建带引用的草稿（status=8 落本地库）
      final draftReq = CreateMessageDraftRequest.create()
        ..chatId = chatId
        ..message = msg;
      final draftResp = await invoke(
        Command.MESSAGE_CREATE_DRAFT.value,
        draftReq.writeToBuffer(),
      );
      expect(draftResp.status, equals(200));
      final clientId = CreateMessageDraftResponse.fromBuffer(draftResp.payload).clientId;
      expect(clientId > Int64(0), isTrue, reason: '草稿应生成 clientId');

      // 2. 从本地库读回该草稿，验证引用字段未被丢弃
final getReq = GetMessageByRangeRequest.create()
        ..chatId = chatId
        ..pos = 1
        ..count = 500
        ..direct = Direct.NONE.value;
      final getResp = await invoke(
        Command.MESSAGE_GET_BY_RANGE.value,
        getReq.writeToBuffer(),
      );
      expect(getResp.status, equals(200));
      final messages =
          GetMessageByRangeResponse.fromBuffer(getResp.payload).entity.messages;
      final saved = messages[clientId];
      expect(saved, isNotNull, reason: '草稿应能从本地读回，实际 keys=${messages.keys}');
      final s = saved!;
      expect(s.refMessageId, equals(Int64(123456)), reason: 'ref_message_id 丢失');
      expect(s.hasRefData(), isTrue, reason: 'ref_data 丢失');
      expect(s.refData.senderName, equals('refSender'));
      expect(s.refData.summary, equals('引用摘要'));
    });
  });
}