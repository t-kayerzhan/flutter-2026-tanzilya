import 'package:flutter/material.dart';

import 'detail_screen.dart';
import 'edit_screen.dart';
import 'routes.dart';
import 'students.dart';
import 'students_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    ),
    initialRoute: Routes.students,
    routes: {Routes.students: (_) => const StudentsScreen()},
    onGenerateRoute: (settings) {
      final args = settings.arguments;
      if (args is! Student) return null;
      return switch (settings.name) {
        Routes.student => MaterialPageRoute(
          settings: settings,
          builder: (_) => DetailScreen(student: args),
        ),
        Routes.edit => MaterialPageRoute<String>(
          settings: settings,
          builder: (_) => EditScreen(student: args),
        ),
        _ => null,
      };
    },
  );
}
