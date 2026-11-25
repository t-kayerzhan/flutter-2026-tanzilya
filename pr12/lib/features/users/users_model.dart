import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';

import 'user.dart';
import 'user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;

  List<User> items = const [];

  ApiException? error;

  bool loading = false;
  bool creating = false;
  bool fromCache = false;

  Future<void> load() async {
    loading = true;
    error = null;

    notifyListeners();

    try {
      final result = await _repo.getAll();

      items = result.items;
      fromCache = result.fromCache;
    } on ApiException catch (e) {
      error = e;
    } catch (e) {
      error = BadResponseException('Cannot load users: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<ApiException?> createUser(User draft) async {
    if (creating) {
      return const BadResponseException('Save already running');
    }

    creating = true;
    notifyListeners();

    try {
      final created = await _repo.create(draft);

      items = [created, ...items];

      return null;
    } on ApiException catch (e) {
      return e;
    } finally {
      creating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _repo.close();
    super.dispose();
  }
}
