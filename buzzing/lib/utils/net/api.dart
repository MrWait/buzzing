import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:buzzing/common/net/code.dart';
import 'package:buzzing/common/net/interceptors/error_interceptor.dart';
import 'package:buzzing/common/net/interceptors/header_interceptor.dart';
import 'package:buzzing/common/net/interceptors/log_interceptor.dart';
import 'package:buzzing/common/net/interceptors/response_interceptor.dart';
import 'package:buzzing/common/net/interceptors/token_interceptor.dart';
import 'package:buzzing/common/net/result_data.dart';

class HttpManager {
  static const CONTENT_TYPE_JSON = "application/json";
  static const CONTENT_TYPE_FORM = "application/x-www-form-urlencoded";

  Dio _dio = new Dio();

  final TokenInterceptors _tokenInterceptors = new TokenInterceptors();

  HttpManager() {
    _dio.interceptors.add(new HeaderInterceptors());
    _dio.interceptors.add(_tokenInterceptors);
    _dio.interceptors.add(new LogsInterceptors());
    _dio.interceptors.add(new ErrorInterceptors());
    _dio.interceptors.add(new ResponseInterceptors());
  }

  Future<ResultData?> netFetch(
      url, params, Map<String, dynamic>? header, Options? option,
      {noTip = false}) async {
    Map<String, dynamic> headers = new HashMap();
    if (header != null) {
      headers.addAll(header);
    }

    if (option != null) {
      option.headers = headers;
    } else {
      option = new Options(method: "get");
      option.headers = headers;
    }

    resultError(DioError e) {
      Response? errorResponse;
      if (e.response != null) {
        errorResponse = e.response;
      } else {
        errorResponse = new Response(
            statusCode: 666, requestOptions: RequestOptions(path: url));
      }
      if (e.type == DioErrorType.connectTimeout ||
          e.type == DioErrorType.receiveTimeout) {
        errorResponse!.statusCode = Code.NETWORK_TIMEOUT;
      }
      return new ResultData(
          Code.errorHandleFunction(errorResponse!.statusCode, e.message, noTip),
          false,
          errorResponse.statusCode);
    }

    Response response;
    try {
      response = await _dio.request(url, data: params, options: option);
    } on DioError catch (e) {
      return resultError(e);
    }
    if (response.data is DioError) {
      return resultError(response.data);
    }
    return response.data;
  }

  clearAuthorization() {
    _tokenInterceptors.clearAuthorization();
  }

  getAuthorization() {
    return _tokenInterceptors.getAuthorization();
  }
}

final HttpManager httpManager = new HttpManager();
