import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_capturer/screen_capturer.dart';

Future<CapturedData?> captureScreen(Directory? savePath) async {
  var dir = savePath ?? await getApplicationDocumentsDirectory();
  String imageName = 'Screenshot-${DateTime.now().millisecondsSinceEpoch}.png';
  String imagePath = '${dir.path}/ScreenShots/$imageName';

  var capturedData = await screenCapturer.capture(
      mode: CaptureMode.region,
      imagePath: imagePath,
      copyToClipboard: true,
      silent: true);
  return capturedData;
}
