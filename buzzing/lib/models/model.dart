import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/models/idl/feed.pb.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/sdk.pb.dart';
import 'package:buzzing/models/idl/message.pb.dart';
import 'package:buzzing/models/idl/user.pb.dart';
import 'package:buzzing/widget/message.dart';
import 'package:buzzing/widget/feedcard.dart';
import 'package:buzzing/utils/logger_util.dart';

class UnionConfig {
  String union = "";
  int unionId = 0;
  String gateway = "";
  int gatewayPort = 0;
  String ws = "";
  int wsPort = 0;
  String rtc = "";
  int rtcPort = 0;
  String uploadFilePath = "";
  String uploadIconPath = "";
  String uploadAvatarPath = "";
  String apiGateway = "";
  String apiRegister = "";
  String apiLogin = "";
  List<String> features = [];

  UnionConfig.empty();
  UnionConfig();

  UnionConfig.Default() {
    union = "https://www.buzzing-im.com";
    unionId = 1024;
    gateway = "https://www.buzzing-im.com";
    gatewayPort = 5150;
    ws = "ws=//www.buzzing-im.com";
    wsPort = 8889;
    rtc = "www.buzzing-im.com";
    rtcPort = 8086;
    uploadFilePath = "/storage/file/upload";
    uploadIconPath = "/storage/icon/upload";
    uploadAvatarPath = "/storage/avatar/upload";
    apiGateway = "/api/v1";
    apiRegister = "/api/accounts/register";
    apiLogin = "/api/accounts/login";
    features = ["im", "calendar", "meeting"];
  }

  factory UnionConfig.fromJson(Map<String, dynamic> json) =>
      _$UnionConfigFromJson(json);
  factory UnionConfig.fromString(String val) =>
      _$UnionConfigFromJson(jsonDecode(val));

  Map<String, dynamic> toJson() => _$UnionConfigToJson(this);
  String toString() => toJson().toString();
}

UnionConfig _$UnionConfigFromJson(Map<String, dynamic> json) => UnionConfig()
  ..union = json['union'] as String
  ..unionId = (json['union_id'] as num).toInt()
  ..gateway = json['gateway'] as String
  ..gatewayPort = (json['gateway_port'] as num).toInt()
  ..ws = json['ws'] as String
  ..wsPort = (json['ws_port'] as num).toInt()
  ..rtc = json['rtc'] as String
  ..rtcPort = (json['rtc_port'] as num).toInt()
  ..uploadFilePath = json['upload_file_path'] as String
  ..uploadIconPath = json['upload_icon_path'] as String
  ..uploadAvatarPath = json['upload_avatar_path'] as String
  ..apiGateway = json['api_gateway'] as String
  ..apiRegister = json['api_register'] as String
  ..apiLogin = json['api_login'] as String
  ..features = (json['features'] as List<dynamic>)
      .map((e) => e as String)
      .toList();

Map<String, dynamic> _$UnionConfigToJson(UnionConfig instance) =>
    <String, dynamic>{
      'union': instance.union,
      'union_id': instance.unionId,
      'gateway': instance.gateway,
      'gateway_port': instance.gatewayPort,
      'ws': instance.ws,
      'ws_port': instance.wsPort,
      'rtc': instance.rtc,
      'rtc_port': instance.rtcPort,
      'upload_file_path': instance.uploadFilePath,
      'upload_icon_path': instance.uploadIconPath,
      'upload_avatar_path': instance.uploadAvatarPath,
      'api_gateway': instance.apiGateway,
      'api_register': instance.apiRegister,
      'api_login': instance.apiLogin,
      'features': instance.features,
    };

class Union {
  Union();
  Union.empty();

  String server = "";
  int port = 0;
  UnionConfig config = UnionConfig.empty();

  void setConfig(UnionConfig newConfig) {
    config = newConfig;
    server = config.gateway;
    if (!server.startsWith("http")) {
      server = "http://" + server;
    }
    port = config.gatewayPort;
  }

  String apiUrl() {
    var url = server;
    if (port != 80) {
      url += ":" + port.toString();
    }
    return url;
  }

  factory Union.fromJson(Map<String, dynamic> json) => _$UnionFromJson(json);
  factory Union.fromString(String val) => Union.fromJson(jsonDecode(val));

  Map<String, dynamic> toJson() => _$UnionToJson(this);
  String toString() => toJson().toString();
}

Union _$UnionFromJson(Map<String, dynamic> json) => Union()
  ..server = json['server'] as String
  ..port = json['port'] as int
  ..config = UnionConfig.fromJson(json['config'] as Map<String, dynamic>);

Map<String, dynamic> _$UnionToJson(Union instance) => <String, dynamic>{
  'server': instance.server,
  'port': instance.port,
  'config': instance.config,
};

class ApiResp {
  int code;
  String msg;
  dynamic data;
  ApiResp.fromJson(Map<String, dynamic> map)
    : code = map["code"],
      msg = map["msg"],
      data = map["data"];
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code;
    data['msg'] = msg;
    data['data'] = data;
    return data;
  }
}

