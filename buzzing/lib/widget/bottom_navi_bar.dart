import 'package:flutter/material.dart';
import 'package:buzzing/res/theme.dart';

class BottomNaviBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bt = Theme.of(context).extension<BuzzingTheme>()!;
    return Container(
        color: bt.success,
        width: 44.0,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("L", textAlign: TextAlign.center),
          Text("1", textAlign: TextAlign.center),
          Text("2", textAlign: TextAlign.center),
          Text("3", textAlign: TextAlign.center),
          Text("4", textAlign: TextAlign.center),
        ]));
  }
}
