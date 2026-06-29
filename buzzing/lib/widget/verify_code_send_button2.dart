import 'dart:async';

import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/res/styles.dart';
import 'package:flutter/material.dart';
import 'package:dart_date/dart_date.dart';

final timeCache = <int, int>{};

class VerifyCodeSendButton2 extends StatefulWidget {
  final Future<bool> Function() onTapCallback;
  final int sec;
  final int uniqueID;

  const VerifyCodeSendButton2({
    Key? key,
    this.uniqueID = 0,
    this.sec = 60,
    required this.onTapCallback,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _VerifyCodeSendButtonState();
}

class _VerifyCodeSendButtonState extends State<VerifyCodeSendButton2> {
  Timer? _timer;
  int _second = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  bool get _isEnabled => _second == 0;
  void _start() {
    _cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_second == 0) {
        _cancel();
        setState(() {});
        return;
      }
      _second--;
      setState(() {});
    });
  }

  void _cancel() {
    if (null != _timer) {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _recordTimer() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final end = now + widget.sec * 1000;
    timeCache.addAll({widget.uniqueID: end});
  }

  void _recoverTimer() {
    int? mic = timeCache[widget.uniqueID];
    if (mic != null) {
      final old = DateTime.fromMillisecondsSinceEpoch(mic);
      final now = DateTime.now();
      final lave = old.differenceInSeconds(now);
      if (lave > 0) {
        _second = lave;
        _start();
      }
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () async {
          if (_isEnabled) {
            final success = await widget.onTapCallback.call();
            if (success) {
              _second = widget.sec;
              _recordTimer();
              _start();
            }
          }
        },
        behavior: HitTestBehavior.translucent,
        child: Text(_isEnabled ? t.getVerificationCode : '$_second s',
            style: PageStyle.ts_0089FF_16sp),
      );
}
