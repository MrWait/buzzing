import 'config.dart';

class Urls {
  static String register() {
    return Config.apiUrl() + "/api/accounts/register";
  }

  static String login() {
    return Config.apiUrl() + "/api/accounts/login";
  }

  static String syncConfig() {
    return Config.apiUrl() + "/config/client";
  }
}
