import 'dart:io' show Platform;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ScreenUtil {
  static double _screenWidth = 375;
  static double _screenHeight = 812;
  static final double _designWidth = 375;
  static final double _designHeight = 812;

  static bool get _isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;

  static void init({required BoxConstraints constraints}) {
    _screenWidth = constraints.maxWidth;
    _screenHeight = constraints.maxHeight;
  }

  static double scaleW(num val) =>
      _isDesktop ? val.toDouble() : val.toDouble() * _screenWidth / _designWidth;

  static double scaleH(num val) =>
      _isDesktop ? val.toDouble() : val.toDouble() * _screenHeight / _designHeight;

  static double scaleSp(num val) => scaleW(val);
}

extension ScreenExtension on num {
  double get sp => ScreenUtil.scaleSp(this);
  double get h => ScreenUtil.scaleH(this);
  double get w => ScreenUtil.scaleW(this);
  double get sh => toDouble() * ScreenUtil.screenHeight;
  double get sw => toDouble() * ScreenUtil.screenWidth;
}
