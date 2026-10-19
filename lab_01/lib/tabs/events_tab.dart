import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/sort.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_results.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Event> events;
  final ValueChanged<Event> onOpen;
  final ValueChanged<Event> onToggleFavourite;

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final _search = TextEditingController();
  EventCategory? _category;
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(Event e) {
    final query = _search.text.trim().toLowerCase();
    return (_category == null || e.category == _category) &&
        (_showPast || !e.isPast) &&
        (query.isEmpty || e.title.toLowerCase().contains(query));
  }

  void _clearFilters() => setState(() {
    _search.clear();
    _category = null;
    _showPast = false;
  });

  @override
  Widget build(BuildContext context) {
    final visible = sortedByDate(widget.events.where(_matches));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: _search,
            // the controller already holds the text; rebuild to re-filter
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search events',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(_search.clear),
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('All'),
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
              ),
              for (final c in EventCategory.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(c.icon),
                    label: Text(c.label),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
                ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FilterChip(
              label: const Text('Past events'),
              selected: _showPast,
              onSelected: (v) => setState(() => _showPast = v),
            ),
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? (widget.events.isEmpty
                    ? const EmptyState(
                        icon: Icons.event_busy,
                        message: 'No events yet. Tap + to add one.',
                      )
                    : EmptyState(
                        icon: Icons.search_off,
                        message: 'No events match your filters.',
                        buttonLabel: 'Clear filters',
                        onPressed: _clearFilters,
                      ))
              : EventResults(
                  events: visible,
                  onOpen: widget.onOpen,
                  onToggleFavourite: widget.onToggleFavourite,
                ),
        ),
      ],
    );
  }
}
