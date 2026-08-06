import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

import '../lib/proto/command.pbenum.dart';
import '../lib/proto/feed.pb.dart';
import '../lib/proto/user.pb.dart';
import 'test_util.dart';

/// 会话生命周期测试 —— 见 session_spec.yaml
///
/// 回归背景：客户端曾出现「A 登出后 B 登录，主界面仍显示 A 的数据」。
/// SDK 侧根因是 logout 只 reset 了 DbConn，未清理 AppAccount.account_info 与
/// AppChat 的运行时缓存（stash_ids / sync flags / prefetch queue）。
/// 本文件验证：登出后不残留旧用户数据，且重新登录后功能完全恢复。
void main() {
  late Int64 loggedInUserId;
  late Int64 loggedInTenantId;
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

  /// 重新登录当前身份，确保后续用例有可用会话
  Future<void> relogin() async {
    final resp = await sdkLogin(
      userId: loggedInUserId.toInt(),
      token: userToken,
      tenantId: loggedInTenantId.toInt(),
    );
    expect(resp.status, equals(200), reason: 'relogin 必须成功');
  }

  group('Session | logout cleanup', () {
    // LOGOUT_RETURNS_OK
    test('USER_LOGOUT 正常返回', () async {
      final resp = await invoke(
        Command.USER_LOGOUT.value,
        userLogoutPayload(),
      );
      expect(resp.status, equals(200));
      await relogin();
    });

    // LOGOUT_CLEARS_DB
    test('登出后 USER_GET_BY_IDS 不得返回上一个用户的数据', () async {
      await logoutUser();

      final req = GetUserByIdsRequest.create()..ids.add(loggedInUserId);
      final resp = await invoke(
        Command.USER_GET_BY_IDS.value,
        req.writeToBuffer(),
      );

      // DbConn 已 reset，且 account_info 已清空（无 token 无法回源），
      // 因此要么直接报错，要么返回空列表；绝不能返回旧用户实体。
      if (resp.status == 200) {
        final users = GetUserByIdsResponse.fromBuffer(resp.payload).users;
        expect(users, isEmpty,
            reason: '登出后不应返回任何用户数据，实际: $users');
      } else {
        print('  logout 后 USER_GET_BY_IDS 返回错误 status=${resp.status}（预期）');
      }

      await relogin();
    });

    // LOGOUT_CLEARS_FEED_DB
    test('登出后 FEED_GET_LIST 不得返回上一个用户的会话列表', () async {
      await logoutUser();

      final req = PullFeedListRequest.create()
        ..cursor = Int64.MAX_VALUE
        ..count = 50;
      final resp = await invoke(
        Command.FEED_GET_LIST.value,
        req.writeToBuffer(),
      );

      if (resp.status == 200) {
        final entity = PullFeedListResponse.fromBuffer(resp.payload).entity;
        expect(entity.feeds, isEmpty,
            reason: '登出后不应返回任何 feed，实际数量: ${entity.feeds.length}');
      } else {
        print('  logout 后 FEED_GET_LIST 返回错误 status=${resp.status}（预期）');
      }

      await relogin();
    });
  });

  group('Session | re-login after logout', () {
    // RELOGIN_OK
    test('登出后可重新登录', () async {
      await logoutUser();
      final resp = await sdkLogin(
        userId: loggedInUserId.toInt(),
        token: userToken,
        tenantId: loggedInTenantId.toInt(),
      );
      expect(resp.status, equals(200));
    });

    // RELOGIN_DB_USABLE
    test('重新登录后 DB 恢复可用', () async {
      await logoutUser();
      await relogin();

      final req = GetUserByIdsRequest.create()..ids.add(loggedInUserId);
      final resp = await invoke(
        Command.USER_GET_BY_IDS.value,
        req.writeToBuffer(),
      );
      expect(resp.status, equals(200));
      final users = GetUserByIdsResponse.fromBuffer(resp.payload).users;
      expect(users.length, equals(1));
      expect(users[0].id, equals(loggedInUserId));
    });

    // RELOGIN_FEED_SYNC_WORKS
    // 回归点：logout 若不复位 feed_sync_flag / pipeline_sync_flag，
    // 再次登录时 sync 会 early-return，导致永久不再同步。
    test('重新登录后 feed 同步仍可工作', () async {
      await logoutUser();
      await relogin();
      // 等待 SDK 完成一轮 feed 同步
      await Future.delayed(const Duration(seconds: 3));

      final req = PullFeedListRequest.create()
        ..cursor = Int64.MAX_VALUE
        ..count = 50;
      final resp = await invoke(
        Command.FEED_GET_LIST.value,
        req.writeToBuffer(),
      );
      expect(resp.status, equals(200),
          reason: 'feed sync flag 未复位会导致同步失效');
    });

    // RELOGIN_REPEATED
    test('连续多轮 logout/login 保持可用', () async {
      for (var i = 0; i < 3; i++) {
        await logoutUser();
        await relogin();

        final req = GetUserByIdsRequest.create()..ids.add(loggedInUserId);
        final resp = await invoke(
          Command.USER_GET_BY_IDS.value,
          req.writeToBuffer(),
        );
        expect(resp.status, equals(200), reason: '第 ${i + 1} 轮 re-login 失败');
        final users = GetUserByIdsResponse.fromBuffer(resp.payload).users;
        expect(users.length, equals(1), reason: '第 ${i + 1} 轮 user 查询失败');
        expect(users[0].id, equals(loggedInUserId));
      }
    });
  });
}
