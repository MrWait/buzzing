import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:buzzing/ffi/rust/frb_generated.dart';
import 'package:fixnum/fixnum.dart';
import 'package:channel/channel.dart';
//import 'package:buzzing/ffi/rust/ffi_rust.dart';
import 'package:buzzing/ffi/rust/api/flutter.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/models/idl/error.pb.dart';
import 'package:buzzing/models/idl/sdk.pb.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:buzzing/event/event_bus.dart';

bool inited = false;

class SdkController {
  int invoke_seq = 1;
  final EventBus eventBus;
  final initCh = Channel<int>();
  var userId = Int64(0);

  final invokeCh = Map<int, Channel<Uint8List>>();
  final pushCallback = Map<int, Function>();

  SdkController({required this.eventBus}) {
    L.w("init sdk controller");
    if (!inited) {
      inited = true;
      Future.delayed(Duration(milliseconds: 0), () async {
        await _init();
        defaultLogger.setLogFn(log);
        initCh.send(0);
      });
    }
  }

  void dispose() {
    L.w("sdk controller close");
  }

  void regPushCallback(int cmd, Function f) {
    pushCallback[cmd] = f;
  }

  void onLogined() {}

  void handlePush(Uint8List data) {
    //L.d("receive sdk push data: ${data}");
    var push = SdkPushPacket.fromBuffer(data);
    L.d("sdk push cmd: ${push.command}");
    final f = pushCallback[push.command];
    if (f != null) {
      f(push.payload);
    }
  }

  void handleInvokeResponse(Uint8List data) {
    //L.d("receive sdk response data: ${data}");
    var response = InvokeResponse.fromBuffer(data);
    L.d("sdk response seq: ${response.seq}");
    final ch = invokeCh.remove(response.seq);
    if (ch != null) {
      ch.send(data);
    }
  }

  void initSdkPushHandler() {
    var push_handle = buzzingRegPushHandler();
    Future.delayed(Duration.zero, () async {
      await for (final data in push_handle) {
        //L.d("receive sdk push data: ${data}");
        handlePush(data);
      }
      L.d("push handler finish");
    });
  }

  void initSdkInvokeHandler() {
    var invoke_handle = buzzingRegInvokeHandler();
    Future.delayed(Duration.zero, () async {
      await for (final data in invoke_handle) {
        //L.d("receive sdk response data: ${data}");
        handleInvokeResponse(data);
      }
      L.d("invoke handler finish");
    });
  }

  Future<void> _init() async {
    L.d("call _init");
    InitRequest init = InitRequest.create();
    var currentDir = Directory.current.path;
    var userStore = (await getApplicationSupportDirectory()).path;
    var docDir = (await getApplicationDocumentsDirectory()).path;
    var cacheDir = (await getApplicationCacheDirectory()).path;
    var downloadDir = (await getDownloadsDirectory())?.path;
    L.d("${currentDir}  ${userStore}, doc: ${docDir}, cache: ${cacheDir}, download: ${downloadDir}");
    init.appId = "buzzing";
    init.appVersion = "0.1.0";
    init.env = EnvChannel.ENV_DEV;
    init.locale = "zh";
    init.commonDataPath = p.join(userStore, "Data");
    init.logPath = p.join(userStore, "Log");
    init.osVersion = "6.1.0";
    init.storagePath = p.join(userStore, "Data");
    init.pathPrefix = userStore;
    init.isRelease = false;
    init.deviceModel = "Windows";
    init.deviceId = "123456";
    L.d("init request ${init}");

    //L.d("get ${greeting}");

    await RustLib.init();
    var ret = await buzzingInit(param: init.writeToBuffer().toList());
    L.d("init ret ${ret}");
    initSdkPushHandler();
    initSdkInvokeHandler();
    // var data = await invokeAsync(Command.ACK, Uint8List.fromList([7, 8, 9]));
    //L.d("invoke async return ${data}");
    L.d("init finish");
  }

  void log(String message, int level, String? error, String? backtrace) {
    if (!inited) {
      return;
    }
    var log = WriteClientLog.create();
    log.msg = message;
    log.level = level;
    if (error != null) {
      log.error = error;
    }
    if (backtrace != null) {
      log.backtrace = backtrace;
    }

    invokeWithoutAck(Command.SDK_WRITE_LOG, log.writeToBuffer());
  }

  void invokeWithoutAck(Command command, Uint8List request) {
    if (!inited) {
      return;
    }

    var req = InvokeRequest.create();
    req.command = command.value;
    req.payload = request;
    buzzingInvoke(param: req.writeToBuffer().toList());
  }

  Future<void> login({
    required $fixnum.Int64 uid,
    required $fixnum.Int64 tenantId,
    required String token,
    required String unionClientConfig,
  }) async {
    L.d("call login");
    SdkLoginUserRequest req = SdkLoginUserRequest.create();
    req.userId = uid;
    req.tenantId = tenantId;
    req.accessToken = token;
    req.unionClientConfig = unionClientConfig;
    var data = await invokeAsync(Command.USER_LOGIN, req.writeToBuffer());
    L.d("invoke login return ${data}");
    L.d("call login finish");
    userId = uid;
    eventBus.emit(GlobalEvent.logined);
  }

  void _uninit() {}

  Future<({int code, List<int>? data})> invokeAsync(
      Command command, Uint8List request) async {
    var _ = await initCh.receive();
    initCh.send(0);
    InvokeRequest req = InvokeRequest.create();
    final channel = Channel<Uint8List>();
    var seq = invoke_seq++;
    invokeCh[seq] = channel;
    req.command = command.value;
    req.seq = seq;
    req.payload = request;
    buzzingInvoke(param: req.writeToBuffer().toList());
    final data = await channel.receive();
    if (!data.isClosed) {
      invokeCh.remove(seq);
      if (data.data != null) {
        var resp = InvokeResponse.fromBuffer(data.data!);
        if (resp.status == 200 || resp.status == 0) {
          return (code: resp.status, data: resp.payload);
        } else {
          L.e("invoke sdk response error, ${command}, ${seq}, ${resp.status}");
          return (code: resp.status, data: null);
        }
      } else {
        L.e("invoke sdk error, return data null");
      }
    }

    return (code: ErrorCode.ERROR_TIMEOUT.value, data: null);
  }

  String genContextId() {
    return "unknown";
  }

  Future<void> logout() async {
    var req = SdkLogoutUserRequest.create();
    await invokeAsync(Command.USER_LOGOUT, req.writeToBuffer());
  }

  void contactGetOrg() {}
  void contactGetProfile() {}
  void contactUpdate() {}

  void chatCreate() {}
  void chatAddMember() {}
  void chatDisolve() {}
  void chatUpdateSetting() {}
  void chatGetMessage() {}

  void messagePrepare() {}
  void messageSend() {}
  void messageRecall() {}

  void feedGetList() {}
  void feedSetTop() {}
}
