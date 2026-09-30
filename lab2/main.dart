import 'data.dart';
import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();
  library.open();

  for (final raw in rawBooks) {
    library.add(Book.fromJson(raw));
  }

  print('=== DISPLAY LIST ===');
  for (final line in library.displayList) {
    print(line);
  }

  print('\n=== QUERIES ===');
  print('All Titles: ${library.allTitles}');
  print('Recent Books (> 2010): ${library.recentBooks.map((b) => b.title)}');
  print('Average Pages: ${library.averagePages}');
  print('Author Book Count: ${library.authorBookCount}');
  print('Distinct Authors: ${library.distinctAuthors}');
  print('All Genres: ${library.allGenres}');

  print('\n=== LOOKUP TEST ===');
  final target = 'Refactoring';
  print('Country of "$target": ${library.countryOf(target)}');

  print('\n=== SHELF STATES ===');
  final books = library.items.whereType<Book>().toList();
  print(describeShelfState(Empty()));
  print(describeShelfState(Ready(books)));
  print(describeShelfState(Broken('Network timeout')));

  print('\n=== STATS RECORD ===');
  final stats = statsOf(books);
  print('Count: ${stats.count}, Avg Pages: ${stats.avgPages}');
}