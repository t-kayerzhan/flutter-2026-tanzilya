import 'dart:async';

import 'package:flutter/material.dart';

import '../models/event.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

enum _MenuAction { edit, delete }

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Event _event = widget.args.event;
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _countdownText(Countdown c) => switch (c) {
    Upcoming(:final left) => 'Starts in ${formatDuration(left)}',
    Started(:final ago) => 'Started ${formatDuration(ago)} ago',
    Ended() => 'Ended',
  };

  Future<void> _primary() async {
    final name = widget.args.profile.name;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Set your name in the profile first'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () {
              Navigator.of(context).pop();
              widget.args.onGoToTab(2);
            },
          ),
        ),
      );
      return;
    }
    if (_event.contains(name)) {
      final updated = _event.withoutAttendee(name);
      setState(() => _event = updated);
      widget.args.onChanged(updated);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Register?'),
        content: Text('Register for "${_event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Register'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final updated = _event.withAttendee(name);
    setState(() => _event = updated);
    widget.args.onChanged(updated);
  }

  Future<void> _edit() async {
    final edited = await Navigator.of(context)
        .pushNamed<Event>(Routes.form, arguments: FormArgs(event: _event));
    if (edited == null || !mounted) return; // backed out, or we are gone
    setState(() => _event = edited);
    widget.args.onChanged(edited);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text('"${_event.title}" will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    widget.args.onDelete(_event.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final name = widget.args.profile.name;
    final joined = name.isNotEmpty && _event.contains(name);
    final canAct = joined || (!_event.isFull && !_event.isPast);
    final (:taken, :free) = _event.places;
    final names = _event.attendees;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: (action) {
                switch (action) {
                  case _MenuAction.edit:
                    _edit();
                  case _MenuAction.delete:
                    _delete();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
                PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: AspectRatio(
                aspectRatio: 16 / 7,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/header.png', fit: BoxFit.cover),
                    Center(
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: _event.category.color(scheme),
                        foregroundColor: scheme.onSurface,
                        child: Icon(_event.category.icon, size: 36),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Chip(label: Text(_event.category.label)),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Chip(
                        label: Text(_countdownText(_event.countdown(_now))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Names (${_event.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.event),
                        title: Text(formatDate(_event.when)),
                      ),
                      ListTile(
                        leading: Icon(_event.online ? Icons.link : Icons.place),
                        title: Text(_event.place),
                      ),
                      ListTile(
                        leading: const Icon(Icons.people),
                        title: Text('$taken of ${_event.limit} places taken'),
                        subtitle: Text('$free free'),
                      ),
                      if (_event.description case final text?)
                        ListTile(
                          leading: const Icon(Icons.notes),
                          title: Text(text),
                        ),
                    ],
                  ),
                  names.isEmpty
                      ? const EmptyState(
                          icon: Icons.group_off,
                          message: 'Nobody has registered yet.',
                        )
                      : ListView.builder(
                          itemCount: names.length,
                          itemBuilder: (context, i) {
                            final n = names[i];
                            final you = n == name;
                            return ListTile(
                              tileColor: you ? scheme.primaryContainer : null,
                              leading: CircleAvatar(child: Text(n[0])),
                              title: Text(
                                you ? '$n (You)' : n,
                                style: you
                                    ? theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      )
                                    : null,
                              ),
                              trailing: you
                                  ? const Icon(Icons.check_circle)
                                  : null,
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: canAct ? _primary : null,
              child: Text(joined ? 'Leave' : 'Register'),
            ),
          ),
        ),
      ),
    );
  }
}
