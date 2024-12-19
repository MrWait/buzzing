import 'package:dio/dio.dart';
import 'package:connectivity/connectivity.dart';

const NOT_TIP_KEY = "noTip";

class ErrorInterceptors extends InterceptorsWrapper {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return handler.reject(DioError(
          requestOptions: options,
          type: DioErrorType.other,
          response: Response(
            requestOptions: options,
            data: new ResultData(),
          )));
    }
    return super.onRequest(options, handler);
  }
}
