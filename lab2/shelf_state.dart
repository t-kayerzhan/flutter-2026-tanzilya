import 'models.dart';

sealed class ShelfState {}

class Empty extends ShelfState {}

class Ready extends ShelfState {
  final List<Book> books;
  Ready(this.books);
}

class Broken extends ShelfState {
  final String message;
  Broken(this.message);
}

String describeShelfState(ShelfState state) => switch (state) {
  Empty() => 'The shelf is completely empty.',
  Ready(:final books) => 'The shelf contains ${books.length} books.',
  Broken(:final message) => 'Shelf error: $message',
};

({int count, double avgPages}) statsOf(List<Book> books) {
  final count = books.length;
  if (count == 0) return (count: 0, avgPages: 0.0);
  final totalPages = books.fold<int>(0, (sum, b) => sum + b.pages);
  return (count: count, avgPages: totalPages / count);
}