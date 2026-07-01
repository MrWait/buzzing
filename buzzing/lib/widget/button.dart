import 'package:buzzing/res/theme.dart';
import 'package:buzzing/utils/screen_ext.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    Key? key,
    required this.text,
    this.enabled = true,
    this.color,
    this.disabledColor,
    this.radius = 4,
    this.textStyle,
    this.disabledTtextStyle,
    this.onTap,
    this.height,
    this.margin,
  }) : super(key: key);
  final Color? color;
  final Color? disabledColor;
  final double radius;
  final TextStyle? textStyle;
  final TextStyle? disabledTtextStyle;
  final String text;
  final double? height;
  final Function()? onTap;
  final EdgeInsetsGeometry? margin;
  final bool enabled;

  Color _backgroundColor(ColorScheme cs) => enabled
      ? color ?? cs.primary
      : disabledColor ?? cs.primary.withValues(alpha: 0.4);

  TextStyle _textStyle(ColorScheme cs, TextTheme tt) => enabled
      ? textStyle ?? tt.titleLarge!.copyWith(color: cs.onPrimary)
      : disabledTtextStyle ?? tt.titleLarge!.copyWith(color: cs.onPrimary);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
        margin: margin,
        child: Material(
          type: MaterialType.transparency,
          child: Ink(
              height: height ?? 44.h,
              decoration: BoxDecoration(
                  color: _backgroundColor(cs),
                  borderRadius: BorderRadius.circular(radius)),
              child: InkWell(
                  onTap: enabled ? onTap : null,
                  borderRadius: BorderRadius.circular(radius),
                  child: Container(
                      alignment: Alignment.center,
                      child: Text(text, style: _textStyle(cs, tt))))),
        ));
  }
}

Widget NaviButton(BuildContext context, Function()? onTap, IconData? icon) {
  final cs = Theme.of(context).colorScheme;
  return GestureDetector(
      onTap: onTap ?? () => {},
      behavior: HitTestBehavior.translucent,
      child: Container(
          height: 44, width: 44, child: Icon(icon, color: cs.primary)));
}
