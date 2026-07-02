import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:http/http.dart' as http;

import '../lib/frb/api/flutter.dart';
import '../lib/frb/frb_generated.dart';
import '../lib/proto/command.pbenum.dart';
import '../lib/proto/entity.pb.dart';
import '../lib/proto/entity.pbenum.dart';
import '../lib/proto/sdk.pb.dart';

// ---------------------------------------------------------------------------
// SDK invoke infrastructure
// ---------------------------------------------------------------------------

final _responses = <int, Completer<InvokeResponse>>{};
int _nextSeq = 1;
bool _initialized = false;

Future<void> initSdk({
  String? libPath,
  String storagePath = './store',
  String logPath = './logs',
}) async {
  if (_initialized) return;
  _initialized = true;

  Directory(storagePath).createSync(recursive: true);
  Directory(logPath).createSync(recursive: true);

  final lib = libPath != null ? ExternalLibrary.open(libPath) : null;
  await RustLib.init(externalLibrary: lib);

  final invokeStream = buzzingRegInvokeHandler();
  invokeStream.listen((data) {
    final response = InvokeResponse.fromBuffer(data);
    final completer = _responses.remove(response.seq);
    if (completer != null) {
      completer.complete(response);
    }
  });

  final pushStream = buzzingRegPushHandler();
  pushStream.listen((_) {});

  final init = InitRequest.create()
    ..deviceType = 1
    ..appId = 'buzzing'
    ..appVersion = '0.1.0'
    ..deviceId = 'test-device-001'
    ..logPath = logPath
    ..storagePath = storagePath
    ..locale = 'zh'
    ..env = EnvChannel.ENV_DEV
    ..osVersion = '0.0.1'
    ..isRelease = false
    ..deviceModel = 'DartTest';
  buzzingInit(param: init.writeToBuffer().toList());
}

Future<InvokeResponse> invoke(int command, List<int> payload) async {
  final seq = _nextSeq++;
  final completer = Completer<InvokeResponse>();
  _responses[seq] = completer;

  final req = InvokeRequest.create()
    ..seq = seq
    ..command = command
    ..payload = payload;
  buzzingInvoke(param: req.writeToBuffer().toList());

  return completer.future.timeout(const Duration(seconds: 10));
}

Future<InvokeResponse> sdkLogin({
  required int userId,
  required String token,
  int tenantId = 0,
  String unionClientConfig = '',
}) async {
  final loginReq = SdkLoginUserRequest.create()
    ..userId = Int64(userId)
    ..accessToken = token
    ..tenantId = Int64(tenantId)
    ..unionClientConfig = unionClientConfig;
  return invoke(Command.USER_LOGIN.value, loginReq.writeToBuffer());
}

Future<void> logoutUser() async {
  await invoke(
    Command.USER_LOGOUT.value,
    SdkLogoutUserRequest.create().writeToBuffer(),
  );
}

// ---------------------------------------------------------------------------
// Session persistence (file-based, stored in ./store/)
// ---------------------------------------------------------------------------

const _sessionFile = 'store/session.json';

Future<void> saveSession({
  required Account account,
  required LoginUser loginUser,
  required String server,
  required int port,
  required Map<String, dynamic> unionConfig,
}) async {
  // Store only the fields we need for re-login
  final data = {
    'server': server,
    'port': port,
    'unionConfig': unionConfig,
    'userId': loginUser.user.id.toInt(),
    'token': loginUser.token,
    'tenantId': loginUser.tenant.id.toInt(),
    'tokenExpire': loginUser.tokenExpire.toInt(),
  };
  await File(_sessionFile).parent.create(recursive: true);
  await File(_sessionFile).writeAsString(json.encode(data));
}

Future<Map<String, dynamic>?> loadSession() async {
  final file = File(_sessionFile);
  if (!await file.exists()) return null;
  try {
    final data = json.decode(await file.readAsString()) as Map<String, dynamic>;
    return data;
  } catch (_) {
    return null;
  }
}

