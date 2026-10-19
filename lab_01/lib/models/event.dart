import 'package:flutter/material.dart';

enum EventCategory {
  tech('Tech', Icons.code),
  sports('Sports', Icons.sports_soccer),
  music('Music', Icons.music_note),
  art('Art', Icons.palette),
  career('Career', Icons.work);

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    EventCategory.tech => scheme.primaryContainer,
    EventCategory.sports => scheme.secondaryContainer,
    EventCategory.music => scheme.tertiaryContainer,
    EventCategory.art => scheme.errorContainer,
    EventCategory.career => scheme.surfaceContainerHighest,
  };
}

sealed class Countdown {
  const Countdown();
}

final class Upcoming extends Countdown {
  const Upcoming(this.left);
  final Duration left;
}

final class Started extends Countdown {
  const Started(this.ago);
  final Duration ago;
}

final class Ended extends Countdown {
  const Ended();
}

@immutable
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.when,
    required this.limit,
    required this.place,
    List<String> attendees = const [],
    this.online = false,
    this.description,
    this.favourite = false,

    // ignore: prefer_initializing_formals
  }) : _attendees = attendees;

  Event.empty()
    : this(
        id: '',
        title: '',
        category: EventCategory.tech,
        when: DateTime.now(),
        limit: 30,
        place: '',
      );

  final String id;
  final String title;
  final EventCategory category;
  final DateTime when;
  final int limit;
  final String place;
  final bool online;
  final String? description;
  final bool favourite;
  final List<String> _attendees;

  /// Read-only view: callers cannot mutate the stored list.
  List<String> get attendees => List.unmodifiable(_attendees);

  int get count => _attendees.length;
  int get free => limit - count;
  bool get isFull => count >= limit;
  bool get isPast => when.isBefore(DateTime.now());
  bool contains(String name) => _attendees.contains(name);

  ({int taken, int free}) get places => (taken: count, free: free);

  Countdown countdown(DateTime now) {
    if (now.isBefore(when)) return Upcoming(when.difference(now));
    final ago = now.difference(when);
    return ago < const Duration(hours: 3) ? Started(ago) : const Ended();
  }

  Event withAttendee(String name) => copyWith(attendees: [..._attendees, name]);

  Event withoutAttendee(String name) => copyWith(
    attendees: [
      for (final n in _attendees)
        if (n != name) n,
    ],
  );

  Event copyWith({
    String? id,
    String? title,
    EventCategory? category,
    DateTime? when,
    int? limit,
    String? place,
    List<String>? attendees,
    bool? online,
    String? description,
    bool clearDescription = false,
    bool? favourite,
  }) => Event(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    when: when ?? this.when,
    limit: limit ?? this.limit,
    place: place ?? this.place,
    attendees: attendees ?? _attendees,
    online: online ?? this.online,
    description: clearDescription ? null : (description ?? this.description),
    favourite: favourite ?? this.favourite,
  );
}

@immutable
class Profile {
  const Profile({required this.name, required this.group});
  const Profile.empty() : this(name: '', group: '');

  final String name;
  final String group;

  Profile copyWith({String? name, String? group}) =>
      Profile(name: name ?? this.name, group: group ?? this.group);
}
