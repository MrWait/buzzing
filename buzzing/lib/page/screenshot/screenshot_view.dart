import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';

import 'package:buzzing/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:image/image.dart' as img;

class ScreenshotOverlay extends StatefulWidget {
  const ScreenshotOverlay({super.key});

  @override
  State<ScreenshotOverlay> createState() => _ScreenshotOverlayState();
}

class _ScreenshotOverlayState extends State<ScreenshotOverlay> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final GlobalKey _screenKey = GlobalKey();
  late ui.Image fullScreenImage;
  Rect? selectionRect;
  Offset? startPoint;
  bool isSelecting = false;
  late Uint8List imageData;
  final double borderWidth = 2;
  final Color borderColor = Colors.blue;
  final Color overlayColor = Colors.black54;

  @override
  void initState() {
    super.initState();

    _loadImage();
    _setupWindowListener();
  }

  // 加载全屏图像
  Future<void> _loadImage() async {
    imageData = await _screenshotController.captureFromWidget(
      RepaintBoundary(key: _screenKey, child: const ScreenCaptureWidget()),
      delay: const Duration(milliseconds: 300),
    );

    final codec = await ui.instantiateImageCodec(imageData);
    final frame = await codec.getNextFrame();
    setState(() {
      fullScreenImage = frame.image;
    });
  }

  // 设置窗口消息监听
  void _setupWindowListener() {
    /*
    DesktopMultiWindow.setMethodHandler((call, windowId) async {
      if (call.method == 'closeScreenshot') {
        Navigator.of(context).pop();
      }
    });
    */
  }

  // 处理鼠标按下事件，开始选择区域
  void _onMouseDown(Offset position) {
    setState(() {
      startPoint = position;
      isSelecting = true;
      selectionRect = Rect.fromLTWH(position.dx, position.dy, 0, 0);
    });
  }

  // 处理鼠标移动事件，更新选择区域
  void _onMouseMove(Offset position) {
    if (!isSelecting || startPoint == null) return;

    final left = startPoint!.dx < position.dx ? startPoint!.dx : position.dx;
    final top = startPoint!.dy < position.dy ? startPoint!.dy : position.dy;
    final width = (startPoint!.dx - position.dx).abs();
    final height = (startPoint!.dy - position.dy).abs();

    setState(() {
      selectionRect = Rect.fromLTWH(left, top, width, height);
    });
  }

  // 处理鼠标释放事件，结束选择
  void _onMouseUp() {
    setState(() {
      isSelecting = false;
    });
  }

  // 确认截图并处理
  void _confirmScreenshot() {
    if (selectionRect == null) return;

    // 裁剪选中区域
    _cropSelectedArea().then((croppedImage) {
      if (croppedImage != null) {
        // 这里可以添加保存图片或其他处理逻辑
        _saveImage(croppedImage);

        // 关闭截图窗口
        Navigator.of(context).pop();
      }
    });
  }

  // 裁剪选中的区域
  Future<Uint8List?> _cropSelectedArea() async {
    try {
      // 将UI Image转换为可编辑的图像数据
      final byteData = await fullScreenImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final buffer = byteData!.buffer.asUint8List();

      // 使用image库裁剪图像
      final image = img.decodeImage(buffer)!;
      final cropped = img.copyCrop(
        image,
        x: selectionRect!.left.toInt(),
        y: selectionRect!.top.toInt(),
        width: selectionRect!.width.toInt(),
        height: selectionRect!.height.toInt(),
      );

      return img.encodePng(cropped);
    } catch (e) {
      L.d('裁剪图像失败: $e');
      return null;
    }
  }

  // 保存图像（这里简化处理，实际项目中可保存到文件）
  void _saveImage(Uint8List imageData) {
    // 实现保存逻辑，例如使用image_gallery_saver或直接写入文件
    L.d('截图已保存，大小: ${imageData.lengthInBytes} bytes');
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted || !_isImageLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onPanStart: (details) => _onMouseDown(details.globalPosition),
        onPanUpdate: (details) => _onMouseMove(details.globalPosition),
        onPanEnd: (_) => _onMouseUp(),
        child: Stack(
          children: [
            // 全屏背景图（半透明）
            Positioned.fill(
              child: Image.memory(
                imageData,
                fit: BoxFit.contain,
                color: Colors.white.withOpacity(0.3),
                colorBlendMode: BlendMode.dstATop,
              ),
            ),
            // 选择区域外的遮罩
            _buildOverlay(),
            // 选择区域边框
            if (selectionRect != null) _buildSelectionBorder(),
            // 操作按钮
            if (selectionRect != null) _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // 构建选择区域外的遮罩
  Widget _buildOverlay() {
    return CustomPaint(
      painter: OverlayPainter(
        selectionRect: selectionRect,
        overlayColor: overlayColor,
      ),
      size: Size.infinite,
    );
  }

  // 构建选择区域边框
  Widget _buildSelectionBorder() {
    return Positioned(
      left: selectionRect!.left,
      top: selectionRect!.top,
      width: selectionRect!.width,
      height: selectionRect!.height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: borderWidth),
        ),
      ),
    );
  }

  // 构建操作按钮
  Widget _buildActionButtons() {
    return Positioned(
      left: selectionRect!.right + 10,
      top: selectionRect!.top,
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green, size: 32),
            onPressed: _confirmScreenshot,
            tooltip: '确认截图',
          ),
          const SizedBox(height: 10),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red, size: 32),
            onPressed: () => setState(() => selectionRect = null),
            tooltip: '取消选择',
          ),
        ],
      ),
    );
  }

  bool get _isImageLoaded =>
      fullScreenImage.width > 0 && fullScreenImage.height > 0;
}

// 自定义画家，绘制选择区域外的遮罩
class OverlayPainter extends CustomPainter {
  final Rect? selectionRect;
  final Color overlayColor;

  OverlayPainter({this.selectionRect, required this.overlayColor});

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制全屏遮罩
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = overlayColor,
    );

    // 清除选择区域的遮罩，形成"镂空"效果
    if (selectionRect != null) {
      canvas.save();
      canvas.clipRect(selectionRect!, doAntiAlias: true);
      canvas.drawColor(Colors.transparent, BlendMode.clear);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant OverlayPainter oldDelegate) {
    return oldDelegate.selectionRect != selectionRect;
  }
}

Future<void> startScreenShot() async {
  /*
  final window = await DesktopMultiWindow.createWindow(jsonEncode({
    'args1': 'Sub window',
    'args2': 100,
    'args3': true,
    'business': 'screenshot',
  }));
  window
    ..setFrame(const Offset(0, 0) & const Size(1280, 720))
    ..center()
    ..setTitle('Another window')
    ..show();
    */
}

// 用于捕获屏幕内容的组件
// 实际使用中可以替换为需要截图的内容
class ScreenCaptureWidget extends StatelessWidget {
  const ScreenCaptureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: const SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 示例内容
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                '这是一个示例界面，点击相机图标可以捕获当前屏幕',
                style: TextStyle(fontSize: 18),
              ),
            ),
            FlutterLogo(size: 100),
            SizedBox(height: 20),
            Text('Flutter 截图工具演示'),
          ],
        ),
      ),
    );
  }
}
