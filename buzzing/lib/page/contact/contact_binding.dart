import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/page/contact/contact_logic.dart';
import 'package:get/get.dart';

class ContactBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ContactController());
  }
}
