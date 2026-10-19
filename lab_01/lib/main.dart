import 'package:flutter/material.dart';

import 'models/event.dart';
import 'routes.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';
import 'screens/shell.dart';
import 'theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Campus Events',
    theme: buildTheme(Brightness.light),
    darkTheme: buildTheme(Brightness.dark),
    themeMode: _themeMode,
    initialRoute: Routes.shell,
    routes: {
      Routes.shell: (_) => AppShell(
        themeMode: _themeMode,
        onThemeMode: (mode) => setState(() => _themeMode = mode),
      ),
    },
    onGenerateRoute: _onGenerateRoute,
    onUnknownRoute: (settings) => MaterialPageRoute<void>(
      settings: settings,
      builder: (context) => const NotFoundScreen(),
    ),
  );
}

Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
  final args = settings.arguments;
  if (settings.name == Routes.detail && args is DetailArgs) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => DetailScreen(args: args),
    );
  }
  if (settings.name == Routes.form && args is FormArgs) {
    return MaterialPageRoute<Event>(
      settings: settings,
      builder: (_) => FormScreen(event: args.event),
    );
  }
  return null;
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Not found')),
    body: const Center(child: Text('Not found')),
  );
}
