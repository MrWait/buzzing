import 'package:buzzing/controller/sdk_controller.dart';
import 'package:get/get.dart';

import 'calendar_logic.dart';

class CalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CalendarLogic());
    Get.lazyPut(() => SdkController());
  }
}
