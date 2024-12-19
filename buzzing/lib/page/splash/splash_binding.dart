import 'package:buzzing/controller/app_controller.dart';
import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/controller/im.dart';
import 'package:get/get.dart';
import 'splash_logic.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashLogic());
    Get.lazyPut(() => SdkController());
    Get.lazyPut(() => ImController());
  }
}
