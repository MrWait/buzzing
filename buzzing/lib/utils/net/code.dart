import 'package:buzzing/common/event/index.dart';
import 'package:buzzing/common/event/http_error_event.dart';

class Code {
  static const NETWORK_ERROR = -1;
  static const NETWORK_TIMEOUT = -2;
  static const NETWORK_JSON_EXCEPTION = -3;
  static const API_REFUSED = -4;
  static const SUCCESS = 200;

  static errorHandleFunction(code, message, noTip) {
    if (noTip) {
      return message;
    }
    if (message != null &&
        message is String &&
        (message.contains("Connection refused") ||
            message.contains("Connection reset"))) {
      code = API_REFUSED;
    }
    eventBus.fire(new HttpErrorEvent(code, message));
    return message;
  }
}
