import 'package:flutter/material.dart';

import '../models/event.dart';
import 'event_card.dart';

/// Phone: separated list. 600 px and wider: grid with cells up to 360 px.
/// Decided by LayoutBuilder: it measures this widget, not the whole screen.
class EventResults extends StatelessWidget {
  const EventResults({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Event> events;
  final ValueChanged<Event> onOpen;
  final ValueChanged<Event> onToggleFavourite;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      Widget card(Event e) => EventCard(
        event: e,
        onTap: () => onOpen(e),
        onFavourite: () => onToggleFavourite(e),
      );

      if (constraints.maxWidth >= 600) {
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 360,
            mainAxisExtent: 140,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: events.length,
          itemBuilder: (context, i) => card(events[i]),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: events.length,
        separatorBuilder: (context, i) => const SizedBox(height: 8),
        itemBuilder: (context, i) => card(events[i]),
      );
    },
  );
}
