import 'package:dio/dio.dart';
import 'package:buzzing/common/config/config.dart';
import 'package:buzzing/common/local/local_storage.dart';
import 'package:buzzing/utils/loogger_util.dart';

class TokenInterceptors extends InterceptorsWrapper {
  String? _token;
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_token == null) {
      var authorizationCode = await getAuthorization();
      if(authorizationCode != null) {
        _token = authorizationCode;
      }
    }
  }

  @override
  onResponse(Response response, handler) async {
    try {
      var responseJson = response.data;
      if (response.statusCode == 201 && responseJson["token"] != null) {
        _token = 'token ' + responseJson["token"];
        await LocalStorage.save(Config.TOKEN_KEY, _token);
      }
    } catch (e) {
      LD(e);
    }
    return super.onResponse(response, handler);
  }

  clearAuthorization() {
    this._token = null;
    LocalStorage.remove(Config.TOKEN_KEY);
    // TODO
  }

  getAuthorization() async {
    String? token = await LocalStorage.get(Config.TOKEN_KEY);
    if (token == null) {
      String? basic = await LocalStorage.get(Config.USER_BASIC_CODE);
      if (basic == null) {
      } else {
        return "Basic $basic";
      }
    } else {
      this._token = token;
      return token;
    }
  }
}
