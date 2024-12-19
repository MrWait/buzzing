import 'package:buzzing/controller/sdk_controller.dart';
import 'package:get/get.dart';

import 'login_logic.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginLogic());
    Get.lazyPut(() => SdkController());
  }
}
