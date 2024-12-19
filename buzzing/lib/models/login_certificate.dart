import 'dart:convert';
import 'dart:ffi';

import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:buzzing/utils/loogger_util.dart';

// get all binded users
class LoginAccount {
  Account? account;
  LoginUser? loginUser;
  String? server;

  static LoginAccount create() => LoginAccount._();
  LoginAccount._();

  factory LoginAccount.fromJson(Map<dynamic, dynamic> json) {
    LD("parse login account: ${json}");
    final loginAccount = create();
    loginAccount.account = Account.fromJson(json["account"] ?? '{}');
    if (json["loginUser"] != null) {
      loginAccount.loginUser = LoginUser.fromJson(json["loginUser"] ?? '{}');
    }
    if (json["server"] != null) {
      loginAccount.server = json["server"].toString();
    }
    return loginAccount;
  }

  factory LoginAccount.fromAccount(Map<String, dynamic> value) {
    var acc = Account.create();

    final loginAccount = create();
    loginAccount.account = Account.create()..mergeFromProto3Json(value);
    LD("login account: ${loginAccount.account}, src: ${value}");
    return loginAccount;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (loginUser != null) {
      data["loginUser"] = loginUser?.writeToJson();
    }
    data["account"] = account?.writeToJson();
    data["server"] = server;
    return data;
  }

  String toString() {
    return this.toJson().toString();
  }
}
