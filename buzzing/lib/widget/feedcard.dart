import 'package:flutter/material.dart';
import 'package:buzzing/res/styles.dart';
import 'package:get/get.dart';

// icon, title, msg, icon
class FeedCard extends StatelessWidget {
  late IconData icon;
  late String title;
  late String msg;
  late Function onTap;
  FeedCard({required icon, required title, required onTap, msg})
      : icon = icon,
        msg = msg,
        title = title,
        onTap = onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      width: 260,
      child: GestureDetector(
          onTap: () => onTap(),
          child: Row(
            children: [
              Container(
                  height: 54,
                  width: 54,
                  color: PageStyle.c_F0F0F0,
                  child: Icon(icon, color: Colors.cyan)),
              Column(children: [
                Expanded(
                    child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
                Expanded(
                    child: Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          msg,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ))),
              ]),
            ],
          )),
    );
  }
}
