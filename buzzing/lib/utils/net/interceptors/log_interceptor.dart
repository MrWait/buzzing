import 'package:dio/dio.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/utils/loogger_util.dart';

class LogsInterceptors extends InterceptorsWrapper {
  static List<Map?> sHttpResponses = [];
  static List<String?> sResponsesHttpUrl = [];
  static List<Map<String, dynamic>?> sHttpRequest = [];
  static List<String?> sRequestHttpUrl = [];
  static List<Map<String, dynamic>?> sHttpError = [];
  static List<String?> sHttpErrorUrl = [];

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (Config.DEBUG!) {
      LD("Request url: ${options.path} ${options.method}");
      options.headers.forEach((k, v) => options.headers[k] == v ?? "");
      LD("Request header: " + options.headers.toString());
      if (options.data != null) {
        LD("Request param: " + options.data.toString());
      }
    }
    try {
      addLogic(sRequestHttpUrl, options.path);
      var data;
      if (options.data is Map) {
        data = options.data;
      } else {
        data = Map<String, dynamic>();
      }
      var map = {
        "header:": {...options.headers},
      };
      if (options.method == "POST") {
        map["data"] = data;
      }
      addLogic(sHttpRequest, map);
    } catch (e) {
      LD(e);
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (Config.DEBUG!) {
      LD("Response param: " + response.toString());
    }
    /*
    switch (response.data) {
      case Map || List:
        {
          try {
            var data = Map<String, dynamic>();
            data["data"] = response.data;
            addLogic(sResponsesHttpUrl, response.requestOptions.uri.toString());
            addLogic(sHttpResponses, data);
          } catch (e) {
            LD(e);
          }
        }
        break;
      case String:
        {
          try {
            var data = Map<String, dynamic>();
            data["data"] = response.data;
            addLogic(sResponsesHttpUrl, response.requestOptions.uri.toString());
            addLogic(sHttpResponses, data);
          } catch (e) {
            LD(e);
          }
        }
    }
    */
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (Config.DEBUG!) {
      LD('Request error: ' + err.toString());
      LD('Request error info: ' + (err.response?.toString() ?? ""));
    }
    try {
      addLogic(sHttpErrorUrl, err.requestOptions.path);
      var errors = Map<String, dynamic>();
      errors["error"] = err.message;
      addLogic(sHttpError, errors);
    } catch (e) {
      LD(e);
    }
    return super.onError(err, handler);
  }

  static addLogic(List list, data) {
    if (list.length > 20) {
      list.removeAt(0);
    }
    list.add(data);
  }
}
