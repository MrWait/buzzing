import 'dart:async';

import 'package:buzzing/page/home/home_page.dart';
import 'package:buzzing/page/login/login_page.dart';
import 'package:buzzing/widget/never_overscroll_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class NavigatorUtils {
  static pushReplacementNamed(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  static pushNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  static goLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, LoginPage.sName);
  }

  static goHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, HomePage.sName);
  }

  static Future<T?> showBuzzingDialog<T>(
      {required BuildContext context,
      bool barrierDismissible = true,
      WidgetBuilder? builder}) {
    return showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return MediaQuery(
              data: MediaQueryData.fromView(
                      WidgetsBinding.instance.platformDispatcher.views.first)
                  .copyWith(textScaleFactor: 1),
              child: NeverOverScrollIndicator(
                  needOverload: false,
                  child: new SafeArea(child: builder!(context))));
        });
  }
}
