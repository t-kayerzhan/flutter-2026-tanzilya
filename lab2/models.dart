class Author {
  final String name;
  final String? country;

  const Author({required this.name, this.country});

  @override
  String toString() => country != null ? '$name ($country)' : name;
}

enum Genre {
  craft(label: 'Craft'),
  theory(label: 'Theory'),
  unknown(label: 'Unknown');

  const Genre({required this.label});
  final String label;

  static Genre fromString(String? raw) {
    if (raw == null) return Genre.unknown;
    return Genre.values.firstWhere(
          (g) => g.name == raw.toLowerCase(),
      orElse: () => Genre.unknown,
    );
  }
}

abstract class LibraryItem {
  final String title;
  final int year;

  const LibraryItem({required this.title, required this.year});

  String describe();

  bool get isOld => year < 2000;
}

mixin Borrowable on LibraryItem {
  String borrowLabel() => 'Borrowing: $title';
}

class Book extends LibraryItem with Borrowable {
  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  const Book({
    required String title,
    required int year,
    required this.pages,
    required this.author,
    required this.genre,
    this.description,
  }) : super(title: title, year: year);

  factory Book.fromJson(Map<String, dynamic> json) {
    final authorName = json['author'] as String? ?? 'Unknown';
    final authorCountry = json['country'] as String?;

    return Book(
      title: json['title'] as String? ?? 'Untitled',
      year: json['year'] as int? ?? 2000,
      pages: json['pages'] as int? ?? 0,
      author: Author(name: authorName, country: authorCountry),
      genre: Genre.fromString(json['genre'] as String?),
      description: json['description'] as String?,
    );
  }

  bool get isLong => pages > 400;

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description,
  }) {
    return Book(
      title: title ?? this.title,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      description: description ?? this.description,
    );
  }

  @override
  String describe() => 'Book: $title ($year) by ${author.name}, ${pages}p.';

  @override
  String toString() => describe();
}

class Magazine extends LibraryItem {
  final int issue;

  const Magazine({
    required String title,
    required int year,
    required this.issue,
  }) : super(title: title, year: year);

  @override
  String describe() => 'Magazine: $title Issue $issue ($year)';
}

class Ghost implements LibraryItem {
  @override
  final String title;
  @override
  final int year;

  const Ghost({required this.title, required this.year});

  @override
  String describe() => 'Ghost Item: $title';

  @override
  bool get isOld => year < 2000;
}