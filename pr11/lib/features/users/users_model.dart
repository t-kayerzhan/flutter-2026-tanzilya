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

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _repo.getAll();
    } on ApiException catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Returns the error to the form without leaking HTTP or BuildContext.
  Future<ApiException?> createUser(User draft) async {
    if (creating) return const BadResponseException('Save already running');
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
