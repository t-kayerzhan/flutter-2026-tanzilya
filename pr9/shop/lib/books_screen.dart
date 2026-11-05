import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');

    final filteredBooks = books.where((book) {
      final query = searchText.toLowerCase();

      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: const [CartBadge()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search books...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredBooks.length,
        itemBuilder: (context, index) {
          final book = filteredBooks[index];

          return BookRow(book: book);
        },
      ),
    );
  }
}

class BookRow extends StatelessWidget {
  const BookRow({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    debugPrint('row ${book.title}');

    final added = context.select<Cart, bool>((cart) => cart.qtyOf(book) > 0);

    return ListTile(
      title: Text(book.title),
      subtitle: Text('${book.author}\n${book.price} ₸'),
      isThreeLine: true,
      trailing: added
          ? const Text('Added')
          : OutlinedButton(
              onPressed: () {
                final ok = context.read<Cart>().add(book);

                if (ok) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(const SnackBar(content: Text('Added')));
                }
              },
              child: const Text('Add'),
            ),
    );
  }
}
