import 'package:flutter/foundation.dart';

import 'book.dart';

class Cart extends ChangeNotifier {
  final Map<Book, int> _qty = {}; //private name using _ in dart

  List<Book> get items => List.unmodifiable(_qty.keys);

  int get count => _qty.length;

  int qtyOf(Book book) => _qty[book] ?? 0;

  int get total {
    int sum = 0;

    for (final entry in _qty.entries) {
      sum += entry.key.price * entry.value;
    }

    return sum;
  }

  bool add(Book book) {
    if (_qty.containsKey(book)) {
      return false;
    }

    _qty[book] = 1;
    notifyListeners();
    return true;
  }

  void increment(Book book) {
    if (!_qty.containsKey(book)) return;

    _qty[book] = _qty[book]! + 1;
    notifyListeners();
  }

  void remove(Book book) {
    _qty.remove(book);
    notifyListeners();
  }

  void clear() {
    _qty.clear();
    notifyListeners();
  }
}
