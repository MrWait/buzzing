import 'package:buzzing/res/images.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buzzing/utils/screen_ext.dart';

class PwdInputBox extends StatelessWidget {
  const PwdInputBox({
    Key? key,
    required this.controller,
    required this.labelStyle,
    required this.textStyle,
    required this.hintStyle,
    this.clearBtnColor,
    this.eyesBtnColor,
    this.showClearBtn = false,
    this.obscureText = true,
    this.onClickEyesBtn,
    this.inputFormatters,
    this.maxLength,
    this.autofocus = false,
  }) : super(key: key);
  final TextStyle labelStyle;
  final TextStyle textStyle;
  final TextStyle hintStyle;
  final Color? eyesBtnColor;
  final Color? clearBtnColor;
  final bool showClearBtn;
  final bool obscureText;
  final TextEditingController controller;
  final Function? onClickEyesBtn;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool autofocus;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(color: Color(0xFFD8D8D8), width: 1.h),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.pwd, style: labelStyle),
          SizedBox(height: 10.h),
          Container(
            height: 28.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _textField()),
                _clearBtn(),
                SizedBox(width: 14.w),
                _eyesBtn(),
              ],
            ),
          ),
          SizedBox(height: 6.h),
        ],
      ),
    );
  }

  Widget _textField() => TextField(
        controller: controller,
        textInputAction: TextInputAction.next,
        style: textStyle,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        autofocus: autofocus,
        decoration: InputDecoration(
            hintText: t.plsInputPwd,
            hintStyle: hintStyle,
            isDense: true,
            contentPadding: EdgeInsets.all(0),
            border: InputBorder.none),
      );

  Widget _clearBtn() => Visibility(
      visible: showClearBtn,
      child: GestureDetector(
        onTap: () {
          controller.clear();
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
            child: Image.asset(ImageRes.ic_clearInput,
                color: clearBtnColor, width: 14.w, height: 14.w)),
      ));

  Widget _eyesBtn() => GestureDetector(
        onTap: () {
          onClickEyesBtn?.call();
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
          child: Image.asset(
              obscureText ? ImageRes.ic_eyeClose : ImageRes.ic_eyeOpen,
              color: eyesBtnColor,
              width: 20.w,
              height: 12.w),
        ),
      );
}
