import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  const UserRepository(this._api);
  final ApiClient _api;

  T _parse<T>(Object? Function() parse, String endpoint) {
    try {
      return parse() as T;
    } on ApiException {
      rethrow;
    } on TypeError catch (e) {
      throw BadResponseException('$endpoint: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$endpoint: $e');
    } on ArgumentError catch (e) {
      throw BadResponseException('$endpoint: $e');
    }
  }

  Map<String, dynamic> _object(http.Response response, String endpoint) =>
      _parse<Map<String, dynamic>>(
        () => _api.decodeResponse(response) as Map<String, dynamic>,
        endpoint,
      );

  Future<List<User>> getAll() async {
    final response = await _api.get('/users');
    return _parse<List<User>>(() {
      final raw = _api.decodeResponse(response) as List<dynamic>;
      return raw
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    }, 'users');
  }

  Future<User> getById(int id) async {
    final response = await _api.get('/users/$id');
    return _parse<User>(
      () => User.fromJson(_object(response, 'users/$id')),
      'users/$id',
    );
  }

  Future<User> create(User draft) async {
    final body = draft.toJson()..remove('id');
    final response = await _api.post('/users', body);
    if (response.statusCode != 201) {
      throw BadResponseException(
        'POST users: expected 201, got ${response.statusCode}',
      );
    }
    return _parse<User>(
      () => User.fromJson(_object(response, 'POST users')),
      'POST users',
    );
  }

  void close() => _api.close();
}
