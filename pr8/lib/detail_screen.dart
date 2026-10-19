import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});

  final Book book;

  Future<void> _confirmDelete(BuildContext context) async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Delete '${book.title}'?"),
          content: const Text(
            'This book will be removed from your reading list.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;

    if (delete == true) {
      Navigator.of(context).pop(BookAction.delete);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(book.title, style: Theme.of(context).textTheme.headlineSmall),

            const SizedBox(height: 20),

            ListTile(title: const Text('Author'), subtitle: Text(book.author)),

            ListTile(
              title: const Text('Pages'),
              subtitle: Text('${book.pages}'),
            ),

            ListTile(
              title: const Text('Year'),
              subtitle: Text(book.year?.toString() ?? 'Year unknown'),
            ),

            ListTile(
              title: const Text('Status'),
              subtitle: Text(book.read ? 'Read' : 'Unread'),
            ),

            const SizedBox(height: 20),

            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(BookAction.toggleRead);
              },
              child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () => _confirmDelete(context),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
