import 'package:buzzing/utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
