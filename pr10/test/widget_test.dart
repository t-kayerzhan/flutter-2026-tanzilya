import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pr10/main.dart';

void main() {
  testWidgets('Home screen has three routes', (tester) async {
    await tester.pumpWidget(const StudentsApp());

    expect(find.text('By hand'), findsOneWidget);
    expect(find.text('FutureBuilder'), findsOneWidget);
    expect(find.text('Countdown'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNWidgets(3));
  });
}
