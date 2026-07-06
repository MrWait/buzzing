import 'package:buzzing/utils/logger_util.dart';
import 'package:flutter/foundation.dart';

class VcLogic extends ChangeNotifier {
  var inCalling = false;

  void init() {
    L.d('VcLogic init');
  }

  void onJoin() {
    inCalling = true;
    notifyListeners();
  }

  void onLeave() {
    inCalling = false;
    notifyListeners();
  }

  void hangUp() {
    inCalling = false;
    notifyListeners();
  }
}
