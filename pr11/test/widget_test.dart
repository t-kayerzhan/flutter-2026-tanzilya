import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pr11/features/users/users_model.dart';
import 'package:pr11/features/users/user_repository.dart';
import 'package:pr11/core/api/api_client.dart';
import 'package:pr11/features/users/users_screen.dart';

void main() {
  testWidgets('Users screen shows title and new-user action', (tester) async {
    final model = UsersModel(UserRepository(ApiClient.create()));
    await tester.pumpWidget(
      ChangeNotifierProvider<UsersModel>.value(
        value: model,
        child: const MaterialApp(home: UsersScreen()),
      ),
    );
    expect(find.text('Users — real API'), findsOneWidget);
    expect(find.byIcon(Icons.person_add), findsOneWidget);
    // Provider.value does not own model; close its client explicitly.
    await tester.pumpWidget(const SizedBox.shrink());
    model.dispose();
  });
}
