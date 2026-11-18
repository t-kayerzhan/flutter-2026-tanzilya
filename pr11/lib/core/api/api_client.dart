import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  // Creates a Client without leaking package:http imports into main.dart.
  factory ApiClient.create({String host = 'jsonplaceholder.typicode.com'}) {
    return ApiClient(http.Client(), host: host);
  }

  final http.Client _client;
  final String host;

  Map<String, String> get headers => const {'Accept': 'application/json'};

  Uri uri(String path, [Map<String, String>? query]) =>
      Uri.https(host, path, query);

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(const Duration(seconds: 10));
      if (kDebugMode) {
        developer.log(
          '${response.request?.method} ${response.request?.url.path} → ${response.statusCode}',
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
    if (status == 401) throw const UnauthorizedException();
    if (status == 404) throw const NotFoundException();
    if (status >= 500) throw ServerException(status);
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

  Future<http.Response> get(String path, [Map<String, String>? query]) =>
      _send(() => _client.get(uri(path, query), headers: headers));

  Future<http.Response> post(String path, Map<String, dynamic> body) => _send(
    () => _client.post(
      uri(path),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ),
  );

  dynamic decodeResponse(http.Response response) => _decode(response);

  void close() => _client.close();
}
