import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

class StudentsFutureScreen extends StatefulWidget {
  const StudentsFutureScreen({super.key, required this.api});

  final FakeApi api;

  @override
  State<StudentsFutureScreen> createState() => _StudentsFutureScreenState();
}

class _StudentsFutureScreenState extends State<StudentsFutureScreen> {
  late Future<List<Student>> _future;
  bool _compact = false;

  @override
  void initState() {
    super.initState();
    _future = widget.api.fetchStudents();
  }

  void _retry() {
    // Only retry creates another Future; build must reuse this field.
    setState(() => _future = widget.api.fetchStudents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students — FutureBuilder'),
        actions: [
          const Center(child: Text('Compact')),
          Switch(
            value: _compact,
            onChanged: (value) => setState(() => _compact = value),
          ),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorView(onRetry: _retry);
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          final list = snapshot.data ?? const <Student>[];
          if (list.isEmpty) {
            return const EmptyView();
          }
          return StudentList(students: list, compact: _compact);
        },
      ),
    );
  }
}