class UpgradeInfoV2 {
  String? buildBuildVersion;
  String? forceUpdateVersion;
  String? forceUpdateVersionNo;
  bool? needForceUpdate;
  String? downloadURL;
  bool? buildHaveNewVersion;
  String? buildVersionNo;
  String? buildVersion;
  String? buildUpdateDescription;
  String? appKey;
  String? buildKey;
  String? buildName;
  String? buildIcon;
  String? buildFileKey;
  String? buildFileSize;

  UpgradeInfoV2({
    this.buildBuildVersion,
    this.forceUpdateVersion,
    this.forceUpdateVersionNo,
    this.needForceUpdate,
    this.downloadURL,
    this.buildHaveNewVersion,
    this.buildVersionNo,
    this.buildVersion,
    this.buildUpdateDescription,
    this.appKey,
    this.buildKey,
    this.buildName,
    this.buildIcon,
    this.buildFileSize,
    this.buildFileKey,
  });

  UpgradeInfoV2.fromJson(Map<String, dynamic> json) {
    buildBuildVersion = json['buildBuildVersion'];
    forceUpdateVersion = json['forceUpdateVersion'];
    forceUpdateVersionNo = json['forceUpdateVersionNo'];
    needForceUpdate = json['needForceUpdate'];
    downloadURL = json['downloadURL'];
    buildHaveNewVersion = json['buildHaveNewVersion'];
    buildVersionNo = json['buildVersionNo'];
    buildVersion = json['buildVersion'];
    buildUpdateDescription = json['buildUpdateDescription'];
    appKey = json['appKey'];
    buildKey = json['buildKey'];
    buildName = json['buildName'];
    buildIcon = json['buildIcon'];
    buildFileKey = json['buildFileKey'];
    buildFileSize = json['buildFileSize'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['buildBuildVersion'] = this.buildBuildVersion;
    data['forceUpdateVersion'] = this.forceUpdateVersion;
    data['forceUpdateVersionNo'] = this.forceUpdateVersionNo;
    data['needForceUpdate'] = this.needForceUpdate;
    data['downloadURL'] = this.downloadURL;
    data['buildHaveNewVersion'] = this.buildHaveNewVersion;
    data['buildVersionNo'] = this.buildVersionNo;
    data['buildVersion'] = this.buildVersion;
    data['buildUpdateDescription'] = this.buildUpdateDescription;
    data['appKey'] = this.appKey;
    data['buildKey'] = this.buildKey;
    data['buildName'] = this.buildName;
    data['buildIcon'] = this.buildIcon;
    data['buildFileKey'] = this.buildFileKey;
    data['buildFileSize'] = this.buildFileSize;
    return data;
  }
}

enum CalendarView {
  agenda("List", Icons.list),
  day("One Day", Icons.calendar_view_day_outlined),
  day3("Three days", Icons.view_column),
  day3Draggable("Three days - Draggable events", Icons.view_column),
  month("Month", Icons.calendar_month),
  multi_column2("Multi columns 1", Icons.view_column_outlined),
  multi_column1("Multi columns 2", Icons.view_column_outlined),
  day7("Seven days (web or tablet)", Icons.calendar_view_week);

  const CalendarView(this.text, this.icon);

  final String text;
  final IconData icon;
}

class Model {
  static Widget messageBox(Int64 id, Int64 userId, Entity entity) {
    var msg = entity.messages[id];
    if (msg != null) {
      var desc = "(" + msg.pos.toString() + ", " + msg.id.toString() + ")";
      var user = entity.users[msg.fromId];
      var avatar = "";
      var name = "";
      if (user != null) {
        return MessageBox(msg: msg, user: user);
      }

      return MessageWidget(
        icon: "M",
        desc: desc,
        simple: false,
        text: msg.summary,
        avatar: avatar,
        userId: userId,
        name: name,
      );
    } else {
      return MessageWidget(simple: true, text: "Error", userId: 0);
    }
  }

  static Widget message(Int64 id, Int64 userId, Entity entity) {
    var msg = entity.messages[id];
    if (msg != null) {
      var desc = "(" + msg.pos.toString() + ", " + msg.id.toString() + ")";
      var avatar = "";
      var name = "";
      var user = entity.users[msg.fromId];
      if (user != null) {
        avatar = user.avatar;
        name = user.name;
      }

      return MessageWidget(
        icon: "M",
        desc: desc,
        simple: false,
        text: msg.summary,
        avatar: avatar,
        userId: userId,
        name: name,
      );
    } else {
      return MessageWidget(simple: true, text: "Error", userId: 0);
    }
  }

  static Widget feed(Int64 id, Entity entity, Function onTap) {
    var feed = entity.feeds[id];
    if (feed == null) {
      L.w("feed not exists in entity: ${id}");
      return FeedCard(
        icon: Icons.group,
        title: "Error" + id.toString(),
        onTap: () {},
      );
    }
    var msg = entity.messages[feed.referId];
    var m = feed.rankTimeMs.toString();
    if (msg != null) {
      m = m + ", " + msg.summary;
    }

    var title = "";
    var chat = entity.chats[feed.id];
    if (chat != null) {
      title = chat.name;
    }

    if (title.length == 0) {
      title = "[" + id.toString() + "]";
    }

    return FeedCard(icon: Icons.group, title: title, msg: m, onTap: onTap);
  }
}

class DataResult {
  var data;
  bool result;
  Function? next;
  DataResult(this.data, this.result, {this.next});
}
