import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/format.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onFavourite,
  });

  final Event event;
  final VoidCallback onTap;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = event.isPast ? scheme.outline : null;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(event: event),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDate(event.when),
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                    Text(
                      event.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: event.favourite ? 'Remove favourite' : 'Add favourite',
                onPressed: onFavourite,
                icon: Icon(
                  event.favourite ? Icons.favorite : Icons.favorite_border,
                  color: event.favourite ? scheme.error : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (:free, taken: _) = event.places;
    final badge = event.isFull ? 'FULL' : (free <= 5 ? '$free left' : null);
    final badgeBg = event.isFull ? scheme.error : scheme.tertiary;
    final badgeFg = event.isFull ? scheme.onError : scheme.onTertiary;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: event.category.color(scheme),
          foregroundColor: scheme.onSurface,
          child: Icon(event.category.icon),
        ),
        if (badge != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: -8,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Text(
                    badge,
                    style: theme.textTheme.labelSmall?.copyWith(color: badgeFg),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
