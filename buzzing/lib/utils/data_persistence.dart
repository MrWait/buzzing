import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:buzzing/models/login_certificate.dart';
import 'package:sp_util/sp_util.dart';
import 'package:uuid/uuid.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:buzzing/models/model.dart';

class DataPersistence {
  static const _FREQUENT_CONTACTS = "%s_frequentContacts";
  static const _ACCOUNT = 'account';
  static const _AT_USER_INFO = '%s_atUserInfo';
  static const _SERVER = 'server';
  static const _IP = 'ip';
  static const _LANGUAGE = 'language';
  static const _IGNORE_UPDATE = 'ignoreUpdate';
  static const _PUSH_LOGIN = '%s_pushLogin';
  static const _CHAT_FONT_SIZE_FACTOR = '%s_chatFontSizeFactor';
  static const _CHAT_BACKGROUND = '%s_chatBackground';
  static const _GROUP_APPLICATION = '%s_groupApplication';
  static const _FRIEND_APPLICATION = '%s_friendApplication';
  static const _DEVICE_ID = 'deviceID';
  static const _ENABLE_VIBRATION = 'enableVibration';
  static const _ENABLE_RING = 'enableRing';
  static const _SCREEN_PWD = 'screenPassword';
  static const _ENABLED_BIOMETRIC = 'enableBiometric';
  static const _CURRENT_UNION_SERVER = "currentUnionServer";
  static const _UNION_SERVER_LIST = "unionServerList";

  static String unionKey(String union) {
    return "UNION_SERVER_" + union;
  }

  static List<String> getUnionServerList() {
    final raw = SpUtil.getString(_UNION_SERVER_LIST);
    if (raw == null || raw.isEmpty) return [];
    final decoded = json.decode(raw);
    return (decoded as List<dynamic>).cast<String>();
  }

  static Future<bool> putUnionServerList(List<String> servers) {
    final result = SpUtil.putString(_UNION_SERVER_LIST, json.encode(servers));
    return result ?? Future.value(true);
  }

  static Future<bool> addUnionToList(String server, int port) {
    final entry = "$server:$port";
    final list = getUnionServerList();
    if (list.contains(entry)) return Future.value(true);
    list.add(entry);
    return putUnionServerList(list);
  }

  static Future<bool> removeUnionFromList(String server, int port) {
    final entry = "$server:$port";
    final list = getUnionServerList();
    list.remove(entry);
    return putUnionServerList(list);
  }

  DataPersistence._();

  static String getDeviceID() {
    var deviceID = SpUtil.getString(_DEVICE_ID);
    if (deviceID!.isEmpty) {
      deviceID = Uuid().v4();
      SpUtil.putString(_DEVICE_ID, deviceID);
    }
    return deviceID;
  }

  static LoginAccount? getAccount() {
    final m = SpUtil.getObject(_ACCOUNT);
    LoginAccount? account = null;
    if (m != null) {
      try {
        account = LoginAccount.fromJson(m!);
      } catch (e) {
        L.d("get account error: ${e}");
        return null;
      }
    }
    return account;
  }

  static Future<bool>? removeAccount() {
    return SpUtil.remove(_ACCOUNT);
  }

  static Future<bool>? putAccount(LoginAccount account) {
    final map = account.toJson();
    return SpUtil.putObject(_ACCOUNT, map);
  }

  static Future<bool>? putIgnoreVersion(String version) {
    return SpUtil.putString(_IGNORE_UPDATE, version);
  }

  static String? getIgnoreVersion() {
    return SpUtil.getString(_IGNORE_UPDATE);
  }

  static int? getLanguage() {
    return SpUtil.getInt(_LANGUAGE);
  }

  static Future<bool>? putLanguage(int index) {
    return SpUtil.putInt(_LANGUAGE, index);
  }

  static Future<bool>? putCurrentUnionServer(String server) {
    return SpUtil.putString(_CURRENT_UNION_SERVER, server);
  }

  static String? getCurrentUnionServer() {
    return SpUtil.getString(_CURRENT_UNION_SERVER);
  }

  static Future<bool>? removeCurrentUnionServer() {
    return SpUtil.remove(_CURRENT_UNION_SERVER);
  }

  static Future<bool>? putUnion(Union union) {
    var key = unionKey(union.server);
    return SpUtil.putObject(key, union.toJson());
  }

  static Union? getUnion(String server) {
    var key = unionKey(server);
    final m = SpUtil.getObject(key);
    Union? union;
    if (m != null) {
      try {
        union = Union.fromJson(m as Map<String, dynamic>);
      } catch (e) {
        union = null;
      }
    }
    return union;
  }

  static Future<bool>? removeUnion(String server) {
    var key = unionKey(server);
    return SpUtil.remove(key);
  }
}

class LocalStorage {
  static save(String key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static get(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  static remove(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
