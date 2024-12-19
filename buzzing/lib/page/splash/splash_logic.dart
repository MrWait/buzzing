import 'dart:async';
import 'dart:ffi';

import 'package:buzzing/controller/app_controller.dart';
import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/routes/app_navigator.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/utils/data_persistence.dart';
import 'package:buzzing/models/login_certificate.dart';
import 'package:buzzing/utils/net/http_util.dart';
import 'package:buzzing/utils/loogger_util.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:get/get.dart';

class SplashLogic extends GetxController {
//  final imLogic = Get.find();
//  final pushLogic = Get.find();
  late StreamSubscription initializedSub;
  final sdk = Get.find<SdkController>();
  final app = Get.find<AppController>();

  @override
  void onInit() {
    if (!try_login()) {
      Future.delayed(Duration(seconds: 2), () {
        AppNavigator.startLogin();
      });
    }

    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  bool try_login() {
    try {
      String currentUnion = DataPersistence.getCurrentUnionServer() ?? "";
      if (currentUnion.isEmpty) {
        L.d("in splash, current union was empty ");
        return false;
      }
      var union = DataPersistence.getUnion(currentUnion);
      if (union == null) {
        L.d("in splash, union config was empty ");
        DataPersistence.removeCurrentUnionServer();
        return false;
      }

      Config.union = union;
      Config.currentUnion = currentUnion;

      LoginAccount? account = DataPersistence.getAccount();
      L.d("in splash, try login. load account: $account, current union: $currentUnion, union: $union");

      if (account == null) {
        return false;
      }

      if (currentUnion != account.server) {
        L.d("login info mismatch, relogin");
        DataPersistence.removeAccount();
        return false;
      }

      var now = DateTime.now().millisecondsSinceEpoch;
      LD("splash check account: $account, now: $now");
      if (account.loginUser != null) {
        if (account.loginUser!.tokenExpire < now) {
          LD("token expire, need relogin");
          DataPersistence.removeAccount();
          return false;
        } else {
          L.d("login info ok");
        }
      }

      HttpUtil.resetBaseUrl(Config.apiUrl());
      LD("login account: $account");
      AppNavigator.startIm(account.loginUser);
      return true;
      // pushLogic.
    } catch (e) {
      // TODO
      LD(e);
      return false;
    }
  }

  @override
  void onClose() {
    //initializedSub.cancel();
    super.onClose();
  }
}
