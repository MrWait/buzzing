import 'package:flutter/material.dart';

class BuzzingInputWidget extends StatefulWidget {
  final bool obscureText;
  final String? hintText;
  final IconData? iconData;
  final ValueChanged<String>? onChanged;
  final TextStyle? textStyle;
  final TextEditingController? controller;

  BuzzingInputWidget(
      {Key? super.key,
      this.hintText,
      this.iconData,
      this.onChanged,
      this.textStyle,
      this.controller,
      this.obscureText = false});

  @override
  _BuzzingInputWidgetState createState() => new _BuzzingInputWidgetState();
}

class _BuzzingInputWidgetState extends State<BuzzingInputWidget> {
  @override
  Widget build(BuildContext context) {
    return new TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        obscureText: widget.obscureText,
        decoration: new InputDecoration(
          hintText: widget.hintText,
          icon: widget.iconData == null ? null : new Icon(widget.iconData),
        ),
        magnifierConfiguration: TextMagnifierConfiguration(magnifierBuilder: (
          BuildContext context,
          MagnifierController controller,
          ValueNotifier<MagnifierInfo> magnifierInfo,
        ) {
          return null;
        }));
  }
}
