import 'dart:developer';

import 'package:logger/logger.dart';

var defaultLogger = DefaultLogger();

var L = Logger(printer: defaultLogger);

typedef LogFn = void Function(String message, int level, String? error, String? backtrace);

class DefaultLogger extends LogPrinter {
  LogFn? logFn;

  @override
  List<String> log(LogEvent event) {
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
    }

    var time = _formatTime(DateTime.now());
    var level = _levelChar(event.level);
    var frame = _formatFrame(event.stackTrace ?? StackTrace.current);
    var msg = event.message.toString().replaceAll('\n', '\\n');
    return ['$time $level $frame $msg'];
  }

  void setLogFn(LogFn fn) {
    logFn = fn;
  }

  String _formatTime(DateTime dt) {
    return '${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}.${_pad3(dt.millisecond)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
  String _pad3(int n) => n.toString().padLeft(3, '0');

  String _levelChar(Level level) {
    return switch (level) {
      Level.all => 'A',
      Level.verbose => 'V',
      Level.trace => 'T',
      Level.debug => 'D',
      Level.info => 'I',
      Level.warning => 'W',
      Level.error => 'E',
      Level.wtf => 'F',
      Level.fatal => 'X',
      Level.nothing => 'N',
      Level.off => "O",
    };
  }

  String _formatFrame(StackTrace stackTrace) {
    var lines = stackTrace.toString().split('\n');
    for (var line in lines) {
      if (line.contains('package:logger/')) continue;
      if (line.contains('logger_util.dart')) continue;
      var trimmed = line.replaceFirst(RegExp(r'^#\d+\s+'), '');
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return 'unknown';
  }
}
