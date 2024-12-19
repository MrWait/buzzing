import 'package:buzzing/common/config/config.dart';

class Address {
  static const String host = "https://api.github.com";
  static const String hostWeb = "https://github.com";
  static const String graphicHost = 'https://ghchart.rshah.org/';
  static const String updateUrl = 'https://gitee.com/';

  static getAuthorization() {
    return "${host}authorizations";
  }

  static search(q, sort, order, type, page, [pageSize = Config.PAGE_SIZE]) {
    if (type == 'user') {
      return "${host}search/users?q=$q&page=$page&per_page=$pageSize";
    }
    sort ??= "best%20match";
    order ??= "desc";
    page ??= 1;
    return "";
  }
}
