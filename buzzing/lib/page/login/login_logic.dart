import 'package:buzzing/models/model.dart';
import 'package:buzzing/controller/app_controller.dart';
import 'package:buzzing/utils/net/apis.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/utils/net/http_util.dart';
import 'package:buzzing/models/login_certificate.dart';
import 'package:buzzing/res/strings.dart';
import 'package:buzzing/routes/app_navigator.dart';
import 'package:buzzing/utils/data_persistence.dart';
import 'package:buzzing/utils/loogger_util.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/widget/im_widget.dart';
import 'package:buzzing/widget/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum LoginType {
  password,
  sms,
}

class LoginLogic extends GetxController {
  var app = Get.find<AppController>();
  var phoneCtrl = TextEditingController();
  var emailCtrl = TextEditingController();
  var pwdCtrl = TextEditingController();
  var codeCtrl = TextEditingController();
  var serverCtl = TextEditingController();
  var portCtl = TextEditingController();
  var phoneFocusNode = FocusNode();
  var emailFocusNode = FocusNode();
  var showAccountCleanBtn = false.obs;
  var showPwdClearBtn = false.obs;
  // 0: server; 1: login; 2: tenant
  var loginMode = 0.obs;
  var obscureText = true.obs;
  var agreedProtocol = true.obs;
  // TODO: add imlogic and push logic
  var enabledLoginButton = false.obs;
  var index = 0.obs;
  var areaCode = "+86".obs;
  var loginType = LoginType.password.obs;
  var loginAccount = LoginAccount.create().obs;
  login() async {
    LD('start login');
    if (index.value == 0 &&
        !CommonUtils.isPhoneNumber(areaCode.value, phoneCtrl.text)) {
      IMWidget.showToast(StrRes.plsInputRightPhone);
      return;
    }
    if (index.value == 1 && !GetUtils.isEmail(emailCtrl.text)) {
      IMWidget.showToast(StrRes.plsInputRightEmail);
      return;
    }
    LoadingView.singleton.wrap(asyncFunction: () async {
      LD("start login");
      var suc = await _login();
      if (suc) {
        //AppNavigator.startIm();
      }
    });
  }

  Future<bool> _login() async {
    try {
      var account =
          await Apis.login(mobile: phoneCtrl.text, password: pwdCtrl.text);
      account.server = Config.union.config.union;
      await DataPersistence.putAccount(account);
      LD("login success, account: ${account}");
      loginAccount.value = account;
      loginMode.value = 2;
      return true;
    } catch (e) {
      LD('login e: ${e}');
    } finally {}
    return false;
  }

  void register() {}

  void toggleEye() {
    obscureText.value = !obscureText.value;
  }

  void backToLogin() {
    loginMode.value = 1;
  }

  @override
  void onReady() {
    phoneCtrl.addListener(() {
      showAccountCleanBtn.value = phoneCtrl.text.isNotEmpty;
      _changeLoginButtonStatus();
    });
    emailCtrl.addListener(() {
      showAccountCleanBtn.value = emailCtrl.text.isNotEmpty;
      _changeLoginButtonStatus();
    });
    pwdCtrl.addListener(() {
      showPwdClearBtn.value = pwdCtrl.text.isNotEmpty;
      _changeLoginButtonStatus();
    });
    codeCtrl.addListener(() {
      _changeLoginButtonStatus();
    });
    super.onReady();
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    emailCtrl.dispose();
    pwdCtrl.dispose();
    codeCtrl.dispose();
    phoneFocusNode.dispose();
    emailFocusNode.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    initData();
    super.onInit();
  }

  void toggleProtocol() {
    agreedProtocol.value = !agreedProtocol.value;
  }

  void _changeLoginButtonStatus() {
    enabledLoginButton.value = (isPasswordLogin && pwdCtrl.text.isNotEmpty ||
            !isPasswordLogin && codeCtrl.text.isNotEmpty) &&
        (phoneCtrl.text.isNotEmpty || emailCtrl.text.isNotEmpty);
  }

  void toServerConfig() {
    loginMode.value = 0;
  }

  Future<void> connectToServer() async {
    // check server
    var server = serverCtl.text;
    if (server.isEmpty) {
      return;
    }
    var port = int.parse(portCtl.text);
    if (port == 0) {
      port = 80;
    }
    L.d("connect to server, ${server} ${port}");
    var union = DataPersistence.getUnion(server);
    if (union == null) {
      union = Union.empty();
      union.server = server;
      union.port = port;
      var url = union.apiUrl();
      Config.union = union;
      HttpUtil.resetBaseUrl(url);
      var config = await Apis.syncConfig();
      L.d("sync config: ${config}");
      if (config != null) {
        union.setConfig(config);
        DataPersistence.putUnion(union);
        DataPersistence.putCurrentUnionServer(server);
      }
    }
    if (union != null) {
      L.d("set api url");
      Config.union = union;
      HttpUtil.resetBaseUrl(Config.apiUrl());
    } else {
      L.d("sync config error");
      return;
    }

    loginMode.value = 1;
  }

  void switchTab(index) {
    this.index.value = index;
    phoneCtrl.clear();
    emailCtrl.clear();
    pwdCtrl.clear();
    if (index == 0) {
      emailFocusNode.unfocus();
      phoneFocusNode.requestFocus();
    } else {
      phoneFocusNode.unfocus();
      emailFocusNode.requestFocus();
    }
  }

  void openCountryCodePicker() async {}
  void forgetPassword() {}
  void initData() {
    if (Config.currentUnion.isNotEmpty &&
        Config.union.server == Config.currentUnion) {
      loginMode.value = 1;
    }
  }

  bool get isPasswordLogin => loginType.value == LoginType.password;

  void switchLoginType() {
    loginType.value = isPasswordLogin ? LoginType.sms : LoginType.password;
  }

  void loginUser(LoginUser user) {
    loginAccount.value.loginUser = user;
    DataPersistence.putAccount(loginAccount.value);
    AppNavigator.startIm(user);
  }

  Future<bool> getVerificationCode() async {
    return true;
  }
}
