import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'config/config.dart';

class CommonUtils {
  CommonUtils._();

  static bool isNotNullStr(String? str) => null != str && str.trim() != "";

  static Future<bool> isExistFile(String? path) async {
    return isNotNullStr(path) ? await File(path!).exists() : false;
  }

  static bool isNoEmpty(String? value) {
    return null != value && value.trim().isNotEmpty;
  }

  static bool isMobile(String mobile) {
    RegExp exp = RegExp(
      r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$',
    );
    return exp.hasMatch(mobile);
  }

  static String? generateMD5(String? data) {
    if (null == data) return null;
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return digest.toString();
  }

  static bool isPhoneNumber(String areaCode, String mobile) {
    if (areaCode == "+86") {
      //return isMobile(mobile);
    }
    return true;
  }

  static List<dynamic> decodeListResult(String? data) {
    return json.decode(data!);
  }

  static Map<String, dynamic> decodeMapResult(String? data) {
    return json.decode(data!);
  }

  static String encodeToString(String data) {
    return json.encode(data);
  }

  static String fixResourceUrl(String url) {
    if (url.contains("http://localhost:5150")) {
      return url.replaceAll("http://localhost:5150", Config.apiUrl());
    }
    return url;
  }
}
