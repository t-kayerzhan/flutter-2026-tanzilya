import '../models/event.dart';

int _byDate(Event a, Event b) {
  if (a.isPast != b.isPast) return a.isPast ? 1 : -1; // past items last
  return a.isPast ? b.when.compareTo(a.when) : a.when.compareTo(b.when);
}

/// Returns a sorted copy; the input is never changed.
List<Event> sortedByDate(Iterable<Event> events) => [...events]..sort(_byDate);
