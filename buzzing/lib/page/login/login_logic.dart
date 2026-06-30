import 'package:buzzing/models/model.dart';
import 'package:buzzing/utils/net/apis.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/utils/net/http_util.dart';
import 'package:buzzing/models/login_certificate.dart';
import 'package:buzzing/routes/app_navigator.dart';
import 'package:buzzing/utils/data_persistence.dart';
import 'package:buzzing/utils/loogger_util.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/widget/im_widget.dart';
import 'package:buzzing/widget/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:buzzing/i18n/strings.g.dart';

enum LoginType {
  password,
  sms,
}

class LoginLogic extends ChangeNotifier {
  var phoneCtrl = TextEditingController();
  var emailCtrl = TextEditingController();
  var pwdCtrl = TextEditingController();
  var codeCtrl = TextEditingController();

  var phoneFocusNode = FocusNode();
  var emailFocusNode = FocusNode();
  var showAccountCleanBtn = false;
  var showPwdClearBtn = false;
  var loginMode = 1;
  var obscureText = true;
  var agreedProtocol = true;
  var enabledLoginButton = false;
  var index = 0;
  var areaCode = "+86";
  var loginType = LoginType.password;
  LoginAccount? loginAccount;

  // union selector state
  final dialogServerCtrl = TextEditingController();
  final dialogPortCtrl = TextEditingController(text: "5150");
  var showUnionDropdown = false;
  var unionList = <String>[];
  var currentUnionEntry = "";

  static final _emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');

  void init() {
    initData();
    phoneCtrl.addListener(() {
      showAccountCleanBtn = phoneCtrl.text.isNotEmpty;
      _changeLoginButtonStatus();
      notifyListeners();
    });
    emailCtrl.addListener(() {
      showAccountCleanBtn = emailCtrl.text.isNotEmpty;
      _changeLoginButtonStatus();
      notifyListeners();
    });
    pwdCtrl.addListener(() {
      showPwdClearBtn = pwdCtrl.text.isNotEmpty;
      _changeLoginButtonStatus();
      notifyListeners();
    });
    codeCtrl.addListener(() {
      _changeLoginButtonStatus();
      notifyListeners();
    });
  }

  void dispose() {
    phoneCtrl.dispose();
    emailCtrl.dispose();
    pwdCtrl.dispose();
    codeCtrl.dispose();
    dialogServerCtrl.dispose();
    dialogPortCtrl.dispose();
    phoneFocusNode.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  void login(BuildContext context) async {
    LD('start login');
    if (index == 0 &&
        !CommonUtils.isPhoneNumber(areaCode, phoneCtrl.text)) {
      IMWidget.showToast(t.plsInputRightPhone);
      return;
    }
    if (index == 1 && !_emailRegExp.hasMatch(emailCtrl.text)) {
      IMWidget.showToast(t.plsInputRightEmail);
      return;
    }
    LoadingView.singleton.wrap(context: context, asyncFunction: () async {
      LD("start login");
      var suc = await _login();
      if (suc) {
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
      loginAccount = account;
      loginMode = 2;
      notifyListeners();
      return true;
    } catch (e) {
      LD('login e: ${e}');
    } finally {}
    return false;
  }

  void register() {}

  void toggleEye() {
    obscureText = !obscureText;
    notifyListeners();
  }

  void backToLogin() {
    loginMode = 1;
    notifyListeners();
  }

  void toggleProtocol() {
    agreedProtocol = !agreedProtocol;
    notifyListeners();
  }

  void _changeLoginButtonStatus() {
    enabledLoginButton = (isPasswordLogin && pwdCtrl.text.isNotEmpty ||
            !isPasswordLogin && codeCtrl.text.isNotEmpty) &&
        (phoneCtrl.text.isNotEmpty || emailCtrl.text.isNotEmpty);
  }

  void toggleUnionDropdown() {
    showUnionDropdown = !showUnionDropdown;
    notifyListeners();
  }

  void closeUnionDropdown() {
    showUnionDropdown = false;
    notifyListeners();
  }

  Future<void> selectUnion(String entry) async {
    showUnionDropdown = false;
    final parts = entry.split(":");
    final server = parts[0];
    final port = parts.length > 1 ? int.tryParse(parts[1]) ?? 80 : 80;
    await _connectToServer(server, port);
    notifyListeners();
  }

  void openAddServer() {
    showUnionDropdown = false;
    dialogServerCtrl.text = "";
    dialogPortCtrl.text = "5150";
    notifyListeners();
  }

  Future<void> onAddServer() async {
    final server = dialogServerCtrl.text.trim();
    if (server.isEmpty) return;
    final port = int.tryParse(dialogPortCtrl.text.trim()) ?? 5150;
    await _connectToServer(server, port);
    notifyListeners();
  }

  Future<void> _connectToServer(String server, int port) async {
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
        DataPersistence.addUnionToList(server, port);
        DataPersistence.putCurrentUnionServer(server);
      }
    }
    if (union.config.union.isNotEmpty) {
      L.d("set api url");
      Config.union = union;
      currentUnionEntry = "$server:$port";
      HttpUtil.resetBaseUrl(Config.apiUrl());
      _refreshUnionList();
    } else {
      L.d("sync config error");
      return;
    }
    loginMode = 1;
  }

  void _refreshUnionList() {
    unionList = DataPersistence.getUnionServerList();
  }

  void switchTab(index) {
    this.index = index;
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
    notifyListeners();
  }

  void openCountryCodePicker() async {}
  void forgetPassword() {}

  void initData() {
    _refreshUnionList();
    final saved = DataPersistence.getCurrentUnionServer();
    if (saved != null && saved.isNotEmpty) {
      currentUnionEntry = saved;
      final union = DataPersistence.getUnion(saved);
      if (union != null) {
        Config.union = union;
        currentUnionEntry = "${union.server}:${union.port}";
        HttpUtil.resetBaseUrl(Config.apiUrl());
        loginMode = 1;
      }
    }
  }

  bool get isPasswordLogin => loginType == LoginType.password;

  void switchLoginType() {
    loginType = isPasswordLogin ? LoginType.sms : LoginType.password;
    notifyListeners();
  }

  void loginUser(LoginUser user, GoRouter router) {
    loginAccount!.loginUser = user;
    DataPersistence.putAccount(loginAccount!);
    AppNavigator.startIm(router, user);
  }

  Future<bool> getVerificationCode() async {
    return true;
  }
}
