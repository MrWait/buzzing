import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/widget/picker.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/utils/loogger_util.dart';
import 'package:window_manager/window_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'button.dart';

class Avatar extends StatelessWidget {
  final String url;
  Widget icon;

  Avatar(this.url, this.icon);

  @override
  Widget build(BuildContext context) {
    if (this.url.isEmpty) {
      return icon;
    } else {
      return Image(
        image: CachedNetworkImageProvider(CommonUtils.fixResourceUrl(this.url)),
      );
    }
  }
}
