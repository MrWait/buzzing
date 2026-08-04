import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_util/sp_util.dart';
import 'package:buzzing/utils/data_persistence.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SpUtil.getInstance();
  });

  test('removeUnionFromList 后列表不再包含该条目', () async {
    await DataPersistence.addUnionToList('a.com', 5150);
    await DataPersistence.addUnionToList('b.com', 5150);
    expect(DataPersistence.getUnionServerList(), ['a.com:5150', 'b.com:5150']);

    await DataPersistence.removeUnionFromList('a.com', 5150);
    expect(DataPersistence.getUnionServerList(), ['b.com:5150']);
  });

  test('removeCurrentUnionServer + getCurrentUnionServer 联动', () async {
    await DataPersistence.putCurrentUnionServer('a.com');
    expect(DataPersistence.getCurrentUnionServer(), 'a.com');
    await DataPersistence.removeCurrentUnionServer();
    expect(DataPersistence.getCurrentUnionServer()?.isEmpty ?? true, true);
  });
}
