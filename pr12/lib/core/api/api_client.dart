import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../storage/secure_store.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(
    this._client,
    this._store, {
    this.host = 'jsonplaceholder.typicode.com',
  });

  factory ApiClient.create(
    SecureStore store, {
    String host = 'jsonplaceholder.typicode.com',
  }) {
    return ApiClient(http.Client(), store, host: host);
  }

  final http.Client _client;
  final SecureStore _store;
  final String host;

  Uri uri(String path, [Map<String, String>? query]) {
    return Uri.https(host, path, query);
  }

  Future<Map<String, String>> get headers async {
    final token = await _store.readToken();

    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        developer.log(
          '${response.request?.method} '
          '${response.request?.url.path} '
          '→ ${response.statusCode}',
          name: 'api',
        );
      }

      _check(response);
      return response;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    }
  }

  void _check(http.Response response) {
    final status = response.statusCode;

    if (status == 401) {
      throw const UnauthorizedException();
    }

    if (status == 404) {
      throw const NotFoundException();
    }

    if (status >= 500) {
      throw ServerException(status);
    }

    if (status >= 400) {
      throw BadResponseException('HTTP $status');
    }
  }

  dynamic _decode(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException catch (e) {
      throw BadResponseException('Invalid JSON: $e');
    }
  }

  Future<http.Response> get(String path, [Map<String, String>? query]) async {
    final requestHeaders = await headers;

    return _send(() => _client.get(uri(path, query), headers: requestHeaders));
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final requestHeaders = await headers;

    return _send(
      () => _client.post(
        uri(path),
        headers: {...requestHeaders, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
  }

  dynamic decodeResponse(http.Response response) {
    return _decode(response);
  }

  void close() {
    _client.close();
  }
}
