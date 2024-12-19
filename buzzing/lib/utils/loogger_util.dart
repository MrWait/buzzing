import 'dart:developer';

import 'package:logger/logger.dart';

var defaultLogger = DefaultLogger();

var L = Logger(printer: defaultLogger);

class DefaultLogger extends LogPrinter {
  final logger = Logger.defaultPrinter();
  Function? logFn;
  @override
  List<String> log(LogEvent event) {
    // TODO: implement log
    if (logFn != null) {
      var stackTrace = event.stackTrace;
      if (event.error != null && event.stackTrace == null) {
        stackTrace = StackTrace.current;
      }
      logFn!(
        event.message.toString(),
        event.level.value,
        event.error?.toString(),
        stackTrace.toString(),
      );
      return [];
    } else {
      return logger.log(event);
    }
  }

  void setLogFn(Function fn) {
    logFn = fn;
  }
}

void printLog(String text, {bool isError = false}) {
  LD(text);
}

void LV(
  dynamic message, {
  DateTime? time,
  Object? error,
  StackTrace? stackTrace,
}) {
  L.v(message, time: time, error: error, stackTrace: stackTrace);
}

void LT(
  dynamic message, {
  DateTime? time,
  Object? error,
  StackTrace? stackTrace,
}) {
  L.t(message, time: time, error: error, stackTrace: stackTrace);
}

void LD(
  dynamic message, {
  DateTime? time,
  Object? error,
  StackTrace? stackTrace,
}) {
  L.d(message, time: time, error: error, stackTrace: stackTrace);
}

void LI(
  dynamic message, {
  DateTime? time,
  Object? error,
  StackTrace? stackTrace,
}) {
  L.i(message, time: time, error: error, stackTrace: stackTrace);
}

void LW(
  dynamic message, {
  DateTime? time,
  Object? error,
  StackTrace? stackTrace,
}) {
  L.w(message, time: time, error: error, stackTrace: stackTrace);
}

void LE(
  dynamic message, {
  DateTime? time,
  Object? error,
  StackTrace? stackTrace,
}) {
  L.e(message, time: time, error: error, stackTrace: stackTrace);
}

void F(
  dynamic message, {
  DateTime? time,
  Object? error,
  StackTrace? stackTrace,
}) {
  L.f(message, time: time, error: error, stackTrace: stackTrace);
}
