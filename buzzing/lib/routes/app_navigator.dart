import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/routes/app_pages.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/utils/data_persistence.dart';
import 'package:get/get.dart';
import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/controller/im.dart';

class AppNavigator {
  static void backLogin() {
    Get.until((route) => Get.currentRoute == AppRoute.LOGIN);
  }

  static void startLogin() {
    Get.offAllNamed(AppRoute.LOGIN);
  }

  static void startRegister(String way) {
    Get.toNamed(AppRoute.REGISTER, arguments: {'registerWay': way});
  }

  static void startIm(LoginUser? user) {
    Future.delayed(Duration.zero, () async {
      final sdk = Get.find<SdkController>();
      final im = Get.find<ImController>();
      if (user != null) {
        im.loginUser = user;
      }
      var account = DataPersistence.getAccount();
      if (account?.loginUser != null) {
        var id = account?.loginUser?.user.id;
        var config = Config.union.config.toString();
        await sdk.login(id, account?.loginUser?.token ?? "", 'zh_cn', config);
        if (id != null) {
          im.setUserId(id);
        }
        Get.offAllNamed(AppRoute.IM);
      } else {
        Get.offAllNamed(AppRoute.LOGIN);
      }
    });
  }

  static void startContact() {
    Future.delayed(Duration.zero, () async {
      Get.offAllNamed(AppRoute.CONTACT);
    });
  }

  static void startCalendar() {
    Future.delayed(Duration.zero, () async {
      Get.offAllNamed(AppRoute.CALENDAR);
    });
  }

  static void startMeeting() {
    Future.delayed(Duration.zero, () async {
      Get.offAllNamed(AppRoute.MEETING);
    });
  }

  static void startRegisterVerifyPhoneOrEmail({
    String? email,
    String? phoneNumber,
    String? areaCode,
    required int usedFor,
    String? invitationCode,
  }) {
    Get.toNamed(AppRoute.REGISTER_VERIFY_PHONE, arguments: {
      'phoneNumber': phoneNumber,
      'areaCode': areaCode,
      'email': email,
      'usedFor': usedFor,
      'invitationCode': invitationCode,
    });
  }
}
