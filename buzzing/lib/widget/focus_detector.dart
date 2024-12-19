import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FocusDetector extends StatefulWidget {
  final VoidCallback? onFocusGained;
  final VoidCallback? onFocusLost;
  final VoidCallback? onVisibilityGained;
  final VoidCallback? onVisibilityLost;
  final VoidCallback? onForegroundGained;
  final VoidCallback? onForegroundLost;

  final Widget child;

  const FocusDetector({
    required this.child,
    this.onFocusGained,
    this.onFocusLost,
    this.onVisibilityGained,
    this.onVisibilityLost,
    this.onForegroundGained,
    this.onForegroundLost,
    Key? key,
  }) : super(key: key);

  @override
  _FocusDetectorState createState() => _FocusDetectorState();
}

class _FocusDetectorState extends State<FocusDetector>
    with WidgetsBindingObserver {
  final _visibilityDetectorKey = UniqueKey();
  bool _isWidgetVisible = false;
  bool _isAppInForeground = true;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) => VisibilityDetector(
      key: _visibilityDetectorKey,
      child: widget.child,
      onVisibilityChanged: (visibilityInfo) {});

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
