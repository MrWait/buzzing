import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/controller/app_controller.dart';
import 'package:get/get.dart';

import 'meeting_logic.dart';

class MeetingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MeetingLogic());
    Get.lazyPut(() => SdkController());
    Get.lazyPut(() => AppController());
  }
}
