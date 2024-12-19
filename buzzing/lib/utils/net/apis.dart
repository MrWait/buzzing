import 'dart:io';
import 'dart:convert';

import 'package:buzzing/models/model.dart';
import 'package:dio/dio.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/utils/config/urls.dart';
import 'package:buzzing/utils/net/http_util.dart';
import 'package:buzzing/models/login_certificate.dart';
import 'package:buzzing/utils/loogger_util.dart';

class Apis {
  static Future<LoginAccount> login({
    String? mobile,
    String? password,
  }) async {
    try {
      var data = await HttpUtil.post(Urls.login(), data: {
        "phone": mobile,
        "password": password,
      });
      LD("login result: ${data}, type: ${data.runtimeType}");
      var loginData = LoginAccount.fromAccount(data);
      LD("login ok: ${loginData}");
      if (loginData.account?.users.length == 0) {
        return Future.error(DioErrorType.unknown);
      }
      //setApiToken(Config.imApiUrl(), loginData.accessToken);
      //var loginUserData = LoginUserCertificate.fromJson(data!);
      //LD("login user ok: ${loginUserData}");
      //setApiToken(Config.imApiUrl(), loginUserData.accessToken);
      return loginData;
    } catch (e) {
      LD("login error e: $e");
      return Future.error(e);
    }
  }

  static Future<UnionConfig?> syncConfig() async {
    try {
      var data = await HttpUtil.pull(Urls.syncConfig());
      var s = data.toString().replaceAll(RegExp("\n"), "");
      return UnionConfig.fromString(s);
    } catch (e) {
      L.w("sync config error: ${e}");
      return Future.error(e);
    }
  }
}
