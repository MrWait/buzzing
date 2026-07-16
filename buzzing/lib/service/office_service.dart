import 'dart:convert';
import 'dart:io';

import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/utils/logger_util.dart';

class OfficeService {
  final String token;

  String get _base => '${Config.apiUrl()}/api/office';

  OfficeService({required String token}) : token = token {}

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

  Future<List<Map<String, dynamic>>> listSpaces() async {
    final r = await _getList('$_base/spaces');
    final l = List<Map<String, dynamic>>.from(r);
    L.d("listSpaces: ${l}");
    return l;
  }

  Future<Map<String, dynamic>> createSpace(String name) async {
    return _post('$_base/spaces', data: {'name': name});
  }

  Future<void> deleteSpace(int id) async {
    await _delete('$_base/spaces/$id');
  }

  Future<List<Map<String, dynamic>>> listDocs(int spaceId) async {
    final r = await _getList('$_base/docs', {'space_id': spaceId.toString()});
    final l = List<Map<String, dynamic>>.from(r);
    return l;
  }

  Future<Map<String, dynamic>> createDoc(int spaceId, String title) async {
    return _post(
      '$_base/docs',
      data: {'space_id': spaceId.toString(), 'title': title},
    );
  }

  Future<Map<String, dynamic>> getDoc(int id) async {
    return _get('$_base/docs/$id');
  }

  Future<Map<String, dynamic>> updateDoc(int id, {String? title}) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    return _patch('$_base/docs/$id', data: data);
  }

  Future<void> deleteDoc(int id) async {
    await _delete('$_base/docs/$id');
  }

  Future<Map<String, dynamic>> getEditUrl(int id) async {
    return _get('$_base/docs/$id/edit-url');
  }
}
