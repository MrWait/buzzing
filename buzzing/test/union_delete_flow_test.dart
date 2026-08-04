import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_util/sp_util.dart';

import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/event/event_bus.dart';
import 'package:buzzing/page/login/login_logic.dart';
import 'package:buzzing/page/login/login_view.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/utils/data_persistence.dart';
import 'package:buzzing/models/model.dart';

/// 复现：下拉中带协议前缀的条目（用户可能在地址栏粘贴完整 URL），
/// removeUnion 用 split(":") 解析导致删不干净、重新下拉仍显示。
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SpUtil.getInstance();
    inited = true;
  });

  Future<Widget> buildApp(String listEntry, {String currentUnion = ''}) async {
    DataPersistence.putUnionServerList([listEntry]);
    if (currentUnion.isNotEmpty) {
      DataPersistence.putCurrentUnionServer(currentUnion);
    }
    final logic = LoginLogic(sdk: SdkController(eventBus: EventBus()));
    logic.init();
    return ProviderScope(
      overrides: [
        loginLogicProvider.overrideWithValue(logic),
      ],
      child: MaterialApp(home: Scaffold(body: LoginPage())),
    );
  }

  void drainLayoutExceptions(WidgetTester tester) {
    while (tester.takeException() != null) {}
  }

  testWidgets('带 http:// 前缀的条目点击 X 后应被真正删除', (tester) async {
    const entry = 'http://a.com:5150';
    await tester.pumpWidget(await buildApp(entry));
    await tester.pumpAndSettle();
    drainLayoutExceptions(tester);

    // 打开下拉
    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();
    drainLayoutExceptions(tester);
    expect(find.text(entry), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    // 点击 X 删除
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    drainLayoutExceptions(tester);

    // 存储应被清空
    expect(DataPersistence.getUnionServerList(), isEmpty,
        reason: '带协议前缀的条目也应能从存储中删除');

    // 重新下拉，不应再显示
    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();
    drainLayoutExceptions(tester);
    expect(find.text(entry), findsNothing,
        reason: '删除后重新下拉不应再显示该配置');
  });

  testWidgets('host 中带端口的条目点击 X 后应被真正删除', (tester) async {
    const entry = 'a.com:5150:5150';
    await tester.pumpWidget(await buildApp(entry));
    await tester.pumpAndSettle();
    drainLayoutExceptions(tester);

    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();
    drainLayoutExceptions(tester);
    expect(find.text(entry), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    drainLayoutExceptions(tester);

    expect(DataPersistence.getUnionServerList(), isEmpty,
        reason: 'host 中带端口也应能删除');

    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();
    drainLayoutExceptions(tester);
    expect(find.text(entry), findsNothing);
  });

  testWidgets('删除当前 union 时同步重置当前连接并清掉缓存配置', (tester) async {
    const entry = 'http://a.com:5150';
    // 模拟连接过该服务器：缓存 union 配置 + 记录为当前连接
    final union = Union.empty();
    union.server = 'http://a.com';
    union.port = 5150;
    union.config.union = 'a.com';
    DataPersistence.putUnion(union, keyServer: 'http://a.com');
    DataPersistence.putUnionServerList([entry]);
    DataPersistence.putCurrentUnionServer('http://a.com');

    final logic = LoginLogic(sdk: SdkController(eventBus: EventBus()));
    logic.init();
    expect(logic.currentUnionEntry, isNotEmpty,
        reason: 'initData 应能从缓存恢复当前 union');

    await tester.pumpWidget(ProviderScope(
      overrides: [loginLogicProvider.overrideWithValue(logic)],
      child: MaterialApp(home: Scaffold(body: LoginPage())),
    ));
    await tester.pumpAndSettle();
    drainLayoutExceptions(tester);

    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();
    drainLayoutExceptions(tester);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    drainLayoutExceptions(tester);

    expect(DataPersistence.getUnionServerList(), isEmpty,
        reason: '列表项应被删除');
    expect(DataPersistence.getUnion('http://a.com'), isNull,
        reason: '缓存的 union 配置应被真正清理');
    expect(DataPersistence.getCurrentUnionServer()?.isEmpty ?? true, true,
        reason: '当前 union 引用应被重置');
    expect(logic.currentUnionEntry, isEmpty,
        reason: 'logic 中当前 union 应被重置');
  });
}
