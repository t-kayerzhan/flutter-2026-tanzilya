import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/event.dart';
import '../routes.dart';
import '../tabs/events_tab.dart';
import '../tabs/favourites_tab.dart';
import '../tabs/profile_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.themeMode,
    required this.onThemeMode,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeMode;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _titles = ['Events', 'Favourites', 'Profile'];

  List<Event> _events = seedEvents();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  void _goToTab(int index) => setState(() => _tab = index);

  void _onChanged(Event updated) => setState(() {
    _events = [for (final e in _events) e.id == updated.id ? updated : e];
  });

  void _onDelete(String id) => setState(() {
    _events = _events.where((e) => e.id != id).toList();
  });

  void _toggleFavourite(Event e) =>
      _onChanged(e.copyWith(favourite: !e.favourite));

  void _openDetail(Event e) {
    Navigator.of(context).pushNamed(
      Routes.detail,
      arguments: DetailArgs(
        event: e,
        profile: _profile,
        onChanged: _onChanged,
        onDelete: _onDelete,
        onGoToTab: _goToTab,
      ),
    );
  }

  Future<void> _add() async {
    final event = await Navigator.of(context)
        .pushNamed<Event>(Routes.form, arguments: const FormArgs());
    if (event == null || !mounted) return;
    setState(() => _events = [..._events, event]);
  }

  Future<void> _about() async {
    Navigator.of(context).pop(); // close the drawer
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Campus Events: Mobile Development, Lab 1. '
          'All data lives in memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _reset() async {
    Navigator.of(context).pop(); // close the drawer
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'Events return to the seed data and the profile is cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _events = seedEvents();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_titles[_tab])),
    drawer: Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: _about,
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: const Text('Reset data'),
              onTap: _reset,
            ),
          ],
        ),
      ),
    ),
    body: IndexedStack(
      index: _tab,
      children: [
        EventsTab(
          events: _events,
          onOpen: _openDetail,
          onToggleFavourite: _toggleFavourite,
        ),
        FavouritesTab(
          events: _events,
          onOpen: _openDetail,
          onToggleFavourite: _toggleFavourite,
        ),
        ProfileTab(
          profile: _profile,
          events: _events,
          themeMode: widget.themeMode,
          onProfile: (p) => setState(() => _profile = p),
          onThemeMode: widget.onThemeMode,
        ),
      ],
    ),
    floatingActionButton: _tab == 0
        ? FloatingActionButton(
            onPressed: _add,
            tooltip: 'New event',
            child: const Icon(Icons.add),
          )
        : null,
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: _goToTab,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
        NavigationDestination(icon: Icon(Icons.favorite), label: 'Favourites'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ],
    ),
  );
}
