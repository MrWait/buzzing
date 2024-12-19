import 'dart:async';

import 'package:flutter/material.dart';

typedef DebounceChildBuilder = Widget Function(
    BuildContext context, Function()? onTap);

class DebounceButton extends StatefulWidget {
  final DebounceChildBuilder builder;
  final Future Function() onTap;
  final Duration? duration;
  const DebounceButton(
      {Key? key, required this.builder, required this.onTap, this.duration})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _DebounceButtonState();
}

class _DebounceButtonState extends State<DebounceButton> {
  Timer? _timer;
  var _enabled = true;
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _click() {
    if (_enabled) {
      _enabled = false;
      widget.onTap().whenComplete(() => {});
      if (_isEnabledTimer) {
        _timer?.cancel();
        _timer = Timer(widget.duration!, () {
          _timer?.cancel();
          _enabled = true;
        });
      }
    }
  }

  bool get _isEnabledTimer => null != widget.duration;

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _click);
  }
}
