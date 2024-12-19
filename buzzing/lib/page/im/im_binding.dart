import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/page/chat/chat_logic.dart';
import 'package:buzzing/page/feed/feed_logic.dart';
import 'package:get/get.dart';
import 'im_logic.dart';

class ImBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ImLogic());
    Get.lazyPut(() => FeedLogic());
    Get.lazyPut(() => ChatLogic());
    Get.lazyPut(() => SdkController());
  }
}
