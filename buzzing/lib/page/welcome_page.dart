import 'dart:async';

import 'package:buzzing/common/dao/user_dao.dart';
import 'package:buzzing/common/style/buzzing_style.dart';
import 'package:buzzing/common/utils/navigator_utils.dart';
import 'package:buzzing/redux/buzzing_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:rive/rive.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatefulWidget {
  static final String sName = "/";
  @override
  State<StatefulWidget> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool hadInit = false;
  String text = "";
  double fontSize = 76;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (hadInit) {
      return;
    }
    hadInit = true;

    Store<BuzzingState> store = StoreProvider.of(context);
    new Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        text = "Welcome";
        fontSize = 60;
      });
    });
    new Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      setState(() {
        text = "BuzzingApp";
        fontSize = 60;
      });
    });
    new Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
      UserDao.initUserInfo(store).then((res) {
        if (res != null && res.result) {
          NavigatorUtils.goHome(context);
        } else {
          NavigatorUtils.goLogin(context);
        }
        return true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<BuzzingState>(builder: (context, store) {
      double size = 200;
      return Material(
        child: new Container(
          color: BuzzingColors.white,
          child: Stack(
            children: <Widget>[
              new Center(
                  child: new Image(
                      image: new AssetImage('static/images/welcome.png'))),
              Align(alignment: Alignment(0.0, 0.3), child: DiffSca),
              Align(),
              new Align(),
            ],
          ),
        ),
      );
    });
  }
}
