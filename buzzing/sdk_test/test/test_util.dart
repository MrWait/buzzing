import 'dart:async';
import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

import '../lib/frb/api/flutter.dart';
import '../lib/frb/frb_generated.dart';
import '../lib/proto/command.pbenum.dart';
import '../lib/proto/entity.pbenum.dart';
import '../lib/proto/sdk.pb.dart';

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

Future<InvokeResponse> loginUser({
  required int userId,
  required String token,
  int tenantId = 0,
}) async {
  final loginReq = SdkLoginUserRequest.create()
    ..userId = Int64(userId)
    ..accessToken = token
    ..tenantId = Int64(tenantId);
  return invoke(Command.USER_LOGIN.value, loginReq.writeToBuffer());
}

Future<void> logoutUser() async {
  await invoke(
    Command.USER_LOGOUT.value,
    SdkLogoutUserRequest.create().writeToBuffer(),
  );
}
