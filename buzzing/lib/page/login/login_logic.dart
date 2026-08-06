import 'dart:convert';

import 'package:buzzing/controller/im.dart';
import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/utils/net/apis.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/utils/net/http_util.dart';
import 'package:buzzing/models/login_certificate.dart';
import 'package:buzzing/routes/app_navigator.dart';
import 'package:buzzing/utils/data_persistence.dart';
import 'package:buzzing/utils/logger_util.dart';
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
  final SdkController sdk;
  final ImController im;
  LoginLogic({required this.sdk, required this.im});

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

  /// 解析下拉项 "server:port"：按最后一个冒号切分，
  /// 兼容 "http(s)://host:port"（用户常直接粘贴完整地址）与 host 内嵌端口的情况，
  /// 避免把 "http://host:5150" 错误解析成 server="http"、port=80 导致删除/连接失败。
  static (String, int) _parseUnionEntry(String entry) {
    final idx = entry.lastIndexOf(":");
    if (idx < 0) return (entry, 80);
    final server = entry.substring(0, idx);
    final port = int.tryParse(entry.substring(idx + 1)) ?? 80;
    return (server, port);
  }

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
    L.d('start login');
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
      L.d("start login");
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
      L.d("login success, account: ${account}");
      loginAccount = account;
      loginMode = 2;
      notifyListeners();
      return true;
    } catch (e) {
      L.d('login e: ${e}');
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
    final (server, port) = _parseUnionEntry(entry);
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

  /// 删除已保存的连接配置，若删除的是当前选中的配置则同时重置当前连接
  Future<void> removeUnion(String entry) async {
    final (server, port) = _parseUnionEntry(entry);
    // 精确删除列表项：removeUnionFromList 会以 "server:port" 重组，
    // 兼容协议前缀后重组结果与下拉项完全一致，避免删不干净。
    await DataPersistence.removeUnionFromList(server, port);
    await DataPersistence.removeUnion(server);
    if (_isSameUnion(currentUnionEntry, entry)) {
      currentUnionEntry = "";
      await DataPersistence.removeCurrentUnionServer();
    }
    _refreshUnionList();
    notifyListeners();
  }

  /// 判断两个 "server:port" 是否指向同一服务（忽略 http(s):// 前缀差异）
  bool _isSameUnion(String entryA, String entryB) {
    if (entryA.isEmpty || entryB.isEmpty) return entryA == entryB;
    final (serverA, portA) = _parseUnionEntry(entryA);
    final (serverB, portB) = _parseUnionEntry(entryB);
    return DataPersistence.normalizeServer(serverA) ==
            DataPersistence.normalizeServer(serverB) &&
        portA == portB;
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
      try {
        var config = await Apis.syncConfig();
        L.d("sync config: ${config}");
        if (config != null) {
          union.setConfig(config);
          await DataPersistence.putUnion(union, keyServer: server);
          await DataPersistence.addUnionToList(server, port);
          await DataPersistence.putCurrentUnionServer(server);
        }
      } catch (e) {
        L.w("connect to server error: ${e}");
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

  /// 选择身份（企业/个人）后进入主界面。
  /// 注意：ImController 为全局单例，切换用户后必须显式 applyLoginUser 刷新身份，
  /// 否则会沿用上一个登录用户的数据。
  void loginUser(LoginUser user, GoRouter router) async {
    L.d("select login user: uid=${user.user.id}, tenant=${user.user.tenantId}");
    loginAccount!.loginUser = user;
    await DataPersistence.putAccount(loginAccount!);
    await sdk.login(
      uid: user.user.id,
      tenantId: user.user.tenantId,
      token: user.token,
      unionClientConfig: json.encode(Config.union.config.toJson()),
    );
    // 刷新客户端侧的登录身份缓存（头像、userId、租户等）
    im.applyLoginUser(user);
    AppNavigator.startIm(router, user);
  }

  Future<bool> getVerificationCode() async {
    return true;
  }
}
