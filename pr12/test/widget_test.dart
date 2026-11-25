import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:pr11/core/api/api_client.dart';
import 'package:pr11/core/storage/secure_store.dart';
import 'package:pr11/features/auth/auth_model.dart';
import 'package:pr11/features/settings/settings_model.dart';
import 'package:pr11/features/users/user_repository.dart';
import 'package:pr11/features/users/users_model.dart';
import 'package:pr11/features/users/users_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Use a fake storage during widget tests.
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('Users screen shows title and new-user action', (
    WidgetTester tester,
  ) async {
    final prefs = SharedPreferencesAsync();
    final store = SecureStore();

    final api = ApiClient.create(store);
    final repository = UserRepository(api);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => SettingsModel(prefs, false, null),
          ),
          ChangeNotifierProvider(create: (_) => AuthModel(store, null)),
          ChangeNotifierProvider(create: (_) => UsersModel(repository)),
        ],
        child: const MaterialApp(home: UsersScreen()),
      ),
    );

    expect(find.text('Users — Practice 12'), findsOneWidget);

    expect(find.byIcon(Icons.person_add), findsOneWidget);

    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
