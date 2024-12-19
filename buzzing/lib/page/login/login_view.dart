import 'package:buzzing/utils/common_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:buzzing/res/strings.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/widget/button.dart';
import 'package:buzzing/widget/code_input_box.dart';
import 'package:buzzing/widget/debounce_button.dart';
import 'package:buzzing/widget/phone_input_box.dart';
import 'package:buzzing/widget/pwd_input_box.dart';
import 'package:buzzing/widget/touch_close_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'login_logic.dart';

class TenantBrief extends StatelessWidget {
  final LoginUser user;
  TenantBrief(LoginUser user) : user = user;
  @override
  Widget build(BuildContext context) {
    var tenantName = user.tenant.name;
    var tenantAvatar = user.tenant.avatar;
    Widget avatar;
    if (user.tenant.id == 0) {
      tenantName = "Personal";
      avatar = Icon(Icons.account_circle_outlined, color: Colors.lightBlue);
    } else {
      avatar = CircleAvatar(
        backgroundImage: Image(
          image: CachedNetworkImageProvider(
            CommonUtils.fixResourceUrl(tenantAvatar),
          ),
        ).image,
        radius: 20,
      );
    }

    tenantName += "(" + user!.tenant.id.toString() + ")";
    return Container(
      child: Row(
        children: [
          avatar,
          Text(tenantName, style: PageStyle.ts_0089FF_12),
        ],
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final logic = Get.find<LoginLogic>();

  Widget tenant_selector(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: 1.sh,
        child: Stack(
          children: [
            Positioned(
              top: 110.h,
              left: 40.w,
              child: GestureDetector(
                onTap: () => logic.backToLogin(),
                child: Text(StrRes.goBack, style: PageStyle.ts_000000_17sp),
              ),
            ),
            Positioned(
              top: 260.h,
              left: 40.w,
              child: Container(
                width: 420.w,
                height: 100.h,
                child: ListView.builder(
                  itemCount: logic.loginAccount.value.account?.users.length,
                  itemBuilder: (context, index) {
                    final user = logic.loginAccount.value.account?.users[index];
                    return GestureDetector(
                      onTap: () => {logic.loginUser(user!)},
                      behavior: HitTestBehavior.translucent,
                      child: TenantBrief(user!),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget login_controller(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: 1.sh,
            child: Stack(
              children: [
                Positioned(
                  top: 136.h,
                  left: 40.w,
                  child: GestureDetector(
                    onDoubleTap: () => logic.toServerConfig(),
                    behavior: HitTestBehavior.translucent,
                    child: Text(
                      StrRes.welcomeUse,
                      style: PageStyle.ts_171A1D_32_semibold,
                    ),
                  ),
                ),
                Positioned(
                  top: 210.h,
                  left: 40.w,
                  child: GestureDetector(
                    onDoubleTap: () => logic.toServerConfig(),
                    behavior: HitTestBehavior.translucent,
                    child: Text(
                      "<- " + Config.apiUrl(),
                      style: PageStyle.ts_171A1D_17,
                    ),
                  ),
                ),
                Positioned(
                  top: 260.h,
                  left: 40.w,
                  width: 295.w,
                  child: Obx(
                    () => PhoneInputBox(
                      controller: logic.phoneCtrl,
                      labelStyle: PageStyle.ts_171A1D_14,
                      textStyle: PageStyle.ts_171A1D0_opacity40p_17,
                      hintStyle: PageStyle.ts_171A1D_17,
                      codeStyle: PageStyle.ts_171A1D_17,
                      arrowColor: PageStyle.c_000000,
                      clearBtnColor: PageStyle.c_000000_opacity40p,
                      code: logic.areaCode.value,
                      onAreaCode: () => logic.openCountryCodePicker(),
                      showClearBtn: logic.showAccountCleanBtn.value,
                      inputWay: InputWay.phone,
                    ),
                  ),
                ),
                Positioned(
                  top: 345.h,
                  left: 40.w,
                  width: 295.w,
                  child: Obx(
                    () => logic.isPasswordLogin
                        ? PwdInputBox(
                            controller: logic.pwdCtrl,
                            labelStyle: PageStyle.ts_171A1D_14,
                            hintStyle: PageStyle.ts_171A1D0_opacity40p_17,
                            textStyle: PageStyle.ts_171A1D_17,
                            showClearBtn: logic.showPwdClearBtn.value,
                            obscureText: logic.obscureText.value,
                            onClickEyesBtn: () => logic.toggleEye(),
                            clearBtnColor: PageStyle.c_000000_opacity40p,
                            eyesBtnColor: PageStyle.c_333333,
                          )
                        : CodeInputBox(
                            controller: logic.codeCtrl,
                            labelStyle: PageStyle.ts_171A1D_14,
                            hintStyle: PageStyle.ts_171A1D0_opacity40p_17,
                            textStyle: PageStyle.ts_171A1D_17,
                            onClickCodeBtn: logic.getVerificationCode,
                          ),
                  ),
                ),
                Positioned(
                  top: 419.h,
                  left: 40.w,
                  child: GestureDetector(
                    onTap: logic.switchLoginType,
                    behavior: HitTestBehavior.translucent,
                    child: Obx(
                      () => Text(
                        logic.isPasswordLogin
                            ? StrRes.useSMSLogin
                            : StrRes.usePwdLogin,
                        style: PageStyle.ts_0089FF_12,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 520.h,
                  left: 40.w,
                  width: 295.w,
                  child: DebounceButton(
                    builder: (context, onTap) {
                      return Obx(
                        () => Button(
                          enabled: logic.enabledLoginButton.value,
                          text: StrRes.login,
                          textStyle: PageStyle.ts_171A1D_32_semibold,
                          onTap: onTap,
                        ),
                      );
                    },
                    duration: Duration(milliseconds: 200),
                    onTap: () async => await logic.login(),
                  ),
                ),
                Positioned(
                  bottom: 60.h,
                  width: 375.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      GestureDetector(
                        onTap: () => logic.forgetPassword(),
                        behavior: HitTestBehavior.translucent,
                        child: Text(
                          StrRes.forgetPwd,
                          style: PageStyle.ts_0089FF_12,
                        ),
                      ),
                      Container(
                        width: 1.w,
                        height: 15.h,
                        color: PageStyle.c_A2A3A5,
                        margin: EdgeInsets.symmetric(horizontal: 12.w),
                      ),
                      GestureDetector(
                        onTap: () => logic.register(),
                        behavior: HitTestBehavior.translucent,
                        child: Obx(
                          () => Text(
                            logic.index.value == 0
                                ? StrRes.phoneRegister
                                : StrRes.emailRegister,
                            style: PageStyle.ts_0089FF_12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget server_selector(BuildContext context) {
    return Container(
      height: 1.sh,
      child: Stack(
        children: [
          Positioned(
            top: 260.h,
            left: 40.w,
            width: 295.w,
            child: TextField(controller: logic.serverCtl),
          ),
          Positioned(
            top: 300.h,
            left: 40.w,
            width: 295.w,
            child: TextField(controller: logic.portCtl),
          ),
          Positioned(
            top: 400.h,
            left: 40.w,
            child: DebounceButton(
              duration: Duration(microseconds: 200),
              builder: (conttext, onTap) {
                return Button(
                  text: "Connect",
                  textStyle: PageStyle.ts_171A1D0_opacity40p_17,
                  onTap: onTap,
                );
              },
              onTap: () async => logic.connectToServer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget loginStage(BuildContext context, int mode) {
    switch (mode) {
      case 1:
        return login_controller(context);
      case 2:
        return tenant_selector(context);
      default:
        return server_selector(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Obx(
        () => Container(child: loginStage(context, logic.loginMode.value)),
      ),
    );
  }
}
