import 'package:buzzing/page/feed/feed_logic.dart';
import 'package:get/get.dart';

class FeedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FeedLogic());
  }
}
