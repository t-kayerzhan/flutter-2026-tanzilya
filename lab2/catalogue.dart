import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  void add(LibraryItem item) {
    items.add(item);
  }

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) {
        return item;
      }
    }
    return null;
  }

  String countryOf(String title) {
    final book = findByTitle(title);
    return book?.author.country ?? 'unknown';
  }

  late final DateTime openedAt;

  void open() {
    openedAt = DateTime.now();
  }

  String? _cachedReport;
  String get report => _cachedReport ??= buildReport();

  String buildReport() {
    return 'Library Report: ${items.length} items total managed successfully.';
  }

  // Level 4 Collections (Single expressions)
  List<String> get allTitles => items.map((item) => item.title).toList();

  List<Book> get recentBooks => items
      .whereType<Book>()
      .where((book) => book.year > 2010)
      .toList();

  // Почему не reduce? reduce выбрасывает StateError на пустых коллекциях
  // и требует функцию с тем же типом возвращаемого значения.
  // fold позволяет безопасно начать с начального значения (0.0 / 0) и работает с пустыми списками.
  double get averagePages {
    final books = items.whereType<Book>().toList();
    if (books.isEmpty) return 0.0;
    final totalPages = books.fold<int>(0, (sum, book) => sum + book.pages);
    return totalPages / books.length;
  }

  Map<String, int> get authorBookCount {
    return items.whereType<Book>().fold<Map<String, int>>({}, (map, book) {
      final name = book.author.name;
      map[name] = (map[name] ?? 0) + 1;
      return map;
    });
  }

  Set<String> get distinctAuthors =>
      items.whereType<Book>().map((b) => b.author.name).toSet();

  Set<Genre> get allGenres =>
      items.whereType<Book>().map((b) => b.genre).toSet();

  List<Object> get displayList => [
    'CATALOGUE',
    for (final item in items.whereType<Book>()) '${item.title} (${item.year})',
    ...items.whereType<Book>().map((b) => b.author.name),
    if (items.whereType<Book>().any((b) => b.pages == 0)) '(incomplete data)',
  ];
}