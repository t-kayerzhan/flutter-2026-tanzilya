import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'countdown_screen.dart';
import 'students_future_screen.dart';
import 'students_screen.dart';

void main() => runApp(const StudentsApp());
/*
void main() {
  debugPrint('A');

  Future.delayed(
    const Duration(seconds: 2),
        () => debugPrint('B'),
  );

  debugPrint('C');

  final api = FakeApi();

  api.fetchStudents().then(
        (list) => debugPrint('${list.length} students'),
  );

  runApp(const StudentsApp());
}
*/


class StudentsApp extends StatelessWidget {
  const StudentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Students Async',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // One API instance keeps fetch/save call counters across screen visits.
  final FakeApi _api = FakeApi();
  //final FakeApi _api = FakeApi(empty: true);

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practice 10')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _open(StudentsScreen(api: _api)),
              child: const Text('By hand'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _open(StudentsFutureScreen(api: _api)),
              child: const Text('FutureBuilder'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _open(const CountdownScreen()),
              child: const Text('Countdown'),
            ),
          ],
        ),
      ),
    );
  }
}
