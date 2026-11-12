import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

enum CountdownMode { builder, manual }

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  CountdownMode _mode = CountdownMode.builder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Column(
        children: [
          const SizedBox(height: 24),
          SegmentedButton<CountdownMode>(
            segments: const [
              ButtonSegment(
                value: CountdownMode.builder,
                label: Text('A: StreamBuilder'),
              ),
              ButtonSegment(
                value: CountdownMode.manual,
                label: Text('B: listen'),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) {
              setState(() => _mode = selection.first);
            },
          ),
          Expanded(
            child: _mode == CountdownMode.builder
                ? const _StreamCountdown()
                : const _ManualCountdown(),
          ),
        ],
      ),
    );
  }
}

class _StreamCountdown extends StatefulWidget {
  const _StreamCountdown();

  @override
  State<_StreamCountdown> createState() => _StreamCountdownState();
}

class _StreamCountdownState extends State<_StreamCountdown> {
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _stream,
      builder: (context, snapshot) {
        return Center(
          child: Text(
            '${snapshot.data ?? 10}',
            style: Theme.of(context).textTheme.displayLarge,
          ),
        );
      },
    );
  }
}

class _ManualCountdown extends StatefulWidget {
  const _ManualCountdown();

  @override
  State<_ManualCountdown> createState() => _ManualCountdownState();
}

class _ManualCountdownState extends State<_ManualCountdown> {
  int _left = 10;
  late final StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((value) {
      setState(() => _left = value);
    });
  }

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$_left', style: Theme.of(context).textTheme.displayLarge),
    );
  }
}
