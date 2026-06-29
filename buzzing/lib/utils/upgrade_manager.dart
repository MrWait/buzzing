import 'dart:io';

import 'package:buzzing/models/model.dart';
import 'package:buzzing/utils/data_persistence.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';

class UpgradeManager {
  PackageInfo? packageInfo;
  UpgradeInfoV2? upgradeInfoV2;
  var isShowUpgradeDialog = false;
  var isNowIgnoreUpdate = false;
  final subject = PublishSubject<double>();

  void closeSubject() {
    subject.close();
  }

  void ignoreUpdate() {
    DataPersistence.putIgnoreVersion(upgradeInfoV2!.buildVersion!);
  }

  void laterUpdate() {
    isNowIgnoreUpdate = true;
  }

  getAppInfo() async {
    if (packageInfo == null) {
      packageInfo = await PackageInfo.fromPlatform();
    }
  }

  void nowUpdate() async {
    throw UnimplementedError();
  }

  void checkUpdate() async {
    throw UnimplementedError();
  }

  autoCheckVersionUpgrade() async {
    if (!Platform.isAndroid) return;
    throw UnimplementedError();
  }
}
