import 'dart:convert';
import 'dart:io';

import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/utils/logger_util.dart';

class OpenAppService {
  final String token;

  String get _base => '${Config.apiUrl()}/openapi/v1';

  OpenAppService({required String token}) : token = token {}

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  Future<Map<String, dynamic>> _get(
    String url, [
    Map<String, String>? query,
  ]) async {
    var uri = Uri.parse(url);
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: query);
    }
    final client = HttpClient();
    try {
      final req = await client.getUrl(uri);
      _headers.forEach((k, v) => req.headers.set(k, v));
      final resp = await req.close();
      final body = await resp.transform(utf8.decoder).join();
      if (resp.statusCode >= 400) {
        throw HttpException('$resp.statusCode: $body', uri: uri);
      }
      return jsonDecode(body) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }

  Future<List<dynamic>> _getList(
    String url, [
    Map<String, String>? query,
  ]) async {
    var uri = Uri.parse(url);
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: query);
    }
    final client = HttpClient();
    try {
      final req = await client.getUrl(uri);
      _headers.forEach((k, v) => req.headers.set(k, v));
      final resp = await req.close();
      final body = await resp.transform(utf8.decoder).join();
      if (resp.statusCode >= 400) {
        throw HttpException('$resp.statusCode: $body', uri: uri);
      }
      return jsonDecode(body) as List<dynamic>;
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> _post(
    String url, {
    Map<String, dynamic>? data,
  }) async {
    final client = HttpClient();
    try {
      final req = await client.postUrl(Uri.parse(url));
      _headers.forEach((k, v) => req.headers.set(k, v));
      if (data != null) req.write(jsonEncode(data));
      final resp = await req.close();
      final body = await resp.transform(utf8.decoder).join();
      if (resp.statusCode >= 400) {
        throw HttpException('$resp.statusCode: $body', uri: Uri.parse(url));
      }
      return jsonDecode(body) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }

  Future<void> _delete(String url) async {
    final client = HttpClient();
    try {
      final req = await client.deleteUrl(Uri.parse(url));
      _headers.forEach((k, v) => req.headers.set(k, v));
      final resp = await req.close();
      if (resp.statusCode >= 400) {
        final body = await resp.transform(utf8.decoder).join();
        throw HttpException('$resp.statusCode: $body', uri: Uri.parse(url));
      }
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> _patch(
    String url, {
    Map<String, dynamic>? data,
  }) async {
    final client = HttpClient();
    try {
      final req = await client.patchUrl(Uri.parse(url));
      _headers.forEach((k, v) => req.headers.set(k, v));
      if (data != null) req.write(jsonEncode(data));
      final resp = await req.close();
      final body = await resp.transform(utf8.decoder).join();
      if (resp.statusCode >= 400) {
        throw HttpException('$resp.statusCode: $body', uri: Uri.parse(url));
      }
      return jsonDecode(body) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }

  Future<List<Map<String, dynamic>>> listApps() async {
    final r = await _getList('$_base/apps');
    return List<Map<String, dynamic>>.from(r);
  }

  Future<Map<String, dynamic>> createApp(Map<String, dynamic> data) async {
    return _post('$_base/apps', data: data);
  }

  Future<Map<String, dynamic>> getApp(int id) async {
    return _get('$_base/apps/$id');
  }

  Future<Map<String, dynamic>> updateApp(
    int id, {
    String? name,
    String? description,
    String? iconUrl,
    String? callbackUrl,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (iconUrl != null) data['icon_url'] = iconUrl;
    if (callbackUrl != null) data['callback_url'] = callbackUrl;
    return _patch('$_base/apps/$id', data: data);
  }

  Future<void> deleteApp(int id) async {
    await _delete('$_base/apps/$id');
  }

  Future<Map<String, dynamic>> regenerateSecret(int id) async {
    return _post('$_base/apps/$id/regenerate-secret');
  }

  // OAuth
  Future<List<Map<String, dynamic>>> listRedirectUris(int appId) async {
    final r = await _getList('$_base/apps/$appId/redirect-uris');
    return List<Map<String, dynamic>>.from(r);
  }

  Future<Map<String, dynamic>> addRedirectUri(
    int appId,
    String uri,
  ) async {
    return _post('$_base/apps/$appId/redirect-uris', data: {'uri': uri});
  }

  Future<void> deleteRedirectUri(int appId, int uriId) async {
    await _delete('$_base/apps/$appId/redirect-uris/$uriId');
  }

  // Webhooks
  Future<List<Map<String, dynamic>>> listWebhooks(int appId) async {
    final r = await _getList('$_base/apps/$appId/webhooks');
    return List<Map<String, dynamic>>.from(r);
  }

  Future<Map<String, dynamic>> createWebhook(
    int appId,
    Map<String, dynamic> data,
  ) async {
    return _post('$_base/apps/$appId/webhooks', data: data);
  }

  Future<Map<String, dynamic>> updateWebhook(
    int appId,
    int whId,
    Map<String, dynamic> data,
  ) async {
    return _patch('$_base/apps/$appId/webhooks/$whId', data: data);
  }

  Future<void> deleteWebhook(int appId, int whId) async {
    await _delete('$_base/apps/$appId/webhooks/$whId');
  }

  // Scheduled Tasks
  Future<List<Map<String, dynamic>>> listTasks(int appId) async {
    final r = await _getList('$_base/apps/$appId/tasks');
    return List<Map<String, dynamic>>.from(r);
  }

  Future<Map<String, dynamic>> createTask(
    int appId,
    Map<String, dynamic> data,
  ) async {
    return _post('$_base/apps/$appId/tasks', data: data);
  }

  Future<Map<String, dynamic>> updateTask(
    int appId,
    int taskId,
    Map<String, dynamic> data,
  ) async {
    return _patch('$_base/apps/$appId/tasks/$taskId', data: data);
  }

  Future<void> deleteTask(int appId, int taskId) async {
    await _delete('$_base/apps/$appId/tasks/$taskId');
  }

  Future<void> pauseTask(int appId, int taskId) async {
    await _post('$_base/apps/$appId/tasks/$taskId/pause');
  }

  Future<void> resumeTask(int appId, int taskId) async {
    await _post('$_base/apps/$appId/tasks/$taskId/resume');
  }

  // Bot
  Future<Map<String, dynamic>> getBotConfig(int appId) async {
    return _get('$_base/apps/$appId/bot');
  }

  Future<Map<String, dynamic>> updateBotConfig(
    int appId,
    Map<String, dynamic> data,
  ) async {
    return _patch('$_base/apps/$appId/bot', data: data);
  }

  // Stats
  Future<Map<String, dynamic>> getAppStats(
    int appId, {
    String? startDate,
    String? endDate,
  }) async {
    final query = <String, String>{};
    if (startDate != null) query['start_date'] = startDate;
    if (endDate != null) query['end_date'] = endDate;
    return _get('$_base/apps/$appId/stats', query);
  }

  Future<List<dynamic>> getErrorLogs(
    int appId, {
    int? limit,
    int? offset,
  }) async {
    final query = <String, String>{};
    if (limit != null) query['limit'] = limit.toString();
    if (offset != null) query['offset'] = offset.toString();
    final r = await _getList('$_base/apps/$appId/error-logs', query);
    return r;
  }

  // Versions
  Future<List<Map<String, dynamic>>> listVersions(int appId) async {
    final r = await _getList('$_base/apps/$appId/versions');
    return List<Map<String, dynamic>>.from(r);
  }

  Future<Map<String, dynamic>> submitVersion(
    int appId,
    Map<String, dynamic> data,
  ) async {
    return _post('$_base/apps/$appId/versions', data: data);
  }
}
