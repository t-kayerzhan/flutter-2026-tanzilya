import 'dart:async';

import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key, required this.api});

  final FakeApi api;

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students;
  Object? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await widget.api.fetchStudents();
      if (!mounted) return;
      setState(() => _students = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _save() async {
    if (_saving || _students == null || _students!.isEmpty) return;
    setState(() => _saving = true);
    try {
      await widget.api.save(_students!.length);
      if (!mounted) return;
      Navigator.pop(context);
    } on StateError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_error != null) {
      content = ErrorView(onRetry: () => unawaited(_load()));
    } else if (_students == null) {
      content = const LoadingView();
    } else if (_students!.isEmpty) {
      content = const EmptyView();
    } else {
      content = StudentList(students: _students!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students — by hand'),
        actions: [
          IconButton(
            tooltip: 'Reload students',
            onPressed: () => unawaited(_load()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: content,
      floatingActionButton: _students != null && _students!.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _saving ? null : _save,
              label: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
              icon: _saving ? null : const Icon(Icons.save),
            )
          : null,
    );
  }
}
