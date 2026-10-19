import 'package:flutter/material.dart';

import 'add_book_screen.dart';
import 'detail_screen.dart';
import 'models/book.dart';
import 'widgets/book_tile.dart';

enum Filter { all, unread, read }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Book> _books = [...seed];
  Filter _filter = Filter.all;

  List<Book> get _visible => switch (_filter) {
    Filter.all => _books,
    Filter.unread => unread(_books),
    Filter.read => _books.where((book) => book.read).toList(),
  };

  Future<void> _openDetail(Book book) async {
    final action = await Navigator.of(context).push<BookAction>(
      MaterialPageRoute(builder: (_) => DetailScreen(book: book)),
    );

    if (!mounted) return;

    switch (action) {
      case null:
        break;

      case BookAction.toggleRead:
        setState(() {
          book.read = !book.read;
        });

      case BookAction.delete:
        setState(() {
          _books.remove(book);
        });
    }
  }

  Future<void> _addBook() async {
    final book = await Navigator.of(context)
        .push<Book>(MaterialPageRoute(builder: (_) => const AddBookScreen()));

    if (!mounted) return;
    if (book == null) return;

    setState(() {
      _books.add(book);
    });
  }

  Widget _metric(BuildContext context, String title, int number) {
    return Expanded(
      child: Column(
        children: [
          Text('$number', style: Theme.of(context).textTheme.headlineSmall),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Scaffold(
      appBar: AppBar(title: Text('Reading list (${visible.length})')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        tooltip: 'Add a book',
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Row(
                  children: [
                    _metric(context, 'Books', _books.length),
                    _metric(context, 'Pages', totalPages(_books)),
                    _metric(context, 'Unread', unread(_books).length),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final f in Filter.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(switch (f) {
                          Filter.all => 'All',
                          Filter.unread => 'Unread',
                          Filter.read => 'Read',
                        }),
                        selected: _filter == f,
                        onSelected: (_) {
                          setState(() {
                            _filter = f;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: visible.length,
                itemBuilder: (context, index) {
                  final book = visible[index];

                  return BookTile(
                    book: book,
                    onToggle: () {
                      setState(() {
                        book.read = !book.read;
                      });
                    },
                    onTap: () => _openDetail(book),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
