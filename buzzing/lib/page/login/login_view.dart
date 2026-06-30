import 'package:buzzing/utils/common_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/widget/button.dart';
import 'package:buzzing/widget/code_input_box.dart';
import 'package:buzzing/widget/debounce_button.dart';
import 'package:buzzing/widget/phone_input_box.dart';
import 'package:buzzing/widget/pwd_input_box.dart';
import 'package:buzzing/widget/touch_close_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    tenantName += "(" + user.tenant.id.toString() + ")";
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logic = ref.watch(loginLogicProvider);
    return ListenableBuilder(
      listenable: logic,
      builder: (ctx, _) {
        return Scaffold(
          body: Center(
            child: SizedBox(
              width: 720,
              child: Row(
                children: [
                  SizedBox(width: 340, child: _BrandPanel()),
                  SizedBox(
                    width: 380,
                    child: logic.loginMode == 2
                        ? _TenantPanel(logic: logic)
                        : _FormPanel(logic: logic),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0F5FF), Color(0xFFE8F0FF)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: PageStyle.c_3370FF,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  "B",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Buzzing",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F1F1F),
              ),
            ),
            SizedBox(height: 12),
            Text(
              t.welcomeHint,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  final LoginLogic logic;
  const _FormPanel({required this.logic});

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: Container(
        color: Colors.white,
        child: Center(
          child: SizedBox(
            width: 340,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60),
                  Text(
                    t.welcomeUse,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  SizedBox(height: 32),
                  _UnionSelector(logic: logic),
                  SizedBox(height: 20),
                  PhoneInputBox(
                    controller: logic.phoneCtrl,
                    labelStyle: PageStyle.ts_171A1D_14,
                    textStyle: PageStyle.ts_171A1D_17,
                    hintStyle: PageStyle.ts_171A1D0_opacity40p_17,
                    codeStyle: PageStyle.ts_171A1D_17,
                    arrowColor: PageStyle.c_000000,
                    clearBtnColor: PageStyle.c_000000_opacity40p,
                    code: logic.areaCode,
                    onAreaCode: () => logic.openCountryCodePicker(),
                    showClearBtn: logic.showAccountCleanBtn,
                    inputWay: InputWay.phone,
                  ),
                  SizedBox(height: 16),
                  logic.isPasswordLogin
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
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: logic.switchLoginType,
                    child: Text(
                      logic.isPasswordLogin ? t.useSMSLogin : t.usePwdLogin,
                      style: TextStyle(
                        fontSize: 12,
                        color: PageStyle.c_3370FF,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: DebounceButton(
                      builder: (context, onTap) {
                        return Button(
                          enabled: logic.enabledLoginButton,
                          text: t.login,
                          textStyle: PageStyle.ts_FFFFFF_16sp,
                          color: PageStyle.c_3370FF,
                          disabledColor: PageStyle.c_3370FF.withOpacity(0.4),
                          radius: 8,
                          onTap: onTap,
                        );
                      },
                      duration: Duration(milliseconds: 200),
                      onTap: () async { logic.login(context); },
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => logic.forgetPassword(),
                        child: Text(
                          t.forgetPwd,
                          style: TextStyle(
                            fontSize: 12,
                            color: PageStyle.c_3370FF,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 12,
                        color: PageStyle.c_A2A3A5,
                        margin: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      GestureDetector(
                        onTap: () => logic.register(),
                        child: Text(
                          logic.index == 0
                              ? t.phoneRegister
                              : t.emailRegister,
                          style: TextStyle(
                            fontSize: 12,
                            color: PageStyle.c_3370FF,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnionSelector extends StatefulWidget {
  final LoginLogic logic;
  const _UnionSelector({required this.logic});

  @override
  State<_UnionSelector> createState() => _UnionSelectorState();
}

class _UnionSelectorState extends State<_UnionSelector> {
  final _key = GlobalKey<State>();

  String _displayText() {
    if (widget.logic.currentUnionEntry.isNotEmpty) {
      return widget.logic.currentUnionEntry;
    }
    return t.serverConfig;
  }

  Future<void> _showMenu() async {
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);

    final items = <PopupMenuEntry<String>>[
      ...widget.logic.unionList.map((entry) => PopupMenuItem<String>(
        value: entry,
        child: Text(entry),
      )),
      if (widget.logic.unionList.isNotEmpty)
        const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: "__add__",
        child: Row(
          children: [
            Icon(Icons.add, size: 18, color: PageStyle.c_3370FF),
            SizedBox(width: 8),
            Text(
              t.addServer,
              style: TextStyle(color: PageStyle.c_3370FF),
            ),
          ],
        ),
      ),
    ];

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(offset.dx, offset.dy + renderBox.size.height, renderBox.size.width, 0),
        Offset.zero & MediaQuery.of(context).size,
      ),
      items: items,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    if (result == "__add__") {
      _showAddServerDialog();
    } else if (result != null) {
      widget.logic.selectUnion(result);
    }
  }

  Future<void> _showAddServerDialog() async {
    final serverCtrl = TextEditingController();
    final portCtrl = TextEditingController(text: "5150");

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.addServer),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: serverCtrl,
              decoration: InputDecoration(
                labelText: t.serverAddress,
                hintText: t.plsInputServerAddress,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: portCtrl,
              decoration: InputDecoration(
                labelText: t.port,
                hintText: t.plsInputPort,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.confirmLogin),
          ),
        ],
      ),
    );

    if (result == true) {
      final server = serverCtrl.text.trim();
      if (server.isNotEmpty) {
        final port = int.tryParse(portCtrl.text.trim()) ?? 5150;
        widget.logic.dialogServerCtrl.text = server;
        widget.logic.dialogPortCtrl.text = port.toString();
        await widget.logic.onAddServer();
      }
    }
    serverCtrl.dispose();
    portCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E6E8), width: 1),
        ),
      ),
      child: InkWell(
        onTap: _showMenu,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(Icons.dns_outlined, size: 16, color: Color(0xFF666666)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _displayText(),
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.logic.currentUnionEntry.isNotEmpty
                        ? Color(0xFF1F1F1F)
                        : Color(0xFF999999),
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Color(0xFF999999)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TenantPanel extends StatelessWidget {
  final LoginLogic logic;
  const _TenantPanel({required this.logic});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => logic.backToLogin(),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, size: 18, color: PageStyle.c_3370FF),
                    SizedBox(width: 4),
                    Text(t.goBack, style: TextStyle(color: PageStyle.c_3370FF, fontSize: 14)),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                t.welcomeUse,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              SizedBox(height: 24),
              ...List.generate(
                logic.loginAccount?.account?.users.length ?? 0,
                (index) {
                  final user = logic.loginAccount?.account?.users[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: PageStyle.c_3370FF,
                        child: Text(
                          user?.user.name.isNotEmpty == true
                              ? user!.user.name[0]
                              : "?",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(user?.user.name ?? ""),
                      subtitle: Text(user?.tenant.name ?? ""),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => logic.loginUser(user!, GoRouter.of(context)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
