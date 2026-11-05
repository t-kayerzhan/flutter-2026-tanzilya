import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/book.dart';
import 'models/cart.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool totalExpanded = true;

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear cart?'),
          content: const Text('Do you want to remove all books?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (confirmed == true) {
      context.read<Cart>().clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            tooltip: 'Clear cart',
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmClear,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<Cart>(
              builder: (context, cart, _) {
                if (cart.items.isEmpty) {
                  return const Center(child: Text('Your cart is empty'));
                }

                return ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final Book book = cart.items[index];

                    return ListTile(
                      title: Text(book.title),
                      subtitle: Text(
                        '${book.price} ₸ × '
                        '${cart.qtyOf(book)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Increase quantity',
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              cart.increment(book);
                            },
                          ),
                          IconButton(
                            tooltip: 'Remove book',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              cart.remove(book);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                totalExpanded = !totalExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Text('Order total', style: TextStyle(fontSize: 18)),
                  const Spacer(),
                  Icon(totalExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (totalExpanded)
            Consumer<Cart>(
              child: const TotalLabel(),
              builder: (context, cart, child) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      child!,
                      const Spacer(),
                      Text(
                        '${cart.total} ₸',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class TotalLabel extends StatelessWidget {
  const TotalLabel({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('TotalLabel build');

    return const Row(
      children: [
        Icon(Icons.payments_outlined),
        SizedBox(width: 8),
        Text('Total:'),
      ],
    );
  }
}
