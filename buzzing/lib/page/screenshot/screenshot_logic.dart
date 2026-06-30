import 'dart:async';
import 'dart:ui' as ui;
import 'package:buzzing/utils/loogger_util.dart';
import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:screen_capturer/screen_capturer.dart';

class ScreenshotService {
  // 打开截图窗口
  static Future<void> startScreenshot() async {
    // 获取屏幕截图
    final Image? fullScreenImage = await captureFullScreen();
    if (fullScreenImage == null) return;

    // 创建截图窗口
    final window = await DesktopMultiWindow.createWindow(
      '{"type": "screenshot", "width": ${ui.window.physicalSize.width}, "height": ${ui.window.physicalSize.height}}',
    );

    // 设置窗口属性（全屏、置顶、无边框）
    window
      ..setFrame(
        Rect.fromLTWH(
          0,
          0,
          ui.window.physicalSize.width / ui.window.devicePixelRatio,
          ui.window.physicalSize.height / ui.window.devicePixelRatio,
        ),
      )
      ..setTitle('Screenshot')
      ..center()
      ..show();

    // 向截图窗口发送全屏图像数据
    window.sendData(await _imageToByteData(fullScreenImage));
  }

  // 捕获全屏图像
  static Future<Image?> captureFullScreen() async {
    try {
      final screenshot = await ScreenCapturer.captureDisplay(
        displayId: 0, // 捕获主显示器
      );
      if (screenshot != null && screenshot.path != null) {
        final image = await decodeImageFromList(await screenshot.toByteData());
        return image;
      }
    } catch (e) {
      LD('捕获屏幕失败: $e');
    }
    return null;
  }

  // 将Image转换为ByteData以便跨窗口传输
  static Future<ByteData> _imageToByteData(Image image) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(image.width.toDouble(), image.height.toDouble());
    canvas.drawImage(image, Offset.zero, Paint());
    final picture = recorder.endRecording();
    final img = await picture.toImage(image.width, image.height);
    return (await img.toByteData(format: ui.ImageByteFormat.png))!;
  }
}
