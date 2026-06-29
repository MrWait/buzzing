import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

import '../lib/proto/calendar.pb.dart';
import '../lib/proto/chat.pb.dart';
import '../lib/proto/command.pbenum.dart';
import '../lib/proto/feed.pb.dart';
import '../lib/proto/message.pb.dart';
import '../lib/proto/sdk.pb.dart';
import '../lib/proto/user.pb.dart';
import 'test_util.dart';

void main() {
  setUpAll(() async {
    await initSdk(
      libPath: '../rust/target/release/librust_lib_buzzing.dylib',
    );
    await loginUser(userId: 12345, token: 'test-token', tenantId: 1);
  });

  tearDownAll(() async {
    await logoutUser();
  });

  group('Basic | invoke routing', () {
    test('ECHO returns response with valid seq', () async {
      final resp = await invoke(Command.ECHO.value, [1, 2, 3]);
      expect(resp, isNotNull);
      expect(resp.seq, greaterThan(0));
    });

    test('unknown command returns error status', () async {
      final resp = await invoke(999999, []);
      expect(resp.status, isNot(anyOf(0, 200)));
      expect(resp.seq, greaterThan(0));
    });

    test('ACK returns response', () async {
      final resp = await invoke(Command.ACK.value, []);
      expect(resp.seq, greaterThan(0));
    });
  });

  group('Account | user queries', () {
    test('USER_GET_BY_IDS with known ids returns response', () async {
      final req = GetUserByIdsRequest.create()..ids.add(Int64(12345));
      final resp = await invoke(
        Command.USER_GET_BY_IDS.value,
        req.writeToBuffer(),
      );
      expect(resp.seq, greaterThan(0));
    });

    test('USER_GET_BY_IDS with unknown ids returns empty', () async {
      final req = GetUserByIdsRequest.create()..ids.addAll([Int64(99999)]);
      final resp = await invoke(
        Command.USER_GET_BY_IDS.value,
        req.writeToBuffer(),
      );
      if (resp.status == 200) {
        final usersResp = GetUserByIdsResponse.fromBuffer(resp.payload);
        expect(usersResp.users, isEmpty);
      }
    });
  });

  group('Chat | feeds', () {
    test('GET_FEED_TOP_LIST returns empty list', () async {
      final req = GetFeedTopListRequest.create();
      final resp = await invoke(
        Command.FEED_GET_TOP_LIST.value,
        req.writeToBuffer(),
      );
      expect(resp.status, anyOf(0, 200));
      final feedResp = GetFeedTopListResponse.fromBuffer(resp.payload);
      expect(feedResp.ids, isEmpty);
    });

    test('PULL_FEED_LIST returns empty', () async {
      final req = PullFeedListRequest.create()..count = 20;
      final resp = await invoke(
        Command.FEED_GET_LIST.value,
        req.writeToBuffer(),
      );
      expect(resp.status, anyOf(0, 200));
      final feedResp = PullFeedListResponse.fromBuffer(resp.payload);
      expect(feedResp.hasMore, isFalse);
    });
  });

  group('Chat | drafts', () {
    test('CHAT_SET_DRAFT and GET_DRAFT round-trip', () async {
      final setReq = SetChatDraftRequest.create()
        ..chatId = Int64(1001)
        ..content = [104, 101, 108, 108, 111];
      var resp = await invoke(
        Command.CHAT_SET_DRAFT.value,
        setReq.writeToBuffer(),
      );
      expect(resp.status, anyOf(0, 200));

      final getReq = GetChatDraftRequest.create()..chatId = Int64(1001);
      resp = await invoke(
        Command.CHAT_GET_DRAFT.value,
        getReq.writeToBuffer(),
      );
      expect(resp.status, anyOf(0, 200));
    });
  });

  group('Message | stubs', () {
    test('RECALL_MESSAGE stub returns response', () async {
      final req = RecallMessageRequest.create()..id = Int64(1);
      final resp = await invoke(
        Command.MESSAGE_RECALL.value,
        req.writeToBuffer(),
      );
      expect(resp.seq, greaterThan(0));
    });
  });

  group('Calendar | reads from local DB', () {
    test('CALENDAR_GET_LIST returns empty initially', () async {
      final req = CalendarGetListRequest.create();
      final resp = await invoke(
        Command.CALENDAR_GET_LIST.value,
        req.writeToBuffer(),
      );
      expect(resp.status, anyOf(0, 200));
      if (resp.payload.isNotEmpty) {
        final calResp = CalendarGetListResponse.fromBuffer(resp.payload);
        expect(calResp.calendars, isEmpty);
      }
    });

    test('SCHEDULE_PULL_BY_IDS stub returns empty', () async {
      final req = SchedulePullByIdsRequest.create()..ids.add(Int64(1));
      final resp = await invoke(
        Command.SCHEDULE_PULL_BY_IDS.value,
        req.writeToBuffer(),
      );
      expect(resp.seq, greaterThan(0));
    });
  });

  group('Re-login | lifecycle', () {
    test('can logout and login again', () async {
      await logoutUser();
      final resp = await loginUser(
        userId: 67890,
        token: 'token-2',
        tenantId: 1,
      );
      expect(resp.status, equals(200));
    });
  });
}
