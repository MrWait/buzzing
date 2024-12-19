import 'package:flutter_easyloading/flutter_easyloading.dart';

class IMWidget {
  static void showToast(String msg) {
    if (msg.trim().isNotEmpty) EasyLoading.showToast(msg);
  }
}
