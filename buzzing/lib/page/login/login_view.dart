import 'package:buzzing/res/theme.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:buzzing/provider/page_providers.dart';
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    var tenantName = user.tenant.name;
    var tenantAvatar = user.tenant.avatar;
    Widget avatar;
    if (user.tenant.id == 0) {
      tenantName = "Personal";
      avatar = Icon(Icons.account_circle_outlined, color: cs.primary);
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
          Text(tenantName, style: tt.bodySmall?.copyWith(color: cs.primary)),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
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
                color: cs.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  "B",
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Buzzing",
              style: tt.headlineMedium?.copyWith(fontSize: 28),
            ),
            SizedBox(height: 12),
            Text(
              t.welcomeHint,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return TouchCloseSoftKeyboard(
      child: Container(
        color: cs.surface,
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
                    style: tt.headlineMedium?.copyWith(fontSize: 24),
                  ),
                  SizedBox(height: 32),
                  _UnionSelector(logic: logic),
                  SizedBox(height: 20),
                  PhoneInputBox(
                    controller: logic.phoneCtrl,
                    labelStyle: tt.bodyMedium!,
                    textStyle: tt.bodyLarge!.copyWith(fontSize: 17),
                    hintStyle: tt.bodyLarge!.copyWith(fontSize: 17, color: cs.onSurface.withValues(alpha: 0.4)),
                    codeStyle: tt.bodyLarge!.copyWith(fontSize: 17),
                    arrowColor: cs.onSurface,
                    clearBtnColor: cs.onSurface.withValues(alpha: 0.4),
                    code: logic.areaCode,
                    onAreaCode: () => logic.openCountryCodePicker(),
                    showClearBtn: logic.showAccountCleanBtn,
                    inputWay: InputWay.phone,
                  ),
                  SizedBox(height: 16),
                  logic.isPasswordLogin
                      ? PwdInputBox(
                          controller: logic.pwdCtrl,
                          labelStyle: tt.bodyMedium!,
                          hintStyle: tt.bodyLarge!.copyWith(fontSize: 17, color: cs.onSurface.withValues(alpha: 0.4)),
                          textStyle: tt.bodyLarge!.copyWith(fontSize: 17),
                          showClearBtn: logic.showPwdClearBtn,
                          obscureText: logic.obscureText,
                          onClickEyesBtn: () => logic.toggleEye(),
                          clearBtnColor: cs.onSurface.withValues(alpha: 0.4),
                          eyesBtnColor: cs.onSurface,
                        )
                      : CodeInputBox(
                          controller: logic.codeCtrl,
                          labelStyle: tt.bodyMedium!,
                          hintStyle: tt.bodyLarge!.copyWith(fontSize: 17, color: cs.onSurface.withValues(alpha: 0.4)),
                          textStyle: tt.bodyLarge!.copyWith(fontSize: 17),
                          onClickCodeBtn: logic.getVerificationCode,
                        ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: logic.switchLoginType,
                    child: Text(
                      logic.isPasswordLogin ? t.useSMSLogin : t.usePwdLogin,
                      style: tt.bodySmall?.copyWith(color: cs.primary),
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
                          textStyle: tt.labelLarge?.copyWith(color: cs.onPrimary),
                          color: cs.primary,
                          disabledColor: cs.primary.withValues(alpha: 0.4),
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
                          style: tt.bodySmall?.copyWith(color: cs.primary),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 12,
                        color: cs.onSurfaceVariant,
                        margin: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      GestureDetector(
                        onTap: () => logic.register(),
                        child: Text(
                          logic.index == 0
                              ? t.phoneRegister
                              : t.emailRegister,
                          style: tt.bodySmall?.copyWith(color: cs.primary),
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

    final cs = Theme.of(context).colorScheme;
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
            Icon(Icons.add, size: 18, color: cs.primary),
            SizedBox(width: 8),
            Text(
              t.addServer,
              style: TextStyle(color: cs.primary),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      key: _key,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant, width: 1),
        ),
      ),
      child: InkWell(
        onTap: _showMenu,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(Icons.dns_outlined, size: 16, color: cs.onSurfaceVariant),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _displayText(),
                  style: tt.bodyMedium?.copyWith(
                    color: widget.logic.currentUnionEntry.isNotEmpty
                        ? cs.onSurface
                        : cs.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: cs.onSurfaceVariant),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      color: cs.surface,
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
                    Icon(Icons.arrow_back, size: 18, color: cs.primary),
                    SizedBox(width: 4),
                    Text(t.goBack, style: tt.bodyMedium?.copyWith(color: cs.primary)),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                t.welcomeUse,
                style: tt.headlineMedium?.copyWith(fontSize: 22),
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
                        backgroundColor: cs.primary,
                        child: Text(
                          user?.user.name.isNotEmpty == true
                              ? user!.user.name[0]
                              : "?",
                          style: TextStyle(color: cs.onPrimary),
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
