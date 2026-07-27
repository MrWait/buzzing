import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/widget/im_widget.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

var dio = Dio();

Map<String, String> tokens = {};

void setApiToken(String domain, String token) {
  tokens[domain] = token;
}

String? getApiToken(String domain) {
  return tokens[domain];
}

class HttpUtil {
  HttpUtil._();

  static void init() {
    dio
      ..interceptors.add(PrettyDioLogger(
          requestHeader: true, requestBody: true, responseHeader: true))
      ..interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        var token = getApiToken(options.baseUrl);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = token;
        }
        return handler.next(options);
      }, onResponse: (response, handler) {
        L.d("response: ${response}");
        return handler.next(response);
      }, onError: (DioError e, handler) {
        return handler.next(e);
      }));
    //dio.options.baseUrl = Config.apiUrl();
    dio.options.connectTimeout = Duration(milliseconds: 30000);
    dio.options.receiveTimeout = Duration(milliseconds: 30000);

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient()..idleTimeout = const Duration(seconds: 3);
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        L.d("allow self-signed certificate: $host:$port");
        return true;
      };
      return client;
    };
  }

  static void resetBaseUrl(String url) {
    dio.options.baseUrl = url;
  }

  static Future post(
    String path, {
    dynamic data,
    bool showErrorToast = true,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var result = await dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      L.d("return data: ${result.data}");
      return result.data!;
      var resp = ApiResp.fromJson(Map<String, dynamic>());
      if (resp.code == 0) {
        return resp.data;
      } else {
        if (showErrorToast) {
          IMWidget.showToast(t['k${resp.code}']?.toString() ?? resp.code.toString());
        }
        return Future.error(resp.msg);
      }
    } catch (error) {
      if (error is DioError) {
        if (showErrorToast) IMWidget.showToast(error.message ?? "");
      }
      if (showErrorToast) IMWidget.showToast(error.toString());
      return Future.error(error);
    }
  }

  static Future download(
    String url, {
    required String cachePath,
    CancelToken? cancelToken,
    Function(int count, int total)? onProgress,
  }) {
    return dio.download(url, cachePath,
        options: Options(receiveTimeout: Duration(milliseconds: 60 * 1000)),
        cancelToken: cancelToken,
        onReceiveProgress: onProgress);
  }

  static Future pull(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.get(url, queryParameters: queryParameters);
  }
}
