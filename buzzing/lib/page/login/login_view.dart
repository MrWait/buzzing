import 'package:buzzing/utils/common_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:buzzing/provider/page_providers.dart';
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:buzzing/i18n/strings.g.dart';

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

class LoginPage extends ConsumerWidget {
  Widget tenant_selector(BuildContext context, LoginLogic logic) {
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
                child: Text(t.goBack, style: PageStyle.ts_000000_17sp),
              ),
            ),
            Positioned(
              top: 260.h,
              left: 40.w,
              child: Container(
                width: 420.w,
                height: 100.h,
                child: ListView.builder(
                  itemCount: logic.loginAccount?.account?.users.length ?? 0,
                  itemBuilder: (context, index) {
                    final user = logic.loginAccount?.account?.users[index];
                    return GestureDetector(
                      onTap: () => logic.loginUser(user!, GoRouter.of(context)),
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

  Widget login_controller(BuildContext context, LoginLogic logic) {
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
                      t.welcomeUse,
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
                  child: PhoneInputBox(
                    controller: logic.phoneCtrl,
                    labelStyle: PageStyle.ts_171A1D_14,
                    textStyle: PageStyle.ts_171A1D0_opacity40p_17,
                    hintStyle: PageStyle.ts_171A1D_17,
                    codeStyle: PageStyle.ts_171A1D_17,
                    arrowColor: PageStyle.c_000000,
                    clearBtnColor: PageStyle.c_000000_opacity40p,
                    code: logic.areaCode,
                    onAreaCode: () => logic.openCountryCodePicker(),
                    showClearBtn: logic.showAccountCleanBtn,
                    inputWay: InputWay.phone,
                  ),
                ),
                Positioned(
                  top: 345.h,
                  left: 40.w,
                  width: 295.w,
                  child: logic.isPasswordLogin
                      ? PwdInputBox(
                          controller: logic.pwdCtrl,
                          labelStyle: PageStyle.ts_171A1D_14,
                          hintStyle: PageStyle.ts_171A1D0_opacity40p_17,
                          textStyle: PageStyle.ts_171A1D_17,
                          showClearBtn: logic.showPwdClearBtn,
                          obscureText: logic.obscureText,
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
                Positioned(
                  top: 419.h,
                  left: 40.w,
                  child: GestureDetector(
                    onTap: logic.switchLoginType,
                    behavior: HitTestBehavior.translucent,
                    child: Text(
                      logic.isPasswordLogin
                          ? t.useSMSLogin
                          : t.usePwdLogin,
                      style: PageStyle.ts_0089FF_12,
                    ),
                  ),
                ),
                Positioned(
                  top: 520.h,
                  left: 40.w,
                  width: 295.w,
                  child: DebounceButton(
                    builder: (context, onTap) {
                      return Button(
                          enabled: logic.enabledLoginButton,
                          text: t.login,
                          textStyle: PageStyle.ts_171A1D_32_semibold,
                          onTap: onTap,
                      );
                    },
                    duration: Duration(milliseconds: 200),
                    onTap: () async { logic.login(context); },
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
                          t.forgetPwd,
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
                        child: Text(
                          logic.index == 0
                              ? t.phoneRegister
                              : t.emailRegister,
                          style: PageStyle.ts_0089FF_12,
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

  Widget server_selector(BuildContext context, LoginLogic logic) {
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

  Widget loginStage(BuildContext context, LoginLogic logic, int mode) {
    switch (mode) {
      case 1:
        return login_controller(context, logic);
      case 2:
        return tenant_selector(context, logic);
      default:
        return server_selector(context, logic);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logic = ref.watch(loginLogicProvider);
    return Container(
      child: ListenableBuilder(
        listenable: logic,
        builder: (ctx, _) => Container(child: loginStage(context, logic, logic.loginMode)),
      ),
    );
  }
}
