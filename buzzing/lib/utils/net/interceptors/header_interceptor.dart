import 'package:dio/dio.dart';

class HeaderInterceptors extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.connectTimeout = 30000;
    options.receiveTimeout = 30000;
    return super.onRequest(options, handler);
  }
}
