import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/widget/verify_code_send_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buzzing/utils/screen_ext.dart';

class CodeInputBox extends StatelessWidget {
  const CodeInputBox({
    Key? key,
    required this.controller,
    required this.labelStyle,
    required this.textStyle,
    required this.hintStyle,
    this.inputFormatters,
    this.maxLength,
    this.autofocus = false,
    required this.onClickCodeBtn,
  }) : super(key: key);
  final TextStyle labelStyle;
  final TextStyle textStyle;
  final TextStyle hintStyle;
  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool autofocus;
  final Future<bool> Function() onClickCodeBtn;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: BorderDirectional(
              bottom: BorderSide(color: Color(0xFFD8D8D8), width: 1.h))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.verificationCode, style: labelStyle),
          SizedBox(height: 10.h),
          Container(
            height: 28.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _textField()),
                SizedBox(width: 14.w),
                VerifyCodeSendButton2(onTapCallback: onClickCodeBtn),
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
        keyboardType: TextInputType.numberWithOptions(decimal: false),
        textInputAction: TextInputAction.next,
        style: textStyle,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        autofocus: autofocus,
        decoration: InputDecoration(
          hintText: t.plsInputVerificationCode,
          hintStyle: hintStyle,
          isDense: true,
          contentPadding: EdgeInsets.all(0),
          border: InputBorder.none,
        ),
      );

  Widget _codeTextBtn() => GestureDetector(
        onTap: onClickCodeBtn,
        behavior: HitTestBehavior.translucent,
        child:
            Text(t.getVerificationCode, style: PageStyle.ts_0089FF_16sp),
      );
}
