import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/sort.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_results.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Event> events;
  final ValueChanged<Event> onOpen;
  final ValueChanged<Event> onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final favourites = sortedByDate(events.where((e) => e.favourite));
    if (favourites.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet. Tap the heart on an event.',
      );
    }
    return EventResults(
      events: favourites,
      onOpen: onOpen,
      onToggleFavourite: onToggleFavourite,
    );
  }
}
