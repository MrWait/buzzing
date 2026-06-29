import 'dart:async';

import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/routes/app_navigator.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/utils/data_persistence.dart';
import 'package:buzzing/models/login_certificate.dart';
import 'package:buzzing/utils/net/http_util.dart';
import 'package:buzzing/utils/loogger_util.dart';
import 'package:go_router/go_router.dart';

class SplashLogic {
  late StreamSubscription initializedSub;
  final SdkController sdk;
  SplashLogic({required this.sdk});

  void init(GoRouter router) {
    if (!try_login(router)) {
      Future.delayed(Duration(seconds: 2), () {
        AppNavigator.startLogin(router);
      });
    }
  }

  void dispose() {
    //initializedSub.cancel();
  }

  bool try_login(GoRouter router) {
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
      AppNavigator.startIm(router, account.loginUser);
      return true;
      // pushLogic.
    } catch (e) {
      // TODO
      LD(e);
      return false;
    }
  }
}
