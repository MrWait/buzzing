import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingView {
  static final LoadingView singleton = LoadingView._();

  factory LoadingView() => singleton;

  LoadingView._();

  OverlayEntry? _overlayEntry;
  bool _isVisible = false;

  Future<T> wrap<T>(
      {required BuildContext context,
      required Future<T> Function() asyncFunction}) async {
    show(context);
    T data;
    try {
      data = await asyncFunction();
    } on Exception catch (_) {
      rethrow;
    } finally {
      dismiss();
    }
    return data;
  }

  void show(BuildContext context) async {
    if (_isVisible) return;
    _overlayEntry = OverlayEntry(
        builder: (BuildContext context) => Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
              child: Center(child: SpinKitCircle(color: Colors.blueAccent)),
            ));
    _isVisible = true;
    Overlay.of(context).insert(_overlayEntry!);
  }

  dismiss() async {
    if (!_isVisible) return;
    _isVisible = false;
    _overlayEntry?.remove();
  }
}
