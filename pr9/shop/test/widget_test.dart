import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop/main.dart';
import 'package:shop/models/cart.dart';

void main() {
  testWidgets('Books screen opens successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => Cart(), child: const Shell()),
    );

    expect(find.text('Books'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
  });
}