/// Rebuild a [LoginUser] from the fields stored in [session].
LoginUser _loginUserFromSession(Map<String, dynamic> session) {
  return LoginUser.create()
    ..user = (User.create()..id = Int64(session['userId'] as int))
    ..token = (session['token'] as String)
    ..tenant = (Tenant.create()..id = Int64(session['tenantId'] as int))
    ..tokenExpire = Int64(session['tokenExpire'] as int);
}

Future<void> clearSession() async {
  final file = File(_sessionFile);
  if (await file.exists()) {
    await file.delete();
  }
}

// ---------------------------------------------------------------------------
// HTTP login flow
// ---------------------------------------------------------------------------

const defaultServerUrl = 'https://www.buzzing-im.com:5150';

/// Download union client config from [serverUrl]/config/client.
Future<Map<String, dynamic>> downloadClientConfig(String serverUrl) async {
  final url = '$serverUrl/config/client';
  final resp = await http.get(Uri.parse(url));
  if (resp.statusCode != 200) {
    throw Exception('downloadClientConfig failed: HTTP ${resp.statusCode}');
  }
  return json.decode(resp.body) as Map<String, dynamic>;
}

/// Login with phone & password via POST [serverUrl]/api/accounts/login.
Future<Account> passwordLogin({
  required String phone,
  required String password,
  required String serverUrl,
}) async {
  final url = '$serverUrl/api/accounts/login';
  final resp = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'phone': phone, 'password': password}),
  );
  if (resp.statusCode != 200) {
    throw Exception('passwordLogin failed: HTTP ${resp.statusCode}\n${resp.body}');
  }
  final account = Account.create()..mergeFromProto3Json(json.decode(resp.body));
  if (account.users.isEmpty) {
    throw Exception('passwordLogin: account has no users. Raw body: ${resp.body}');
  }
  return account;
}

/// Pick the first non-personal identity (tenant.id != 0).
LoginUser selectNonPersonalIdentity(Account account) {
  for (final user in account.users) {
    if (user.tenant.id != Int64(0)) {
      return user;
    }
  }
  throw Exception('No non-personal identity found in account');
}

/// Check if the token has expired (tokenExpire is ms epoch).
bool isTokenExpired(LoginUser user) {
  final expireMs = user.tokenExpire.toInt();
  if (expireMs <= 0) return false;
  return DateTime.now().millisecondsSinceEpoch >= expireMs;
}

/// Automatically log in, reusing saved session if still valid.
/// Returns the selected [LoginUser] (non-personal identity).
Future<LoginUser> autoLoginOrFullFlow({
  String serverUrl = defaultServerUrl,
  String phone = '10011110002',
  String password = '123456',
}) async {
  // Try loading saved session
  final session = await loadSession();
  if (session != null && session['userId'] != null) {
    final loginUser = _loginUserFromSession(session);
    if (!isTokenExpired(loginUser)) {
      final uc = session['unionConfig'];
      final configJson = uc != null ? json.encode(uc) : '';
      await sdkLogin(
        userId: loginUser.user.id.toInt(),
        token: loginUser.token,
        tenantId: loginUser.tenant.id.toInt(),
        unionClientConfig: configJson,
      );
      return loginUser;
    }
    // Token expired – clear stale session and proceed with full flow
    await clearSession();
  }

  // Full HTTP login flow
  final unionConfig = await downloadClientConfig(serverUrl);
  final account = await passwordLogin(
    phone: phone,
    password: password,
    serverUrl: serverUrl,
  );
  final loginUser = selectNonPersonalIdentity(account);
  final configJson = json.encode(unionConfig);

  await sdkLogin(
    userId: loginUser.user.id.toInt(),
    token: loginUser.token,
    tenantId: loginUser.tenant.id.toInt(),
    unionClientConfig: configJson,
  );

  await saveSession(
    account: account,
    loginUser: loginUser,
    server: serverUrl,
    port: 5150,
    unionConfig: unionConfig,
  );

  return loginUser;
}
