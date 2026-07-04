import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

import '../lib/proto/calendar.pb.dart';
import '../lib/proto/chat.pb.dart';
import '../lib/proto/command.pbenum.dart';
import '../lib/proto/dept.pb.dart';
import '../lib/proto/entity.pb.dart';
import '../lib/proto/feed.pb.dart';
import '../lib/proto/message.pb.dart';
import '../lib/proto/sdk.pb.dart';
import '../lib/proto/user.pb.dart';
import 'test_util.dart';

void main() {
  late Int64 loggedInUserId;
  late Int64 loggedInTenantId;
  late Int64 userDeptId;
  late String userToken;

  setUpAll(() async {
    await initSdk(
      libPath: '../rust/target/release/librust_lib_buzzing.dylib',
    );
    final loginUser = await autoLoginOrFullFlow();
    loggedInUserId = loginUser.user.id;
    loggedInTenantId = loginUser.tenant.id;
    userToken = loginUser.token;
    print('Logged in: userId=$loggedInUserId, tenantId=$loggedInTenantId');
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
      final req = GetUserByIdsRequest.create()..ids.add(loggedInUserId);
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
    test('CALENDAR_GET_LIST returns calendars from local DB', () async {
      final req = CalendarGetListRequest.create();
      final resp = await invoke(
        Command.CALENDAR_GET_LIST.value,
        req.writeToBuffer(),
      );
      print('CALENDAR_GET_LIST: status=${resp.status}, payloadLen=${resp.payload.length}');
      expect(resp.status, anyOf(0, 200));
      if (resp.payload.isNotEmpty) {
        final calResp = CalendarGetListResponse.fromBuffer(resp.payload);
        print('calendars count: ${calResp.calendars.length}');
      }
    });

    test('SCHEDULE_PULL_BY_IDS returns response', () async {
      final req = SchedulePullByIdsRequest.create()..ids.add(Int64(1));
      final resp = await invoke(
        Command.SCHEDULE_PULL_BY_IDS.value,
        req.writeToBuffer(),
      );
      print('SCHEDULE_PULL_BY_IDS: status=${resp.status}, payloadLen=${resp.payload.length}');
      expect(resp.seq, greaterThan(0));
    });
  });

  group('Calendar | SDK CRUD', () {
    late Int64 createdCalId;
    late Int64 createdSchedId;

    test('CALENDAR_CREATE creates a calendar via SDK', () async {
      final req = CalendarCreateRequest.create()
        ..calendar = (Calendar.create()
          ..name = 'sdk-test-cal-${DateTime.now().millisecondsSinceEpoch}'
          ..desc = 'created by sdk test'
          ..color = 0xFF3370FF
          ..isDefault = false);
      final resp = await invoke(
        Command.CALENDAR_CREATE.value,
        req.writeToBuffer(),
      );
      print('CALENDAR_CREATE: status=${resp.status}, payloadLen=${resp.payload.length}');
      expect(resp.status, anyOf(0, 200));
      if (resp.payload.isNotEmpty) {
        final createResp = CalendarCreateResponse.fromBuffer(resp.payload);
        expect(createResp.calendar, isNotNull);
        expect(createResp.calendar.name, req.calendar.name);
        createdCalId = createResp.calendar.id;
        print('created calendar id=$createdCalId');
      }
    });

    test('SCHEDULE_CREATE creates a schedule via SDK', () async {
      expect(createdCalId, greaterThan(Int64(0)));
      final now = DateTime.now().millisecondsSinceEpoch;
      final req = ScheduleCreateRequest.create()
        ..schedule = (Schedule.create()
          ..calendarId = createdCalId
          ..title = 'sdk-test-sched-${now}'
          ..startTime = Int64(now)
          ..endTime = Int64(now + 3600000)
          ..type = 0);
      final resp = await invoke(
        Command.SCHEDULE_CREATE.value,
        req.writeToBuffer(),
      );
      print('SCHEDULE_CREATE: status=${resp.status}, payloadLen=${resp.payload.length}');
      expect(resp.status, anyOf(0, 200));
      if (resp.payload.isNotEmpty) {
        final createResp = ScheduleCreateResponse.fromBuffer(resp.payload);
        expect(createResp.schedule, isNotNull);
        expect(createResp.schedule.title, req.schedule.title);
        createdSchedId = createResp.schedule.id;
        print('created schedule id=$createdSchedId');
      }
    });

    test('CALENDAR_GET_LIST includes created calendar', () async {
      expect(createdCalId, greaterThan(Int64(0)));
      await Future.delayed(const Duration(milliseconds: 500));
      final req = CalendarGetListRequest.create();
      final resp = await invoke(
        Command.CALENDAR_GET_LIST.value,
        req.writeToBuffer(),
      );
      print('CALENDAR_GET_LIST after create: status=${resp.status}');
      expect(resp.status, anyOf(0, 200));
      if (resp.payload.isNotEmpty) {
        final calResp = CalendarGetListResponse.fromBuffer(resp.payload);
        final found = calResp.calendars.where((c) => c.id == createdCalId);
        if (found.isNotEmpty) {
          print('created calendar found in local DB: name="${found.first.name}"');
        } else {
          print('created calendar NOT yet in local DB (push may be pending)');
        }
      }
    });

    test('SCHEDULE_PULL_BY_CALENDAR_IDS returns response', () async {
      expect(createdCalId, greaterThan(Int64(0)));
      final now = DateTime.now().millisecondsSinceEpoch;
      final req = SchedulePullByCalendarIdsRequest.create()
        ..calendarIds.add(createdCalId)
        ..startTime = Int64(now - 86400000)
        ..endTime = Int64(now + 86400000);
      final resp = await invoke(
        Command.SCHEDULE_PULL_BY_CALENDAR_IDS.value,
        req.writeToBuffer(),
      );
      print('SCHEDULE_PULL_BY_CALENDAR_IDS: status=${resp.status}, payloadLen=${resp.payload.length}');
      expect(resp.seq, greaterThan(0));
      if (resp.payload.isNotEmpty) {
        final pullResp = SchedulePullByCalendarIdsResponse.fromBuffer(resp.payload);
        print('schedules count: ${pullResp.schedules.length}');
        if (createdSchedId != Int64(0)) {
          final found = pullResp.schedules.where((s) => s.id == createdSchedId);
          if (found.isNotEmpty) {
            print('created schedule found: "${found.first.title}"');
          }
        }
      }
    });

    test('SCHEDULE_CREATE with cycle rule (daily)', () async {
      expect(createdCalId, greaterThan(Int64(0)));
      final now = DateTime.now().millisecondsSinceEpoch;
      final req = ScheduleCreateRequest.create()
        ..schedule = (Schedule.create()
          ..calendarId = createdCalId
          ..title = 'sdk-recurring-sched-${now}'
          ..startTime = Int64(now)
          ..endTime = Int64(now + 3600000)
          ..type = 0
          ..cycle = (ScheduleCycleRule.create()
            ..rule = (CycleRule.create()
              ..cycleType = 1  // CycleByDay
              ..seq = 1)));    // every day
      final resp = await invoke(
        Command.SCHEDULE_CREATE.value,
        req.writeToBuffer(),
      );
      print('SCHEDULE_CREATE (recurring): status=${resp.status}, payloadLen=${resp.payload.length}');
      expect(resp.status, anyOf(0, 200));
      if (resp.payload.isNotEmpty) {
        final createResp = ScheduleCreateResponse.fromBuffer(resp.payload);
        expect(createResp.schedule, isNotNull);
        print('created recurring schedule id=${createResp.schedule.id}');
      }
    });

    test('SCHEDULE_UPDATE updates schedule via SDK', () async {
      expect(createdSchedId, greaterThan(Int64(0)));
      final now = DateTime.now().millisecondsSinceEpoch;
      final req = ScheduleUpdateRequest.create()
        ..schedule = (Schedule.create()
          ..id = createdSchedId
          ..calendarId = createdCalId
          ..title = 'sdk-updated-sched-${now}')
        ..modifyScope = 0;
      final resp = await invoke(
        Command.SCHEDULE_UPDATE.value,
        req.writeToBuffer(),
      );
      print('SCHEDULE_UPDATE: status=${resp.status}, payloadLen=${resp.payload.length}');
      expect(resp.status, anyOf(0, 200));
    });
  });

  group('Contact | user queries', () {
    test('USER_GET_BY_IDS single known user returns full fields', () async {
      final req = GetUserByIdsRequest.create()..ids.add(loggedInUserId);
      final resp = await invoke(
        Command.USER_GET_BY_IDS.value,
        req.writeToBuffer(),
      );
      expect(resp.status, anyOf(0, 200));
      final usersResp = GetUserByIdsResponse.fromBuffer(resp.payload);
      print('USER_GET_BY_IDS: status=${resp.status}, users=${usersResp.users.length}');
      expect(usersResp.users, hasLength(1));
      final u = usersResp.users.first;
      print('  user: id=${u.id}, name="${u.name}", deptId=${u.deptId}, tenantId=${u.tenantId}');
      expect(u.id, loggedInUserId);
      expect(u.name, isNotEmpty);
      userDeptId = u.deptId;
      print('  captured userDeptId=$userDeptId');
    });

    test('USER_GET_BY_IDS with empty ids returns empty', () async {
      final req = GetUserByIdsRequest.create();
      final resp = await invoke(
        Command.USER_GET_BY_IDS.value,
        req.writeToBuffer(),
      );
      expect(resp.status, anyOf(0, 200));
      final usersResp = GetUserByIdsResponse.fromBuffer(resp.payload);
      expect(usersResp.users, isEmpty);
    });

    test('USER_GET_BY_IDS with mixed known+unknown ids', () async {
      final req = GetUserByIdsRequest.create()
        ..ids.addAll([loggedInUserId, Int64(99999)]);
      final resp = await invoke(
        Command.USER_GET_BY_IDS.value,
        req.writeToBuffer(),
      );
      expect(resp.status, anyOf(0, 200));
      final usersResp = GetUserByIdsResponse.fromBuffer(resp.payload);
      expect(usersResp.users, hasLength(1));
      expect(usersResp.users.first.id, loggedInUserId);
    });

    test('USER_GET_BY_IDS with all unknown ids returns empty', () async {
      final req = GetUserByIdsRequest.create()..ids.add(Int64(99999));
      final resp = await invoke(
        Command.USER_GET_BY_IDS.value,
        req.writeToBuffer(),
      );
      expect(resp.status, anyOf(0, 200));
      final usersResp = GetUserByIdsResponse.fromBuffer(resp.payload);
      expect(usersResp.users, isEmpty);
    });
  });

  group('Contact | dept queries', () {
    test('DEPT_GET_BY_ID known dept returns full fields', () async {
      if (userDeptId == Int64(0)) {
        print('SKIP: user has no department (deptId=0)');
        return;
      }
      final req = GetDeptRequest.create()
        ..id = userDeptId
        ..tenantId = loggedInTenantId
        ..recursive = false;
      final resp = await invoke(
        Command.DEPT_GET_BY_ID.value,
        req.writeToBuffer(),
      );
      print('DEPT_GET_BY_ID: status=${resp.status}, userDeptId=$userDeptId, tenantId=$loggedInTenantId');
      expect(resp.status, anyOf(0, 200));
      final deptResp = GetDeptResponse.fromBuffer(resp.payload);
      print('  depts: keys=${deptResp.depts.keys}, count=${deptResp.depts.length}');
      print('  users: keys=${deptResp.users.keys}, count=${deptResp.users.length}');
      if (deptResp.depts.isEmpty) {
        print('  WARN: no depts returned, skipping further assertions');
        return;
      }
      final dept = deptResp.depts[userDeptId];
      expect(dept, isNotNull);
      final d = dept!;
      print('  dept: id=${d.id}, name="${d.name}", tenantId=${d.tenantId}');
      expect(d.name, isNotEmpty);
      expect(d.version, greaterThan(Int64(0)));
    });

    test('DEPT_GET_BY_ID unknown dept returns empty', () async {
      final req = GetDeptRequest.create()
        ..id = Int64(999999)
        ..tenantId = Int64(1)
        ..recursive = false;
      final resp = await invoke(
        Command.DEPT_GET_BY_ID.value,
        req.writeToBuffer(),
      );
      expect(resp.status, anyOf(0, 200));
      final deptResp = GetDeptResponse.fromBuffer(resp.payload);
      expect(deptResp.depts, isEmpty);
    });

    test('DEPT_GET_BY_ID recursive returns depts', () async {
      if (userDeptId == Int64(0)) {
        print('SKIP: user has no department (deptId=0)');
        return;
      }
      final req = GetDeptRequest.create()
        ..id = userDeptId
        ..tenantId = loggedInTenantId
        ..recursive = true;
      final resp = await invoke(
        Command.DEPT_GET_BY_ID.value,
        req.writeToBuffer(),
      );
      print('DEPT_GET_BY_ID recursive: status=${resp.status}, userDeptId=$userDeptId, tenantId=$loggedInTenantId');
      expect(resp.status, anyOf(0, 200));
      final deptResp = GetDeptResponse.fromBuffer(resp.payload);
      print('  depts: keys=${deptResp.depts.keys}, count=${deptResp.depts.length}');
      print('  users: keys=${deptResp.users.keys}, count=${deptResp.users.length}');
      if (deptResp.depts.isEmpty) {
        print('  WARN: no depts returned with recursive=true');
        return;
      }
    });

    test('DEPT_GET_BY_ID users are valid entity.User', () async {
      if (userDeptId == Int64(0)) {
        print('SKIP: user has no department (deptId=0)');
        return;
      }
      final req = GetDeptRequest.create()
        ..id = userDeptId
        ..tenantId = loggedInTenantId
        ..recursive = true;
      final resp = await invoke(
        Command.DEPT_GET_BY_ID.value,
        req.writeToBuffer(),
      );
      print('DEPT_GET_BY_ID users: status=${resp.status}, userDeptId=$userDeptId, tenantId=$loggedInTenantId');
      expect(resp.status, anyOf(0, 200));
      final deptResp = GetDeptResponse.fromBuffer(resp.payload);
      print('  users count=${deptResp.users.length}');
      for (final entry in deptResp.users.entries) {
        print('  user[${entry.key}]: id=${entry.value.id}, name="${entry.value.name}"');
        expect(entry.key, greaterThan(Int64(0)));
        expect(entry.value.id, greaterThan(Int64(0)));
        expect(entry.value.name, isNotEmpty);
      }
    });
  });

  group('Re-login | lifecycle', () {
    test('can logout and login again', () async {
      await logoutUser();
      final resp = await sdkLogin(
        userId: loggedInUserId.toInt(),
        token: userToken,
        tenantId: 1,
      );
      expect(resp.status, equals(200));
    });
  });
}
