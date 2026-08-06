import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/im.dart';
import '../utils/data_persistence.dart';
import 'app_provider.dart';
import 'sdk_provider.dart';

final imProvider = Provider<ImController>((ref) {
  final sdk = ref.watch(sdkProvider);
  final bus = ref.watch(eventBusProvider);
  final im = ImController(sdk: sdk, ev: bus);
  im.onInit();
  ref.onDispose(() => im.dispose());
  // 冷启动时若已有持久化身份，立即应用；
  // 运行期切换用户由 LoginLogic.loginUser / SplashLogic 显式调用 applyLoginUser。
  final account = DataPersistence.getAccount();
  final loginUser = account?.loginUser;
  if (loginUser != null) {
    im.applyLoginUser(loginUser);
  }
  return im;
});
