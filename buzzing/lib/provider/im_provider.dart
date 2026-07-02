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
  final account = DataPersistence.getAccount();
  if (account?.loginUser != null) {
    im.loginUser = account!.loginUser!;
    im.userId = im.loginUser.user.id;
    im.avatar = im.loginUser.user.avatar;
    im.setUserId(im.loginUser.user.id);
    Future.delayed(Duration.zero, () => im.fetchFeed());
  }
  return im;
});
